import 'package:flutter/material.dart';
import 'package:hold/bloc/mixpanel_provider.dart';
import 'package:hold/bloc/recent_activity_bloc.dart';
import 'package:hold/constants/app_colors.dart';
import 'package:hold/storage/graph_value.dart';
import 'package:hold/widget/dual_scroll_controller.dart';

class EndlessHorizontalGraph extends StatefulWidget {
  final RecentActivityBloc bloc;
  final DualScrollController controller;
  final double bottomGraphOffset;
  final ValueChanged<int> selectedItemChanged;

  const EndlessHorizontalGraph(
    this.bloc,
    this.controller,
    this.selectedItemChanged, {
    Key key,
    this.bottomGraphOffset,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return EndlessHorizontalGraphState();
  }
}

class EndlessHorizontalGraphState extends State<EndlessHorizontalGraph> {
  static const HORIZONTAL_PADDING = 20.0;
  static const CIRCLE_SIZE = 16.0;
  static const GRAPH_HEIGHT = 80.0;
  static const ADDITIONAL_ITEMS_COUNT = 6;

  int _highlightedIitemIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<GraphValue>>(
      stream: widget.bloc.graph,
      initialData: List(),
      builder:
          (BuildContext context, AsyncSnapshot<List<GraphValue>> listData) {
        List<GraphValue> list = listData.data;
        return ListView.builder(
          controller: widget.controller.graphController,
          scrollDirection: Axis.horizontal,
          reverse: true,
          itemCount: list.length + 1,
          itemBuilder: (BuildContext context, int index) {
            print("list length: ${list.length}");

            // Start padding
            if (index == 0) {
              return SizedBox(
                width: list.length > 4
                    ? 36
                    : (MediaQuery.of(context).size.width / 2) -
                        (HORIZONTAL_PADDING + CIRCLE_SIZE) / 2,
              );
            }
            // End padding
            if (index > list.length) {
              return SizedBox(
                width: HORIZONTAL_PADDING * 2 + CIRCLE_SIZE,
              );
            }

            GraphValue listItem = list[index - 1];
            if (listItem.value == null) {
              return SizedBox(
                width: HORIZONTAL_PADDING * 2 + CIRCLE_SIZE,
              );
            }
            return InkWell(
              onTap: () {
                _selectIndex(index, listItem.cardNumber);
              },
              child: SizedBox(
                width: HORIZONTAL_PADDING * 2 + CIRCLE_SIZE,
                height: GRAPH_HEIGHT,
                child: Container(
                  padding: EdgeInsets.only(
                    left: HORIZONTAL_PADDING,
                    right: HORIZONTAL_PADDING,
                    bottom: widget.bottomGraphOffset -
                        CIRCLE_SIZE / 2 +
                        GRAPH_HEIGHT * (listItem.value.roundToDouble() / 100),
                    top: widget.bottomGraphOffset +
                        CIRCLE_SIZE / 2 +
                        GRAPH_HEIGHT *
                            (1 - listItem.value.roundToDouble() / 100),
                  ),
                  width: HORIZONTAL_PADDING * 2 + CIRCLE_SIZE,
                  height: GRAPH_HEIGHT + CIRCLE_SIZE,
                  child: StreamBuilder<int>(
                    stream: widget.controller.highlightedGraphIitemIndex,
                    initialData: 0,
                    builder: (BuildContext context,
                        AsyncSnapshot<int> highlighteIitemIndex) {
                      _highlightedIitemIndex = highlighteIitemIndex.data + 1;

                      return Container(
                        alignment: Alignment.bottomCenter,
                        height: CIRCLE_SIZE,
                        width: CIRCLE_SIZE,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isHighlight(index)
                                ? AppColors.ORANGE_BUTTON_BACKGROUND
                                : AppColors.ORANGE_BUTTON_BACKGROUND
                                    .withOpacity(0.64),
                            boxShadow: isHighlight(index)
                                ? [
                                    BoxShadow(
                                      color: AppColors.LIGHT,
                                      blurRadius:
                                          6.0, // has the effect of softening the shadow
                                      spreadRadius:
                                          5.0, // has the effect of extending the shadow,
                                    )
                                  ]
                                : null),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  bool isHighlight(int index) => _highlightedIitemIndex == index;

  void _selectIndex(int index, int id) {
    MixPanelProvider().trackEvent("CONVERSATIONS", {
      "Click Emotion Log Item": DateTime.now().toIso8601String(),
    });
    setState(() {
      _highlightedIitemIndex = index;
    });

    widget.controller.scrollTo(index - 1);
    widget.selectedItemChanged(id);
  }
}
