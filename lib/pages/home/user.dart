import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:my_wealth/model/user_login.dart';
import 'package:my_wealth/provider/user_provider.dart';
import 'package:my_wealth/storage/local_box.dart';
import 'package:my_wealth/themes/colors.dart';
import 'package:my_wealth/utils/dialog/show_my_dialog.dart';
import 'package:my_wealth/utils/prefs/shared_user.dart';
import 'package:provider/provider.dart';

class UserPage extends StatefulWidget {
  const UserPage({ Key? key }) : super(key: key);

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  late UserLoginInfoModel? _userInfo;
  
  @override
  void initState() {
    super.initState();

    _userInfo = UserSharedPreferences.getUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: ((context, userProvider, child) {
        _userInfo = userProvider.userInfo;
        return Container(
          padding: const EdgeInsets.all(25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              const Text("hello,"),
              Text(
                _userInfo!.username,
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 25,),
              InkWell(
                onTap: (() {
                  //TODO: navigate to new screen to change password
                  debugPrint("Change Password");
                }),
                child: Container(
                  width: double.infinity,
                  height: 60,
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
                    children: const <Widget>[
                      Icon(
                        Ionicons.lock_open,
                        color: secondaryColor,
                        size: 20,
                      ),
                      SizedBox(width: 10,),
                      Expanded(
                        child: Text(
                          "Change Password",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ),
                    ],
                  )
                ),
              ),
              InkWell(
                onTap: (() {
                  Navigator.pushNamed(context, '/user/risk');
                }),
                child: Container(
                  width: double.infinity,
                  height: 60,
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
                      const Icon(
                        Ionicons.warning_outline,
                        color: secondaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 10,),
                      Expanded(
                        child: Text(
                          "Risk Factor (Current: " + _userInfo!.risk.toString() + "%)",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ),
                    ],
                  )
                ),
              ),
              InkWell(
                onTap: (() {
                  Future<bool?> result = ShowMyDialog(
                    title: "Logout",
                    text: "Do you want to logout?",
                  ).show(context);

                  result.then((value) async {
                    if(value == true) {
                      await LocalBox.clear().then((_) {
                        debugPrint("🧹 Cleaning Local Storage");
                        // navigate back to login
                        Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false);
                      });
                    }
                  });
                }),
                child: Container(
                  width: double.infinity,
                  height: 60,
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
                    children: const <Widget>[
                      Icon(
                        Ionicons.log_out_outline,
                        color: secondaryColor,
                        size: 20,
                      ),
                      SizedBox(width: 10,),
                      Expanded(
                        child: Text(
                          "Logout",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ),
                    ],
                  )
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}