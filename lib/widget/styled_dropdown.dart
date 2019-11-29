import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hold/constants/app_colors.dart';
import 'package:hold/constants/app_sizes.dart';
import 'package:hold/constants/app_styles.dart';

class StyledDropdown extends StatelessWidget {
  final Map<String, String> values;
  final String selectedValue;
  final ValueChanged<String> onSelect;

  const StyledDropdown(
    this.values,
    this.selectedValue,
    this.onSelect, {
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (values == null || values.length == 0) return Container();
    return Container(
        padding: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            side: BorderSide(
                width: 1.0, style: BorderStyle.solid, color: AppColors.TEXT),
            borderRadius:
                BorderRadius.all(Radius.circular(AppSizes.BORDER_RADIUS)),
          ),
        ),
        child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
          icon: SvgPicture.asset(
            'assets/material_icons/rounded/navigation/expand_more.svg',
            width: 12.0,
            color: Colors.white,
          ),
          value: selectedValue ?? values.keys.elementAt(0),
          onChanged: onSelect,
          items: values.entries.map((MapEntry<String, String> language) {
            return new DropdownMenuItem<String>(
              child: new Text(
                language.value,
                style: AppStyles.PROFILE_TEXT,
              ),
              value: language.key,
            );
          }).toList(),
        )));
  }
}
