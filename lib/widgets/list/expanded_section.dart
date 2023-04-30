import 'package:flutter/material.dart';

class ExpandedSection extends StatefulWidget {
  final Widget child;
  final bool expand;
  const ExpandedSection({Key? key, required this.child, required this.expand}) : super(key: key);

  @override
  State<ExpandedSection> createState() => _ExpandedSectionState();
}

class _ExpandedSectionState extends State<ExpandedSection> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation; 

  @override
  void initState() {
    super.initState();
    _prepareAnimation();
    _runExpandCheck();
  }

  void _prepareAnimation() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _animation = CurvedAnimation(
      parent: _controller, 
      curve: Curves.fastOutSlowIn
    );
  }

  void _runExpandCheck() {
    if (widget.expand) {
      _controller.forward();
    }
    else {
      _controller.reverse();
    }
  }

  @override
  void didUpdateWidget(covariant ExpandedSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    _runExpandCheck();
  }

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      axisAlignment: 1.0,
      sizeFactor: _animation,
      child: widget.child,
    );
  }
}