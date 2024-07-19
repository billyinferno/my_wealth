import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:my_wealth/api/index_api.dart';
import 'package:my_wealth/api/watchlist_api.dart';
import 'package:my_wealth/model/index/index_model.dart';
import 'package:my_wealth/model/index/index_price_model.dart';
import 'package:my_wealth/model/watchlist/watchlist_summary_performance_model.dart';
import 'package:my_wealth/model/user/user_login.dart';
import 'package:my_wealth/themes/colors.dart';
import 'package:my_wealth/utils/arguments/wacthlist_summary_performance_args.dart';
import 'package:my_wealth/utils/dialog/create_snack_bar.dart';
import 'package:my_wealth/utils/extensions/string.dart';
import 'package:my_wealth/utils/function/format_currency.dart';
import 'package:my_wealth/utils/function/risk_color.dart';
import 'package:my_wealth/storage/prefs/shared_user.dart';
import 'package:my_wealth/utils/globals.dart';
import 'package:my_wealth/widgets/modal/overlay_loading_modal.dart';
import 'package:my_wealth/widgets/page/common_error_page.dart';
import 'package:my_wealth/widgets/page/common_loading_page.dart';
import 'package:my_wealth/widgets/chart/performance_chart.dart';
import 'package:my_wealth/widgets/chart/performance_chart_painter.dart';

class WatchlistSummaryPerformancePage extends StatefulWidget {
  final Object? args;
  const WatchlistSummaryPerformancePage({super.key, required this.args});

  @override
  State<WatchlistSummaryPerformancePage> createState() => _WatchlistSummaryPerformancePageState();
}

class _WatchlistSummaryPerformancePageState extends State<WatchlistSummaryPerformancePage> {
  final WatchlistAPI _watchlistAPI = WatchlistAPI();
  final IndexAPI _indexAPI = IndexAPI();
  final TextStyle _smallFont = const TextStyle(fontSize: 10, color: textPrimary,);

  late WatchlistSummaryPerformanceArgs _args;
  late UserLoginInfoModel _userInfo;
  late Future<bool> _getData;
  late List<SummaryPerformanceModel> _summaryPerfData;
  late List<PerformanceData> _perfData;
  late List<PerformanceData> _perfData90D;
  late List<PerformanceData> _perfDataDaily;
  late List<PerformanceData> _perfDataMonhtly;
  late List<PerformanceData> _perfDataYearly;
  late double _totalDayGain;
  late double _totalCost;
  late double _totalValue;
  late double _totalRealised;
  late double _totalUnrealised;
  late double _totalPotentialPL;
  late double _max;
  late double _min;
  late double _avg;
  late double _max90;
  late double _min90;
  late double _maxDaily;
  late double _minDaily;
  late double _maxMonhtly;
  late double _minMonhtly;
  late double _maxYearly;
  late double _minYearly;
  late double _maxPL;
  late double _minPL;
  late IndexModel _indexCompare;
  late String _indexCompareName;
  late List<IndexPriceModel> _indexComparePrice;

  late int _totalData;
  late String _graphSelection;
  late String _dateFormat;
  late double _gainDifference;

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
    _perfData90D = [];
    _perfDataDaily = [];
    _perfDataMonhtly = [];
    _perfDataYearly = [];
    _gainDifference = 0;

    _indexCompareName = "";
    _indexComparePrice = [];

    // defaulted the graph selection into 90 day
    _graphSelection = '9';

    // defaulted the date format to dd/MM
    _dateFormat = "dd/MM";

    // get the arguments passed on this
    _args = widget.args as WatchlistSummaryPerformanceArgs;

    // get the user info
    _userInfo = UserSharedPreferences.getUserInfo()!;

    // from the args we will knew the type and and the daygain, realised, and unrealised
    // value, so we don't need to calculate or compute again, as this already compute on
    // the watchlist page.
    _totalDayGain = _args.computeResult!.getTotalDayGain(type: _args.type);
    _totalCost = _args.computeResult!.getTotalCost(type: _args.type);
    _totalValue = _args.computeResult!.getTotalValue(type: _args.type);
    _totalRealised = _args.computeResult!.getTotalRealised(type: _args.type);
    _totalUnrealised = _totalValue - _totalCost;

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
          title: Center(
            child: Text(
              "Performance ${_args.type.toCapitalized()}",
              style: const TextStyle(
                color: secondaryColor,
              ),
            )
          ),
          actions: <Widget>[
            IconButton(
              onPressed: (() async {
                // go to index list page
                await Navigator.pushNamed(context, '/index/find').then((value) async {
                  if (value != null) {
                    // convert value to company list model
                    _indexCompare = value as IndexModel;
                    _indexCompareName = _indexCompare.indexName;

                    await _getIndexData().onError((error, stackTrace) {
                      // remove the index compare name and price since we will
                      // not be able to perform comparison
                      _indexCompareName = "";
                      _indexComparePrice.clear();
                    },);
                  }
                });
              }),
              icon: const Icon(
                Ionicons.git_compare_outline,
                color: textPrimary,
              )
            ),
            const SizedBox(width: 10,),
          ],
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
                          const SizedBox(height: 5,),
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
                          const SizedBox(height: 5,),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              _rowItem(text: "MIN (${_perfData.length})", value: _min, needColor: true),
                              const SizedBox(width: 10,),
                              _rowItem(text: "MAX (${_perfData.length})", value: _max, needColor: true),
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
                        _perfData = _perfData90D.toList();
                        _dateFormat = "dd/MM";
                        _max = _max90;
                        _min = _min90;
                        break;
                      case "m":
                        _perfData = _perfDataMonhtly.toList();
                        _dateFormat = "MM/yy";
                        _max = _maxMonhtly;
                        _min = _minMonhtly;
                        break;
                      case "y":
                        _perfData = _perfDataYearly.toList();
                        _dateFormat = "MM/yy";
                        _max = _maxYearly;
                        _min = _minYearly;
                        break;
                      default:
                        _perfData = _perfDataDaily.toList();
                        _dateFormat = "dd/MM";
                        _max = _maxDaily;
                        _min = _minDaily;
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
              width: double.infinity,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Visibility(
                    visible: (_indexCompareName.isNotEmpty),
                    child: Text(
                      "Comparing with $_indexCompareName",
                      style: const TextStyle(
                        fontSize: 10,
                      ),
                    )
                  ),
                  const Expanded(child: SizedBox(),),
                  Container(
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
                  )
                ],
              ),
            ),
            _showChart(),
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
                Container(
                  width: 50,
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
                    "%",
                    textAlign: TextAlign.center,
                    style: _smallFont,
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

                  String percentGain = "-";
                  if (_perfData[index].total > 0) {
                    percentGain = "${formatDecimalWithNull(_perfData[index].gain / _perfData[index].total, 100, 2)}%";
                  }
                  
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.all(5),
                        width: 100,
                        child: Text(
                          Globals.dfddMMyyyy.format(_perfData[index].date),
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
                      Container(
                        width: 75,
                        color: (isMinMax ? plColor : Colors.transparent),
                        padding: const EdgeInsets.all(5),
                        child: Text(
                          percentGain,
                          textAlign: TextAlign.center,
                          style: _smallFont.copyWith(
                            color: (isMinMax ? Colors.white : plColor),
                          ),
                          overflow: TextOverflow.ellipsis,
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

  Widget _showChart() {
    // check if we have data or not?
    if (_perfData.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(10),
        child: const Center(
          child: Text("No data"),
        ),
      );
    }

    // we got performance date
    return SizedBox(
      width: double.infinity,
      child: PerformanceChart(
        perfData: _perfData,
        height: 250,
        dateOffset: (_perfData.length > 10 ? null : 1),
        dateFormat: _dateFormat,
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
    double max = double.infinity * (-1);
    double min = double.infinity;
    double avg = 0;
    double plDiffMin = double.infinity;
    double plDiffMax = double.infinity * (-1);
    double? plBefore;
    double? plDiff;

    // check whether the arguments is all, if all then we will need to get all the data, and combine it later
    if (_args.type == 'all') {
      Map<String, List<SummaryPerformanceModel>> perfData = {};
      await Future.wait([
        _watchlistAPI.getWatchlistPerformanceSummary('reksadana').then((resp) {
          perfData['reksadana'] = resp;
        }),
        _watchlistAPI.getWatchlistPerformanceSummary('saham').then((resp) {
          perfData['saham'] = resp;
        }),
        _watchlistAPI.getWatchlistPerformanceSummary('gold').then((resp) {
          perfData['gold'] = resp;
        }),
        _watchlistAPI.getWatchlistPerformanceSummary('crypto').then((resp) {
          perfData['crypto'] = resp;
        }),
      ]).then((_) {
        // set the total data as 0
        _totalData = 0;

        // temporaty performance data map
        Map<DateTime, SummaryPerformanceModel> tmpSummaryPerfData = {};
        Map<DateTime, bool> mapDates = {};
        List<DateTime> listDates = [];
        SummaryPerformanceModel tmpCurrentSummaryPerfModel;
        SummaryPerformanceModel tmpNextSummaryPerfModel;

        // loop thru all the perf data to get the dates
        perfData.forEach((key, data) {
          for(int i=0; i < data.length; i++) {
            mapDates[data[i].plDate] = true;
          }
        });
        // sort the dates so we can use it later when we want to generate the performance data
        listDates = mapDates.keys.toList()..sort();

        // loop thru all the perfData
        perfData.forEach((key, data) {
          // convert the performance data to map, so we can check whether the date is available or not?
          Map<DateTime, SummaryPerformanceModel> tmpPerfData = {};

          // loop thru all the performance model
          for(int i=0; i < data.length; i++) {
            tmpPerfData[data[i].plDate] = data[i];
          }

          // loop thru the list of dates
          double prevValue = 0;
          double prevAmount = 0;
          for(int i=0; i < listDates.length; i++) {
            // check if this date is available or not on the tmpPerfData
            if (tmpPerfData.containsKey(listDates[i])) {
              // just add the data
              prevValue = tmpPerfData[listDates[i]]!.plValue;
              prevAmount = tmpPerfData[listDates[i]]!.totalAmount;
            }

            // add this prevValue and totalAmount to the tmpSummaryPerfData
            // first check if exists or not on the tmpSummaryPerfData
            if (tmpSummaryPerfData.containsKey(listDates[i])) {
              // get the current value
              tmpCurrentSummaryPerfModel = tmpSummaryPerfData[listDates[i]]!;
              // create the next data
              tmpNextSummaryPerfModel = SummaryPerformanceModel(
                plDate: listDates[i],
                plValue: tmpCurrentSummaryPerfModel.plValue + prevValue,
                totalAmount: tmpCurrentSummaryPerfModel.totalAmount + prevAmount,
              );
              // add to the tmpSummaryPerfData
              tmpSummaryPerfData[listDates[i]] = tmpNextSummaryPerfModel;
            }
            else {
              tmpSummaryPerfData[listDates[i]] = SummaryPerformanceModel(
                plDate: listDates[i],
                plValue: prevValue,
                totalAmount: prevAmount,
              );
            }
          }
        });

        // once finished loop all the performance data, and combine it
        // extract the data from map to list of _summaryPerfData and _perfData
        _summaryPerfData = [];
        tmpSummaryPerfData.forEach((key, data) {          
          // add this data to the summary perf data
          _summaryPerfData.add(data);
        });
      }).onError((error, stackTrace) {
        debugPrint(error.toString());
        throw 'Error when try to get the data from server';
      });
    }
    else {
      try {
        // perform the get company detail information here
        await _watchlistAPI.getWatchlistPerformanceSummary(_args.type).then((resp) {
          // copy the response to watchlist performance
          _summaryPerfData = resp; 
        });
      }
      catch(error) {
        debugPrint(error.toString());
        throw 'Error when try to get the data from server';
      }
    }

    // monthly and yearly performance data helper
    Map<DateTime, PerformanceData> monthly = {};
    Map<DateTime, PerformanceData> yearly = {};

    // helper for get the month and year performance
    DateTime dtMonth;
    DateTime dtYear;
    
    // loop thru all the summary performance data
    for(int i=0; i < _summaryPerfData.length; i++) {
      SummaryPerformanceModel dt = _summaryPerfData[i];

      // process the summary performance data by separate it into 90 day, daily,
      // monthly, and yearly.

      PerformanceData currData = PerformanceData(
        date: dt.plDate,
        gain: dt.plValue,
        total: dt.totalAmount,
      );

      // for daily, we will only showed the latest 5 years, since if more than
      // that it will be too many.
      // 260 days is working day for a year
      if (i >= (_summaryPerfData.length - (260 * 5))) {
        _perfDataDaily.add(currData);
      }

      // check if this is last 90 day?
      if (i >= (_summaryPerfData.length - 90)) {
        _perfData90D.add(currData);
      }

      // get the month/year for this data
      dtMonth = DateTime(dt.plDate.year, dt.plDate.month, 1);
      dtYear = DateTime(dt.plDate.year, 12, 31);

      // add the month and year to the helper map
      monthly[dtMonth] = currData;
      yearly[dtYear] = currData;

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
      avg = avg + (plDiff ?? 0);
    }

    // now put all the entried on the monhtly and yearly to the performance
    // data list for monthly and yearly.
    _perfDataMonhtly = monthly.values.toList();
    _perfDataYearly = yearly.values.toList();

    // get the performance data based on graph selection
    switch(_graphSelection) {
        case "9":
          _perfData = _perfData90D.toList();
          _dateFormat = "dd/MM";
          break;
        case "m":
          _perfData = _perfDataMonhtly.toList();
          _dateFormat = "MM/yy";
          break;
        case "y":
          _perfData = _perfDataYearly.toList();
          _dateFormat = "MM/yy";
          break;
        default:
          _perfData = _perfDataDaily.toList();
          _dateFormat = "dd/MM";
          break;
    }

    // calculate the gain difference
    _calculateGainDifference();

    // calculate the min max for each graph
    _calculateMinMax();

    _totalData = _perfData.length;
    if (_totalData > 0) {
      _max = max;
      _min = min;
      _avg = avg / (_totalData - 1);
      _maxPL = plDiffMax;
      _minPL = plDiffMin;
    }
    else {
      _max = 0;
      _min = 0;
      _avg = 0;
      _maxPL = 0;
      _minPL = 0;
    }

    return true;
  }

  void _calculateMinMax() {
    // initialize all the max and min PL
    _max90 = double.negativeInfinity;
    _min90 = double.infinity;
    _maxDaily = double.negativeInfinity;
    _minDaily = double.infinity;
    _maxMonhtly = double.negativeInfinity;
    _minMonhtly = double.infinity;
    _maxYearly = double.negativeInfinity;
    _minYearly = double.infinity;

    // loop thru all the data to get the min and max for each list
    for (PerformanceData data in _perfData90D) {
      if (data.gain >= _max90) {
        _max90 = data.gain;
      }
      
      if (data.gain <= _min90) {
        _min90 = data.gain;
      }
    }

    for (PerformanceData data in _perfDataDaily) {
      if (data.gain >= _maxDaily) {
        _maxDaily = data.gain;
      }
      
      if (data.gain <= _minDaily) {
        _minDaily = data.gain;
      }
    }

    for (PerformanceData data in _perfDataMonhtly) {
      if (data.gain >= _maxMonhtly) {
        _maxMonhtly = data.gain;
      }
      
      if (data.gain <= _minMonhtly) {
        _minMonhtly = data.gain;
      }
    }

    for (PerformanceData data in _perfDataYearly) {
      if (data.gain >= _maxYearly) {
        _maxYearly = data.gain;
      }
      
      if (data.gain <= _minYearly) {
        _minYearly = data.gain;
      }
    }

    // check again to ensure all being set
    if (_max90 == double.negativeInfinity) {
      _max90 = 0;
    }
    if (_min90 == double.infinity) {
      _min90 = 0;
    }
    if (_maxDaily == double.negativeInfinity) {
      _maxDaily = 0;
    }
    if (_minDaily == double.infinity) {
      _minDaily = 0;
    }
    if (_maxMonhtly == double.negativeInfinity) {
      _maxMonhtly = 0;
    }
    if (_minMonhtly == double.infinity) {
      _minMonhtly = 0;
    }
    if (_maxYearly == double.negativeInfinity) {
      _maxYearly = 0;
    }
    if (_minYearly == double.infinity) {
      _minYearly = 0;
    }
  }

  void _calculateGainDifference() {
    // ensure that we have data first
    if (_perfData.isNotEmpty) {
      // compute array 0 and length-1 to get the gain difference
      _gainDifference = _perfData[_perfData.length-1].gain - _perfData[0].gain;
    }
    else {
      // if watchlist is empty, then defaulted to 0
      _gainDifference = 0;
    }
  }

  Future<void> _getIndexData() async {
    // ensure we have _perfDataDaily
    if (_perfDataDaily.isNotEmpty) {
      // show loading screen
      LoadingScreen.instance().show(context: context);

      await _indexAPI.getIndexPriceDate(
        _indexCompare.indexId,
        _perfDataDaily.first.date,
        _perfDataDaily.last.date
      ).then((resp) {
        _indexComparePrice = resp;
      },).onError((error, stackTrace) {
        debugPrint("Error: ${error.toString()}");
        debugPrintStack(stackTrace: stackTrace);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(createSnackBar(message: "Error when get index price"));
        }
      },).whenComplete(() {
        // remove the loading screen
        LoadingScreen.instance().hide();
      },);
    }
  }
}