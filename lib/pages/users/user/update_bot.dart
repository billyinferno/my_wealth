import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';
import 'package:my_wealth/_index.g.dart';

class UpdateBotPage extends StatefulWidget {
  const UpdateBotPage({super.key});

  @override
  State<UpdateBotPage> createState() => _UpdateBotPageState();
}

class _UpdateBotPageState extends State<UpdateBotPage> {
  late UserLoginInfoModel? _userInfo;
  late String _bot;
  final TextEditingController _controller = TextEditingController();
  final UserAPI _userApi = UserAPI();

  @override
  void initState() {
    super.initState();
    _userInfo = UserSharedPreferences.getUserInfo();
    _bot = _userInfo!.bot;
    _controller.text = _bot;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
            child: Text(
          "Update Telegram Bot Token",
          style: TextStyle(
            color: secondaryColor,
          ),
        )),
        leading: IconButton(
          icon: const Icon(Ionicons.arrow_back),
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
              const Text("Telegram Token:"),
              const SizedBox(
                height: 10,
              ),
              Container(
                decoration: BoxDecoration(
                    border: Border.all(
                  color: primaryLight,
                  width: 1.0,
                  style: BorderStyle.solid,
                )),
                child: TextFormField(
                  controller: _controller,
                  showCursor: true,
                  cursorColor: secondaryColor,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  keyboardAppearance: Brightness.dark,
                  textAlign: TextAlign.right,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                    ),
                    focusColor: secondaryColor,
                    hintText: "Token Bot",
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              MaterialButton(
                minWidth: double.infinity,
                color: secondaryColor,
                textColor: textPrimary,
                onPressed: (() async {
                  // check if the current value and slide value for risk factor
                  // is the same or not?
                  if (_controller.text == _bot) {
                    // skip, and just go back
                    Navigator.pop(context);
                  } else {
                    if (_controller.text.isNotEmpty) {
                      Log.success(message: "💾 Save the updated bot token");
                      // show loading screen
                      LoadingScreen.instance().show(context: context);
          
                      // update the bot token
                      await _userApi.updateBotToken(
                        bot: _controller.text
                      ).then((resp) async {
                        // we will get updated user info here, so stored the updated
                        // user info with new risk factor to the local storea
                        await UserSharedPreferences.setUserInfo(userInfo: resp);
                        
                        if (context.mounted) {
                          // update the provider to notify the user page
                          Provider.of<UserProvider>(context, listen: false).setUserLoginInfo(user: resp);
          
                          // once finished, then pop out from this page
                          Navigator.pop(context);
                        }
                      }).onError((error, stackTrace) {
                        if (context.mounted) {
                          // showed the snack bar
                          ScaffoldMessenger.of(context).showSnackBar(createSnackBar(
                            message: "Unable to update Bot Token",
                          ));
                        }
                      }).whenComplete(() {
                        // remove loading screen after finished
                        LoadingScreen.instance().hide();
                      },);
                    } else {
                      // showed the snack bar
                      ScaffoldMessenger.of(context)
                          .showSnackBar(createSnackBar(
                        message: "Bot Token empty",
                      ));
                    }
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
