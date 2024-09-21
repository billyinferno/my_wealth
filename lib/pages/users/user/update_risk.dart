import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';
import 'package:my_wealth/_index.g.dart';

class UpdateRiskPage extends StatefulWidget {
  const UpdateRiskPage({ super.key });

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
    return Scaffold(
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
      body: MySafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(25, 25, 25, 0),
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
                      inactiveColor: textPrimary,
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
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  TransparentButton(
                    icon: Ionicons.save,
                    text: "Save",
                    color: secondaryColor,
                    onTap: (() async {
                      // check if the current value and slide value for risk factor
                      // is the same or not?
                      if (_userInfo!.risk == _riskValue.toInt()) {
                        // skip, and just go back
                        Navigator.pop(context);
                      }
                      else {
                        Log.success(message: "💾 Save the updated risk factor");
                        // show loading screen
                        LoadingScreen.instance().show(context: context);
                              
                        // call API to update user risk
                        await _userApi.updateRisk(
                          risk: _riskValue.toInt()
                        ).then((resp) async {
                          // we will get updated user info here, so stored the updated
                          // user info with new risk factor to the local storea
                          await UserSharedPreferences.setUserInfo(userInfo: resp);
                            
                          // update the provider to notify the user page
                          if (context.mounted) {
                            Provider.of<UserProvider>(context, listen: false).setUserLoginInfo(user: resp);
                              
                            // once finished, then pop out from this page
                            Navigator.pop(context);
                          }    
                        }).onError((error, stackTrace) {
                          if (context.mounted) {                        
                            // showed the snack bar
                            ScaffoldMessenger.of(context).showSnackBar(
                              createSnackBar(
                                message: "Unable to update risk factor",
                              )
                            );
                          }
                        }).whenComplete(() {
                          LoadingScreen.instance().hide();
                        },);
                      }
                    })
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}