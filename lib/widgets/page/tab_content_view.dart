import 'package:flutter/material.dart';

class TabContentView extends StatelessWidget {
  final List<Widget> children;

  const TabContentView({
    super.key,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    var controller = DefaultTabController.of(context);
    
    return ListenableBuilder(
      listenable: controller,
      builder: (context, child) {
        return children[controller.index];
      }
    );
  }
}