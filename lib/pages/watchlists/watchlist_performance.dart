import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ionicons/ionicons.dart';
import 'package:my_wealth/_index.g.dart';

class WatchlistPerformancePage extends StatefulWidget {
  final Object? args;
  const WatchlistPerformancePage({super.key, required this.args});

  @override
  State<WatchlistPerformancePage> createState() => _WatchlistPerformancePageState();
}

class _WatchlistPerformancePageState extends State<WatchlistPerformancePage> {
  final TextStyle _smallFont = const TextStyle(fontSize: 10, color: textPrimary,);
  final WatchlistAPI _watchlistAPI = WatchlistAPI();
  final IndexAPI _indexAPI = IndexAPI();

  late WatchlistListArgs _watchlistArgs;
  late UserLoginInfoModel _userInfo;
  late WatchlistComputationResult _watchlistComputation;
  late Future<bool> _getData;
  late List<WatchlistPerformanceModel> _watchlistPerformance;
  late List<WatchlistPerformanceModel> _watchlistPerformance90Day;
  late List<WatchlistPerformanceModel> _watchlistPerformanceDaily;
  late List<WatchlistPerformanceModel> _watchlistPerformanceMonth;
  late List<WatchlistPerformanceModel> _watchlistPerformanceYear;

  late IndexModel _indexCompare;
  late String _indexCompareName;
  late List<IndexPriceModel> _indexComparePrice;
  late List<PerformanceData> _indexData;
  late List<PerformanceData> _indexData90D;
  late List<PerformanceData> _indexDataDaily;
  late List<PerformanceData> _indexDataMonthly;
  late List<PerformanceData> _indexDataYearly;

  late CompanyDetailArgs _companyArgs;
  late double _max;
  late double _min;
  late double _avg;
  late double _maxPL;
  late double _minPL;

  late double _max90;
  late double _min90;
  late double _max90PL;
  late double _min90PL;
  late double _avg90;
  late double _gainDiff90;
  late double _maxDaily;
  late double _minDaily;
  late double _maxDailyPL;
  late double _minDailyPL;
  late double _avgDaily;
  late double _gainDiffDaily;
  late double _maxMonthly;
  late double _minMonthly;
  late double _maxMonthlyPL;
  late double _minMonthlyPL;
  late double _avgMonthly;
  late double _gainDiffMonthly;
  late double _maxYearly;
  late double _minYearly;
  late double _maxYearlyPL;
  late double _minYearlyPL;
  late double _avgYearly;
  late double _gainDiffYearly;

  late String _graphSelection;
  late DateFormat _dateFormat;
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

    // get the computation for the watchlist
    _watchlistComputation = detailWatchlistComputation(watchlist: _watchlistArgs.watchList, riskFactor: _userInfo.risk);

    // assume max, min, and average is null
    _max = 0;
    _min = 0;
    _avg = 0;
    _maxPL = 0;
    _minPL = 0;

    // set the graph selection as "9" (90 days)
    _graphSelection = "9";
    _dateFormat = Globals.dfddMM;

    // initialize the result watchlist performance
    _watchlistPerformance = [];
    _watchlistPerformance90Day = [];
    _watchlistPerformanceDaily = [];
    _watchlistPerformanceMonth = [];
    _watchlistPerformanceYear = [];
    _gainDifference = 0;

    // initialize the index compare data
    _indexData = [];
    _indexData90D = [];
    _indexDataDaily = [];
    _indexDataMonthly = [];
    _indexDataYearly = [];

    _indexCompareName = "";
    _indexComparePrice = [];
    
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
            const SizedBox(height: 10,),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                const SizedBox(width: 10,),
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
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Container(
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
                    ),
                  ),
                ),
                const SizedBox(width: 10,),
              ],
            ),
            SizedBox(
              width: double.infinity,
              child: PerformanceChart(
                watchlistPerfData: _watchlistPerformance,
                watchlist: _watchlistArgs.watchList.watchlistDetail,
                compare: _indexData,
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
          ],
        ),
      ),
    );
  }

  Widget _summaryBoxInfo() {
    Icon iconPriceDiff = (
      _watchlistComputation.priceDiff == 0 ?
      const Icon(Ionicons.remove_outline, color: textPrimary, size: 15,) :
      (
        _watchlistComputation.priceDiff > 0 ?
        const Icon(Ionicons.caret_up, color: Colors.green, size: 12,) :
        const Icon(Ionicons.caret_down, color: secondaryColor, size: 12,)
      )
    );

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 10,
            color: _watchlistComputation.riskColor,
          ),
          Expanded(
            child: Container(
              color: primaryDark,
              padding: const EdgeInsets.all(10),
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
                            formatCurrencyWithNull(
                              _watchlistArgs.watchList.watchlistCompanyNetAssetValue,
                              shorten: false,
                              decimalNum: 2
                            ),
                          ),
                          const SizedBox(width: 5,),
                          iconPriceDiff,
                          const SizedBox(width: 5,),
                          Container(
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: (
                                    _watchlistComputation.priceDiff == 0 ? textPrimary :
                                    (
                                      _watchlistComputation.priceDiff > 0 ?
                                      Colors.green :
                                      secondaryColor
                                    )
                                  ),
                                  width: 2.0,
                                  style: BorderStyle.solid,
                                )
                              )
                            ),
                            child: Text(
                              formatCurrencyWithNull(
                                _watchlistComputation.priceDiff,
                                shorten: false,
                                decimalNum: 2
                              ),
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
                            Globals.dfddMMyyyy.formatDateWithNull(
                              _watchlistArgs.watchList.watchlistCompanyLastUpdate
                            ),
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
                      RowChild(
                        headerText: "AVG PRICE",
                        value: (
                          _watchlistComputation.totalCurrentShares > 0 ?
                          (_watchlistComputation.totalCost / _watchlistComputation.totalCurrentShares) :
                          null
                        )
                      ),
                      const SizedBox(width: 10,),
                      RowChild(
                        headerText: "COST",
                        value: _watchlistComputation.totalCost
                      ),
                      const SizedBox(width: 10,),
                      RowChild(
                        headerText: "VALUE",
                        value: _watchlistComputation.totalValue
                      ),
                    ],
                  ),
                  const SizedBox(height: 5,),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      RowChild(
                        headerText: "SHARES",
                        value: _watchlistComputation.totalCurrentShares
                      ),
                      const SizedBox(width: 10,),
                      RowChild(
                        headerText: "UNREALISED",
                        value: _watchlistComputation.totalUnrealisedGain,
                        autoColor: true,
                      ),
                      const SizedBox(width: 10,),
                      RowChild(
                        headerText: "REALISED",
                        value: _watchlistComputation.totalRealisedGain,
                        autoColor: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 5,),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      RowChild(
                        headerText: "MAX (${_watchlistPerformance.length})",
                        value: _max,
                        autoColor: true,
                      ),
                      const SizedBox(width: 10,),
                      RowChild(
                        headerText: "MIN (${_watchlistPerformance.length})",
                        value: _min,
                        autoColor: true,
                      ),
                      const SizedBox(width: 10,),
                      RowChild(
                        headerText: "AVERAGE (${_watchlistPerformance.length})",
                        value: _avg,
                        autoColor: true,
                      ),
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

  Future<bool> _getInitData() async {
    try {
      // perform the get company detail information here
      await _watchlistAPI.getWatchlistPerformance(
        type: _watchlistArgs.type,
        id: _watchlistArgs.watchList.watchlistId
      ).then((resp) {
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

        // get the maximum and minimum
        _calculateMinMax();

        // change the graph selection
        _changeGraphSelection();
      });
    }
    catch(error, stackTrace) {
      Log.error(
        message: 'Error getting data from server',
        error: error,
        stackTrace: stackTrace,
      );
      throw Exception('Error when try to get the data from server');
    }

    return true;
  }

  Future<void> _getIndexData() async {
    // ensure we have _perfDataDaily
    if (_watchlistPerformance.isNotEmpty) {
      // show loading screen
      LoadingScreen.instance().show(context: context);

      await _indexAPI.getIndexPriceDate(
        indexID: _indexCompare.indexId,
        from: _watchlistPerformance.first.buyDate,
        to: _watchlistPerformance.last.buyDate
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
    for(WatchlistPerformanceModel dt in _watchlistPerformanceDaily) {
      // check if date is in the index price or not?
      if (indexPriceMap.containsKey(dt.buyDate)) {
        // create the performance data for this
        gain = 0;
        total = indexPriceMap[dt.buyDate]!;

        // check if we can calculate the gain?
        if (previousTotal != null) {
          // calculate the gain
          gain = total - previousTotal;
        }

        // set previous total as current total
        previousTotal = total;

        // create the performance data for this
        PerformanceData pfData = PerformanceData(
          date: dt.buyDate,
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
            date: dt.buyDate,
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
  }

  (double, double, double, double, double, double) _calculateMinMaxData({
    required List<WatchlistPerformanceModel> watchlistData
  }) {
    double min = double.infinity;
    double max = double.negativeInfinity;
    double minPL = double.infinity;
    double maxPL = double.negativeInfinity;
    double avg = 0;
    double gainDifference = 0;
    double firstTotal = 0;
    double lastTotal = 0;
    double prevVal = 0;
    double currVal = 0;
    double currentPL;

    for(int i=0; i < watchlistData.length; i++) {
      currVal = (
        watchlistData[i].currentPrice *
        watchlistData[i].buyTotal
      ) - watchlistData[i].buyAmount;

      // check for data
      if (min > currVal) {
        min = currVal;
      }

      if (max < currVal) {
        max = currVal;
      }

      // for PL gain only do after index 1 on wards
      if (i > 0) {
        prevVal = (
          watchlistData[i-1].currentPrice *
          watchlistData[i-1].buyTotal
        ) - watchlistData[i-1].buyAmount;

        currentPL = currVal - prevVal;

        if (minPL > currentPL) {
          minPL = currentPL;
        }

        if (maxPL < currentPL) {
          maxPL = currentPL;
        }
      }
    }

    if (minPL == double.infinity) {
      minPL = min;
    }
    if (maxPL == double.negativeInfinity) {
      maxPL = max;
    }

    // at least have more than 1 data for the gain difference
    if ((watchlistData.length - 1) > 0) {
      // get the first total
      firstTotal = (
        watchlistData[0].currentPrice *
        watchlistData[0].buyTotal
      ) - watchlistData[0].buyAmount;

      // calculate the last total                      
      lastTotal = (
        watchlistData[(watchlistData.length-1)].currentPrice *
        watchlistData[watchlistData.length-1].buyTotal
      ) - watchlistData[watchlistData.length-1].buyAmount;

      gainDifference = lastTotal - firstTotal;
      avg = gainDifference / watchlistData.length;
    }
    else {
      gainDifference = (
        watchlistData[0].currentPrice *
        watchlistData[0].buyTotal
      ) - watchlistData[0].buyAmount;
      avg = gainDifference;
    }

    return (min, max, minPL, maxPL, avg, gainDifference);
  }

  void _calculateMinMax() {
    double min, max, minPL, maxPL, avg, gainDiff;

    // initialize all the max and min PL
    (min, max, minPL, maxPL, avg, gainDiff) = _calculateMinMaxData(watchlistData: _watchlistPerformance90Day);
    _min90 = min;
    _max90 = max;
    _min90PL = minPL;
    _max90PL = maxPL;
    _avg90 = avg;
    _gainDiff90 = gainDiff;

    (min, max, minPL, maxPL, avg, gainDiff) = _calculateMinMaxData(watchlistData: _watchlistPerformanceDaily);
    _minDaily = min;
    _maxDaily = max;
    _minDailyPL = minPL;
    _maxDailyPL = maxPL;
    _avgDaily = avg;
    _gainDiffDaily = gainDiff;

    (min, max, minPL, maxPL, avg, gainDiff) = _calculateMinMaxData(watchlistData: _watchlistPerformanceMonth);
    _minMonthly = min;
    _maxMonthly = max;
    _minMonthlyPL = minPL;
    _maxMonthlyPL = maxPL;
    _avgMonthly = avg;
    _gainDiffMonthly = gainDiff;

    (min, max, minPL, maxPL, avg, gainDiff) = _calculateMinMaxData(watchlistData: _watchlistPerformanceYear);
    _minYearly = min;
    _maxYearly = max;
    _minYearlyPL = minPL;
    _maxYearlyPL = maxPL;
    _avgYearly = avg;
    _gainDiffYearly = gainDiff;
  }

  void _changeGraphSelection() {
    switch(_graphSelection) {
      case "9":
        _max = _max90;
        _min = _min90;
        _avg = _avg90;
        _maxPL = _max90PL;
        _minPL = _min90PL;
        _gainDifference = _gainDiff90;
        _watchlistPerformance = _watchlistPerformance90Day.toList();
        _indexData = _indexData90D.toList();
        _dateFormat = Globals.dfddMM;
        break;
      case "m":
        _max = _maxMonthly;
        _min = _minMonthly;
        _avg = _avgMonthly;
        _maxPL = _maxMonthlyPL;
        _minPL = _minMonthlyPL;
        _gainDifference = _gainDiffMonthly;
        _watchlistPerformance = _watchlistPerformanceMonth.toList();
        _indexData = _indexDataMonthly.toList();
        _dateFormat = Globals.dfMMyy;
        break;
      case "y":
        _max = _maxYearly;
        _min = _minYearly;
        _avg = _avgYearly;
        _maxPL = _maxYearlyPL;
        _minPL = _minYearlyPL;
        _gainDifference = _gainDiffYearly;
        _watchlistPerformance = _watchlistPerformanceYear.toList();
        _indexData = _indexDataYearly.toList();
        _dateFormat = Globals.dfMMyy;
        break;
      default:
        _max = _maxDaily;
        _min = _minDaily;
        _avg = _avgDaily;
        _maxPL = _maxDailyPL;
        _minPL = _minDailyPL;
        _gainDifference = _gainDiffDaily;
        _watchlistPerformance = _watchlistPerformanceDaily.toList();
        _indexData = _indexDataDaily.toList();
        _dateFormat = Globals.dfddMM;
        break;
    }
  }
}
