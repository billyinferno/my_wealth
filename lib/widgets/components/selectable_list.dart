import 'package:flutter/material.dart';
import 'package:my_wealth/_index.g.dart';

class SelectableList<T> extends StatefulWidget {
  final Map<T, String> items;
  final T? initialValue;
  final Function(T) onPress;
  const SelectableList({
    super.key,
    required this.items,
    this.initialValue,
    required this.onPress,
  });

  @override
  State<SelectableList<T>> createState() => _SelectableListState<T>();
}

class _SelectableListState<T> extends State<SelectableList<T>> {
  late T _initialValue;
  late T _selectedValue;
  
  @override
  void initState() {
    super.initState();

    // check if initial value is set or not?
    if (widget.items.isNotEmpty) {
      _initialValue = (widget.initialValue ?? widget.items.keys.first);

      // ensure that this initial value is exists
      assert(
        widget.items.containsKey(_initialValue),
        'Initial keys ${_initialValue.toString()} is not part of the item list',
      );
    }

    // set the selected value as initial value
    _selectedValue = _initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: widget.items.entries.map((item) {
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

  void _setSelected(T value) {
    setState(() {
      _selectedValue = value;
    });
  }
}