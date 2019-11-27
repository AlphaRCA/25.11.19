import 'package:flutter/material.dart';
import 'package:hold/widget/buttons/appbar_back.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ImproveHoldScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: AppBarBack(),
        title: Text('Improve HOLD'),
        centerTitle: true,
      ),
      body: WebView(
        initialUrl: 'https://servdes.typeform.com/to/Vty5mF',
        javascriptMode: JavascriptMode.unrestricted,
      ),
    );
  }
}
