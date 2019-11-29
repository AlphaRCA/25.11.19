import 'package:flutter/material.dart';
import 'package:hold/constants/app_colors.dart';
import 'package:hold/constants/app_sizes.dart';
import 'package:infinite_listview/infinite_listview.dart';

class AmPmSelector extends StatefulWidget {
  final ValueChanged<DayPeriod> onAmPmChanged;
  final DayPeriod initialValue;

  AmPmSelector(this.onAmPmChanged, {Key key, this.initialValue})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _AmPmSelectorState();
  }
}

class _AmPmSelectorState extends State<AmPmSelector> {
  final List<String> values = ["", "AM", "PM", ""];
  InfiniteScrollController scrollController = new InfiniteScrollController();
  bool _programmedJump = false;
  String currentValue = "AM";

  @override
  void initState() {
    if (widget.initialValue != null && widget.initialValue != DayPeriod.am)
      WidgetsBinding.instance.addPostFrameCallback(_scrollAfterBuild);
    super.initState();
  }

  void _scrollAfterBuild(Duration timeStamp) {
    _programmedJump = true;
    setState(() {
      currentValue = "PM";
    });
    scrollController.jumpTo(AppSizes.NUMBER_PICKER_ITEM_HEIGHT);
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
                  itemBuilder: (BuildContext ctxt, int index) {
                    return SizedBox(
                      height: AppSizes.NUMBER_PICKER_ITEM_HEIGHT,
                      width: AppSizes.NUMBER_PICKER_ITEM_WIDTH,
                      child: Center(
                        child: InkWell(
                          onTap: () {
                            scrollController.animateTo(
                                values[index % 4] == "PM"
                                    ? AppSizes.NUMBER_PICKER_ITEM_HEIGHT
                                    : 0,
                                curve: Curves.decelerate,
                                duration: Duration(milliseconds: 300));
                          },
                          child: Text(
                            values[index % 4],
                            style: TextStyle(
                                fontSize: 22,
                                color: currentValue == values[index % 4]
                                    ? AppColors.TEXT_EF
                                    : AppColors.DIALOG_REMINDER_TEXT),
                          ),
                        ),
                      ),
                    );
                  }),
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
            )
          ],
        ),
      ),
      onNotification: _onNotification,
    );
  }

  bool _onNotification(Notification notification) {
    if (notification is ScrollEndNotification) {
      if (_programmedJump) {
        _programmedJump = false;
        return true;
      }
      if (notification.metrics.pixels >
          AppSizes.NUMBER_PICKER_ITEM_HEIGHT * 0.5) {
        setState(() {
          currentValue = "PM";
        });
      } else {
        setState(() {
          currentValue = "AM";
        });
      }
      widget.onAmPmChanged(currentValue == "AM" ? DayPeriod.am : DayPeriod.pm);
      double offsetDifference =
          scrollController.offset % AppSizes.NUMBER_PICKER_ITEM_HEIGHT;
      if (offsetDifference.abs() > 1.0) {
        _programmedJump = true;
        double jumpLength =
            currentValue == "AM" ? 0 : AppSizes.NUMBER_PICKER_ITEM_HEIGHT;
        scrollController.jumpTo(jumpLength);
      }
      return true;
    } else {
      return false;
    }
  }
}
