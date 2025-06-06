import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';
import 'package:my_wealth/_index.g.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final UserAPI _userApi = UserAPI();
  final ScrollController _scrollController = ScrollController();
  
  late UserLoginInfoModel? _userInfo;
  late String _type;
  bool _isVisible = false;
  bool _showLots = false;
  bool _showEmptyWatchlist = true;
  
  @override
  void initState() {
    super.initState();

    var (type, _) = Globals.runAs();
    _type = type;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
      body: MySafeArea(
        child: Consumer<UserProvider>(
          builder: (context, userProvider, child) {
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
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          UserButton(
                            icon: Ionicons.lock_open_outline,
                            text: "Change Password",
                            onTap: (() {
                              Navigator.pushNamed(context, '/user/password');
                            }),
                          ),
                          UserButton(
                            icon: Ionicons.warning_outline,
                            text: "Risk Factor (Current: ${_userInfo!.risk}%)",
                            onTap: (() {
                              Navigator.pushNamed(context, '/user/risk');
                            }),
                          ),
                          UserButton(
                            icon: Ionicons.eye_outline,
                            text: "Visibility",
                            trailing: CupertinoSwitch(
                              value: _isVisible,
                              activeTrackColor: secondaryColor,
                              onChanged: ((value) async {
                                _isVisible = !_isVisible;
                                await _updateVisibilitySummary(_isVisible).then((resp) {
                                  Log.success(message: "🔃 Update Visibility to $_isVisible");
                                  _setSummaryVisible(_isVisible);
                                }).onError((error, stackTrace) {
                                  _showScaffoldMessage(text: error.toString());
                                });
                              }),
                            ),
                          ),
                          UserButton(
                            icon: Ionicons.list_outline,
                            text: "Show Lots",
                            trailing: CupertinoSwitch(
                              value: _showLots,
                              activeTrackColor: secondaryColor,
                              onChanged: ((value) async {
                                _showLots = !_showLots;
                                await _updateShowLots(_showLots).then((resp) {
                                  Log.success(message: "🔃 Update Show Lots to $_showLots");
                                  _setShowLots(_showLots);
                                }).onError((error, stackTrace) {
                                  _showScaffoldMessage(text: error.toString());
                                });
                              }),
                            ),
                          ),
                          UserButton(
                            icon: Ionicons.list_outline,
                            text: "Show Empty Watchlist",
                            trailing: CupertinoSwitch(
                              value: _showEmptyWatchlist,
                              activeTrackColor: secondaryColor,
                              onChanged: ((value) async {
                                _showEmptyWatchlist = !_showEmptyWatchlist;
                                await _updateShowEmptyWatchlist(_showEmptyWatchlist).then((resp) {
                                  Log.success(message: "🔃 Update Show Empty Watchlist to $_showEmptyWatchlist");
                                  _setShowEmptywatchlist(_showEmptyWatchlist);
                                }).onError((error, stackTrace) {
                                  _showScaffoldMessage(text: error.toString());
                                });
                              }),
                            ),
                          ),
                          UserButton(
                            icon: Ionicons.information_outline,
                            text: "Application Version",
                            subText: Globals.appVersion,
                          ),
                          UserButton(
                            icon: Ionicons.rocket_outline,
                            text: "Run As",
                            subText: _type,
                          ),
                          UserButton(
                            icon: Ionicons.information_outline,
                            text: "Flutter Version",
                            subText: Globals.flutterVersion,
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
                          UserButton(
                            icon: Ionicons.log_out_outline,
                            text: "Logout",
                            onTap: (() {
                              Future<bool?> result = ShowMyDialog(
                                title: "Logout",
                                text: "Do you want to logout?",
                              ).show(context);
                                        
                              result.then((value) async {
                                if(value == true) {
                                  await LocalBox.clear().then((_) {
                                    Log.success(message: "🧹 Cleaning Local Storage");
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
                          ),  
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _setSummaryVisible(bool visibilility) {
    setState(() {
      _isVisible = visibilility;
    });
  }

  Future<bool> _updateVisibilitySummary(bool visibility) async {
    bool ret = false;

    // show loading screen
    LoadingScreen.instance().show(context: context);

    // update user summary visibility configuration
    await _userApi.updateVisibilitySummary(
      visibility: visibility
    ).then((resp) async {
      // set the return value as true
      ret = true;

      // update the user info and the user provider so it will affect all the listener
      await UserSharedPreferences.setUserInfo(userInfo: resp);

      // update the provider to notify the user page
      if (mounted) {
        Provider.of<UserProvider>(context, listen: false).setUserLoginInfo(user: resp);
        Provider.of<UserProvider>(context, listen: false).setSummaryVisibility(visibility: visibility);
      }
    }).onError((error, stackTrace) {
      // throw the exception
      throw Exception(error.toString());
    }).whenComplete(() {
      // remove loading screen once finished
      LoadingScreen.instance().hide();
    },);

    return ret;
  }

  void _setShowLots(bool showLots) {
    setState(() {
      _showLots = showLots;
    });
  }

  Future<bool> _updateShowLots(bool showLots) async {
    bool ret = false;

    // show loading screen
    LoadingScreen.instance().show(context: context);

    // update user show lots configuration
    await _userApi.updateShowLots(showLots: showLots).then((resp) async {
      // set the return value as true
      ret = true;

      // update the user info and the user provider so it will affect all the listener
      await UserSharedPreferences.setUserInfo(userInfo: resp);

      // update the provider to notify the user page
      if (mounted) {        
        Provider.of<UserProvider>(context, listen: false).setUserLoginInfo(user: resp);
        Provider.of<UserProvider>(context, listen: false).setShowLots(visibility: showLots);
      }
    }).onError((error, stackTrace) {
      // throw the exception
      throw Exception(error.toString());
    }).whenComplete(() {
      // remove loading screen once finisged
      LoadingScreen.instance().hide();
    },);

    return ret;
  }

  void _setShowEmptywatchlist(bool showEmptyWatchlist) {
    setState(() {
      _showEmptyWatchlist = showEmptyWatchlist;
    });
  }

  Future<bool> _updateShowEmptyWatchlist(bool showEmptyWatchlist) async {
    bool ret = false;

    // show loading screen
    LoadingScreen.instance().show(context: context);

    // update user show empty watchlish configuration
    await _userApi.updateShowEmptyWatchlist(
      showEmptyWatchlist: showEmptyWatchlist
    ).then((resp) async {
      // set the return value as true
      ret = true;

      // update the user info and the user provider so it will affect all the listener
      await UserSharedPreferences.setUserInfo(userInfo: resp);

      // update the provider to notify the user page
      if (mounted) {
        Provider.of<UserProvider>(context, listen: false).setUserLoginInfo(user: resp);
        Provider.of<UserProvider>(context, listen: false).setShowEmptyWatchlists(visibility: showEmptyWatchlist);
      }
    }).onError((error, stackTrace) {
      // throw the exception
      throw Exception(error.toString());
    }).whenComplete(() {
      // remove loading screen when finished
      LoadingScreen.instance().hide();
    },);

    return ret;
  }

  void _showScaffoldMessage({required String text}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(createSnackBar(message: text));
    }
  }
}