import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hold/widget/dialogs/general_toast.dart';

class ToastSectionDeleted extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GeneralToast(
      "Part of the\ncollection\ndeleted",
      image: SvgPicture.asset(
        'assets/material_icons/rounded/action/delete_outline.svg',
        color: Colors.white,
      ),
    );
  }
}
