import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:ionicons/ionicons.dart';
import 'package:my_wealth/api/broker_api.dart';
import 'package:my_wealth/api/broker_summary_api.dart';
import 'package:my_wealth/api/company_api.dart';
import 'package:my_wealth/api/favourites_api.dart';
import 'package:my_wealth/api/index_api.dart';
import 'package:my_wealth/api/insight_api.dart';
import 'package:my_wealth/api/user_api.dart';
import 'package:my_wealth/api/watchlist_api.dart';
import 'package:my_wealth/provider/broker_provider.dart';
import 'package:my_wealth/provider/company_provider.dart';
import 'package:my_wealth/provider/favourites_provider.dart';
import 'package:my_wealth/provider/index_provider.dart';
import 'package:my_wealth/provider/inisght_provider.dart';
import 'package:my_wealth/provider/user_provider.dart';
import 'package:my_wealth/provider/watchlist_provider.dart';
import 'package:my_wealth/storage/box/local_box.dart';
import 'package:my_wealth/utils/dialog/create_snack_bar.dart';
import 'package:my_wealth/utils/globals.dart';
import 'package:my_wealth/storage/prefs/shared_broker.dart';
import 'package:my_wealth/storage/prefs/shared_company.dart';
import 'package:my_wealth/storage/prefs/shared_favourites.dart';
import 'package:my_wealth/storage/prefs/shared_index.dart';
import 'package:my_wealth/storage/prefs/shared_insight.dart';
import 'package:my_wealth/storage/prefs/shared_user.dart';
import 'package:my_wealth/themes/colors.dart';
import 'package:my_wealth/storage/prefs/shared_watchlist.dart';
import 'package:my_wealth/utils/net/netutils.dart';
import 'package:my_wealth/widgets/modal/overlay_loading_modal.dart';
import 'package:provider/provider.dart';

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
  
  bool _isLoading = true;
  bool _isInvalidToken = false;

  @override
  void initState() {
    super.initState();

    // once all page already loaded, then we can try to perform check login
    Future.microtask(() async {
      await _checkLogin().then((isLogin) async {
        if(isLogin) {
          debugPrint("🔓 Already login");
          await _getAdditionalInfo().then((_) {
            if (mounted) {
              // once finished get the additional information route this to home
              debugPrint("🏠 Redirect to home");
              Navigator.restorablePushNamedAndRemoveUntil(context, "/home", (_) => false);
            }
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
                                  debugPrint("🏠 Login success, redirect to home");
                                  Navigator.restorablePushNamedAndRemoveUntil(context, "/home", (_) => false);
                                }
                                else {
                                  debugPrint("⛔ Wrong login information");
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
            debugPrint("3️⃣ Update user information");

            // set the current visibility configuration on the provider
            Provider.of<UserProvider>(context, listen: false).setSummaryVisibility(visibility: resp.visibility);
            Provider.of<UserProvider>(context, listen: false).setShowLots(visibility: resp.showLots);
            Provider.of<UserProvider>(context, listen: false).setShowEmptyWatchlists(visibility: resp.showEmptyWatchlist);
          }
        });
      }
    }).onError((NetException error, stackTrace) async {
      debugPrint("⛔ ${error.message}");

      if(error.message.toLowerCase() == "xmlhttprequest error.") {
        // show no connection to API
        _showScaffoldMessage(text: "Unable to connect to API");
      }
      else {
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
    });

    // return the result of the check login to the caller
    return ret;
  }

  Future<bool> _login(String username, String password) async {
    bool ret = false;
    debugPrint("🔑 Try to login");
    
    // show the loading screen
    LoadingScreen.instance().show(context: context);

    // check user credentials
    await _userAPI.login(username, password).then((resp) async {
      // login success, check and ensure that user is confirmed and not blocked
      if(resp.user.confirmed == true && resp.user.blocked == false) {
        ret = true;

        // clear the local box as we will refresh everything when we perform check login
        await LocalBox.clear().then((_) {
          debugPrint("🧹 Cleaning local storage before login");
        });

        // as we already got the model here, we can store the JWT to the secured box here
        await UserSharedPreferences.setUserJWT(resp.jwt).then((_) {
          debugPrint("1️⃣ Set user JWT token");
        });

        // refresh JWT token on the NetUtils after login
        NetUtils.refreshJWT();

        // then we can store the user information to the local storage
        await UserSharedPreferences.setUserInfo(resp.user).then((_) {
          if (mounted) {
            // put the user information on the provider
            Provider.of<UserProvider>(context, listen: false).setUserLoginInfo(resp.user);
            debugPrint("2️⃣ Set user information");
          }
        });

        // and we can call all the rest of the API that we also need when user already
        // login.
        await _getAdditionalInfo();
      }
    }).onError((error, stackTrace) {
      // check if the error message is "XMLHttpRequest error."
      if (error.toString() == "XMLHttpRequest error.") {
        debugPrint("🌏 No Internet Connection");
        _showScaffoldMessage(text: "Unable to connect to API");
      }
      else {
        // login failed
        debugPrint("🔐 Login failed");
        _showScaffoldMessage(text: "Invalid identifier or password");
      }
    });

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
        debugPrint("4️⃣ Get user favourites reksadana");
      }),
      _faveAPI.getFavourites("saham").then((resp) async {
        await FavouritesSharedPreferences.setFavouritesList("saham", resp);
        if (!mounted) return;
        Provider.of<FavouritesProvider>(context, listen: false).setFavouriteList("saham", resp);
        debugPrint("5️⃣ Get user favourites saham");
      }),
      _faveAPI.getFavourites("crypto").then((resp) async {
        await FavouritesSharedPreferences.setFavouritesList("crypto", resp);
        if (!mounted) return;
        Provider.of<FavouritesProvider>(context, listen: false).setFavouriteList("crypto", resp);
        debugPrint("6️⃣ Get user favourites crypto");
      }),
      _watchlistApi.getWatchlist("reksadana").then((resp) async {
        await WatchlistSharedPreferences.setWatchlist("reksadana", resp);
        if (!mounted) return;
        Provider.of<WatchlistProvider>(context, listen: false).setWatchlist("reksadana", resp);
        debugPrint("7️⃣ Get user watchlist reksadana");
      }),
      _watchlistApi.getWatchlist("saham").then((resp) async {
        await WatchlistSharedPreferences.setWatchlist("saham", resp);
        if (!mounted) return;
        Provider.of<WatchlistProvider>(context, listen: false).setWatchlist("saham", resp);
        debugPrint("8️⃣ Get user watchlist saham");
      }),
      _watchlistApi.getWatchlist("crypto").then((resp) async {
        await WatchlistSharedPreferences.setWatchlist("crypto", resp);
        if (!mounted) return;
        Provider.of<WatchlistProvider>(context, listen: false).setWatchlist("crypto", resp);
        debugPrint("9️⃣ Get user watchlist crypto");
      }),
      _watchlistApi.getWatchlist("gold").then((resp) async {
        await WatchlistSharedPreferences.setWatchlist("gold", resp);
        if (!mounted) return;
        Provider.of<WatchlistProvider>(context, listen: false).setWatchlist("gold", resp);
        debugPrint("1️⃣0️⃣ Get user watchlist gold");
      }),
      _indexApi.getIndex().then((resp) async {
        await IndexSharedPreferences.setIndexList(resp);
        if (!mounted) return;
        Provider.of<IndexProvider>(context, listen: false).setIndexList(resp);
        debugPrint("🔟1️⃣ Get index");
      }),
      _brokerApi.getBroker().then((resp) async {
        await BrokerSharedPreferences.setBrokerList(resp);
        if (!mounted) return;
        Provider.of<BrokerProvider>(context, listen: false).setBrokerList(resp);
        debugPrint('🔟2️⃣ Get Broker');
      }),
      _brokerSummaryApi.getBrokerSummaryTop().then((resp) async {
        await BrokerSharedPreferences.setBroketTopList(resp);
        if (!mounted) return;
        Provider.of<BrokerProvider>(context, listen: false).setBrokerTopList(resp);
        debugPrint('🔟3️⃣ Get Broker Top List');
      }),
      _insightAPI.getBrokerTopTransaction().then((resp) async {
        await InsightSharedPreferences.setBrokerTopTxn(resp);
        if (!mounted) return;
        Provider.of<InsightProvider>(context, listen: false).setBrokerTopTransactionList(resp);
        debugPrint('🔟4️⃣ Get Broker Top Transaction List');
      }),
      _insightAPI.getMarketToday().then((resp) async {
        await InsightSharedPreferences.setBrokerMarketToday(resp);
        if (!mounted) return;
        Provider.of<InsightProvider>(context, listen: false).setBrokerMarketToday(resp);
        debugPrint('🔟5️⃣ Get Broker Market Today');
      }),
      _insightAPI.getMarketCap().then((resp) async {
        await InsightSharedPreferences.setMarketCap(resp);
        if (!mounted) return;
        Provider.of<InsightProvider>(context, listen: false).setMarketCap(resp);
        debugPrint('🔟6️⃣ Get Broker Market Cap');
      }),
      _insightAPI.getSectorSummary().then((resp) async {
        await InsightSharedPreferences.setSectorSummaryList(resp);
        if (!mounted) return;
        Provider.of<InsightProvider>(context, listen: false).setSectorSummaryList(resp);
        debugPrint('🔟7️⃣ Get Sector Summary List');
      }),
      _insightAPI.getTopWorseCompany('top').then((resp) async {
        await InsightSharedPreferences.setTopWorseCompanyList('top', resp);
        if (!mounted) return;
        Provider.of<InsightProvider>(context, listen: false).setTopWorseCompanyList('top', resp);
        debugPrint('🔟8️⃣ Get Top Company Summary List');
      }),
      _insightAPI.getTopWorseCompany('worse').then((resp) async {
        await InsightSharedPreferences.setTopWorseCompanyList('worse', resp);
        if (!mounted) return;
        Provider.of<InsightProvider>(context, listen: false).setTopWorseCompanyList('worse', resp);
        debugPrint('🔟9️⃣ Get Worse Company Summary List');
      }),
      _insightAPI.getTopWorseReksadana('saham', 'top').then((resp) async {
        await InsightSharedPreferences.setTopReksadanaList('saham', resp);
        if (!mounted) return;
        Provider.of<InsightProvider>(context, listen: false).setTopReksadanaList('saham', resp);
        debugPrint('🔟🔟1️⃣ Get Top Reksadana Saham Summary List');
      }),
      _insightAPI.getTopWorseReksadana('campuran', 'top').then((resp) async {
        await InsightSharedPreferences.setTopReksadanaList('campuran', resp);
        if (!mounted) return;
        Provider.of<InsightProvider>(context, listen: false).setTopReksadanaList('campuran', resp);
        debugPrint('🔟🔟2️⃣ Get Top Reksadana Campuran Summary List');
      }),
      _insightAPI.getTopWorseReksadana('pasaruang', 'top').then((resp) async {
        await InsightSharedPreferences.setTopReksadanaList('pasaruang', resp);
        if (!mounted) return;
        Provider.of<InsightProvider>(context, listen: false).setTopReksadanaList('pasaruang', resp);
        debugPrint('🔟🔟3️⃣ Get Top Reksadana Pasar Uang Summary List');
      }),
      _insightAPI.getTopWorseReksadana('pendapatantetap', 'top').then((resp) async {
        await InsightSharedPreferences.setTopReksadanaList('pendapatantetap', resp);
        if (!mounted) return;
        Provider.of<InsightProvider>(context, listen: false).setTopReksadanaList('pendapatantetap', resp);
        debugPrint('🔟🔟4️⃣ Get Top Reksadana Pendapatan Tetap Summary List');
      }),
      _insightAPI.getTopWorseReksadana('saham', 'loser').then((resp) async {
        await InsightSharedPreferences.setWorseReksadanaList('saham', resp);
        if (!mounted) return;
        Provider.of<InsightProvider>(context, listen: false).setWorseReksadanaList('saham', resp);
        debugPrint('🔟🔟5️⃣ Get Top Reksadana Saham Summary List');
      }),
      _insightAPI.getTopWorseReksadana('campuran', 'loser').then((resp) async {
        await InsightSharedPreferences.setWorseReksadanaList('campuran', resp);
        if (!mounted) return;
        Provider.of<InsightProvider>(context, listen: false).setWorseReksadanaList('campuran', resp);
        debugPrint('🔟🔟6️⃣ Get Top Reksadana Campuran Summary List');
      }),
      _insightAPI.getTopWorseReksadana('pasaruang', 'loser').then((resp) async {
        await InsightSharedPreferences.setWorseReksadanaList('pasaruang', resp);
        if (!mounted) return;
        Provider.of<InsightProvider>(context, listen: false).setWorseReksadanaList('pasaruang', resp);
        debugPrint('🔟🔟7️⃣ Get Top Reksadana Pasar Uang Summary List');
      }),
      _insightAPI.getTopWorseReksadana('pendapatantetap', 'loser').then((resp) async {
        await InsightSharedPreferences.setWorseReksadanaList('pendapatantetap', resp);
        if (!mounted) return;
        Provider.of<InsightProvider>(context, listen: false).setWorseReksadanaList('pendapatantetap', resp);
        debugPrint('🔟🔟8️⃣ Get Top Reksadana Pendapatan Tetap Summary List');
      }),
      _insightAPI.getBandarInteresting().then((resp) async {
        await InsightSharedPreferences.setBandarInterestingList(resp);
        if (!mounted) return;
        Provider.of<InsightProvider>(context, listen: false).setBandarInterestingList(resp);
        debugPrint('🔟🔟9️⃣ Get Bandar Interesting List');
      }),
      _companyAPI.getSectorNameList().then((resp) async {
        await CompanySharedPreferences.setSectorNameList(resp);
        if (!mounted) return;
        Provider.of<CompanyProvider>(context, listen: false).setSectorList(resp);
        debugPrint('🔟🔟🔟 Get Saham Sector Name List');
      }),
      _watchlistApi.getWatchlistHistory().then((resp) async {
        await WatchlistSharedPreferences.setWatchlistHistory(resp);
        if (!mounted) return;
        Provider.of<WatchlistProvider>(context, listen: false).setWatchlistHistory(resp);
        debugPrint("🔟🔟🔟1️⃣ Get user watchlist history");
      }),
      _insightAPI.getStockNewListed().then((resp) async {
        await InsightSharedPreferences.setStockNewListed(resp);
        if (!mounted) return;
        Provider.of<InsightProvider>(context, listen: false).setStockNewListed(resp);
        debugPrint('🔟🔟🔟2️⃣ Get Stock New Listed');
      }),
      _insightAPI.getStockDividendList().then((resp) async {
        await InsightSharedPreferences.setStockDividendList(resp);
        if (!mounted) return;
        Provider.of<InsightProvider>(context, listen: false).setStockDividendList(resp);
        debugPrint('🔟🔟🔟3️⃣ Get Stock Dividend List');
      }),
      _insightAPI.getStockSplitList().then((resp) async {
        await InsightSharedPreferences.setStockSplitList(resp);
        if (!mounted) return;
        Provider.of<InsightProvider>(context, listen: false).setStockSplitList(resp);
        debugPrint('🔟🔟🔟4️⃣ Get Stock Split List');
      }),
      _brokerSummaryApi.getBrokerSummaryDate().then((resp) async {
        if (!mounted) return;
        await BrokerSharedPreferences.setBrokerMinMaxDate(resp.brokerMinDate, resp.brokerMaxDate);
        debugPrint('🔟🔟🔟6️⃣ Get Broker Min and Max Date');
      }),
      
      InsightSharedPreferences.clearTopAccumulation(), // clear the topAccumulation as we will inquiry when user visit the screen
      InsightSharedPreferences.clearEps(), // clear eps result as we will inquiry when user visit the screen
      InsightSharedPreferences.clearSideway(), // clear sideway result as we will inquiry when user visit the screen
      InsightSharedPreferences.clearIndexBeater(), // clear index beater result as we will inquiry when user visit the screen
      InsightSharedPreferences.clearStockCollect(), // clear stock collect result
      InsightSharedPreferences.clearBrokerCollect(), // clear broker collect result
    ]).then((_) {
      debugPrint("💯 Finished get additional information");
    });
  }

  void _setIsLoading(bool isLoading) {
    setState(() {
      _isLoading = isLoading;
    });
  }

  void _showScaffoldMessage({required String text}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(createSnackBar(message: text,));
    }
  }
}