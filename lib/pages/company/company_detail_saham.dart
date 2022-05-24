import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ionicons/ionicons.dart';
import 'package:my_wealth/api/company_api.dart';
import 'package:my_wealth/model/company_detail_model.dart';
import 'package:my_wealth/model/price_model.dart';
import 'package:my_wealth/model/user_login.dart';
import 'package:my_wealth/themes/colors.dart';
import 'package:my_wealth/utils/arguments/company_detail_args.dart';
import 'package:my_wealth/utils/function/format_currency.dart';
import 'package:my_wealth/utils/function/risk_color.dart';
import 'package:my_wealth/utils/loader/show_loader_dialog.dart';
import 'package:my_wealth/utils/prefs/shared_user.dart';
import 'package:my_wealth/widgets/company_detail_price_list.dart';
import 'package:my_wealth/widgets/company_info_box.dart';
import 'package:my_wealth/widgets/heat_graph.dart';
import 'package:my_wealth/widgets/line_chart.dart';
import 'package:my_wealth/widgets/transparent_button.dart';

class CompanyDetailSahamPage extends StatefulWidget {
  final Object? companyData;
  const CompanyDetailSahamPage({Key? key, required this.companyData}) : super(key: key);

  @override
  State<CompanyDetailSahamPage> createState() => _CompanyDetailSahamPageState();
}

class _CompanyDetailSahamPageState extends State<CompanyDetailSahamPage> {
  final ScrollController _scrollController = ScrollController();
  final ScrollController _calendarScrollController = ScrollController();
  final ScrollController _graphScrollController = ScrollController();

  late CompanyDetailArgs _companyData;
  late CompanyDetailModel _companyDetail;
  late UserLoginInfoModel? _userInfo;
  
  final CompanyAPI _companyApi = CompanyAPI();
  final DateFormat _df = DateFormat("dd/MM/yyyy");

  bool _isLoading = true;
  bool _showCurrentPriceComparison = false;
  Map<DateTime, GraphData>? _graphData;
  
  int _numPrice = 0;
  int _bodyPage = -1;

  double? _minPrice;
  double? _maxPrice;
  double? _avgPrice;

  @override
  void initState() {
    super.initState();

    // set that this is still loading
    _isLoading = true;

    // convert company arguments
    _companyData = widget.companyData as CompanyDetailArgs;

    // get user information
    _userInfo = UserSharedPreferences.getUserInfo();

    // initialize graph data
    _graphData = {};

    Future.microtask(() async {
      // show the loader dialog
      showLoaderDialog(context);
      // perform the get company detail information here
      await _companyApi.getCompanyDetail(_companyData.companyId, _companyData.type).then((resp) {
        // copy the response to company detail data
        _companyDetail = resp;
        
        // generate map data
        _generateGraphData(resp);        
      }).whenComplete(() {
        // once finished then remove the loader dialog
        Navigator.pop(context);
        _setIsLoading(false);
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
    _calendarScrollController.dispose();
    _graphScrollController.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return _generatePage();
  }

  Widget _generatePage() {
    if (_isLoading) {
      return Container(color: primaryColor,);
    }
    else {
      // generate the actual page
      return WillPopScope(
        onWillPop: (() async {
          return false;
        }),
        child: Scaffold(
          appBar: AppBar(
            title: const Center(
              child: Text(
                "Company Detail",
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
              Icon(
                (_companyData.companyFavourite ? Ionicons.star : Ionicons.star_outline),
                color: accentColor,
              ),
              const SizedBox(width: 20,),
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
                            Text(
                              (_companyDetail.companySymbol == null ? "" : "(" + _companyDetail.companySymbol! + ") ") + _companyData.companyName,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              _companyDetail.companyType,
                              style: const TextStyle(
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              formatCurrency(_companyDetail.companyNetAssetValue!),
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
                                  ((_companyDetail.companyNetAssetValue! - _companyDetail.companyPrevPrice!) > 0 ? Ionicons.caret_up : Ionicons.caret_down),
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
                            const SizedBox(height: 20,),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                CompanyInfoBox(
                                  header: "Volume",
                                  headerAlign: TextAlign.right,
                                  child: Text(
                                    formatCurrencyWithNull(_companyDetail.companyTotalUnit),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                                const SizedBox(width: 10,),
                                CompanyInfoBox(
                                  header: "Frequency",
                                  headerAlign: TextAlign.right,
                                  child: Text(
                                    formatIntWithNull(_companyDetail.companyFrequency),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                                const SizedBox(width: 10,),
                                CompanyInfoBox(
                                  header: "Market Cap",
                                  headerAlign: TextAlign.right,
                                  child: Text(
                                    formatIntWithNull(_companyDetail.companyMarketCap),
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
                                  header: "One Day",
                                  headerAlign: TextAlign.right,
                                  child: Text(
                                    formatDecimalWithNull(_companyDetail.companyDailyReturn, 100, 4) + "%",
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                                const SizedBox(width: 10,),
                                CompanyInfoBox(
                                  header: "One Week",
                                  headerAlign: TextAlign.right,
                                  child: Text(
                                    formatDecimalWithNull(_companyDetail.companyWeeklyReturn, 100, 4) + "%",
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                                const SizedBox(width: 10,),
                                CompanyInfoBox(
                                  header: "One Month",
                                  headerAlign: TextAlign.right,
                                  child: Text(
                                    formatDecimalWithNull(_companyDetail.companyMonthlyReturn, 100, 4) + "%",
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
                                  header: "Three Month",
                                  headerAlign: TextAlign.right,
                                  child: Text(
                                    formatDecimalWithNull(_companyDetail.companyQuarterlyReturn, 100, 4) + "%",
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                                const SizedBox(width: 10,),
                                CompanyInfoBox(
                                  header: "Six Month",
                                  headerAlign: TextAlign.right,
                                  child: Text(
                                    formatDecimalWithNull(_companyDetail.companySemiAnnualReturn, 100, 4) + "%",
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                                const SizedBox(width: 10,),
                                CompanyInfoBox(
                                  header: "One Year",
                                  headerAlign: TextAlign.right,
                                  child: Text(
                                    formatDecimalWithNull(_companyDetail.companyYearlyReturn, 100, 4) + "%",
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
                                  header: "Three Years",
                                  headerAlign: TextAlign.right,
                                  child: Text(
                                    formatDecimalWithNull(_companyDetail.companyThreeYear, 100, 4) + "%",
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                                const SizedBox(width: 10,),
                                CompanyInfoBox(
                                  header: "Five Years",
                                  headerAlign: TextAlign.right,
                                  child: Text(
                                    formatDecimalWithNull(_companyDetail.companyFiveYear, 100, 4) + "%",
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                                const SizedBox(width: 10,),
                                CompanyInfoBox(
                                  header: "Ten Years",
                                  headerAlign: TextAlign.right,
                                  child: Text(
                                    formatDecimalWithNull(_companyDetail.companyTenYear, 100, 4) + "%",
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
                                  headerAlign: TextAlign.right,
                                  child: Text(
                                    formatDecimalWithNull(_companyDetail.companyYtdReturn, 100, 4) + "%",
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                                const SizedBox(width: 10,),
                                CompanyInfoBox(
                                  header: "PER",
                                  headerAlign: TextAlign.right,
                                  child: Text(
                                    formatDecimalWithNull(_companyDetail.companyPer, 1, 4),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                                const SizedBox(width: 10,),
                                CompanyInfoBox(
                                  header: "PER Annual",
                                  headerAlign: TextAlign.right,
                                  child: Text(
                                    formatDecimalWithNull(_companyDetail.companyPerAnnualized, 1, 4),
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
                                  header: "PBR",
                                  headerAlign: TextAlign.right,
                                  child: Text(
                                    formatDecimalWithNull(_companyDetail.companyPbr, 1, 4),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                                const SizedBox(width: 10,),
                                CompanyInfoBox(
                                  header: "PSR Annual",
                                  headerAlign: TextAlign.right,
                                  child: Text(
                                    formatDecimalWithNull(_companyDetail.companyPsrAnnualized, 1, 4),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                                const SizedBox(width: 10,),
                                CompanyInfoBox(
                                  header: "PCFR Annual",
                                  headerAlign: TextAlign.right,
                                  child: Text(
                                    formatDecimalWithNull(_companyDetail.companyPcfrAnnualized, 1, 4),
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
                                    formatCurrencyWithNull(_minPrice!),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                                const SizedBox(width: 10,),
                                CompanyInfoBox(
                                  header: "Max (" + _numPrice.toString() + ")",
                                  headerAlign: TextAlign.right,
                                  child: Text(
                                    formatCurrencyWithNull(_maxPrice!),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                                const SizedBox(width: 10,),
                                CompanyInfoBox(
                                  header: "Avg (" + _numPrice.toString() + ")",
                                  headerAlign: TextAlign.right,
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
                  flex: 3,
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
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(width: 10,),
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
    ));

    _table.add(Expanded(
      child: ListView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        children: List<Widget>.generate(_companyDetail.companyPrices.length, (index) {
          double? dayDiff;
          Color dayDiffColor = Colors.transparent;
          if((index+1) < _companyDetail.companyPrices.length) {
            double currPrice = _companyDetail.companyPrices[index].priceValue;
            double prevPrice = _companyDetail.companyPrices[index + 1].priceValue;
            dayDiff = currPrice - prevPrice;
            dayDiffColor = riskColor(currPrice, prevPrice, _userInfo!.risk);
          }
          return CompanyDetailPriceList(
            date: _df.format(_companyDetail.companyPrices[index].priceDate.toLocal()),
            price: formatCurrency(_companyDetail.companyPrices[index].priceValue),
            diff: formatCurrency(_companyDetail.companyNetAssetValue! - _companyDetail.companyPrices[index].priceValue),
            riskColor: riskColor(_companyDetail.companyNetAssetValue!, _companyDetail.companyPrices[index].priceValue, _userInfo!.risk),
            dayDiff: (dayDiff == null ? "-" : formatCurrency(dayDiff)),
            dayDiffColor: dayDiffColor,
          );
        }),
      ),
    ));

    return _table;
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
                currentPrice: _companyDetail.companyNetAssetValue!,
                enableDailyComparison: _showCurrentPriceComparison,
              ),
            ],
          ),
        ),
      ),
    ));

    return _calendar;
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

  void _setIsLoading(bool val) {
    setState(() {
      _isLoading = val;
    });
  }

  void _generateGraphData(CompanyDetailModel data) {
    // map the price date on company
    List<GraphData> _tempData = [];
    int _totalData = 0;
    double _totalPrice = 0;
    int _totalPriceData = 0;

    _minPrice = double.maxFinite;
    _maxPrice = double.minPositive;

    // move the last update to friday
    int _addDay = 5 - data.companyLastUpdate!.toLocal().weekday;
    DateTime _endDate = data.companyLastUpdate!.add(Duration(days: _addDay));

    // then go 14 weeks before so we knew the start date
    DateTime _startDate = _endDate.subtract(const Duration(days: 89)); // ((7*13) - 2), the 2 is because we end the day on Friday so no Saturday and Sunday.

    // only get the 1st 64 data, since we will want to get the latest data
    for (PriceModel _price in data.companyPrices) {
      // ensure that all the data we will put is more than or equal with startdate
      if(_price.priceDate.compareTo(_startDate) >= 0) {
        _tempData.add(GraphData(date: _price.priceDate.toLocal(), price: _price.priceValue));
        _totalData += 1;
      }

      // count for minimum, maximum, and average
      if(_totalPriceData < 29) {
        if(_minPrice! > _price.priceValue) {
          _minPrice = _price.priceValue;
        }

        if(_maxPrice! < _price.priceValue) {
          _maxPrice = _price.priceValue;
        }

        _totalPrice += _price.priceValue;
        _totalPriceData++;
      }

      // if total data already more than 64 break  the data, as heat map only will display 65 data
      if(_totalData >= 64) {
        break;
      }
    }

    // add the current price which only in company
    _tempData.add(GraphData(date: data.companyLastUpdate!.toLocal(), price: data.companyNetAssetValue!));

    // check current price for minimum, maximum, and average
    if(_minPrice! > data.companyNetAssetValue!) {
      _minPrice = data.companyNetAssetValue!;
    }

    if(_maxPrice! < data.companyNetAssetValue!) {
      _maxPrice = data.companyNetAssetValue!;
    }

    _totalPrice += data.companyNetAssetValue!;
    _totalPriceData++;
    
    // compute average
    _avgPrice = _totalPrice / _totalPriceData;
    _numPrice = _totalPriceData;

    // sort the temporary data
    _tempData.sort((a, b) {
      return a.date.compareTo(b.date);
    });

    // once sorted, then we can put it on map
    for (GraphData _data in _tempData) {
      _graphData![_data.date] = _data;
    }
  }
}