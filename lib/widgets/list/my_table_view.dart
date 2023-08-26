import 'package:flutter/material.dart';
import 'package:my_wealth/themes/colors.dart';

class MyTableItem {
  final String title;
  final List<String> content;
  final Color? color;
  final double? width;
  final Alignment? textAlign;

  MyTableItem({required this.title, required this.content, required this.color, this.width, this.textAlign});
}

class MyTableView extends StatelessWidget {
  final List<MyTableItem> data;
  const MyTableView({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _itemWithHeader();
  }

  Widget _itemWithHeader() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: primaryLight,
            style: BorderStyle.solid,
            width: 1.0,
          ),
          bottom: BorderSide(
            color: primaryLight,
            style: BorderStyle.solid,
            width: 1.0,
          ),
          right: BorderSide(
            color: primaryLight,
            style: BorderStyle.solid,
            width: 1.0,
          )
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          // loop thru the data
          ..._loopData(),
        ],
      ),
    );
  }

  List<Widget> _loopData() {
    List<Widget> ret = [];

    for (MyTableItem value in data) {
      // add the table on ret
      ret.add(_header(item: value));     
    }

    return ret;
  }

  Widget _header({required MyTableItem item}) {  
    const TextStyle headerStyle = TextStyle(
      fontSize: 10,
    );

    if (item.width != null) {
      return Container(
        width: item.width,
        decoration: const BoxDecoration(
          color: primaryDark,
          border: Border(
            left: BorderSide(
              color: primaryLight,
              style: BorderStyle.solid,
              width: 1.0,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(2, 0, 2, 0),
              color: item.color,
              child: Center(
                child: Text(
                  item.title,
                  style: headerStyle.copyWith(
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
            ),
            ...List<Widget>.generate(item.content.length, (index) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(2, 0, 2, 0),
                child: Align(
                  alignment: (item.textAlign ?? Alignment.center),
                  child: Text(
                    item.content[index],
                    style: headerStyle,
                  ),
                ),
              );
            },),
          ],
        ),
      );
    }
    else {
      return Expanded(
        child: Container(
          decoration: const BoxDecoration(
            color: primaryDark,
            border: Border(
              left: BorderSide(
                color: primaryLight,
                style: BorderStyle.solid,
                width: 1.0,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(2, 0, 2, 0),
                color: item.color,
                child: Center(
                  child: Text(
                    item.title,
                    style: headerStyle.copyWith(
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              ),
              ...List<Widget>.generate(item.content.length, (index) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(2, 0, 2, 0),
                  child: Align(
                    alignment: (item.textAlign ?? Alignment.center),
                    child: Text(
                      item.content[index],
                      style: headerStyle,
                    ),
                  ),
                );
              },),
            ],
          ),
        ),
      );
    }
  }
}