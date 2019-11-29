import 'package:flutter/material.dart';
import 'package:hold/constants/app_colors.dart';

class HoloSliderThumbShape extends SliderComponentShape {
  final double thumbRadius;

  const HoloSliderThumbShape({
    this.thumbRadius = 6.0,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(thumbRadius);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    Animation<double> activationAnimation,
    Animation<double> enableAnimation,
    bool isDiscrete,
    TextPainter labelPainter,
    RenderBox parentBox,
    SliderThemeData sliderTheme,
    TextDirection textDirection,
    double value,
  }) {
    final Canvas canvas = context.canvas;

    final fillPaint = Paint()
      ..color = AppColors.ORANGE_BUTTON_BACKGROUND
      ..style = PaintingStyle.fill
      ..maskFilter = MaskFilter.blur(
          BlurStyle.normal, _convertRadiusToSigma(thumbRadius / 2));

    final colorPaint = Paint()
      ..color = sliderTheme.thumbColor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, thumbRadius, fillPaint);
    canvas.drawCircle(center, thumbRadius, colorPaint);
  }

  double _convertRadiusToSigma(double radius) {
    return radius * 1.57735 + 0.5;
  }
}
