import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:my_wealth/_index.g.dart';

class PasswordTextFields extends StatefulWidget {
  final TextEditingController controller;
  final String title;
  final String hintText;
  final bool masked;
  const PasswordTextFields({
    super.key,
    required this.controller,
    required this.title,
    this.hintText = '',
    this.masked = true,
  });

  @override
  State<PasswordTextFields> createState() => _PasswordTextFieldsState();
}

class _PasswordTextFieldsState extends State<PasswordTextFields> {
  late bool _masked;

  @override
  void initState() {
    _masked = widget.masked;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: primaryLight,
            width: 1.0,
            style: BorderStyle.solid,
          ),
        )
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          const SizedBox(width: 10,),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: secondaryLight,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(width: 10,),
          Expanded(
            child: TextFormField(
              controller: widget.controller,
              showCursor: true,
              cursorColor: secondaryColor,
              keyboardAppearance: Brightness.dark,
              textAlign: TextAlign.right,
              obscureText: _masked,
              decoration: InputDecoration(
                border: const OutlineInputBorder(
                  borderSide: BorderSide.none,
                ),
                focusColor: secondaryColor,
                hintText: widget.hintText,
                hintStyle: TextStyle(
                  color: textPrimary.withValues(alpha: 0.3),
                  fontStyle: FontStyle.italic,
                ),
                suffix: IconButton(
                  onPressed: (() {
                    setState(() {
                      _masked = !_masked;
                    });
                  }),
                  icon: Icon(
                    (_masked ? Ionicons.eye_outline : Ionicons.eye_off_outline),
                    size: 15,
                    color: primaryLight,
                  )
                )
              ),
            ),
          ),
        ],
      ),
    );
  }
}