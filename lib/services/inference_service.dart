import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_onnxruntime/flutter_onnxruntime.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart' as vt;

class NativeOnnxService {
  static OrtSession? _session;
  static Map<int, String>? _labels;
  static const String _modelAssetPath = 'assets/models/usl_model_flex.onnx';
  static const String _labelsAssetPath = 'assets/data/labels.json';

  static Future<String> translateVideo(File videoFile) async {
    try {
      final label = await _translateVideoLocal(videoFile);
      if (label != null && label.isNotEmpty) {
        return label;
      }
      throw Exception('Model returned an empty prediction.');
    } catch (error) {
      throw Exception('ONNX inference error: $error');
    }
  }

  static Future<String?> _translateVideoLocal(File videoFile) async {
    await _ensureModelLoaded();

    final session = _session;
    if (session == null) return null;

    // Get shapes from the model
    final inputName = session.inputNames.first;
    final outputName = session.outputNames.first;
    // Try to obtain tensor shapes from the session if exposed by the runtime; otherwise fall back to sensible defaults.
    List<int> inputShape;
    List<int> outputShape;
    try {
      final dynamic s = session as dynamic;
      if (s.inputShapes != null && s.inputShapes[inputName] != null) {
        inputShape = (s.inputShapes[inputName] as List).map((e) => e as int).toList();
      } else if (s.inputs != null && s.inputs[inputName] != null && s.inputs[inputName]['shape'] != null) {
        inputShape = (s.inputs[inputName]['shape'] as List).map((e) => e as int).toList();
      } else {
        // Fallback default: [batch, seqLen, height, width, channels]
        inputShape = [1, 16, 224, 224, 3];
      }

      if (s.outputShapes != null && s.outputShapes[outputName] != null) {
        outputShape = (s.outputShapes[outputName] as List).map((e) => e as int).toList();
      } else if (s.outputs != null && s.outputs[outputName] != null && s.outputs[outputName]['shape'] != null) {
        outputShape = (s.outputs[outputName]['shape'] as List).map((e) => e as int).toList();
      } else {
        // Fallback default: [batch, numClasses]
        outputShape = [1, 1000];
      }
    } catch (_) {
      // If any dynamic access fails, use sensible defaults.
      inputShape = [1, 16, 224, 224, 3];
      outputShape = [1, 1000];
    }

    if (inputShape.length != 5 || outputShape.length != 2) {
      throw Exception('Unexpected model tensor shapes.');
    }

    final sequenceLength = inputShape[1] as int;
    final imageHeight = inputShape[2] as int;
    final imageWidth = inputShape[3] as int;
    final channels = inputShape[4] as int;
    final numClasses = outputShape[1] as int;

    if (channels != 3) {
      throw Exception('Model expects $channels channels; only RGB (3) is supported.');
    }

    // Build the 5D input tensor (List of List ...)
    final inputTensorData = await _buildInputTensor(
      videoFile: videoFile,
      sequenceLength: sequenceLength,
      imageHeight: imageHeight,
      imageWidth: imageWidth,
    );

    // Flatten the 5D list into 1D float list for OrtValue
    final flattenedInput = inputTensorData[0]
        .expand((frame) => frame)
        .expand((row) => row)
        .expand((pixel) => pixel)
        .toList()
        .cast<double>();

    // Create OrtValue (float32)
    final inputOrtValue = await OrtValue.fromList(flattenedInput, inputShape.cast<int>());

    // Run inference
    final inputs = {inputName: inputOrtValue};
    final outputs = await session.run(inputs);

    // Get output probabilities
    final outputOrtValue = outputs[outputName]!;
    final probabilities = (await outputOrtValue.asList()).cast<double>();

    // Argmax to find best class
    var bestIndex = 0;
    var bestScore = probabilities[0];
    for (var i = 1; i < probabilities.length; i++) {
      if (probabilities[i] > bestScore) {
        bestScore = probabilities[i];
        bestIndex = i;
      }
    }

    final label = _labels?[bestIndex] ?? 'class_$bestIndex';
    return label;
  }

  static Future<void> _ensureModelLoaded() async {
    if (_session != null && _labels != null) return;

    final ort = OnnxRuntime();

    try {
      _session ??= await ort.createSessionFromAsset(_modelAssetPath);
    } catch (_) {
      // Fallback: copy model to temporary directory
      final tempDir = await getTemporaryDirectory();
      final modelBytes = await rootBundle.load(_modelAssetPath);
      final modelFile = File('${tempDir.path}/usl_model_flex.onnx');
      await modelFile.writeAsBytes(modelBytes.buffer.asUint8List(), flush: true);

      // Some runtimes expose a bytes-based session creation method instead of a path-based one.
      final bytes = await modelFile.readAsBytes();
      _session ??= await ort.createSessionFromBytes(bytes);
    }

    if (_session == null) {
      throw Exception('Failed to create ONNX session');
    }

    // Load labels once
    final labelsJson = await rootBundle.loadString(_labelsAssetPath);
    final decoded = jsonDecode(labelsJson) as Map<String, dynamic>;
    _labels = decoded.map((key, value) => MapEntry(int.parse(key), value.toString()));
  }

  // ==================== Frame processing (unchanged) ====================
  static Future<List<List<List<List<List<double>>>>>> _buildInputTensor({
    required File videoFile,
    required int sequenceLength,
    required int imageHeight,
    required int imageWidth,
  }) async {
    final input = [
      List.generate(
        sequenceLength,
        (_) => List.generate(
          imageHeight,
          (_) => List.generate(imageWidth, (_) => List.filled(3, 0.0)),
        ),
      ),
    ];

    var successfulFrames = 0;
    const frameIntervalMs = 120;
    List<List<List<double>>>? lastFrame;

    for (var frameIndex = 0; frameIndex < sequenceLength; frameIndex++) {
      final timeMs = frameIndex * frameIntervalMs;

      final thumbnail = await _extractThumbnailBytes(videoFile.path, timeMs);

      if (thumbnail == null) {
        if (lastFrame != null) {
          input[0][frameIndex] = lastFrame;
          successfulFrames++;
        }
        continue;
      }

      final decoded = img.decodeImage(thumbnail);
      if (decoded == null) continue;

      final resized = img.copyResize(decoded, width: imageWidth, height: imageHeight);

      for (var y = 0; y < imageHeight; y++) {
        for (var x = 0; x < imageWidth; x++) {
          final pixel = resized.getPixel(x, y);
          input[0][frameIndex][y][x][0] = pixel.r / 255.0;
          input[0][frameIndex][y][x][1] = pixel.g / 255.0;
          input[0][frameIndex][y][x][2] = pixel.b / 255.0;
        }
      }

      lastFrame = input[0][frameIndex];
      successfulFrames++;
    }

    if (successfulFrames == 0) {
      throw Exception('Could not extract any frames from the video.');
    }

    return input;
  }

  static Future<Uint8List?> _extractThumbnailBytes(String videoPath, int timeMs) async {
    try {
      final bytes = await vt.VideoThumbnail.thumbnailData(
        video: videoPath,
        imageFormat: vt.ImageFormat.PNG,
        timeMs: timeMs,
        quality: 75,
      );
      if (bytes != null) return bytes;
    } catch (_) {}

    try {
      final tempDir = await getTemporaryDirectory();
      final thumbPath = await vt.VideoThumbnail.thumbnailFile(
        video: videoPath,
        thumbnailPath: tempDir.path,
        imageFormat: vt.ImageFormat.PNG,
        timeMs: timeMs,
        quality: 75,
      );

      if (thumbPath == null) return null;
      final file = File(thumbPath);
      if (!await file.exists()) return null;

      final bytes = await file.readAsBytes();
      await file.delete().catchError((_) {});
      return bytes;
    } catch (_) {
      return null;
    }
  }
}

extension on OnnxRuntime {
  Future<dynamic> createSessionFromBytes(Uint8List bytes) async {
    // Not all platforms/runtimes expose a bytes-based session creation.
    // Ensure the Future completes with an error rather than returning null.
    throw UnimplementedError('createSessionFromBytes is not implemented on this platform.');
  }
}