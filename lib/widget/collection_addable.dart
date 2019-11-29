import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hold/constants/app_colors.dart';
import 'package:hold/model/collection_short_data.dart';

class CollectionAddable extends StatefulWidget {
  final CollectionShortData content;
  final VoidCallback onItemAdded;
  final VoidCallback onItemRemoved;
  final bool isInitiallySelected;

  const CollectionAddable(
    this.content,
    this.onItemAdded,
    this.onItemRemoved,
    this.isInitiallySelected, {
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _CollectionAddableState();
  }
}

class _CollectionAddableState extends State<CollectionAddable> {
  bool _isAdded;

  @override
  void initState() {
    _isAdded = widget.isInitiallySelected;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.0),
      child: Container(
        padding: EdgeInsets.all(16.0),
        color: _isAdded
            ? AppColors.REFLECTION_LIST_SELECTED_BG
            : AppColors.REFLECTION_LIST_BG,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(right: 48.0),
                  child: Text(
                    widget.content.getName(),
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: AppColors.COLLECTION_TITLE_TEXT,
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0),
                  ),
                ),
                Text(
                  widget.content.getNumberText(),
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: AppColors.COLLECTION_SUBTITLE),
                  maxLines: 1,
                ),
              ],
            ),
            _isAdded
                ? IconButton(
                    onPressed: () {
                      widget.onItemRemoved();
                      setState(() {
                        _isAdded = false;
                      });
                    },
                    icon: Icon(Icons.done_outline),
                    color: AppColors.ORANGE_BUTTON_BACKGROUND,
                  )
                : IconButton(
                    onPressed: () {
                      widget.onItemAdded();
                      setState(() {
                        _isAdded = true;
                      });
                    },
                    icon: SvgPicture.asset(
                      'assets/material_icons/rounded/content/add.svg',
                      height: 14.0,
                      color: AppColors.REFLECTION_ICON,
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
