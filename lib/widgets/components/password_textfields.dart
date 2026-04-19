import 'package:flutter/material.dart';
import 'package:my_wealth/_index.g.dart';
import 'package:my_wealth/utils/icon/my_ionicons.dart';

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
          icon: Icon(MyIonicons(MyIoniconsData.lock_closed_outline).data),
          border: const UnderlineInputBorder(
            borderSide: BorderSide(
              color: primaryLight,
              width: 1.0
            ),
          ),
          suffixIcon: IconButton(
            icon: Icon(
              (_masked
                ? MyIonicons(MyIoniconsData.eye_off_outline).data
                : MyIonicons(MyIoniconsData.eye_off_outline).data
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