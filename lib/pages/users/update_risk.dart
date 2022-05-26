import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:my_wealth/api/user_api.dart';
import 'package:my_wealth/model/user_login.dart';
import 'package:my_wealth/provider/user_provider.dart';
import 'package:my_wealth/themes/colors.dart';
import 'package:my_wealth/utils/dialog/create_snack_bar.dart';
import 'package:my_wealth/utils/loader/show_loader_dialog.dart';
import 'package:my_wealth/utils/prefs/shared_user.dart';
import 'package:provider/provider.dart';

class UpdateRiskPage extends StatefulWidget {
  const UpdateRiskPage({ Key? key }) : super(key: key);

  @override
  UpdateRiskPageState createState() => UpdateRiskPageState();
}

class UpdateRiskPageState extends State<UpdateRiskPage> {
  late UserLoginInfoModel? _userInfo;
  late double _riskValue;
  final UserAPI _userApi = UserAPI();

  @override
  void initState() {
    super.initState();
    _userInfo = UserSharedPreferences.getUserInfo();
    _riskValue = _userInfo!.risk.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: (() async {
        return false;
      }),
      child: Scaffold(
        appBar: AppBar(
          title: const Center(
            child: Text(
              "Update Risk",
              style: TextStyle(
                color: secondaryColor,
              ),
            )
          ),
          leading: IconButton(
            icon: const Icon(
              Ionicons.arrow_back
            ),
            onPressed: (() {
              Navigator.pop(context);
            }),
          ),
        ),
        body: Container(
          padding: const EdgeInsets.all(25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Text("Current risk factor is "),
                  Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.green,
                          width: 2.0,
                          style: BorderStyle.solid,
                        )
                      )
                    ),
                    child: Text(
                      "${_userInfo!.risk}%",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10,),
              const Text("Change risk factor to:"),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Slider(
                      value: _riskValue,
                      onChanged: ((value) {
                        setState(() {
                          _riskValue = value.toInt().toDouble();
                        });
                      }),
                      min: 5,
                      max: 100,
                      divisions: 95,
                      label: _riskValue.toInt().toString(),
                      activeColor: accentColor,
                      inactiveColor: accentDark,
                    ),
                  ),
                  SizedBox(
                    width: 45,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text("$_riskValue%")
                    )
                  ),
                ],
              ),
              const SizedBox(height: 10,),
              MaterialButton(
                minWidth: double.infinity,
                color: secondaryColor,
                textColor: textPrimary,
                onPressed: (() async {
                  // check if the current value and slide value for risk factor
                  // is the same or not?
                  if (_userInfo!.risk == _riskValue.toInt()) {
                    // skip, and just go back
                    Navigator.pop(context);
                  }
                  else {
                    debugPrint("💾 Save the updated risk factor");
                    showLoaderDialog(context);
                    await _userApi.updateRisk(_riskValue.toInt()).then((resp) async {
                      // remove the loader dialog
                      Navigator.pop(context);
    
                      // we will get updated user info here, so stored the updated
                      // user info with new risk factor to the local storea
                      await UserSharedPreferences.setUserInfo(resp);
    
                      // update the provider to notify the user page
                      if (!mounted) return;
                      Provider.of<UserProvider>(context, listen: false).setUserLoginInfo(resp);
    
                      // once finished, then pop out from this page
                      Navigator.pop(context);
                    }).onError((error, stackTrace) {
                      // remove the loader dialog
                      Navigator.pop(context);
    
                      // showed the snack bar
                      ScaffoldMessenger.of(context).showSnackBar(
                        createSnackBar(
                          message: "Unable to update risk factor",
                        )
                      );
                    });
                  }
                }),
                child: const Text("Save")
              ),
            ],
          ),
        ),
      ),
    );
  }
}