import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:my_wealth/_index.g.dart';

class CommonLoadingPage extends StatelessWidget {
  final bool isNeedScaffold;
  final String loadingText;
  const CommonLoadingPage({
    super.key,
    this.isNeedScaffold = true,
    this.loadingText = "Loading data...",
  });

  @override
  Widget build(BuildContext context) {
    if ((isNeedScaffold)) {
      return Scaffold(
        body: Container(
          width: double.infinity,
          color: primaryColor,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const SpinKitCubeGrid(
                color: secondaryColor,
                size: 25,
              ),
              const SizedBox(height: 5,),
              Text(
                loadingText,
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
    else {
      // no need scaffold as this is probably coming from embeded page like
      // from insight that already have scaffold inside.
      return Container(
        width: double.infinity,
        color: primaryColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const SpinKitCubeGrid(
              color: secondaryColor,
              size: 25,
            ),
            const SizedBox(height: 5,),
            Text(
              loadingText,
              style: const TextStyle(
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