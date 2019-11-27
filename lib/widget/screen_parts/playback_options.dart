import 'package:flutter/material.dart';
import 'package:hold/bloc/playback_options_bloc.dart';
import 'package:hold/widget/styled_dropdown.dart';

import '../white_text.dart';

class PlaybackOptions extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _PlaybackOptionsState();
  }
}

class _PlaybackOptionsState extends State<PlaybackOptions> {
  final PlaybackOptionsBloc _bloc = new PlaybackOptionsBloc();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        WhiteText(
          "PLAYBACK",
          paddingLeft: 24,
          paddingTop: 8,
        ),
        SizedBox(
          height: 16.0,
        ),
        WhiteText(
          "Language",
          paddingLeft: 24,
          paddingTop: 8,
        ),
        Row(children: <Widget>[
          SizedBox(
            width: 24,
          ),
          Expanded(
            child: FutureBuilder<Map<String, String>>(
              initialData: Map(),
              future: _bloc.availableLanguages,
              builder: (BuildContext context,
                  AsyncSnapshot<Map<String, String>> langList) {
                final langListValue = langList.data;
                return StreamBuilder<String>(
                  initialData: "",
                  stream: _bloc.selectedLanguage,
                  builder: (BuildContext ctxt, AsyncSnapshot<String> value) {
                    String selectedLanguage = value.data;
                    if (langListValue.isEmpty ||
                        selectedLanguage == null ||
                        selectedLanguage.isEmpty) return Container();
                    return StyledDropdown(
                        langListValue, selectedLanguage, _bloc.selectLanguage);
                  },
                );
              },
            ),
          ),
          SizedBox(
            width: 24,
          ),
        ]),
        SizedBox(
          height: 16.0,
        ),
        WhiteText(
          "Voice",
          paddingLeft: 24,
          paddingTop: 8,
        ),
        Row(
          children: <Widget>[
            SizedBox(
              width: 24,
            ),
            Expanded(
              child: StreamBuilder<Map<String, String>>(
                initialData: Map(),
                stream: _bloc.voices,
                builder: (BuildContext context,
                    AsyncSnapshot<Map<String, String>> voiceList) {
                  final voiceListValue = voiceList.data;
                  return StreamBuilder<String>(
                    stream: _bloc.selectedVoice,
                    initialData: "",
                    builder: (BuildContext ctxt, AsyncSnapshot<String> value) {
                      String selectedVoice = value.data;
                      if (selectedVoice == null || selectedVoice.isEmpty)
                        return Container();
                      return StyledDropdown(
                          voiceListValue, selectedVoice, _bloc.selectVoice);
                    },
                  );
                },
              ),
            ),
            SizedBox(
              width: 24,
            ),
          ],
        ),
      ],
    );
  }
}
