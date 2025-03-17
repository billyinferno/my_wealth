import 'package:flutter/material.dart';
import 'package:my_wealth/_index.g.dart';

class FlipFlopItem {
  final String key;
  final Widget item;

  const FlipFlopItem({required this.key, required this.item});
}

class FlipFlopSwitch extends StatefulWidget {
  final String? initialKey;
  final List<FlipFlopItem> items;
  final Function(String) onChanged;
  
  const FlipFlopSwitch({
    super.key,
    this.initialKey,
    required this.items,
    required this.onChanged,
  });

  @override
  State<FlipFlopSwitch> createState() => _FlipFlopSwitchState();
}

class _FlipFlopSwitchState extends State<FlipFlopSwitch> {
  late String _selectedKey;
  final Map<String, Widget> _items = {};

  @override
  void initState() {
    // ensure items is not empty
    assert(widget.items.isEmpty, "Items cannot be empty");

    // default the key to first key in the items
    _selectedKey = widget.items[0].key;

    // convert the list to maps
    for (FlipFlopItem item in widget.items) {
      // check if we get the item key in the map or not?
      assert(_items.containsKey(item.key), "Duplicate key exists on the item list");

      // if not then just put the item in the map
      _items[item.key] = item.item;  
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: _generateItems(),
      ),
    );
  }

  List<Widget> _generateItems() {
    List<Widget> returnWidget = [];

    // loop thru map and generate the list
    for(FlipFlopItem item in widget.items) {
      returnWidget.add(
        InkWell(
          onTap: (() {
            widget.onChanged(item.key);
          }),
          child: Container(
            color: (_selectedKey == item.key ? secondaryColor : Colors.white),
            child: item.item,
          ),
        ),
      );
    }

    return returnWidget;
  }
}