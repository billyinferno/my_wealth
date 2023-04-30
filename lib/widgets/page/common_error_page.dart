import 'package:flutter/material.dart';
import 'package:my_wealth/themes/colors.dart';

class CommonErrorPage extends StatelessWidget {
  final String errorText;
  const CommonErrorPage({Key? key, required this.errorText}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            "Error",
            style: TextStyle(
              color: secondaryColor,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: (() async {
            Navigator.pop(context);
          }),
        ),
      ),
      body: Container(
        width: double.infinity,
        color: primaryColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 5,),
            Text(
              errorText,
              style: const TextStyle(
                color: secondaryColor,
                fontSize: 10,
              ),
            ),
          ],
        ),
      )
    );
  }
}