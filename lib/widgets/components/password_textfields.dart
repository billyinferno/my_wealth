import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:my_wealth/_index.g.dart';

class PasswordTextFields extends StatefulWidget {
  final TextEditingController controller;
  final String title;
  final bool masked;
  const PasswordTextFields({
    super.key,
    required this.controller,
    required this.title,
    this.masked = true,
  });

  @override
  State<PasswordTextFields> createState() => _PasswordTextFieldsState();
}

class _PasswordTextFieldsState extends State<PasswordTextFields> {
  late bool _masked;

  @override
  void initState() {
    super.initState();
    
    _masked = widget.masked;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
      child: TextFormField(
        controller: widget.controller,
        cursorColor: primaryLight,
        decoration: InputDecoration(
          labelText: widget.title,
          labelStyle: const TextStyle(
            color: primaryLight
          ),
          icon: const Icon(Ionicons.lock_closed_outline),
          border: const UnderlineInputBorder(
            borderSide: BorderSide(
              color: primaryLight,
              width: 1.0
            ),
          ),
          suffixIcon: IconButton(
            icon: Icon(
              (_masked
                ? Ionicons.eye_off_outline
                : Ionicons.eye_off_outline
              ),
              color: secondaryLight,
            ),
            onPressed: (() {
              setState(() {
                _masked = !_masked;
              });
            }),
          ),
        ),
        obscureText: _masked,
      ),
    );
  }
}