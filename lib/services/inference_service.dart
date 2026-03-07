import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:video_thumbnail/video_thumbnail.dart' as vt;

/// Client for calling the external inference backend hosted on Hugging Face.
class InferenceService {
  static const String _modelAssetPath = 'assets/models/usl_model_flex.tflite';
  static const String _labelsAssetPath = 'assets/data/labels.json';

  static Interpreter? _interpreter;
  static Map<int, String>? _labels;
  static String? _modelTempPath;

  /// Sends a recorded video to the backend and returns the translation.
  /// Throws on network or server error.
  static Future<String> translateVideo(File videoFile) async {
    try {
      final localPrediction = await _translateVideoLocal(videoFile);
      if (localPrediction != null && localPrediction.isNotEmpty) {
        return localPrediction;
      }
      throw Exception('Model returned an empty prediction.');
    } catch (error) {
      throw Exception('Local inference error: $error');
    }
  }

  static Future<String?> _translateVideoLocal(File videoFile) async {
    await _ensureLocalModelLoaded();

    final interpreter = _interpreter;
    if (interpreter == null) return null;

    final inputShape = interpreter.getInputTensor(0).shape;
    final outputShape = interpreter.getOutputTensor(0).shape;

    if (inputShape.length != 5 || outputShape.length != 2) {
      throw Exception('Unexpected model tensor shapes.');
    }

    final sequenceLength = inputShape[1];
    final imageHeight = inputShape[2];
    final imageWidth = inputShape[3];
    final channels = inputShape[4];
    final classes = outputShape[1];

    if (channels != 3) {
      throw Exception(
          'Model expects $channels channels; only RGB (3) is supported.');
    }

    final input = await _buildInputTensor(
      videoFile: videoFile,
      sequenceLength: sequenceLength,
      imageHeight: imageHeight,
      imageWidth: imageWidth,
    );

    final output = List.generate(1, (_) => List.filled(classes, 0.0));
    interpreter.run(input, output);

    final probabilities = output[0];
    var bestIndex = 0;
    var bestScore = probabilities[0];
    for (var index = 1; index < probabilities.length; index++) {
      if (probabilities[index] > bestScore) {
        bestScore = probabilities[index];
        bestIndex = index;
      }
    }

    final label = _labels?[bestIndex] ?? 'class_$bestIndex';
    return label;
  }

  static Future<void> _ensureLocalModelLoaded() async {
    if (_interpreter != null && _labels != null) return;

    try {
      _interpreter ??= await Interpreter.fromAsset(_modelAssetPath);
    } catch (error) {
      try {
        final tempDir = await getTemporaryDirectory();
        final modelBytes = await rootBundle.load(_modelAssetPath);
        final modelFile = File('${tempDir.path}/usl_model_flex.tflite');
        await modelFile.writeAsBytes(
          modelBytes.buffer.asUint8List(),
          flush: true,
        );
        _modelTempPath = modelFile.path;
        _interpreter ??= Interpreter.fromFile(modelFile);
      } catch (fallbackError) {
        throw Exception(
          'Could not load TFLite model. Asset load failed: $error | File fallback failed: $fallbackError',
        );
      }
    }

    if (_interpreter == null) {
      throw Exception('TFLite interpreter initialization returned null.');
    }

    try {
      _interpreter!.allocateTensors();
    } catch (allocateError) {
      throw Exception(
          'Interpreter loaded but tensor allocation failed: $allocateError');
    }

    final labelsJson = await rootBundle.loadString(_labelsAssetPath);
    final decoded = jsonDecode(labelsJson) as Map<String, dynamic>;
    _labels = decoded.map(
      (key, value) => MapEntry(int.parse(key), value.toString()),
    );
  }

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

      final resized = img.copyResize(
        decoded,
        width: imageWidth,
        height: imageHeight,
      );

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
      throw Exception('Could not extract frames from recorded video.');
    }

    return input;
  }

  static Future<Uint8List?> _extractThumbnailBytes(
    String videoPath,
    int timeMs,
  ) async {
    try {
      final bytes = await vt.VideoThumbnail.thumbnailData(
        video: videoPath,
        imageFormat: vt.ImageFormat.PNG,
        timeMs: timeMs,
        quality: 75,
      );
      if (bytes != null) return bytes;
    } catch (_) {
      // Fallback to file-based thumbnail extraction below.
    }

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
      try {
        await file.delete();
      } catch (_) {
        // ignore cleanup failure
      }
      return bytes;
    } catch (_) {
      return null;
    }
  }
}
