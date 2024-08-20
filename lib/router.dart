import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_wealth/_index.g.dart';

class RouterPage extends StatefulWidget {
  const RouterPage({ super.key });

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
        ChangeNotifierProvider<BrokerProvider>(create: (context) => BrokerProvider()),
        ChangeNotifierProvider<InsightProvider>(create: (context) => InsightProvider()),
        ChangeNotifierProvider<CompanyProvider>(create: (context) => CompanyProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        scrollBehavior: MyCustomScrollBehavior(),
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
      case '/user':
      {
        return createAnimationRoute(const UserPage());
      }
      case '/user/risk':
      {
        return createAnimationRoute(const UpdateRiskPage());
      }
      case '/user/password':
      {
        return createAnimationRoute(const ChangePasswordPage());
      }
      case '/user/bot':
      {
        return createAnimationRoute(const UpdateBotPage());
      }
      case '/index/detail':
      {
        return createAnimationRoute(IndexDetailPage(index: settings.arguments,));
      }
      case '/index/find':
      {
        return createAnimationRoute(const IndexFindOtherPage());
      }
      case '/favourites/list/reksadana':
      {
        return createAnimationRoute(const SearchCompanyListReksadanaPage());
      }
      case '/favourites/list/saham':
      {
        return createAnimationRoute(const SearchCompanyListSahamPage());
      }
      case '/favourites/list/crypto':
      {
        return createAnimationRoute(const SearchCompanyListCryptoPage());
      }
      case '/company/detail/reksadana':
      {
        return createAnimationRoute(CompanyDetailReksadanaPage(companyData: settings.arguments,));
      }
      case '/company/detail/find':
      {
        return createAnimationRoute(CompanyDetailFindOtherPage(args: settings.arguments,));
      }
      case '/company/detail/saham':
      {
        return createAnimationRoute(CompanyDetailSahamPage(companyData: settings.arguments,));
      }
      case '/company/detail/saham/find':
      {
        return createAnimationRoute(CompanyDetailSahamFindOtherPage(args: settings.arguments,));
      }
      case '/company/detail/crypto':
      {
        return createAnimationRoute(CompanyDetailCryptoPage(companyData: settings.arguments,));
      }
      case '/company/detail/gold':
      {
        return createAnimationRoute(const CompanyDetailGoldPage());
      }
      case '/watchlist/add':
      {
        return createAnimationRoute(WatchlistAddPage(watchlistArgs: settings.arguments,));
      }
      case '/watchlist/list':
      {
        return createAnimationRoute(WatchlistListPage(watchlistArgs: settings.arguments,));
      }
      case '/watchlist/performance':
      {
        return createAnimationRoute(WatchlistPerformancePage(args: settings.arguments,));
      }
      case '/watchlist/calendar':
      {
        return createAnimationRoute(WatchlistCalendarPage(args: settings.arguments,));
      }
      case '/watchlist/summary/performance':
      {
        return createAnimationRoute(WatchlistSummaryPerformancePage(args: settings.arguments,));
      }
      case '/watchlist/summary/calendar':
      {
        return createAnimationRoute(WatchlistSummaryCalendarPage(args: settings.arguments,));
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
      case '/broker/find':
      {
        return createAnimationRoute(const BrokerFindOtherPage());
      }
      case '/broker/detail':
      {
        return createAnimationRoute(BrokerDetailPage(args: settings.arguments,));
      }
      case '/insight/stock/industry':
      {
        return createAnimationRoute(InsightStockSubPage(args: settings.arguments,));
      }
      case '/insight/stock/sector/sub/list':
      {
        return createAnimationRoute(InsightStockSubListPage(args: settings.arguments,));
      }
      case '/insight/stock/per':
      {
        return createAnimationRoute(InsightStockPERListPage(args: settings.arguments,));
      }
      case '/insight/broker/specificbroker':
      {
        return createAnimationRoute(const InsightBandarBrokerCollectPage());
      }
      case '/insight/broker/specificquery':
      {
        return createAnimationRoute(const InsightBrokerSpecificQueryPage());
      }
      case '/insight/broker/specificcode':
      {
        return createAnimationRoute(const InsightBrokerSpecificCompanyPage());
      }
      case '/portofolio/list':
      {
        return createAnimationRoute(PortofolioListPage(args: settings.arguments,));
      }
      case '/portofolio/list/detail':
      {
        return createAnimationRoute(PortofolioDetailPage(args: settings.arguments,));
      }
      default:
      {
        return MaterialPageRoute(builder: (context) => const LoginPage());
      }
    }
  }
}