import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:my_wealth/themes/colors.dart';

class CommonLoadingPage extends StatelessWidget {
  const CommonLoadingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        color: primaryColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: const <Widget>[
            SpinKitCubeGrid(
              color: secondaryColor,
              size: 25,
            ),
            SizedBox(height: 5,),
            Text(
              "Loading data...",
              style: TextStyle(
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