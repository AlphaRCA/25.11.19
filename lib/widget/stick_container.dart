import 'package:flutter/material.dart';
import 'package:hold/constants/app_colors.dart';
import 'package:hold/constants/app_sizes.dart';
import 'package:hold/widget/animation_parts/animation_setting.dart';
import 'package:hold/widget/stick_position.dart';

class StickContainer extends StatelessWidget {
  static const _OUTER_PADDING = 24.0;

  final Widget child;
  final StickPosition position;
  final Color background;
  final double heightLimited;

  const StickContainer(
    this.child, {
    Key key,
    this.position = StickPosition.center,
    this.background = AppColors.ACTION_LIGHT,
    this.heightLimited,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(getLeftPaddingForStick(position), 8,
          getRightPaddingForStick(position), 8),
      child: Container(
        height: heightLimited,
        decoration: BoxDecoration(
            color: background, borderRadius: getBordersForStick(position)),
        padding: EdgeInsets.all(8.0),
        child: child,
      ),
    );
  }

  static BorderRadius getBordersForStick(StickPosition stickPosition) {
    List<double> cornerRadius = new List.filled(4, AppSizes.BORDER_RADIUS);
    switch (stickPosition) {
      case StickPosition.center:
        break;
      case StickPosition.left:
        cornerRadius[0] = 0;
        cornerRadius[2] = 0;
        break;
      case StickPosition.right:
        cornerRadius[1] = 0;
        cornerRadius[3] = 0;
        break;
    }
    return BorderRadius.only(
      topLeft: Radius.circular(cornerRadius[0]),
      topRight: Radius.circular(cornerRadius[1]),
      bottomLeft: Radius.circular(cornerRadius[2]),
      bottomRight: Radius.circular(cornerRadius[3]),
    );
  }

  static double getLeftPaddingForStick(StickPosition stickPosition) {
    double leftPadding;
    switch (stickPosition) {
      case StickPosition.center:
        leftPadding = _OUTER_PADDING;
        break;
      case StickPosition.left:
        leftPadding = 0;
        break;
      case StickPosition.right:
        leftPadding = _OUTER_PADDING;
        break;
    }
    return leftPadding;
  }

  static double getRightPaddingForStick(StickPosition stickPosition) {
    double rightPadding;
    switch (stickPosition) {
      case StickPosition.center:
        rightPadding = _OUTER_PADDING;
        break;
      case StickPosition.left:
        rightPadding = _OUTER_PADDING;
        break;
      case StickPosition.right:
        rightPadding = 0;
        break;
    }
    return rightPadding;
  }

  static AnimationSetting getAnimationSetting(
      StickPosition stickPosition, double screenWidth) {
    switch (stickPosition) {
      case StickPosition.left:
        return AnimationSetting(-screenWidth, 0, 0, screenWidth);
      case StickPosition.right:
      case StickPosition.center:
      default:
        return AnimationSetting(screenWidth, screenWidth * 2, 0, screenWidth);
    }
  }
}
