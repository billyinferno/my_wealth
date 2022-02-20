import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:my_wealth/themes/colors.dart';

class PasswordTextFields extends StatefulWidget {
  final TextEditingController controller;
  final String title;
  final bool? masked;
  const PasswordTextFields({ Key? key,
    required this.controller,
    required this.title,
    this.masked }) : super(key: key);

  @override
  _PasswordTextFieldsState createState() => _PasswordTextFieldsState();
}

class _PasswordTextFieldsState extends State<PasswordTextFields> {
  bool _masked = false;

  @override
  void initState() {
    super.initState();
    _masked = (widget.masked ?? false);
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
          Text(
            widget.title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: secondaryLight,
            ),
          ),
          const SizedBox(width: 10,),
          Expanded(
            child: TextFormField(
              controller: widget.controller,
              showCursor: true,
              cursorColor: secondaryColor,
              keyboardAppearance: Brightness.dark,
              textAlign: TextAlign.right,
              decoration: const InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                ),
                focusColor: secondaryColor,
              ),
              obscureText: _masked,
            ),
          ),
          const SizedBox(width: 10,),
          IconButton(
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
          ),
        ],
      ),
    );
  }
}
