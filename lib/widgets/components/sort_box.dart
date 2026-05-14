import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_wealth/_index.g.dart';
import 'package:my_wealth/utils/icon/my_ionicons.dart';

enum SortBoxType {
  ascending,
  descending,
}

enum TextFilterMode {
  toggle,
  alwaysShow,
}

class SortBox extends StatefulWidget {
  final String initialFilter;
  final Map<String, String> filterList;
  final SortBoxType filterSort;
  final Function(String, SortBoxType) onChanged;
  final Color bgColor;
  final Color fgColor;
  final EdgeInsets padding;
  final bool enabledTextFilter;
  final TextFilterMode textFilterMode;
  final Color txtBgColor;
  final Function(String)? onTextFilterChanged;
  const SortBox({
    super.key,
    required this.initialFilter,
    required this.filterList,
    required this.filterSort,
    required this.onChanged,
    this.bgColor = primaryDark,
    this.fgColor = accentColor,
    this.padding = const EdgeInsets.fromLTRB(10, 5, 10, 10),
    this.enabledTextFilter = false,
    this.textFilterMode = TextFilterMode.toggle,
    this.txtBgColor = primaryColor,
    this.onTextFilterChanged,
  });

  @override
  State<SortBox> createState() => _SortBoxState();
}

class _SortBoxState extends State<SortBox> {
  final TextEditingController _filterTextController = TextEditingController();

  late TextStyle _filterTypeSelected;
  late TextStyle _filterTypeUnselected;
  late SortBoxType _currentSort;
  late String _currentFilter;
  late bool _textFilterShowed;

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

    // default text filter to be hidden
    _textFilterShowed = false;
  }
  
  @override
  void dispose() {
    _filterTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: widget.padding,
      width: double.infinity,
      color: widget.bgColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Row(
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
                        Icon(
                          MyIonicons(MyIoniconsData.caret_down).data,
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
              Visibility(
                visible: widget.enabledTextFilter && widget.textFilterMode == TextFilterMode.toggle,
                child: const SizedBox(
                  width: 2,
                ),
              ),
              Visibility(
                visible: widget.enabledTextFilter && widget.textFilterMode == TextFilterMode.toggle,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      // toggle the text filter visibility
                      _textFilterShowed = !_textFilterShowed;
                      // also clear the text filter value when hide it
                      _filterTextController.clear();
                      // also trigger the on text filter changed with empty value to reset the filter                      if (!_textFilterShowed) {
                      widget.onTextFilterChanged?.call('');
                    });
                  },
                  child: Container(
                    width: 20,
                    height: 30,
                    color: Colors.transparent,
                    child: Icon(
                      MyIonicons(MyIoniconsData.search).data,
                      color: (_textFilterShowed ? widget.fgColor : primaryLight),
                      size: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Visibility(
            visible: _textFilterShowed || widget.textFilterMode == TextFilterMode.alwaysShow,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                const SizedBox(
                  height: 10,
                ),
                CupertinoSearchTextField(
                  controller: _filterTextController,
                  backgroundColor: widget.txtBgColor,
                  style: const TextStyle(
                    color: textPrimary,
                    fontFamily: '--apple-system',
                  ),
                  onChanged: ((searchText) {
                    widget.onTextFilterChanged?.call(searchText);
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
