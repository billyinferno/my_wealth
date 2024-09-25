import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:my_wealth/_index.g.dart';

class SearchBox extends StatefulWidget {
  final String filterMode;
  final Map<String, String> filterList;
  final Function(String) onFilterSelect;
  final String filterSort;
  final Function(String) onSortSelect;
  final Color bgColor;
  final Color fgColor;
  const SearchBox({
    super.key,
    required this.filterMode,
    required this.filterList,
    required this.filterSort,
    required this.onFilterSelect,
    required this.onSortSelect,
    this.bgColor = primaryDark,
    this.fgColor = accentColor,
  });

  @override
  State<SearchBox> createState() => _SearchBoxState();
}

class _SearchBoxState extends State<SearchBox> {
  late TextStyle _filterTypeSelected;
  late TextStyle _filterTypeUnselected;

  @override
  void initState() {
    super.initState();

    // move all the data from parent to this widget, as we will perform set state
    // here that will not affect the parent widget.
    _filterTypeSelected = TextStyle(
      fontSize: 10,
      color: widget.fgColor,
      fontWeight: FontWeight.bold
    );
    
    _filterTypeUnselected = const TextStyle(
      fontSize: 10,
      color: primaryLight,
      fontWeight: FontWeight.normal
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 5, 10, 10),
      color: widget.bgColor,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          const Text(
            "SORT",
            style: TextStyle(
              color: primaryLight,
              fontSize: 10,
            ),
          ),
          const SizedBox(
            width: 5,
          ),
          Expanded(
            child: GestureDetector(
              onTap: (() {
                ShowMyModalBottomSheet(
                  context: context,
                  filterList: widget.filterList,
                  filterMode: widget.filterMode,
                  onFilterSelect: ((value) {
                    widget.onFilterSelect(value);
                  })
                ).show();
              }),
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: primaryLight,
                    width: 1.0,
                    style: BorderStyle.solid,
                  ),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child:
                          Text(widget.filterList[widget.filterMode] ?? 'Code'),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    const Icon(
                      Ionicons.caret_down,
                      color: accentColor,
                      size: 15,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(
            width: 5,
          ),
          GestureDetector(
            onTap: (() {
              if (widget.filterSort != "ASC") {
                widget.onSortSelect("ASC");
              }
            }),
            child: SizedBox(
              width: 35,
              child: Center(
                child: Text(
                  "ASC",
                  style: (widget.filterSort == "ASC"
                      ? _filterTypeSelected
                      : _filterTypeUnselected),
                ),
              ),
            ),
          ),
          const SizedBox(
            width: 2,
          ),
          GestureDetector(
            onTap: (() {
              if (widget.filterSort != "DESC") {
                widget.onSortSelect("DESC");
              }
            }),
            child: SizedBox(
              width: 35,
              child: Center(
                child: Text(
                  "DESC",
                  style: (widget.filterSort == "DESC"
                      ? _filterTypeSelected
                      : _filterTypeUnselected),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
