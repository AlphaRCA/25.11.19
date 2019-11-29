import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'HoleArea.dart';
import 'WidgetData.dart';

class InvertedClipper extends CustomClipper<Path> {
  final Animation<double> animation;
  final List<WidgetData> widgetsData;
  double padding;
  Function deepEq = const DeepCollectionEquality().equals;
  List<HoleArea> areas = [];

  InvertedClipper(
      {@required this.padding,
      this.animation,
      Listenable reclip,
      this.widgetsData})
      : super(reclip: reclip) {
    if (widgetsData.isNotEmpty) {
      widgetsData.forEach((WidgetData widgetData) {
        if (widgetData.isEnabled) {
          final GlobalKey key = widgetData.key;
          if (key == null) {
            //    throw new Exception("GlobalKey is null!");
          } else if (key.currentWidget == null) {
//            throw new Exception("GlobalKey is not assigned to a Widget!");
          } else {
            areas.add(getHoleArea(
                key: key,
                shape: widgetData.shape,
                padding: widgetData.padding));
          }
        }
      });
    }
  }

  @override
  Path getClip(Size size) {
    Path path = Path();
    double animationValue = animation != null ? animation.value : 0;
    areas.forEach((HoleArea area) {
      switch (area.shape) {
        case WidgetShape.Oval:
          {
            path.addOval(Rect.fromLTWH(
                area.x - (((area.padding + padding) + animationValue * 15) / 2),
                area.y - ((area.padding + padding) + animationValue * 15) / 2,
                area.width + ((area.padding + padding) + animationValue * 15),
                area.height +
                    ((area.padding + padding) + animationValue * 15)));
          }
          break;
        case WidgetShape.Rect:
          {
            path.addRect(Rect.fromLTWH(
                area.x - (((area.padding + padding) + animationValue * 15) / 2),
                area.y - ((area.padding + padding) + animationValue * 15) / 2,
                area.width + ((area.padding + padding) + animationValue * 15),
                area.height +
                    ((area.padding + padding) + animationValue * 15)));
          }
          break;
        case WidgetShape.RRect:
          {
            path.addRRect(RRect.fromRectAndCorners(
              Rect.fromLTWH(
                  area.x -
                      (((area.padding + padding) + animationValue * 15) / 2),
                  area.y - ((area.padding + padding) + animationValue * 15) / 2,
                  area.width + ((area.padding + padding) + animationValue * 15),
                  area.height +
                      ((area.padding + padding) + animationValue * 15)),
              topLeft: Radius.circular(16.0),
              topRight: Radius.circular(16.0),
              bottomLeft: Radius.circular(16.0),
              bottomRight: Radius.circular(16.0),
            ));
          }
          break;
        case WidgetShape.LeftRRect:
          {
            path.addRRect(RRect.fromRectAndCorners(
              Rect.fromLTWH(
                  area.x -
                      (((area.padding + padding - 30) + animationValue * 15) /
                          2),
                  area.y - ((area.padding + padding) + animationValue * 15) / 2,
                  area.width + ((area.padding + padding) + animationValue * 15),
                  area.height +
                      ((area.padding + padding) + animationValue * 15)),
              topLeft: Radius.circular(16.0),
              bottomLeft: Radius.circular(16.0),
            ));
          }
          break;
        case WidgetShape.RightRRect:
          {
            path.addRRect(RRect.fromRectAndCorners(
              Rect.fromLTWH(
                  area.x -
                      (((area.padding + padding + 30) + animationValue * 15) /
                          2),
                  area.y - ((area.padding + padding) + animationValue * 15) / 2,
                  area.width + ((area.padding + padding) + animationValue * 15),
                  area.height +
                      ((area.padding + padding) + animationValue * 15)),
              topRight: Radius.circular(16.0),
              bottomRight: Radius.circular(16.0),
            ));
          }
          break;
        case WidgetShape.TopRRect:
          {
            path.addRRect(RRect.fromRectAndCorners(
              Rect.fromLTWH(
                  area.x -
                      (((area.padding + padding) + animationValue * 15) / 2),
                  area.y - ((area.padding + padding) + animationValue * 15) / 2,
                  area.width + ((area.padding + padding) + animationValue * 15),
                  area.height +
                      ((area.padding + padding) + animationValue * 15)),
              topLeft: Radius.circular(16.0),
              topRight: Radius.circular(16.0),
            ));
          }
          break;
        case WidgetShape.BottomRRect:
          {
            path.addRRect(RRect.fromRectAndCorners(
              Rect.fromLTWH(
                  area.x -
                      (((area.padding + padding) + animationValue * 15) / 2),
                  area.y - ((area.padding + padding) + animationValue * 15) / 2,
                  area.width + ((area.padding + padding) + animationValue * 15),
                  area.height +
                      ((area.padding + padding) + animationValue * 15)),
              bottomLeft: Radius.circular(16.0),
              bottomRight: Radius.circular(16.0),
            ));
          }
          break;
        case WidgetShape.StretchedVRRect:
          {
            path.addRRect(RRect.fromRectAndCorners(
              Rect.fromLTWH(
                  area.x -
                      (((area.padding + padding - 16) + animationValue * 15) /
                          2),
                  area.y -
                      ((area.padding + padding + 16) + animationValue * 15) / 2,
                  area.width +
                      ((area.padding + padding - 16) + animationValue * 15),
                  area.height +
                      ((area.padding + padding + 16) + animationValue * 15)),
              topLeft: Radius.circular(16.0),
              topRight: Radius.circular(16.0),
              bottomLeft: Radius.circular(16.0),
              bottomRight: Radius.circular(16.0),
            ));
          }
          break;
        case WidgetShape.StretchedHRRect:
          {
            path.addRRect(RRect.fromRectAndCorners(
              Rect.fromLTWH(
                  area.x - (area.padding + padding - 16) / 2,
                  area.y - (area.padding + padding + 16) / 2,
                  area.width + area.padding + padding - 16,
                  area.height + area.padding + padding),
              topLeft: Radius.circular(16.0),
              topRight: Radius.circular(16.0),
              bottomLeft: Radius.circular(16.0),
              bottomRight: Radius.circular(16.0),
            ));
          }
          break;
      }
    });
    return path
      ..addRect(Rect.fromLTWH(0.0, 0.0, size.width, size.height))
      ..fillType = PathFillType.evenOdd;
  }

  @override
  bool shouldReclip(InvertedClipper oldClipper) {
    return !deepEq(oldClipper.areas, areas);
  }
}
