import 'package:flutter/material.dart';
import 'package:hold/constants/app_colors.dart';
import 'package:hold/constants/app_sizes.dart';
import 'package:infinite_listview/infinite_listview.dart';

class TimeItemSelector extends StatefulWidget {
  final int initialValue;
  final int maxValue;
  final ValueChanged<int> onTimeItemSelected;

  const TimeItemSelector(
    this.maxValue,
    this.onTimeItemSelected, {
    Key key,
    this.initialValue,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _TimeItemSelectorState();
  }
}

class _TimeItemSelectorState extends State<TimeItemSelector> {
  final double _visibilityRadius = 1;
  InfiniteScrollController scrollController = new InfiniteScrollController();
  int currentValue = 1;
  bool _programedJump = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null && widget.initialValue != 1)
      WidgetsBinding.instance.addPostFrameCallback(_scrollAfterBuild);
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener(
      child: Container(
        height: AppSizes.NUMBER_PICKER_ITEM_HEIGHT * 3 + 2,
        width: AppSizes.NUMBER_PICKER_ITEM_WIDTH,
        child: Stack(
          children: <Widget>[
            Positioned.fill(
              child: InfiniteListView.builder(
                controller: scrollController,
                itemExtent: AppSizes.NUMBER_PICKER_ITEM_HEIGHT,
                itemBuilder: (BuildContext context, int index) {
                  int value = index % widget.maxValue;
                  if (widget.maxValue == 12 && value == 0) value = 12;
                  String textInSelector = value.toString();
                  if (textInSelector.length == 1)
                    textInSelector = "0" + textInSelector;
                  return Center(
                    child: new Text(
                      textInSelector,
                      style: TextStyle(
                          color: value == currentValue ||
                                  (widget.maxValue == 12 &&
                                      value == 12 &&
                                      currentValue == 0)
                              ? AppColors.TEXT_EF
                              : AppColors.DIALOG_REMINDER_TEXT,
                          fontSize: 25.36,
                          fontWeight: FontWeight.bold),
                    ),
                  );
                },
              ),
            ),
            Positioned(
              bottom: AppSizes.NUMBER_PICKER_ITEM_HEIGHT,
              left: 0,
              right: 0,
              child: Container(
                height: 1,
                width: AppSizes.NUMBER_PICKER_ITEM_WIDTH,
                color: AppColors.TEXT,
              ),
            ),
            Positioned(
              top: AppSizes.NUMBER_PICKER_ITEM_HEIGHT,
              left: 0,
              right: 0,
              child: Container(
                height: 1,
                width: AppSizes.NUMBER_PICKER_ITEM_WIDTH,
                color: AppColors.TEXT,
              ),
            ),
          ],
        ),
      ),
      onNotification: _onNotification,
    );
  }

  bool _onNotification(Notification notification) {
    if (notification is ScrollEndNotification) {
      if (_programedJump) {
        _programedJump = false;
        return true;
      } else {
        setState(() {
          currentValue = findSelectedItem(notification.metrics.pixels);
        });
        widget.onTimeItemSelected(currentValue);
        double offsetDifference =
            scrollController.offset % AppSizes.NUMBER_PICKER_ITEM_HEIGHT;
        if (offsetDifference.abs() > 1.0) {
          _programedJump = true;
          double jumpLength =
              (currentValue - 1) * AppSizes.NUMBER_PICKER_ITEM_HEIGHT;
          scrollController.jumpTo(jumpLength);
        }
        return true;
      }
    } else {
      return false;
    }
  }

  double getOffsetForSelection(int index) {
    return (index - _visibilityRadius) * AppSizes.NUMBER_PICKER_ITEM_HEIGHT;
  }

  int findSelectedItem(double offset) {
    int indexOffset = offset ~/ AppSizes.NUMBER_PICKER_ITEM_HEIGHT;
    int borderMovement =
        (offset - indexOffset * AppSizes.NUMBER_PICKER_ITEM_HEIGHT) ~/
            (AppSizes.NUMBER_PICKER_ITEM_HEIGHT / 2);
    indexOffset += borderMovement;
    return (1 + indexOffset) % widget.maxValue;
  }

  double getFullListHeight() {
    return widget.maxValue * AppSizes.NUMBER_PICKER_ITEM_HEIGHT;
  }

  void _scrollAfterBuild(Duration timeStamp) {
    _programedJump = true;
    setState(() {
      currentValue = widget.initialValue;
    });
    scrollController
        .jumpTo((widget.initialValue - 1) * AppSizes.NUMBER_PICKER_ITEM_HEIGHT);
  }
}
