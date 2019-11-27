import 'package:flutter/material.dart';
import 'package:hold/constants/app_colors.dart';
import 'package:hold/constants/app_sizes.dart';

class BottomInfoSheet extends StatefulWidget {
  final String title;
  final String text;

  const BottomInfoSheet(
    this.title,
    this.text, {
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _BottomInfoSheetState();
  }
}

class _BottomInfoSheetState extends State<BottomInfoSheet>
    with SingleTickerProviderStateMixin {
  AnimationController animationController;
  final animationDuration = Duration(milliseconds: 400);
  GlobalKey<ScaffoldState> scaffoldState = new GlobalKey();
  int routeCount = 1;

  @override
  void initState() {
    animationController = AnimationController(
      vsync: this,
      duration: animationDuration,
      reverseDuration: animationDuration,
    );
    animationController.addListener(_closeScreen);
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(showInfo);
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldState,
      backgroundColor: AppColors.BOTTOM_SHEET_FADER,
      body: GestureDetector(
        onTap: close,
      ),
    );
  }

  void close() {
    animationController.animateTo(0.0,
        duration: animationDuration, curve: Curves.easeInOut);
    Navigator.of(context).pop();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pop();
    });
  }

  void _closeScreen() {
    print("status: ${animationController.status}");
    if (animationController.status == AnimationStatus.completed) {
      print("ANIMATION COMPLETED");
      Navigator.of(context).pop();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pop();
      });
    }
  }

  void showInfo(_) {
    scaffoldState.currentState.showBottomSheet((BuildContext ctxt) {
      return BottomSheet(
        animationController: animationController,
        elevation: 0,
        backgroundColor: AppColors.TRANSPARENT,
        onClosing: () {},
        builder: (BuildContext context) {
          return Container(
            decoration: BoxDecoration(
              color: AppColors.DIALOG_REMINDER_BG,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppSizes.BORDER_RADIUS),
                topRight: Radius.circular(AppSizes.BORDER_RADIUS),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(40.0, 8, 0, 24),
                        child: Container(
                          padding: EdgeInsets.all(14.0),
                          child: Icon(
                            Icons.info_outline,
                            color: Colors.white,
                            size: 28,
                          ),
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.BOTTOM_SHEET_BG,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.BOTTOM_SHEET_HALO,
                                  spreadRadius:
                                      4.0, // has the effect of extending the shadow
                                ),
                                BoxShadow(
                                  color: AppColors.BOTTOM_SHEET_HALO,
                                  spreadRadius:
                                      16.0, // has the effect of extending the shadow
                                ),
                                BoxShadow(
                                  color: AppColors.BOTTOM_SHEET_HALO,
                                  spreadRadius:
                                      24.0, // has the effect of extending the shadow
                                ),
                              ]),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: AppColors.BOTTOM_SHEET_ICONS,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          Navigator.of(context).pop();
                        });
                      },
                    ),
                  ],
                ),
                Container(
                  child: Padding(
                    padding: EdgeInsets.only(left: 16.0, bottom: 12.0),
                    child: Text(
                      "Why this can help...",
                      style: TextStyle(
                          color: AppColors.BOTTOM_SHEET_TEXT,
                          fontSize: 21,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                      color: AppColors.BOTTOM_SHEET_ICONS,
                      width: 1.0,
                    )),
                  ),
                ),
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        widget.title,
                        textScaleFactor: 1.4,
                        style: TextStyle(
                            color: AppColors.BOTTOM_SHEET_TEXT,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      Text(
                        widget.text,
                        style: TextStyle(
                          color: AppColors.BOTTOM_SHEET_TEXT,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 16,
                )
              ],
            ),
          );
        },
      );
    }, backgroundColor: AppColors.TRANSPARENT, elevation: 0);
  }
}
