import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:my_wealth/api/user_api.dart';
import 'package:my_wealth/model/user/user_login.dart';
import 'package:my_wealth/provider/user_provider.dart';
import 'package:my_wealth/storage/box/local_box.dart';
import 'package:my_wealth/themes/colors.dart';
import 'package:my_wealth/utils/dialog/create_snack_bar.dart';
import 'package:my_wealth/utils/dialog/show_my_dialog.dart';
import 'package:my_wealth/utils/globals.dart';
import 'package:my_wealth/utils/loader/show_loader_dialog.dart';
import 'package:my_wealth/storage/prefs/shared_user.dart';
import 'package:my_wealth/utils/net/netutils.dart';
import 'package:provider/provider.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final UserAPI _userApi = UserAPI();
  late UserLoginInfoModel? _userInfo;
  bool _isVisible = false;
  bool _showLots = false;
  bool _showEmptyWatchlist = true;
  
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            "User Profile",
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
      body: Consumer<UserProvider>(builder: (context, userProvider, child) {
        // get the user information from provider
        _userInfo = userProvider.userInfo;

        // now check current user configuration
        _isVisible = _userInfo!.visibility;
        _showLots = _userInfo!.showLots;
        _showEmptyWatchlist = _userInfo!.showEmptyWatchlist;

        // once finished return the page
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
              const SizedBox(height: 12,),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    InkWell(
                      onTap: (() {
                        Navigator.pushNamed(context, '/user/password');
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
                        child: const Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
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
                                "Risk Factor (Current: ${_userInfo!.risk}%)",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            ),
                          ],
                        )
                      ),
                    ),
                    Container(
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
                      width: double.infinity,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Icon(
                                      Ionicons.eye_outline,
                                      color: secondaryColor,
                                      size: 20,
                                    ),
                                    SizedBox(width: 10,),
                                    Text(
                                      "Visibility",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10,),
                          CupertinoSwitch(
                            value: _isVisible,
                            onChanged: ((value) async {
                              _isVisible = !_isVisible;
                              await _updateVisibilitySummary(_isVisible).then((resp) {
                                debugPrint("🔃 Update Visibility to $_isVisible");
                                setSummaryVisible(_isVisible);
                              }).onError((error, stackTrace) {
                                _showScaffoldMessage(text: error.toString());
                              });
                            }),
                          ),
                        ],
                      )
                    ),
                    Container(
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
                      width: double.infinity,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Icon(
                                      Ionicons.list_outline,
                                      color: secondaryColor,
                                      size: 20,
                                    ),
                                    SizedBox(width: 10,),
                                    Text(
                                      "Show Lots",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10,),
                          CupertinoSwitch(
                            value: _showLots,
                            onChanged: ((value) async {
                              _showLots = !_showLots;
                              await _updateShowLots(_showLots).then((resp) {
                                debugPrint("🔃 Update Show Lots to $_showLots");
                                setShowLots(_showLots);
                              }).onError((error, stackTrace) {
                                _showScaffoldMessage(text: error.toString());
                              });
                            }),
                          ),
                        ],
                      )
                    ),
                    Container(
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
                      width: double.infinity,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Icon(
                                      Ionicons.list_outline,
                                      color: secondaryColor,
                                      size: 20,
                                    ),
                                    SizedBox(width: 10,),
                                    Text(
                                      "Show Empty Watchlist",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10,),
                          CupertinoSwitch(
                            value: _showEmptyWatchlist,
                            onChanged: ((value) async {
                              _showEmptyWatchlist = !_showEmptyWatchlist;
                              await _updateShowEmptyWatchlist(_showEmptyWatchlist).then((resp) {
                                debugPrint("🔃 Update Show Empty Watchlist to $_showEmptyWatchlist");
                                setShowEmptywatchlist(_showEmptyWatchlist);
                              }).onError((error, stackTrace) {
                                _showScaffoldMessage(text: error.toString());
                              });
                            }),
                          ),
                        ],
                      )
                    ),
                    Container(
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
                      width: double.infinity,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                const Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Icon(
                                      Ionicons.information,
                                      color: secondaryColor,
                                      size: 20,
                                    ),
                                    SizedBox(width: 10,),
                                    Text(
                                      "Application Version",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  Globals.appVersion,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: primaryLight,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    ),
                    Container(
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
                      width: double.infinity,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                const Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Icon(
                                      Ionicons.information,
                                      color: secondaryColor,
                                      size: 20,
                                    ),
                                    SizedBox(width: 10,),
                                    Text(
                                      "Flutter Version",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  Globals.flutterVersion,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: primaryLight,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    ),
                    // TODO: to enable once we already have telegram bot token for the price alert, or else
                    // InkWell(
                    //   onTap: (() {
                    //     Navigator.pushNamed(context, '/user/bot');
                    //   }),
                    //   child: Container(
                    //     width: double.infinity,
                    //     height: 60,
                    //     decoration: const BoxDecoration(
                    //       border: Border(
                    //         bottom: BorderSide(
                    //           color: primaryLight,
                    //           width: 1.0,
                    //           style: BorderStyle.solid,
                    //         ),
                    //       )
                    //     ),
                    //     child: Row(
                    //       crossAxisAlignment: CrossAxisAlignment.center,
                    //       mainAxisAlignment: MainAxisAlignment.start,
                    //       children: const <Widget>[
                    //         Icon(
                    //           Ionicons.notifications_outline,
                    //           color: secondaryColor,
                    //           size: 20,
                    //         ),
                    //         SizedBox(width: 10,),
                    //         Expanded(
                    //           child: Text(
                    //             "Telegram Bot Token",
                    //             style: TextStyle(
                    //               fontWeight: FontWeight.bold,
                    //             ),
                    //           )
                    //         ),
                    //       ],
                    //     )
                    //   ),
                    // ),
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
                              // clear the JWT token from NetUtils
                              NetUtils.clearJWT();
                              
                              // navigate back to login
                              if (context.mounted) {
                                Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false);
                              }
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
                        child: const Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
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
              ),
              const SizedBox(height: 30,),
            ],
          ),
        );
      },),
    );
  }

  void setSummaryVisible(visibilility) {
    setState(() {
      _isVisible = visibilility;
    });
  }

  Future<bool> _updateVisibilitySummary(bool visibility) async {
    bool ret = false;

    showLoaderDialog(context);
    await _userApi.updateVisibilitySummary(visibility).then((resp) async {
      // set the return value as true
      ret = true;

      // update the user info and the user provider so it will affect all the listener
      await UserSharedPreferences.setUserInfo(resp);

      // update the provider to notify the user page
      if (!mounted) return;
      Provider.of<UserProvider>(context, listen: false).setUserLoginInfo(resp);
      Provider.of<UserProvider>(context, listen: false).setSummaryVisibility(visibility: visibility);

      // remove the loader
      Navigator.pop(context);
    }).onError((error, stackTrace) {
      if (mounted) {
        // remove the loader
        Navigator.pop(context);
      }

      // throw the exception
      throw Exception(error.toString());
    });

    return ret;
  }

  void setShowLots(showLots) {
    setState(() {
      _showLots = showLots;
    });
  }

  Future<bool> _updateShowLots(bool showLots) async {
    bool ret = false;

    showLoaderDialog(context);
    await _userApi.updateShowLots(showLots).then((resp) async {
      // set the return value as true
      ret = true;

      // update the user info and the user provider so it will affect all the listener
      await UserSharedPreferences.setUserInfo(resp);

      // update the provider to notify the user page
      if (!mounted) return;
      Provider.of<UserProvider>(context, listen: false).setUserLoginInfo(resp);
      Provider.of<UserProvider>(context, listen: false).setShowLots(visibility: showLots);

      // remove the loader
      Navigator.pop(context);
    }).onError((error, stackTrace) {
      if (mounted) {
        // remove the loader
        Navigator.pop(context);
      }

      // throw the exception
      throw Exception(error.toString());
    });

    return ret;
  }

  void setShowEmptywatchlist(showEmptyWatchlist) {
    setState(() {
      _showEmptyWatchlist = showEmptyWatchlist;
    });
  }

  Future<bool> _updateShowEmptyWatchlist(bool showEmptyWatchlist) async {
    bool ret = false;

    showLoaderDialog(context);
    await _userApi.updateShowEmptyWatchlist(showEmptyWatchlist).then((resp) async {
      // set the return value as true
      ret = true;

      // update the user info and the user provider so it will affect all the listener
      await UserSharedPreferences.setUserInfo(resp);

      // update the provider to notify the user page
      if (!mounted) return;
      Provider.of<UserProvider>(context, listen: false).setUserLoginInfo(resp);
      Provider.of<UserProvider>(context, listen: false).setShowEmptyWatchlists(visibility: showEmptyWatchlist);

      // remove the loader
      Navigator.pop(context);
    }).onError((error, stackTrace) {
      if (mounted) {
        // remove the loader
        Navigator.pop(context);
      }

      // throw the exception
      throw Exception(error.toString());
    });

    return ret;
  }

  void _showScaffoldMessage({required String text}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(createSnackBar(message: text));
    }
  }
}