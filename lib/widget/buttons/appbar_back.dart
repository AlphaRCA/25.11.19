import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hold/constants/app_colors.dart';

class AppBarBack extends StatelessWidget {
  final WillPopCallback onTap;

  const AppBarBack({Key key, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
        key: Key("back"),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Padding(
            padding: EdgeInsets.all(4.0),
            child: SvgPicture.asset(
              'assets/material_icons/rounded/navigation/chevron_left.svg',
              color: AppColors.TEXT.withOpacity(0.52),
            ),
          ),
        ),
        onTap: () async {
          if (onTap == null) {
            Navigator.of(context).pop();
          } else {
            bool tapFuncResult = await onTap();
            if (tapFuncResult ?? false) {
              Navigator.of(context).pop();
            }
          }
        });
  }
}
