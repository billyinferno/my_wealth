import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:my_wealth/themes/colors.dart';

class SearchBox extends StatefulWidget {
  final String filterMode;
  final Map<String, String> filterList;
  final Function(String) onFilterSelect;
  final String filterSort;
  final Function(String) onSortSelect;
  const SearchBox({Key? key, required this.filterMode, required this.filterList, required this.filterSort, required this.onFilterSelect, required this.onSortSelect}) : super(key: key);

  @override
  State<SearchBox> createState() => _SearchBoxState();
}

class _SearchBoxState extends State<SearchBox> {
  final TextStyle _filterTypeSelected = const TextStyle(fontSize: 10, color: accentColor, fontWeight: FontWeight.bold);
  final TextStyle _filterTypeUnselected = const TextStyle(fontSize: 10, color: primaryLight, fontWeight: FontWeight.normal);
  
  // late String _filterMode;
  // late Map<String, String> _filterList;
  // late String _filterSort;

  @override
  void initState() {
    // move all the data from parent to this widget, as we will perform set state
    // here that will not affect the parent widget.
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 5, 10, 10),
      color: primaryDark,
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
          const SizedBox(width: 5,),
          Expanded(
            child: GestureDetector(
              onTap: (() {
                showModalBottomSheet<void>(
                  context: context,
                  backgroundColor: Colors.transparent,
                  isDismissible: true,
                  builder:(context) {
                    return Container(
                      height: ((widget.filterList.length * 40) + 50),
                      margin: const EdgeInsets.fromLTRB(10, 10, 10, 25),
                      padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          const Center(
                            child: Text("Select Filter"),
                          ),
                          ...widget.filterList.entries.map((e) => GestureDetector(
                            onTap: (() {
                              widget.onFilterSelect(e.key);
                              // remove the modal sheet
                              Navigator.pop(context);
                            }),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: primaryLight,
                                    width: 1.0,
                                    style: BorderStyle.solid,
                                  )
                                )
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      color: (widget.filterMode == e.key ? accentDark : Colors.transparent),
                                      borderRadius: BorderRadius.circular(2),
                                      border: Border.all(
                                        color: accentDark,
                                        width: 1.0,
                                        style: BorderStyle.solid,
                                      )
                                    ),
                                    child: Center(
                                      child: Text(
                                        e.key,
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: (widget.filterMode == e.key ? textPrimary : accentColor),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10,),
                                  Text(
                                    e.value,
                                    style: TextStyle(
                                      color: (widget.filterMode == e.key ? accentColor : textPrimary),
                                      fontWeight: (widget.filterMode == e.key ? FontWeight.bold : FontWeight.normal),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )).toList(),
                        ],
                      )
                    );
                  },
                );
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
                      child: Text(widget.filterList[widget.filterMode] ?? 'Code'),
                    ),
                    const SizedBox(width: 5,),
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
          const SizedBox(width: 5,),
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
                  style: (widget.filterSort == "ASC" ? _filterTypeSelected : _filterTypeUnselected),
                ),
              ),
            ),
          ),
          const SizedBox(width: 2,),
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
                  style: (widget.filterSort == "DESC" ? _filterTypeSelected : _filterTypeUnselected),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}