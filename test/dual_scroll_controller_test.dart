import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hold/widget/dual_scroll_controller.dart';
import 'package:mockito/mockito.dart';

class MockScrollController extends Mock implements ScrollController {}

class TestScrollController extends ScrollController {
  VoidCallback myListener;
  double myOffset;

  TestScrollController(this.myOffset);

  void userScrollTo(double scrollPosition) {
    myOffset += scrollPosition;
    myListener();
  }

  @override
  double get offset => myOffset;

  @override
  void addListener(VoidCallback listener) {
    myListener = listener;
  }
}

main() {
  final graphOffset = 30.0;
  final graphItemSize = 40.0;
  final listItemSize = 70.0;
  DualScrollController dualScrollController;
  MockScrollController graphController = new MockScrollController();
  MockScrollController listController = new MockScrollController();

  test(
      "when scrolled on graph (graphItemSize) list is scrolled (-listItemSize)",
      () {
    TestScrollController graphEventSender =
        new TestScrollController(graphOffset);
    dualScrollController = new DualScrollController(
        initialGraphOffset: graphOffset,
        graphItemSize: graphItemSize,
        graphC: graphEventSender,
        listC: listController);
    dualScrollController.setListItemSize(listItemSize);
    graphEventSender.userScrollTo(graphItemSize);
    expect(verify(listController.jumpTo(captureAny)).captured.single,
        listItemSize);
    graphEventSender.userScrollTo(-graphItemSize);
    expect(verify(listController.jumpTo(captureAny)).captured.single, 0);
  });

  test(
      "when scrolled on list (+listItemSize) graph is scrolled (-graphItemSize)",
      () {
    TestScrollController listEventSender = new TestScrollController(0);
    dualScrollController = new DualScrollController(
        initialGraphOffset: graphOffset,
        graphItemSize: graphItemSize,
        graphC: graphController,
        listC: listEventSender);
    dualScrollController.setListItemSize(listItemSize);
    listEventSender.userScrollTo(listItemSize);
    expect(verify(graphController.jumpTo(captureAny)).captured.single,
        graphItemSize + graphOffset);
    listEventSender.userScrollTo(-listItemSize);
    expect(verify(graphController.jumpTo(captureAny)).captured.single,
        graphOffset);
  });

  test(
      "when scrolled to the end of list (-listItemSize) graph is scrolled to the end too (+graphItemSize)",
      () {});
}
