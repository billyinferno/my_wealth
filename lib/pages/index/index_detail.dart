import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ionicons/ionicons.dart';
import 'package:my_wealth/api/index_api.dart';
import 'package:my_wealth/model/index/index_model.dart';
import 'package:my_wealth/model/index/index_price_model.dart';
import 'package:my_wealth/model/user/user_login.dart';
import 'package:my_wealth/themes/colors.dart';
import 'package:my_wealth/utils/dialog/create_snack_bar.dart';
import 'package:my_wealth/utils/function/format_currency.dart';
import 'package:my_wealth/utils/function/risk_color.dart';
import 'package:my_wealth/utils/globals.dart';
import 'package:my_wealth/utils/loader/show_loader_dialog.dart';
import 'package:my_wealth/storage/prefs/shared_user.dart';
import 'package:my_wealth/widgets/list/company_info_box.dart';
import 'package:my_wealth/widgets/chart/heat_graph.dart';
import 'package:my_wealth/widgets/chart/line_chart.dart';
import 'package:my_wealth/widgets/components/transparent_button.dart';

class IndexDetailPage extends StatefulWidget {
  final Object? index;
  const IndexDetailPage({ Key? key, required this.index }) : super(key: key);

  @override
  IndexDetailPageState createState() => IndexDetailPageState();
}

class IndexDetailPageState extends State<IndexDetailPage> {
  final DateFormat _df = DateFormat('dd/MM/yyyy');
  final IndexAPI _indexApi = IndexAPI();
  final ScrollController _scrollController = ScrollController();
  final ScrollController _calendarScrollController = ScrollController();
  final ScrollController _graphScrollController = ScrollController();

  late IndexModel _index;
  late UserLoginInfoModel? _userInfo;
  late String _indexName;

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
    _indexName = _index.indexName;
    if (Globals.indexName.containsKey(_index.indexName)) {
      _indexName = "($_indexName) ${Globals.indexName[_indexName]}";
    }
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
                              Text(_df.format(_index.indexLastUpdate.toLocal())),
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
                                  "${formatDecimalWithNull(_index.indexDailyReturn, 100)}%",
                                  textAlign: TextAlign.right,
                                ),
                              ),
                              const SizedBox(width: 10,),
                              CompanyInfoBox(
                                header: "Weekly",
                                headerAlign: MainAxisAlignment.end,
                                child: Text(
                                  "${formatDecimalWithNull(_index.indexWeeklyReturn, 100)}%",
                                  textAlign: TextAlign.right,
                                ),
                              ),
                              const SizedBox(width: 10,),
                              CompanyInfoBox(
                                header: "Monthly",
                                headerAlign: MainAxisAlignment.end,
                                child: Text(
                                  "${formatDecimalWithNull(_index.indexMonthlyReturn, 100)}%",
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
                                  "${formatDecimalWithNull(_index.indexMtdReturn, 100)}%",
                                  textAlign: TextAlign.right,
                                ),
                              ),
                              const SizedBox(width: 10,),
                              CompanyInfoBox(
                                header: "Monhtly",
                                headerAlign: MainAxisAlignment.end,
                                child: Text(
                                  "${formatDecimalWithNull(_index.indexMonthlyReturn, 100)}%",
                                  textAlign: TextAlign.right,
                                ),
                              ),
                              const SizedBox(width: 10,),
                              CompanyInfoBox(
                                header: "Quarterly",
                                headerAlign: MainAxisAlignment.end,
                                child: Text(
                                  "${formatDecimalWithNull(_index.indexQuarterlyReturn, 100)}%",
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
                                  "${formatDecimalWithNull(_index.indexSemiAnnualReturn, 100)}%",
                                  textAlign: TextAlign.right,
                                ),
                              ),
                              const SizedBox(width: 10,),
                              CompanyInfoBox(
                                header: "YTD",
                                headerAlign: MainAxisAlignment.end,
                                child: Text(
                                  "${formatDecimalWithNull(_index.indexYtdReturn, 100)}%",
                                  textAlign: TextAlign.right,
                                ),
                              ),
                              const SizedBox(width: 10,),
                              CompanyInfoBox(
                                header: "Yearly",
                                headerAlign: MainAxisAlignment.end,
                                child: Text(
                                  "${formatDecimalWithNull(_index.indexYearlyReturn, 100)}%",
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
                  bgColor: primaryDark,
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
                  bgColor: primaryDark,
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
                  bgColor: primaryDark,
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
    await _indexApi.getIndexPrice(_index.indexId).then((resp) {
      _indexPrice = resp;

      // loop on the resp and put it on the graph
      List<GraphData> tempData = [];
      int totalData = 0;

      // initialize the minimum, maximum, and total price
      double totalPrice = 0;
      _minPrice = double.maxFinite;
      _maxPrice = double.minPositive;

      // just loop the last 64 data of the index, no need to care about the date
      // as it should be handle by the API call to select the data from the last date backward.
      for (int i = 0; i < resp.length; i++) {
        // add current index price to the temporary data
        tempData.add(GraphData(date: resp[i].indexPriceDate.toLocal(), price: resp[i].indexPriceValue));

        if(_numPrice < 29) {
          if(_minPrice! > resp[i].indexPriceValue) {
            _minPrice = resp[i].indexPriceValue;
          }
          if(_maxPrice! < resp[i].indexPriceValue) {
            _maxPrice = resp[i].indexPriceValue;
          }
          totalPrice += resp[i].indexPriceValue;
          _numPrice++;
        }

        // add total data, and if already 64 break the list
        totalData += 1;
        // check total data now
        if(totalData >= 64) {
          break;
        }
      }

      // add the current price which only in index
      tempData.add(GraphData(date: _index.indexLastUpdate.toLocal(), price: _index.indexNetAssetValue));

      // check the current price to min, max, and total
      if(_minPrice! > _index.indexNetAssetValue) {
        _minPrice = _index.indexNetAssetValue;
      }
      if(_maxPrice! < _index.indexNetAssetValue) {
        _maxPrice = _index.indexNetAssetValue;
      }
      totalPrice += _index.indexNetAssetValue;
      _numPrice++;

      // get average price
      _avgPrice = totalPrice / _numPrice;

      // once got the data now sort it
      tempData.sort((a, b) {
        return a.date.compareTo(b.date);
      });

      // once sorted, then we can put it on map
      for (GraphData data in tempData) {
        _graphData![data.date] = data;
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
    List<Widget> graph = [];

    graph.add(SingleChildScrollView(
      controller: _graphScrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      child: LineChart(
        data: _graphData!,
        height: 250,
      ),
    ));

    return graph;
  }

  List<Widget> _showCalendar() {
    List<Widget> calendar = [];

    calendar.add(Expanded(
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

    return calendar;
  }

  List<Widget> _showTable() {
    List<Widget> table = [];

    table.add(Row(
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
    ));

    table.add(Expanded(
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

    // add another spacer on the end
    table.add(const SizedBox(height: 30,));
    
    return table;
  }
}