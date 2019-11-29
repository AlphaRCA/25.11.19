import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hold/constants/app_colors.dart';

class CollectionAction extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const CollectionAction(
    this.text,
    this.onPressed, {
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          padding: EdgeInsets.fromLTRB(24.0, 12.0, 8.0, 12.0),
          decoration: BoxDecoration(
            borderRadius: new BorderRadius.circular(18.0),
            color: AppColors.PLAY_CONTAINER_BACKGROUND,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                text,
                style: TextStyle(
                  fontSize: 21.13,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SvgPicture.asset(
                  'assets/material_icons/rounded/content/add.svg',
                  height: 14.0,
                  color: Colors.black87,
                  //color: AppColors.REFLECTION_ICON,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
