import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:ionicons/ionicons.dart';
import 'package:my_wealth/api/favourites_api.dart';
import 'package:my_wealth/api/index_api.dart';
import 'package:my_wealth/api/user_api.dart';
import 'package:my_wealth/api/watchlist_api.dart';
import 'package:my_wealth/provider/favourites_provider.dart';
import 'package:my_wealth/provider/index_provider.dart';
import 'package:my_wealth/provider/user_provider.dart';
import 'package:my_wealth/provider/watchlist_provider.dart';
import 'package:my_wealth/utils/dialog/create_snack_bar.dart';
import 'package:my_wealth/utils/globals.dart';
import 'package:my_wealth/utils/loader/show_loader_dialog.dart';
import 'package:my_wealth/utils/prefs/shared_favourites.dart';
import 'package:my_wealth/utils/prefs/shared_index.dart';
import 'package:my_wealth/utils/prefs/shared_user.dart';
import 'package:my_wealth/themes/colors.dart';
import 'package:my_wealth/utils/prefs/shared_watchlist.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({ Key? key }) : super(key: key);

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final FocusNode _usernameFocus = FocusNode();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _passwordFocus = FocusNode();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final UserAPI _userAPI = UserAPI();
  final FavouritesAPI _faveAPI = FavouritesAPI();
  final WatchlistAPI _watchlistApi = WatchlistAPI();
  final IndexAPI _indexApi = IndexAPI();
  
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    // once all page already loaded, then we can try to perform check login
    Future.microtask(() async {
      _checkLogin().then((isLogin) async {
        if(isLogin) {
          debugPrint("🔓 Already login");
          await _getAdditionalInfo().then((_) {
            // once finished get the additional information route this to home
            debugPrint("🏠 Redirect to home");
            Navigator.restorablePushNamedAndRemoveUntil(context, "/home", (_) => false);
          });
        }
        else {
          debugPrint("🔐 Not yet login");
          _setIsLoading(false);
        }
      });
    });
  }

  @override
  void dispose() {
    _usernameFocus.dispose();
    _usernameController.dispose();
    _passwordFocus.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _generateBody(),
    );
  }

  Widget _generateBody() {
    if (_isLoading) {
      return _splashScreen();
    }
    return _loginScreen();
  }

  Widget _splashScreen() {
    return Center(
      child: Container(
        color: primaryColor,
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SpinKitCubeGrid(
              color: secondaryColor,
            ),
            const SizedBox(
              height: 25,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: const <Widget>[
                Text(
                  "my",
                  style: TextStyle(
                    color: secondaryColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Wealth",
                  style: TextStyle(
                    color: secondaryLight,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Text(
              Globals.appVersion,
              style: const TextStyle(
                color: textPrimary,
                fontSize: 10,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _loginScreen() {
    final mq = MediaQueryData.fromWindow(window);
    final double height = mq.size.height;
    
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Container(
        color: Colors.transparent,
        width: double.infinity,
        height: height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: const <Widget>[
                Text(
                  "my",
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: secondaryColor,
                  ),
                ),
                Text(
                  "Wealth",
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: secondaryLight,
                  ),
                ),
              ],
            ),
            Form(
              key: _formKey,
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.all(15),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: primaryDark,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      "username",
                      style: TextStyle(
                        color: secondaryLight,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5,),
                    TextFormField(
                      controller: _usernameController,
                      focusNode: _usernameFocus,
                      validator: ((val) {
                        if (val!.isNotEmpty) {
                          return null;
                        }
                        else {
                          return "Please enter username";
                        }
                      }),
                      onTap: (() {
                        setState(() {
                          FocusScope.of(context).requestFocus(_usernameFocus);
                        });
                      }),
                      decoration: InputDecoration(
                        hintText: "username",
                        prefixIcon: Icon(
                          Ionicons.person,
                          color: (_usernameFocus.hasFocus ? secondaryColor : textPrimary),
                        ),
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: textPrimary,
                            width: 1.0,
                          ),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: secondaryLight,
                            width: 1.0,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15,),
                    const Text(
                      "password",
                      style: TextStyle(
                        color: secondaryLight,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5,),
                    TextFormField(
                      controller: _passwordController,
                      focusNode: _passwordFocus,
                      obscureText: true,
                      validator: ((val) {
                        if (val!.isNotEmpty) {
                          if (val.length < 6) {
                            return "Password length cannot be less than 6";
                          }
                          return null;
                        }
                        else {
                          return "Please enter password";
                        }
                      }),
                      onTap: (() {
                        setState(() {
                          FocusScope.of(context).requestFocus(_passwordFocus);
                        });
                      }),
                      decoration: InputDecoration(
                        hintText: "password",
                        prefixIcon: Icon(
                          Ionicons.key,
                          color: (_passwordFocus.hasFocus ? secondaryColor : textPrimary),
                        ),
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: textPrimary,
                            width: 1.0,
                          ),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: secondaryLight,
                            width: 1.0,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15,),
                    MaterialButton(
                      height: 50,
                      onPressed: (() {
                        if (_formKey.currentState!.validate()) {
                          showLoaderDialog(context);
                          _login(_usernameController.text, _passwordController.text).then((res) async {
                            Navigator.pop(context);
                            if(res) {
                              debugPrint("🏠 Login success, redirect to home");
                              Navigator.restorablePushNamedAndRemoveUntil(context, "/home", (_) => false);
                            }
                            else {
                              debugPrint("⛔ Wrong login information");
                              ScaffoldMessenger.of(context).showSnackBar(
                                createSnackBar(
                                  message: "Invalid identifier or password",
                                )
                              );
                            }
                          });
                        }
                      }),
                      color: secondaryDark,
                      minWidth: double.infinity,
                      child: const Text(
                        "Login",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: Text(
                  "version - ${Globals.appVersion}",
                  style: const TextStyle(
                    color: primaryLight,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _checkLogin() async {
    bool ret = false;

    await _userAPI.me().then((resp) async {
      // check if user confirmed and not blocked
      if(resp.confirmed == true && resp.blocked == false) {
        ret = true;

        // stored this information on the shared preference,
        // in case there are update from user that directly performed
        // on server.
        await UserSharedPreferences.setUserInfo(resp).then((_) {
          // put the user information on the provider
          Provider.of<UserProvider>(context, listen: false).setUserLoginInfo(resp);
          debugPrint("3️⃣ Update user information");
        });
      }
    }).onError((error, stackTrace) {
      debugPrint("⛔ $error");
    });

    // return the result of the check login to the caller
    return ret;
  }

  Future<bool> _login(String username, String password) async {
    bool ret = false;
    debugPrint("🔑 Try to login");
    
    await _userAPI.login(username, password).then((resp) async {
      // login success, check and ensure that user is confirmed and not blocked
      if(resp.user.confirmed == true && resp.user.blocked == false) {
        ret = true;

        // as we already got the model here, we can store the JWT to the secured box here
        await UserSharedPreferences.setUserJWT(resp.jwt).then((_) {
          debugPrint("1️⃣ Set user JWT token");
        });

        // then we can store the user information to the local storage
        await UserSharedPreferences.setUserInfo(resp.user).then((_) {
          // put the user information on the provider
          Provider.of<UserProvider>(context, listen: false).setUserLoginInfo(resp.user);
          debugPrint("2️⃣ Set user information");
        });

        // and we can call all the rest of the API that we also need when user already
        // login.
        await _getAdditionalInfo();
      }
    }).onError((error, stackTrace) {
      // login failed
      debugPrint("🔐 Login failed");
    });

    return ret;
  }

  Future<void> _getAdditionalInfo() async {
    await Future.wait([
      _faveAPI.getFavourites("reksadana").then((resp) async {
        await FavouritesSharedPreferences.setFavouritesList("reksadana", resp);
        if (!mounted) return;
        Provider.of<FavouritesProvider>(context, listen: false).setFavouriteList("reksadana", resp);
        debugPrint("4️⃣ Get user favourites reksadana");
      }),
      _faveAPI.getFavourites("saham").then((resp) async {
        await FavouritesSharedPreferences.setFavouritesList("saham", resp);
        if (!mounted) return;
        Provider.of<FavouritesProvider>(context, listen: false).setFavouriteList("saham", resp);
        debugPrint("4️⃣ Get user favourites saham");
      }),
      _faveAPI.getFavourites("crypto").then((resp) async {
        await FavouritesSharedPreferences.setFavouritesList("crypto", resp);
        if (!mounted) return;
        Provider.of<FavouritesProvider>(context, listen: false).setFavouriteList("crypto", resp);
        debugPrint("4️⃣ Get user favourites crypto");
      }),
      _watchlistApi.getWatchlist("reksadana").then((resp) async {
        await WatchlistSharedPreferences.setWatchlist("reksadana", resp);
        if (!mounted) return;
        Provider.of<WatchlistProvider>(context, listen: false).setWatchlist("reksadana", resp);
        debugPrint("5️⃣ Get user watchlist reksadana");
      }),
      _watchlistApi.getWatchlist("saham").then((resp) async {
        await WatchlistSharedPreferences.setWatchlist("saham", resp);
        if (!mounted) return;
        Provider.of<WatchlistProvider>(context, listen: false).setWatchlist("saham", resp);
        debugPrint("5️⃣ Get user watchlist saham");
      }),
      _watchlistApi.getWatchlist("crypto").then((resp) async {
        await WatchlistSharedPreferences.setWatchlist("crypto", resp);
        if (!mounted) return;
        Provider.of<WatchlistProvider>(context, listen: false).setWatchlist("crypto", resp);
        debugPrint("5️⃣ Get user watchlist crypto");
      }),
      _watchlistApi.getWatchlist("gold").then((resp) async {
        await WatchlistSharedPreferences.setWatchlist("gold", resp);
        if (!mounted) return;
        Provider.of<WatchlistProvider>(context, listen: false).setWatchlist("gold", resp);
        debugPrint("5️⃣ Get user watchlist gold");
      }),
      _indexApi.getIndex().then((resp) async {
        await IndexSharedPreferences.setIndexList(resp);
        if (!mounted) return;
        Provider.of<IndexProvider>(context, listen: false).setIndexList(resp);
        debugPrint("6️⃣ Get index");
      }),
    ]).then((_) {
      debugPrint("💯 Finished get additional information");
    });
  }

  void _setIsLoading(bool isLoading) {
    setState(() {
      _isLoading = isLoading;
    });
  }
}