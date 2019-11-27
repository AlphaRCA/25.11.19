import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hold/bloc/mixpanel_provider.dart';
import 'package:hold/constants/app_colors.dart';
import 'package:hold/constants/app_sizes.dart';
import 'package:hold/storage/editable_ui_question.dart';
import 'package:hold/widget/dialogs/dialog_reflection_unavailable.dart';
import 'package:hold/widget/launchers/dialog_launchers.dart';

class QuestionWidget extends StatelessWidget {
  final EditableUIQuestion question;
  final QuestionTapAction clickAction;
  final QuestionInfoAction infoAction;
  final bool active;

  const QuestionWidget(this.question, this.infoAction, this.clickAction,
      {Key key, this.active = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(bottom: 8),
        child: GestureDetector(
          onTap: active
              ? () {
                  clickAction(question);
                }
              : () {
                  _showDialogUnavailable(context);
                },
          child: Container(
            decoration: BoxDecoration(
              color: active
                  ? AppColors.QUESTION_ACTIVE_BG
                  : AppColors.QUESTION_INACTIVE_BG,
              borderRadius:
                  BorderRadius.all(Radius.circular(AppSizes.BORDER_RADIUS)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  child: Text(
                    question.title.toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12.67,
                      color: active
                          ? AppColors.QUESTION_TITLE_ACTIVE_TEXT
                          : AppColors.QUESTION_INACTIVE_TEXT,
                    ),
                  ),
                  padding: EdgeInsets.fromLTRB(
                    AppSizes.CARD_PADDING,
                    AppSizes.CARD_PADDING,
                    AppSizes.CARD_PADDING,
                    0.0,
                  ),
                ),
                Expanded(
                  child: active
                      ? Padding(
                          padding: EdgeInsets.fromLTRB(
                            AppSizes.CARD_PADDING,
                            AppSizes.CARD_PADDING,
                            AppSizes.CARD_PADDING,
                            0.0,
                          ),
                          child: AutoSizeText(
                            question.description ?? "",
                            style: TextStyle(
                              color: AppColors.QUESTION_ACTIVE_TEXT,
                              fontWeight: FontWeight.bold,
                              fontSize: 21.1,
                            ),
                          ),
                        )
                      : Text(""),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: IconButton(
                        icon: Icon(
                          active ? Icons.info_outline : Icons.https,
                          color: active
                              ? AppColors.QUESTION_ACTIVE_TEXT
                              : AppColors.QUESTION_INACTIVE_TEXT,
                        ),
                        onPressed: active
                            ? () {
                                infoAction(question.title, question.information,
                                    question.level);
                              }
                            : () {
                                _showDialogUnavailable(context);
                              },
                      ),
                    ),
                    Expanded(
                      child: Text(
                        question.subtitle ?? "Stage ${question.level}",
                        style: TextStyle(
                          color: AppColors.ORANGE_BUTTON_BACKGROUND,
                          fontWeight: FontWeight.bold,
                          fontSize: 12.0,
                        ),
                      ),
                    ),
                    Container(
                      width: 56.0,
                      height: 56.0,
                      decoration: BoxDecoration(
                        color: AppColors.QUESTION_BUTTON_BG,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(AppSizes.BORDER_RADIUS),
                          topRight: Radius.circular(0),
                          bottomLeft: Radius.circular(0),
                          bottomRight: Radius.circular(AppSizes.BORDER_RADIUS),
                        ),
                      ),
                      child: IconButton(
                        icon: SvgPicture.asset(
                          "assets/material_icons/rounded/action/trending_flat.svg",
                          color: Colors.black87,
                        ),
                        onPressed: active
                            ? () {
                                MixPanelProvider().trackEvent("REFLECT", {
                                  "Click  ": question.title,
                                  "Tier ": "${question.level} Tool"
                                });
                                clickAction(question);
                              }
                            : () {
                                _showDialogUnavailable(context);
                              },
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ));
  }

  void _showDialogUnavailable(BuildContext context) {
    DialogLaunchers.showDialog(
        context: context, dialog: DialogReflectionUnavailable());
  }
}

typedef QuestionInfoAction = void Function(
    String questionTitle, String longDescription, int level);

typedef QuestionTapAction = void Function(EditableUIQuestion question);
