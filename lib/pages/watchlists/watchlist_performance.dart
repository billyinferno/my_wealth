import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ionicons/ionicons.dart';
import 'package:my_wealth/api/watchlist_api.dart';
import 'package:my_wealth/model/user_login.dart';
import 'package:my_wealth/model/watchlist_performance_model.dart';
import 'package:my_wealth/themes/colors.dart';
import 'package:my_wealth/utils/arguments/watchlist_list_args.dart';
import 'package:my_wealth/utils/function/computation.dart';
import 'package:my_wealth/utils/function/format_currency.dart';
import 'package:my_wealth/utils/prefs/shared_user.dart';
import 'package:my_wealth/widgets/common_error_page.dart';
import 'package:my_wealth/widgets/common_loading_page.dart';

class WatchlistPerformancePage extends StatefulWidget {
  final Object? args;
  const WatchlistPerformancePage({Key? key, required this.args}) : super(key: key);

  @override
  State<WatchlistPerformancePage> createState() => _WatchlistPerformancePageState();
}

class _WatchlistPerformancePageState extends State<WatchlistPerformancePage> {
  final TextStyle _smallFont = const TextStyle(fontSize: 10, color: textPrimary,);
  final DateFormat _df = DateFormat('dd/MM/yyyy');
  final WatchlistAPI _watchlistAPI = WatchlistAPI();

  late WatchlistListArgs _watchlistArgs;
  late UserLoginInfoModel _userInfo;
  late WatchlistComputationResult _watchlistComputation;
  late Future<bool> _getData;
  late List<WatchlistPerformanceModel> _watchlistPerformance;

  @override
  void initState() {
    super.initState();

    // get the user information
    _userInfo = UserSharedPreferences.getUserInfo()!;

    // convert the args to watchlist args
    _watchlistArgs = widget.args as WatchlistListArgs;

    // get the computation for the watchlist
    _watchlistComputation = detailWatchlistComputation(watchlist: _watchlistArgs.watchList, riskFactor: _userInfo.risk);

    // get initial data
    _getData = _getInitData();   
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getData,
      builder: ((context, snapshot) {
        if (snapshot.hasError) {
          return const CommonErrorPage(errorText: 'Error loading watchlist performance');
        }
        else if (snapshot.hasData) {
          return _generatePage();
        }
        else {
          return const CommonLoadingPage();
        }
      })
    );
  }

  Widget _generatePage() {
    return WillPopScope(
      onWillPop: (() async {
        return false;
      }),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: ((() {
              // return back to the previous page
              Navigator.pop(context);
            })),
            icon: const Icon(
              Ionicons.arrow_back,
            )
          ),
          title: const Center(
            child: Text(
              "Performance",
              style: TextStyle(
                color: secondaryColor,
              ),
            )
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              width: double.infinity,
              color: _watchlistComputation.riskColor,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(width: 10,),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: primaryDark,
                        border: Border(
                          bottom: BorderSide(
                            color: primaryLight,
                            width: 1.0,
                            style: BorderStyle.solid,
                          )
                        )
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            _watchlistArgs.watchList.watchlistCompanyName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 5,),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    formatCurrencyWithNull(_watchlistArgs.watchList.watchlistCompanyNetAssetValue, false, true, false, 2),
                                  ),
                                  const SizedBox(width: 5,),
                                  (_watchlistComputation.priceDiff == 0 ? const Icon(Ionicons.remove_outline, color: textPrimary, size: 15,) : (_watchlistComputation.priceDiff > 0 ? const Icon(Ionicons.caret_up, color: Colors.green, size: 12,) : const Icon(Ionicons.caret_down, color: secondaryColor, size: 12,))),
                                  const SizedBox(width: 5,),
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: (_watchlistComputation.priceDiff == 0 ? textPrimary : (_watchlistComputation.priceDiff > 0 ? Colors.green : secondaryColor)),
                                          width: 2.0,
                                          style: BorderStyle.solid,
                                        )
                                      )
                                    ),
                                    child: Text(
                                      formatCurrencyWithNull(_watchlistComputation.priceDiff, false, true, false, 2),
                                    ),
                                  )
                                ],
                              ),
                              const Expanded(child: SizedBox()),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  const Icon(
                                    Ionicons.time_outline,
                                    color: primaryLight,
                                    size: 15,
                                  ),
                                  const SizedBox(width: 5,),
                                  Text(
                                    _df.format(_watchlistArgs.watchList.watchlistCompanyLastUpdate!),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 10,),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              _rowChild(headerText: "AVG PRICE", valueText: (_watchlistComputation.totalCurrentShares > 0 ? formatCurrency(_watchlistComputation.totalCost / _watchlistComputation.totalCurrentShares) : "-")),
                              const SizedBox(width: 10,),
                              _rowChild(headerText: "COST", valueText: formatCurrency(_watchlistComputation.totalCost)),
                              const SizedBox(width: 10,),
                              _rowChild(headerText: "VALUE", valueText: formatCurrency(_watchlistComputation.totalValue)),
                            ],
                          ),
                          const SizedBox(height: 10,),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              _rowChild(headerText: "CURRENT", valueText: formatCurrency(_watchlistComputation.totalCurrentShares)),
                              const SizedBox(width: 10,),
                              _rowChild(headerText: "UNREALISED", valueText: formatCurrency(_watchlistComputation.totalUnrealisedGain)),
                              const SizedBox(width: 10,),
                              _rowChild(headerText: "REALISED", valueText: formatCurrency(_watchlistComputation.totalRealisedGain)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10,),
            Text("AAAAA")
          ],
        ),
      ),
    );
  }

  Widget _rowChild({required String headerText, required String valueText}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: double.infinity,
            child: Text(
              headerText,
              style: _smallFont,
            ),
          ),
          const SizedBox(height: 2,),
          Text(
            valueText,
          ),
        ],
      ),
    );
  }

  Future<bool> _getInitData() async {
    try {
      // perform the get company detail information here
      await _watchlistAPI.getWatchlistPerformance(_watchlistArgs.type, _watchlistArgs.watchList.watchlistId).then((resp) {
        // copy the response to watchlist performance
        _watchlistPerformance = resp; 
      });
    }
    catch(error) {
      debugPrint(error.toString());
      throw 'Error when try to get the data from server';
    }

    return true;
  }
}