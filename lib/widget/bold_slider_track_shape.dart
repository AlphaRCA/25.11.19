import 'package:flutter/material.dart';
import 'dart:math';

class BoldSliderTrackShape extends SliderTrackShape {
  static const RADIUS = 1;

  @override
  Rect getPreferredRect({
    RenderBox parentBox,
    Offset offset = Offset.zero,
    SliderThemeData sliderTheme,
    bool isEnabled,
    bool isDiscrete,
  }) {
    final double thumbWidth =
        sliderTheme.thumbShape.getPreferredSize(true, isDiscrete).width;
    final double trackHeight = sliderTheme.trackHeight;
    assert(thumbWidth >= 0);
    assert(trackHeight >= 0);
    assert(parentBox.size.width >= thumbWidth);
    assert(parentBox.size.height >= trackHeight);

    final double trackLeft = offset.dx + thumbWidth / 2;
    final double trackTop =
        offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double trackWidth = parentBox.size.width - thumbWidth;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    RenderBox parentBox,
    SliderThemeData sliderTheme,
    Animation<double> enableAnimation,
    TextDirection textDirection,
    Offset thumbCenter,
    bool isDiscrete,
    bool isEnabled,
  }) {
    if (sliderTheme.trackHeight == 0) {
      return;
    }

    final Rect trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );

    final Paint activePaint = Paint()
      ..color = isEnabled
          ? sliderTheme.activeTrackColor
          : sliderTheme.disabledActiveTrackColor
      ..style = PaintingStyle.fill;

    final Paint inactivePaint = Paint()
      ..color = isEnabled
          ? sliderTheme.inactiveTrackColor
          : sliderTheme.disabledInactiveTrackColor
      ..style = PaintingStyle.fill;

    final pathSegment = Path()
      ..moveTo(trackRect.left, trackRect.top - RADIUS)
      ..lineTo(trackRect.right, trackRect.top - RADIUS)
      ..lineTo(trackRect.right, trackRect.bottom + RADIUS)
      ..lineTo(trackRect.left, trackRect.bottom + RADIUS)
      ..lineTo(trackRect.left, trackRect.top - RADIUS)
      ..arcTo(
        Rect.fromPoints(
          Offset(trackRect.right + RADIUS * 2, trackRect.top - RADIUS),
          Offset(trackRect.right - RADIUS * 2, trackRect.bottom + RADIUS),
        ),
        -pi / 2,
        pi,
        false,
      );

    final activePathSegment = Path()
      ..moveTo(trackRect.left, trackRect.top - RADIUS)
      ..lineTo(thumbCenter.dx, trackRect.top - RADIUS)
      ..lineTo(thumbCenter.dx, trackRect.bottom + RADIUS)
      ..lineTo(trackRect.left, trackRect.bottom + RADIUS)
      ..lineTo(trackRect.left, trackRect.top - RADIUS)
      ..arcTo(
        Rect.fromPoints(
          Offset(trackRect.left + RADIUS * 2, trackRect.top - RADIUS),
          Offset(trackRect.left - RADIUS * 2, trackRect.bottom + RADIUS),
        ),
        -pi * 3 / 2,
        pi,
        false,
      );

    context.canvas
      ..drawPath(pathSegment, inactivePaint)
      ..drawPath(activePathSegment, activePaint)
      ..drawArc(
        Rect.fromPoints(
          Offset(trackRect.left + RADIUS * 2, trackRect.top - RADIUS),
          Offset(trackRect.left - RADIUS * 2, trackRect.bottom + RADIUS),
        ),
        -pi * 3 / 2,
        pi,
        false,
        activePaint,
      );
  }
}
