import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:my_wealth/themes/colors.dart';

class CommonLoadingPage extends StatelessWidget {
  final bool? isNeedScaffold;
  const CommonLoadingPage({Key? key, this.isNeedScaffold}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if ((isNeedScaffold ?? true)) {
      return Scaffold(
        body: Container(
          width: double.infinity,
          color: primaryColor,
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
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
    else {
      // no need scaffold as this is probably coming from embeded page like
      // from insight that already have scaffold inside.
      return Container(
        width: double.infinity,
        color: primaryColor,
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
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
      );
    }
  }
}