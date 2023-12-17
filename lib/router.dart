import 'package:flutter/material.dart';
import 'package:my_wealth/pages/broker/broker_detail.dart';
import 'package:my_wealth/pages/broker/broker_find_other.dart';
import 'package:my_wealth/pages/company/company_detail_crypto.dart';
import 'package:my_wealth/pages/company/company_detail_gold.dart';
import 'package:my_wealth/pages/company/company_detail_reksadana.dart';
import 'package:my_wealth/pages/company/company_detail_saham.dart';
import 'package:my_wealth/pages/company/find/company_detail_find_other.dart';
import 'package:my_wealth/pages/company/find/company_detail_saham_find_other.dart';
import 'package:my_wealth/pages/favourites/favourite_company_list_crypto.dart';
import 'package:my_wealth/pages/favourites/favourite_company_list_reksadana.dart';
import 'package:my_wealth/pages/favourites/favourite_company_list_saham.dart';
import 'package:my_wealth/pages/home.dart';
import 'package:my_wealth/pages/index/index_detail.dart';
import 'package:my_wealth/pages/insight/insight_broker_page/insight_broker_specific_company.dart';
import 'package:my_wealth/pages/insight/insight_broker_page/insight_broker_specific_query.dart';
import 'package:my_wealth/pages/insight/insight_stock_page/insight_stock_per_list.dart';
import 'package:my_wealth/pages/insight/insight_stock_page/insight_stock_sub.dart';
import 'package:my_wealth/pages/insight/insight_stock_page/insight_stock_sub_list.dart';
import 'package:my_wealth/pages/login.dart';
import 'package:my_wealth/pages/portofolio/portofolio_detail.dart';
import 'package:my_wealth/pages/portofolio/portofolio_list.dart';
import 'package:my_wealth/pages/users/user/change_password.dart';
import 'package:my_wealth/pages/users/user/update_bot.dart';
import 'package:my_wealth/pages/users/user/update_risk.dart';
import 'package:my_wealth/pages/users/user.dart';
import 'package:my_wealth/pages/watchlist_detail/watchlist_detail_create.dart';
import 'package:my_wealth/pages/watchlist_detail/watchlist_detail_edit.dart';
import 'package:my_wealth/pages/watchlist_detail/watchlist_detail_sell.dart';
import 'package:my_wealth/pages/watchlists/watchlist_add.dart';
import 'package:my_wealth/pages/watchlists/watchlist_calendar.dart';
import 'package:my_wealth/pages/watchlists/watchlist_list.dart';
import 'package:my_wealth/pages/watchlists/watchlist_performance.dart';
import 'package:my_wealth/pages/watchlists/watchlist_summary_performance.dart';
import 'package:my_wealth/provider/broker_provider.dart';
import 'package:my_wealth/provider/company_provider.dart';
import 'package:my_wealth/provider/favourites_provider.dart';
import 'package:my_wealth/provider/index_provider.dart';
import 'package:my_wealth/provider/inisght_provider.dart';
import 'package:my_wealth/provider/user_provider.dart';
import 'package:my_wealth/provider/watchlist_provider.dart';
import 'package:my_wealth/themes/colors.dart';
import 'package:my_wealth/themes/theme.dart';
import 'package:my_wealth/utils/animation/page_transition.dart';
import 'package:my_wealth/utils/extensions/custom_scroll_behaviour.dart';
import 'package:my_wealth/storage/prefs/shared_user.dart';
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
      case '/company/detail/find':
      {
        return createAnimationRoute(CompanyDetailFindOtherPage(type: settings.arguments,));
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