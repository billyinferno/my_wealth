import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:my_wealth/api/watchlist_api.dart';
import 'package:my_wealth/model/user/user_login.dart';
import 'package:my_wealth/model/watchlist/watchlist_performance_model.dart';
import 'package:my_wealth/themes/colors.dart';
import 'package:my_wealth/utils/arguments/company_detail_args.dart';
import 'package:my_wealth/utils/arguments/watchlist_list_args.dart';
import 'package:my_wealth/utils/function/computation.dart';
import 'package:my_wealth/utils/function/format_currency.dart';
import 'package:my_wealth/storage/prefs/shared_user.dart';
import 'package:my_wealth/utils/globals.dart';
import 'package:my_wealth/widgets/list/row_child.dart';
import 'package:my_wealth/widgets/list/watchlist_performance_builder.dart';
import 'package:my_wealth/widgets/page/common_error_page.dart';
import 'package:my_wealth/widgets/page/common_loading_page.dart';
import 'package:my_wealth/widgets/chart/performance_chart.dart';

class WatchlistPerformancePage extends StatefulWidget {
  final Object? args;
  const WatchlistPerformancePage({super.key, required this.args});

  @override
  State<WatchlistPerformancePage> createState() => _WatchlistPerformancePageState();
}

class _WatchlistPerformancePageState extends State<WatchlistPerformancePage> {
  final TextStyle _smallFont = const TextStyle(fontSize: 10, color: textPrimary,);
  final WatchlistAPI _watchlistAPI = WatchlistAPI();

  late WatchlistListArgs _watchlistArgs;
  late UserLoginInfoModel _userInfo;
  late WatchlistComputationResult _watchlistComputation;
  late Color _unrealisedColor;
  late Color _realisedColor;
  late Future<bool> _getData;
  late List<WatchlistPerformanceModel> _watchlistPerformance;
  late List<WatchlistPerformanceModel> _watchlistPerformance90Day;
  late List<WatchlistPerformanceModel> _watchlistPerformanceDaily;
  late List<WatchlistPerformanceModel> _watchlistPerformanceMonth;
  late List<WatchlistPerformanceModel> _watchlistPerformanceYear;
  late CompanyDetailArgs _companyArgs;
  late double _max;
  late Color _maxColor;
  late double _min;
  late Color _minColor;
  late double _avg;
  late Color _avgColor;
  late double _maxPL;
  late double _minPL;
  late int _totalData;
  late String _graphSelection;
  late String _dateFormat;
  late double _gainDifference;

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

    // set the unrealised and realised default color
    _unrealisedColor = textPrimary;
    _realisedColor = textPrimary;

    // get the computation for the watchlist
    _watchlistComputation = detailWatchlistComputation(watchlist: _watchlistArgs.watchList, riskFactor: _userInfo.risk);

    // check the unrealised and realised after computation to showed the correct color
    if (_watchlistComputation.totalUnrealisedGain > 0) {
      _unrealisedColor = Colors.green;
    }
    else if (_watchlistComputation.totalUnrealisedGain < 0) {
      _unrealisedColor = secondaryColor;
    }

    if (_watchlistComputation.totalRealisedGain > 0) {
      _realisedColor = Colors.green;
    }
    else if (_watchlistComputation.totalRealisedGain < 0) {
      _realisedColor = secondaryColor;
    }

    // assume max, min, and average is null
    _max = 0;
    _maxColor = textPrimary;
    _min = 0;
    _minColor = textPrimary;
    _avg = 0;
    _avgColor = textPrimary;
    _maxPL = 0;
    _minPL = 0;

    // set the graph selection as "9" (90 days)
    _graphSelection = "9";
    _dateFormat = "dd/MM";

    // initialize the result watchlist performance
    _watchlistPerformance = [];
    _watchlistPerformance90Day = [];
    _watchlistPerformanceDaily = [];
    _watchlistPerformanceMonth = [];
    _watchlistPerformanceYear = [];
    _gainDifference = 0;
    
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
    return PopScope(
      canPop: false,
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
                                    Globals.dfddMMyyyy.format(_watchlistArgs.watchList.watchlistCompanyLastUpdate!.toLocal()),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 8,),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              RowChild(headerText: "AVG PRICE", valueText: (_watchlistComputation.totalCurrentShares > 0 ? formatCurrency(_watchlistComputation.totalCost / _watchlistComputation.totalCurrentShares) : "-")),
                              const SizedBox(width: 10,),
                              RowChild(headerText: "COST", valueText: formatCurrency(_watchlistComputation.totalCost)),
                              const SizedBox(width: 10,),
                              RowChild(headerText: "VALUE", valueText: formatCurrency(_watchlistComputation.totalValue)),
                            ],
                          ),
                          const SizedBox(height: 5,),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              RowChild(headerText: "SHARES", valueText: formatCurrency(_watchlistComputation.totalCurrentShares)),
                              const SizedBox(width: 10,),
                              RowChild(headerText: "UNREALISED", valueText: formatCurrency(_watchlistComputation.totalUnrealisedGain), valueColor: _unrealisedColor),
                              const SizedBox(width: 10,),
                              RowChild(headerText: "REALISED", valueText: formatCurrency(_watchlistComputation.totalRealisedGain), valueColor: _realisedColor),
                            ],
                          ),
                          const SizedBox(height: 5,),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              RowChild(headerText: "MAX", valueText: formatCurrencyWithNull(_max), valueColor: _maxColor),
                              const SizedBox(width: 10,),
                              RowChild(headerText: "MIN", valueText: formatCurrencyWithNull(_min), valueColor: _minColor),
                              const SizedBox(width: 10,),
                              RowChild(headerText: "AVERAGE", valueText: formatCurrencyWithNull(_avg), valueColor: _avgColor),
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
            SizedBox(
              width: double.infinity,
              child: CupertinoSegmentedControl(
                children: const {
                  "9": Text("90 Days"),
                  "d": Text("Daily"),
                  "m": Text("Monhtly"),
                  "y": Text("Yearly"),
                },
                onValueChanged: ((value) {
                  String selectedValue = value.toString();
        
                  setState(() {
                    _graphSelection = selectedValue;

                    switch(_graphSelection) {
                      case "9":
                        _watchlistPerformance = _watchlistPerformance90Day.toList();
                        _dateFormat = "dd/MM";
                        break;
                      case "m":
                        _watchlistPerformance = _watchlistPerformanceMonth.toList();
                        _dateFormat = "MM/yy";
                        break;
                      case "y":
                        _watchlistPerformance = _watchlistPerformanceYear.toList();
                        _dateFormat = "MM/yy";
                        break;
                      default:
                        _watchlistPerformance = _watchlistPerformanceDaily.toList();
                        _dateFormat = "dd/MM";
                        break;
                    }

                    // calculate the gain difference
                    _calculateGainDifference();
                  });
                }),
                groupValue: _graphSelection,
                selectedColor: secondaryColor,
                borderColor: secondaryDark,
                pressedColor: primaryDark,
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
              child: Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(10, 2, 10, 2),
                  decoration: BoxDecoration(
                    color: (_gainDifference < 0 ? secondaryDark : Colors.green[900]),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Text(
                    formatCurrency(_gainDifference, false, true, false, 2),
                    style: const TextStyle(
                      fontSize: 10,
                    ),
                  )
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: PerformanceChart(
                watchlistPerfData: _watchlistPerformance,
                watchlist: _watchlistArgs.watchList.watchlistDetail,
                height: 250,
                dateOffset: (_watchlistPerformance.length > 10 ? null : 1),
                dateFormat: _dateFormat,
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
                  width: 50,
                  child: Text(
                    "DATE",
                    textAlign: TextAlign.center,
                    style: _smallFont,
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
                    child: Text(
                      "SHARES",
                      textAlign: TextAlign.center,
                      style: _smallFont,
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
                    child: Text(
                      "AVG",
                      textAlign: TextAlign.center,
                      style: _smallFont,
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
                    child: Text(
                      "PRICE",
                      textAlign: TextAlign.center,
                      style: _smallFont,
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
                    child: Text(
                      "P/L",
                      textAlign: TextAlign.center,
                      style: _smallFont,
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
                    child: Text(
                      "+/-",
                      textAlign: TextAlign.center,
                      style: _smallFont,
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: WatchlistBuilder(
                data: _watchlistPerformance,
                min: _min,
                max: _max,
                minPL: _minPL,
                maxPL: _maxPL,
                graphSelection: _graphSelection,
              ),
            ),
            const SizedBox(height: 25,), // safe area
          ],
        ),
      ),
    );
  }

  Future<bool> _getInitData() async {
    try {
      // perform the get company detail information here
      await _watchlistAPI.getWatchlistPerformance(_watchlistArgs.type, _watchlistArgs.watchList.watchlistId).then((resp) {
        // generate all the watchlist performance, 90 day, daily, monthly, yearly
        _watchlistPerformance90Day.clear();
        _watchlistPerformanceDaily.clear();
        _watchlistPerformanceMonth.clear();
        _watchlistPerformanceYear.clear();

        // loop thru all the response
        // for monthly and year, we will need help from MAP, so let's create
        // helper variable here
        Map<DateTime, WatchlistPerformanceModel> monthly = {};
        Map<DateTime, WatchlistPerformanceModel> yearly = {};
        
        DateTime dtMonth;
        DateTime dtYear;

        for(int i=0; i< resp.length; i++) {
          // first let's calculate the date
          dtMonth = DateTime(resp[i].buyDate.year, resp[i].buyDate.month, 1);
          dtYear = DateTime(resp[i].buyDate.year, 12, 31);

          monthly[dtMonth] = resp[i];
          yearly[dtYear] = resp[i];

          // check if this is lesser than 90 day or not?
          if (i >= (resp.length - 90)) {
            // add this to the 90 day list
            _watchlistPerformance90Day.add(resp[i]);
          }

          // for daily it seems that seeing 5 years should be enough
          // otherwise it will be showed too many?
          // 260 days is working day for a year
          if (i > (resp.length - (260 * 5))) {
            _watchlistPerformanceDaily.add(resp[i]);
          }
        }

        if (_watchlistPerformance90Day.isEmpty) {
          _watchlistPerformance90Day = [];
        }

        // once got the monthly and yearly, convert this map to list
        if (monthly.isNotEmpty) {
          _watchlistPerformanceMonth = monthly.values.toList();
        }
        else {
          _watchlistPerformanceMonth = [];
        }

        if (yearly.isNotEmpty) {
          _watchlistPerformanceYear = yearly.values.toList();
        }
        else {
          _watchlistPerformanceYear = [];
        }

        // now check which one is being selected by user
        _watchlistPerformance = [];
        switch(_graphSelection) {
          case "9":
            if (_watchlistPerformance90Day.isNotEmpty) {
              _watchlistPerformance = _watchlistPerformance90Day.toList();
            }
            break;
          case "m":
            if (_watchlistPerformanceMonth.isNotEmpty) {
              _watchlistPerformance = _watchlistPerformanceMonth.toList();
            }
            break;
          case "y":
            if (_watchlistPerformanceYear.isNotEmpty) {
              _watchlistPerformance = _watchlistPerformanceYear.toList();
            }
            break;
          default:
            _watchlistPerformance = [];
            break;
        }

        // calculate the gain difference
        _calculateGainDifference();

        // get the maximum and minimum
        _totalData = 0;
        
        double max = double.infinity * (-1);
        double min = double.infinity;
        double avg = 0;
        double pl = 0;
        double plDiffMin = double.infinity;
        double plDiffMax = double.infinity * (-1);
        double? plBefore;
        double? plDiff;

        for(int i=0; i < _watchlistPerformance.length; i++) {
          WatchlistPerformanceModel dt = _watchlistPerformance[i];

          // check if we got the data or not?
          if (dt.buyTotal > 0) {

            // got data, so now check if this is max or not
            _totalData++;

            pl = (dt.buyTotal * dt.currentPrice) - (dt.buyTotal * dt.buyAvg);

            // check if this is first PL or not?
            if (plBefore == null) {
              plBefore = pl;
            }
            else {
              plDiff = pl - plBefore;

              // check if this is plDiffMax or plDiffMin
              if (plDiff > plDiffMax) {
                plDiffMax = plDiff;
              }

              if (plDiff < plDiffMin) {
                plDiffMin = plDiff;
              }

              // set plBefore to pl
              plBefore = pl;
            }

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
          if (_max > 0) {
            _maxColor = Colors.green;
          }
          else if (_max < 0) {
            _maxColor = secondaryColor;
          }

          _min = min;
          if (_min > 0) {
            _minColor = Colors.green;
          }
          else if (_min < 0) {
            _minColor = secondaryColor;
          }

          _avg = avg / _totalData;
          if (_avg > 0) {
            _avgColor = Colors.green;
          }
          else if (_avg < 0) {
            _avgColor = secondaryColor;
          }

          _maxPL = plDiffMax;
          _minPL = plDiffMin;
        }
      });
    }
    catch(error) {
      debugPrint(error.toString());
      throw 'Error when try to get the data from server';
    }

    return true;
  }

  void _calculateGainDifference() {
    double firstTotal = 0;
    double lastTotal = 0;

    // calculate the gain difference by checking the first data of
    // _watchlistPerfomance and the last.
    // ensure that we have data first
    if (_watchlistPerformance.isNotEmpty) {
      // compute array 0 and length-1 to get the gain difference
      // get the first total
      firstTotal = (
          _watchlistPerformance[0].currentPrice * _watchlistPerformance[0].buyTotal
        ) - _watchlistPerformance[0].buyAmount;

      // calculate the last total                      
      lastTotal = (
          _watchlistPerformance[(_watchlistPerformance.length-1)].currentPrice *
          _watchlistPerformance[_watchlistPerformance.length-1].buyTotal
        ) - _watchlistPerformance[_watchlistPerformance.length-1].buyAmount;

      _gainDifference = lastTotal - firstTotal;
    }
    else {
      // if watchlist is empty, then defaulted to 0
      _gainDifference = 0;
    }
  }
}
