import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:my_wealth/themes/colors.dart';

class CommonErrorPage extends StatelessWidget {
  final String errorText;
  const CommonErrorPage({super.key, required this.errorText});

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
            const Icon(
              Ionicons.alert_circle,
              color: secondaryColor,
              size: 20,
            ),
            const SizedBox(height: 10,),
            Text(
              errorText,
              style: const TextStyle(
                color: secondaryColor,
                fontSize: 15,
              ),
            ),
          ],
        ),
      )
    );
  }
}