import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ionicons/ionicons.dart';
import 'package:my_wealth/api/company_api.dart';
import 'package:my_wealth/api/price_api.dart';
import 'package:my_wealth/api/watchlist_api.dart';
import 'package:my_wealth/model/company/company_detail_model.dart';
import 'package:my_wealth/model/price/price_gold_model.dart';
import 'package:my_wealth/model/user/user_login.dart';
import 'package:my_wealth/model/watchlist/watchlist_detail_list_model.dart';
import 'package:my_wealth/themes/colors.dart';
import 'package:my_wealth/utils/function/binary_computation.dart';
import 'package:my_wealth/utils/function/format_currency.dart';
import 'package:my_wealth/utils/function/map_sorted.dart';
import 'package:my_wealth/utils/function/risk_color.dart';
import 'package:my_wealth/storage/prefs/shared_user.dart';
import 'package:my_wealth/widgets/page/common_error_page.dart';
import 'package:my_wealth/widgets/page/common_loading_page.dart';
import 'package:my_wealth/widgets/list/company_detail_price_list.dart';
import 'package:my_wealth/widgets/list/company_info_box.dart';
import 'package:my_wealth/widgets/chart/heat_graph.dart';
import 'package:my_wealth/widgets/chart/line_chart.dart';
import 'package:my_wealth/widgets/components/transparent_button.dart';

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

  final DateFormat _df = DateFormat("dd/MM/yyyy");
  final Bit _bitData = Bit();

  late DateTime _fromDate;
  late DateTime _toDate;

  final Map<int, List<PriceGoldModel>> _priceGoldData = {};
  late int _currentPriceGoldDay;
  late List<PriceGoldModel> _priceGold;

  late String _currentPriceCcy;
  
  bool _showCurrentPriceComparison = false;
  int _bodyPage = 0;
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

    _bodyPage = 0;
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

    // default the price ccy to IDR
    _currentPriceCcy = "IDR";

    // clear the heat map graph data
    _heatMapGraphData = {};

    _getData = _getInitData();
  }

  @override
  void dispose() {
    super.dispose();
    _summaryController.dispose();
    _priceController.dispose();
    _graphScrollController.dispose();
    _calendarScrollController.dispose();
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

    if ((_companyDetail.companyNetAssetValue! - _companyDetail.companyPrevPrice!) > 0) {
      currentIcon = Ionicons.caret_up;
    }
    else if ((_companyDetail.companyNetAssetValue! - _companyDetail.companyPrevPrice!) < 0) {
      currentIcon = Ionicons.caret_down;
    }
    
    return PopScope(
      canPop: false,
      child: Scaffold(
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
          actions: const <Widget>[
            Icon(
              Ionicons.star,
              color: accentColor,
            ),
            SizedBox(width: 20,),
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              color: riskColor(_companyDetail.companyNetAssetValue!, _companyDetail.companyPrevPrice!, _userInfo!.risk),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(width: 10,),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      color: primaryColor,
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
                                color: riskColor(_companyDetail.companyNetAssetValue!, _companyDetail.companyPrevPrice!, _userInfo!.risk),
                              ),
                              const SizedBox(width: 10,),
                              Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: riskColor(_companyDetail.companyNetAssetValue!, _companyDetail.companyPrevPrice!, _userInfo!.risk),
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
                              // ignore: unnecessary_null_comparison
                              Text((_companyDetail.companyLastUpdate! == null ? "-" : _df.format(_companyDetail.companyLastUpdate!.toLocal()))),
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
                  )
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
                  bgColor: primaryDark,
                  icon: Ionicons.speedometer_outline,
                  callback: (() {
                    setState(() {
                      _bodyPage = 0;
                    });
                  }),
                  active: (_bodyPage == 0),
                  vertical: true,
                ),
                const SizedBox(width: 10,),
                TransparentButton(
                  text: "Table",
                  bgColor: primaryDark,
                  icon: Ionicons.list_outline,
                  callback: (() {
                    setState(() {
                      _bodyPage = 1;
                    });
                  }),
                  active: (_bodyPage == 1),
                  vertical: true,
                ),
                const SizedBox(width: 10,),
                TransparentButton(
                  text: "Map",
                  bgColor: primaryDark,
                  icon: Ionicons.calendar_clear_outline,
                  callback: (() {
                    setState(() {
                      _bodyPage = 2;
                    });
                  }),
                  active: (_bodyPage == 2),
                  vertical: true,
                ),
                const SizedBox(width: 10,),
                TransparentButton(
                  text: "Graph",
                  bgColor: primaryDark,
                  icon: Ionicons.stats_chart_outline,
                  callback: (() {
                    setState(() {
                      _bodyPage = 3;
                    });
                  }),
                  active: (_bodyPage == 3),
                  vertical: true,
                ),
                const SizedBox(width: 10,),
              ],
            ),
            const SizedBox(height: 10,),
            _ccyStatSelection(),
            const SizedBox(height: 5,),
            Expanded(child: _detail()),
            const SizedBox(height: 30,),
          ],
        ),
      ),
    );
  }

  Widget _detail() {
    switch(_bodyPage) {
      case 0:
        return _showSummary();
      case 1:
        return _showTable();
      case 2:
        return _showCalendar();
      case 3:
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
        padding: const EdgeInsets.all(10),
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
                    "${formatDecimalWithNull(_companyDetail.companyDailyReturn, 100)}%",
                    textAlign: TextAlign.right,
                  ),
                ),
                const SizedBox(width: 10,),
                CompanyInfoBox(
                  header: "Weekly",
                  headerAlign: MainAxisAlignment.end,
                  child: Text(
                    "${formatDecimalWithNull(_companyDetail.companyWeeklyReturn, 100)}%",
                    textAlign: TextAlign.right,
                  ),
                ),
                const SizedBox(width: 5,),
                CompanyInfoBox(
                  header: "Monthly",
                  headerAlign: MainAxisAlignment.end,
                  child: Text(
                    "${formatDecimalWithNull(_companyDetail.companyMonthlyReturn, 100)}%",
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
                    "${formatDecimalWithNull(_companyDetail.companyYtdReturn, 100)}%",
                    textAlign: TextAlign.right,
                  ),
                ),
                const SizedBox(width: 10,),
                CompanyInfoBox(
                  header: "Yearly",
                  headerAlign: MainAxisAlignment.end,
                  child: Text(
                    "${formatDecimalWithNull(_companyDetail.companyYearlyReturn, 100)}%",
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
                padding: const EdgeInsets.all(10),
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
                        child: const Text(
                          "Date",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
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
                        child: const Text(
                          "Price",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.right,
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
                        child: const Align(
                          alignment: Alignment.centerRight,
                          child: Icon(
                            Ionicons.swap_vertical,
                            size: 16,
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
                        child: const Align(
                          alignment: Alignment.centerRight,
                          child: Icon(
                            Ionicons.pulse_outline,
                            size: 16,
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
          child: ListView(
            controller: _priceController,
            physics: const AlwaysScrollableScrollPhysics(),
            children: List<Widget>.generate(_priceGold.length, (index) {
              double? dayDiff;
              Color dayDiffColor = Colors.transparent;
              double currPrice;
              double prevPrice = 0;
              double priceDiff = 0;
              Color risk = Colors.white;

              // check which CCY we want to show
              if (_currentPriceCcy.toLowerCase() == 'idr') {
                currPrice = _priceGold[index].priceGoldIdr;
                if(index > 0) {
                  prevPrice = _priceGold[index-1].priceGoldIdr;
                }
                priceDiff = _companyDetail.companyNetAssetValue! - _priceGold[index].priceGoldIdr;
                risk = riskColor(_companyDetail.companyNetAssetValue!, _priceGold[index].priceGoldIdr, _userInfo!.risk);
              }
              else {
                currPrice = _priceGold[index].priceGoldUsd;
                if(index > 0) {
                  prevPrice = _priceGold[index-1].priceGoldUsd;
                }
                priceDiff = _companyDetail.companyCurrentPriceUsd! - _priceGold[index].priceGoldIdr;
                risk = riskColor(_companyDetail.companyCurrentPriceUsd!, _priceGold[index].priceGoldUsd, _userInfo!.risk);
              }

              // check if we have previous price or not?
              if((index+1) < _priceGold.length) {
                dayDiff = currPrice - prevPrice;
                dayDiffColor = riskColor(currPrice, prevPrice, _userInfo!.risk);
              }

              return CompanyDetailPriceList(
                date: _df.format(_priceGold[index].priceGoldDate.toLocal()),
                price: formatCurrency(currPrice, true),
                diff: formatCurrency(priceDiff, true),
                riskColor: risk,
                dayDiff: (dayDiff == null ? "-" : formatCurrency(dayDiff)),
                dayDiffColor: dayDiffColor,
              );
            }),
          ),
        ),
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
                        activeColor: accentColor,
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
            ),
          ),
        )
      ],
    );
  }

  Future<bool> _getInitData() async {
    try {
      await _companyApi.getCompanyDetail(-1, "gold").then((resp) {
        _companyDetail = resp;

        // calculate the from and to date that we need to get the gold price
        _toDate = (_companyDetail.companyLastUpdate ?? DateTime.now()).toLocal();
        _fromDate = _toDate.subtract(const Duration(days: 365)).toLocal();
      }).onError((error, stackTrace) {
        debugPrint("Error: ${error.toString()}");
        debugPrintStack(stackTrace: stackTrace);
        throw Exception("Error when get gold information");
      },);

      await Future.wait([
        _priceAPI.getGoldPrice(_fromDate, _toDate).then((resp) {
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
                date: resp[i].priceGoldDate, price: resp[i].priceGoldIdr
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

          _generateGraphData();
        }).onError((error, stackTrace) {
          debugPrint("Error: ${error.toString()}");
          debugPrintStack(stackTrace: stackTrace);
          throw Exception("Error when get price gold data");
        },),

        _watchlistAPI.findDetail(-1).then((resp) {
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
          debugPrint("Error: ${error.toString()}");
          debugPrintStack(stackTrace: stackTrace);
          throw Exception("Error when get gold watchlist data");
        },),
      ]).onError((error, stackTrace) {
        throw Exception('Error while getting data from server');
      });
    }
    catch(error) {
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
        _graphData.add(GraphData(date: price.priceGoldDate, price: price.priceGoldIdr));
      }
      else {
        _graphData.add(GraphData(date: price.priceGoldDate, price: price.priceGoldUsd));
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
}