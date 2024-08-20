import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';
import 'package:my_wealth/_index.g.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({ super.key });

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
  final BrokerAPI _brokerApi = BrokerAPI();
  final BrokerSummaryAPI _brokerSummaryApi = BrokerSummaryAPI();
  final InsightAPI _insightAPI = InsightAPI();
  final CompanyAPI _companyAPI = CompanyAPI();

  late Future<bool> _getMe;
  late bool _isLogin;
  
  bool _isInvalidToken = false;

  @override
  void initState() {
    super.initState();

    // check if user already login
    _isLogin = false;
    _getMe = _checkIfLogin();
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
      body: MySafeArea(
        child: FutureBuilder(
          future: _getMe,
          builder: ((context, snapshot) {
            if ((snapshot.hasData || snapshot.hasError) && !_isLogin) {
              // check if user is login or not?
              return _generateBody();
            }
            else {
              // show loading
              return _splashScreen();
            }
          }),
        ),
      ),
    );
  }

  Widget _generateBody() {
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
              children: <Widget>[
                const Text(
                  "my",
                  style: TextStyle(
                    color: secondaryColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ).animate().fade(duration: const Duration(milliseconds: 1000)).slideY(),
                const Text(
                  "Wealth",
                  style: TextStyle(
                    color: secondaryLight,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ).animate().fade(duration: const Duration(milliseconds: 1000)).slideY(),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
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
                        onPressed: (() async {
                          if (_formKey.currentState!.validate()) {
                            await _login(_usernameController.text, _passwordController.text).then((res) async {
                              if (mounted) {
                                // check whether user is able to login or not?
                                if(res) {
                                  Log.success(message: "🏠 Login success, redirect to home");
                                  Navigator.restorablePushNamedAndRemoveUntil(context, "/home", (_) => false);
                                }
                                else {
                                  Log.error(message: "⛔ Wrong login information");
                                }
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
        )
      ],
    );
  }

  Future<bool> _checkLogin() async {
    bool ret = false;
    String currJwtToken = UserSharedPreferences.getUserJWT();

    try {
      await _userAPI.me().then((resp) async {
        // check if user confirmed and not blocked
        if(resp.confirmed == true && resp.blocked == false) {
          ret = true;

          // stored this information on the shared preference,
          // in case there are update from user that directly performed
          // on server.
          await UserSharedPreferences.setUserInfo(resp).then((_) {
            if (mounted) {
              // put the user information on the provider
              Provider.of<UserProvider>(context, listen: false).setUserLoginInfo(resp);
              Log.success(message: "3️⃣ Update user information");

              // set the current visibility configuration on the provider
              Provider.of<UserProvider>(context, listen: false).setSummaryVisibility(visibility: resp.visibility);
              Provider.of<UserProvider>(context, listen: false).setShowLots(visibility: resp.showLots);
              Provider.of<UserProvider>(context, listen: false).setShowEmptyWatchlists(visibility: resp.showEmptyWatchlist);
            }
          });
        }
      });
    }
    on NetException catch (error, _) {
      Log.error(message: "⛔ ${error.message}");

      // check if this is rejection from server
      if(error.code != 200) {
        // check if we have jwt token or not?
        if (currJwtToken.isNotEmpty) {
          // if already got token but unable to login, it means that the token already invalid
          _isInvalidToken = true;
          
          // since we knew that this is invalid token, then just clear the JWT
          // otherwise it will causing the login to be invalid as we still have
          // the invalid JWT token in the NetUtils
          NetUtils.clearJWT();

          // show invalid token message on the login screen
          _showScaffoldMessage(text: "Token expired, please re-login");
        }
      }
    }
    on ClientException catch (error, stackTrace) {
      Log.error(
        message: "⛔ Client exception with error ${error.message}",
        error: error,
        stackTrace: stackTrace,
      );

      // show no connection to API
      _showScaffoldMessage(text: "Unable to connect to server");
    }
    catch (error, stackTrace) {
      Log.error(
        message: "⛔ Generic error ${error.toString()}",
        error: error,
        stackTrace: stackTrace,
      );

      // show generic error on application
      _showScaffoldMessage(text: "Error processing on applicatoin");
    }

    // return the result of the check login to the caller
    return ret;
  }

  Future<bool> _login(String username, String password) async {
    bool ret = false;
    Log.info(message: "🔑 Try to login");
    
    // show the loading screen
    LoadingScreen.instance().show(context: context);

    // check user credentials
    try {
      await _userAPI.login(username, password).then((resp) async {
        // login success, check and ensure that user is confirmed and not blocked
        if(resp.user.confirmed == true && resp.user.blocked == false) {
          ret = true;

          // clear the local box as we will refresh everything when we perform check login
          await LocalBox.clear().then((_) {
            Log.success(message: "🧹 Cleaning local storage before login");
          });

          // as we already got the model here, we can store the JWT to the secured box here
          await UserSharedPreferences.setUserJWT(resp.jwt).then((_) {
            Log.success(message: "1️⃣ Set user JWT token");
          });

          // refresh JWT token on the NetUtils after login
          NetUtils.refreshJWT();

          // then we can store the user information to the local storage
          await UserSharedPreferences.setUserInfo(resp.user).then((_) {
            if (mounted) {
              // put the user information on the provider
              Provider.of<UserProvider>(context, listen: false).setUserLoginInfo(resp.user);
              Log.success(message: "2️⃣ Set user information");
            }
          });
        }
      });
    }
    on NetException catch (error, _) {
      // login failed
      Log.error(message: "🔐 Login failed");
      _showScaffoldMessage(text: "Invalid identifier or password");
    }
    on ClientException catch (error, _) {
      Log.error(message: "🌏 No Internet Connection");
      _showScaffoldMessage(text: "Unable to connect to API");
    }
    catch (error, stackTrace) {
      // generic error
      Log.error(
        message: "⛔ Generic error ${error.toString()}",
        error: error,
        stackTrace: stackTrace,
      );

      // show generic error on application
      _showScaffoldMessage(text: "Error processing on applicatoin");
    }

    // and we can call all the rest of the API that we also need when user already
    // login.
    await _getAdditionalInfo().onError((error, stackTrace) {
      // set the return into false
      ret = false;

      // print error on the console
      Log.error(
        message: "ℹ️ Unable to get additional information",
        error: error,
        stackTrace: stackTrace,
      );

      // show the error on the scaffold
      _showScaffoldMessage(text: "Unable to get additional info");
    },);

    // remove the loading screen
    LoadingScreen.instance().hide();

    return ret;
  }

  Future<void> _getAdditionalInfo() async {
    // check whether this is due to invalid token?
    // if so then we need to refresh the JWT being used
    if (_isInvalidToken) {
      // refresh the netutils JWT token
      NetUtils.refreshJWT();
    }
    
    await Future.wait([
      _faveAPI.getFavourites("reksadana").then((resp) async {
        await FavouritesSharedPreferences.setFavouritesList("reksadana", resp);
        if (!mounted) return;
        Provider.of<FavouritesProvider>(context, listen: false).setFavouriteList("reksadana", resp);
        Log.success(message: "4️⃣ Get user favourites reksadana");
      }),
      _faveAPI.getFavourites("saham").then((resp) async {
        await FavouritesSharedPreferences.setFavouritesList("saham", resp);
        if (!mounted) return;
        Provider.of<FavouritesProvider>(context, listen: false).setFavouriteList("saham", resp);
        Log.success(message: "5️⃣ Get user favourites saham");
      }),
      _faveAPI.getFavourites("crypto").then((resp) async {
        await FavouritesSharedPreferences.setFavouritesList("crypto", resp);
        if (!mounted) return;
        Provider.of<FavouritesProvider>(context, listen: false).setFavouriteList("crypto", resp);
        Log.success(message: "6️⃣ Get user favourites crypto");
      }),
      _watchlistApi.getWatchlist("reksadana").then((resp) async {
        await WatchlistSharedPreferences.setWatchlist("reksadana", resp);
        if (!mounted) return;
        Provider.of<WatchlistProvider>(context, listen: false).setWatchlist("reksadana", resp);
        Log.success(message: "7️⃣ Get user watchlist reksadana");
      }),
      _watchlistApi.getWatchlist("saham").then((resp) async {
        await WatchlistSharedPreferences.setWatchlist("saham", resp);
        if (!mounted) return;
        Provider.of<WatchlistProvider>(context, listen: false).setWatchlist("saham", resp);
        Log.success(message: "8️⃣ Get user watchlist saham");
      }),
      _watchlistApi.getWatchlist("crypto").then((resp) async {
        await WatchlistSharedPreferences.setWatchlist("crypto", resp);
        if (!mounted) return;
        Provider.of<WatchlistProvider>(context, listen: false).setWatchlist("crypto", resp);
        Log.success(message: "9️⃣ Get user watchlist crypto");
      }),
      _watchlistApi.getWatchlist("gold").then((resp) async {
        await WatchlistSharedPreferences.setWatchlist("gold", resp);
        if (!mounted) return;
        Provider.of<WatchlistProvider>(context, listen: false).setWatchlist("gold", resp);
        Log.success(message: "1️⃣0️⃣ Get user watchlist gold");
      }),
      _indexApi.getIndex().then((resp) async {
        await IndexSharedPreferences.setIndexList(resp);
        if (!mounted) return;
        Provider.of<IndexProvider>(context, listen: false).setIndexList(resp);
        Log.success(message: "🔟1️⃣ Get index");
      }),
      _brokerApi.getBroker().then((resp) async {
        await BrokerSharedPreferences.setBrokerList(resp);
        if (!mounted) return;
        Provider.of<BrokerProvider>(context, listen: false).setBrokerList(resp);
        Log.success(message: '🔟2️⃣ Get Broker');
      }),
      _brokerSummaryApi.getBrokerSummaryTop().then((resp) async {
        await BrokerSharedPreferences.setBroketTopList(resp);
        if (!mounted) return;
        Provider.of<BrokerProvider>(context, listen: false).setBrokerTopList(resp);
        Log.success(message: '🔟3️⃣ Get Broker Top List');
      }),
      _insightAPI.getBrokerTopTransaction().then((resp) async {
        await InsightSharedPreferences.setBrokerTopTxn(resp);
        if (!mounted) return;
        Provider.of<InsightProvider>(context, listen: false).setBrokerTopTransactionList(resp);
        Log.success(message: '🔟4️⃣ Get Broker Top Transaction List');
      }),
      _insightAPI.getMarketToday().then((resp) async {
        await InsightSharedPreferences.setBrokerMarketToday(resp);
        if (!mounted) return;
        Provider.of<InsightProvider>(context, listen: false).setBrokerMarketToday(resp);
        Log.success(message: '🔟5️⃣ Get Broker Market Today');
      }),
      _insightAPI.getMarketCap().then((resp) async {
        await InsightSharedPreferences.setMarketCap(resp);
        if (!mounted) return;
        Provider.of<InsightProvider>(context, listen: false).setMarketCap(resp);
        Log.success(message: '🔟6️⃣ Get Broker Market Cap');
      }),
      _insightAPI.getSectorSummary().then((resp) async {
        await InsightSharedPreferences.setSectorSummaryList(resp);
        if (!mounted) return;
        Provider.of<InsightProvider>(context, listen: false).setSectorSummaryList(resp);
        Log.success(message: '🔟7️⃣ Get Sector Summary List');
      }),
      _insightAPI.getTopWorseCompany('top').then((resp) async {
        await InsightSharedPreferences.setTopWorseCompanyList('top', resp);
        if (!mounted) return;
        Provider.of<InsightProvider>(context, listen: false).setTopWorseCompanyList('top', resp);
        Log.success(message: '🔟8️⃣ Get Top Company Summary List');
      }),
      _insightAPI.getTopWorseCompany('worse').then((resp) async {
        await InsightSharedPreferences.setTopWorseCompanyList('worse', resp);
        if (!mounted) return;
        Provider.of<InsightProvider>(context, listen: false).setTopWorseCompanyList('worse', resp);
        Log.success(message: '🔟9️⃣ Get Worse Company Summary List');
      }),
      _insightAPI.getTopWorseReksadana('saham', 'top').then((resp) async {
        await InsightSharedPreferences.setTopReksadanaList('saham', resp);
        if (!mounted) return;
        Provider.of<InsightProvider>(context, listen: false).setTopReksadanaList('saham', resp);
        Log.success(message: '🔟🔟1️⃣ Get Top Reksadana Saham Summary List');
      }),
      _insightAPI.getTopWorseReksadana('campuran', 'top').then((resp) async {
        await InsightSharedPreferences.setTopReksadanaList('campuran', resp);
        if (!mounted) return;
        Provider.of<InsightProvider>(context, listen: false).setTopReksadanaList('campuran', resp);
        Log.success(message: '🔟🔟2️⃣ Get Top Reksadana Campuran Summary List');
      }),
      _insightAPI.getTopWorseReksadana('pasaruang', 'top').then((resp) async {
        await InsightSharedPreferences.setTopReksadanaList('pasaruang', resp);
        if (!mounted) return;
        Provider.of<InsightProvider>(context, listen: false).setTopReksadanaList('pasaruang', resp);
        Log.success(message: '🔟🔟3️⃣ Get Top Reksadana Pasar Uang Summary List');
      }),
      _insightAPI.getTopWorseReksadana('pendapatantetap', 'top').then((resp) async {
        await InsightSharedPreferences.setTopReksadanaList('pendapatantetap', resp);
        if (!mounted) return;
        Provider.of<InsightProvider>(context, listen: false).setTopReksadanaList('pendapatantetap', resp);
        Log.success(message: '🔟🔟4️⃣ Get Top Reksadana Pendapatan Tetap Summary List');
      }),
      _insightAPI.getTopWorseReksadana('saham', 'loser').then((resp) async {
        await InsightSharedPreferences.setWorseReksadanaList('saham', resp);
        if (!mounted) return;
        Provider.of<InsightProvider>(context, listen: false).setWorseReksadanaList('saham', resp);
        Log.success(message: '🔟🔟5️⃣ Get Top Reksadana Saham Summary List');
      }),
      _insightAPI.getTopWorseReksadana('campuran', 'loser').then((resp) async {
        await InsightSharedPreferences.setWorseReksadanaList('campuran', resp);
        if (!mounted) return;
        Provider.of<InsightProvider>(context, listen: false).setWorseReksadanaList('campuran', resp);
        Log.success(message: '🔟🔟6️⃣ Get Top Reksadana Campuran Summary List');
      }),
      _insightAPI.getTopWorseReksadana('pasaruang', 'loser').then((resp) async {
        await InsightSharedPreferences.setWorseReksadanaList('pasaruang', resp);
        if (!mounted) return;
        Provider.of<InsightProvider>(context, listen: false).setWorseReksadanaList('pasaruang', resp);
        Log.success(message: '🔟🔟7️⃣ Get Top Reksadana Pasar Uang Summary List');
      }),
      _insightAPI.getTopWorseReksadana('pendapatantetap', 'loser').then((resp) async {
        await InsightSharedPreferences.setWorseReksadanaList('pendapatantetap', resp);
        if (!mounted) return;
        Provider.of<InsightProvider>(context, listen: false).setWorseReksadanaList('pendapatantetap', resp);
        Log.success(message: '🔟🔟8️⃣ Get Top Reksadana Pendapatan Tetap Summary List');
      }),
      _insightAPI.getBandarInteresting().then((resp) async {
        await InsightSharedPreferences.setBandarInterestingList(resp);
        if (!mounted) return;
        Provider.of<InsightProvider>(context, listen: false).setBandarInterestingList(resp);
        Log.success(message: '🔟🔟9️⃣ Get Bandar Interesting List');
      }),
      _companyAPI.getSectorNameList().then((resp) async {
        await CompanySharedPreferences.setSectorNameList(resp);
        if (!mounted) return;
        Provider.of<CompanyProvider>(context, listen: false).setSectorList(resp);
        Log.success(message: '🔟🔟🔟 Get Saham Sector Name List');
      }),
      _watchlistApi.getWatchlistHistory().then((resp) async {
        await WatchlistSharedPreferences.setWatchlistHistory(resp);
        if (!mounted) return;
        Provider.of<WatchlistProvider>(context, listen: false).setWatchlistHistory(resp);
        Log.success(message: "🔟🔟🔟1️⃣ Get user watchlist history");
      }),
      _insightAPI.getStockNewListed().then((resp) async {
        await InsightSharedPreferences.setStockNewListed(resp);
        if (!mounted) return;
        Provider.of<InsightProvider>(context, listen: false).setStockNewListed(resp);
        Log.success(message: '🔟🔟🔟2️⃣ Get Stock New Listed');
      }),
      _insightAPI.getStockDividendList().then((resp) async {
        await InsightSharedPreferences.setStockDividendList(resp);
        if (!mounted) return;
        Provider.of<InsightProvider>(context, listen: false).setStockDividendList(resp);
        Log.success(message: '🔟🔟🔟3️⃣ Get Stock Dividend List');
      }),
      _insightAPI.getStockSplitList().then((resp) async {
        await InsightSharedPreferences.setStockSplitList(resp);
        if (!mounted) return;
        Provider.of<InsightProvider>(context, listen: false).setStockSplitList(resp);
        Log.success(message: '🔟🔟🔟4️⃣ Get Stock Split List');
      }),
      _brokerSummaryApi.getBrokerSummaryDate().then((resp) async {
        if (!mounted) return;
        await BrokerSharedPreferences.setBrokerMinMaxDate(resp.brokerMinDate, resp.brokerMaxDate);
        Log.success(message: '🔟🔟🔟6️⃣ Get Broker Min and Max Date');
      }),
      
      InsightSharedPreferences.clearTopAccumulation(), // clear the topAccumulation as we will inquiry when user visit the screen
      InsightSharedPreferences.clearEps(), // clear eps result as we will inquiry when user visit the screen
      InsightSharedPreferences.clearSideway(), // clear sideway result as we will inquiry when user visit the screen
      InsightSharedPreferences.clearIndexBeater(), // clear index beater result as we will inquiry when user visit the screen
      InsightSharedPreferences.clearStockCollect(), // clear stock collect result
      InsightSharedPreferences.clearBrokerCollect(), // clear broker collect result
    ]).then((_) {
      Log.success(message: "💯 Finished get additional information");
    });
  }

  Future<bool> _checkIfLogin() async {
    // check whether user already login or not?
    await _checkLogin().then((isLogin) async {
      if(isLogin) {
        Log.info(message: "🔓 Already login");

        // set the _isLogin variable to true
        _isLogin = true;

        // get the additional information for user
        await _getAdditionalInfo().then((_) {
          if (mounted) {
            // once finished get the additional information route this to home
            Log.info(message: "🏠 Redirect to home");
            Navigator.restorablePushNamedAndRemoveUntil(context, "/home", (_) => false);
          }
        }).onError((error, stackTrace) {
          Log.error(
            message: "Error when get additional data",
            error: error,
            stackTrace: stackTrace,
          );
          throw Exception('Error when get the additional data');
        },);
      }
      else {
        Log.info(message: "🔐 Not yet login");
      }
    });

    return true;
  }

  void _showScaffoldMessage({required String text}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(createSnackBar(message: text,));
    }
  }
}