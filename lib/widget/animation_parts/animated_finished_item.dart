import 'package:flutter/material.dart';

import 'animation_setting.dart';

class AnimatedFinishedItem extends StatefulWidget {
  final WidgetKeyDependent child;
  final GlobalKey childKey;
  final AnimationSetting animationSetting;

  const AnimatedFinishedItem(
      {Key key,
      @required this.child,
      @required this.animationSetting,
      this.childKey})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _AnimatedFinishedItemState();
  }
}

class _AnimatedFinishedItemState extends State<AnimatedFinishedItem> {
  double leftPosition;
  double calculatedHeight, calculatedWidth;
  GlobalKey visibilityKey = new GlobalKey();
  final Duration animationDuration = Duration(milliseconds: 600);
  final Curve animationCurve = Curves.decelerate;

  @override
  void initState() {
    leftPosition = widget.animationSetting.initialLeft;
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(_afterBuild);
  }

  @override
  Widget build(BuildContext context) {
    if (calculatedHeight == null) {
      return Opacity(
        key: visibilityKey,
        opacity: 0,
        child: widget.child(),
      );
    } else {
      return Container(
        height: calculatedHeight,
        child: Stack(
          children: <Widget>[
            AnimatedPositioned(
              left: leftPosition,
              top: 0,
              width: calculatedWidth,
              curve: animationCurve,
              duration: animationDuration,
              child: widget.child(key: widget.childKey),
            ),
          ],
        ),
      );
    }
  }

  void _afterBuild(Duration timeStamp) {
    print("after build");
    if (calculatedHeight == null) {
      calculatedWidth = visibilityKey.currentContext.size.width;
      setState(() {
        calculatedHeight = visibilityKey.currentContext.size.height;
      });
      print("calculated height became $calculatedHeight");
      print("old position is $leftPosition");
      WidgetsBinding.instance.addPostFrameCallback(_afterBuild);
    } else {
      print("do animation");
      setState(() {
        leftPosition = widget.animationSetting.resultLeft;
      });
      print("new position will be $leftPosition");
    }
  }
}

typedef Widget WidgetKeyDependent({GlobalKey key});
