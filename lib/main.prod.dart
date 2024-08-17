import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:my_wealth/_index.g.dart';

void main() async {
  // run all the initialisation on the runZonedGuarded to ensure that all the
  // init already finished before we perform runApp.
  await runZonedGuarded(() async {
    // ensure that the flutter widget already binding
    WidgetsFlutterBinding.ensureInitialized();

    // after that we can initialize the box
    await Future.microtask(() async {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]); // set prefered orientation
      await dotenv.load(fileName: "env/.prod.env"); // load the environment files
      await Hive.initFlutter(); // initialize Hive
      await LocalBox.init(); // initialize box (normal and secure)
    }).then((_) {
      // if all the future success means application is initialized
      Log.success(message: "💯 Application Initialized");
    }).onError((error, stackTrace) {
      // if caught error print all the error and the stack trace
      Log.error(
        message: "Error when initialized application",
        error: error,
        stackTrace: stackTrace,
      );
    }).whenComplete(() {
      // run the application whatever happen with the future
      runApp(const MyApp());
    });
  }, (error, stack) {
    Log.error(
      message: "Error during runZonedGuarded",
      error: error,
      stackTrace: stack
    );
  },);
}

class MyApp extends StatefulWidget {
  const MyApp({ super.key });

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    // return router page, as we will perform all the routing from router page
    // to minimize the main page.
    return const RouterPage();
  }
}
