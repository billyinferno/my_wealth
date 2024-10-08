import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:ionicons/ionicons.dart';
import 'package:my_wealth/_index.g.dart';

class IndexDetailPage extends StatefulWidget {
  final Object? index;
  const IndexDetailPage({ super.key, required this.index });

  @override
  IndexDetailPageState createState() => IndexDetailPageState();
}

class IndexDetailPageState extends State<IndexDetailPage> {
  final IndexAPI _indexApi = IndexAPI();
  final ScrollController _scrollController = ScrollController();
  final ScrollController _calendarScrollController = ScrollController();
  final ScrollController _graphScrollController = ScrollController();

  late IndexModel _index;
  late UserLoginInfoModel? _userInfo;
  late String _indexName;

  late Future<bool> _getData;
  
  final Map<int, List<IndexPriceModel>> _indexPriceData = {};
  late List<IndexPriceModel> _indexPriceList;
  late int _currentIndexPrice;
  late List<GraphData> _graphData;
  late List<SeasonalityModel> _seasonality;
  final Map<DateTime, GraphData> _heatMapGraphData = {};

  double _priceDiff = 0;
  Color _riskColor = Colors.green;
  bool _showCurrentPriceComparison = false;
  int _bodyPage = 0;
  int _numPrice = 0;
  late double _minPrice;
  late double _maxPrice;
  late double _avgPrice;
  late bool _sortAsc;
  late int _userRisk;

  @override
  void initState() {
    super.initState();

    _index = widget.index as IndexModel;
    _indexName = _index.indexName;
    
    if (Globals.indexName.containsKey(_index.indexName)) {
      _indexName = "($_indexName) ${Globals.indexName[_indexName]}";
    }

    // default the index price data to 90 days
    _currentIndexPrice = 90;

    // clear both index price data and graphdata
    _graphData = [];
    _indexPriceData.clear();

    // initialize all the 30, 90, 180, and 365
    _indexPriceData[30] = [];
    _indexPriceData[60] = [];
    _indexPriceData[90] = [];
    _indexPriceData[180] = [];
    _indexPriceData[365] = [];

    // initialize the index price list
    _indexPriceList = [];

    _userInfo = UserSharedPreferences.getUserInfo();

    _priceDiff = _index.indexNetAssetValue - _index.indexPrevPrice;
    _riskColor = riskColor(
      value: _index.indexNetAssetValue,
      cost: _index.indexPrevPrice,
      riskFactor: _userInfo!.risk
    );

    // get the current user risk
    _userRisk = (_userInfo!.risk);

    _bodyPage = 0;
    _numPrice = 0;

    _showCurrentPriceComparison = false;

    // initialize seasonility with empty list
    _seasonality = [];

    // initialize sort as descending (latest date on top)
    _sortAsc = false;

    _getData = _getAllData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _graphScrollController.dispose();
    _calendarScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getData,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const CommonErrorPage(errorText: 'Unable to get index price data');
        }
        else if (snapshot.hasData) {
          return _body();
        }
        else {
          return const CommonLoadingPage();
        }
      },
    );
  }

  Widget blank() {
    return Container(
      color: primaryColor,
    );
  }

  Widget _body() {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(
              Ionicons.arrow_back,
            ),
            onPressed: (() {
              Navigator.pop(context);
            }),
          ),
          title: const Center(
            child: Text(
              "Index Detail",
              style: TextStyle(
                color: secondaryColor,
              ),
            ),
          ),
          actions: <Widget>[
            IconButton(
              onPressed: (() {
                setState(() {
                  _sortAsc = !_sortAsc;
                  _indexPriceList = _indexPriceList.reversed.toList();
                });
              }),
              icon: Icon(
                (
                  _sortAsc ?
                  LucideIcons.arrow_up_a_z :
                  LucideIcons.arrow_down_z_a
                )
              )
            ),
            const SizedBox(width: 10,),
        ],
        ),
        body: MySafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                color: _riskColor,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    const SizedBox(width: 10,),
                    Expanded(
                      child: Container(
                        color: primaryColor,
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              _indexName,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              formatCurrency(_index.indexNetAssetValue),
                              style: const TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Icon(
                                  (_priceDiff > 0 ? Ionicons.caret_up : Ionicons.caret_down),
                                  color: _riskColor,
                                ),
                                const SizedBox(width: 10,),
                                Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: _riskColor,
                                        width: 2.0,
                                        style: BorderStyle.solid,
                                      ),
                                    )
                                  ),
                                  child: Text(formatCurrency(_priceDiff)),
                                ),
                                Expanded(child: Container(),),
                                const Icon(
                                  Ionicons.time_outline,
                                  color: primaryLight,
                                ),
                                const SizedBox(width: 10,),
                                // ignore: unnecessary_null_comparison
                                Text(Globals.dfddMMyyyy.formatLocal(_index.indexLastUpdate)),
                              ],
                            ),
                            const SizedBox(height: 8,),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                CompanyInfoBox(
                                  header: "Daily",
                                  headerAlign: MainAxisAlignment.end,
                                  child: Text(
                                    "${formatDecimalWithNull(
                                      _index.indexDailyReturn,
                                      times: 100,
                                    )}%",
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                                const SizedBox(width: 10,),
                                CompanyInfoBox(
                                  header: "Weekly",
                                  headerAlign: MainAxisAlignment.end,
                                  child: Text(
                                    "${formatDecimalWithNull(
                                      _index.indexWeeklyReturn,
                                      times: 100
                                    )}%",
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                                const SizedBox(width: 10,),
                                CompanyInfoBox(
                                  header: "Monthly",
                                  headerAlign: MainAxisAlignment.end,
                                  child: Text(
                                    "${formatDecimalWithNull(
                                      _index.indexMonthlyReturn,
                                      times: 100
                                    )}%",
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3,),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                CompanyInfoBox(
                                  header: "MTD",
                                  headerAlign: MainAxisAlignment.end,
                                  child: Text(
                                    "${formatDecimalWithNull(
                                      _index.indexMtdReturn,
                                      times: 100
                                    )}%",
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                                const SizedBox(width: 10,),
                                CompanyInfoBox(
                                  header: "Monhtly",
                                  headerAlign: MainAxisAlignment.end,
                                  child: Text(
                                    "${formatDecimalWithNull(
                                      _index.indexMonthlyReturn,
                                      times: 100
                                    )}%",
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                                const SizedBox(width: 10,),
                                CompanyInfoBox(
                                  header: "Quarterly",
                                  headerAlign: MainAxisAlignment.end,
                                  child: Text(
                                    "${formatDecimalWithNull(
                                      _index.indexQuarterlyReturn,
                                      times: 100
                                    )}%",
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3,),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                CompanyInfoBox(
                                  header: "Semi Annual",
                                  headerAlign: MainAxisAlignment.end,
                                  child: Text(
                                    "${formatDecimalWithNull(
                                      _index.indexSemiAnnualReturn,
                                      times: 100
                                    )}%",
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                                const SizedBox(width: 10,),
                                CompanyInfoBox(
                                  header: "YTD",
                                  headerAlign: MainAxisAlignment.end,
                                  child: Text(
                                    "${formatDecimalWithNull(
                                      _index.indexYtdReturn,
                                      times: 100
                                    )}%",
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                                const SizedBox(width: 10,),
                                CompanyInfoBox(
                                  header: "Yearly",
                                  headerAlign: MainAxisAlignment.end,
                                  child: Text(
                                    "${formatDecimalWithNull(
                                      _index.indexYearlyReturn,
                                      times: 100
                                    )}%",
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3,),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                CompanyInfoBox(
                                  header: "Min ($_numPrice)",
                                  headerAlign: MainAxisAlignment.end,
                                  child: Text(
                                    formatCurrencyWithNull(_minPrice),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                                const SizedBox(width: 10,),
                                CompanyInfoBox(
                                  header: "Max ($_numPrice)",
                                  headerAlign: MainAxisAlignment.end,
                                  child: Text(
                                    formatCurrencyWithNull(_maxPrice),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                                const SizedBox(width: 10,),
                                CompanyInfoBox(
                                  header: "Avg ($_numPrice)",
                                  headerAlign: MainAxisAlignment.end,
                                  child: Text(
                                    formatCurrencyWithNull(_avgPrice),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
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
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(width: 10,),
                  TransparentButton(
                    text: "Table",
                    color: primaryDark,
                    borderColor: primaryLight,
                    icon: Ionicons.list_outline,
                    onTap: (() {
                      setState(() {
                        _bodyPage = 0;
                      });
                    }),
                    active: (_bodyPage == 0),
                    vertical: true,
                  ),
                  const SizedBox(width: 10,),
                  TransparentButton(
                    text: "Season",
                    color: primaryDark,
                    borderColor: primaryLight,
                    icon: Ionicons.rainy,
                    onTap: (() {
                      setState(() {
                        _bodyPage = 3;
                      });
                    }),
                    active: (_bodyPage == 3),
                    vertical: true,
                  ),
                  const SizedBox(width: 10,),
                  TransparentButton(
                    text: "Map",
                    color: primaryDark,
                    borderColor: primaryLight,
                    icon: Ionicons.calendar_clear_outline,
                    onTap: (() {
                      setState(() {
                        _bodyPage = 1;
                      });
                    }),
                    active: (_bodyPage == 1),
                    vertical: true,
                  ),
                  const SizedBox(width: 10,),
                  TransparentButton(
                    text: "Graph",
                    color: primaryDark,
                    borderColor: primaryLight,
                    icon: Ionicons.stats_chart_outline,
                    onTap: (() {
                      setState(() {
                        _bodyPage = 2;
                      });
                    }),
                    active: (_bodyPage == 2),
                    vertical: true,
                  ),
                  const SizedBox(width: 10,),
                ],
              ),
              const SizedBox(height: 10,),
              Expanded(child: _detail()),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _getAllData() async {
    await Future.wait([
      _getIndexPriceDate().then((_) {
        Log.success(message: "🏁 Get index price detail");
      }),

      _indexApi.getSeasonality(id: _index.indexId).then((resp) {
        Log.success(message: "🏁 Get index seasonility");

        _seasonality = resp;
      })
    ]).onError((error, stackTrace) {
      Log.error(
        message: 'Error getting index data',
        error: error,
        stackTrace: stackTrace,
      );
      throw Exception("Error when get indices price data");
    },);
    
    return true;
  }

  Future<void> _getIndexPriceDate() async {
    // get the 1 year, and from this we can generate the 30, 90, 180, 365
    DateTime oneYearAgo = DateTime.now().subtract(const Duration(days: 365));

    // get the data from API
    await _indexApi.getIndexPriceDate(
      indexID: _index.indexId,
      from: oneYearAgo.toLocal(),
      to: DateTime.now().toLocal()
    ).then((resp) {
      // clear the _indexPriceData first
      _indexPriceData.clear();

      // initialize all the 30, 90, 180, and 365
      _indexPriceData[30] = [];
      _indexPriceData[60] = [];
      _indexPriceData[90] = [];
      _indexPriceData[180] = [];
      _indexPriceData[365] = [];

      for (int i=0; i < resp.length; i++) {
        // add the 30 days
        if (i < 30) {
          _indexPriceData[30]!.add(resp[i]);
        }

        // add the 60 days
        if (i < 60) {
          _indexPriceData[60]!.add(resp[i]);
        }

        // add the 90 days
        if (i < 90) {
          _indexPriceData[90]!.add(resp[i]);
        }

        // add the 180 days
        if (i < 180) {
          _indexPriceData[180]!.add(resp[i]);
        }

        // add the 365 days
        _indexPriceData[365]!.add(resp[i]);
      }

      // copy the _indexPriceData[180] and put it on the list as we will
      // use this to display on the index price table
      _indexPriceList = _indexPriceData[180]!.toList();

      // generate current graph data
      _generateGraphData();

      // generate heat map data
      _generateHeatMapGraphData();
    });
  }

  void _generateGraphData() {
    // calculate the _min, _max, _avg, and _num price here
    double totalPrice = 0;

    // initialize the _min, _max, _avg, and _num price
    _numPrice = 0;
    _minPrice = _index.indexNetAssetValue;
    _maxPrice = _index.indexNetAssetValue;
    _avgPrice = _index.indexNetAssetValue;

    // clear graph data
    _graphData.clear();

    // loop thru current index in reverse
    for(IndexPriceModel price in (_indexPriceData[_currentIndexPrice] ?? []).toList().reversed) {
      if (_minPrice > price.indexPriceValue) {
        _minPrice = price.indexPriceValue;
      }

      if (_maxPrice < price.indexPriceValue) {
        _maxPrice = price.indexPriceValue;
      }

      totalPrice = totalPrice + price.indexPriceValue;

      _graphData.add(GraphData(date: price.indexPriceDate, price: price.indexPriceValue));
    }

    // check if we got > 0 num price or not?
    _numPrice = _indexPriceData[_currentIndexPrice]!.length;
    if (_numPrice > 0) {
      _avgPrice = totalPrice / _numPrice;
    }
    else {
      _numPrice = 1;
    }
  }

  void _generateHeatMapGraphData() {
    // get the price data we want to generate the graph
    List<IndexPriceModel> priceData = (_indexPriceData[90] ?? []);
    
    // copy the data to another list, so we will not change the list value
    List<IndexPriceModel> tempData = priceData.toList();
    // now sort the temp data
    tempData.sort((a, b) {
      return a.indexPriceDate.compareTo(b.indexPriceDate);
    });
    
    // clear the graph data
    _heatMapGraphData.clear();

    // loop thru price data and generate the graph data
    for(int i=0; i < tempData.length; i++) {
      _heatMapGraphData[tempData[i].indexPriceDate] = GraphData(
        date: tempData[i].indexPriceDate,
        price: tempData[i].indexPriceValue,
      );
    }
  }

  Widget _detail() {
    switch(_bodyPage) {
      case 0:
        return _showTable();
      case 1:
        return _showCalendar();
      case 2:
        return _showGraph();
      case 3:
        return _showSeasonality();
      default:
        return _showTable();
    }
  }

  Widget _showSeasonality() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text("Risk Percentage"),
            const SizedBox(width: 10,),
            SizedBox(
              width: 120,
              child: NumberStepper(
                initialRate: _userRisk,
                maxRate: 75,
                minRate: 5,
                ratePrefix: "%",
                bgColor: primaryColor,
                borderColor: primaryLight,
                textColor: Colors.white,
                onTap: ((value) {
                  setState(() {
                    _userRisk = value;
                  });
                }),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10,),
        Expanded(
          child: SeasonalityTable(
            data: _seasonality,
            risk: _userRisk,
          )
        ),
      ],
    );
  }

  Widget _showGraph() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        SingleChildScrollView(
          controller: _graphScrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                width: double.infinity,
                child: CupertinoSegmentedControl(
                  children: const {
                    30: Text("30D"),
                    60: Text("2M"),
                    90: Text("3M"),
                    180: Text("6M"),
                    365: Text("1Y"),
                  },
                  onValueChanged: ((value) {
                    setState(() {
                      _currentIndexPrice = value;
                      _generateGraphData();
                    });
                  }),
                  groupValue: _currentIndexPrice,
                  selectedColor: secondaryColor,
                  borderColor: secondaryDark,
                  pressedColor: primaryDark,
                ),
              ),
              const SizedBox(height: 5,),
              LineChart(
                data: _graphData,
                height: 250,
                dateOffset: (_graphData.length ~/ 9),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _showCalendar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: SingleChildScrollView(
            controller: _calendarScrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            child: Container(
              margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              decoration: BoxDecoration(
                border: Border.all(
                  color: primaryLight,
                  width: 1.0,
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(height: 5,),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Text("Current Price Comparison"),
                      const SizedBox(width: 10,),
                      CupertinoSwitch(
                        value: _showCurrentPriceComparison,
                        activeTrackColor: accentColor,
                        onChanged: ((val) {
                          setState(() {
                            _showCurrentPriceComparison = val;
                          });
                        })
                      )
                    ],
                  ),
                  const SizedBox(height: 5,),
                  HeatGraph(
                    data: _heatMapGraphData,
                    userInfo: _userInfo!,
                    currentPrice: _index.indexNetAssetValue,
                    enableDailyComparison: _showCurrentPriceComparison,
                  ),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _showTable() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            const SizedBox(width: 3,),
            Expanded(
              child: Container(
                color: primaryColor,
                padding: const EdgeInsets.all(10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      flex: 2,
                      child: Container(
                        height: 21,
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: primaryLight,
                              width: 1.0,
                              style: BorderStyle.solid,
                            )
                          )
                        ),
                        child: const Text(
                          "Date",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    ),
                    const SizedBox(width: 10,),
                    Expanded(
                      flex: 1,
                      child: Container(
                        height: 21,
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: primaryLight,
                              width: 1.0,
                              style: BorderStyle.solid,
                            )
                          )
                        ),
                        child: const Text(
                          "Price",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10,),
                    Expanded(
                      flex: 1,
                      child: Container(
                        height: 21,
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: primaryLight,
                              width: 1.0,
                              style: BorderStyle.solid,
                            )
                          )
                        ),
                        child: const Align(
                          alignment: Alignment.centerRight,
                          child: Icon(
                            Ionicons.swap_vertical,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10,),
                    Expanded(
                      flex: 1,
                      child: Container(
                        height: 21,
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: primaryLight,
                              width: 1.0,
                              style: BorderStyle.solid,
                            )
                          )
                        ),
                        child: const Align(
                          alignment: Alignment.centerRight,
                          child: Icon(
                            Ionicons.pulse_outline,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        Expanded(
          child: ListView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            children: List<Widget>.generate(_indexPriceList.length, (index) {
              double? dayDiff;
              Color dayDiffColor = Colors.transparent;
              if((index + 1) < _indexPriceList.length) {
                double? currDayPrice = _indexPriceList[index].indexPriceValue;
                double? prevDayPrice = _indexPriceList[index+1].indexPriceValue;
                dayDiff = (currDayPrice - prevDayPrice);
                dayDiffColor = riskColor(
                  value: currDayPrice,
                  cost: prevDayPrice,
                  riskFactor: _userInfo!.risk
                );
              }
              return Container(
                color: riskColor(
                  value: _index.indexNetAssetValue,
                  cost: _indexPriceList[index].indexPriceValue,
                  riskFactor: _userInfo!.risk
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    const SizedBox(width: 10,),
                    Expanded(
                      child: Container(
                        color: primaryColor,
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                              flex: 2,
                              child: Text(
                                Globals.dfddMMyyyy.formatLocal(_indexPriceList[index].indexPriceDate),
                                style: const TextStyle(
                                  fontSize: 12,
                                ),
                              )
                            ),
                            const SizedBox(width: 10,),
                            Expanded(
                              flex: 1,
                              child: Text(
                                formatCurrency(_indexPriceList[index].indexPriceValue),
                                style: const TextStyle(
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ),
                            const SizedBox(width: 10,),
                            Expanded(
                              flex: 1,
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        width: 2.0,
                                        color: riskColor(
                                          value: _index.indexNetAssetValue,
                                          cost: _indexPriceList[index].indexPriceValue,
                                          riskFactor: _userInfo!.risk
                                        ),
                                        style: BorderStyle.solid,
                                      )
                                    )
                                  ),
                                  child: Text(
                                    formatCurrency(_index.indexNetAssetValue - _indexPriceList[index].indexPriceValue),
                                    style: const TextStyle(
                                      fontSize: 12,
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10,),
                            Expanded(
                              flex: 1,
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        width: 2.0,
                                        color: dayDiffColor,
                                        style: BorderStyle.solid,
                                      )
                                    )
                                  ),
                                  child: Text(
                                    formatCurrencyWithNull(dayDiff),
                                    style: const TextStyle(
                                      fontSize: 12,
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        )
      ],
    );
  }
}