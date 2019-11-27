import 'dart:io';
import 'dart:math' as math;

import 'package:audioplayers/audio_cache.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animation_set/animation_set.dart';
import 'package:flutter_animation_set/animator.dart';
import 'package:hold/bloc/mixpanel_provider.dart';
import 'package:hold/bloc/speech_recognition_bloc.dart';
import 'package:hold/constants/app_colors.dart';
import 'package:hold/widget/dialogs/dialog_no_internet.dart';
import 'package:hold/widget/launchers/dialog_launchers.dart';

class DictateButton extends StatelessWidget {
  final SpeechRecognitionBloc _bloc = new SpeechRecognitionBloc();

  Stream<String> get textStream => _bloc.spokenText;

  Stream<String> get finalTextStream => _bloc.finalText;
  final VoidCallback onDictateStarted;
  bool isClick = false;

  DictateButton(
    this.onDictateStarted, {
    Key key,
  }) : super(key: key);

  Future<bool> _isInternetAvailable() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      } else {
        return false;
      }
    } on SocketException catch (_) {
      return false;
    }
  }

  void _showDialogUnavailable(context) {
    DialogLaunchers.showDialog(context: context, dialog: DialogNoInternet());
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
        initialData: null,
        stream: _bloc.isListening,
        builder: (BuildContext context, AsyncSnapshot<bool> available) {
          print("voice stream state is ${available.data}");
          final availabilityState = available.data;
          return Column(
            children: <Widget>[
              Text(
                availabilityState == null
                    ? "Prepairing engine..."
                    : availabilityState
                        ? "Say it outloud..."
                        : "HOLD to dictate...",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12.6,
                  color: AppColors.DIALOG_INACTIVE_TEXT.withOpacity(0.38),
                ),
              ),
              Listener(
                onPointerDown: (details) async {
                  _bloc.reinit();
                  if (await _isInternetAvailable()) {
                    MixPanelProvider().trackEvent("CONVERSATION", {
                      "Click Mic Button": DateTime.now().toIso8601String(),
                    });
                    await AudioCache().play("audio_start.wav");
                    if (!availabilityState) {
                      _bloc.start();
                      onDictateStarted();
                      isClick = true;
                    }
                  } else {
                    await AudioCache().play("audio_error.wav");
                    _showDialogUnavailable(context);
                  }
                },
                onPointerUp: (details) async {
                  await AudioCache().play("audio_end.wav");
                  isClick = false;
                  _bloc.stop();
                },
                child: Stack(children: <Widget>[
                  isClick
                      ? makeRippleAnim()
                      : new Container(width: 100, height: 100),
                  Container(
                      margin: EdgeInsets.only(left: 20.0, top: 20.0),
                      width: 60.0,
                      height: 60.0,
                      decoration: new BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.VOICE_INPUT_BTN_BG,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 2.0,
                            spreadRadius: 2.0,
                            offset: Offset(0, 4.0),
                          )
                        ],
                      ),
                      child: Align(
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.mic_none,
                          color: AppColors.QUESTION_TITLE_ACTIVE_TEXT,
                        ),
                      )),
                ]),
              )
            ],
          );
        });
  }

  Widget makeRippleAnim() {
    return Container(
      width: 100,
      height: 100,
      child: Transform.rotate(
        angle: math.pi / 4,
        child: Stack(
          children: <Widget>[
            AnimatorSet(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black, width: 30),
                ),
              ),
              animatorSet: [
                Serial(duration: 440, serialList: [
                  SX(from: 0.0, to: 1.0),
                  SY(from: 0.0, to: 1.0),
                  O(from: 1.0, to: 0.0),
                ]),
                Delay(duration: 250),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
