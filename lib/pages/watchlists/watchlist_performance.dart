import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ionicons/ionicons.dart';
import 'package:my_wealth/api/watchlist_api.dart';
import 'package:my_wealth/model/user_login.dart';
import 'package:my_wealth/model/watchlist_performance_model.dart';
import 'package:my_wealth/themes/colors.dart';
import 'package:my_wealth/utils/arguments/company_detail_args.dart';
import 'package:my_wealth/utils/arguments/watchlist_list_args.dart';
import 'package:my_wealth/utils/function/computation.dart';
import 'package:my_wealth/utils/function/format_currency.dart';
import 'package:my_wealth/utils/prefs/shared_user.dart';
import 'package:my_wealth/widgets/common_error_page.dart';
import 'package:my_wealth/widgets/common_loading_page.dart';
import 'package:my_wealth/widgets/performance_chart_painter.dart';

class WatchlistPerformancePage extends StatefulWidget {
  final Object? args;
  const WatchlistPerformancePage({Key? key, required this.args}) : super(key: key);

  @override
  State<WatchlistPerformancePage> createState() => _WatchlistPerformancePageState();
}

class _WatchlistPerformancePageState extends State<WatchlistPerformancePage> {
  final TextStyle _smallFont = const TextStyle(fontSize: 10, color: textPrimary,);
  final DateFormat _df = DateFormat('dd/MM/yyyy');
  final DateFormat _dfMMDD = DateFormat('MM/yy');
  final WatchlistAPI _watchlistAPI = WatchlistAPI();

  late WatchlistListArgs _watchlistArgs;
  late UserLoginInfoModel _userInfo;
  late WatchlistComputationResult _watchlistComputation;
  late Future<bool> _getData;
  late List<WatchlistPerformanceModel> _watchlistPerformance;
  late CompanyDetailArgs _companyArgs;
  late double? _max;
  late double? _min;
  late double? _avg;
  late int _totalData;

  @override
  void initState() {
    super.initState();

    // get the user information
    _userInfo = UserSharedPreferences.getUserInfo()!;

    // convert the args to watchlist args
    _watchlistArgs = widget.args as WatchlistListArgs;

    // set the company args so we can navigate to company detail page
    _companyArgs = CompanyDetailArgs(
      companyId: _watchlistArgs.watchList.watchlistCompanyId,
      companyName: _watchlistArgs.watchList.watchlistCompanyName,
      companyCode: _watchlistArgs.watchList.watchlistCompanySymbol ?? '',
      companyFavourite: (_watchlistArgs.watchList.watchlistFavouriteId > 0 ? true : false),
      favouritesId: _watchlistArgs.watchList.watchlistFavouriteId,
      type: _watchlistArgs.type
    );

    // get the computation for the watchlist
    _watchlistComputation = detailWatchlistComputation(watchlist: _watchlistArgs.watchList, riskFactor: _userInfo.risk);

    // assume max, min, and average is null
    _max = null;
    _min = null;
    _avg = null;
    
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
          actions: <Widget>[
            IconButton(
              onPressed: (() {
                Navigator.pushNamed(context, '/company/detail/${_watchlistArgs.type}', arguments: _companyArgs);
              }),
              icon: const Icon(
                Ionicons.business_outline
              ),
            )
          ],
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
                              _rowChild(headerText: "SHARES", valueText: formatCurrency(_watchlistComputation.totalCurrentShares)),
                              const SizedBox(width: 10,),
                              _rowChild(headerText: "UNREALISED", valueText: formatCurrency(_watchlistComputation.totalUnrealisedGain)),
                              const SizedBox(width: 10,),
                              _rowChild(headerText: "REALISED", valueText: formatCurrency(_watchlistComputation.totalRealisedGain)),
                            ],
                          ),
                          const SizedBox(height: 10,),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              _rowChild(headerText: "MAX", valueText: formatCurrencyWithNull(_max)),
                              const SizedBox(width: 10,),
                              _rowChild(headerText: "MIN", valueText: formatCurrencyWithNull(_min)),
                              const SizedBox(width: 10,),
                              _rowChild(headerText: "AVERAGE", valueText: formatCurrencyWithNull(_avg)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: CustomPaint(
                painter: PerformanceChartPainter(data: _watchlistPerformance),
                child: const SizedBox(
                  height: 250,
                ),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: const BoxDecoration(
                      color: primaryDark,
                      border: Border(
                          bottom: BorderSide(
                        color: primaryLight,
                        width: 1.0,
                        style: BorderStyle.solid,
                      ))),
                  width: 60,
                  child: const Text(
                    "DATE",
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(
                        color: primaryDark,
                        border: Border(
                            bottom: BorderSide(
                          color: primaryLight,
                          width: 1.0,
                          style: BorderStyle.solid,
                        ))),
                    child: const Text(
                      "SHARES",
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(
                        color: primaryDark,
                        border: Border(
                            bottom: BorderSide(
                          color: primaryLight,
                          width: 1.0,
                          style: BorderStyle.solid,
                        ))),
                    child: const Text(
                      "AVG",
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(5),
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
                    child: const Text(
                      "PRICE",
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(5),
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
                    child: const Text(
                      "P/L",
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _watchlistPerformance.length,
                itemBuilder: ((context, index) {
                  double pl = (_watchlistPerformance[index].buyTotal * _watchlistPerformance[index].currentPrice) - (_watchlistPerformance[index].buyTotal * _watchlistPerformance[index].buyAvg);
                  Color plColor = (pl == 0 ? textPrimary : (pl < 0 ? secondaryColor : Colors.green));

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.all(5),
                        width: 60,
                        child: Text(
                          _dfMMDD.format(_watchlistPerformance[index].buyDate),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          child: Text(
                            formatDecimal(_watchlistPerformance[index].buyTotal, 2),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          child: Text(
                            formatCurrency(_watchlistPerformance[index].buyAvg, false, false, true, 0),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          child: Text(
                            formatCurrency(_watchlistPerformance[index].currentPrice, false, false, true, 0),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          child: Text(
                            formatCurrency(pl, false, false, true, 0),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: plColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
            const SizedBox(height: 25,), // safe area
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

        // get the maximum and minimum
        _totalData = 0;
        
        double max = double.infinity * (-1);
        double min = double.infinity;
        double avg = 0;
        double pl = 0;

        for(WatchlistPerformanceModel dt in _watchlistPerformance) {
          // check if we got the data or not?
          if (dt.buyTotal > 0) {

            // got data, so now check if this is max or not
            _totalData++;

            pl = (dt.buyTotal * dt.currentPrice) - (dt.buyTotal * dt.buyAvg);

            // check if this is min or max?
            if (pl > max) {
              max = pl;
            }

            if (pl < min) {
              min = pl;
            }

            // add for the average
            avg = avg + pl;
          }
        }

        if (_totalData > 0) {
          _max = max;
          _min = min;
          _avg = avg / _totalData;
        }
      });
    }
    catch(error) {
      debugPrint(error.toString());
      throw 'Error when try to get the data from server';
    }

    return true;
  }
}