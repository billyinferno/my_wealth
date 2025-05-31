import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:my_wealth/_index.g.dart';

enum SortBoxType {
  ascending,
  descending,
}

class SortBox extends StatefulWidget {
  final String initialFilter;
  final Map<String, String> filterList;
  final SortBoxType filterSort;
  final Function(String, SortBoxType) onChanged;
  final Color bgColor;
  final Color fgColor;
  final EdgeInsets padding;
  const SortBox({
    super.key,
    required this.initialFilter,
    required this.filterList,
    required this.filterSort,
    required this.onChanged,
    this.bgColor = primaryDark,
    this.fgColor = accentColor,
    this.padding = const EdgeInsets.fromLTRB(10, 5, 10, 10),
  });

  @override
  State<SortBox> createState() => _SortBoxState();
}

class _SortBoxState extends State<SortBox> {
  late TextStyle _filterTypeSelected;
  late TextStyle _filterTypeUnselected;
  late SortBoxType _currentSort;
  late String _currentFilter;

  @override
  void initState() {
    super.initState();

    assert(
      widget.filterList.isNotEmpty,
      "Filter list cannot be empty",
    );

    assert(
      widget.filterList.containsKey(widget.initialFilter),
      "Initial filter must be one of the keys in the filter list",
    );

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

    // get the current sort type from the parent widget
    _currentSort = widget.filterSort;

    // get the current filter from the parent widget
    _currentFilter = widget.initialFilter;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: widget.padding,
      width: double.infinity,
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
                  filterMode: widget.initialFilter,
                  onFilterSelect: ((value) {
                    _currentFilter = value;
                    widget.onChanged(_currentFilter, _currentSort);
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
                      child: Text(
                        widget.filterList[widget.initialFilter] ?? 'Code'
                      ),
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
              if (_currentSort != SortBoxType.ascending) {
                _currentSort = SortBoxType.ascending;
                widget.onChanged(_currentFilter, _currentSort);
              }
            }),
            child: SizedBox(
              width: 35,
              child: Center(
                child: Text(
                  "ASC",
                  style: (
                    _currentSort == SortBoxType.ascending ?
                    _filterTypeSelected :
                    _filterTypeUnselected
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            width: 2,
          ),
          GestureDetector(
            onTap: (() {
              if (_currentSort != SortBoxType.descending) {
                _currentSort = SortBoxType.descending;
                widget.onChanged(_currentFilter, _currentSort);
              }
            }),
            child: SizedBox(
              width: 35,
              child: Center(
                child: Text(
                  "DESC",
                  style: (
                    _currentSort == SortBoxType.descending ?
                    _filterTypeSelected :
                    _filterTypeUnselected
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
