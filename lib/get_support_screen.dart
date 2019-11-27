import 'package:flutter/material.dart';
import 'package:hold/constants/app_colors.dart';
import 'package:hold/widget/buttons/appbar_back.dart';
import 'package:hold/widget/buttons/green_action.dart';
import 'package:url_launcher/url_launcher.dart';

import 'bloc/mixpanel_provider.dart';

class GetSupportScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    MixPanelProvider().trackEvent(
        "PROFILE", {"Pageview Get Support": DateTime.now().toIso8601String()});
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
    MixPanelProvider().trackEvent("PROFILE",
        {"Click Mind.co.uk button": DateTime.now().toIso8601String()});
    const url = 'https://www.mind.org.uk/';
    if (await canLaunch(url)) {
      await launch(url);
    }
  }

  void _openSamaritans() async {
    MixPanelProvider().trackEvent("PROFILE",
        {"Click Samaritans button": DateTime.now().toIso8601String()});
    const url = 'https://www.samaritans.org/';
    if (await canLaunch(url)) {
      await launch(url);
    }
  }

  void _openNhs() async {
    MixPanelProvider().trackEvent("PROFILE", {
      "Click NHS Advice and Support button": DateTime.now().toIso8601String()
    });
    const url = 'https://www.nhs.uk/';
    if (await canLaunch(url)) {
      await launch(url);
    }
  }
}
