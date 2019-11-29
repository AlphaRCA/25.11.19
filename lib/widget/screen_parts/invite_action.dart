import 'package:flutter/material.dart';
import 'package:hold/constants/app_colors.dart';
import 'package:hold/constants/app_sizes.dart';

class InviteAction extends StatelessWidget {
  final Color background;
  final String invite;
  final String title;
  final OnAnimatedClick mainAction;
  final GlobalKey key;
  final GlobalKey containerKey;

  const InviteAction(
    this.title,
    this.invite,
    this.background,
    this.mainAction,
    this.key,
    this.containerKey,
  ) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: GestureDetector(
        onTap: () {
          final RenderBox renderBox = key.currentContext.findRenderObject();
          final RenderBox parentContainerBox =
              containerKey.currentContext.findRenderObject();
          final position = renderBox.localToGlobal(Offset.zero) -
              parentContainerBox.localToGlobal(Offset.zero);
          mainAction(renderBox.size.height, renderBox.size.width, position);
        },
        child: Container(
          padding: EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.all(Radius.circular(AppSizes.BORDER_RADIUS)),
            color: background,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                title,
                style: TextStyle(
                  color: AppColors.INVITE_TEXT_COLOR,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              SizedBox(
                height: 8,
              ),
              Text(
                invite,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.INVITE_TEXT_COLOR,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

typedef Future<Null> OnAnimatedClick(
    double itemHeight, double itemWidth, Offset position);
