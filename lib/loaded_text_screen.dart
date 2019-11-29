import 'package:flutter/material.dart';
import 'package:hold/widget/buttons/appbar_back.dart';
import 'package:webview_flutter/webview_flutter.dart';

class LoadedTextScreen extends StatelessWidget {
  final String title;
  final String webAddress;

  const LoadedTextScreen(
    this.title,
    this.webAddress, {
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print("web-address $webAddress");
    return Scaffold(
      appBar: AppBar(
        leading: AppBarBack(),
        title: Text(title),
      ),
      body: WebView(
        initialUrl: webAddress,
        javascriptMode: JavascriptMode.disabled,
      ),
    );
  }
}
