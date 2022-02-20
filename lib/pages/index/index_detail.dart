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

  late IndexModel _index;
  late UserLoginInfoModel? _userInfo;

  double _priceDiff = 0;
  Color _riskColor = Colors.green;
  bool _isLoading = true;
  bool _isTable = true;
  List<IndexPriceModel> _indexPrice = [];
  Map<DateTime, GraphData> _graphData = {};

  @override
  void initState() {
    super.initState();
    _index = widget.index as IndexModel;
    _userInfo = UserSharedPreferences.getUserInfo();

    _priceDiff = _index.indexNetAssetValue - _index.indexPrevPrice;
    _riskColor = riskColor(_index.indexNetAssetValue, _index.indexPrevPrice, _userInfo!.risk);
    _indexPrice = [];

    _isLoading = true;
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
                      _isTable = true;
                    });
                  }),
                  active: (_isTable),
                ),
                const SizedBox(width: 10,),
                TransparentButton(
                  text: "Calendar",
                  icon: Ionicons.calendar_clear_outline,
                  callback: (() {
                    setState(() {
                      _isTable = false;
                    });
                  }),
                  active: (!_isTable),
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
      for (IndexPriceModel _price in resp) {
        _tempData.add(GraphData(date: _price.indexPriceDate.toLocal(), price: _price.indexPriceValue));
      }
      // add the current price which only in index
      _tempData.add(GraphData(date: _index.indexLastUpdate.toLocal(), price: _index.indexNetAssetValue));

      // once got the data now sort it
      _tempData.sort((a, b) {
        return a.date.compareTo(b.date);
      });

      for (GraphData _data in _tempData) {
        _graphData[_data.date] = _data;
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
    if(_isTable) {
      return _showTable();
    }
    else {
      return _showCalendar();
    }
  }

  List<Widget> _showCalendar() {
    List<Widget> _calendar = [];

    _calendar.add(Container(
      margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
      decoration: BoxDecoration(
        border: Border.all(
          color: primaryLight,
          width: 1.0,
          style: BorderStyle.solid,
        ),
      ),
      child: HeatGraph(
        data: _graphData,
        userInfo: _userInfo!
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