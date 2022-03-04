import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:my_wealth/router.dart';
import 'package:my_wealth/storage/local_box.dart';

void main() {
  // this is needed to ensure that all the binding already initialized before
  // we plan to load the shared preferences.
  WidgetsFlutterBinding.ensureInitialized();

  // initialize flutter application
  Future.wait([
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]), // set prefered orientation
    dotenv.load(fileName: "env/.dev.env"), // load the environment files
    Hive.initFlutter(), // initialize Hive
    LocalBox.init(), // initialize box (normal and secure)
  ]).then((_) {
    // if all the future success means application is initialized
    debugPrint("💯 Application Initialized");
  }).onError((error, stackTrace) {
    // if caught error print all the error and the stack trace
    debugPrint(error.toString());
    debugPrint(stackTrace.toString());
  }).whenComplete(() {
    // run the application whatever happen with the future
    runApp(const MyApp());
  });
}

class MyApp extends StatefulWidget {
  const MyApp({ Key? key }) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    // return router page, as we will perform all the routing from router page
    // to minimize the main page.
    return const RouterPage();
  }
}
