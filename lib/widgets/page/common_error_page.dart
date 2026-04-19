import 'package:flutter/material.dart';
import 'package:my_wealth/_index.g.dart';
import 'package:my_wealth/utils/icon/my_ionicons.dart';

class CommonErrorPage extends StatelessWidget {
  final String errorText;
  final bool isNeedScaffold;
  const CommonErrorPage({
    super.key,
    required this.errorText,
    this.isNeedScaffold = true
  });

  @override
  Widget build(BuildContext context) {
    if (isNeedScaffold) {
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
              Icon(
                MyIonicons(MyIoniconsData.alert_circle).data,
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
    else {
      return Container(
        width: double.infinity,
        color: primaryColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(
              MyIonicons(MyIoniconsData.alert_circle).data,
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
      );
    }
  }
}