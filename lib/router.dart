import 'package:flutter/material.dart';
import 'package:my_wealth/pages/company/company_detail_crypto.dart';
import 'package:my_wealth/pages/company/company_detail_reksadana.dart';
import 'package:my_wealth/pages/company/company_detail_saham.dart';
import 'package:my_wealth/pages/favourites/favourite_company_list_crypto.dart';
import 'package:my_wealth/pages/favourites/favourite_company_list_reksadana.dart';
import 'package:my_wealth/pages/favourites/favourite_company_list_saham.dart';
import 'package:my_wealth/pages/home.dart';
import 'package:my_wealth/pages/index/index_detail.dart';
import 'package:my_wealth/pages/login.dart';
import 'package:my_wealth/pages/users/change_password.dart';
import 'package:my_wealth/pages/users/update_risk.dart';
import 'package:my_wealth/pages/watchlist_detail/watchlist_detail_create.dart';
import 'package:my_wealth/pages/watchlist_detail/watchlist_detail_edit.dart';
import 'package:my_wealth/pages/watchlist_detail/watchlist_detail_sell.dart';
import 'package:my_wealth/pages/watchlists/watchlist_add.dart';
import 'package:my_wealth/pages/watchlists/watchlist_list.dart';
import 'package:my_wealth/provider/favourites_provider.dart';
import 'package:my_wealth/provider/index_provider.dart';
import 'package:my_wealth/provider/user_provider.dart';
import 'package:my_wealth/provider/watchlist_provider.dart';
import 'package:my_wealth/themes/colors.dart';
import 'package:my_wealth/themes/theme.dart';
import 'package:my_wealth/utils/animation/page_transition.dart';
import 'package:my_wealth/utils/prefs/shared_user.dart';
import 'package:provider/provider.dart';

class RouterPage extends StatefulWidget {
  const RouterPage({ Key? key }) : super(key: key);

  @override
  RouterPageState createState() => RouterPageState();
}

class RouterPageState extends State<RouterPage> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<UserProvider>(create: (context) => UserProvider()),
        ChangeNotifierProvider<FavouritesProvider>(create: (context) => FavouritesProvider()),
        ChangeNotifierProvider<WatchlistProvider>(create: (context) => WatchlistProvider()),
        ChangeNotifierProvider<IndexProvider>(create: (context) => IndexProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "My Wealth",
        theme: themeData.copyWith(
          colorScheme: themeData.colorScheme.copyWith(
            secondary: secondaryColor,
          ),
        ),
        initialRoute: '/',
        onGenerateRoute: ((RouteSettings settings) {
          return _switchRoute(settings);
        }),
      ),
    );
  }

  bool _isUserLogin() {
    // get bearer token from User Shared Preferences
    String bearerToken = UserSharedPreferences.getUserJWT();

    // check if string is empty or not?
    if(bearerToken.isNotEmpty) {
      return true;
    }
    return false;
  }

  Route<dynamic>? _switchRoute(RouteSettings settings) {
    // get the route name
    String routeName = (settings.name ?? '/');
    routeName = routeName.toLowerCase();
    
    // check if user try to access route other than "/" and "/login";
    if ((routeName != "/" || routeName != "/login") && (!_isUserLogin())) {
      // force the route to be "/"
      routeName = "/";
    }

    // check which route that user need to go
    switch(routeName) {
      case '/login':
      case '/':
      {
        return MaterialPageRoute(builder: (context) => const LoginPage());
      }
      case '/home':
      {
        return MaterialPageRoute(builder: (context) => const HomePage());
      }
      case '/user/risk':
      {
        return createAnimationRoute(const UpdateRiskPage());
      }
      case '/user/password':
      {
        return createAnimationRoute(const ChangePasswordPage());
      }
      case '/index/detail':
      {
        return createAnimationRoute(IndexDetailPage(index: settings.arguments,));
      }
      case '/favourites/list/reksadana':
      {
        return createAnimationRoute(const FavouriteCompanyListReksadanaPage());
      }
      case '/favourites/list/saham':
      {
        return createAnimationRoute(const FavouriteCompanyListSahamPage());
      }
      case '/favourites/list/crypto':
      {
        return createAnimationRoute(const FavouriteCompanyListCryptoPage());
      }
      case '/company/detail/reksadana':
      {
        return createAnimationRoute(CompanyDetailReksadanaPage(companyData: settings.arguments,));
      }
      case '/company/detail/saham':
      {
        return createAnimationRoute(CompanyDetailSahamPage(companyData: settings.arguments,));
      }
      case '/company/detail/crypto':
      {
        return createAnimationRoute(CompanyDetailCryptoPage(companyData: settings.arguments,));
      }
      case '/watchlist/add':
      {
        return createAnimationRoute(WatchlistAddPage(watchlistArgs: settings.arguments,));
      }
      case '/watchlist/list':
      {
        return createAnimationRoute(WatchlistListPage(watchlistArgs: settings.arguments,));
      }
      case '/watchlist/detail/buy':
      {
        return createAnimationRoute(WatchlistDetailBuyPage(watchlistArgs: settings.arguments,));
      }
      case '/watchlist/detail/sell':
      {
        return createAnimationRoute(WatchlistDetailSellPage(watchlistArgs: settings.arguments,));
      }
      case '/watchlist/detail/edit':
      {
        return createAnimationRoute(WatchlistDetailEditPage(watchlistArgs: settings.arguments,));
      }
      default:
      {
        return MaterialPageRoute(builder: (context) => const LoginPage());
      }
    }
  }
}