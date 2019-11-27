import 'package:flutter/material.dart';
import 'package:hold/bloc/conversation_search_bloc.dart';
import 'package:hold/bloc/mixpanel_provider.dart';
import 'package:hold/constants/app_colors.dart';
import 'package:hold/constants/app_sizes.dart';

class SearchWidget extends StatefulWidget {
  final ValueChanged<String> onSearch;
  final ValueChanged<bool> onFocus;
  final VoidCallback onSearchCancel, onSearchStarted;

  const SearchWidget(
    this.onSearch, {
    Key key,
    this.onFocus,
    this.onSearchStarted,
    this.onSearchCancel,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _SearchWidgetState();
  }
}

class _SearchWidgetState extends State<SearchWidget> {
  final FocusNode focusNode = new FocusNode();
  final TextEditingController controller = new TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    focusNode.addListener(_onFocus);
    controller.addListener(_onTextEntered);
    super.initState();
  }

  @override
  void dispose() {
    focusNode.removeListener(_onFocus);
    focusNode.dispose();
    controller.removeListener(_onTextEntered);
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
      color: AppColors.REFLECTION_LIST_BG,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        decoration: BoxDecoration(
          color: AppColors.BACKGROUND,
          borderRadius: BorderRadius.all(
            Radius.circular(AppSizes.BORDER_RADIUS),
          ),
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: TextField(
                decoration: new InputDecoration(
                  hintText: "Search your conversations",
                  hintStyle: new TextStyle(color: AppColors.SEARCH_FIELD_TEXT),
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
                focusNode: focusNode,
                controller: controller,
                style: new TextStyle(color: AppColors.SEARCH_FIELD_TEXT),
                maxLines: 1,
                onChanged: widget.onSearch,
                keyboardType: TextInputType.text,
                textAlignVertical: TextAlignVertical.center,
              ),
            ),
            _hasText
                ? IconButton(
                    onPressed: () {
                      controller.text = "";
                      widget.onSearch("");
                      focusNode.unfocus();
                      setState(() {
                        _hasText = false;
                      });
                    },
                    icon: Icon(Icons.clear, color: AppColors.SEARCH_FIELD_TEXT),
                  )
                : IconButton(
                    onPressed: (){
                      MixPanelProvider().trackEvent("REFLECT", {
                        "Click Search": DateTime.now().toIso8601String(),
                      });
                    },
                    icon:
                        Icon(Icons.search, color: AppColors.SEARCH_FIELD_TEXT),
                  )
          ],
        ),
      ),
    );
  }

  void _onFocus() {
    if (widget.onFocus != null) widget.onFocus(focusNode.hasFocus);
    if (widget.onSearchCancel != null &&
        !focusNode.hasFocus &&
        controller.text.isEmpty) {
      widget.onSearchCancel();
    }
  }

  void _onTextEntered() {
    if (!_hasText &&
        controller.text.isNotEmpty &&
        controller.text.length >= ConversationSearchBloc.SEARCH_THRESHOLD) {
      if (widget.onSearchStarted != null) widget.onSearchStarted();
      setState(() {
        _hasText = true;
      });
    }
    if (_hasText & controller.text.isEmpty) {
      setState(() {
        _hasText = false;
      });
    }
  }
}
