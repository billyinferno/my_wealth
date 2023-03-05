import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ionicons/ionicons.dart';
import 'package:my_wealth/api/watchlist_api.dart';
import 'package:my_wealth/model/watchlist/watchlist_summary_performance_model.dart';
import 'package:my_wealth/model/user/user_login.dart';
import 'package:my_wealth/themes/colors.dart';
import 'package:my_wealth/utils/arguments/wacthlist_summary_performance_args.dart';
import 'package:my_wealth/utils/extensions/string.dart';
import 'package:my_wealth/utils/function/format_currency.dart';
import 'package:my_wealth/utils/function/risk_color.dart';
import 'package:my_wealth/utils/prefs/shared_user.dart';
import 'package:my_wealth/widgets/common_error_page.dart';
import 'package:my_wealth/widgets/common_loading_page.dart';
import 'package:my_wealth/widgets/performance_chart.dart';
import 'package:my_wealth/widgets/performance_chart_painter.dart';

class WatchlistSummaryPerformancePage extends StatefulWidget {
  final Object? args;
  const WatchlistSummaryPerformancePage({Key? key, required this.args}) : super(key: key);

  @override
  State<WatchlistSummaryPerformancePage> createState() => _WatchlistSummaryPerformancePageState();
}

class _WatchlistSummaryPerformancePageState extends State<WatchlistSummaryPerformancePage> {
  final WatchlistAPI _watchlistAPI = WatchlistAPI();
  final TextStyle _smallFont = const TextStyle(fontSize: 10, color: textPrimary,);
  final DateFormat _df = DateFormat('dd/MM/yyyy');

  late WatchlistSummaryPerformanceArgs _args;
  late UserLoginInfoModel _userInfo;
  late Future<bool> _getData;
  late List<SummaryPerformanceModel> _summaryPerfData;
  late List<PerformanceData> _perfData;
  late double _totalDayGain;
  late double _totalCost;
  late double _totalValue;
  late double _totalRealised;
  late double _totalUnrealised;
  late double _totalPotentialPL;
  late double _max;
  late double _min;
  late double _avg;
  late double _maxPL;
  late double _minPL;
  late int _totalData;

  @override
  void initState() {
    // init all the variables
    _totalDayGain = 0;
    _totalCost = 0;
    _totalValue = 0;
    _totalRealised = 0;
    _totalUnrealised = 0;
    _totalPotentialPL = 0;
    _totalData = 0;

    _perfData = [];

    // get the arguments passed on this
    _args = widget.args as WatchlistSummaryPerformanceArgs;

    // get the user info
    _userInfo = UserSharedPreferences.getUserInfo()!;

    // from the args we will knew the type and and the daygain, realised, and unrealised
    // value, so we don't need to calculate or compute again, as this already compute on
    // the watchlist page.
    switch(_args.type) {
      case 'reksadana':
        _totalDayGain = _args.computeResult!.totalDayGainReksadana;
        _totalCost = _args.computeResult!.totalCostReksadana;
        _totalValue = _args.computeResult!.totalValueReksadana;
        _totalRealised = _args.computeResult!.totalRealisedReksadana;
        _totalUnrealised = _args.computeResult!.totalValueReksadana - _args.computeResult!.totalCostReksadana;
        break;
      case 'saham':
        _totalDayGain = _args.computeResult!.totalDayGainSaham;
        _totalCost = _args.computeResult!.totalCostSaham;
        _totalValue = _args.computeResult!.totalValueSaham;
        _totalRealised = _args.computeResult!.totalRealisedSaham;
        _totalUnrealised = _args.computeResult!.totalValueSaham - _args.computeResult!.totalCostSaham;
        break;
      case 'gold':
        _totalDayGain = _args.computeResult!.totalDayGainGold;
        _totalCost = _args.computeResult!.totalCostGold;
        _totalValue = _args.computeResult!.totalValueGold;
        _totalRealised = _args.computeResult!.totalRealisedGold;
        _totalUnrealised = _args.computeResult!.totalValueGold - _args.computeResult!.totalCostGold;
        break;
      case 'crypto':
        _totalDayGain = _args.computeResult!.totalDayGainCrypto;
        _totalCost = _args.computeResult!.totalCostCrypto;
        _totalValue = _args.computeResult!.totalValueCrypto;
        _totalRealised = _args.computeResult!.totalRealisedCrypto;
        _totalUnrealised = _args.computeResult!.totalValueCrypto - _args.computeResult!.totalCostCrypto;
        break;
      default:
        _totalRealised = 0;
        _totalDayGain = 0;
        _totalCost = 0;
        _totalValue = 0;
        _totalUnrealised = 0;
        break;
    }

    // once calculation finished we can try to calculate the potential PL
    _totalPotentialPL = _totalRealised + _totalUnrealised;

    _getData = _getPerformanceData();

    super.initState();
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
          title: Center(
            child: Text(
              "Performance ${_args.type.toCapitalized()}",
              style: const TextStyle(
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
              color: riskColor(_totalValue, _totalCost, _userInfo.risk),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(width: 10,),
                  Expanded(
                    child: Container(
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
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              _rowItem(text: "DAY GAIN", value: _totalDayGain, needColor: true),
                              const SizedBox(width: 10,),
                              _rowItem(text: "COST", value: _totalCost),
                              const SizedBox(width: 10,),
                              _rowItem(text: "VALUE", value: _totalValue),
                            ],
                          ),
                          const SizedBox(height: 10,),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              _rowItem(text: "UNREALISED", value: _totalUnrealised, needColor: true),
                              const SizedBox(width: 10,),
                              _rowItem(text: "REALISED", value: _totalRealised, needColor: true),
                              const SizedBox(width: 10,),
                              _rowItem(text: "POTENTIAL PL", value: _totalPotentialPL, needColor: true),
                            ],
                          ),
                          const SizedBox(height: 10,),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              _rowItem(text: "MIN", value: _min, needColor: true),
                              const SizedBox(width: 10,),
                              _rowItem(text: "MAX", value: _max, needColor: true),
                              const SizedBox(width: 10,),
                              _rowItem(text: "AVERAGE", value: _avg, needColor: true),
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
              child: PerformanceChart(
                perfData: _perfData,
                height: 250,
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
                  width: 100,
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
              child: ListView.builder(
                itemCount: _perfData.length,
                physics: const AlwaysScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  double? plDiff;
                  Color plDiffColor = textPrimary;
                  if (index > 0) {
                    // get the pl diff with pl before and now
                    plDiff = _perfData[index].gain - _perfData[index - 1].gain;

                    // set the correct plDiffColor
                    if (plDiff > 0) plDiffColor = Colors.green;
                    if (plDiff < 0) plDiffColor = secondaryColor;
                  }

                  // check if this data is the same as _max or _min?
                  Color plColor = (_perfData[index].gain == 0 ? textPrimary : (_perfData[index].gain < 0 ? secondaryColor : Colors.green));

                  bool isMinMax = false;
                  if (_perfData[index].gain == _max || _perfData[index].gain == _min) {
                    // means for this we will need to put color on the container instead of the text
                    isMinMax = true;
                    plColor = textPrimary;
                    if (_perfData[index].gain == _max) {
                      plColor = Colors.green[900]!;
                    }
                    if (_perfData[index].gain == _min) {
                      plColor = secondaryDark;
                    }
                  }

                  bool isPLMinMax = false;
                  if (plDiff == _maxPL || plDiff == _minPL) {
                    // means for this we will need to put color on the container instead of the text
                    isPLMinMax = true;
                    plDiffColor = (plDiff == 0 ? textPrimary : (plDiff! < 0 ? secondaryDark : Colors.green[900]!));
                  }
                  
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.all(5),
                        width: 100,
                        child: Text(
                          _df.format(_perfData[index].date),
                          textAlign: TextAlign.center,
                          style: _smallFont,
                        ),
                      ),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          color: (isMinMax ? plColor : Colors.transparent),
                          child: Text(
                            formatCurrency(_perfData[index].gain, false, false, false, 0),
                            textAlign: TextAlign.center,
                            style: _smallFont.copyWith(
                              color: (isMinMax ? Colors.white : plColor),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          color: (isPLMinMax ? plDiffColor : Colors.transparent),
                          child: Text(
                            formatCurrencyWithNull(plDiff, false, false, false, 0),
                            textAlign: TextAlign.center,
                            style: _smallFont.copyWith(
                              color: (isPLMinMax ? Colors.white : plDiffColor),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 30,),
          ],
        ),
      ),
    );
  }

  Widget _rowItem({required String text, required double value, bool? needColor}) {
    bool isNeedColor = (needColor ?? false);    
    Color textColor = textPrimary;

    if (isNeedColor) {
      if (value < 0) {
        textColor = secondaryColor;
      }
      if (value > 0) {
        textColor = Colors.green;
      }
    }

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Text(
            text,
            style: const TextStyle(
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 2,),
          Text(
            formatCurrency(value, false, true, true, 2),
            style: TextStyle(
              color: textColor
            ),
          )
        ],
      ),
    );
  }

  Future<bool> _getPerformanceData() async {
    try {
      // perform the get company detail information here
      await _watchlistAPI.getWatchlistPerformanceSummary(_args.type).then((resp) {
        // copy the response to watchlist performance
        _summaryPerfData = resp; 

        // get the maximum and minimum
        _totalData = 0;
        
        double max = double.infinity * (-1);
        double min = double.infinity;
        double avg = 0;
        double plDiffMin = double.infinity;
        double plDiffMax = double.infinity * (-1);
        double? plBefore;
        double? plDiff;

        for(int i=0; i < _summaryPerfData.length; i++) {
          SummaryPerformanceModel dt = _summaryPerfData[i];

          // add this data to the performance data
          _perfData.add(PerformanceData(date: dt.plDate, gain: dt.plValue));

          // got data, so now check if this is max or not
          _totalData++;

          // check if this is first PL or not?
          if (plBefore == null) {
            plBefore = dt.plValue;
          }
          else {
            plDiff = dt.plValue - plBefore;

            // check if this is plDiffMax or plDiffMin
            if (plDiff > plDiffMax) {
              plDiffMax = plDiff;
            }

            if (plDiff < plDiffMin) {
              plDiffMin = plDiff;
            }

            // set plBefore to pl
            plBefore = dt.plValue;
          }

          // check if this is min or max?
          if (dt.plValue > max) {
            max = dt.plValue;
          }

          if (dt.plValue < min) {
            min = dt.plValue;
          }

          // add for the average
          avg = avg + dt.plValue;
        }

        if (_totalData > 0) {
          _max = max;
          _min = min;
          _avg = avg / _totalData;
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
}