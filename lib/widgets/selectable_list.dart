import 'package:flutter/material.dart';
import 'package:my_wealth/widgets/selectable_button.dart';

class SelectableItem {
  final String name;
  final String value;

  const SelectableItem({required this.name, required this.value});
}

class SelectableList extends StatefulWidget {
  final List<SelectableItem> items;
  final String? initialValue;
  final Function(String) onPress;
  const SelectableList({Key? key, required this.items, this.initialValue, required this.onPress}) : super(key: key);

  @override
  State<SelectableList> createState() => _SelectableListState();
}

class _SelectableListState extends State<SelectableList> {
  final Map<String, String> _items = {};
  String _initialValue = "";
  String _selectedValue = "";
  
  @override
  void initState() {
    // loop thru the items and put it into map
    for (SelectableItem item in widget.items) {
      _items[item.name] = item.value;
    }

    // check if initial value is set or not?
    if (widget.items.isNotEmpty) {
      _initialValue = (widget.initialValue ?? widget.items[0].value);

      // ensure that this initial value is exists
      assert(_items.containsKey(_initialValue), 'Initial keys is not part of the item list');
    }

    // set the selected value as initial value
    _selectedValue = _initialValue;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: _items.entries.map((item) {
          return SelectableButton(
            text: item.value,
            selected: (item.key == _selectedValue),
            onPress: (() {
              widget.onPress(item.key);
              _setSelected(item.key);
            })
          );
        }).toList(),
      ),
    );
  }

  void _setSelected(String value) {
    setState(() {
      _selectedValue = value;
    });
  }
}