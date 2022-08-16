import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ionicons/ionicons.dart';
import 'package:my_wealth/api/broker_summary_api.dart';
import 'package:my_wealth/api/company_api.dart';
import 'package:my_wealth/api/info_fundamental_api.dart';
import 'package:my_wealth/api/info_sahams_api.dart';
import 'package:my_wealth/api/price_api.dart';
import 'package:my_wealth/api/watchlist_api.dart';
import 'package:my_wealth/model/broker_summary_date_model.dart';
import 'package:my_wealth/model/broker_summary_model.dart';
import 'package:my_wealth/model/company_detail_model.dart';
import 'package:my_wealth/model/company_top_broker_model.dart';
import 'package:my_wealth/model/info_fundamentals_model.dart';
import 'package:my_wealth/model/info_saham_price_model.dart';
import 'package:my_wealth/model/price_saham_ma_model.dart';
import 'package:my_wealth/model/user_login.dart';
import 'package:my_wealth/model/watchlist_detail_list_model.dart';
import 'package:my_wealth/themes/colors.dart';
import 'package:my_wealth/utils/arguments/broker_detail_args.dart';
import 'package:my_wealth/utils/arguments/company_detail_args.dart';
import 'package:my_wealth/utils/dialog/create_snack_bar.dart';
import 'package:my_wealth/utils/dialog/show_info_dialog.dart';
import 'package:my_wealth/utils/function/format_currency.dart';
import 'package:my_wealth/utils/function/risk_color.dart';
import 'package:my_wealth/utils/loader/show_loader_dialog.dart';
import 'package:my_wealth/utils/prefs/shared_user.dart';
import 'package:my_wealth/widgets/company_info_box.dart';
import 'package:my_wealth/widgets/heat_graph.dart';
import 'package:my_wealth/widgets/line_chart.dart';
import 'package:my_wealth/widgets/stock_candlestick_painter.dart';
import 'package:my_wealth/widgets/stock_volume_painter.dart';
import 'package:my_wealth/widgets/transparent_button.dart';

class CompanyDetailSahamPage extends StatefulWidget {
  final Object? companyData;
  const CompanyDetailSahamPage({Key? key, required this.companyData}) : super(key: key);

  @override
  State<CompanyDetailSahamPage> createState() => _CompanyDetailSahamPageState();
}

class _CompanyDetailSahamPageState extends State<CompanyDetailSahamPage> with SingleTickerProviderStateMixin {
  final ScrollController _infoController = ScrollController();
  final ScrollController _brokerController = ScrollController();
  final ScrollController _priceController = ScrollController();
  final ScrollController _calendarScrollController = ScrollController();
  final ScrollController _graphScrollController = ScrollController();
  final ScrollController _chipController = ScrollController();
  final ScrollController _fundamentalController = ScrollController();
  final ScrollController _fundamentalItemController = ScrollController();
  late TabController _tabController;

  late CompanyDetailArgs _companyData;
  late CompanyDetailModel _companyDetail;
  late UserLoginInfoModel? _userInfo;
  late BrokerSummaryModel _brokerSummary;
  late CompanyTopBrokerModel _topBroker;
  late BrokerSummaryBuySellModel _brokerSummaryBuySell;
  late BrokerSummaryDateModel _brokerSummaryDate;
  late PriceSahamMovingAverageModel _priceMA;
  late List<InfoFundamentalsModel> _infoFundamental;
  late List<InfoSahamPriceModel> _infoSahamPrice;
  late String _brokerSummarySelected;
  late Map<DateTime, double> _watchlistDetail;

  final CompanyAPI _companyApi = CompanyAPI();
  final BrokerSummaryAPI _brokerSummaryAPI = BrokerSummaryAPI();
  final PriceAPI _priceAPI = PriceAPI();
  final InfoFundamentalAPI _infoFundamentalAPI = InfoFundamentalAPI();
  final InfoSahamsAPI _infoSahamsAPI = InfoSahamsAPI();
  final WatchlistAPI _watchlistAPI = WatchlistAPI();
  final DateFormat _df = DateFormat("dd/MM/yyyy");
  final TextStyle _topBrokerHeader = const TextStyle(color: accentColor, fontWeight: FontWeight.bold, fontSize: 10,);
  final TextStyle _topBrokerRow = const TextStyle(fontSize: 10,);

  late DateTime _brokerSummaryDateFrom;
  late DateTime _brokerSummaryDateTo;
  late DateTime _topBrokerDateFrom;
  late DateTime _topBrokerDateTo;
  
  bool _isLoading = true;
  bool _showCurrentPriceComparison = false;
  Map<DateTime, GraphData>? _graphData;
  
  int _numPrice = 0;
  int _bodyPage = 0;
  int _quarterSelection = 5;
  String _quarterSelectionText = "Every Quarter";

  double? _minPrice;
  double? _maxPrice;
  double? _avgPrice;
  int? _maxVolume;
  int? _maxHigh;
  int? _minLow;

  @override
  void initState() {
    super.initState();

    // initialize the tab controller for summary page
    _tabController = TabController(length: 2, vsync: this);

    // set that this is still loading
    _isLoading = true;

    // convert company arguments
    _companyData = widget.companyData as CompanyDetailArgs;

    // get user information
    _userInfo = UserSharedPreferences.getUserInfo();

    // initialize graph data
    _graphData = {};

    // assuming we don't have any watchlist detail
    _watchlistDetail = {};

    Future.microtask(() async {
      // show the loader dialog
      showLoaderDialog(context);

      // get the min and max broker summary date
      await _brokerSummaryAPI.getBrokerSummaryCodeDate(_companyData.companyCode).then((resp) {
        _brokerSummaryDate = resp;
      });

      // get all the information needed
      await _companyApi.getCompanyDetail(_companyData.companyId, _companyData.type).then((resp) {
          // copy the response to company detail data
          _companyDetail = resp;

          // set the broker summary date based on the last update of the company
          _brokerSummaryDateFrom = (_companyDetail.companyLastUpdate ?? DateTime.now());
          _brokerSummaryDateTo = (_companyDetail.companyLastUpdate ?? DateTime.now());    

          // we will try to get the broker data for 3 month of current date
          _topBrokerDateTo =  (_companyDetail.companyLastUpdate == null ? DateTime.now().toLocal() : _companyDetail.companyLastUpdate!.toLocal());
          _topBrokerDateFrom = _topBrokerDateTo.add(const Duration(days: -90));
      });

      await _brokerSummaryAPI.getBrokerSummary(_companyData.companyCode, _brokerSummaryDateFrom.toLocal(), _brokerSummaryDateTo.toLocal()).then((resp) {
        _brokerSummary = resp;
        _brokerSummaryBuySell = resp.brokerSummaryAll;
        _brokerSummarySelected = "a";
      });

      await _companyApi.getCompanyTopBroker(_companyData.companyCode, _topBrokerDateFrom, _topBrokerDateTo).then((resp) {
        _topBroker = resp;
        _topBrokerDateFrom = (resp.brokerMinDate ?? DateTime.now());
        _topBrokerDateTo = (resp.brokerMaxDate ?? DateTime.now());
      });

      await _priceAPI.getPriceMovingAverage(_companyData.companyCode).then((resp) {
        _priceMA = resp;
      });

      await _infoFundamentalAPI.getInfoFundamental(_companyData.companyCode, _quarterSelection).then((resp) {
        _infoFundamental = resp;
      });

      await _infoSahamsAPI.getInfoSahamPrice(_companyData.companyCode).then((resp) {
        _infoSahamPrice = resp;

        // loop thru _infoSahamPrice to get the max volume
        _maxVolume = -1;
        _maxHigh = -1;
        _minLow = 999999999;
        
        for (InfoSahamPriceModel price in _infoSahamPrice) {
          if (price.volume > _maxVolume!) {
            _maxVolume = price.volume;
          }
          if (price.adjustedHighPrice > _maxHigh!) {
            _maxHigh = price.adjustedHighPrice;
          }
          if (price.adjustedLowPrice < _minLow!) {
            _minLow = price.adjustedLowPrice;
          }
          if (price.lastPrice > _maxHigh!) {
            _maxHigh = price.lastPrice;
          }
          if (price.lastPrice < _minLow!) {
            _minLow = price.lastPrice;
          }
        }

        // check if maxHigh, minLow is the same, if same then it probably because all the while
        // the price is the same, so we don't have low and high, for this we can just ignore the maxHigh and minLow
        // and add new ceiling for this.
        if (_maxHigh == _minLow) {
          _maxHigh = _maxHigh! + _maxHigh!;
        }

        // generate map data
        _generateGraphData(_infoSahamPrice, _companyDetail);   
      });

      await _watchlistAPI.findDetail(_companyData.companyId).then((resp) {
        // if we got response then map it to the map, so later we can sent it
        // to the graph for rendering the time when we buy the share
        DateTime tempDate;
        for(WatchlistDetailListModel data in resp) {
          tempDate = data.watchlistDetailDate.toLocal();
          if (_watchlistDetail.containsKey(DateTime(tempDate.year, tempDate.month, tempDate.day))) {
            _watchlistDetail[DateTime(tempDate.year, tempDate.month, tempDate.day)] = _watchlistDetail[DateTime(tempDate.year, tempDate.month, tempDate.day)]! + data.watchlistDetailShare;
          }
          else {
            _watchlistDetail[DateTime(tempDate.year, tempDate.month, tempDate.day)] = data.watchlistDetailShare;
          }
        }
      });
    }).onError((error, stackTrace) {
      ScaffoldMessenger.of(context).showSnackBar(createSnackBar(message: 'Error when try to get the data from server'));
      debugPrint(error.toString());
      debugPrintStack(stackTrace: stackTrace);
    }).whenComplete(() {
      // once finished then remove the loader dialog
      Navigator.pop(context);
      _setIsLoading(false);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _priceController.dispose();
    _calendarScrollController.dispose();
    _graphScrollController.dispose();
    _chipController.dispose();
    _infoController.dispose();
    _brokerController.dispose();
    _fundamentalController.dispose();
    _fundamentalItemController.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return _generatePage();
  }

  Widget _generatePage() {
    IconData currentIcon = Ionicons.remove;

    if (_isLoading) {
      return Container(color: primaryColor,);
    }
    else {
      if ((_companyDetail.companyNetAssetValue! - _companyDetail.companyPrevPrice!) > 0) {
        currentIcon = Ionicons.caret_up;
      }
      else if ((_companyDetail.companyNetAssetValue! - _companyDetail.companyPrevPrice!) < 0) {
        currentIcon = Ionicons.caret_down;
      }

      // generate the actual page
      return WillPopScope(
        onWillPop: (() async {
          return false;
        }),
        child: Scaffold(
          appBar: AppBar(
            title: const Center(
              child: Text(
                "Stock Detail",
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
                              (_companyDetail.companySymbol == null ? "" : "(${_companyDetail.companySymbol!}) ") + _companyData.companyName,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 5,),
                            SingleChildScrollView(
                              controller: _chipController,
                              physics: const AlwaysScrollableScrollPhysics(),
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(color: secondaryLight, style: BorderStyle.solid, width: 1.0),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    padding: const EdgeInsets.all(2),
                                    child: Text(
                                      _companyDetail.companyType,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: secondaryLight,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 5,),
                                  Visibility(
                                    visible: (_companyDetail.companyType.toLowerCase() != _companyDetail.companyIndustry.toLowerCase()),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(color: secondaryLight, style: BorderStyle.solid, width: 1.0),
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      padding: const EdgeInsets.all(2),
                                      child: Text(
                                        _companyDetail.companyIndustry,
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: secondaryLight,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 5,),
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
                                  header: "Volume",
                                  headerAlign: MainAxisAlignment.end,
                                  child: Text(
                                    formatCurrencyWithNull(_companyDetail.companyTotalUnit),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                                const SizedBox(width: 10,),
                                CompanyInfoBox(
                                  header: "Frequency",
                                  headerAlign: MainAxisAlignment.end,
                                  child: Text(
                                    formatIntWithNull(_companyDetail.companyFrequency),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                                const SizedBox(width: 10,),
                                CompanyInfoBox(
                                  header: "Value",
                                  headerAlign: MainAxisAlignment.end,
                                  child: Text(
                                    formatIntWithNull(_companyDetail.companyValue),
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
                    textSize: 11,
                    icon: Ionicons.speedometer_outline,
                    callback: (() {
                      setState(() {
                        _bodyPage = 0;
                      });
                    }),
                    active: (_bodyPage == 0),
                    vertical: true,
                  ),
                  const SizedBox(width: 5,),
                  TransparentButton(
                    text: "Broker",
                    textSize: 11,
                    icon: Ionicons.business_outline,
                    callback: (() {
                      setState(() {
                        _bodyPage = 1;
                      });
                    }),
                    active: (_bodyPage == 1),
                    vertical: true,
                  ),
                  const SizedBox(width: 5,),
                  TransparentButton(
                    text: "Table",
                    textSize: 11,
                    icon: Ionicons.list_outline,
                    callback: (() {
                      setState(() {
                        _bodyPage = 2;
                      });
                    }),
                    active: (_bodyPage == 2),
                    vertical: true,
                  ),
                  const SizedBox(width: 5,),
                  TransparentButton(
                    text: "Map",
                    textSize: 11,
                    icon: Ionicons.calendar_clear_outline,
                    callback: (() {
                      setState(() {
                        _bodyPage = 3;
                      });
                    }),
                    active: (_bodyPage == 3),
                    vertical: true,
                  ),
                  const SizedBox(width: 5,),
                  TransparentButton(
                    text: "Stat",
                    textSize: 11,
                    icon: Ionicons.stats_chart_outline,
                    callback: (() {
                      setState(() {
                        _bodyPage = 4;
                      });
                    }),
                    active: (_bodyPage == 4),
                    vertical: true,
                  ),
                  const SizedBox(width: 5,),
                ],
              ),
              const SizedBox(height: 5,),
              Expanded(child: _detail()),
              const SizedBox(height: 30,),
            ],
          ),
        ),
      );
    }
  }

  Widget _detail() {
    switch(_bodyPage) {
      case 0:
        return _showSummary();
      case 1:
        return _showBroker();
      case 2:
        return _showTable();
      case 3:
        return _showCalendar();
      case 4:
        return _showGraph();
      default:
        return _showSummary();
    }
  }

  Widget _showSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const <Widget>[
            Tab(text: 'SUMMARY',),
            Tab(text: 'FUNDAMENTAL',),
          ],
        ),
        const SizedBox(height: 10,),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: <Widget>[
              _tabSummaryInfo(),
              _tabFundamentalInfo(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _tabFundamentalInfo() {
    return Container(
      padding: const EdgeInsets.all(10),
      child: SingleChildScrollView(
        controller: _fundamentalController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Center(
              child: InkWell(
                onTap: (() async {
                  int? quarter;
                  await showCupertinoModalPopup<void>(
                    context: context,
                    builder: (BuildContext context) => CupertinoActionSheet(
                      title: const Text(
                        "Select Period",
                        style: TextStyle(
                          fontFamily: '--apple-system',
                        ),
                      ),
                      actions: <CupertinoActionSheetAction>[
                        CupertinoActionSheetAction(
                          onPressed: (() {
                            quarter = 5;
                            Navigator.pop(context);
                          }),
                          child: const Text(
                            "Every Quarter",
                            style: TextStyle(
                              fontFamily: '--apple-system',
                              color: textPrimary,
                            ),
                          ),
                        ),
                        CupertinoActionSheetAction(
                          onPressed: (() {
                            quarter = 1;
                            Navigator.pop(context);
                          }),
                          child: const Text(
                            "3 Month",
                            style: TextStyle(
                              fontFamily: '--apple-system',
                              color: textPrimary,
                            ),
                          ),
                        ),
                        CupertinoActionSheetAction(
                          onPressed: (() {
                            quarter = 2;
                            Navigator.pop(context);
                          }),
                          child: const Text(
                            "6 Month",
                            style: TextStyle(
                              fontFamily: '--apple-system',
                              color: textPrimary,
                            ),
                          ),
                        ),
                        CupertinoActionSheetAction(
                          onPressed: (() {
                            quarter = 3;
                            Navigator.pop(context);
                          }),
                          child: const Text(
                            "9 Month",
                            style: TextStyle(
                              fontFamily: '--apple-system',
                              color: textPrimary,
                            ),
                          ),
                        ),
                        CupertinoActionSheetAction(
                          onPressed: (() {
                            quarter = 4;
                            Navigator.pop(context);
                          }),
                          child: const Text(
                            "12 Month",
                            style: TextStyle(
                              fontFamily: '--apple-system',
                              color: textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
      
                  // check if quarter is null or not?
                  if (quarter  != null) {
                    // set the quarter selection
                    _quarterSelection = quarter!;
                    // set the quarter selection text
                    switch(_quarterSelection) {
                      case 1:
                        _quarterSelectionText = "3 Month";
                        break;
                      case 2:
                        _quarterSelectionText = "6 Month";
                        break;
                      case 3:
                        _quarterSelectionText = "9 Month";
                        break;
                      case 4:
                        _quarterSelectionText = "12 Month";
                        break;
                      case 5:
                        _quarterSelectionText = "Every Quarter";
                        break;
                      default:
                        _quarterSelectionText = "Every Quarter";
                        break;
                    }
      
                    // get the new data from api
                    await _getFundamental();
                  }
                }),
                child: Text(
                  _quarterSelectionText,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: secondaryColor,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20,),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  width: 125,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      _text(
                        text: "Period",
                        fontWeight: FontWeight.bold,
                        color: secondaryColor,
                      ),
                      _text(
                        text: "Last Price",
                      ),
                      _text(
                        text: "Share Out",
                      ),
                      _text(
                        text: "Market Cap",
                      ),
                      _text(
                        text: "BALANCE SHEET",
                        fontWeight: FontWeight.bold,
                        color: accentColor,
                      ),
                      _text(
                        text: "Cash",
                      ),
                      _text(
                        text: "Total Asset",
                      ),
                      _text(
                        text: "S.T.Borrowing",
                      ),
                      _text(
                        text: "L.T.Borrowing",
                      ),
                      _text(
                        text: "Total Equity",
                      ),
                      _text(
                        text: "INCOME STATEMENT",
                        fontWeight: FontWeight.bold,
                        color: accentColor,
                      ),
                      _text(
                        text: "Revenue",
                      ),
                      _text(
                        text: "Gross Profit",
                      ),
                      _text(
                        text: "Operating Profit",
                      ),
                      _text(
                        text: "Net.Profit",
                      ),
                      _text(
                        text: "EBITDA",
                      ),
                      _text(
                        text: "Interest Expense",
                      ),
                      _text(
                        text: "RATIO",
                        fontWeight: FontWeight.bold,
                        color: accentColor,
                      ),
                      _text(
                        text: "Deviden",
                      ),
                      _text(
                        text: "EPS",
                      ),
                      _text(
                        text: "PER",
                      ),
                      _text(
                        text: "BVPS",
                      ),
                      _text(
                        text: "PBV",
                      ),
                      _text(
                        text: "ROA",
                      ),
                      _text(
                        text: "ROE",
                      ),
                      _text(
                        text: "EV/EBITDA",
                      ),
                      _text(
                        text: "Debt/Equity",
                      ),
                      _text(
                        text: "Debt/TotalCap",
                      ),
                      _text(
                        text: "Debt/EBITDA",
                      ),
                      _text(
                        text: "EBITDA/IntExps",
                      ),
                    ],
                  )
                ),
                const SizedBox(width: 10,),
                Expanded(
                  child: SingleChildScrollView(
                    controller: _fundamentalItemController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: List<Widget>.generate(_infoFundamental.length, (index) {
                        return SizedBox(
                          width: 85,
                          child: _fundamentalItem(fundamental: _infoFundamental[index])
                        );
                      }),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _fundamentalItem({required InfoFundamentalsModel fundamental}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        _text(
          text: "${fundamental.period}M ${fundamental.year}",
          fontWeight: FontWeight.bold,
          bgColor: primaryDark,
          color: secondaryLight
        ),
        _text(
          text: formatIntWithNull(fundamental.lastPrice, false, false),
          bgColor: primaryDark,
        ),
        _text(
          text: formatIntWithNull(fundamental.shareOut, false, true),
          bgColor: primaryDark,
        ),
        _text(
          text: formatIntWithNull(fundamental.marketCap, false, true),
          bgColor: primaryDark,
        ),
        _text(
          text: "",
          fontWeight: FontWeight.bold,
          bgColor: primaryDark,
        ),
        _text(
          text: formatIntWithNull(fundamental.cash, false, true),
          bgColor: primaryDark,
        ),
        _text(
          text: formatIntWithNull(fundamental.totalAsset, false, true),
          bgColor: primaryDark,
        ),
        _text(
          text: formatIntWithNull(fundamental.stBorrowing, false, true),
          bgColor: primaryDark,
        ),
        _text(
          text: formatIntWithNull(fundamental.ltBorrowing, false, true),
          bgColor: primaryDark,
        ),
        _text(
          text: formatIntWithNull(fundamental.totalEquity, false, true),
          bgColor: primaryDark,
        ),
        _text(
          text: "",
          fontWeight: FontWeight.bold,
          bgColor: primaryDark,
        ),
        _text(
          text: formatIntWithNull(fundamental.revenue, false, true),
          bgColor: primaryDark,
        ),
        _text(
          text: formatIntWithNull(fundamental.grossProfit, false, true),
          bgColor: primaryDark,
        ),
        _text(
          text: formatIntWithNull(fundamental.operatingProfit, false, true),
          bgColor: primaryDark,
        ),
        _text(
          text: formatIntWithNull(fundamental.netProfit, false, true),
          bgColor: primaryDark,
        ),
        _text(
          text: formatIntWithNull(fundamental.ebitda, false, true),
          bgColor: primaryDark,
        ),
        _text(
          text: formatIntWithNull(fundamental.interestExpense, false, true),
          bgColor: primaryDark,
        ),
        _text(
          text: "",
          fontWeight: FontWeight.bold,
          bgColor: primaryDark,
        ),
        _text(
          text: formatCurrencyWithNull(fundamental.deviden),
          bgColor: primaryDark,
        ),
        _text(
          text: formatCurrencyWithNull(fundamental.eps),
          bgColor: primaryDark,
        ),
        _text(
          text: '${formatCurrencyWithNull(fundamental.per)} x',
          bgColor: primaryDark,
        ),
        _text(
          text: formatCurrencyWithNull(fundamental.bvps),
          bgColor: primaryDark,
        ),
        _text(
          text: '${formatCurrencyWithNull(fundamental.pbv)} x',
          bgColor: primaryDark,
        ),
        _text(
          text: '${formatCurrencyWithNull(fundamental.roa)} %',
          bgColor: primaryDark,
        ),
        _text(
          text: '${formatCurrencyWithNull(fundamental.roe)} %',
          bgColor: primaryDark,
        ),
        _text(
          text: formatCurrencyWithNull(fundamental.evEbitda),
          bgColor: primaryDark,
        ),
        _text(
          text: formatCurrencyWithNull(fundamental.debtEquity),
          bgColor: primaryDark,
        ),
        _text(
          text: formatCurrencyWithNull(fundamental.debtTotalcap),
          bgColor: primaryDark,
        ),
        _text(
          text: formatCurrencyWithNull(fundamental.debtEbitda),
          bgColor: primaryDark,
        ),
        _text(
          text: formatCurrencyWithNull(fundamental.ebitdaInterestexpense),
          bgColor: primaryDark,
        ),
      ],
    );
  }

  Widget _tabSummaryInfo() {
    return Container(
      padding: const EdgeInsets.all(10),
      child: SingleChildScrollView(
        controller: _infoController,
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                CompanyInfoBox(
                  header: "Prev Close",
                  headerAlign: MainAxisAlignment.end,
                  child: Text(
                    formatCurrencyWithNull(_companyDetail.companyPrevClosingPrice),
                    textAlign: TextAlign.right,
                  ),
                ),
                const SizedBox(width: 10,),
                CompanyInfoBox(
                  header: "Adj Close",
                  headerAlign: MainAxisAlignment.end,
                  child: Text(
                    formatCurrencyWithNull(_companyDetail.companyAdjustedClosingPrice),
                    textAlign: TextAlign.right,
                  ),
                ),
                const SizedBox(width: 10,),
                CompanyInfoBox(
                  header: "Adj Open",
                  headerAlign: MainAxisAlignment.end,
                  child: Text(
                    formatCurrencyWithNull(_companyDetail.companyAdjustedOpenPrice),
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
                  header: "Adj High",
                  headerAlign: MainAxisAlignment.end,
                  child: Text(
                    formatCurrencyWithNull(_companyDetail.companyAdjustedHighPrice),
                    textAlign: TextAlign.right,
                  ),
                ),
                const SizedBox(width: 10,),
                CompanyInfoBox(
                  header: "Adj Low",
                  headerAlign: MainAxisAlignment.end,
                  child: Text(
                    formatCurrencyWithNull(_companyDetail.companyAdjustedLowPrice),
                    textAlign: TextAlign.right,
                  ),
                ),
                const SizedBox(width: 10,),
                CompanyInfoBox(
                  header: "Cptlztion",
                  headerAlign: MainAxisAlignment.end,
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
                  headerAlign: MainAxisAlignment.end,
                  child: Text(
                    "${formatDecimalWithNull(_companyDetail.companyDailyReturn, 100, 4)}%",
                    textAlign: TextAlign.right,
                  ),
                ),
                const SizedBox(width: 10,),
                CompanyInfoBox(
                  header: "One Week",
                  headerAlign: MainAxisAlignment.end,
                  child: Text(
                    "${formatDecimalWithNull(_companyDetail.companyWeeklyReturn, 100, 4)}%",
                    textAlign: TextAlign.right,
                  ),
                ),
                const SizedBox(width: 10,),
                CompanyInfoBox(
                  header: "One Month",
                  headerAlign: MainAxisAlignment.end,
                  child: Text(
                    "${formatDecimalWithNull(_companyDetail.companyMonthlyReturn, 100, 4)}%",
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
                  headerAlign: MainAxisAlignment.end,
                  child: Text(
                    "${formatDecimalWithNull(_companyDetail.companyQuarterlyReturn, 100, 4)}%",
                    textAlign: TextAlign.right,
                  ),
                ),
                const SizedBox(width: 10,),
                CompanyInfoBox(
                  header: "Six Month",
                  headerAlign: MainAxisAlignment.end,
                  child: Text(
                    "${formatDecimalWithNull(_companyDetail.companySemiAnnualReturn, 100, 4)}%",
                    textAlign: TextAlign.right,
                  ),
                ),
                const SizedBox(width: 10,),
                CompanyInfoBox(
                  header: "One Year",
                  headerAlign: MainAxisAlignment.end,
                  child: Text(
                    "${formatDecimalWithNull(_companyDetail.companyYearlyReturn, 100, 4)}%",
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
                  headerAlign: MainAxisAlignment.end,
                  child: Text(
                    "${formatDecimalWithNull(_companyDetail.companyThreeYear, 100, 4)}%",
                    textAlign: TextAlign.right,
                  ),
                ),
                const SizedBox(width: 10,),
                CompanyInfoBox(
                  header: "Five Years",
                  headerAlign: MainAxisAlignment.end,
                  child: Text(
                    "${formatDecimalWithNull(_companyDetail.companyFiveYear, 100, 4)}%",
                    textAlign: TextAlign.right,
                  ),
                ),
                const SizedBox(width: 10,),
                CompanyInfoBox(
                  header: "Ten Years",
                  headerAlign: MainAxisAlignment.end,
                  child: Text(
                    "${formatDecimalWithNull(_companyDetail.companyTenYear, 100, 4)}%",
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
                  headerAlign: MainAxisAlignment.end,
                  child: Text(
                    "${formatDecimalWithNull(_companyDetail.companyMtd, 100, 4)}%",
                    textAlign: TextAlign.right,
                  ),
                ),
                const SizedBox(width: 10,),
                CompanyInfoBox(
                  header: "YTD",
                  headerAlign: MainAxisAlignment.end,
                  child: Text(
                    "${formatDecimalWithNull(_companyDetail.companyYtdReturn, 100, 4)}%",
                    textAlign: TextAlign.right,
                  ),
                ),
                const SizedBox(width: 10,),
                const Expanded(child: SizedBox(),),
              ],
            ),
            const SizedBox(height: 10,),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                CompanyInfoBox(
                  header: "PER",
                  headerAlign: MainAxisAlignment.end,
                  onTap: (() async {
                    await ShowInfoDialog(
                      title: "PER (Price Earning Ratio)",
                      text: "The price-to-earnings ratio is the ratio for valuing a company that measures its current share price relative to its earnings per share (EPS). The price-to-earnings ratio is also sometimes known as the price multiple or the earnings multiple.",
                      okayColor: accentColor
                    ).show(context);
                  }),
                  child: Text(
                    formatDecimalWithNull(_companyDetail.companyPer, 1, 4),
                    textAlign: TextAlign.right,
                  ),
                ),
                const SizedBox(width: 10,),
                CompanyInfoBox(
                  header: "PER Annual",
                  headerAlign: MainAxisAlignment.end,
                  child: Text(
                    formatDecimalWithNull(_companyDetail.companyPerAnnualized, 1, 4),
                    textAlign: TextAlign.right,
                  ),
                ),
                const SizedBox(width: 10,),
                CompanyInfoBox(
                  header: "Beta 1Y",
                  onTap: (() async {
                    await ShowInfoDialog(
                      title: "Beta 1 Year",
                      text: "A ratio that measures the risk or volatility of a company's share price in comparison to the market as a whole. Beta (1 Year) is calculated using one year of weekly returns.",
                      okayColor: accentColor
                    ).show(context);
                  }),
                  headerAlign: MainAxisAlignment.end,
                  child: Text(
                    formatDecimalWithNull(_companyDetail.companyBetaOneYear, 1, 4),
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
                  headerAlign: MainAxisAlignment.end,
                  onTap: (() async {
                    await ShowInfoDialog(
                      title: 'Price-to-Book (P/B) Ratio',
                      text: "Companies use the price-to-book ratio (P/B ratio) to compare a firm's market capitalization to its book value. It's calculated by dividing the company's stock price per share by its book value per share (BVPS). An asset's book value is equal to its carrying value on the balance sheet, and companies calculate it by netting the asset against its accumulated depreciation.",
                      okayColor: accentColor,
                    ).show(context);
                  }),
                  child: Text(
                    formatDecimalWithNull(_companyDetail.companyPbr, 1, 4),
                    textAlign: TextAlign.right,
                  ),
                ),
                const SizedBox(width: 10,),
                CompanyInfoBox(
                  header: "PSR Annual",
                  headerAlign: MainAxisAlignment.end,
                  onTap: (() async {
                    await ShowInfoDialog(
                      title: "Price–sales ratio (Annualized)",
                      text: "PSR, is a valuation metric for stocks. It is calculated by dividing the company's market capitalization by the revenue in the most recent year; or, equivalently, divide the per-share stock price by the per-share revenue.",
                      okayColor: accentColor,
                    ).show(context);
                  }),
                  child: Text(
                    formatDecimalWithNull(_companyDetail.companyPsrAnnualized, 1, 4),
                    textAlign: TextAlign.right,
                  ),
                ),
                const SizedBox(width: 10,),
                CompanyInfoBox(
                  header: "PCFR Annual",
                  headerAlign: MainAxisAlignment.end,
                  onTap: (() async {
                    await ShowInfoDialog(
                      title: "Price-to-Cash Flow (P/CF) Ratio",
                      text: " The price-to-cash flow (P/CF) ratio is a stock valuation indicator or multiple that measures the value of a stock’s price relative to its operating cash flow per share. The ratio uses operating cash flow (OCF), which adds back non-cash expenses such as depreciation and amortization to net income.\n\nP/CF is especially useful for valuing stocks that have positive cash flow but are not profitable because of large non-cash charges.",
                      okayColor: accentColor,
                    ).show(context);
                  }),
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
                  header: "MA5",
                  headerAlign: MainAxisAlignment.end,
                  child: Text(
                    formatIntWithNull(_priceMA.priceSahamMa.priceSahamMa5),
                    textAlign: TextAlign.right,
                  ),
                ),
                const SizedBox(width: 10,),
                CompanyInfoBox(
                  header: "MA8",
                  headerAlign: MainAxisAlignment.end,
                  child: Text(
                    formatIntWithNull(_priceMA.priceSahamMa.priceSahamMa8),
                    textAlign: TextAlign.right,
                  ),
                ),
                const SizedBox(width: 10,),
                CompanyInfoBox(
                  header: "MA13",
                  headerAlign: MainAxisAlignment.end,
                  child: Text(
                    formatIntWithNull(_priceMA.priceSahamMa.priceSahamMa13),
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
                  header: "MA20",
                  headerAlign: MainAxisAlignment.end,
                  child: Text(
                    formatIntWithNull(_priceMA.priceSahamMa.priceSahamMa20),
                    textAlign: TextAlign.right,
                  ),
                ),
                const SizedBox(width: 10,),
                CompanyInfoBox(
                  header: "MA30",
                  headerAlign: MainAxisAlignment.end,
                  child: Text(
                    formatIntWithNull(_priceMA.priceSahamMa.priceSahamMa30),
                    textAlign: TextAlign.right,
                  ),
                ),
                const SizedBox(width: 10,),
                CompanyInfoBox(
                  header: "MA50",
                  headerAlign: MainAxisAlignment.end,
                  child: Text(
                    formatIntWithNull(_priceMA.priceSahamMa.priceSahamMa50),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _text({required String text, FontWeight? fontWeight, double? fontSize, Color? color, Color? bgColor}) {
    FontWeight? fontWeightUsed = (fontWeight ?? FontWeight.normal);
    double? fontSizeUsed = (fontSize ?? 10);
    Color? colorUsed = (color ?? textPrimary);
    Color? bgColorUsed = (bgColor ?? Colors.transparent);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            color: bgColorUsed,
            child: Text(
              text,
              style: TextStyle(
                fontWeight: fontWeightUsed,
                fontSize: fontSizeUsed,
                color: colorUsed,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _showBroker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Container(
            padding: const EdgeInsets.fromLTRB(5, 10, 5, 10),
            child: SingleChildScrollView(
              controller: _brokerController,
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  const Center(
                    child: Text(
                      "Broker Summary",
                      style: TextStyle(
                        color: secondaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10,),
                  InkWell(
                    onTap: (() async {
                      // check for the max date to avoid any assertion that the initial date range
                      // is more than the lastDate
                      DateTime maxDate = _brokerSummaryDate.brokerMaxDate.toLocal();
                      if (maxDate.isBefore(_brokerSummaryDateTo.toLocal())) {
                        maxDate = _brokerSummaryDateTo;
                      }

                      DateTimeRange? result = await showDateRangePicker(
                        context: context,
                        firstDate: _brokerSummaryDate.brokerMinDate.toLocal(),
                        lastDate: maxDate.toLocal(),
                        initialDateRange: DateTimeRange(start: _brokerSummaryDateFrom.toLocal(), end: _brokerSummaryDateTo.toLocal()),
                        confirmText: 'Done',
                        currentDate: _companyDetail.companyLastUpdate,
                      );

                      // check if we got the result or not?
                      if (result != null) {
                        // check whether the result start and end is different date, if different then we need to get new broker summary data.
                        if ((result.start.compareTo(_brokerSummaryDateFrom) != 0) || (result.end.compareTo(_brokerSummaryDateTo) != 0)) {                      
                          // set the broker from and to date
                          _brokerSummaryDateFrom = result.start;
                          _brokerSummaryDateTo = result.end;

                          // get the broker summary
                          await _getBrokerSummary();
                        }
                      }
                    }),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          _df.format(_brokerSummary.brokerSummaryFromDate.toLocal()),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: secondaryLight,
                          ),
                        ),
                        const Text(
                          " - ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: secondaryLight,
                          ),
                        ),
                        Text(
                          _df.format(_brokerSummary.brokerSummaryToDate.toLocal()),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: secondaryLight,
                          ),
                        ),
                        const SizedBox(width: 10,),
                        const Icon(
                          Ionicons.calendar_outline,
                          size: 15,
                          color: secondaryLight,
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 10,),
                  SizedBox(
                    width: double.infinity,
                    child: CupertinoSegmentedControl(
                      children: const {
                        "a": Text("All"),
                        "d": Text("Domestic"),
                        "f": Text("Foreign"),
                      },
                      onValueChanged: ((value) {
                        String selectedValue = value.toString();
              
                        setState(() {
                          if(selectedValue == "a") {
                            _brokerSummaryBuySell = _brokerSummary.brokerSummaryAll;
                            _brokerSummarySelected = "a";
                          }
                          else if(selectedValue == "d") {
                            _brokerSummaryBuySell = _brokerSummary.brokerSummaryDomestic;
                            _brokerSummarySelected = "d";
                          }
                          else if(selectedValue == "f") {
                            _brokerSummaryBuySell = _brokerSummary.brokerSummaryForeign;
                            _brokerSummarySelected = "f";
                          }
                        });
                      }),
                      groupValue: _brokerSummarySelected,
                      selectedColor: secondaryColor,
                      borderColor: secondaryDark,
                      pressedColor: primaryDark,
                    ),
                  ),
                  const SizedBox(height: 10,),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: primaryLight,
                        style: BorderStyle.solid,
                        width: 1.0
                      ),
                      color: primaryDark
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                child: _tableRow(brokerCode: "BY", lot: "B.lot", value: "B.val", average: "B.avg", isBold: true, backgroundColor: secondaryDark)
                              ),
                              ...List<Widget>.generate(10, (index) {
                                if (_brokerSummaryBuySell.brokerSummaryBuy.length > index) {
                                  return _tableRow(
                                    brokerCode: _brokerSummaryBuySell.brokerSummaryBuy[index].brokerSummaryID!,
                                    lot: formatIntWithNull(_brokerSummaryBuySell.brokerSummaryBuy[index].brokerSummaryLot, true, false),
                                    value: formatIntWithNull(_brokerSummaryBuySell.brokerSummaryBuy[index].brokerSummaryValue, true, false),
                                    average: formatIntWithNull(_brokerSummaryBuySell.brokerSummaryBuy[index].brokerSummaryAverage, false, false),
                                  );
                                }
                                else {
                                  return _tableRow(
                                    brokerCode: "-",
                                    lot: "-",
                                    value: "-",
                                    average: "-"
                                  );
                                }
                              },),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                child: _tableRow(brokerCode: "SY", lot: "S.lot", value: "S.val", average: "S.avg", isBold: true, backgroundColor: Colors.green[900])
                              ),
                              ...List<Widget>.generate(10, (index) {
                                if (_brokerSummaryBuySell.brokerSummarySell.length > index) {
                                  return _tableRow(
                                    brokerCode: _brokerSummaryBuySell.brokerSummarySell[index].brokerSummaryID!,
                                    lot: formatIntWithNull(_brokerSummaryBuySell.brokerSummarySell[index].brokerSummaryLot, true, false),
                                    value: formatIntWithNull(_brokerSummaryBuySell.brokerSummarySell[index].brokerSummaryValue, true, false),
                                    average: formatIntWithNull(_brokerSummaryBuySell.brokerSummarySell[index].brokerSummaryAverage, false, false),
                                  );
                                }
                                else {
                                  return _tableRow(
                                    brokerCode: "-",
                                    lot: "-",
                                    value: "-",
                                    average: "-"
                                  );
                                }
                              },),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20,),
                  const Center(
                    child: Text(
                      "Top Broker",
                      style: TextStyle(
                        color: secondaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10,),
                  InkWell(
                    onTap: (() async {
                      // check for the max date to avoid any assertion that the initial date range
                      // is more than the lastDate
                      DateTime maxDate = _brokerSummaryDate.brokerMaxDate.toLocal();
                      DateTime minDate = _brokerSummaryDate.brokerMinDate.toLocal();
                      if (maxDate.isBefore(_topBrokerDateTo.toLocal())) {
                        maxDate = _topBrokerDateTo;
                      }
                      if (minDate.isAfter(_topBrokerDateFrom.toLocal())) {
                        minDate = _topBrokerDateFrom;
                      }

                      DateTimeRange? result = await showDateRangePicker(
                        context: context,
                        firstDate: minDate.toLocal(),
                        lastDate: maxDate.toLocal(),
                        initialDateRange: DateTimeRange(start: _topBrokerDateFrom.toLocal(), end: _topBrokerDateTo.toLocal()),
                        confirmText: 'Done',
                        currentDate: _companyDetail.companyLastUpdate!.toLocal(),
                      );

                      // check if we got the result or not?
                      if (result != null) {
                        // check whether the result start and end is different date, if different then we need to get new broker summary data.
                        if ((result.start.compareTo(_topBrokerDateFrom) != 0) || (result.end.compareTo(_topBrokerDateTo) != 0)) {                      
                          // set the broker from and to date
                          _topBrokerDateFrom = result.start;
                          _topBrokerDateTo = result.end;

                          await _getTopBroker();
                        }
                      }
                    }),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          _df.format((_topBroker.brokerMinDate == null ? DateTime.now() : _topBroker.brokerMinDate!.toLocal())),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: secondaryLight,
                          ),
                        ),
                        const Text(
                          " - ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: secondaryLight,
                          ),
                        ),
                        Text(
                          _df.format((_topBroker.brokerMaxDate == null ? DateTime.now() : _topBroker.brokerMaxDate!.toLocal())),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: secondaryLight,
                          ),
                        ),
                        const SizedBox(width: 10,),
                        const Icon(
                          Ionicons.calendar_outline,
                          size: 15,
                          color: secondaryLight,
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 10,),
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: primaryDark,
                      border: Border.all(color: primaryLight, width: 1.0, style: BorderStyle.solid),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          flex: 1,
                          child: Text(
                            "ID",
                            style: _topBrokerHeader,
                          )
                        ),
                        const SizedBox(width: 3,),
                        Expanded(
                          flex: 3,
                          child: Text(
                            "Lot",
                            style: _topBrokerHeader,
                          )
                        ),
                        const SizedBox(width: 3,),
                        Expanded(
                          flex: 3,
                          child: Text(
                            "Avg",
                            style: _topBrokerHeader,
                          )
                        ),
                        const SizedBox(width: 3,),
                        Expanded(
                          flex: 3,
                          child: Text(
                            "Cost",
                            style: _topBrokerHeader,
                          )
                        ),
                        const SizedBox(width: 3,),
                        Expanded(
                          flex: 3,
                          child: Text(
                            "Value",
                            style: _topBrokerHeader,
                          )
                        ),
                        const SizedBox(width: 3,),
                        Expanded(
                          flex: 3,
                          child: Text(
                            "Diff",
                            style: _topBrokerHeader,
                          )
                        ),
                      ],
                    ),
                  ),
                  ...List.generate(
                    _topBroker.brokerData.length,
                    (index) {
                      double currentValue = (_topBroker.brokerData[index].brokerSummaryLot * (_companyDetail.companyNetAssetValue ?? 0)) * 100;
                      double currentDiff = (currentValue - (_topBroker.brokerData[index].brokerSummaryValue * 100));
                      return InkWell(
                        onTap: (() {
                          BrokerDetailArgs args = BrokerDetailArgs(
                            brokerFirmID: _topBroker.brokerData[index].brokerSummaryId
                          );
                          Navigator.pushNamed(context, '/broker/detail', arguments: args);
                        }),
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: const BoxDecoration(
                            border: Border(
                              left: BorderSide(
                                color: primaryLight,
                                width: 1.0,
                                style: BorderStyle.solid,
                              ),
                              right: BorderSide(
                                color: primaryLight,
                                width: 1.0,
                                style: BorderStyle.solid,
                              ),
                              bottom: BorderSide(
                                color: primaryLight,
                                width: 1.0,
                                style: BorderStyle.solid,
                              )
                            )
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Expanded(
                                flex: 1,
                                child: Text(
                                  _topBroker.brokerData[index].brokerSummaryId,
                                  style: _topBrokerRow,
                                )
                              ),
                              const SizedBox(width: 3,),
                              Expanded(
                                flex: 3,
                                child: Text(
                                  formatIntWithNull(_topBroker.brokerData[index].brokerSummaryLot, false, false),
                                  style: _topBrokerRow,
                                )
                              ),
                              const SizedBox(width: 3,),
                              Expanded(
                                flex: 3,
                                child: Text(
                                  formatCurrency(_topBroker.brokerData[index].brokerSummaryAverage, false, false, true),
                                  style: _topBrokerRow,
                                )
                              ),
                              const SizedBox(width: 3,),
                              Expanded(
                                flex: 3,
                                child: Text(
                                  formatIntWithNull(_topBroker.brokerData[index].brokerSummaryValue * 100),
                                  style: _topBrokerRow,
                                )
                              ),
                              const SizedBox(width: 3,),
                              Expanded(
                                flex: 3,
                                child: Text(
                                  formatCurrency(currentValue, false, false, true),
                                  style: _topBrokerRow,
                                )
                              ),
                              const SizedBox(width: 3,),
                              Expanded(
                                flex: 3,
                                child: Text(
                                  formatCurrency(currentDiff, false, false, true),
                                  style: _topBrokerRow.copyWith(
                                    color: (currentDiff < 0 ? secondaryColor : currentDiff > 0 ? Colors.green : textPrimary)
                                  ),
                                )
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _tableRow({required String brokerCode, required String lot, required String value, required String average, Color? textColor, bool? isBold, Color? backgroundColor, double? fontSize}) {
    Color textColorUse = (textColor ?? Colors.white);
    Color backgroundColorUse = (backgroundColor ?? Colors.transparent);
    bool isBoldUse = (isBold ?? false);
    double fontSizeUse = (fontSize ?? 10);

    return InkWell(
      onTap: (() {
        BrokerDetailArgs args = BrokerDetailArgs(
          brokerFirmID: brokerCode
        );
        Navigator.pushNamed(context, '/broker/detail', arguments: args);
      }),
      child: Container(
        color: backgroundColorUse,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
              width: 30,
              child: Text(
                brokerCode,
                style: TextStyle(
                  fontWeight: (isBoldUse ? FontWeight.bold : FontWeight.normal),
                  fontSize: fontSizeUse,
                  color: textColorUse,
                ),
              ),
            ),
            const SizedBox(width: 5,),
            Expanded(
              child: Container(
                padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                child: Text(
                  lot,
                  style: TextStyle(
                    fontWeight: (isBoldUse ? FontWeight.bold : FontWeight.normal),
                    fontSize: fontSizeUse,
                    color: textColorUse,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 5,),
            Expanded(
              child: Container(
                padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                child: Text(
                  value,
                  style: TextStyle(
                    fontWeight: (isBoldUse ? FontWeight.bold : FontWeight.normal),
                    fontSize: fontSizeUse,
                    color: textColorUse,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 5,),
            Expanded(
              child: Container(
                padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                child: Text(
                  average,
                  style: TextStyle(
                    fontWeight: (isBoldUse ? FontWeight.bold : FontWeight.normal),
                    fontSize: fontSizeUse,
                    color: textColorUse,
                  ),
                ),
              ),
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
        ),
        Expanded(
          child: ListView(
            controller: _priceController,
            physics: const AlwaysScrollableScrollPhysics(),
            children: List<Widget>.generate(_infoSahamPrice.length, (index) {
              int? dayDiff;
              Color dayDiffColor = Colors.transparent;
              int lowDiff = _infoSahamPrice[index].lastPrice - _infoSahamPrice[index].adjustedLowPrice;
              int highDiff = (_infoSahamPrice[index].lastPrice - _infoSahamPrice[index].adjustedHighPrice) * -1;

              if((index+1) < _infoSahamPrice.length) {
                int currPrice = _infoSahamPrice[index].lastPrice;
                int prevPrice = _infoSahamPrice[index + 1].lastPrice;
                dayDiff = currPrice - prevPrice;
                dayDiffColor = riskColor(currPrice.toDouble(), prevPrice.toDouble(), _userInfo!.risk);
              }

              return Container(
                color: riskColor(_companyDetail.companyNetAssetValue!, _infoSahamPrice[index].lastPrice.toDouble(), _userInfo!.risk),
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
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    _df.format(_infoSahamPrice[index].date.toLocal()),
                                    style: const TextStyle(
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    formatIntWithNull(_infoSahamPrice[index].volume, false, true),
                                    style: const TextStyle(
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              )
                            ),
                            const SizedBox(width: 10,),
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    formatCurrency(_infoSahamPrice[index].lastPrice.toDouble()),
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    formatCurrency(_infoSahamPrice[index].adjustedLowPrice.toDouble()),
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(
                                      fontSize: 10,
                                    ),
                                  ),
                                  Text(
                                    formatCurrency(_infoSahamPrice[index].adjustedHighPrice.toDouble()),
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              )
                            ),
                            const SizedBox(width: 10,),
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: riskColor(_companyDetail.companyNetAssetValue!, _infoSahamPrice[index].lastPrice.toDouble(), _userInfo!.risk),
                                          width: 2.0,
                                          style: BorderStyle.solid,
                                        )
                                      )
                                    ),
                                    child: Text(
                                      formatCurrency(_companyDetail.companyNetAssetValue! - _infoSahamPrice[index].lastPrice.toDouble()),
                                      textAlign: TextAlign.right,
                                      style: const TextStyle(
                                        fontSize: 12,
                                      ),
                                    )
                                  ),
                                  Text(
                                    formatIntWithNull(lowDiff, false, false),
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: secondaryColor,
                                    ),
                                  ),
                                  Text(
                                    formatIntWithNull(highDiff, false, false),
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              )
                            ),
                            const SizedBox(width: 10,),
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: dayDiffColor,
                                          width: 2.0,
                                          style: BorderStyle.solid,
                                        )
                                      )
                                    ),
                                    child: Text(
                                      (dayDiff == null ? "-" : formatCurrency(dayDiff.toDouble())),
                                      textAlign: TextAlign.right,
                                      style: const TextStyle(
                                        fontSize: 12,
                                      ),
                                    )
                                  ),
                                  Text(
                                    '${formatDecimalWithNull(lowDiff / _infoSahamPrice[index].lastPrice, 100, 2)}%',
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: secondaryColor,
                                    ),
                                  ),
                                  Text(
                                    '${formatDecimalWithNull(highDiff / _infoSahamPrice[index].lastPrice, 100, 2)}%',
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              )
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
        )
      ],
    );
  }

  Widget _showGraph() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: SingleChildScrollView(
            controller: _graphScrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                LineChart(
                  data: _graphData!,
                  height: 250,
                  watchlist: _watchlistDetail,
                ),
                const SizedBox(height: 5,),
                SizedBox(
                  height: 160,
                  child: CustomPaint(
                    size: Size.infinite,
                    painter: StockCandleStickPainter(
                      stockData: _infoSahamPrice,
                      maxHigh: _maxHigh!,
                      minLow: _minLow!,
                    ),
                  ),
                ),
                const SizedBox(height: 15,),
                SizedBox(
                  height: 30,
                  child: CustomPaint(
                    size: Size.infinite,
                    painter: StockVolumePainter(
                      stockData: _infoSahamPrice,
                      maxVolume: _maxVolume!,
                    ),
                  ),
                ),
                const SizedBox(height: 15,),
              ],
            ),
          ),
        )
      ],
    );
  }

  void _setIsLoading(bool val) {
    setState(() {
      _isLoading = val;
    });
  }

  void _generateGraphData(List<InfoSahamPriceModel> prices, CompanyDetailModel company) {
    // map the price date on company
    List<GraphData> tempData = [];
    int totalData = 0;
    double totalPrice = 0;
    int totalPriceData = 0;

    _minPrice = double.maxFinite;
    _maxPrice = double.minPositive;

    // move the last update to friday
    int addDay = 5 - company.companyLastUpdate!.toLocal().weekday;
    DateTime endDate = company.companyLastUpdate!.add(Duration(days: addDay));

    // then go 14 weeks before so we knew the start date
    DateTime startDate = endDate.subtract(const Duration(days: 89)); // ((7*13) - 2), the 2 is because we end the day on Friday so no Saturday and Sunday.

    // only get the 1st 64 data, since we will want to get the latest data
    for (InfoSahamPriceModel price in prices) {
      // ensure that all the data we will put is more than or equal with startdate
      if(price.date.compareTo(startDate) >= 0) {
        tempData.add(GraphData(date: price.date.toLocal(), price: price.lastPrice.toDouble()));
        totalData += 1;
      }

      // count for minimum, maximum, and average
      if(totalPriceData < 29) {
        if(_minPrice! > price.lastPrice.toDouble()) {
          _minPrice = price.lastPrice.toDouble();
        }

        if(_maxPrice! < price.lastPrice.toDouble()) {
          _maxPrice = price.lastPrice.toDouble();
        }

        totalPrice += price.lastPrice.toDouble();
        totalPriceData++;
      }

      // if total data already more than 64 break  the data, as heat map only will display 65 data
      if(totalData >= 64) {
        break;
      }
    }

    // add the current price which only in company
    tempData.add(GraphData(date: company.companyLastUpdate!.toLocal(), price: company.companyNetAssetValue!));

    // check current price for minimum, maximum, and average
    if(_minPrice! > company.companyNetAssetValue!) {
      _minPrice = company.companyNetAssetValue!;
    }

    if(_maxPrice! < company.companyNetAssetValue!) {
      _maxPrice = company.companyNetAssetValue!;
    }

    totalPrice += company.companyNetAssetValue!;
    totalPriceData++;
    
    // compute average
    _avgPrice = totalPrice / totalPriceData;
    _numPrice = totalPriceData;

    // sort the temporary data
    tempData.sort((a, b) {
      return a.date.compareTo(b.date);
    });

    // once sorted, then we can put it on map
    for (GraphData data in tempData) {
      _graphData![data.date] = data;
    }
  }

  void _setBrokerSummary(BrokerSummaryModel value) {
    setState(() {
      _brokerSummary = value;
      // check what is current broker summary being selected
      if (_brokerSummarySelected == 'a') {
        _brokerSummaryBuySell = value.brokerSummaryAll;
      }
      else if (_brokerSummarySelected == 'd') {
        _brokerSummaryBuySell = value.brokerSummaryDomestic;
      }
      else if (_brokerSummarySelected == 'f') {
        _brokerSummaryBuySell = value.brokerSummaryForeign;
      }
    });
  }

  Future<void> _getBrokerSummary() async {
    // show loader dialog
    showLoaderDialog(context);

    // get the broker summary
    await _brokerSummaryAPI.getBrokerSummary(_companyData.companyCode, _brokerSummaryDateFrom.toLocal(), _brokerSummaryDateTo.toLocal()).then((resp) {
      _setBrokerSummary(resp);
      // remove the loader dialog
      Navigator.pop(context);
    }).onError((error, stackTrace) {
      // remove the loader dialog
      Navigator.pop(context);
      // show snack bar
      ScaffoldMessenger.of(context).showSnackBar(createSnackBar(message: 'Error when try to get broker data from server'));
      // show error
      debugPrint(error.toString());
      debugPrintStack(stackTrace: stackTrace);
    });
  }

  Future<void> _getTopBroker() async {
    // show loader dialog
    showLoaderDialog(context);

    // get the broker summary
    await _companyApi.getCompanyTopBroker(_companyData.companyCode, _topBrokerDateFrom.toLocal(), _topBrokerDateTo.toLocal()).then((resp) {
      setState(() {
        _topBroker = resp;
      });
      // remove the loader dialog
      Navigator.pop(context);
    }).onError((error, stackTrace) {
      // remove the loader dialog
      Navigator.pop(context);
      // show snack bar
      ScaffoldMessenger.of(context).showSnackBar(createSnackBar(message: 'Error when try to get top broker data from server'));
      // show error
      debugPrint(error.toString());
      debugPrintStack(stackTrace: stackTrace);
    });
  }

  Future<void> _getFundamental() async {
    List<InfoFundamentalsModel> result = [];
    // show loader dialog
    showLoaderDialog(context);

    // get the fundamental data
    await _infoFundamentalAPI.getInfoFundamental(_companyData.companyCode, _quarterSelection).then((resp) {
      Navigator.pop(context);
      result = resp;
    }).onError((error, stackTrace) {
      Navigator.pop(context);
      debugPrintStack(stackTrace: stackTrace);
      ScaffoldMessenger.of(context).showSnackBar(createSnackBar(message: "Error when fetching fundamental data"));
    });

    // set the current info fundamental with the result we got
    setState(() {
      _infoFundamental = result;
    });
  }
}