import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ionicons/ionicons.dart';
import 'package:my_wealth/api/index_api.dart';
import 'package:my_wealth/model/index_model.dart';
import 'package:my_wealth/model/index_price_model.dart';
import 'package:my_wealth/model/user_login.dart';
import 'package:my_wealth/themes/colors.dart';
import 'package:my_wealth/utils/dialog/create_snack_bar.dart';
import 'package:my_wealth/utils/function/format_currency.dart';
import 'package:my_wealth/utils/function/risk_color.dart';
import 'package:my_wealth/utils/loader/show_loader_dialog.dart';
import 'package:my_wealth/utils/prefs/shared_user.dart';
import 'package:my_wealth/widgets/company_info_box.dart';
import 'package:my_wealth/widgets/heat_graph.dart';
import 'package:my_wealth/widgets/line_chart.dart';
import 'package:my_wealth/widgets/transparent_button.dart';

class IndexDetailPage extends StatefulWidget {
  final Object? index;
  const IndexDetailPage({ Key? key, required this.index }) : super(key: key);

  @override
  _IndexDetailPageState createState() => _IndexDetailPageState();
}

class _IndexDetailPageState extends State<IndexDetailPage> {
  final DateFormat _df = DateFormat('dd/MM/yyyy');
  final IndexAPI _indexApi = IndexAPI();
  final ScrollController _scrollController = ScrollController();
  final ScrollController _calendarScrollController = ScrollController();
  final ScrollController _graphScrollController = ScrollController();

  late IndexModel _index;
  late UserLoginInfoModel? _userInfo;

  double _priceDiff = 0;
  Color _riskColor = Colors.green;
  bool _isLoading = true;
  bool _showCurrentPriceComparison = false;
  int _bodyPage = 0;
  List<IndexPriceModel> _indexPrice = [];
  Map<DateTime, GraphData>? _graphData;
  int _numPrice = 0;
  double? _minPrice;
  double? _maxPrice;
  double? _avgPrice;

  @override
  void initState() {
    super.initState();
    _index = widget.index as IndexModel;
    _userInfo = UserSharedPreferences.getUserInfo();

    _priceDiff = _index.indexNetAssetValue - _index.indexPrevPrice;
    _riskColor = riskColor(_index.indexNetAssetValue, _index.indexPrevPrice, _userInfo!.risk);
    _indexPrice = [];
    _bodyPage = 0;
    _numPrice = 0;

    _isLoading = true;
    _showCurrentPriceComparison = false;

    // initialize graph data
    _graphData = {};

    Future.microtask(() async {
      // show loader
      showLoaderDialog(context);
      await _getIndexPriceDetail().then((_) async {
        // await Future.delayed(const Duration(seconds: 3));
        debugPrint("🏁 Get index price detail");
      }).onError((error, stackTrace) {
        ScaffoldMessenger.of(context).showSnackBar(createSnackBar(message: error.toString()));
      }).whenComplete(() {
        // remove loader
        Navigator.pop(context);
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
    _graphScrollController.dispose();
    _calendarScrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if(_isLoading) {
      return blank();
    }
    else {
      return body();
    }
  }

  Widget blank() {
    return Container(
      color: primaryColor,
    );
  }

  Widget body() {
    return WillPopScope(
      onWillPop: (() async {
        return false;
      }),
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
        body: Column(
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
                            _index.indexName,
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
                              Text(_df.format(_index.indexLastUpdate.toLocal())),
                            ],
                          ),
                          const SizedBox(height: 20,),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              CompanyInfoBox(
                                header: "Daily",
                                headerAlign: TextAlign.right,
                                child: Text(
                                  formatDecimalWithNull(_index.indexDailyReturn, 100) + "%",
                                  textAlign: TextAlign.right,
                                ),
                              ),
                              const SizedBox(width: 10,),
                              CompanyInfoBox(
                                header: "Weekly",
                                headerAlign: TextAlign.right,
                                child: Text(
                                  formatDecimalWithNull(_index.indexWeeklyReturn, 100) + "%",
                                  textAlign: TextAlign.right,
                                ),
                              ),
                              const SizedBox(width: 10,),
                              CompanyInfoBox(
                                header: "Monthly",
                                headerAlign: TextAlign.right,
                                child: Text(
                                  formatDecimalWithNull(_index.indexMonthlyReturn, 100) + "%",
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
                                header: "MTD",
                                headerAlign: TextAlign.right,
                                child: Text(
                                  formatDecimalWithNull(_index.indexMtdReturn, 100) + "%",
                                  textAlign: TextAlign.right,
                                ),
                              ),
                              const SizedBox(width: 10,),
                              CompanyInfoBox(
                                header: "Monhtly",
                                headerAlign: TextAlign.right,
                                child: Text(
                                  formatDecimalWithNull(_index.indexMonthlyReturn, 100) + "%",
                                  textAlign: TextAlign.right,
                                ),
                              ),
                              const SizedBox(width: 10,),
                              CompanyInfoBox(
                                header: "Quarterly",
                                headerAlign: TextAlign.right,
                                child: Text(
                                  formatDecimalWithNull(_index.indexQuarterlyReturn, 100) + "%",
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
                                header: "Semi Annual",
                                headerAlign: TextAlign.right,
                                child: Text(
                                  formatDecimalWithNull(_index.indexSemiAnnualReturn, 100) + "%",
                                  textAlign: TextAlign.right,
                                ),
                              ),
                              const SizedBox(width: 10,),
                              CompanyInfoBox(
                                header: "YTD",
                                headerAlign: TextAlign.right,
                                child: Text(
                                  formatDecimalWithNull(_index.indexYtdReturn, 100) + "%",
                                  textAlign: TextAlign.right,
                                ),
                              ),
                              const SizedBox(width: 10,),
                              CompanyInfoBox(
                                header: "Yearly",
                                headerAlign: TextAlign.right,
                                child: Text(
                                  formatDecimalWithNull(_index.indexYearlyReturn, 100) + "%",
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
                                header: "Min (" + _numPrice.toString() + ")",
                                headerAlign: TextAlign.right,
                                child: Text(
                                  formatCurrencyWithNull(_minPrice),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                              const SizedBox(width: 10,),
                              CompanyInfoBox(
                                header: "Max (" + _numPrice.toString() + ")",
                                headerAlign: TextAlign.right,
                                child: Text(
                                  formatCurrencyWithNull(_maxPrice),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                              const SizedBox(width: 10,),
                              CompanyInfoBox(
                                header: "Avg (" + _numPrice.toString() + ")",
                                headerAlign: TextAlign.right,
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
                  icon: Ionicons.list_outline,
                  callback: (() {
                    setState(() {
                      _bodyPage = 0;
                    });
                  }),
                  active: (_bodyPage == 0),
                ),
                const SizedBox(width: 10,),
                TransparentButton(
                  text: "Map",
                  icon: Ionicons.calendar_clear_outline,
                  callback: (() {
                    setState(() {
                      _bodyPage = 1;
                    });
                  }),
                  active: (_bodyPage == 1),
                ),
                const SizedBox(width: 10,),
                TransparentButton(
                  text: "Graph",
                  icon: Ionicons.stats_chart_outline,
                  callback: (() {
                    setState(() {
                      _bodyPage = 2;
                    });
                  }),
                  active: (_bodyPage == 2),
                ),
                const SizedBox(width: 10,),
              ],
            ),
            const SizedBox(height: 10,),
            ..._detail(),
          ],
        ),
      ),
    );
  }

  Future<void> _getIndexPriceDetail() async {
    _indexApi.getIndexPrice(_index.indexId).then((resp) {
      _indexPrice = resp;

      // loop on the resp and put it on the graph
      List<GraphData> _tempData = [];
      int _totalData = 0;
      
      // move the last update to friday
      int _addDay = 5 - _index.indexLastUpdate.toLocal().weekday;
      DateTime _endDate = _index.indexLastUpdate.add(Duration(days: _addDay));

      // then go 14 weeks before so we knew the start date
      DateTime _startDate = _endDate.subtract(const Duration(days: 89)); // ((7*13) - 2), the 2 is because we end the day on Friday so no Saturday and Sunday.

      // initialize the minimum, maximum, and total price
      double _totalPrice = 0;
      _minPrice = double.maxFinite;
      _maxPrice = double.minPositive;
      for (IndexPriceModel _price in resp) {
        // ensure that this date is at least bigger than start date
        if(_price.indexPriceDate.compareTo(_startDate) >= 0) {
          _tempData.add(GraphData(date: _price.indexPriceDate.toLocal(), price: _price.indexPriceValue));

          // add total data, and if already 64 break the list
          _totalData += 1;
        }

        if(_numPrice < 29) {
          if(_minPrice! > _price.indexPriceValue) {
            _minPrice = _price.indexPriceValue;
          }
          if(_maxPrice! < _price.indexPriceValue) {
            _maxPrice = _price.indexPriceValue;
          }
          _totalPrice += _price.indexPriceValue;
          _numPrice++;
        }

        // check total data now
        if(_totalData >= 64) {
          break;
        }
      }

      // add the current price which only in index
      _tempData.add(GraphData(date: _index.indexLastUpdate.toLocal(), price: _index.indexNetAssetValue));

      // check the current price to min, max, and total
      if(_minPrice! > _index.indexNetAssetValue) {
        _minPrice = _index.indexNetAssetValue;
      }
      if(_maxPrice! < _index.indexNetAssetValue) {
        _maxPrice = _index.indexNetAssetValue;
      }
      _totalPrice += _index.indexNetAssetValue;
      _numPrice++;

      // get average price
      _avgPrice = _totalPrice / _numPrice;

      // once got the data now sort it
      _tempData.sort((a, b) {
        return a.date.compareTo(b.date);
      });

      // once sorted, then we can put it on map
      for (GraphData _data in _tempData) {
        _graphData![_data.date] = _data;
        // debugPrint(_data.date.toString());
      }
      // debugPrint("--- END OF SORTED DATA ---");
    }).whenComplete(() {
      // when finished then set the isLoading into false to loead the body
      _setIsLoading(false);
    });
  }

  void _setIsLoading(bool isLoading) {
    setState(() {
      _isLoading = isLoading;
    });
  }

  List<Widget> _detail() {
    switch(_bodyPage) {
      case 0:
        return _showTable();
      case 1:
        return _showCalendar();
      case 2:
        return _showGraph();
      default:
        return _showTable();
    }
  }

  List<Widget> _showGraph() {
    List<Widget> _graph = [];

    _graph.add(SingleChildScrollView(
      controller: _graphScrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      child: LineChart(
        data: _graphData!,
        height: 250,
      ),
    ));

    return _graph;
  }

  List<Widget> _showCalendar() {
    List<Widget> _calendar = [];

    _calendar.add(Expanded(
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
                data: _graphData!,
                userInfo: _userInfo!,
                currentPrice: _index.indexNetAssetValue,
                enableDailyComparison: _showCurrentPriceComparison,
              ),
            ],
          ),
        ),
      ),
    ));

    return _calendar;
  }

  List<Widget> _showTable() {
    List<Widget> _table = [];

    _table.add(Row(
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
                  child: Container(
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
    ));

    _table.add(Expanded(
      child: ListView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        children: List<Widget>.generate(_indexPrice.length, (index) {
          double? dayDiff;
          Color dayDiffColor = Colors.transparent;
          if((index + 1) < _indexPrice.length) {
            double? currDayPrice = _indexPrice[index].indexPriceValue;
            double? prevDayPrice = _indexPrice[index+1].indexPriceValue;
            dayDiff = (currDayPrice - prevDayPrice);
            dayDiffColor = riskColor(currDayPrice, prevDayPrice, _userInfo!.risk);
          }
          return Container(
            color: riskColor(_index.indexNetAssetValue, _indexPrice[index].indexPriceValue, _userInfo!.risk),
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
                            _df.format(_indexPrice[index].indexPriceDate.toLocal()),
                            style: const TextStyle(
                              fontSize: 12,
                            ),
                          )
                        ),
                        const SizedBox(width: 10,),
                        Expanded(
                          flex: 1,
                          child: Text(
                            formatCurrency(_indexPrice[index].indexPriceValue),
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
                                    color: riskColor(_index.indexNetAssetValue, _indexPrice[index].indexPriceValue, _userInfo!.risk),
                                    style: BorderStyle.solid,
                                  )
                                )
                              ),
                              child: Text(
                                formatCurrency(_index.indexNetAssetValue - _indexPrice[index].indexPriceValue),
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
                                (dayDiff == null ? "-" : formatCurrency(dayDiff)),
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
    ));
    
    return _table;
  }
}