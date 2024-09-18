import 'dart:math';

import 'package:flutter/material.dart';
import 'package:my_wealth/_index.g.dart';

class ShowMyModalBottomSheet {
  final BuildContext context;
  final String title;
  final Color bgColor;
  final double maxHeight;
  final Map<String, String> filterList;
  final String filterMode;
  final Function(String) onFilterSelect;

  ShowMyModalBottomSheet({
    required this.context,
    this.title = "Select Filter",
    this.bgColor = Colors.black,
    this.maxHeight = 400,
    required this.filterList,
    required this.filterMode,
    required this.onFilterSelect}
  );

  Future<void> show() {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      builder: (context) {
        return Container(
          height: (min((filterList.length * 40) + 60, maxHeight)),
          margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
          padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Center(
                child: Text(title),
              ),
              Expanded(
                child: MySafeArea(
                  bottomPadding: 15, // since we already add 10 on the default
                  child: ListView.builder(
                    itemCount: filterList.length,
                    itemBuilder: ((context, index) {
                      String key = filterList.keys.elementAt(index);
                                
                      return GestureDetector(
                        onTap: (() {
                          onFilterSelect(key);
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
                          ))),
                          child: Row(
                            crossAxisAlignment:
                                CrossAxisAlignment.center,
                            mainAxisAlignment:
                                MainAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: (
                                    filterMode == key ?
                                    accentDark :
                                    Colors.transparent
                                  ),
                                  borderRadius: BorderRadius.circular(2),
                                  border: Border.all(
                                    color: accentDark,
                                    width: 1.0,
                                    style: BorderStyle.solid,
                                  )
                                ),
                                child: Center(
                                  child: Text(
                                    key,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: (
                                        filterMode == key ?
                                        textPrimary :
                                        accentColor
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10,),
                              Text(
                                filterList[key]!,
                                style: TextStyle(
                                  color: (
                                    filterMode == key ?
                                    accentColor :
                                    textPrimary
                                  ),
                                  fontWeight: (
                                    filterMode == key ?
                                    FontWeight.bold :
                                    FontWeight.normal
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    })
                  ),
                ),
              ),
            ],
          )
        );
      },
    );
  }
}