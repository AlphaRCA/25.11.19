import 'package:flutter/material.dart';
import 'package:hold/constants/app_sizes.dart';
import 'package:rxdart/rxdart.dart' as rx;

class DualScrollController {
  static const ANIMATION_DURATION = Duration(milliseconds: 300);

  final double initialGraphOffset;

  final ScrollController graphController;
  final ScrollController listController;

  final double graphItemSize;
  double listItemHeight = 116.0;
  double listTitleHeight = 54.0;

  rx.BehaviorSubject<int> _selectedItemController = new rx.BehaviorSubject();
  Stream<int> get selectedItem => _selectedItemController.stream;

  rx.BehaviorSubject<int> _highlightedItemController = new rx.BehaviorSubject();
  Stream<int> get highlightedGraphIitemIndex =>
      _highlightedItemController.stream;

  bool _isListScrolling = false;
  String scrollSource = "";

  DualScrollController({
    @required this.initialGraphOffset,
    @required this.graphItemSize,
    ScrollController graphC,
    ScrollController listC,
  })  : this.graphController = graphC ?? new ScrollController(),
        this.listController = listC ?? new ScrollController() {
    graphController.addListener(_convertGraphToList);
    listController
      ..addListener(_convertListToGraph)
      ..addListener(_highlightGraphItem);
  }

  void _convertGraphToList() {
    if (listController.hasClients && !_isListScrolling) {
      double coefficient = graphController.offset *
          (listController.position.maxScrollExtent /
              graphController.position.maxScrollExtent);

      listController.jumpTo(coefficient);
    }
  }

  void _convertListToGraph() {
    if (graphController.hasClients && _isListScrolling) {
      double coefficient = listController.offset *
          (graphController.position.maxScrollExtent /
              listController.position.maxScrollExtent);

      graphController.jumpTo(coefficient);
    }
  }

  void _highlightGraphItem() {
    if (listController.hasClients && _isListScrolling) {
      double scrollOffset = listController.offset;

      int firstItemIndex =
          (scrollOffset - listTitleHeight.toInt() + 4) ~/ listItemHeight;

      if (firstItemIndex < 0) firstItemIndex = 0;

      _highlightedItemController.add(firstItemIndex);
    }
  }

  void scrollTo(int index) {
    _selectedItemController.add(index);
    listController.animateTo(
      _calculateItemPositionInList(index),
      duration: AppSizes.DUAL_SCROLL_ANIMATION_DURATION,
      curve: AppSizes.ANIMATION_TYPE,
    );
  }

  bool onListScroll(Notification scrollNotification) {
    if (scrollNotification is ScrollStartNotification) {
      _isListScrolling = true;
    } else if (scrollNotification is ScrollEndNotification) {
      _isListScrolling = false;
    }
    return false;
  }

  void dispose() {
    graphController.removeListener(_convertGraphToList);
    listController.removeListener(_convertListToGraph);
    graphController.dispose();
    listController.dispose();
  }

  void setListItemSize(double size) {
    listItemHeight = size;
  }

  void setListTitleHeight(double height) {
    listTitleHeight = height;
  }

  double _calculateItemPositionInList(int index) {
    double newPosition = listTitleHeight + (listItemHeight * index);
    print("scrollToPostition: $newPosition");
    return newPosition;
  }
}

typedef void SelectionListener(int itemIndex);
