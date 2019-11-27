import 'package:flutter/material.dart';
import 'package:hold/constants/app_colors.dart';
import 'package:hold/main.dart';
import 'package:hold/main_screen.dart';

class InitialScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _InitialScreenState();
  }
}

class _InitialScreenState extends State<InitialScreen> {
  NavigatorObserver navigatorObserver;
  @override
  void initState() {
    super.initState();
    _initRedirect();
  }

  @override
  Widget build(BuildContext context) {
    MyApp.screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 6,
            child: Padding(
              padding: EdgeInsets.all(40),
              child: Align(
                child: Image.asset(
                  "assets/logo.png",
                  width: MediaQuery.of(context).size.width / 4,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              "Take hold of your thoughts",
              style: TextStyle(color: AppColors.TEXT, fontSize: 17.25),
            ),
          )
        ],
      ),
    );
  }

  void _initRedirect() async {
    await Future.delayed(Duration(seconds: 2));
    _openMainScreen();
  }

  void _openMainScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MainScreen()),
    );
  }
}
