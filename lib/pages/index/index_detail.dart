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
  late MinMaxDateModel _minMaxDate;

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
  late BodyPage _bodyPage;
  late int _numPrice;
  late double _minPrice;
  late double _maxPrice;
  late double _avgPrice;
  late ColumnType _columnType;
  late SortType _sortType;
  late int _userRisk;

  late String _mapSelection;
  late CompanyWeekdayPerformanceModel _weekdayPerformance;
  late DateTime _weekdayPerformanceDateFrom;
  late DateTime _weekdayPerformanceDateTo;
  late CompanyWeekdayPerformanceModel _monthlyPerformance;
  late DateTime _monthlyPerformanceDateFrom;
  late DateTime _monthlyPerformanceDateTo;
  late MyYearPickerCalendarType _calendarMonthlyType;
  late bool _calendarWeeklyRange;
  late DateTime _minPriceDate;

  @override
  void initState() {
    super.initState();

    _index = widget.index as IndexModel;
    _indexName = _index.indexName;

    // set the weekday performance start and end date as 180 days (around 6 month)
    _weekdayPerformanceDateTo = _index.indexLastUpdate;
    _weekdayPerformanceDateFrom = _weekdayPerformanceDateTo.subtract(Duration(days: 180));
    
    // set the monthly analysis date
    _monthlyPerformanceDateFrom = DateTime(_weekdayPerformanceDateTo.year, 1, 1);
    _monthlyPerformanceDateTo = DateTime(_weekdayPerformanceDateTo.year, 12, 31);

    // default the calendar type to single
    _calendarMonthlyType = MyYearPickerCalendarType.single;

    // default the weekly calendar to range instead year
    _calendarWeeklyRange = true;
    
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

    _bodyPage = BodyPage.table;
    _numPrice = 0;
    _mapSelection = "p";

    _showCurrentPriceComparison = false;

    // initialize seasonility with empty list
    _seasonality = [];

    // initialize sort as descending (latest date on top)
    _columnType = ColumnType.date;
    _sortType = SortType.descending;

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
        ),
        body: MySafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      color: _riskColor,
                      width: 10,
                    ),
                    Expanded(
                      child: Container(
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
                        _bodyPage = BodyPage.table;
                      });
                    }),
                    active: (_bodyPage == BodyPage.table),
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
                        _bodyPage = BodyPage.season;
                      });
                    }),
                    active: (_bodyPage == BodyPage.season),
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
                        _bodyPage = BodyPage.map;
                      });
                    }),
                    active: (_bodyPage == BodyPage.map),
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
                        _bodyPage = BodyPage.graph;
                      });
                    }),
                    active: (_bodyPage == BodyPage.graph),
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
      _indexApi.getIndexPriceMinMaxDate(
        companyId: _index.indexId
      ).then((resp) {
        _minMaxDate = resp;
        _minPriceDate = _minMaxDate.minDate;
      }),

      _getIndexPriceDate(),

      _indexApi.getSeasonality(id: _index.indexId).then((resp) {
        _seasonality = resp;
      }),

      _indexApi.getIndexWeekdayPerformance(
        id: _index.indexId,
        fromDate: _weekdayPerformanceDateFrom,
        toDate: _weekdayPerformanceDateTo,
      ).then((resp) {
        _weekdayPerformance = resp;
      }),

      _indexApi.getIndexMonthlyPerformance(
        id: _index.indexId,
        fromDate: _monthlyPerformanceDateFrom,
        toDate: _monthlyPerformanceDateTo,
      ).then((resp) {
        _monthlyPerformance = resp;
      }),
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

      // generate current graph data
      _generateIndexData();

      // generate heat map data
      _generateHeatMapGraphData();
    });
  }

  void _generateIndexData() {
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

      _graphData.add(
        GraphData(
          date: price.indexPriceDate.toLocal(),
          price: price.indexPriceValue
        )
      );
    }

    // check if we got > 0 num price or not?
    _numPrice = _indexPriceData[_currentIndexPrice]!.length;
    if (_numPrice > 0) {
      _avgPrice = totalPrice / _numPrice;
    }
    else {
      _numPrice = 1;
    }

    // generate the correct index price data
    _generateIndexPriceTable();
  }

  void _generateIndexPriceTable() {
    Color dayDiffColor;
    double dayDiff = 0;

    // clear the index price list
    _indexPriceList.clear();

    // loop for the correct index price data
    for(int i=0; i < _indexPriceData[_currentIndexPrice]!.length; i++) {
      dayDiffColor = Colors.transparent;
      if((i + 1) < _indexPriceData[_currentIndexPrice]!.length) {
        double? currDayPrice = _indexPriceData[_currentIndexPrice]![i].indexPriceValue;
        double? prevDayPrice = _indexPriceData[_currentIndexPrice]![i+1].indexPriceValue;
        dayDiff = (currDayPrice - prevDayPrice);
        dayDiffColor = riskColor(
          value: currDayPrice,
          cost: prevDayPrice,
          riskFactor: _userInfo!.risk
        );
      }

      _indexPriceList.add(IndexPriceModel(
        indexPriceDate: _indexPriceData[_currentIndexPrice]![i].indexPriceDate,
        indexPriceValue: _indexPriceData[_currentIndexPrice]![i].indexPriceValue,
        indexPriceDiff: _index.indexNetAssetValue - _indexPriceData[_currentIndexPrice]![i].indexPriceValue,
        indexDayDiff: dayDiff,
        indexColor: dayDiffColor,
      ));
    }

    // call sort info once finished
    _sortInfo();
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
      _heatMapGraphData[tempData[i].indexPriceDate.toLocal()] = GraphData(
        date: tempData[i].indexPriceDate.toLocal(),
        price: tempData[i].indexPriceValue,
      );
    }
  }

  Widget _detail() {
    switch(_bodyPage) {
      case BodyPage.table:
        return _showTable();
      case BodyPage.map:
        return _showCalendar();
      case BodyPage.graph:
        return _showGraph();
      case BodyPage.season:
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
                      _generateIndexData();
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
        SizedBox(
          width: double.infinity,
          child: CupertinoSegmentedControl<String>(
            children: const {
              "p": Text("Price"),
              "w": Text("Weekday"),
              "m": Text("Monthly"),
            },
            onValueChanged: ((value) {
              String selectedValue = value.toString();

              setState(() {
                _mapSelection = selectedValue;
              });
            }),
            groupValue: _mapSelection,
            selectedColor: secondaryColor,
            borderColor: secondaryDark,
            pressedColor: primaryDark,
          ),
        ),
        const SizedBox(height: 10,),
        Expanded(
          child: SingleChildScrollView(
            controller: _calendarScrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            child: _selectedMap(),
          ),
        )
      ],
    );
  }

  Widget _selectedMap() {
    switch(_mapSelection) {
      case "w":
        return Container(
          margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
          decoration: BoxDecoration(
            border: Border.all(
              color: primaryLight,
              width: 1.0,
              style: BorderStyle.solid,
            )
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 5,),
              Center(child: Text("Weekday Performance")),
              const SizedBox(height: 2,),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(width: 10,),
                  Expanded(
                    child: InkWell(
                      onTap: (() async {
                        // stored current from and to date
                        DateTime prevDateFrom = _weekdayPerformanceDateFrom;
                        DateTime prevDateTo = _weekdayPerformanceDateTo;
                    
                        // check for the max date to avoid any assertion that the initial date range
                        // is more than the lastDate
                        DateTime maxDate = _minMaxDate.maxDate.toLocal();
                        if (maxDate.isBefore(_weekdayPerformanceDateFrom.toLocal())) {
                          maxDate = _weekdayPerformanceDateFrom;
                        }
                        
                        if (_calendarWeeklyRange) {
                          DateTimeRange? result = await showDateRangePicker(
                            context: context,
                            firstDate: _minPriceDate.toLocal(),
                            lastDate: maxDate.toLocal(),
                            initialDateRange: DateTimeRange(
                              start: _weekdayPerformanceDateFrom.toLocal(),
                              end: _weekdayPerformanceDateTo.toLocal()
                            ),
                            confirmText: 'Done',
                            currentDate: _index.indexLastUpdate.toLocal(),
                            initialEntryMode: DatePickerEntryMode.calendarOnly,
                          );
                      
                          // check if we got the result or not?
                          if (result != null) {
                            // check whether the result start and end is different date, if different then we need to get new broker summary data.
                            if ((result.start.compareTo(_weekdayPerformanceDateFrom) != 0) ||
                                (result.end.compareTo(_weekdayPerformanceDateTo) != 0)) {
                              // set the weekday performance from and to date
                              _weekdayPerformanceDateFrom = result.start;
                              _weekdayPerformanceDateTo = result.end;
                      
                              // get the weekday performance
                              await _getWeekdayPerformance().onError((error, stackTrace) {
                                // if error then revert back the date
                                _weekdayPerformanceDateFrom = prevDateFrom;
                                _weekdayPerformanceDateTo = prevDateTo;
                      
                                // show error
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    createSnackBar(
                                      message: error.toString()
                                    )
                                  );
                                }
                              },);
                            }
                          }
                        }
                        else {
                          await showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text("Select Year"),
                                    IconButton(
                                    icon: Icon(
                                      Ionicons.close,
                                    ),
                                    onPressed: () {
                                      // remove the dialog
                                      Navigator.pop(context);
                                    },
                                  ),
                                  ],
                                ),
                                contentPadding: const EdgeInsets.all(10),
                                content: SizedBox(
                                  width: 300,
                                  height: 300,
                                  child: MyYearPicker(
                                    firstDate: _minPriceDate.toLocal(),
                                    lastDate: maxDate.toLocal(),
                                    startDate: _weekdayPerformanceDateFrom,
                                    endDate: _weekdayPerformanceDateTo,
                                    type: MyYearPickerCalendarType.range,
                                    onChanged: (value) async {
                                      Navigator.pop(context);
                      
                                      // check the new date whether it's same year or not?
                                      if (
                                        value.startDate.toLocal().year != _weekdayPerformanceDateFrom.year ||
                                        value.endDate.toLocal().year != _weekdayPerformanceDateTo.year
                                      ) {
                                        // not same year, set the current year to the monthly performance year
                                        _weekdayPerformanceDateFrom = value.startDate;
                                        _weekdayPerformanceDateTo = value.endDate;
                                      
                                        // get the weekday performance
                                        await _getWeekdayPerformance().onError((error, stackTrace) {
                                          // if error then revert back the date
                                          _weekdayPerformanceDateFrom = prevDateFrom;
                                          _weekdayPerformanceDateTo = prevDateTo;
                                
                                          // show error
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              createSnackBar(
                                                message: error.toString()
                                              )
                                            );
                                          }
                                        },);
                                      }
                                    }
                                  ),
                                ),
                              );
                            },
                          );
                        }
                      }),
                      child: Container(
                        color: Colors.transparent,
                        child: Center(
                          child: Text(
                            "${Globals.dfDDMMMyyyy.format(_weekdayPerformanceDateFrom)} - ${Globals.dfDDMMMyyyy.format(_weekdayPerformanceDateTo)}",
                            style: TextStyle(
                              color: secondaryLight,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 5,),
                  SizedBox(
                    height: 15,
                    width: 30,
                    child: Transform.scale(
                      scale: 0.5,
                      child: CupertinoSwitch(
                        value: _calendarWeeklyRange,
                        activeTrackColor: secondaryColor,
                        onChanged: (value) {
                          setState(() {
                            _calendarWeeklyRange = value;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 2,),
                  SizedBox(
                    width: 35,
                    child: Text(
                      (_calendarWeeklyRange ? "Day" : "Year"),
                      style: TextStyle(
                        fontSize: 10,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10,),
                ],
              ),
              WeekdayPerformanceChart(
                data: _weekdayPerformance,
              ),
            ],
          ),
        );
      case "m":
        return Container(
          margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
          decoration: BoxDecoration(
            border: Border.all(
              color: primaryLight,
              width: 1.0,
              style: BorderStyle.solid,
            )
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 5,),
              Center(child: Text("Monthly Performance")),
              const SizedBox(height: 2,),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: InkWell(
                      onTap: (() async {
                        // stored current from and to date
                        DateTime prevDateFrom = _monthlyPerformanceDateFrom;
                        DateTime prevDateTo = _monthlyPerformanceDateTo;

                        // check for the max date to avoid any assertion that the initial date range
                        // is more than the lastDate
                        DateTime maxDate = _minMaxDate.maxDate.toLocal();
                        if (maxDate.isBefore(_index.indexLastUpdate.toLocal())) {
                          maxDate = _index.indexLastUpdate;
                        }

                        await showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text("Select Year"),
                                  IconButton(
                                  icon: Icon(
                                    Ionicons.close,
                                  ),
                                  onPressed: () {
                                    // remove the dialog
                                    Navigator.pop(context);
                                  },
                                ),
                                ],
                              ),
                              contentPadding: const EdgeInsets.all(10),
                              content: SizedBox(
                                width: 300,
                                height: 300,
                                child: MyYearPicker(
                                  firstDate: _minPriceDate.toLocal(),
                                  lastDate: maxDate.toLocal(),
                                  startDate: _monthlyPerformanceDateFrom,
                                  endDate: _monthlyPerformanceDateTo,
                                  type: _calendarMonthlyType,
                                  onChanged: (value) async {
                                    Navigator.pop(context);
                    
                                    // check the new date whether it's same year or not?
                                    if (value.startDate.toLocal().year != _monthlyPerformanceDateFrom.year || value.endDate.toLocal().year != _monthlyPerformanceDateTo.year) {
                                      // not same year, set the current year to the monthly performance year
                                      _monthlyPerformanceDateFrom = value.startDate;
                                      _monthlyPerformanceDateTo = value.endDate;
                                    
                                      // get the monthly performance
                                      await _getMonthlyPerformance().onError((error, stackTrace) {
                                        // if error then revert back the date
                                        _monthlyPerformanceDateFrom = prevDateFrom;
                                        _monthlyPerformanceDateTo = prevDateTo;

                                        // show error
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            createSnackBar(
                                              message: error.toString()
                                            )
                                          );
                                        }
                                      },);
                                    }
                                  }
                                ),
                              ),
                            );
                          },
                        );
                      }),
                      child: Container(
                        width: double.infinity,
                        color: Colors.transparent,
                        child: Center(
                          child: Text(
                            (
                              "${_monthlyPerformanceDateFrom.year}${(
                                _monthlyPerformanceDateFrom.year != _monthlyPerformanceDateTo.year ?
                                " - ${_monthlyPerformanceDateTo.year}" :
                                ""
                              )}"
                            ),
                            style: TextStyle(
                              color: secondaryLight,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 5,),
                  FlipFlopSwitch<MyYearPickerCalendarType>(
                    initialKey: _calendarMonthlyType,
                    icons: const [
                      FlipFlopItem<MyYearPickerCalendarType>(key: MyYearPickerCalendarType.single, icon: LucideIcons.calendar_1),
                      FlipFlopItem<MyYearPickerCalendarType>(key: MyYearPickerCalendarType.range, icon: LucideIcons.calendar_range),
                    ],
                    onChanged: <MyYearPickerCalendarType>(value) {
                      setState(() {
                        _calendarMonthlyType = value;
                      });
                    },
                  ),
                  const SizedBox(width: 10,),
                ],
              ),
              WeekdayPerformanceChart(
                data: _monthlyPerformance,
                type: WeekdayPerformanceType.monthly,
              ),
            ],
          ),
        );
      default:
        return Container(
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
        );
    }
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
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _performSort(columnType: ColumnType.date);
                            });
                          },
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              const Text(
                                "Date",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Visibility(
                                visible: (_columnType == ColumnType.date),
                                child: const SizedBox(width: 5,),
                              ),
                              Visibility(
                                visible: (_columnType == ColumnType.date),
                                child: _sortIcon()
                              ),
                            ],
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
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _performSort(columnType: ColumnType.price);
                            });
                          },
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              const Text(
                                "Price",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.right,
                              ),
                              Visibility(
                                visible: (_columnType == ColumnType.price),
                                child: const SizedBox(width: 5,),
                              ),
                              Visibility(
                                visible: (_columnType == ColumnType.price),
                                child: _sortIcon()
                              ),
                            ],
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
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _performSort(columnType: ColumnType.diff);
                            });
                          },
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              const Align(
                                alignment: Alignment.centerRight,
                                child: Icon(
                                  Ionicons.swap_vertical,
                                  size: 16,
                                ),
                              ),
                              Visibility(
                                visible: (_columnType == ColumnType.diff),
                                child: const SizedBox(width: 5,),
                              ),
                              Visibility(
                                visible: (_columnType == ColumnType.diff),
                                child: _sortIcon()
                              ),
                            ],
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
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _performSort(columnType: ColumnType.diff);
                            });
                          },
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              const Align(
                                alignment: Alignment.centerRight,
                                child: Icon(
                                  Ionicons.pulse_outline,
                                  size: 16,
                                ),
                              ),
                              Visibility(
                                visible: (_columnType == ColumnType.gainloss),
                                child: const SizedBox(width: 5,),
                              ),
                              Visibility(
                                visible: (_columnType == ColumnType.gainloss),
                                child: _sortIcon()
                              ),
                            ],
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
              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: 10,
                      color: riskColor(
                        value: _index.indexNetAssetValue,
                        cost: _indexPriceList[index].indexPriceValue,
                        riskFactor: _userInfo!.risk
                      ),
                    ),
                    Expanded(
                      child: Container(
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
                                    formatCurrency(_indexPriceList[index].indexPriceDiff),
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
                                        color: _indexPriceList[index].indexColor,
                                        style: BorderStyle.solid,
                                      )
                                    )
                                  ),
                                  child: Text(
                                    formatCurrencyWithNull(_indexPriceList[index].indexDayDiff),
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

  Widget _sortIcon() {
    return Icon(
      (
        _sortType == SortType.ascending ?
        Ionicons.arrow_up :
        Ionicons.arrow_down
      ),
      size: 10,
      color: textPrimary,
    );
  }

  Future<void> _getWeekdayPerformance() async {
    // show loading screen
    LoadingScreen.instance().show(context: context);

    await _indexApi.getIndexWeekdayPerformance(
      id: _index.indexId,
      fromDate: _weekdayPerformanceDateFrom,
      toDate: _weekdayPerformanceDateTo,
    ).then((resp) {
      setState(() {
        _weekdayPerformance = resp;
      });
    }).onError((error, stackTrace) {
      // print the error
      Log.error(
        message: 'Error when try to get weekeday performance data from server',
        error: error,
        stackTrace: stackTrace,
      );

      // show error
      throw Exception('Error when try to get weekday performance from server');
    },).whenComplete(() {
      // remove the loading screen
      LoadingScreen.instance().hide();
    },);
  }

  Future<void> _getMonthlyPerformance() async {
    // show loading screen
    LoadingScreen.instance().show(context: context);

    await _indexApi.getIndexMonthlyPerformance(
      id: _index.indexId,
      fromDate: _monthlyPerformanceDateFrom,
      toDate: _monthlyPerformanceDateTo,
    ).then((resp) {
      setState(() {
        _monthlyPerformance = resp;
      });
    }).onError((error, stackTrace) {
      // print the error
      Log.error(
        message: 'Error when try to get monthly performance data from server',
        error: error,
        stackTrace: stackTrace,
      );

      // show error
      throw Exception('Error when try to get monthly performance from server');
    },).whenComplete(() {
      // remove the loading screen
      LoadingScreen.instance().hide();
    },);
  }

  void _performSort({required ColumnType columnType}) {
    if (_columnType == columnType) {
      if (_sortType == SortType.ascending) {
        _sortType = SortType.descending;
      }
      else {
        _sortType = SortType.ascending;
      }

      // just reverse the current list
      _indexPriceList = _indexPriceList.reversed.toList();
    }
    else {
      // set the correct column type
      _columnType = columnType;
      
      // call sort info to get the correct sort
      _sortInfo();
    }
  }

  void _sortInfo() {
    switch(_columnType) {
      case ColumnType.price:
        _indexPriceList.sort((a, b) => (a.indexPriceValue.compareTo(b.indexPriceValue)));
        break;
      case ColumnType.diff:
        _indexPriceList.sort((a, b) => (a.indexPriceDiff.compareTo(b.indexPriceDiff)));
        break;
      case ColumnType.gainloss:
        _indexPriceList.sort((a, b) => (a.indexDayDiff.compareTo(b.indexDayDiff)));
        break;
      default:
        _indexPriceList.sort((a, b) => (a.indexPriceDate.compareTo(b.indexPriceDate)));
        break;
    }

    // check if this is descending?
    if (_sortType == SortType.descending) {
      _indexPriceList = _indexPriceList.reversed.toList();
    }
  }
}