import 'package:flip_card/flip_card.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hold/bloc/onboarding_bloc.dart';
import 'package:hold/constants/app_colors.dart';
import 'package:hold/initial_screen.dart';
import 'package:hold/widget/buttons/bottom_button.dart';
import 'package:hold/widget/header_text.dart';
import 'package:hold/widget/onboarding_text.dart';
import 'package:hold/widget/screen_parts/profile_page.dart';
import 'constants/app_sizes.dart';
import 'loaded_text_screen.dart';

class OnboardingScreen extends StatefulWidget {
  final OnboardingBloc bloc;

  const OnboardingScreen({Key key, this.bloc}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _OnboardingScreenState();
  }
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const _TOP_PROPORTION = 4;
  static const _BOTTOM_PROPORTION = 4;
  static const _PAGES_LENGTH = 4;

  OnboardingBloc _bloc;
  final PageController controller = new PageController();
  bool isFinalButton = false;
  int pageIndex = 0;
  bool _hasAccepted = false;

  Map<int, GlobalKey<FlipCardState>> cardKeys = {};

  @override
  void initState() {
    super.initState();
    if (widget.bloc == null) {
      _bloc = new OnboardingBloc();
    } else {
      _bloc = widget.bloc;
    }

    for (int i = 0; i < _PAGES_LENGTH; i++) {
      GlobalKey<FlipCardState> key = GlobalKey<FlipCardState>();
      setState(() {
        cardKeys[i] = key;
      });
    }

    Future.delayed(Duration(milliseconds: 500), () {
      cardKeys[0].currentState.toggleCard();
    });
  }

  @override
  Widget build(BuildContext context) {
    controller.addListener(_onPageChange);
    List<Widget> pages = <Widget>[_firstPage, _secondPage, _thirdPage];
    if (_hasAccepted) pages.add(_fourthPage);

    return Scaffold(
      appBar: AppBar(
        leading: pageIndex == 0
            ? Container()
            : InkWell(
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
                onTap: () {
                  controller.previousPage(
                      duration: AppSizes.ANIMATION_DURATION,
                      curve: AppSizes.ANIMATION_TYPE);
                },
              ),
      ),
      bottomNavigationBar: BottomButton(
        isFinalButton ? "I UNDERSTAND" : "NEXT",
        () {
          if (isFinalButton) {
            _bloc.acceptAndStart();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => InitialScreen()),
            );
          } else {
            controller.nextPage(
              duration: AppSizes.PAGE_ANIMATION_DURATION,
              curve: AppSizes.ANIMATION_TYPE,
            );
          }
        },
        disabled: pageIndex == 2 && !_hasAccepted,
        textColor: pageIndex == 2
            ? _hasAccepted
                ? AppColors.ORANGE_BUTTON_TEXT
                : AppColors.ORANGE_BUTTON_TEXT.withOpacity(0.34)
            : AppColors.ORANGE_BUTTON_TEXT,
        key: Key("next"),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            // color: AppColors.BACKGROUND,
            // padding: EdgeInsets.only(top: 16, bottom: 0),
            child: PageView(
              physics: BouncingScrollPhysics(),
              children: pages,
              controller: controller,
              onPageChanged: _onPageChanged,
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Padding(
              padding: EdgeInsets.only(top: 16.0, bottom: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  for (var i = 0; i < _PAGES_LENGTH; i++) getCircleBar(i)
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onPageChange() {
    if (controller.page > 2.5) {
      if (pageIndex != controller.page.round()) {
        setState(() {
          pageIndex = controller.page.round();
          isFinalButton = true;
        });
      }
    } else {
      if (pageIndex != controller.page.round()) {
        setState(() {
          pageIndex = controller.page.round();
          isFinalButton = false;
        });
      }
    }
  }

  void _onPageChanged(int page) {
    for (var i = 0; i < _PAGES_LENGTH; i++) {
      if (cardKeys[i].currentState != null &&
          !cardKeys[i].currentState.isFront) {
        cardKeys[i].currentState.toggleCard();
      }
    }

    final cardKey = cardKeys[page];
    cardKey.currentState.toggleCard();
  }

  Widget getCircleBar(int i) {
    return FlipCard(
      key: cardKeys[i],
      flipOnTouch: false,
      speed: 300,
      direction: FlipDirection.HORIZONTAL,
      front: Container(
        margin: EdgeInsets.symmetric(horizontal: 8),
        height: 8,
        width: 8,
        decoration: BoxDecoration(
          color: AppColors.TEXT.withOpacity(0.34),
          borderRadius: BorderRadius.all(
            Radius.circular(5),
          ),
        ),
      ),
      back: Container(
        margin: EdgeInsets.symmetric(horizontal: 8),
        height: 8,
        width: 8,
        decoration: BoxDecoration(
          color: AppColors.TEXT,
          borderRadius: BorderRadius.all(
            Radius.circular(5),
          ),
        ),
      ),
    );
  }

  Widget get _firstPage => Padding(
        padding: EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 48.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              flex: _TOP_PROPORTION,
              child: Center(
                child: Image.asset(
                  "assets/Onboarding1.gif",
                  filterQuality: FilterQuality.medium,
                  fit: BoxFit.fitHeight,
                ),
              ),
            ),
            Expanded(
              flex: _BOTTOM_PROPORTION,
              child: Column(
                children: <Widget>[
                  HeaderText(
                    "Chat with yourself",
                    color: AppColors.TEXT,
                  ),
                  OnboardingText(
                    "HOLD helps you think clearly by encouraging you to take "
                    "both sides of the conversation, helping you structure your "
                    "thinking and make sense of your own advice.",
                    color: AppColors.TEXT,
                  )
                ],
              ),
            )
          ],
        ),
      );

  Widget get _secondPage => Padding(
        padding: EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 48.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Expanded(
              flex: _TOP_PROPORTION,
              child: Center(
                child: Image.asset("assets/Onboarding2.gif"),
              ),
            ),
            Expanded(
              flex: _BOTTOM_PROPORTION,
              child: Column(
                children: <Widget>[
                  HeaderText("Build on your own conversations"),
                  OnboardingText(
                    "HOLD gives you an easy way to look back at your "
                    "conversations and reflect on them with a new perspective. "
                    "You can also create collections that will help you learn "
                    "more about your patterns.",
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  Widget get _thirdPage => Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Expanded(
            child: Center(
              child: Image.asset("assets/Onboarding3.gif"),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: HeaderText("A personal space no one can access"),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(24.0, 0, 24.0, 10.0),
            child: OnboardingText(
              "HOLD is a safe environment where you can take time to talk, "
              "reflect and learn about yourself.",
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.SEMITRANSPARENT,
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(12.0, 10.0, 24.0, 16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Theme(
                      data: ThemeData(
                        unselectedWidgetColor: Colors.white,
                        selectedRowColor: AppColors.TEXT_EF,
                      ),
                      child: Checkbox(
                        value: _hasAccepted,
                        checkColor: AppColors.BACKGROUND,
                        activeColor: AppColors.TEXT_EF,
                        onChanged: (value) {
                          setState(() {
                            _hasAccepted = value;
                          });
                        },
                      )),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(top: 12.0, bottom: 32.0),
                      child: RichText(
                        text: TextSpan(
                            style: TextStyle(
                              color: AppColors.ONBOARDING_TEXT,
                              fontSize: 12.7,
                            ),
                            children: [
                              TextSpan(
                                text:
                                    'By using this application, you agree to its ',
                              ),
                              TextSpan(
                                text: 'terms of service',
                                style: TextStyle(
                                    decoration: TextDecoration.underline),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = _openTerms,
                              ),
                              TextSpan(text: " and "),
                              TextSpan(
                                  text: "privacy policy",
                                  style: TextStyle(
                                      decoration: TextDecoration.underline),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = _openPolicy),
                              TextSpan(
                                text: ".\n\n"
                                    "We ensure that all the information you enter in the app is "
                                    "only stored on this phone and will never be shared with anyone.",
                              )
                            ]),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      );

  Widget get _fourthPage => Padding(
        padding: EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 48.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              flex: _TOP_PROPORTION,
              child: Center(
                child: Image.asset("assets/Onboarding4.gif"),
              ),
            ),
            Expanded(
              flex: _BOTTOM_PROPORTION,
              child: Column(
                children: <Widget>[
                  HeaderText("HOLD is not a crisis service"),
                  OnboardingText(
                    "HOLD is a tool that is not indended to be a medical "
                    "intervention. If you are in a crisis, select 'Support' "
                    "in your profile and find external resources that you "
                    "can choose to use.",
                  )
                ],
              ),
            )
          ],
        ),
      );

  void _openTerms() {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) =>
            LoadedTextScreen("Terms of service", ProfilePage.TERMS_ADDRESS)));
  }

  void _openPolicy() {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) =>
            LoadedTextScreen("Privacy policy", ProfilePage.PRIVACY_ADDRESS)));
  }
}
