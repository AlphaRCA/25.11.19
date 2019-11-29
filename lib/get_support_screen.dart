import 'package:flutter/material.dart';
import 'package:hold/constants/app_colors.dart';
import 'package:hold/widget/buttons/appbar_back.dart';
import 'package:hold/widget/buttons/green_action.dart';
import 'package:url_launcher/url_launcher.dart';

class GetSupportScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: AppBarBack(),
        title: Text("Get support"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 40.0,
            ),
            Padding(
                padding: EdgeInsets.all(16),
                child: Text("You are not alone",
                    style: TextStyle(
                        color: AppColors.TEXT_EF,
                        fontSize: 21.13,
                        fontWeight: FontWeight.bold))),
            Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                "HOLD is not enough if you are dealing with a mental "
                "health crisis or emergency, please contact your doctor or "
                "see the NHS options in the link below.",
                style: TextStyle(color: AppColors.TEXT_EF, fontSize: 17.25),
              ),
            ),
            GreenAction("Mind.org.uk", _openMindCoUk),
            GreenAction("Samaritans", _openSamaritans),
            SizedBox(
              height: 40,
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                "If you are dealing with a mental health crisis or emergency",
                style: TextStyle(color: AppColors.TEXT_EF, fontSize: 17.25),
              ),
            ),
            GreenAction("NHS advice and support", _openNhs),
          ],
        ),
      ),
    );
  }

  void _openMindCoUk() async {
    const url = 'https://www.mind.org.uk/';
    if (await canLaunch(url)) {
      await launch(url);
    }
  }

  void _openSamaritans() async {
    const url = 'https://www.samaritans.org/';
    if (await canLaunch(url)) {
      await launch(url);
    }
  }

  void _openNhs() async {
    const url = 'https://www.nhs.uk/';
    if (await canLaunch(url)) {
      await launch(url);
    }
  }
}
