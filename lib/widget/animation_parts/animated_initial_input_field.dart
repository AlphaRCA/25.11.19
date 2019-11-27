import 'package:flutter/material.dart';
import 'package:hold/constants/app_colors.dart';
import 'package:hold/widget/stick_container.dart';
import 'package:hold/widget/stick_position.dart';

class AnimatedInitialInputField extends StatefulWidget {
  final Widget child;
  final Offset initialOffset;
  final double height;
  final StickPosition finalStickPosition;
  final Color backgroundColor;
  final Color initialColor;

  const AnimatedInitialInputField(
    this.child,
    this.initialOffset,
    this.height, {
    Key key,
    this.finalStickPosition = StickPosition.left,
    this.backgroundColor = AppColors.LIGHT_BACKGROUND,
    this.initialColor,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _AnimatedInitialInputFieldState();
  }
}

class _AnimatedInitialInputFieldState extends State<AnimatedInitialInputField> {
  double top, height, left, right;
  bool isAnimationFinished = false;
  GlobalKey stackKey = new GlobalKey();
  BorderRadius radius;
  final Duration animationDuration = Duration(milliseconds: 600);
  Color color;

  @override
  void initState() {
    super.initState();
    top = widget.initialOffset.dy;
    height = widget.height;
    left = 16.0;
    right = 16.0;
    radius = StickContainer.getBordersForStick(StickPosition.center);
    color = widget.initialColor ?? widget.backgroundColor;
    print(
        "during creating this widget the parameters are ${widget.height}, ${widget.initialOffset}");
    WidgetsBinding.instance.addPostFrameCallback(_afterBuild);
  }

  @override
  Widget build(BuildContext context) {
    if (isAnimationFinished) {
      return widget.child;
    } else {
      return Stack(
        key: stackKey,
        children: <Widget>[
          AnimatedPositioned(
            left: left,
            right: right,
            top: top,
            height: height,
            curve: Curves.decelerate,
            duration: animationDuration,
            child: AnimatedContainer(
              curve: Curves.decelerate,
              duration: animationDuration,
              height: height,
              decoration: BoxDecoration(color: color, borderRadius: radius),
            ),
          ),
        ],
      );
    }
  }

  void _afterBuild(Duration timeStamp) {
    print("after build block size is ${stackKey.currentContext.size}");
    print("screen size is ${MediaQuery.of(context).size}");
    setState(() {
      top = 16.0;
      height = stackKey.currentContext.size.height - 32.0;
      radius = StickContainer.getBordersForStick(widget.finalStickPosition);
      left = StickContainer.getLeftPaddingForStick(widget.finalStickPosition);
      right = StickContainer.getRightPaddingForStick(widget.finalStickPosition);
      color = widget.backgroundColor;
    });
    Future.delayed(animationDuration).then((_) {
      onAnimationFinished();
    });
  }

  void onAnimationFinished() {
    print("animation completed");
    setState(() {
      isAnimationFinished = true;
    });
  }
}
