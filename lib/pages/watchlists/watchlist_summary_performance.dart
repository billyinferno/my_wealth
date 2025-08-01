import 'dart:collection';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:intl/intl.dart';
import 'package:ionicons/ionicons.dart';
import 'package:my_wealth/_index.g.dart';

class SummaryPerformanceDataList {
  final DateTime date;
  final double pl;
  final Color plColor;
  final bool isPLMinMax;
  final double? diff;
  final Color diffColor;
  final bool isDiffMinMax;
  final double? percentage;

  const SummaryPerformanceDataList({
    required this.date,
    required this.pl,
    required this.plColor,
    required this.isPLMinMax,
    this.diff,
    required this.diffColor,
    required this.isDiffMinMax,
    this.percentage,
  });
}

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
  late String _perfSort;
  late List<SummaryPerformanceDataList> _perfDataSort;
  late List<PerformanceData> _perfData;
  late List<PerformanceData> _perfData90D;
  late List<PerformanceData> _perfDataDaily;
  late List<PerformanceData> _perfDataMonthly;
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
  late double _max90PL;
  late double _min90PL;
  late double _maxDaily;
  late double _minDaily;
  late double _maxDailyPL;
  late double _minDailyPL;
  late double _maxMonthly;
  late double _minMonthly;
  late double _maxMonthlyPL;
  late double _minMonthlyPL;
  late double _maxYearly;
  late double _minYearly;
  late double _maxYearlyPL;
  late double _minYearlyPL;
  late double _avg90;
  late double _avgDaily;
  late double _avgMonthly;
  late double _avgYearly;
  late double _maxPL;
  late double _minPL;

  late IndexModel _indexCompare;
  late String _indexCompareName;
  late List<IndexPriceModel> _indexComparePrice;
  late List<PerformanceData> _indexData;
  late List<PerformanceData> _indexData90D;
  late List<PerformanceData> _indexDataDaily;
  late List<PerformanceData> _indexDataMonthly;
  late List<PerformanceData> _indexDataYearly;

  late String _graphSelection;
  late DateFormat _dateFormat;
  late double _gainDifference;

  @override
  void initState() {
    super.initState();

    // init all the variables
    _totalDayGain = 0;
    _totalCost = 0;
    _totalValue = 0;
    _totalRealised = 0;
    _totalUnrealised = 0;
    _totalPotentialPL = 0;

    _perfData = [];
    _perfData90D = [];
    _perfDataDaily = [];
    _perfDataMonthly = [];
    _perfDataYearly = [];
    _gainDifference = 0;

    _indexData = [];
    _indexData90D = [];
    _indexDataDaily = [];
    _indexDataMonthly = [];
    _indexDataYearly = [];

    _indexCompareName = "";
    _indexComparePrice = [];

    // defaulted the graph selection into 90 day
    _graphSelection = '9';

    // default the sort as ASC
    _perfSort = "A";
    _perfDataSort = [];

    // defaulted the date format to dd/MM
    _dateFormat = Globals.dfddMM;

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
    return Scaffold(
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
    
                    _indexData.clear();
                    _indexData90D.clear();
                    _indexDataDaily.clear();
                    _indexDataMonthly.clear();
                    _indexDataYearly.clear();
                  });
                }
              });
            }),
            icon: const Icon(
              Ionicons.git_compare_outline,
              color: textPrimary,
            ),
          ),
          IconButton(
            onPressed: (() {
              setState(() {
                // check current _perfSort
                if (_perfSort == "A") {
                  _perfSort = "D";
                }
                else {
                  _perfSort = "A";
                }
    
                // just reverse the _perfDataSort
                _perfDataSort = _perfDataSort.reversed.toList();
              });
            }),
            icon: Icon(
              (_perfSort == "A" ? LucideIcons.arrow_up_a_z : LucideIcons.arrow_down_z_a),
              color: textPrimary,
            ),
          ),
          const SizedBox(width: 10,),
        ],
      ),
      body: MySafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            _summaryBoxInfo(),
            const SizedBox(height: 10,),
            SizedBox(
              width: double.infinity,
              child: CupertinoSegmentedControl(
                children: const {
                  "9": Text("90 Days"),
                  "d": Text("Daily"),
                  "m": Text("Monthly"),
                  "y": Text("Yearly"),
                },
                onValueChanged: ((value) {
                  String selectedValue = value.toString();
        
                  setState(() {
                    _graphSelection = selectedValue;
            
                    _changeGraphSelection();
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
                    child: InkWell(
                      onTap: (() {
                        // clear the compare
                        showCupertinoDialog(
                          context: context,
                          builder: ((BuildContext context) {
                            return CupertinoAlertDialog(
                              title: const Text("Clear Compare"),
                              content: Text("Do you want to clear comparison with $_indexCompareName?"),
                              actions: <CupertinoDialogAction>[
                                CupertinoDialogAction(
                                  onPressed: (() {
                                    // clear the _indexData
                                    _indexCompareName = "";
                                    _indexComparePrice.clear();
            
                                    _indexData.clear();
                                    _indexData90D.clear();
                                    _indexDataDaily.clear();
                                    _indexDataMonthly.clear();
                                    _indexDataYearly.clear();
            
                                    // remove the dialog
                                    Navigator.pop(context);
            
                                    // set state to rebuild the widget
                                    setState(() {
                                    });
                                  }),
                                  child: const Text(
                                    "Yes",
                                    style: TextStyle(
                                      color: textPrimary,
                                    ),
                                  )
                                ),
                                CupertinoDialogAction(
                                  onPressed: (() {
                                    // remove the dialog
                                    Navigator.pop(context);
                                  }),
                                  child: const Text("No")
                                ),
                              ],
                            );
                          })
                        );
                      }),
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(10, 2, 5, 2),
                        decoration: BoxDecoration(
                          color: accentDark,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              "Comparing with $_indexCompareName",
                              style: const TextStyle(
                                fontSize: 10,
                              ),
                            ),
                            const SizedBox(width: 5,),
                            const Icon(
                              Ionicons.close,
                              size: 10,
                              color: textPrimary,
                            ),
                          ],
                        ),
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
                      formatCurrency(
                        _gainDifference,
                        shorten: false,
                        decimalNum: 2
                      ),
                      style: const TextStyle(
                        fontSize: 10,
                      ),
                    )
                  )
                ],
              ),
            ),
            _showChart(),
            Container(
              decoration: const BoxDecoration(
                color: primaryDark,
                border: Border(
                  bottom: BorderSide(
                    color: primaryLight,
                    width: 1.0,
                    style: BorderStyle.solid,
                  ),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(5),
                    width: 100,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "DATE",
                          textAlign: TextAlign.center,
                          style: _smallFont,
                        ),
                        const SizedBox(width: 5,),
                        Icon(
                          (_perfSort == "A" ? Ionicons.arrow_up : Ionicons.arrow_down),
                          size: 10,
                          color: textPrimary,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(5),
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
                      child: Text(
                        "+/-",
                        textAlign: TextAlign.center,
                        style: _smallFont,
                      ),
                    ),
                  ),
                  Container(
                    width: 75,
                    padding: const EdgeInsets.all(5),
                    child: Text(
                      "%",
                      textAlign: TextAlign.center,
                      style: _smallFont,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _perfDataSort.length,
                physics: const AlwaysScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.all(5),
                        width: 100,
                        child: Text(
                          Globals.dfddMMyyyy.formatLocal(_perfDataSort[index].date),
                          textAlign: TextAlign.center,
                          style: _smallFont,
                        ),
                      ),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          color: (_perfDataSort[index].isPLMinMax ? _perfDataSort[index].plColor : Colors.transparent),
                          child: Text(
                            formatCurrency(
                              _perfDataSort[index].pl,
                              showDecimal: false,
                              shorten: false,
                              decimalNum: 0
                            ),
                            textAlign: TextAlign.center,
                            style: _smallFont.copyWith(
                              color: (_perfDataSort[index].isPLMinMax ? Colors.white : _perfDataSort[index].plColor),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          color: (_perfDataSort[index].isDiffMinMax ? _perfDataSort[index].diffColor : Colors.transparent),
                          child: Text(
                            formatCurrencyWithNull(
                              _perfDataSort[index].diff,
                              showDecimal: false,
                              shorten: false,
                              decimalNum: 0
                            ),
                            textAlign: TextAlign.center,
                            style: _smallFont.copyWith(
                              color: (_perfDataSort[index].isDiffMinMax ? Colors.white : _perfDataSort[index].diffColor),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      Container(
                        width: 75,
                        color: (_perfDataSort[index].isPLMinMax ? _perfDataSort[index].plColor : Colors.transparent),
                        padding: const EdgeInsets.all(5),
                        child: Text(
                          "${formatDecimalWithNull(
                            _perfDataSort[index].percentage,
                            times: 100,
                            decimal: 2
                          )}%",
                          textAlign: TextAlign.center,
                          style: _smallFont.copyWith(
                            color: (_perfDataSort[index].isPLMinMax ? Colors.white : _perfDataSort[index].plColor),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryBoxInfo() {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 10,
            color: riskColor(
              value: _totalValue,
              cost: _totalCost,
              riskFactor: _userInfo.risk
            ),
          ),
          Expanded(
            child: Container(
              color: primaryDark,
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
                      _rowItem(text: "AVERAGE (${_perfData.length})", value: _avg, needColor: true),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
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
        compare: _indexData,
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
            formatCurrency(
              value,
              decimalNum: 2
            ),
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
        _watchlistAPI.getWatchlistPerformanceSummary(
          type: 'reksadana'
        ).then((resp) {
          perfData['reksadana'] = resp;
        }),
        _watchlistAPI.getWatchlistPerformanceSummary(
          type: 'saham'
        ).then((resp) {
          perfData['saham'] = resp;
        }),
        _watchlistAPI.getWatchlistPerformanceSummary(
          type: 'gold'
        ).then((resp) {
          perfData['gold'] = resp;
        }),
        _watchlistAPI.getWatchlistPerformanceSummary(
          type: 'crypto'
        ).then((resp) {
          perfData['crypto'] = resp;
        }),
      ]).then((_) {
        // temporaty performance data map
        Map<DateTime, SummaryPerformanceModel> tmpSummaryPerfData = {};
        List<DateTime> listAllDates = [];
        List<DateTime> listDates = [];
        SummaryPerformanceModel tmpCurrentSummaryPerfModel;
        SummaryPerformanceModel tmpNextSummaryPerfModel;

        // loop thru all the perf data to get the dates
        perfData.forEach((key, data) {
          for(int i=0; i < data.length; i++) {
            listAllDates.add(data[i].plDate);
          }
        });
        // sort the dates so we can use it later when we want to generate the performance data
        listDates = LinkedHashSet<DateTime>.from(listAllDates).toList()..sort();

        // convert the performance data to map, so we can check whether the date is available or not?
        Map<DateTime, SummaryPerformanceModel> tmpPerfData = {};

        // loop thru all the perfData
        perfData.forEach((key, data) {
          // clear the map first before we add
          tmpPerfData.clear();

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
        Log.error(
          message: 'Error getting data from server',
          error: error,
          stackTrace: stackTrace,
        );
        throw Exception('Error when try to get the data from server');
      });
    }
    else {
      // perform get watchlist performance summary for specific type here
      await _watchlistAPI.getWatchlistPerformanceSummary(
        type: _args.type
      ).then((resp) {
        // copy the response to watchlist performance
        _summaryPerfData = resp; 
      }).onError((error, stackTrace) {
        Log.error(
          message: 'Error getting data from server',
          error: error,
          stackTrace: stackTrace,
        );
        throw Exception('Error when try to get the data from server');
      },);
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

    // now put all the entried on the monthly and yearly to the performance
    // data list for monthly and yearly.
    _perfDataMonthly = monthly.values.toList();
    _perfDataYearly = yearly.values.toList();

    // calculate the min max for each graph
    _calculateMinMax();

    // set which max and min data
    _changeGraphSelection();

    return true;
  }

  void _calculateMinMax() {
    // initialize all the max and min PL
    _max90 = double.negativeInfinity;
    _min90 = double.infinity;
    _max90PL = double.negativeInfinity;
    _min90PL = double.infinity;

    _maxDaily = double.negativeInfinity;
    _minDaily = double.infinity;
    _maxDailyPL = double.negativeInfinity;
    _minDailyPL = double.infinity;

    _maxMonthly = double.negativeInfinity;
    _minMonthly = double.infinity;
    _maxMonthlyPL = double.negativeInfinity;
    _minMonthlyPL = double.infinity;

    _maxYearly = double.negativeInfinity;
    _minYearly = double.infinity;
    _maxYearlyPL = double.negativeInfinity;
    _minYearlyPL = double.infinity;

    _avg90 = 0;
    _avgDaily = 0;
    _avgMonthly = 0;
    _avgYearly = 0;

    PerformanceData? prevData;
    double plDiff;

    // loop thru all the data to get the min and max for each list
    prevData = null;
    for (PerformanceData data in _perfData90D) {
      if (data.gain >= _max90) {
        _max90 = data.gain;
      }
      
      if (data.gain <= _min90) {
        _min90 = data.gain;
      }

      // check if prev data is null or not?
      if (prevData != null) {
        // check the pl diff
        plDiff = data.gain - prevData.gain;

        // check if this is more than current PL or not?
        if (_max90PL < plDiff) {
          _max90PL = plDiff;
        }
        if (_min90PL > plDiff) {
          _min90PL = plDiff;
        }

        _avg90 = _avg90 + plDiff;
      }
      // set current data as prev data
      prevData = data;
    }

    // calculate avg for 90d
    if (_perfData90D.length > 1) {
      _avg90 = (_avg90 / (_perfData90D.length - 1));
    }

    // set previous data into null before we start next data
    prevData = null;
    for (PerformanceData data in _perfDataDaily) {
      if (data.gain >= _maxDaily) {
        _maxDaily = data.gain;
      }
      
      if (data.gain <= _minDaily) {
        _minDaily = data.gain;
      }

      // check if prev data is null or not?
      if (prevData != null) {
        // check the pl diff
        plDiff = data.gain - prevData.gain;

        // check if this is more than current PL or not?
        if (_maxDailyPL < plDiff) {
          _maxDailyPL = plDiff;
        }
        if (_minDailyPL > plDiff) {
          _minDailyPL = plDiff;
        }

        _avgDaily = _avgDaily + plDiff;
      }
      // set current data as prev data
      prevData = data;
    }

    // calculate avg for daily
    if (_perfDataDaily.length > 1) {
      _avgDaily = (_avgDaily / (_perfDataDaily.length - 1));
    }

    // set previous data into null before we start next data
    prevData = null;
    for (PerformanceData data in _perfDataMonthly) {
      if (data.gain >= _maxMonthly) {
        _maxMonthly = data.gain;
      }
      
      if (data.gain <= _minMonthly) {
        _minMonthly = data.gain;
      }

      // check if prev data is null or not?
      if (prevData != null) {
        // check the pl diff
        plDiff = data.gain - prevData.gain;

        // check if this is more than current PL or not?
        if (_maxMonthlyPL < plDiff) {
          _maxMonthlyPL = plDiff;
        }
        if (_minMonthlyPL > plDiff) {
          _minMonthlyPL = plDiff;
        }

        _avgMonthly = _avgMonthly + plDiff;
      }
      // set current data as prev data
      prevData = data;
    }

    // calculate avg monthly
    if (_perfDataMonthly.length > 1) {
      _avgMonthly = (_avgMonthly / (_perfDataMonthly.length - 1));
    }

    // set previous data into null before we start next data
    prevData = null;
    for (PerformanceData data in _perfDataYearly) {
      if (data.gain >= _maxYearly) {
        _maxYearly = data.gain;
      }
      
      if (data.gain <= _minYearly) {
        _minYearly = data.gain;
      }

      // check if prev data is null or not?
      if (prevData != null) {
        // check the pl diff
        plDiff = data.gain - prevData.gain;

        // check if this is more than current PL or not?
        if (_maxYearlyPL < plDiff) {
          _maxYearlyPL = plDiff;
        }
        if (_minYearlyPL > plDiff) {
          _minYearlyPL = plDiff;
        }

        _avgYearly = _avgYearly + plDiff;
      }
      // set current data as prev data
      prevData = data;
    }

    // calculate avg monthly
    if (_perfDataYearly.length > 1) {
      _avgYearly = (_avgYearly / (_perfDataYearly.length - 1));
    }

    // check again to ensure all being set
    if (_max90 == double.negativeInfinity) {
      _max90 = 0;
    }
    if (_min90 == double.infinity) {
      _min90 = 0;
    }
    if (_max90PL == double.negativeInfinity) {
      _max90PL = 0;
    }
    if (_min90PL == double.infinity) {
      _min90PL = 0;
    }

    if (_maxDaily == double.negativeInfinity) {
      _maxDaily = 0;
    }
    if (_minDaily == double.infinity) {
      _minDaily = 0;
    }
    if (_maxDailyPL == double.negativeInfinity) {
      _maxDailyPL = 0;
    }
    if (_minDailyPL == double.infinity) {
      _minDailyPL = 0;
    }

    if (_maxMonthly == double.negativeInfinity) {
      _maxMonthly = 0;
    }
    if (_minMonthly == double.infinity) {
      _minMonthly = 0;
    }
    if (_maxMonthlyPL == double.negativeInfinity) {
      _maxMonthlyPL = 0;
    }
    if (_minMonthlyPL == double.infinity) {
      _minMonthlyPL = 0;
    }

    if (_maxYearly == double.negativeInfinity) {
      _maxYearly = 0;
    }
    if (_minYearly == double.infinity) {
      _minYearly = 0;
    }
    if (_maxYearlyPL == double.negativeInfinity) {
      _maxYearlyPL = 0;
    }
    if (_minYearlyPL == double.infinity) {
      _minYearlyPL = 0;
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
        indexID: _indexCompare.indexId,
        from: _perfDataDaily.first.date,
        to: _perfDataDaily.last.date
      ).then((resp) async {
        _indexComparePrice = resp;

        // generate the index performance data
        await _generateIndexPerformanceData();

        // once finished just set state so we can rebuild the page
        setState(() {
        });
      },).onError((error, stackTrace) {
        Log.error(
          message: 'Error getting index price',
          error: error,
          stackTrace: stackTrace,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(createSnackBar(message: "Error when get index price"));
        }
      },).whenComplete(() {
        // remove the loading screen
        LoadingScreen.instance().hide();
      },);
    }
  }

  Future<void> _generateIndexPerformanceData() async {
    // here we will need to generate the index performance data that we will
    // passed to performance data chart.

    // first let's convert the index price model from list to map
    Map<DateTime, double> indexPriceMap = {};

    // since index price should be sorted already from API, we can just loop
    // thru index price model, and add it to map
    for(IndexPriceModel dt in _indexComparePrice) {
      indexPriceMap[dt.indexPriceDate.toLocal()] = dt.indexPriceValue;
    }

    // once we generate the date, now we can create the index performance daily
    // data based on loop on the performance daily data, and look for the same
    // date on the index price map

    // first clear the data
    _indexDataDaily.clear();

    double gain;
    double total;
    double? previousTotal;

    // loop thru performance daily data to get the date
    for(PerformanceData dt in _perfDataDaily) {
      // check if date is in the index price or not?
      if (indexPriceMap.containsKey(dt.date)) {
        // create the performance data for this
        gain = 0;
        total = indexPriceMap[dt.date]!;

        // check if we can calculate the gain?
        if (previousTotal != null) {
          // calculate the gain
          gain = total - previousTotal;
        }

        // set previous total as current total
        previousTotal = total;

        // create the performance data for this
        PerformanceData pfData = PerformanceData(
          date: dt.date,
          gain: gain,
          total: total
        );

        // add this to the index data daily
        _indexDataDaily.add(pfData);
      }
      else {
        // in case we have value already, then just use the latest index data
        // daily
        if (_indexDataDaily.isNotEmpty) {
          // get the last data
          PerformanceData lastData = _indexDataDaily.last;
          
          // insert it again but with different date
          PerformanceData mockupData = PerformanceData(
            date: dt.date,
            gain: lastData.gain,
            total: lastData.total,
          );

          // add mockup data to the _indexDataDaily
          _indexDataDaily.add(mockupData);
        }
      }
    }

    // once we got the daily data, then we can do the 90d, monthly, and yearly
    _indexData90D.clear();
    _indexDataMonthly.clear();
    _indexDataYearly.clear();

    // temporary map for monthly and yearly
    Map<DateTime, PerformanceData> monthly = {};
    Map<DateTime, PerformanceData> yearly = {};
    DateTime dateHelper;
    
    for(int i=0; i<_indexDataDaily.length; i++) {
      if (i >= (_indexDataDaily.length - 90)) {
        _indexData90D.add(_indexDataDaily[i]);
      }

      // get the date time for monthly
      dateHelper = DateTime(_indexDataDaily[i].date.year, _indexDataDaily[i].date.month, 1);
      // add this on the monthly map
      monthly[dateHelper] = _indexDataDaily[i];

      // get the date time for yearly
      dateHelper = DateTime(_indexDataDaily[i].date.year, 12, 31);
      // add this on the yearly map
      yearly[dateHelper] = _indexDataDaily[i];
    }

    // once finished when we can put this on the _indexDataMonthly and
    // _indexDataYearly
    _indexDataMonthly = monthly.values.toList();
    _indexDataYearly = yearly.values.toList();

    // now check which graph now is being showed, so we can set the correct
    // index data
    switch(_graphSelection) {
      case "9":
        _indexData = _indexData90D.toList();
        break;
      case "m":
        _indexData = _indexDataMonthly.toList();
        break;
      case "y":
        _indexData = _indexDataYearly.toList();
        break;
      default:
        _indexData = _indexDataDaily.toList();
        break;
    }
  }

  void _generatePerfDataList() {
    double? plDiff;
    Color plDiffColor;
    Color plColor;
    bool isPLMinMax;
    bool isDiffMinMax;
    double? percentGain;
    double prevTotal = 1; // default to 1 so we can avoid divide by zero error
    
    // clear current perf data sort
    _perfDataSort.clear();

    for(int index=0; index<_perfData.length; index++) {
      // if index already more than 0, then we can use the previous total
      // otherwise we will use the prevTotal as 1, so we can avoid divide by
      // zero error
      if (index > 0) {
        // check if we have previous total or not?
        if (_perfData[index - 1].total > 0) {
          // set the prev total to the previous total
          prevTotal = _perfData[index - 1].total;
        }
        else {
          // if we don't have previous total, then just use the prevTotal
          // which is 1, so we can avoid divide by zero error
          prevTotal = 1;
        }
      }
      else {
        // if index is 0, then we will use the prevTotal as 1, so we can avoid
        // divide by zero error
        prevTotal = 1;
      }

      // default the diff color as text primary
      plDiffColor = textPrimary;
      plDiff = null;

      // calculate the performance data so we can put it on the list view
      // builder easier, without performing calcultion every list
      if (index > 0) {
        // get the pl diff with pl before and now
        plDiff = _perfData[index].gain - _perfData[index - 1].gain;

        // set the correct plDiffColor
        if (plDiff > 0) plDiffColor = Colors.green;
        if (plDiff < 0) plDiffColor = secondaryColor;
      }

      // check if this data is the same as _max or _min?
      plColor = (_perfData[index].gain == 0 ? textPrimary : (_perfData[index].gain < 0 ? secondaryColor : Colors.green));

      isPLMinMax = false;
      plColor = textPrimary;
      // only highlight if we still have total, otherwise it means that we already
      // sold all the investment, so no need to highlight.
      if (_perfData[index].total > 0) {
        if (_perfData[index].gain == _max || _perfData[index].gain == _min) {
          // means for this we will need to put color on the container instead of the text
          isPLMinMax = true;
          if (_perfData[index].gain == _max) {
            plColor = Colors.green[900]!;
          }
          if (_perfData[index].gain == _min) {
            plColor = secondaryDark;
          }
        }
      }

      isDiffMinMax = false;
      // only to highlight the pl diff if the pl diff min max is not 0
      if (plDiff != 0) {
        if (plDiff == _maxPL || plDiff == _minPL) {
          // means for this we will need to put color on the container instead of the text
          isDiffMinMax = true;
          plDiffColor = (plDiff! < 0 ? secondaryDark : Colors.green[900]!);
        }
      }

      percentGain = null;
      if (_perfData[index].total > 0) {
        percentGain = _perfData[index].gain / _perfData[index].total;
      }
      else {
        // if we don't have total, just use the previous total for the
        // percentage gain calculation
        percentGain = _perfData[index].gain / prevTotal;
      }

      SummaryPerformanceDataList data = SummaryPerformanceDataList(
        date: _perfData[index].date,
        pl: _perfData[index].gain,
        plColor: plColor,
        isPLMinMax: isPLMinMax,
        diff: plDiff,
        diffColor: plDiffColor, 
        isDiffMinMax: isDiffMinMax,
        percentage: percentGain,
      );

      // add the data to the _perfDataSort list
      _perfDataSort.add(data);
    }
  }

  void _changeGraphSelection() {
    switch(_graphSelection) {
      case "9":
        _perfData = _perfData90D.toList();
        _indexData = _indexData90D.toList();
        _dateFormat = Globals.dfddMM;
        _max = _max90;
        _min = _min90;
        _maxPL = _max90PL;
        _minPL = _min90PL;
        _avg = _avg90;
        break;
      case "m":
        _perfData = _perfDataMonthly.toList();
        _indexData = _indexDataMonthly.toList();
        _dateFormat = Globals.dfMMyy;
        _max = _maxMonthly;
        _min = _minMonthly;
        _maxPL = _maxMonthlyPL;
        _minPL = _minMonthlyPL;
        _avg = _avgMonthly;
        break;
      case "y":
        _perfData = _perfDataYearly.toList();
        _indexData = _indexDataYearly.toList();
        _dateFormat = Globals.dfMMyy;
        _max = _maxYearly;
        _min = _minYearly;
        _maxPL = _maxYearlyPL;
        _minPL = _minYearlyPL;
        _avg = _avgYearly;
        break;
      default:
        _perfData = _perfDataDaily.toList();
        _indexData = _indexDataDaily.toList();
        _dateFormat = Globals.dfddMM;
        _max = _maxDaily;
        _min = _minDaily;
        _maxPL = _maxDailyPL;
        _minPL = _minDailyPL;
        _avg = _avgDaily;
        break;
    }

    // generate the perf sort data based on the perf graph above
    _generatePerfDataList();

    // once generated then we can see whether this is sorted as Ascending or
    // descending?
    if (_perfSort == "D") {
      // reverse the _perfDataSort
      _perfDataSort = _perfDataSort.reversed.toList();
    }

    // calculate the gain difference
    _calculateGainDifference();
  }
}