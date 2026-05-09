import 'package:flutter/material.dart';

import '../constants/app_constants.dart';

class AppLogoMark extends StatelessWidget {
  final double size;
  final bool showBorder;

  const AppLogoMark({
    super.key,
    this.size = 36,
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).cardColor,
        border:
            showBorder ? Border.all(color: AppConstants.dividerColor) : null,
        boxShadow: [
          BoxShadow(
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/DP.jpeg',
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
