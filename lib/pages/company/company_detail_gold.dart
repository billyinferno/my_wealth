import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:my_wealth/_index.g.dart';

class CompanyDetailGoldPage extends StatefulWidget {
  const CompanyDetailGoldPage({super.key});

  @override
  State<CompanyDetailGoldPage> createState() => _CompanyDetailGoldPageState();
}

class _CompanyDetailGoldPageState extends State<CompanyDetailGoldPage> {
  late CompanyDetailModel _companyDetail;
  late UserLoginInfoModel? _userInfo;
  late Map<DateTime, int> _watchlistDetail;
  late Future<bool> _getData;
  
  final ScrollController _summaryController = ScrollController();
  final ScrollController _priceController = ScrollController();
  final ScrollController _calendarScrollController = ScrollController();
  final ScrollController _graphScrollController = ScrollController();

  final CompanyAPI _companyApi = CompanyAPI();
  final WatchlistAPI _watchlistAPI = WatchlistAPI();
  final PriceAPI _priceAPI = PriceAPI();

  final Bit _bitData = Bit();

  late DateTime _fromDate;
  late DateTime _toDate;

  final Map<int, List<PriceGoldModel>> _priceGoldData = {};
  late int _currentPriceGoldDay;
  late List<PriceGoldModel> _priceGold;
  late Map<String, List<CompanyDetailList>> _priceGoldSortData;
  late List<CompanyDetailList> _priceGoldSort;
  late ColumnType _columnType;
  late SortType _sortType;

  late String _currentPriceCcy;
  
  bool _showCurrentPriceComparison = false;
  late BodyPage _bodyPage;
  late List<GraphData> _graphData;
  late Map<DateTime, GraphData> _heatMapGraphData;
  int _numPrice = 0;
  double? _minPrice;
  double? _maxPrice;
  double? _avgPrice;

  @override
  void initState() {
    super.initState();
    _showCurrentPriceComparison = false;

    _bodyPage = BodyPage.summary;
    _numPrice = 0;

    _userInfo = UserSharedPreferences.getUserInfo();

    // initialize graph data
    _graphData = [];

    // assuming we don't have any watchlist detail
    _watchlistDetail = {};

    // default the from and to date as today date
    _fromDate = _toDate = DateTime.now();

    // initialize the price gold map and list
    _priceGoldData.clear();
    _priceGoldData[30] = [];
    _priceGoldData[60] = [];
    _priceGoldData[90] = [];
    _priceGoldData[180] = [];
    _priceGoldData[365] = [];
    _currentPriceGoldDay = 90;

    _priceGold = [];

    // initialize the price gold sort and default the sort to Ascending
    _priceGoldSortData = {};
    _priceGoldSort = [];
    
    // default the column type to date, and sort type to descending
    _columnType = ColumnType.date;
    _sortType = SortType.descending;

    // default the price ccy to IDR
    _currentPriceCcy = "IDR";

    // clear the heat map graph data
    _heatMapGraphData = {};

    _getData = _getInitData();
  }

  @override
  void dispose() {
    _summaryController.dispose();
    _priceController.dispose();
    _graphScrollController.dispose();
    _calendarScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getData,
      builder: ((context, snapshot) {
        if (snapshot.hasError) {
          return const CommonErrorPage(errorText: 'Error loading gold data');
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
    IconData currentIcon = Ionicons.remove;
    Color priceColor = riskColor(
      value: _companyDetail.companyNetAssetValue!,
      cost: _companyDetail.companyPrevPrice!,
      riskFactor: _userInfo!.risk
    );

    if ((_companyDetail.companyNetAssetValue! - _companyDetail.companyPrevPrice!) > 0) {
      currentIcon = Ionicons.caret_up;
    }
    else if ((_companyDetail.companyNetAssetValue! - _companyDetail.companyPrevPrice!) < 0) {
      currentIcon = Ionicons.caret_down;
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            "Gold Detail",
            style: TextStyle(
              color: secondaryColor,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: (() async {
            Navigator.pop(context);
          }),
        ),
        actions: <Widget>[
          const Icon(
            Ionicons.star,
            color: accentColor,
          ),
          const SizedBox(width: 10,),
        ],
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
                    color: priceColor,
                    width: 10,
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          const Text(
                            "(XAU) Gold",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                formatCurrency(_companyDetail.companyNetAssetValue!),
                                style: const TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  height: 1.0,
                                ),
                              ),
                              const SizedBox(width: 10,),
                              Text(
                                "USD ${formatCurrency(_companyDetail.companyCurrentPriceUsd!)}",
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Icon(
                                currentIcon,
                                color: priceColor,
                              ),
                              const SizedBox(width: 10,),
                              Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: priceColor,
                                      width: 2.0,
                                      style: BorderStyle.solid,
                                    ),
                                  )
                                ),
                                child: Text(formatCurrency(_companyDetail.companyNetAssetValue! - _companyDetail.companyPrevPrice!)),
                              ),
                              Expanded(child: Container(),),
                              const Icon(
                                Ionicons.time_outline,
                                color: primaryLight,
                              ),
                              const SizedBox(width: 10,),
                              Text(
                                Globals.dfddMMyyyy.formatDateWithNull(
                                  _companyDetail.companyLastUpdate,
                                )
                              ),
                            ],
                          ),
                          const SizedBox(height: 10,),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              CompanyInfoBox(
                                header: "Min ($_numPrice)",
                                headerAlign: MainAxisAlignment.end,
                                child: Text(
                                  formatCurrencyWithNull(_minPrice!),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                              const SizedBox(width: 10,),
                              CompanyInfoBox(
                                header: "Max ($_numPrice)",
                                headerAlign: MainAxisAlignment.end,
                                child: Text(
                                  formatCurrencyWithNull(_maxPrice!),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                              const SizedBox(width: 10,),
                              CompanyInfoBox(
                                header: "Avg ($_numPrice)",
                                headerAlign: MainAxisAlignment.end,
                                child: Text(
                                  formatCurrencyWithNull(_avgPrice!),
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
                  text: "Info",
                  color: primaryDark,
                  borderColor: primaryLight,
                  icon: Ionicons.speedometer_outline,
                  onTap: (() {
                    setState(() {
                      _bodyPage = BodyPage.summary;
                    });
                  }),
                  active: (_bodyPage == BodyPage.summary),
                  vertical: true,
                ),
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
            _ccyStatSelection(),
            const SizedBox(height: 5,),
            Expanded(child: _detail()),
          ],
        ),
      ),
    );
  }

  Widget _detail() {
    switch(_bodyPage) {
      case BodyPage.summary:
        return _showSummary();
      case BodyPage.table:
        return _showTable();
      case BodyPage.map:
        return _showCalendar();
      case BodyPage.graph:
        return _showGraph();
      default:
        return _showTable();
    }
  }

  Widget _showSummary() {
    return SingleChildScrollView(
      controller: _summaryController,
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                CompanyInfoBox(
                  header: "Daily",
                  headerAlign: MainAxisAlignment.end,
                  child: Text(
                    "${formatDecimalWithNull(_companyDetail.companyDailyReturn, times: 100)}%",
                    textAlign: TextAlign.right,
                  ),
                ),
                const SizedBox(width: 10,),
                CompanyInfoBox(
                  header: "Weekly",
                  headerAlign: MainAxisAlignment.end,
                  child: Text(
                    "${formatDecimalWithNull(_companyDetail.companyWeeklyReturn, times: 100)}%",
                    textAlign: TextAlign.right,
                  ),
                ),
                const SizedBox(width: 5,),
                CompanyInfoBox(
                  header: "Monthly",
                  headerAlign: MainAxisAlignment.end,
                  child: Text(
                    "${formatDecimalWithNull(_companyDetail.companyMonthlyReturn, times: 100)}%",
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10,),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                CompanyInfoBox(
                  header: "YTD",
                  headerAlign: MainAxisAlignment.end,
                  child: Text(
                    "${formatDecimalWithNull(_companyDetail.companyYtdReturn, times: 100)}%",
                    textAlign: TextAlign.right,
                  ),
                ),
                const SizedBox(width: 10,),
                CompanyInfoBox(
                  header: "Yearly",
                  headerAlign: MainAxisAlignment.end,
                  child: Text(
                    "${formatDecimalWithNull(_companyDetail.companyYearlyReturn, times: 100)}%",
                    textAlign: TextAlign.right,
                  ),
                ),
                const SizedBox(width: 10,),
                const Expanded(child: SizedBox()),
              ],
            ),
          ],
        ),
      ),
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
            const SizedBox(width: 10,),
            Expanded(
              child: Container(
                color: primaryColor,
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      flex: 3,
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
                                textAlign: TextAlign.center,
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
                      ),
                    ),
                    const SizedBox(width: 10,),
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
                      )
                    ),
                    const SizedBox(width: 10,),
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
                      )
                    ),
                    const SizedBox(width: 10,),
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
                              _performSort(columnType: ColumnType.gainloss);
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
                      )
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        Expanded(
          child: ListView.builder(
            controller: _priceController,
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: _priceGoldSort.length,
            itemBuilder: (context, index) {
              return CompanyDetailPriceList(
                date: Globals.dfddMMyyyy.formatLocal(_priceGoldSort[index].date),
                price: formatCurrency(_priceGoldSort[index].price, checkThousand: true),
                diff: formatCurrency(_priceGoldSort[index].diff, checkThousand: true),
                riskColor: _priceGoldSort[index].riskColor,
                dayDiff: formatCurrencyWithNull(_priceGoldSort[index].dayDiff),
                dayDiffColor: _priceGoldSort[index].dayDiffColor,
              );
            },
          ),
        ),
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
                    currentPrice: _companyDetail.companyNetAssetValue!,
                    enableDailyComparison: _showCurrentPriceComparison,
                    weekend: true,
                  ),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _showGraph() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        const SizedBox(height: 10,),
        _dayStatSelection(),
        const SizedBox(height: 5,),
        Expanded(
          child: SingleChildScrollView(
            controller: _graphScrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            child: LineChart(
              data: _graphData,
              height: 250,
              watchlist: _watchlistDetail,
              dateOffset: (_priceGold.length ~/ 10),
              fillDate: true,
              onlyWeekday: false,
            ),
          ),
        )
      ],
    );
  }

  Future<bool> _getInitData() async {
    try {
      await _companyApi.getCompanyDetail(
        companyId: -1,
        type: "gold"
      ).then((resp) {
        _companyDetail = resp;

        // calculate the from and to date that we need to get the gold price
        _toDate = (_companyDetail.companyLastUpdate ?? DateTime.now()).toLocal();
        _fromDate = _toDate.subtract(const Duration(days: 365)).toLocal();
      }).onError((error, stackTrace) {
        Log.error(
          message: "Error when get gold information",
          error: error,
          stackTrace: stackTrace,
        );
        throw Exception("Error when get gold information");
      },);

      await Future.wait([
        _priceAPI.getGoldPrice(
          from: _fromDate,
          to: _toDate
        ).then((resp) {
          // clear the price gold map
          _priceGoldData.clear();
          _priceGoldData[30] = [];
          _priceGoldData[60] = [];
          _priceGoldData[90] = [];
          _priceGoldData[180] = [];
          _priceGoldData[365] = [];

          // clear the heat map graph data
          _heatMapGraphData.clear();

          // loop thru the response to populate the price gold map data
          for(int i=0; i<resp.length; i++) {
            if (i<30) {
              _priceGoldData[30]!.add(resp[i]);
            }

            if (i<60) {
              _priceGoldData[60]!.add(resp[i]);
            }

            if (i<90) {
              _priceGoldData[90]!.add(resp[i]);
              
              // since gold have weekend, then we can just generate the heat
              // graph data from 90 days
              _heatMapGraphData[resp[i].priceGoldDate] = GraphData(
                date: resp[i].priceGoldDate.toLocal(),
                price: resp[i].priceGoldIdr
              );
            }

            if (i<180) {
              _priceGoldData[180]!.add(resp[i]);
            }

            if (i<365) {
              _priceGoldData[365]!.add(resp[i]);
            }
          }

          // sorted based on the keys
          _heatMapGraphData = sortedMap<DateTime, GraphData>(data: _heatMapGraphData);

          _priceGold = (_priceGoldData[_currentPriceGoldDay] ?? []);

          // generate price gold sort
          _generateGoldSort();

          _generateGraphData();
        }).onError((error, stackTrace) {
          Log.error(
            message: "Error when get price gold data",
            error: error,
            stackTrace: stackTrace,
          );
          throw Exception("Error when get price gold data");
        },),

        _watchlistAPI.findDetail(companyId: -1).then((resp) {
          // if we got response then map it to the map, so later we can sent it
          // to the graph for rendering the time when we buy the share
          DateTime tempDate;
          for(WatchlistDetailListModel data in resp) {
            tempDate = data.watchlistDetailDate.toLocal();
            if (_watchlistDetail.containsKey(DateTime(tempDate.year, tempDate.month, tempDate.day))) {
              // if exists get the current value of the _watchlistDetails and put into _bitData
              _bitData.set(_watchlistDetail[DateTime(tempDate.year, tempDate.month, tempDate.day)]!);
              // check whether this is buy or sell
              if (data.watchlistDetailShare >= 0) {
                _bitData[15] = 1;
              }
              else {
                _bitData[14] = 1;
              }
              _watchlistDetail[DateTime(tempDate.year, tempDate.month, tempDate.day)] = _bitData.toInt();
            }
            else {
              if (data.watchlistDetailShare >= 0) {
                _watchlistDetail[DateTime(tempDate.year, tempDate.month, tempDate.day)] = 1;
              }
              else {
                _watchlistDetail[DateTime(tempDate.year, tempDate.month, tempDate.day)] = 2;
              }
            }
          }
        }).onError((error, stackTrace) {
          Log.error(
            message: "Error when get gold watchlist data",
            error: error,
            stackTrace: stackTrace,
          );
          throw Exception("Error when get gold watchlist data");
        },),
      ]).onError((error, stackTrace) {
        Log.error(
          message: 'Error while getting data from server',
          error: error,
          stackTrace: stackTrace,
        );
        throw Exception('Error while getting data from server');
      });
    }
    catch(error) {
      Log.error(
        message: 'Error when try to get the data from server',
        error: error,
      );
      throw 'Error when try to get the data from server';
    }

    return true;
  }

  Widget _dayStatSelection() {
    return SizedBox(
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
            _currentPriceGoldDay = value;
            _priceGold = _priceGoldData[_currentPriceGoldDay]!;

            _generateGoldSort();
            _generateGraphData();
          });
        }),
        groupValue: _currentPriceGoldDay,
        selectedColor: extendedColor,
        borderColor: Colors.transparent,
        pressedColor: textPrimary,
      ),
    );
  }

  Widget _ccyStatSelection() {
    return SizedBox(
      width: double.infinity,
      child: CupertinoSegmentedControl(
        children: const {
          "IDR": Text("IDR"),
          "USD": Text("USD"),
        },
        onValueChanged: ((value) {
          setState(() {
            _currentPriceCcy = value;
            
            // change the _priceGoldSort based on the selection
            _priceGoldSort = (_priceGoldSortData[_currentPriceCcy.toUpperCase()] ?? []);

            // call sort info to correctly sort the data
            _sortInfo();

            // generate graph data
            _generateGraphData();
          });
        }),
        groupValue: _currentPriceCcy,
        selectedColor: accentDark,
        borderColor: Colors.transparent,
        pressedColor: textPrimary,
      ),
    );
  }

  void _generateGraphData() {
    double totalPrice = 0;
    int totalPriceData = 0;
    _minPrice = _companyDetail.companyNetAssetValue;
    _maxPrice = _companyDetail.companyNetAssetValue;

    _graphData.clear();

    // loop the price gold data to generate graph data
    for (PriceGoldModel price in _priceGold.toList().reversed) {
      if(_minPrice! > price.priceGoldIdr) {
        _minPrice = price.priceGoldIdr;
      }

      if(_maxPrice! < price.priceGoldIdr) {
        _maxPrice = price.priceGoldIdr;
      }

      totalPrice += price.priceGoldIdr;
      totalPriceData++;

      // generate the graph data
      if (_currentPriceCcy.toLowerCase() == "idr") {
        _graphData.add(
          GraphData(
            date: price.priceGoldDate.toLocal(),
            price: price.priceGoldIdr
          )
        );
      }
      else {
        _graphData.add(
          GraphData(
            date: price.priceGoldDate.toLocal(),
            price: price.priceGoldUsd
          )
        );
      }
    }

    // compute average
    if (totalPriceData > 0) {
      _avgPrice = totalPrice / totalPriceData;
      _numPrice = totalPriceData;
    }
    else {
      _numPrice = 1;
    }
  }

  void _generateGoldSort() {
    double? dayDiff;
    Color dayDiffColor;
    double currPrice;
    double prevPrice;
    double priceDiff;
    Color risk;

    List<CompanyDetailList> priceIDR = [];
    List<CompanyDetailList> priceUSD = [];

    // clear current gold sort data
    _priceGoldSortData.clear();

    // loop thru price gold to generate the gold sort data
    for(int index=0; index < _priceGold.length; index++) {
      // generate IDR data first
      dayDiff = null;
      dayDiffColor = Colors.transparent;
      prevPrice = 0;
      priceDiff = 0;
      risk = Colors.white;

      currPrice = _priceGold[index].priceGoldIdr;
      if(index > 0) {
        prevPrice = _priceGold[index-1].priceGoldIdr;
      }
      priceDiff = _companyDetail.companyNetAssetValue! - _priceGold[index].priceGoldIdr;
      risk = riskColor(
        value: _companyDetail.companyNetAssetValue!,
        cost: _priceGold[index].priceGoldIdr,
        riskFactor: _userInfo!.risk
      );

      dayDiff = currPrice - prevPrice;
      dayDiffColor = riskColor(
        value: currPrice,
        cost: prevPrice,
        riskFactor: _userInfo!.risk
      );

      CompanyDetailList dataIDR = CompanyDetailList(
        date: _priceGold[index].priceGoldDate.toLocal(),
        price: currPrice,
        diff: priceDiff,
        riskColor: risk,
        dayDiff: dayDiff,
        dayDiffColor: dayDiffColor,
      );

      // add to IDR list
      priceIDR.add(dataIDR);

      // after that generate USD
      dayDiff = null;
      dayDiffColor = Colors.transparent;
      prevPrice = 0;
      priceDiff = 0;
      risk = Colors.white;

      currPrice = _priceGold[index].priceGoldUsd;
      if(index > 0) {
        prevPrice = _priceGold[index-1].priceGoldUsd;
      }
      priceDiff = _companyDetail.companyCurrentPriceUsd! - _priceGold[index].priceGoldUsd;
      risk = riskColor(
        value: _companyDetail.companyCurrentPriceUsd!,
        cost: _priceGold[index].priceGoldUsd,
        riskFactor: _userInfo!.risk
      );

      dayDiff = currPrice - prevPrice;
      dayDiffColor = riskColor(
        value: currPrice,
        cost: prevPrice,
        riskFactor: _userInfo!.risk
      );

      CompanyDetailList dataUSD = CompanyDetailList(
        date: _priceGold[index].priceGoldDate.toLocal(),
        price: currPrice,
        diff: priceDiff,
        riskColor: risk,
        dayDiff: dayDiff,
        dayDiffColor: dayDiffColor,
      );

      // add to USD list
      priceUSD.add(dataUSD);
    }

    // now add on the map for both IDR and USD
    _priceGoldSortData["IDR"] = priceIDR;
    _priceGoldSortData["USD"] = priceUSD;

    // set the current _priceGoldSort based on the currency
    _priceGoldSort = (_priceGoldSortData[_currentPriceCcy.toUpperCase()] ?? []);

    // call sort info
    _sortInfo();
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
      _priceGoldSort = _priceGoldSort.reversed.toList();
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
        _priceGoldSort.sort((a, b) => (a.price.compareTo(b.price)));
        break;
      case ColumnType.diff:
        _priceGoldSort.sort((a, b) => (a.diff.compareTo(b.diff)));
        break;
      case ColumnType.gainloss:
        _priceGoldSort.sort((a, b) => ((a.dayDiff ?? 0).compareTo((b.dayDiff ?? 0))));
        break;
      default:
        _priceGoldSort.sort((a, b) => (a.date.compareTo(b.date)));
        break;
    }

    // check if this is descending?
    if (_sortType == SortType.descending) {
      _priceGoldSort = _priceGoldSort.reversed.toList();
    }
  }
}