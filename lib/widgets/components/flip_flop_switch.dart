import 'package:flutter/material.dart';
import 'package:my_wealth/_index.g.dart';

class FlipFlopItem<T> {
  final T key;
  final IconData icon;

  const FlipFlopItem({required this.key, required this.icon});
}

class FlipFlopSwitch<T> extends StatefulWidget {
  final T? initialKey;
  final List<FlipFlopItem> icons;
  final double width;
  final double height;
  final double iconSize;
  final Function(T) onChanged;
  
  const FlipFlopSwitch({
    super.key,
    this.initialKey,
    required this.icons,
    this.width = 25,
    this.height = 25,
    this.iconSize = 15,
    required this.onChanged,
  });

  @override
  State<FlipFlopSwitch> createState() => _FlipFlopSwitchState();
}

class _FlipFlopSwitchState<T> extends State<FlipFlopSwitch> {
  late T _selectedKey;
  final Map<T, IconData> _items = {};

  @override
  void initState() {
    // ensure items is not empty
    assert(widget.icons.isNotEmpty, "Items cannot be empty");

    // default the key to first key in the items
    _selectedKey = (widget.initialKey ?? widget.icons[0].key);

    // convert the list to maps
    for (FlipFlopItem item in widget.icons) {
      // check if we get the item key in the map or not?
      assert(!_items.containsKey(item.key), "Duplicate key exists on the item list");

      // if not then just put the item in the map
      _items[item.key] = item.icon;  
    }
    
    assert(_items.containsKey(_selectedKey), "Invalid initial key");

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: (widget.icons.length * widget.width),
      height: widget.height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: _generateItems(),
      ),
    );
  }

  List<Widget> _generateItems() {
    List<Widget> returnWidget = [];
    int i = 1;

    // loop thru map and generate the list
    for(FlipFlopItem item in widget.icons) {
      BorderRadius? radius;

      // check whether we are first item or last one
      if (i == 1) {
        // first item
        radius = BorderRadius.only(
          topLeft: Radius.circular(5),
          bottomLeft: Radius.circular(5),
        );
      }
      else if (i == widget.icons.length) {
        // last one
        radius = BorderRadius.only(
          topRight: Radius.circular(5),
          bottomRight: Radius.circular(5),
        );
      }

      returnWidget.add(
        InkWell(
          onTap: (() {
            setState(() {
              _selectedKey = item.key;           
              widget.onChanged(item.key);
            });
          }),
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: (_selectedKey == item.key ? secondaryColor : Colors.white),
              borderRadius: radius,
            ),
            child: Center(
              child: Icon(
                item.icon,
                size: widget.iconSize,
                color: (_selectedKey == item.key ? Colors.white : secondaryColor),
              )
            ),
          ),
        ),
      );

      // next item
      i++;
    }

    return returnWidget;
  }
}