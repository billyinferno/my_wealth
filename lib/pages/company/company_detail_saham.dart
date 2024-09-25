import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:ionicons/ionicons.dart';
import 'package:my_wealth/_index.g.dart';

class SahamPriceList {
  final DateTime date;
  final int volume;
  final double lastPrice;
  final Color lastPriceColor;
  final double adjustedLowPrice;
  final double adjustedHighPrice;
  final double lowDiff;
  final double highDiff;
  final double? dayDiff;
  final Color dayDiffColor;

  const SahamPriceList({
    required this.date,
    required this.volume,
    required this.lastPrice,
    required this.lastPriceColor,
    required this.adjustedLowPrice,
    required this.adjustedHighPrice,
    required this.lowDiff,
    required this.highDiff,
    required this.dayDiff,
    required this.dayDiffColor,
  });
}

class CompanyDetailSahamPage extends StatefulWidget {
  final Object? companyData;
  const CompanyDetailSahamPage({super.key, required this.companyData});

  @override
  State<CompanyDetailSahamPage> createState() => _CompanyDetailSahamPageState();
}

class _CompanyDetailSahamPageState extends State<CompanyDetailSahamPage>
    with SingleTickerProviderStateMixin {
  final ScrollController _infoController = ScrollController();
  final ScrollController _brokerController = ScrollController();
  final ScrollController _priceController = ScrollController();
  final ScrollController _calendarScrollController = ScrollController();
  final ScrollController _graphScrollController = ScrollController();
  final ScrollController _chipController = ScrollController();
  final ScrollController _fundamentalController = ScrollController();
  final ScrollController _fundamentalItemController = ScrollController();
  final ScrollController _compareController = ScrollController();
  final ScrollController _dividendController = ScrollController();
  final ScrollController _splitController = ScrollController();
  late TabController _tabController;

  late CompanyDetailArgs _companyData;
  late CompanyDetailModel _companyDetail;
  late CompanyDetailModel _otherCompanyDetail;
  late UserLoginInfoModel? _userInfo;
  late BrokerSummaryModel _brokerSummary;
  late BrokerSummaryModel _brokerSummaryGross;
  late BrokerSummaryModel _brokerSummaryNet;
  late CompanyTopBrokerModel _topBroker;
  late BrokerSummaryBuySellModel _brokerSummaryBuySell;
  late BrokerSummaryDateModel _brokerSummaryDate;
  late List<BrokerSummaryAccumulationModel> _brokerSummaryAccumulation;
  late PriceSahamMovingAverageModel _priceMA;
  late PriceSahamMovementModel _priceMovement;
  late List<Map<String, double>> _priceMovementData;
  late List<InfoFundamentalsModel> _infoFundamental;
  late InfoFundamentalsModel _otherInfoFundamental;
  late List<InfoSahamPriceModel> _infoSahamPrice;
  late String _priceSort;
  late List<SahamPriceList> _infoSahamPriceSort;
  final Map<int, List<InfoSahamPriceModel>> _infoSahamPriceData = {};
  late int _currentInfoSahamPrice;
  late String _brokerSummarySelected;
  late Map<DateTime, int> _watchlistDetail;
  late String? _otherCompanyCode;
  late List<SeasonalityModel> _seasonality;
  late BrokerSummaryDailyStatModel _brokerSummaryDailyStat;
  late List<Map<String, double>> _brokerSummaryDailyData;
  late BrokerSummaryDailyStatModel _brokerSummaryMonthlyStat;
  late List<Map<String, double>> _brokerSummaryMonthlyData;
  late String _brokerSummaryDailyMonthlyDataSelected;
  late String _brokerSummaryDailyMonthlyTypeSelected;
  late String _brokerSummaryDailyMonhtlyValueSelected;
  late CompanySahamDividendModel _dividend;
  late List<DateTime> _dividendDate;
  late CompanySahamSplitModel _split;

  final CompanyAPI _companyApi = CompanyAPI();
  final BrokerSummaryAPI _brokerSummaryAPI = BrokerSummaryAPI();
  final PriceAPI _priceAPI = PriceAPI();
  final InfoFundamentalAPI _infoFundamentalAPI = InfoFundamentalAPI();
  final InfoSahamsAPI _infoSahamsAPI = InfoSahamsAPI();
  final WatchlistAPI _watchlistAPI = WatchlistAPI();
  final IndexAPI _indexAPI = IndexAPI();

  final TextStyle _topBrokerHeader = const TextStyle(
    color: accentColor,
    fontWeight: FontWeight.bold,
    fontSize: 10,
  );
  final TextStyle _topBrokerRow = const TextStyle(
    fontSize: 10,
  );
  final Bit _bitData = Bit();

  late DateTime _brokerSummaryDateFrom;
  late DateTime _brokerSummaryDateTo;
  late DateTime _topBrokerDateFrom;
  late DateTime _topBrokerDateTo;

  late Future<bool> _getData;
  late int _userRisk;

  bool _showCurrentPriceComparison = false;
  bool _showNet = true;
  late List<GraphData> _graphData;
  late Map<DateTime, GraphData> _heatMapGraphData;

  late IndexModel _indexCompare;
  late String _indexCompareName;
  late List<IndexPriceModel> _indexComparePrice;
  late Map<DateTime, double> _indexPriceMap;
  late List<GraphData> _indexData;

  late List<WatchlistListModel> _watchlists;
  late bool _isOwned;

  int _numPrice = 0;
  int _bodyPage = 0;
  int _quarterSelection = 5;
  String _quarterSelectionText = "Every Quarter";
  String _graphSelection = "s";

  double? _minPrice;
  double? _maxPrice;
  double? _avgPrice;
  int? _maxVolume;
  int? _maxHigh;
  int? _minLow;

  int? _totalBuyLot;
  double? _totalBuyValue;
  double? _totalBuyAverage;
  int? _totalSellLot;
  double? _totalSellValue;
  double? _totalSellAverage;

  @override
  void initState() {
    super.initState();

    // initialize the tab controller for summary page
    _tabController = TabController(length: 6, vsync: this);

    // convert company arguments
    _companyData = widget.companyData as CompanyDetailArgs;

    // get user information
    _userInfo = UserSharedPreferences.getUserInfo();

    // get user watchlists data
    _watchlists = WatchlistSharedPreferences.getWatchlist(type: "saham");
    _isOwned = false;

    // initialize graph data
    _graphData = [];
    _heatMapGraphData = {};

    // assuming we don't have any watchlist detail
    _watchlistDetail = {};

    // initialize the other company variable that will be used for compare
    _otherCompanyCode = null;
    _otherCompanyDetail = CompanyDetailModel(
        companyId: -1,
        companySymbol: null,
        companyName: '',
        companyType: '',
        companyIndustry: '',
        companySharia: false,
        companyPrices: []);
    _otherInfoFundamental = InfoFundamentalsModel(code: '');

    // initialize the broker summary accumulation as empty list
    _brokerSummaryAccumulation = [];

    // initialize info fundamental with empty array
    _infoFundamental = [];

    // initialize the info price saham
    _infoSahamPrice = [];

    // initialize array and defaulted the sort as ascending
    _infoSahamPriceSort = [];
    _priceSort = "A";

    _infoSahamPriceData.clear();

    // initialize all the info
    _infoSahamPriceData[30] = [];
    _infoSahamPriceData[60] = [];
    _infoSahamPriceData[90] = [];
    _infoSahamPriceData[180] = [];
    _infoSahamPriceData[365] = [];

    // initialize the index information
    _indexComparePrice = [];
    _indexCompareName = "";
    _indexPriceMap = {};
    _indexData = [];

    // initialize dividend date, assume no dividend has been given
    _dividendDate = [];

    // default saham price to 90
    _currentInfoSahamPrice = 90;

    // get the current user risk
    _userRisk = (_userInfo!.risk);

    // get all the data needed during initialization
    _getData = _getInitData();
  }

  @override
  void dispose() {
    _priceController.dispose();
    _calendarScrollController.dispose();
    _graphScrollController.dispose();
    _chipController.dispose();
    _infoController.dispose();
    _brokerController.dispose();
    _fundamentalController.dispose();
    _fundamentalItemController.dispose();
    _compareController.dispose();
    _dividendController.dispose();
    _splitController.dispose();
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // return _generatePage();
    return FutureBuilder(
        future: _getData,
        builder: ((context, snapshot) {
          if (snapshot.hasError) {
            return const CommonErrorPage(errorText: 'Error loading stock data');
          } else if (snapshot.hasData) {
            return _generatePage();
          } else {
            return const CommonLoadingPage();
          }
        }));
  }

  Widget _generatePage() {
    IconData currentIcon = Ionicons.remove;
    double diffPrice = _companyDetail.companyNetAssetValue! - _companyDetail.companyPrevPrice!;

    if (diffPrice > 0) {
      currentIcon = Ionicons.caret_up;
    } else if (diffPrice < 0) {
      currentIcon = Ionicons.caret_down;
    }

    // generate the actual page
    return Scaffold(
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
          Visibility(
            visible: _isOwned,
            child: Container(
              padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
              child: const Icon(
                Ionicons.checkmark,
                color: Colors.green,
              ),
            ),
          ),
          Icon(
            (_companyData.companyFavourite ? Ionicons.star : Ionicons.star_outline),
            color: accentColor,
          ),
          IconButton(
            icon: Icon(
              (_priceSort == "A" ? LucideIcons.arrow_up_a_z : LucideIcons.arrow_down_z_a),
              color: textPrimary,
            ),
            onPressed: (() {
              setState(() {
                if (_priceSort == "A") {
                  _priceSort = "D";
                } else {
                  _priceSort = "A";
                }
    
                // just reversed the list
                _infoSahamPriceSort = _infoSahamPriceSort.reversed.toList();
              });
            }),
          ),
          const SizedBox(
            width: 10,
          ),
        ],
      ),
      body: MySafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Visibility(
              visible: (_companyDetail.companyFCA ?? false),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(5),
                color: secondaryDark,
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Ionicons.warning,
                      color: secondaryLight,
                      size: 10,
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Text(
                      "This company is flagged with Full Call Auction",
                      style: TextStyle(
                        fontSize: 10,
                      ),
                    )
                  ],
                ),
              ),
            ),
            Container(
              color: riskColor(
                value: _companyDetail.companyNetAssetValue!,
                cost: _companyDetail.companyPrevPrice!,
                riskFactor: _userInfo!.risk
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      color: primaryColor,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            (
                              _companyDetail.companySymbol == null ?
                              "" :
                              "(${_companyDetail.companySymbol!}) "
                            ) + _companyData.companyName,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          SingleChildScrollView(
                            controller: _chipController,
                            physics: const AlwaysScrollableScrollPhysics(),
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Visibility(
                                  visible:
                                      (_companyDetail.companyType.isNotEmpty),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: secondaryLight,
                                          style: BorderStyle.solid,
                                          width: 1.0),
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
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                Visibility(
                                  visible: (_companyDetail.companyType
                                          .toLowerCase() !=
                                      _companyDetail.companyIndustry
                                          .toLowerCase()),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: secondaryLight,
                                          style: BorderStyle.solid,
                                          width: 1.0),
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
                          Text(
                            formatCurrency(
                              _companyDetail.companyNetAssetValue!
                            ),
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
                                color: riskColor(
                                  value: _companyDetail.companyNetAssetValue!,
                                  cost: _companyDetail.companyPrevPrice!,
                                  riskFactor: _userInfo!.risk
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Container(
                                padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                                decoration: BoxDecoration(
                                    border: Border(
                                  bottom: BorderSide(
                                    color: riskColor(
                                      value: _companyDetail.companyNetAssetValue!,
                                      cost: _companyDetail.companyPrevPrice!,
                                      riskFactor: _userInfo!.risk
                                    ),
                                    width: 2.0,
                                    style: BorderStyle.solid,
                                  ),
                                )),
                                child: Text(
                                  formatCurrency(
                                    _companyDetail.companyNetAssetValue! - _companyDetail.companyPrevPrice!
                                  )
                                ),
                              ),
                              Expanded(
                                child: Container(),
                              ),
                              const Icon(
                                Ionicons.time_outline,
                                color: primaryLight,
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Text(
                                Globals.dfddMMyyyy.formatDateWithNull(
                                  _companyDetail.companyLastUpdate,
                                )
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              CompanyInfoBox(
                                header: "Volume",
                                headerAlign: MainAxisAlignment.end,
                                child: Text(
                                  formatCurrencyWithNull(
                                    _companyDetail.companyTotalUnit
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              CompanyInfoBox(
                                header: "Frequency",
                                headerAlign: MainAxisAlignment.end,
                                child: Text(
                                  formatIntWithNull(
                                    _companyDetail.companyFrequency
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              CompanyInfoBox(
                                header: "Value",
                                headerAlign: MainAxisAlignment.end,
                                child: Text(
                                  formatIntWithNull(
                                    _companyDetail.companyValue
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 5,
                          ),
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
                              const SizedBox(
                                width: 10,
                              ),
                              CompanyInfoBox(
                                header: "Max ($_numPrice)",
                                headerAlign: MainAxisAlignment.end,
                                child: Text(
                                  formatCurrencyWithNull(_maxPrice!),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
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
                  color: primaryDark,
                  borderColor: primaryLight,
                  textSize: 11,
                  icon: Ionicons.speedometer_outline,
                  onTap: (() {
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
                  color: primaryDark,
                  borderColor: primaryLight,
                  textSize: 11,
                  icon: Ionicons.business_outline,
                  onTap: (() {
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
                  color: primaryDark,
                  borderColor: primaryLight,
                  textSize: 11,
                  icon: Ionicons.list_outline,
                  onTap: (() {
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
                  color: primaryDark,
                  borderColor: primaryLight,
                  textSize: 11,
                  icon: Ionicons.calendar_clear_outline,
                  onTap: (() {
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
                  color: primaryDark,
                  borderColor: primaryLight,
                  textSize: 11,
                  icon: Ionicons.stats_chart_outline,
                  onTap: (() {
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
          ],
        ),
      ),
    );
  }

  Widget _detail() {
    switch (_bodyPage) {
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
          tabAlignment: TabAlignment.start,
          indicatorColor: accentColor,
          indicatorSize: TabBarIndicatorSize.tab,
          labelColor: textPrimary,
          unselectedLabelColor: textPrimary,
          dividerHeight: 0,
          tabs: const <Widget>[
            Tab(text: 'SUMMARY',),
            Tab(text: 'FUNDAMENTAL',),
            Tab(text: 'COMPARE'),
            Tab(text: 'SEASONALITY'),
            Tab(text: 'DIVIDEND'),
            Tab(text: 'SPLIT'),
          ],
        ),
        const SizedBox(height: 10,),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: <Widget>[
              _tabSummaryInfo(),
              _tabFundamentalInfo(),
              _tabCompareInfo(),
              _tabSeasonality(),
              _tabDividend(),
              _tabSplit(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _tabSummaryInfo() {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
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
                    formatCurrencyWithNull(
                      _companyDetail.companyPrevClosingPrice
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                CompanyInfoBox(
                  header: "Adj Close",
                  headerAlign: MainAxisAlignment.end,
                  child: Text(
                    formatCurrencyWithNull(
                      _companyDetail.companyAdjustedClosingPrice
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                CompanyInfoBox(
                  header: "Adj Open",
                  headerAlign: MainAxisAlignment.end,
                  child: Text(
                    formatCurrencyWithNull(
                      _companyDetail.companyAdjustedOpenPrice
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 5,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                CompanyInfoBox(
                  header: "Adj High",
                  headerAlign: MainAxisAlignment.end,
                  child: Text(
                    formatCurrencyWithNull(
                      _companyDetail.companyAdjustedHighPrice
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                CompanyInfoBox(
                  header: "Adj Low",
                  headerAlign: MainAxisAlignment.end,
                  child: Text(
                    formatCurrencyWithNull(
                      _companyDetail.companyAdjustedLowPrice
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                CompanyInfoBox(
                  header: "Capitalization",
                  headerAlign: MainAxisAlignment.end,
                  child: Text(
                    formatCurrencyWithNull(_companyDetail.companyMarketCap),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 5,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                CompanyInfoBox(
                  header: "One Day",
                  headerAlign: MainAxisAlignment.end,
                  child: Text(
                    "${formatDecimalWithNull(
                      _companyDetail.companyDailyReturn,
                      times: 100,
                      decimal: 4
                    )}%",
                    textAlign: TextAlign.right,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                CompanyInfoBox(
                  header: "One Week",
                  headerAlign: MainAxisAlignment.end,
                  child: Text(
                    "${formatDecimalWithNull(
                      _companyDetail.companyWeeklyReturn,
                      times: 100,
                      decimal: 4
                    )}%",
                    textAlign: TextAlign.right,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                CompanyInfoBox(
                  header: "One Month",
                  headerAlign: MainAxisAlignment.end,
                  child: Text(
                    "${formatDecimalWithNull(
                      _companyDetail.companyMonthlyReturn,
                      times: 100,
                      decimal: 4
                    )}%",
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 5,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                CompanyInfoBox(
                  header: "Three Months",
                  headerAlign: MainAxisAlignment.end,
                  child: Text(
                    "${formatDecimalWithNull(
                      _companyDetail.companyQuarterlyReturn,
                      times: 100,
                      decimal: 4
                    )}%",
                    textAlign: TextAlign.right,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                CompanyInfoBox(
                  header: "Six Months",
                  headerAlign: MainAxisAlignment.end,
                  child: Text(
                    "${formatDecimalWithNull(
                      _companyDetail.companySemiAnnualReturn,
                      times: 100,
                      decimal: 4,
                    )}%",
                    textAlign: TextAlign.right,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                CompanyInfoBox(
                  header: "One Year",
                  headerAlign: MainAxisAlignment.end,
                  child: Text(
                    "${formatDecimalWithNull(
                      _companyDetail.companyYearlyReturn,
                      times: 100,
                      decimal: 4,
                    )}%",
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 5,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                CompanyInfoBox(
                  header: "Three Years",
                  headerAlign: MainAxisAlignment.end,
                  child: Text(
                    "${formatDecimalWithNull(
                      _companyDetail.companyThreeYear,
                      times: 100,
                      decimal: 4,
                    )}%",
                    textAlign: TextAlign.right,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                CompanyInfoBox(
                  header: "Five Years",
                  headerAlign: MainAxisAlignment.end,
                  child: Text(
                    "${formatDecimalWithNull(
                      _companyDetail.companyFiveYear,
                      times: 100,
                      decimal: 4,
                    )}%",
                    textAlign: TextAlign.right,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                CompanyInfoBox(
                  header: "Ten Years",
                  headerAlign: MainAxisAlignment.end,
                  child: Text(
                    "${formatDecimalWithNull(
                      _companyDetail.companyTenYear,
                      times: 100,
                      decimal: 4,
                    )}%",
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 5,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                CompanyInfoBox(
                  header: "MTD",
                  headerAlign: MainAxisAlignment.end,
                  child: Text(
                    "${formatDecimalWithNull(
                      _companyDetail.companyMtd,
                      times: 100,
                      decimal: 4,
                    )}%",
                    textAlign: TextAlign.right,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                CompanyInfoBox(
                  header: "YTD",
                  headerAlign: MainAxisAlignment.end,
                  child: Text(
                    "${formatDecimalWithNull(
                      _companyDetail.companyYtdReturn,
                      times: 100,
                      decimal: 4,
                    )}%",
                    textAlign: TextAlign.right,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                const Expanded(
                  child: SizedBox(),
                ),
              ],
            ),
            const SizedBox(
              height: 5,
            ),
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
                      okayColor: accentColor)
                    .show(context);
                  }),
                  child: Text(
                    formatDecimalWithNull(
                      _companyDetail.companyPer,
                      decimal: 4,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                CompanyInfoBox(
                  header: "PER Annual",
                  headerAlign: MainAxisAlignment.end,
                  child: Text(
                    formatDecimalWithNull(
                      _companyDetail.companyPerAnnualized,
                      decimal: 4
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                CompanyInfoBox(
                  header: "Beta 1Y",
                  onTap: (() async {
                    await ShowInfoDialog(
                      title: "Beta 1 Year",
                      text: "A ratio that measures the risk or volatility of a company's share price in comparison to the market as a whole. Beta (1 Year) is calculated using one year of weekly returns.",
                      okayColor: accentColor)
                    .show(context);
                  }),
                  headerAlign: MainAxisAlignment.end,
                  child: Text(
                    formatDecimalWithNull(
                      _companyDetail.companyBetaOneYear,
                      decimal: 4,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 5,
            ),
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
                    formatDecimalWithNull(
                      _companyDetail.companyPbr,
                      decimal: 4,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                CompanyInfoBox(
                  header: "PSR Annual",
                  headerAlign: MainAxisAlignment.end,
                  onTap: (() async {
                    await ShowInfoDialog(
                      title: "Price–sales ratio (Annualized)",
                      text:
                          "PSR, is a valuation metric for stocks. It is calculated by dividing the company's market capitalization by the revenue in the most recent year; or, equivalently, divide the per-share stock price by the per-share revenue.",
                      okayColor: accentColor,
                    ).show(context);
                  }),
                  child: Text(
                    formatDecimalWithNull(
                      _companyDetail.companyPsrAnnualized,
                      decimal: 4,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                CompanyInfoBox(
                  header: "PCFR Annual",
                  headerAlign: MainAxisAlignment.end,
                  onTap: (() async {
                    await ShowInfoDialog(
                      title: "Price-to-Cash Flow (P/CF) Ratio",
                      text:
                          " The price-to-cash flow (P/CF) ratio is a stock valuation indicator or multiple that measures the value of a stock’s price relative to its operating cash flow per share. The ratio uses operating cash flow (OCF), which adds back non-cash expenses such as depreciation and amortization to net income.\n\nP/CF is especially useful for valuing stocks that have positive cash flow but are not profitable because of large non-cash charges.",
                      okayColor: accentColor,
                    ).show(context);
                  }),
                  child: Text(
                    formatDecimalWithNull(
                      _companyDetail.companyPcfrAnnualized,
                      decimal: 4,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 5,
            ),
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
                const SizedBox(
                  width: 10,
                ),
                CompanyInfoBox(
                  header: "MA8",
                  headerAlign: MainAxisAlignment.end,
                  child: Text(
                    formatIntWithNull(_priceMA.priceSahamMa.priceSahamMa8),
                    textAlign: TextAlign.right,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
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
            const SizedBox(
              height: 5,
            ),
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
                const SizedBox(
                  width: 10,
                ),
                CompanyInfoBox(
                  header: "MA30",
                  headerAlign: MainAxisAlignment.end,
                  child: Text(
                    formatIntWithNull(_priceMA.priceSahamMa.priceSahamMa30),
                    textAlign: TextAlign.right,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
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

  Widget _tabFundamentalInfo() {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
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
                    builder: ((BuildContext context) {
                      return MySafeArea(
                        child: CupertinoActionSheet(
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
                    }),
                  );

                  // check if quarter is null or not?
                  if (quarter != null) {
                    // set the quarter selection
                    _quarterSelection = quarter!;
                    // set the quarter selection text
                    switch (_quarterSelection) {
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
            const SizedBox(
              height: 15,
            ),
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
                    )),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    controller: _fundamentalItemController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: List<Widget>.generate(_infoFundamental.length,
                          (index) {
                        return SizedBox(
                            width: 85,
                            child: _fundamentalItem(
                                fundamental: _infoFundamental[index]));
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

  Widget _tabCompareInfo() {
    return Container(
      padding: const EdgeInsets.fromLTRB(5, 5, 5, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              const Expanded(
                  child: CompareFields(
                      color: primaryDark,
                      borderColor: primaryLight,
                      text: "Code")),
              Expanded(
                  child: CompareFields(
                      color: primaryDark,
                      borderColor: accentColor,
                      text: _companyDetail.companySymbol!,
                      textAlign: TextAlign.center)),
              Expanded(
                child: InkWell(
                    onTap: (() async {
                      await Navigator.pushNamed(
                              context, '/company/detail/saham/find',
                              arguments: _companyDetail.companySymbol!)
                          .then((value) async {
                        // check if value is not null?
                        if (value != null) {
                          // means we already got our other company code, we can call API to find the company
                          _otherCompanyCode = value as String;

                          // get the company detail information
                          await _getCompanyDetail();

                          setState(() {
                            // set state to rebuild the widget
                          });
                        }
                      });
                    }),
                    child: CompareFields(
                        color: primaryDark,
                        borderColor: extendedLight,
                        text: (_otherCompanyCode ?? '+'),
                        textAlign: TextAlign.center)),
              ),
            ],
          ),
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: CompareFields(
                    color: Colors.transparent,
                    borderColor: Colors.transparent,
                    text: "Info",
                    fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: CompareFields(
                    color: Colors.transparent,
                    borderColor: Colors.transparent,
                    text: "",
                    fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: CompareFields(
                    color: Colors.transparent,
                    borderColor: Colors.transparent,
                    text: "",
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: _compareController,
              physics: const AlwaysScrollableScrollPhysics(),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        CompareFields(
                          color: primaryDark,
                          borderColor: primaryLight,
                          text: "Last Price",
                          fontWeight: FontWeight.bold
                        ),
                        CompareFields(
                          color: primaryDark,
                          borderColor: primaryLight,
                          text: "One Year",
                          fontWeight: FontWeight.bold
                        ),
                        CompareFields(
                          color: primaryDark,
                          borderColor: primaryLight,
                          text: "Three Year",
                          fontWeight: FontWeight.bold
                        ),
                        CompareFields(
                          color: primaryDark,
                          borderColor: primaryLight,
                          text: "Five Year",
                          fontWeight: FontWeight.bold
                        ),
                        CompareFields(
                          color: primaryDark,
                          borderColor: primaryLight,
                          text: "Ten Year",
                          fontWeight: FontWeight.bold
                        ),
                        CompareFields(
                          color: primaryDark,
                          borderColor: primaryLight,
                          text: "Period",
                          fontWeight: FontWeight.bold
                        ),
                        CompareFields(
                          color: Colors.transparent,
                          borderColor: Colors.transparent,
                          text: "Balance Sheet",
                          fontWeight: FontWeight.bold
                        ),
                        CompareFields(
                          color: primaryDark,
                          borderColor: primaryLight,
                          text: "Cash",
                          fontWeight: FontWeight.bold
                        ),
                        CompareFields(
                          color: primaryDark,
                          borderColor: primaryLight,
                          text: "Total Asset",
                          fontWeight: FontWeight.bold
                        ),
                        CompareFields(
                          color: primaryDark,
                          borderColor: primaryLight,
                          text: "S.T.Borrow",
                          fontWeight: FontWeight.bold
                        ),
                        CompareFields(
                          color: primaryDark,
                          borderColor: primaryLight,
                          text: "L.T.Borrow",
                          fontWeight: FontWeight.bold
                        ),
                        CompareFields(
                          color: primaryDark,
                          borderColor: primaryLight,
                          text: "Total Equity",
                          fontWeight: FontWeight.bold
                        ),
                        CompareFields(
                          color: Colors.transparent,
                          borderColor: Colors.transparent,
                          text: "Income Stmt",
                          fontWeight: FontWeight.bold
                        ),
                        CompareFields(
                          color: primaryDark,
                          borderColor: primaryLight,
                          text: "Revenue",
                          fontWeight: FontWeight.bold
                        ),
                        CompareFields(
                          color: primaryDark,
                          borderColor: primaryLight,
                          text: "Gross Profit",
                          fontWeight: FontWeight.bold
                        ),
                        CompareFields(
                          color: primaryDark,
                          borderColor: primaryLight,
                          text: "Opr Profit",
                          fontWeight: FontWeight.bold
                        ),
                        CompareFields(
                          color: primaryDark,
                          borderColor: primaryLight,
                          text: "Net Profit",
                          fontWeight: FontWeight.bold
                        ),
                        CompareFields(
                          color: primaryDark,
                          borderColor: primaryLight,
                          text: "EBITDA",
                          fontWeight: FontWeight.bold
                        ),
                        CompareFields(
                          color: primaryDark,
                          borderColor: primaryLight,
                          text: "Int Expense",
                          fontWeight: FontWeight.bold
                        ),
                        CompareFields(
                          color: Colors.transparent,
                          borderColor: Colors.transparent,
                          text: "Ratio",
                          fontWeight: FontWeight.bold
                        ),
                        CompareFields(
                          color: primaryDark,
                          borderColor: primaryLight,
                          text: "EPS",
                          fontWeight: FontWeight.bold
                        ),
                        CompareFields(
                          color: primaryDark,
                          borderColor: primaryLight,
                          text: "PER",
                          fontWeight: FontWeight.bold
                        ),
                        CompareFields(
                          color: primaryDark,
                          borderColor: primaryLight,
                          text: "PER Annual",
                          fontWeight: FontWeight.bold
                        ),
                        CompareFields(
                          color: primaryDark,
                          borderColor: primaryLight,
                          text: "Beta 1Y",
                          fontWeight: FontWeight.bold
                        ),
                        CompareFields(
                          color: primaryDark,
                          borderColor: primaryLight,
                          text: "BVPS",
                          fontWeight: FontWeight.bold
                        ),
                        CompareFields(
                          color: primaryDark,
                          borderColor: primaryLight,
                          text: "PBV",
                          fontWeight: FontWeight.bold
                        ),
                        CompareFields(
                          color: primaryDark,
                          borderColor: primaryLight,
                          text: "PSR Annual",
                          fontWeight: FontWeight.bold
                        ),
                        CompareFields(
                          color: primaryDark,
                          borderColor: primaryLight,
                          text: "PCFR Annual",
                          fontWeight: FontWeight.bold
                        ),
                        CompareFields(
                          color: primaryDark,
                          borderColor: primaryLight,
                          text: "ROA",
                          fontWeight: FontWeight.bold
                        ),
                        CompareFields(
                          color: primaryDark,
                          borderColor: primaryLight,
                          text: "ROE",
                          fontWeight: FontWeight.bold
                        ),
                        CompareFields(
                          color: primaryDark,
                          borderColor: primaryLight,
                          text: "EV/EBITDA",
                          fontWeight: FontWeight.bold
                        ),
                        CompareFields(
                          color: primaryDark,
                          borderColor: primaryLight,
                          text: "Debt/Equity",
                          fontWeight: FontWeight.bold
                        ),
                        CompareFields(
                          color: primaryDark,
                          borderColor: primaryLight,
                          text: "Debt/Total Cap",
                          fontWeight: FontWeight.bold
                        ),
                        CompareFields(
                          color: primaryDark,
                          borderColor: primaryLight,
                          text: "Debt/EBITDA",
                          fontWeight: FontWeight.bold
                        ),
                        CompareFields(
                          color: primaryDark,
                          borderColor: primaryLight,
                          text: "EBITDA/IntExp",
                          fontWeight: FontWeight.bold
                        ),
                      ],
                    ),
                  ),
                  _companyCompareInfo(),
                  _otherCompanyCompareInfo(),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _tabSeasonality() {
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
          ),
        ),
      ],
    );
  }

  Widget _tabDividend() {
    // check if stock never giving dividend before
    if (_dividend.dividend.isEmpty) {
      return Center(
        child: Text(
            "Stock ${_companyData.companyCode} never given any dividend before"),
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
              controller: _dividendController,
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  ..._generateDividend(),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          const Center(
            child: Text(
              "Dividend data provide by IDX",
              style: TextStyle(
                fontSize: 9,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _itemDividend({
    required String cumDate,
    required String exDate,
    required String recordDate,
    required String paymentDate,
    required String cashDividend,
    required String price,
    required String priceDate,
    required String note,
  }) {
    const TextStyle styleBold = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 10,
    );

    const TextStyle styleNormal = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 10,
    );

    return Container(
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
      decoration: const BoxDecoration(
          border: Border(
              bottom: BorderSide(
        color: primaryLight,
        width: 1.0,
        style: BorderStyle.solid,
      ))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              const Expanded(
                child: Text(
                  "Dividend",
                  style: styleBold,
                ),
              ),
              Expanded(
                child: Text(
                  cashDividend,
                  style: styleNormal,
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 5,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Text(
                  "Price ($priceDate)",
                  style: styleBold,
                ),
              ),
              Expanded(
                child: Text(
                  price,
                  style: styleNormal,
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 5,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              const Expanded(
                child: Text(
                  "Cum Date",
                  style: styleBold,
                ),
              ),
              Expanded(
                child: Text(
                  cumDate,
                  style: styleNormal,
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 5,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              const Expanded(
                child: Text(
                  "Ex Date",
                  style: styleBold,
                ),
              ),
              Expanded(
                child: Text(
                  exDate,
                  style: styleNormal,
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 5,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              const Expanded(
                child: Text(
                  "Record Date",
                  style: styleBold,
                ),
              ),
              Expanded(
                child: Text(
                  recordDate,
                  style: styleNormal,
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 5,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              const Expanded(
                child: Text(
                  "Payment Date",
                  style: styleBold,
                ),
              ),
              Expanded(
                child: Text(
                  paymentDate,
                  style: styleNormal,
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 5,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              const Expanded(
                child: Text(
                  "Note",
                  style: styleBold,
                ),
              ),
              Expanded(
                child: Text(
                  note,
                  style: styleNormal,
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _generateDividend() {
    List<Widget> ret = [];

    // loop thru dividend list
    for (Dividend dividend in _dividend.dividend) {
      // add dividend date to the dividen date list
      _dividendDate.add(dividend.recordDate.toLocal());

      // generate item dividend
      ret.add(_itemDividend(
        cumDate: Globals.dfddMMyy.formatDateWithNull(dividend.cumDividend),
        exDate: Globals.dfddMMyy.formatLocal(dividend.exDividend),
        recordDate: Globals.dfddMMyy.formatLocal(dividend.recordDate),
        paymentDate: Globals.dfddMMyy.formatLocal(dividend.paymentDate.toLocal()),
        cashDividend: formatCurrency(dividend.cashDividend.toDouble()),
        price: formatCurrencyWithNull(dividend.price),
        priceDate: Globals.dfddMMyy.formatDateWithNull(dividend.priceDate),
        note: dividend.note,
      ));
    }

    return ret;
  }

  Widget _tabSplit() {
    // check if stock never been split before
    if (_split.splits.isEmpty) {
      return Center(
        child: Text(
            "Stock ${_companyData.companyCode} never been splitted before"),
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
              controller: _splitController,
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  ..._generateSplit(),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          const Center(
            child: Text(
              "Stock split data provide by IDX",
              style: TextStyle(
                fontSize: 9,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _itemSplit({
    required String ratio,
    required String splitFactor,
    required String listedShares,
    required String listingDate,
  }) {
    const TextStyle styleBold = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 10,
    );

    const TextStyle styleNormal = TextStyle(
      fontSize: 10,
    );

    return Container(
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
      decoration: const BoxDecoration(
          border: Border(
              bottom: BorderSide(
        color: primaryLight,
        width: 1.0,
        style: BorderStyle.solid,
      ))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              const Expanded(
                child: Text(
                  "Ratio",
                  style: styleBold,
                ),
              ),
              Expanded(
                child: Text(
                  ratio,
                  style: styleNormal,
                  textAlign: TextAlign.right,
                ),
              )
            ],
          ),
          const SizedBox(
            height: 5,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              const Expanded(
                child: Text(
                  "Split Factor",
                  style: styleBold,
                ),
              ),
              Expanded(
                child: Text(
                  splitFactor,
                  style: styleNormal,
                  textAlign: TextAlign.right,
                ),
              )
            ],
          ),
          const SizedBox(
            height: 5,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              const Expanded(
                child: Text(
                  "Listed Shares",
                  style: styleBold,
                ),
              ),
              Expanded(
                child: Text(
                  listedShares,
                  style: styleNormal,
                  textAlign: TextAlign.right,
                ),
              )
            ],
          ),
          const SizedBox(
            height: 5,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              const Expanded(
                child: Text(
                  "Listing Date",
                  style: styleBold,
                ),
              ),
              Expanded(
                child: Text(
                  listingDate,
                  style: styleNormal,
                  textAlign: TextAlign.right,
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _generateSplit() {
    List<Widget> ret = [];

    // loop thru split data
    for (SplitInfo split in _split.splits) {
      ret.add(_itemSplit(
        ratio: split.ratio,
        splitFactor: formatDecimal(split.splitFactor, decimal: 2),
        listedShares: formatCurrency(
          split.listedShares,
          shorten: false,
          decimalNum: 2,
        ),
        listingDate: Globals.dfddMMyyyy.formatLocal(split.listingDate),
      ));
    }

    return ret;
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
            color: secondaryLight),
        _text(
          text: formatIntWithNull(
            fundamental.lastPrice,
            showDecimal: false
          ),
          bgColor: primaryDark,
        ),
        _text(
          text: formatIntWithNull(fundamental.shareOut,),
          bgColor: primaryDark,
        ),
        _text(
          text: formatIntWithNull(
            fundamental.marketCap,
          ),
          bgColor: primaryDark,
        ),
        _text(
          text: "",
          fontWeight: FontWeight.bold,
          bgColor: primaryDark,
        ),
        _text(
          text: formatIntWithNull(fundamental.cash,),
          bgColor: primaryDark,
        ),
        _text(
          text: formatIntWithNull(fundamental.totalAsset,),
          bgColor: primaryDark,
        ),
        _text(
          text: formatIntWithNull(fundamental.stBorrowing,),
          bgColor: primaryDark,
        ),
        _text(
          text: formatIntWithNull(fundamental.ltBorrowing,),
          bgColor: primaryDark,
        ),
        _text(
          text: formatIntWithNull(fundamental.totalEquity,),
          bgColor: primaryDark,
        ),
        _text(
          text: "",
          fontWeight: FontWeight.bold,
          bgColor: primaryDark,
        ),
        _text(
          text: formatIntWithNull(fundamental.revenue,),
          bgColor: primaryDark,
        ),
        _text(
          text: formatIntWithNull(fundamental.grossProfit,),
          bgColor: primaryDark,
        ),
        _text(
          text: formatIntWithNull(fundamental.operatingProfit,),
          bgColor: primaryDark,
        ),
        _text(
          text: formatIntWithNull(fundamental.netProfit,),
          bgColor: primaryDark,
        ),
        _text(
          text: formatIntWithNull(fundamental.ebitda,),
          bgColor: primaryDark,
        ),
        _text(
          text: formatIntWithNull(fundamental.interestExpense,),
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

  Widget _text(
      {required String text,
      FontWeight? fontWeight,
      double? fontSize,
      Color? color,
      Color? bgColor}) {
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
            padding: const EdgeInsets.fromLTRB(5, 10, 5, 0),
            child: SingleChildScrollView(
              controller: _brokerController,
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  AveragePriceChart(
                    company: _companyDetail,
                    price: _infoSahamPrice,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  BrokerSummaryDistributionChart(
                      data: _brokerSummaryAccumulation),
                  const SizedBox(
                    height: 20,
                  ),
                  const Center(
                    child: Text(
                      "Broker Summary",
                      style: TextStyle(
                        color: secondaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  InkWell(
                    onTap: (() async {
                      // check for the max date to avoid any assertion that the initial date range
                      // is more than the lastDate
                      DateTime maxDate =
                          _brokerSummaryDate.brokerMaxDate.toLocal();
                      if (maxDate.isBefore(_brokerSummaryDateTo.toLocal())) {
                        maxDate = _brokerSummaryDateTo;
                      }

                      DateTimeRange? result = await showDateRangePicker(
                        context: context,
                        firstDate: _brokerSummaryDate.brokerMinDate.toLocal(),
                        lastDate: maxDate.toLocal(),
                        initialDateRange: DateTimeRange(
                            start: _brokerSummaryDateFrom.toLocal(),
                            end: _brokerSummaryDateTo.toLocal()),
                        confirmText: 'Done',
                        currentDate: _companyDetail.companyLastUpdate,
                        initialEntryMode: DatePickerEntryMode.calendarOnly,
                      );

                      // check if we got the result or not?
                      if (result != null) {
                        // check whether the result start and end is different date, if different then we need to get new broker summary data.
                        if ((result.start.compareTo(_brokerSummaryDateFrom) !=
                                0) ||
                            (result.end.compareTo(_brokerSummaryDateTo) != 0)) {
                          // set the broker from and to date
                          _brokerSummaryDateFrom = result.start;
                          _brokerSummaryDateTo = result.end;

                          // get the broker summary
                          await _getBrokerSummary().onError(
                            (error, stackTrace) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    createSnackBar(message: error.toString()));
                              }
                            },
                          );
                        }
                      }
                    }),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        const SizedBox(
                          width: 20,
                        ),
                        Text(
                          Globals.dfddMMyyyy.formatLocal(
                            _brokerSummary.brokerSummaryFromDate
                          ),
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
                          Globals.dfddMMyyyy.formatLocal(
                            _brokerSummary.brokerSummaryToDate
                          ),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: secondaryLight,
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        const Icon(
                          Ionicons.calendar_outline,
                          size: 15,
                          color: secondaryLight,
                        ),
                        Expanded(child: Container()),
                        const Text(
                          "Net",
                          style: TextStyle(
                            color: textPrimary,
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(
                          width: 50,
                          height: 25,
                          child: FittedBox(
                            child: CupertinoSwitch(
                              value: _showNet,
                              activeTrackColor: accentColor,
                              onChanged: ((value) {
                                _showNet = value;

                                if (_showNet) {
                                  _setBrokerSummary(_brokerSummaryNet);
                                } else {
                                  _setBrokerSummary(_brokerSummaryGross);
                                }
                              }),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
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
                          if (selectedValue == "a") {
                            _brokerSummaryBuySell =
                                _brokerSummary.brokerSummaryAll;
                            _brokerSummarySelected = "a";
                          } else if (selectedValue == "d") {
                            _brokerSummaryBuySell =
                                _brokerSummary.brokerSummaryDomestic;
                            _brokerSummarySelected = "d";
                          } else if (selectedValue == "f") {
                            _brokerSummaryBuySell =
                                _brokerSummary.brokerSummaryForeign;
                            _brokerSummarySelected = "f";
                          }
                          _calculateBrokerSummary();
                        });
                      }),
                      groupValue: _brokerSummarySelected,
                      selectedColor: secondaryColor,
                      borderColor: secondaryDark,
                      pressedColor: primaryDark,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    decoration: BoxDecoration(
                        border: Border.all(
                            color: primaryLight,
                            style: BorderStyle.solid,
                            width: 1.0),
                        color: primaryDark),
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
                                  child: _tableRow(
                                      brokerCode: "BY",
                                      lot: "B.lot",
                                      value: "B.val",
                                      average: "B.avg",
                                      isBold: true,
                                      backgroundColor: secondaryDark,
                                      enableTab: false)),
                              ...List<Widget>.generate(
                                10,
                                (index) {
                                  if (_brokerSummaryBuySell
                                          .brokerSummaryBuy.length >
                                      index) {
                                    return _tableRow(
                                      brokerCode: _brokerSummaryBuySell.brokerSummaryBuy[index].brokerSummaryID!,
                                      lot: formatIntWithNull(
                                        _brokerSummaryBuySell.brokerSummaryBuy[index].brokerSummaryLot,
                                        checkThousand: true,
                                        showDecimal: false
                                      ),
                                      value: formatCurrencyWithNull(
                                        _brokerSummaryBuySell.brokerSummaryBuy[index].brokerSummaryValue,
                                        checkThousand: true,
                                        showDecimal: false
                                      ),
                                      average: formatCurrencyWithNull(
                                        _brokerSummaryBuySell.brokerSummaryBuy[index].brokerSummaryAverage,
                                        showDecimal: false
                                      ),
                                    );
                                  } else {
                                    return _tableRow(
                                      brokerCode: "-",
                                      lot: "-",
                                      value: "-",
                                      average: "-",
                                      enableTab: false,
                                    );
                                  }
                                },
                              ),
                              Container(
                                child: _tableRow(
                                  brokerCode: "Σ",
                                  lot: formatIntWithNull(
                                    _totalBuyLot,
                                    checkThousand: true,
                                    showDecimal: false
                                  ),
                                  value: formatCurrencyWithNull(
                                    _totalBuyValue,
                                    checkThousand: true,
                                    showDecimal: false
                                  ),
                                  average: formatCurrencyWithNull(
                                    _totalBuyAverage,
                                    checkThousand:false,
                                    showDecimal:false
                                  ),
                                  isBold: true,
                                  backgroundColor: secondaryDark,
                                  enableTab: false,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                  child: _tableRow(
                                      brokerCode: "SY",
                                      lot: "S.lot",
                                      value: "S.val",
                                      average: "S.avg",
                                      isBold: true,
                                      backgroundColor: Colors.green[900],
                                      enableTab: false)),
                              ...List<Widget>.generate(
                                10,
                                (index) {
                                  if (_brokerSummaryBuySell.brokerSummarySell.length > index) {
                                    return _tableRow(
                                      brokerCode: _brokerSummaryBuySell.brokerSummarySell[index].brokerSummaryID!,
                                      lot: formatIntWithNull(
                                        _brokerSummaryBuySell.brokerSummarySell[index].brokerSummaryLot,
                                        checkThousand: true,
                                        showDecimal: false
                                      ),
                                      value: formatCurrencyWithNull(
                                        _brokerSummaryBuySell.brokerSummarySell[index].brokerSummaryValue,
                                        checkThousand: true,
                                        showDecimal: false
                                      ),
                                      average: formatCurrencyWithNull(
                                        _brokerSummaryBuySell.brokerSummarySell[index].brokerSummaryAverage,
                                        showDecimal: false
                                      ),
                                    );
                                  } else {
                                    return _tableRow(
                                      brokerCode: "-",
                                      lot: "-",
                                      value: "-",
                                      average: "-",
                                      enableTab: false,
                                    );
                                  }
                                },
                              ),
                              Container(
                                child: _tableRow(
                                  brokerCode: "Σ",
                                  lot: formatIntWithNull(
                                    _totalSellLot,
                                    checkThousand: true,
                                    showDecimal: false
                                  ),
                                  value: formatCurrencyWithNull(
                                    _totalSellValue,
                                    checkThousand: true,
                                    showDecimal: false
                                  ),
                                  average: formatCurrencyWithNull(
                                    _totalSellAverage,
                                    showDecimal: false
                                  ),
                                  isBold: true,
                                  backgroundColor: Colors.green[900],
                                  enableTab: false,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Center(
                    child: Text(
                      "Top Broker",
                      style: TextStyle(
                        color: secondaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  InkWell(
                    onTap: (() async {
                      // check for the max date to avoid any assertion that the initial date range
                      // is more than the lastDate
                      DateTime maxDate =
                          _brokerSummaryDate.brokerMaxDate.toLocal();
                      DateTime minDate =
                          _brokerSummaryDate.brokerMinDate.toLocal();
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
                        initialDateRange: DateTimeRange(
                            start: _topBrokerDateFrom.toLocal(),
                            end: _topBrokerDateTo.toLocal()),
                        confirmText: 'Done',
                        currentDate:
                            _companyDetail.companyLastUpdate!.toLocal(),
                        initialEntryMode: DatePickerEntryMode.calendarOnly,
                      );

                      // check if we got the result or not?
                      if (result != null) {
                        // check whether the result start and end is different date, if different then we need to get new broker summary data.
                        if ((result.start.compareTo(_topBrokerDateFrom) != 0) ||
                            (result.end.compareTo(_topBrokerDateTo) != 0)) {
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
                          Globals.dfddMMyyyy.formatLocal(
                            _topBroker.brokerMinDate == null ?
                            DateTime.now() :
                            _topBroker.brokerMinDate!
                          ),
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
                          Globals.dfddMMyyyy.formatLocal(
                            _topBroker.brokerMaxDate == null ?
                            DateTime.now() :
                            _topBroker.brokerMaxDate!
                          ),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: secondaryLight,
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        const Icon(
                          Ionicons.calendar_outline,
                          size: 15,
                          color: secondaryLight,
                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: primaryDark,
                      border: Border.all(
                          color: primaryLight,
                          width: 1.0,
                          style: BorderStyle.solid),
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
                            )),
                        const SizedBox(
                          width: 3,
                        ),
                        Expanded(
                            flex: 3,
                            child: Text(
                              "Lot",
                              style: _topBrokerHeader,
                            )),
                        const SizedBox(
                          width: 3,
                        ),
                        Expanded(
                            flex: 3,
                            child: Text(
                              "Avg",
                              style: _topBrokerHeader,
                            )),
                        const SizedBox(
                          width: 3,
                        ),
                        Expanded(
                            flex: 3,
                            child: Text(
                              "Cost",
                              style: _topBrokerHeader,
                            )),
                        const SizedBox(
                          width: 3,
                        ),
                        Expanded(
                            flex: 3,
                            child: Text(
                              "Value",
                              style: _topBrokerHeader,
                            )),
                        const SizedBox(
                          width: 3,
                        ),
                        Expanded(
                            flex: 3,
                            child: Text(
                              "Diff",
                              style: _topBrokerHeader,
                            )),
                      ],
                    ),
                  ),
                  ...List.generate(_topBroker.brokerData.length, (index) {
                    double currentValue =
                        (_topBroker.brokerData[index].brokerSummaryLot *
                                (_companyDetail.companyNetAssetValue ?? 0)) *
                            100;
                    double currentDiff = (currentValue -
                        (_topBroker.brokerData[index].brokerSummaryValue *
                            100));
                    return InkWell(
                      onTap: (() {
                        BrokerDetailArgs args = BrokerDetailArgs(
                            brokerFirmID:
                                _topBroker.brokerData[index].brokerSummaryId);
                        Navigator.pushNamed(context, '/broker/detail',
                            arguments: args);
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
                                ))),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                                flex: 1,
                                child: Text(
                                  _topBroker.brokerData[index].brokerSummaryId,
                                  style: _topBrokerRow,
                                )),
                            const SizedBox(
                              width: 3,
                            ),
                            Expanded(
                                flex: 3,
                                child: Text(
                                  formatIntWithNull(
                                    _topBroker.brokerData[index].brokerSummaryLot,
                                    showDecimal: false
                                  ),
                                  style: _topBrokerRow,
                                )),
                            const SizedBox(
                              width: 3,
                            ),
                            Expanded(
                                flex: 3,
                                child: Text(
                                  formatCurrency(
                                    _topBroker.brokerData[index].brokerSummaryAverage,
                                    showDecimal: false,
                                  ),
                                  style: _topBrokerRow,
                                )),
                            const SizedBox(
                              width: 3,
                            ),
                            Expanded(
                                flex: 3,
                                child: Text(
                                  formatCurrencyWithNull(
                                    _topBroker.brokerData[index].brokerSummaryValue * 100
                                  ),
                                  style: _topBrokerRow,
                                )),
                            const SizedBox(
                              width: 3,
                            ),
                            Expanded(
                                flex: 3,
                                child: Text(
                                  formatCurrency(
                                    currentValue,
                                    showDecimal: false,
                                  ),
                                  style: _topBrokerRow,
                                )),
                            const SizedBox(
                              width: 3,
                            ),
                            Expanded(
                                flex: 3,
                                child: Text(
                                  formatCurrency(
                                    currentDiff,
                                    showDecimal: false,
                                  ),
                                  style: _topBrokerRow.copyWith(
                                    color: (
                                      currentDiff < 0 ?
                                      secondaryColor :
                                      (
                                        currentDiff > 0 ?
                                        Colors.green :
                                        textPrimary
                                      )
                                    )
                                  ),
                                )),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _tableRow(
      {required String brokerCode,
      required String lot,
      required String value,
      required String average,
      Color? textColor,
      bool? isBold,
      Color? backgroundColor,
      double? fontSize,
      bool? enableTab}) {
    Color textColorUse = (textColor ?? Colors.white);
    Color backgroundColorUse = (backgroundColor ?? Colors.transparent);
    bool isBoldUse = (isBold ?? false);
    double fontSizeUse = (fontSize ?? 10);
    bool isTapEnabled = (enableTab ?? true);

    return InkWell(
      onTap: (() {
        // if tap is not enabled then just return
        if (!isTapEnabled) {
          return;
        }

        // otherwise then open the broker detail page
        BrokerDetailArgs args = BrokerDetailArgs(brokerFirmID: brokerCode);
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
            const SizedBox(
              width: 5,
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                child: Text(
                  lot,
                  style: TextStyle(
                    fontWeight:
                        (isBoldUse ? FontWeight.bold : FontWeight.normal),
                    fontSize: fontSizeUse,
                    color: textColorUse,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const SizedBox(
              width: 5,
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                child: Text(
                  value,
                  style: TextStyle(
                    fontWeight:
                        (isBoldUse ? FontWeight.bold : FontWeight.normal),
                    fontSize: fontSizeUse,
                    color: textColorUse,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const SizedBox(
              width: 5,
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                child: Text(
                  average,
                  style: TextStyle(
                    fontWeight:
                        (isBoldUse ? FontWeight.bold : FontWeight.normal),
                    fontSize: fontSizeUse,
                    color: textColorUse,
                  ),
                  overflow: TextOverflow.ellipsis,
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
            const SizedBox(
              width: 10,
            ),
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
                        ))),
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
                            const SizedBox(
                              width: 5,
                            ),
                            Icon(
                              (_priceSort == "A"
                                  ? Ionicons.arrow_up
                                  : Ionicons.arrow_down),
                              size: 10,
                              color: textPrimary,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
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
                          ))),
                          child: const Text(
                            "Price",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        )),
                    const SizedBox(
                      width: 10,
                    ),
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
                          ))),
                          child: const Align(
                            alignment: Alignment.centerRight,
                            child: Icon(
                              Ionicons.swap_vertical,
                              size: 16,
                            ),
                          ),
                        )),
                    const SizedBox(
                      width: 10,
                    ),
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
                          ))),
                          child: const Align(
                            alignment: Alignment.centerRight,
                            child: Icon(
                              Ionicons.pulse_outline,
                              size: 16,
                            ),
                          ),
                        )),
                  ],
                ),
              ),
            ),
          ],
        ),
        Expanded(
          child: ListView.builder(
            controller: _priceController,
            itemCount: _infoSahamPriceSort.length,
            physics: const AlwaysScrollableScrollPhysics(),
            itemBuilder: ((context, index) {
              return Container(
                width: double.infinity,
                color: _infoSahamPriceSort[index].lastPriceColor,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    const SizedBox(
                      width: 5,
                    ),
                    Expanded(
                      child: Container(
                        color: _infoSahamPriceSort[index].dayDiffColor,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            const SizedBox(
                              width: 5,
                            ),
                            Expanded(
                              child: Container(
                                padding:
                                    const EdgeInsets.fromLTRB(10, 5, 10, 5),
                                color: primaryColor,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Expanded(
                                        flex: 3,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Text(
                                              Globals.dfddMMyyyy.formatLocal(
                                                _infoSahamPriceSort[index].date
                                              ),
                                              style: const TextStyle(
                                                fontSize: 12,
                                              ),
                                            ),
                                            Text(
                                              formatIntWithNull(
                                                _infoSahamPriceSort[index].volume,
                                                checkThousand:false,
                                                showDecimal:true
                                              ),
                                              style: const TextStyle(
                                                fontSize: 10,
                                              ),
                                            ),
                                          ],
                                        )),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(
                                        flex: 2,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Text(
                                              formatCurrency(
                                                _infoSahamPriceSort[index].lastPrice,
                                                showDecimal: false
                                              ),
                                              textAlign: TextAlign.right,
                                              style: const TextStyle(
                                                fontSize: 12,
                                              ),
                                            ),
                                            Text(
                                              formatCurrency(
                                                _infoSahamPriceSort[index].adjustedLowPrice,
                                                showDecimal: false
                                              ),
                                              textAlign: TextAlign.right,
                                              style: const TextStyle(
                                                fontSize: 10,
                                              ),
                                            ),
                                            Text(
                                              formatCurrency(
                                                _infoSahamPriceSort[index].adjustedHighPrice,
                                                showDecimal: false
                                              ),
                                              textAlign: TextAlign.right,
                                              style: const TextStyle(
                                                fontSize: 10,
                                              ),
                                            ),
                                          ],
                                        )),
                                    const SizedBox(
                                      width: 10,
                                    ),
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
                                                    color: riskColor(
                                                      value: _companyDetail.companyNetAssetValue!,
                                                      cost: _infoSahamPriceSort[index].lastPrice,
                                                      riskFactor: _userInfo!.risk
                                                    ),
                                                    width: 2.0,
                                                    style: BorderStyle.solid,
                                                  )
                                                )
                                              ),
                                              child: Text(
                                                formatCurrency(
                                                  _companyDetail.companyNetAssetValue! - _infoSahamPriceSort[index].lastPrice,
                                                  showDecimal: false
                                                ),
                                                textAlign: TextAlign.right,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              formatCurrency(
                                                _infoSahamPriceSort[index].lowDiff,
                                                showDecimal: false
                                              ),
                                              textAlign: TextAlign.right,
                                              style: const TextStyle(
                                                fontSize: 10,
                                                color: secondaryColor,
                                              ),
                                            ),
                                            Text(
                                              formatCurrency(
                                                _infoSahamPriceSort[index].highDiff,
                                                showDecimal: false
                                              ),
                                              textAlign: TextAlign.right,
                                              style: const TextStyle(
                                                fontSize: 10,
                                                color: Colors.green,
                                              ),
                                            ),
                                          ],
                                        )),
                                    const SizedBox(
                                      width: 10,
                                    ),
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
                                                    color: _infoSahamPriceSort[index].dayDiffColor,
                                                    width: 2.0,
                                                    style: BorderStyle.solid,
                                                  )
                                                )
                                              ),
                                              child: Text(
                                                formatCurrencyWithNull(
                                                  _infoSahamPriceSort[index].dayDiff,
                                                  showDecimal: false
                                                ),
                                                textAlign: TextAlign.right,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              '${formatDecimalWithNull(
                                                _infoSahamPriceSort[index].lowDiff / _infoSahamPriceSort[index].lastPrice,
                                                times: 100,
                                                decimal: 2,
                                              )}%',
                                              textAlign: TextAlign.right,
                                              style: const TextStyle(
                                                fontSize: 10,
                                                color: secondaryColor,
                                              ),
                                            ),
                                            Text(
                                              '${formatDecimalWithNull(
                                                _infoSahamPriceSort[index].highDiff / _infoSahamPriceSort[index].lastPrice,
                                                times: 100,
                                                decimal: 2,
                                              )}%',
                                              textAlign: TextAlign.right,
                                              style: const TextStyle(
                                                fontSize: 10,
                                                color: Colors.green,
                                              ),
                                            ),
                                          ],
                                        )),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    )
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
                  const SizedBox(
                    height: 5,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Text("Current Price Comparison"),
                      const SizedBox(
                        width: 10,
                      ),
                      CupertinoSwitch(
                          value: _showCurrentPriceComparison,
                          activeTrackColor: accentColor,
                          onChanged: ((val) {
                            setState(() {
                              _showCurrentPriceComparison = val;
                            });
                          }))
                    ],
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  HeatGraph(
                    data: _heatMapGraphData,
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

  Widget _selectedGraph() {
    switch (_graphSelection) {
      case "b":
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            const Center(
              child: Text("Broker Buy Sell"),
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                const SizedBox(
                  width: 20,
                ),
                const SizedBox(
                  width: 50,
                  child: Text(
                    "Period",
                    style: TextStyle(
                      color: secondaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: CupertinoSegmentedControl(
                    children: const {
                      "d": Text("Daily"),
                      "m": Text("Monthly"),
                    },
                    onValueChanged: ((value) {
                      String selectedValue = value.toString();

                      setState(() {
                        _brokerSummaryDailyMonthlyDataSelected = selectedValue;
                        _setBrokerSummaryDailyMonthlyData();
                      });
                    }),
                    groupValue: _brokerSummaryDailyMonthlyDataSelected,
                    selectedColor: Colors.purple,
                    borderColor: Colors.purple[900]!,
                    pressedColor: Colors.purple[900]!,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                const SizedBox(
                  width: 20,
                ),
                const SizedBox(
                  width: 50,
                  child: Text(
                    "Type",
                    style: TextStyle(
                      color: secondaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: CupertinoSegmentedControl(
                    children: const {
                      "a": Text("All"),
                      "d": Text("Domestic"),
                      "f": Text("Foreign"),
                    },
                    onValueChanged: ((value) {
                      String selectedValue = value.toString();

                      setState(() {
                        _brokerSummaryDailyMonthlyTypeSelected = selectedValue;
                        _setBrokerSummaryDailyMonthlyData();
                      });
                    }),
                    groupValue: _brokerSummaryDailyMonthlyTypeSelected,
                    selectedColor: const Color(0xff40826d),
                    borderColor: const Color.fromARGB(255, 24, 49, 41),
                    pressedColor: const Color.fromARGB(255, 24, 49, 41),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                const SizedBox(
                  width: 20,
                ),
                const SizedBox(
                  width: 50,
                  child: Text(
                    "Data",
                    style: TextStyle(
                      color: secondaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: CupertinoSegmentedControl(
                    children: const {
                      "l": Text("Lot"),
                      "v": Text("Value"),
                    },
                    onValueChanged: ((value) {
                      String selectedValue = value.toString();

                      setState(() {
                        _brokerSummaryDailyMonhtlyValueSelected = selectedValue;
                        _setBrokerSummaryDailyMonthlyData();
                      });
                    }),
                    groupValue: _brokerSummaryDailyMonhtlyValueSelected,
                    selectedColor: const Color(0xff007ba7),
                    borderColor: const Color.fromARGB(255, 0, 56, 77),
                    pressedColor: const Color.fromARGB(255, 0, 56, 77),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            MultiLineChart(
              height: 250,
              data: _brokerSummaryDailyData,
              color: const [Colors.green, secondaryDark],
              legend: const ["Buy", "Sell"],
              dateOffset:
                  (_brokerSummaryDailyMonthlyDataSelected == 'd' ? 20 : 4),
            ),
          ],
        );
      case "m":
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Center(
              child: Text(
                  "Monthly Price Movement (${_priceMovement.prices.length} month${_priceMovement.prices.length > 1 ? "s" : ""})"),
            ),
            MultiLineChart(
              height: 250,
              data: _priceMovementData,
              color: const [Colors.orange, Colors.red, Colors.green],
              legend: const ["Average", "Minimum", "Maximum"],
            ),
          ],
        );
      case "c":
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            const Center(
              child: Text("Candlestick and Trade Volume"),
            ),
            const SizedBox(
              height: 5,
            ),
            _dayStatSelection(),
            const SizedBox(
              height: 10,
            ),
            StockChart(
              data: _infoSahamPrice,
              high: _maxHigh!,
              low: _minLow!,
              maxVol: _maxVolume!,
              dateOffset: (_infoSahamPrice.length ~/ 10),
            ),
          ],
        );
      case "s":
      default:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            InkWell(
              onDoubleTap: (() {
                // check if we want to remove the comparison
                if (_indexCompareName.isNotEmpty) {
                  showCupertinoDialog(
                      context: context,
                      builder: ((BuildContext context) {
                        return CupertinoAlertDialog(
                          title: const Text("Clear Compare"),
                          content: Text(
                            "Do you want to clear comparison with $_indexCompareName?"
                          ),
                          actions: <CupertinoDialogAction>[
                            CupertinoDialogAction(
                              onPressed: (() {
                                setState(() {
                                  // clear the index compare data
                                  _indexCompareName = "";
                                  _indexComparePrice.clear();
                                  _indexPriceMap.clear();
                                  _indexData.clear();
                                });

                                // remove the dialog
                                Navigator.pop(context);
                              }),
                              child: const Text(
                                "Yes",
                                style: TextStyle(
                                  color: textPrimary,
                                ),
                              ),
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
                      }));
                }
              }),
              child: Container(
                color: Colors.transparent,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                        "Stock Price${(_indexCompareName.isNotEmpty ? " (Compare with $_indexCompareName)" : "")}"),
                    Visibility(
                        visible: _indexCompareName.isNotEmpty,
                        child: const SizedBox(
                          width: 5,
                        )),
                    Visibility(
                      visible: _indexCompareName.isNotEmpty,
                      child: Container(
                        height: 15,
                        width: 15,
                        color: secondaryDark,
                        child: const Icon(
                          Ionicons.close,
                          size: 12,
                          color: textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Expanded(child: _dayStatSelection()),
                InkWell(
                  onTap: (() async {
                    // go to index list page
                    await Navigator.pushNamed(
                      context,
                      '/index/find'
                    ).then((value) async {
                      if (value != null) {
                        // convert value to company list model
                        _indexCompare = value as IndexModel;
                        _indexCompareName = _indexCompare.indexName;

                        await _getIndexData().onError((error, stackTrace) {
                          // remove the index compare name and price since we will
                          // not be able to perform comparison
                          _indexCompareName = "";
                          _indexComparePrice.clear();
                          _indexPriceMap.clear();
                          _indexData.clear();
                        });
                      }
                    });
                  }),
                  child: Container(
                    height: 28,
                    width: 28,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      color: extendedColor,
                    ),
                    child: const Icon(
                      Ionicons.git_compare_outline,
                      color: textPrimary,
                      size: 15,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 15,
                ),
              ],
            ),
            LineChart(
              data: _graphData,
              compare: _indexData,
              dividend: _dividendDate,
              height: 250,
              watchlist: _watchlistDetail,
              dateOffset: (_graphData.length > 10 ? null : 1),
            ),
          ],
        );
    }
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
            _currentInfoSahamPrice = value;
            _infoSahamPrice = _infoSahamPriceData[_currentInfoSahamPrice]!;
            _generateSahamPriceSort();

            _calculateMinMaxPrice(_infoSahamPrice);
            _generateGraphData(_infoSahamPrice, _companyDetail);
            _generateIndexGraph();
          });
        }),
        groupValue: _currentInfoSahamPrice,
        selectedColor: extendedColor,
        borderColor: Colors.transparent,
        pressedColor: textPrimary,
      ),
    );
  }

  Widget _showGraph() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        const SizedBox(height: 10,),
        SizedBox(
          width: double.infinity,
          child: CupertinoSegmentedControl(
            children: const {
              "s": Text("Daily"),
              "c": Text("Candle"),
              "m": Text("Monthly"),
              "b": Text("Broker"),
            },
            onValueChanged: ((value) {
              String selectedValue = value.toString();

              setState(() {
                _graphSelection = selectedValue;
              });
            }),
            groupValue: _graphSelection,
            selectedColor: secondaryColor,
            borderColor: secondaryDark,
            pressedColor: primaryDark,
          ),
        ),
        const SizedBox(height: 10,),
        Expanded(
          child: SingleChildScrollView(
            controller: _graphScrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            child: _selectedGraph(),
          ),
        ),
      ],
    );
  }

  Widget _companyCompareInfo() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          ..._generateCompareFields(
            company: _companyDetail,
            fundamental: (_infoFundamental.isNotEmpty
              ? _infoFundamental[0]
              : InfoFundamentalsModel(code: _companyDetail.companySymbol!)
            ),
            otherCompany: _otherCompanyDetail,
            otherFundamental: _otherInfoFundamental,
            borderColor: accentColor
          ),
        ],
      ),
    );
  }

  Widget _otherCompanyCompareInfo() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          ..._generateCompareFields(
            company: _otherCompanyDetail,
            fundamental: _otherInfoFundamental,
            otherCompany: _companyDetail,
            otherFundamental: (_infoFundamental.isNotEmpty
              ? _infoFundamental[0]
              : InfoFundamentalsModel(code: _companyDetail.companySymbol!)
            ),
            borderColor: extendedLight
          ),
        ],
      ),
    );
  }

  List<Widget> _generateCompareFields({
    required CompanyDetailModel company,
    required InfoFundamentalsModel fundamental,
    required CompanyDetailModel otherCompany,
    required InfoFundamentalsModel otherFundamental,
    required Color borderColor}
  ) {
    List<Widget> returnWidget = [
      CompareFields(
        color: primaryDark,
        borderColor: borderColor,
        text: formatIntWithNull(
          fundamental.lastPrice,
          showDecimal: false
        )
      ),
      CompareFields(
        color: primaryDark,
        borderColor: borderColor,
        text: "${formatDecimalWithNull(
          company.companyYearlyReturn,
          times: 100,
          decimal: 4
        )}%",
        showCompare: (_otherCompanyCode != null),
        isBigger: ((company.companyYearlyReturn ?? 0) -
          (otherCompany.companyYearlyReturn ?? 0)
        )
      ),
      CompareFields(
        color: primaryDark,
        borderColor: borderColor,
        text: "${formatDecimalWithNull(
          company.companyThreeYear,
          times: 100,
          decimal: 4
        )}%",
        showCompare: (_otherCompanyCode != null),
        isBigger: (
          (company.companyThreeYear ?? 0) - (otherCompany.companyThreeYear ?? 0)
        )
      ),
      CompareFields(
        color: primaryDark,
        borderColor: borderColor,
        text: "${formatDecimalWithNull(
          company.companyFiveYear,
          times: 100,
          decimal: 4
        )}%",
        showCompare: (_otherCompanyCode != null),
        isBigger: (
          (company.companyFiveYear ?? 0) - (otherCompany.companyFiveYear ?? 0)
        )
      ),
      CompareFields(
        color: primaryDark,
        borderColor: borderColor,
        text: "${formatDecimalWithNull(
          company.companyTenYear,
          times: 100,
          decimal: 4
        )}%",
        showCompare: (_otherCompanyCode != null),
        isBigger: (
          (company.companyTenYear ?? 0) - (otherCompany.companyTenYear ?? 0)
        )
      ),
      CompareFields(
        color: primaryDark,
        borderColor: borderColor,
        text: (_otherCompanyCode == null
          ? '-'
          : "${fundamental.period}M ${_otherInfoFundamental.year}"
        )
      ),
      const CompareFields(
        color: Colors.transparent,
        borderColor: Colors.transparent,
        text: ""
      ),
      CompareFields(
        color: primaryDark,
        borderColor: borderColor,
        text: formatIntWithNull(fundamental.cash,),
        showCompare: (_otherCompanyCode != null),
        isBigger: ((fundamental.cash ?? 0) - (otherFundamental.cash ?? 0)).toDouble()
      ),
      CompareFields(
        color: primaryDark,
        borderColor: borderColor,
        text: formatIntWithNull(fundamental.totalAsset,),
        showCompare: (_otherCompanyCode != null),
        isBigger: (
          (fundamental.totalAsset ?? 0) - (otherFundamental.totalAsset ?? 0)
        ).toDouble()
      ),
      CompareFields(
        color: primaryDark,
        borderColor: borderColor,
        text: formatIntWithNull(fundamental.stBorrowing,),
        showCompare: (_otherCompanyCode != null),
        isBigger: (
          (otherFundamental.stBorrowing ?? 0) - (fundamental.stBorrowing ?? 0)
        ).toDouble()
      ),
      CompareFields(
        color: primaryDark,
        borderColor: borderColor,
        text: formatIntWithNull(fundamental.ltBorrowing,),
        showCompare: (_otherCompanyCode != null),
        isBigger: (
          (otherFundamental.ltBorrowing ?? 0) -(fundamental.ltBorrowing ?? 0)
        ).toDouble()
      ),
      CompareFields(
        color: primaryDark,
        borderColor: borderColor,
        text: formatIntWithNull(fundamental.totalEquity,),
        showCompare: (_otherCompanyCode != null),
        isBigger: ((
          fundamental.totalEquity ?? 0) - (otherFundamental.totalEquity ?? 0)
        ).toDouble()
      ),
      const CompareFields(
        color: Colors.transparent,
        borderColor: Colors.transparent,
        text: ""
      ),
      CompareFields(
        color: primaryDark,
        borderColor: borderColor,
        text: formatIntWithNull(fundamental.revenue,),
        showCompare: (_otherCompanyCode != null),
        isBigger: (
          (fundamental.revenue ?? 0) - (otherFundamental.revenue ?? 0)
        ).toDouble()
      ),
      CompareFields(
        color: primaryDark,
        borderColor: borderColor,
        text: formatIntWithNull(fundamental.grossProfit,),
        showCompare: (_otherCompanyCode != null),
        isBigger: (
          (fundamental.grossProfit ?? 0) - (otherFundamental.grossProfit ?? 0)
        ).toDouble()
      ),
      CompareFields(
        color: primaryDark,
        borderColor: borderColor,
        text: formatIntWithNull(fundamental.operatingProfit,),
        showCompare: (_otherCompanyCode != null),
        isBigger: (
          (fundamental.operatingProfit ?? 0) - (otherFundamental.operatingProfit ?? 0)
        ).toDouble()
      ),
      CompareFields(
        color: primaryDark,
        borderColor: borderColor,
        text: formatIntWithNull(fundamental.netProfit,),
        showCompare: (_otherCompanyCode != null),
        isBigger: (
          (fundamental.netProfit ?? 0) - (otherFundamental.netProfit ?? 0)
        ).toDouble()
      ),
      CompareFields(
        color: primaryDark,
        borderColor: borderColor,
        text: formatIntWithNull(fundamental.ebitda,),
        showCompare: (_otherCompanyCode != null),
        isBigger: (
          (fundamental.ebitda ?? 0) - (otherFundamental.ebitda ?? 0)
        ).toDouble()
      ),
      CompareFields(
        color: primaryDark,
        borderColor: borderColor,
        text: formatIntWithNull(fundamental.interestExpense,),
        showCompare: (_otherCompanyCode != null),
        isBigger: (
          (otherFundamental.interestExpense ?? 0) - (fundamental.interestExpense ?? 0)
        ).toDouble()
      ),
      const CompareFields(
        color: Colors.transparent,
        borderColor: Colors.transparent,
        text: ""
      ),
      CompareFields(
        color: primaryDark,
        borderColor: borderColor,
        text: formatDecimalWithNull(
          fundamental.eps,
          decimal: 2
        ),
        showCompare: (_otherCompanyCode != null),
        isBigger: ((fundamental.eps ?? 0) - (otherFundamental.eps ?? 0))
      ),
      CompareFields(
        color: primaryDark,
        borderColor: borderColor,
        text: formatDecimalWithNull(
          fundamental.per,
          decimal: 2
        ),
        showCompare: (_otherCompanyCode != null),
        isBigger: ((otherFundamental.per ?? 0) - (fundamental.per ?? 0))
      ),
      CompareFields(
        color: primaryDark,
        borderColor: borderColor,
        text: formatDecimalWithNull(
          company.companyPerAnnualized,
          decimal: 2
        ),
        showCompare: (_otherCompanyCode != null),
        isBigger: (
          (otherCompany.companyPerAnnualized ?? 0) -
          (company.companyPerAnnualized ?? 0)
        )
      ),
      CompareFields(
        color: primaryDark,
        borderColor: borderColor,
        text: formatDecimalWithNull(
          company.companyBetaOneYear,
          decimal: 2
        ),
        showCompare: (_otherCompanyCode != null),
        isBigger: (
          (company.companyBetaOneYear ?? 0) -
          (otherCompany.companyBetaOneYear ?? 0)
        )
      ),
      CompareFields(
        color: primaryDark,
        borderColor: borderColor,
        text: formatDecimalWithNull(
          fundamental.bvps,
          decimal: 2
        ),
        showCompare: (_otherCompanyCode != null),
        isBigger: ((fundamental.bvps ?? 0) - (otherFundamental.bvps ?? 0))
      ),
      CompareFields(
        color: primaryDark,
        borderColor: borderColor,
        text: formatDecimalWithNull(
          fundamental.pbv,
          decimal: 2
        ),
        showCompare: (_otherCompanyCode != null),
        isBigger: (fundamental.pbv ?? 0).noMinCompare(
          (otherFundamental.pbv ?? 0),
          '<'
        )
      ),
      CompareFields(
        color: primaryDark,
        borderColor: borderColor,
        text: formatDecimalWithNull(
          company.companyPsrAnnualized,
          decimal: 2
        ),
        showCompare: (_otherCompanyCode != null),
        isBigger: ((otherCompany.companyPsrAnnualized ?? 0) -
          (company.companyPsrAnnualized ?? 0)
        )
      ),
      CompareFields(
        color: primaryDark,
        borderColor: borderColor,
        text: formatDecimalWithNull(
          company.companyPcfrAnnualized,
          decimal: 2
        ),
        showCompare: (_otherCompanyCode != null),
        isBigger: (company.companyPcfrAnnualized ?? 0).noMinCompare(
          (otherCompany.companyPcfrAnnualized ?? 0),
          '<'
        )
      ),
      CompareFields(
        color: primaryDark,
        borderColor: borderColor,
        text: formatDecimalWithNull(
          fundamental.roa,
          decimal: 2
        ),
        showCompare: (_otherCompanyCode != null),
        isBigger: ((fundamental.roa ?? 0) - (otherFundamental.roa ?? 0))
      ),
      CompareFields(
        color: primaryDark,
        borderColor: borderColor,
        text: formatDecimalWithNull(
          fundamental.roe,
          decimal: 2
        ),
        showCompare: (_otherCompanyCode != null),
        isBigger: ((fundamental.roe ?? 0) - (otherFundamental.roe ?? 0))
      ),
      CompareFields(
        color: primaryDark,
        borderColor: borderColor,
        text: formatDecimalWithNull(
          fundamental.evEbitda,
          decimal: 2
        ),
        showCompare: (_otherCompanyCode != null),
        isBigger: (fundamental.evEbitda ?? 0).noMinCompare(
          (otherFundamental.evEbitda ?? 0),
          '<'
        )
      ),
      CompareFields(
        color: primaryDark,
        borderColor: borderColor,
        text: formatDecimalWithNull(
          fundamental.debtEquity,
          decimal: 2
        ),
        showCompare: (_otherCompanyCode != null),
        isBigger: (fundamental.debtEquity ?? 0).noMinCompare(
          (otherFundamental.debtEquity ?? 0),
          '<'
        )
      ),
      CompareFields(
        color: primaryDark,
        borderColor: borderColor,
        text: formatDecimalWithNull(
          fundamental.debtTotalcap,
          decimal: 2
        ),
        showCompare: (_otherCompanyCode != null),
        isBigger: (fundamental.debtTotalcap ?? 0).noMinCompare(
          (otherFundamental.debtTotalcap ?? 0),
          '<'
        )
      ),
      CompareFields(
        color: primaryDark,
        borderColor: borderColor,
        text: formatDecimalWithNull(
          fundamental.debtEbitda,
          decimal: 2
        ),
        showCompare: (_otherCompanyCode != null),
        isBigger: (fundamental.debtEbitda ?? 0).noMinCompare(
          (otherFundamental.debtEbitda ?? 0),
          '<'
        )
      ),
      CompareFields(
        color: primaryDark,
        borderColor: borderColor,
        text: formatDecimalWithNull(
          fundamental.ebitdaInterestexpense,
          decimal: 2
        ),
        showCompare: (_otherCompanyCode != null),
        isBigger: ((fundamental.ebitdaInterestexpense ?? 0) -
          (otherFundamental.ebitdaInterestexpense ?? 0)
        )
      ),
    ];

    return returnWidget;
  }

  void _generateGraphData(
    List<InfoSahamPriceModel> prices,
    CompanyDetailModel company
  ) {
    // map the price date on company
    List<GraphData> tempData = [];
    double totalPrice = 0;
    int totalPriceData = 0;

    _minPrice = double.maxFinite;
    _maxPrice = double.minPositive;

    // loop thru all the prices
    for (InfoSahamPriceModel price in prices) {
      tempData.add(GraphData(
          date: price.date.toLocal(), price: price.lastPrice.toDouble()));

      // count for minimum, maximum, and average
      if (_minPrice! > price.lastPrice.toDouble()) {
        _minPrice = price.lastPrice.toDouble();
      }

      if (_maxPrice! < price.lastPrice.toDouble()) {
        _maxPrice = price.lastPrice.toDouble();
      }

      totalPrice += price.lastPrice.toDouble();
      totalPriceData++;
    }

    // add the current price which only in company
    tempData.add(GraphData(
        date: company.companyLastUpdate!.toLocal(),
        price: company.companyNetAssetValue!));

    // check current price for minimum, maximum, and average
    if (_minPrice! > company.companyNetAssetValue!) {
      _minPrice = company.companyNetAssetValue!;
    }

    if (_maxPrice! < company.companyNetAssetValue!) {
      _maxPrice = company.companyNetAssetValue!;
    }

    // compute average
    _avgPrice = 0;
    if (totalPriceData > 0) {
      _avgPrice = totalPrice / totalPriceData;
    }
    _numPrice = totalPriceData;

    // sort the temporary data
    tempData.sort((a, b) {
      return a.date.compareTo(b.date);
    });

    // once sorted, then we can put it on map
    _graphData.clear();
    for (GraphData data in tempData) {
      _graphData.add(data);
    }
  }

  void _setBrokerSummary(BrokerSummaryModel value) {
    setState(() {
      _brokerSummary = value;
      // check what is current broker summary being selected
      if (_brokerSummarySelected == 'a') {
        _brokerSummaryBuySell = value.brokerSummaryAll;
      } else if (_brokerSummarySelected == 'd') {
        _brokerSummaryBuySell = value.brokerSummaryDomestic;
      } else if (_brokerSummarySelected == 'f') {
        _brokerSummaryBuySell = value.brokerSummaryForeign;
      }
      // calculate the broker summary
      _calculateBrokerSummary();
    });
  }

  void _calculateBrokerSummary() {
    int? totalBuyLot;
    double? totalBuyValue;
    double? totalBuyAverage;
    int? totalSellLot;
    double? totalSellValue;
    double? totalSellAverage;

    // we will calculate based on the current broker summary buy sell variable
    for (BrokerSummaryBuySellElement buy
        in _brokerSummaryBuySell.brokerSummaryBuy) {
      // check if total buy still null?
      // if so then initialize it with 0
      totalBuyLot ??= 0;
      totalBuyValue ??= 0;

      // add the total buy for this stock
      totalBuyLot += buy.brokerSummaryLot!;
      totalBuyValue += buy.brokerSummaryValue!;
      totalBuyAverage = totalBuyValue / (totalBuyLot * 100);
    }

    for (BrokerSummaryBuySellElement sell
        in _brokerSummaryBuySell.brokerSummarySell) {
      // check if total buy still null?companyYearlyRisk
      // if so then initialize it with 0
      totalSellLot ??= 0;
      totalSellValue ??= 0;

      // add the total buy for this stock
      totalSellLot += sell.brokerSummaryLot!;
      totalSellValue += sell.brokerSummaryValue!;
      totalSellAverage = totalSellValue / (totalSellLot * 100);
    }

    // move all the result to the class variable
    _totalBuyLot = totalBuyLot;
    _totalBuyValue = totalBuyValue;
    _totalBuyAverage = totalBuyAverage;
    _totalSellLot = totalSellLot;
    _totalSellValue = totalSellValue;
    _totalSellAverage = totalSellAverage;
  }

  void _setBrokerSummaryDailyMonthlyData() {
    // check whether this is daily or monthly
    BrokerSummaryDailyStatModel currentData;
    switch (_brokerSummaryDailyMonthlyDataSelected) {
      case "m":
        currentData = _brokerSummaryMonthlyStat;
        break;
      case "d":
      default:
        currentData = _brokerSummaryDailyStat;
    }
    // check what data we got?
    BrokerSummaryDailyStatItem currentItem;
    switch (_brokerSummaryDailyMonthlyTypeSelected) {
      case "d":
        currentItem = currentData.domestic;
        break;
      case "f":
        currentItem = currentData.foreign;
        break;
      case "a":
      default:
        currentItem = currentData.all;
        break;
    }

    // init the broker summary daily data
    _brokerSummaryDailyData.clear();

    // loop thru all the _brokerSummaryDailyStat.all
    Map<String, double> buyData = {};
    for (BrokerSummaryDailyStatBuySell data in currentItem.buy) {
      if (_brokerSummaryDailyMonhtlyValueSelected == "v") {
        buyData[data.date] = data.totalValue.toDouble();
      } else {
        buyData[data.date] = data.totalLot.toDouble();
      }
    }

    Map<String, double> sellData = {};
    for (BrokerSummaryDailyStatBuySell data in currentItem.sell) {
      if (_brokerSummaryDailyMonhtlyValueSelected == "v") {
        sellData[data.date] = data.totalValue.toDouble();
      } else {
        sellData[data.date] = data.totalLot.toDouble();
      }
    }

    // add buy and sell data to dail data
    _brokerSummaryDailyData.add(buyData);
    _brokerSummaryDailyData.add(sellData);
  }

  Future<void> _getBrokerSummary() async {
    // show loading screen
    LoadingScreen.instance().show(context: context);

    // get the broker summary
    await Future.wait([
      // get the broker summary gross
      _brokerSummaryAPI.getBrokerSummary(
        stockCode: _companyData.companyCode,
        dateFrom: _brokerSummaryDateFrom.toLocal(),
        dateTo: _brokerSummaryDateTo.toLocal()
      ).then((resp) {
        _brokerSummaryGross = resp;
      }),

      // get the broker summary net
      _brokerSummaryAPI.getBrokerSummaryNet(
        stockCode: _companyData.companyCode,
        dateFrom: _brokerSummaryDateFrom.toLocal(),
        dateTo: _brokerSummaryDateTo.toLocal()
      ).then((resp) {
        _brokerSummaryNet = resp;
      }),
    ]).onError(
      (error, stackTrace) {
        // print the error
        Log.error(
          message: 'Error when try to get broker data from server',
          error: error,
          stackTrace: stackTrace,
        );

        // show error
        throw Exception('Error when try to get broker data from server');
      },
    ).then((_) {
      // remove the loading screen
      LoadingScreen.instance().hide();
    });

    // check whether we need to show groos or net broker summary
    if (_showNet) {
      _setBrokerSummary(_brokerSummaryNet);
    } else {
      _setBrokerSummary(_brokerSummaryGross);
    }
  }

  Future<void> _getTopBroker() async {
    // show loading screen
    LoadingScreen.instance().show(context: context);

    // get the broker summary
    await _companyApi.getCompanyTopBroker(
      code: _companyData.companyCode,
      fromDate: _topBrokerDateFrom.toLocal(),
      toDate: _topBrokerDateTo.toLocal()
    ).then((resp) {
      setState(() {
        _topBroker = resp;
      });
    }).onError((error, stackTrace) {
      if (mounted) {
        // show snack bar
        ScaffoldMessenger.of(context).showSnackBar(
          createSnackBar(
            message: 'Error when try to get top broker data from server'
          )
        );
      }
      // show error
      Log.error(
        message: 'Error when get top broker data',
        error: error,
        stackTrace: stackTrace,
      );
    });

    // remove loading screen
    LoadingScreen.instance().hide();
  }

  Future<void> _getFundamental() async {
    List<InfoFundamentalsModel> result = [];

    // show loading screen
    LoadingScreen.instance().show(context: context);

    // get the fundamental data
    await _infoFundamentalAPI.getInfoFundamental(
      code: _companyData.companyCode,
      quarter: _quarterSelection
    ).then((resp) {
      result = resp;
    }).onError((error, stackTrace) {
      Log.error(
        message: 'Error fetching fundamental data',
        error: error,
        stackTrace: stackTrace,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            createSnackBar(message: "Error when fetching fundamental data"));
      }
    });

    // remove loading screen
    LoadingScreen.instance().hide();

    // set the current info fundamental with the result we got
    setState(() {
      _infoFundamental = result;
    });
  }

  Future<bool> _getInitData() async {
    DateTime fromDate = DateTime.now().subtract(
      const Duration(
        days: 365
      )
    ).toLocal();

    DateTime toDate = DateTime.now().toLocal();

    try {
      // get the data that refer as dependency by other API
      // get company detail
      await _companyApi.getCompanyDetail(
        companyId: _companyData.companyId,
        type: _companyData.type
      ).then((resp) {
        // copy the response to company detail data
        _companyDetail = resp;

        // set the broker summary date based on the last update of the company
        _brokerSummaryDateFrom =
            (_companyDetail.companyLastUpdate ?? DateTime.now());
        _brokerSummaryDateTo =
            (_companyDetail.companyLastUpdate ?? DateTime.now());

        // got company detail, let's recalculate the from and to date that we
        // will use to get the shama price, since broker summary already cater
        // in case company last update is null, use brker summary date to
        // as base for the from and to date.
        fromDate =
            _brokerSummaryDateTo.subtract(const Duration(days: 365)).toLocal();
        toDate = _brokerSummaryDateTo.toLocal();

        // we will try to get the broker data for 3 month of current date
        _topBrokerDateTo = (_companyDetail.companyLastUpdate == null
            ? DateTime.now().toLocal()
            : _companyDetail.companyLastUpdate!.toLocal());
        _topBrokerDateFrom = _topBrokerDateTo.add(const Duration(days: -90));
      }).onError((error, stackTrace) {
        Log.error(
          message: 'Error getting company detail',
          error: error,
          stackTrace: stackTrace,
        );
      });

      // get broker summary daily stat
      await _brokerSummaryAPI.getBrokerSummaryDailyStat(
        code: _companyData.companyCode
      ).then((resp) {
        _brokerSummaryDailyStat = resp;

        // init the broker summary daily data
        _brokerSummaryDailyData = [];

        // assuming that we will get the all lot data
        _brokerSummaryDailyMonthlyDataSelected = "d";
        _brokerSummaryDailyMonthlyTypeSelected = "a";
        _brokerSummaryDailyMonhtlyValueSelected = "l";

        // loop thru all the _brokerSummaryDailyStat.all
        Map<String, double> buyData = {};
        for (BrokerSummaryDailyStatBuySell data
            in _brokerSummaryDailyStat.all.buy) {
          buyData[data.date] = data.totalLot.toDouble();
        }

        Map<String, double> sellData = {};
        for (BrokerSummaryDailyStatBuySell data
            in _brokerSummaryDailyStat.all.sell) {
          sellData[data.date] = data.totalLot.toDouble();
        }

        // add buy and sell data to dail data
        _brokerSummaryDailyData.add(buyData);
        _brokerSummaryDailyData.add(sellData);
      }).onError((error, stackTrace) {
        Log.error(
          message: 'Error getting broker daily stat',
          error: error,
          stackTrace: stackTrace,
        );
      });

      // for rest of the data we can call async to faster the process of loading
      // the page.
      await Future.wait([
        _brokerSummaryAPI.getBrokerSummaryCodeDate(
          stockCode: _companyData.companyCode
        ).then((resp) {
          _brokerSummaryDate = resp;
        }).onError(
          (error, stackTrace) {
            Log.error(
              message: 'Error getting broker summary',
              error: error,
              stackTrace: stackTrace,
            );
            throw Exception('Error when got broker summary');
          },
        ),
        _brokerSummaryAPI.getBrokerSummary(
          stockCode: _companyData.companyCode,
          dateFrom: _brokerSummaryDateFrom.toLocal(),
          dateTo: _brokerSummaryDateTo.toLocal()
        ).then((resp) {
          _brokerSummaryGross = resp;
        }).onError(
          (error, stackTrace) {
            Log.error(
              message: 'Error getting broker summary gross data',
              error: error,
              stackTrace: stackTrace,
            );
            throw Exception('Error when got broker summary gross data');
          },
        ),
        _brokerSummaryAPI.getBrokerSummaryNet(
          stockCode: _companyData.companyCode,
          dateFrom: _brokerSummaryDateFrom.toLocal(),
          dateTo: _brokerSummaryDateTo.toLocal()
        ).then((resp) {
          _brokerSummary = resp;
          _brokerSummaryNet = resp;
          _brokerSummaryBuySell = resp.brokerSummaryAll;
          _brokerSummarySelected = "a";

          // calculate the broker summary
          _calculateBrokerSummary();
        }).onError(
          (error, stackTrace) {
            Log.error(
              message: 'Error getting broker summary buy and sell data',
              error: error,
              stackTrace: stackTrace,
            );
            throw Exception('Error when got broker summary buy and sell data');
          },
        ),
        _brokerSummaryAPI.getBrokerSummaryAccumulation(
          version: 'v1',
          stockCode: _companyData.companyCode,
          date: _brokerSummaryDateFrom.toLocal()
        ).then((resp) {
          _brokerSummaryAccumulation.add(resp);
        }).onError(
          (error, stackTrace) {
            Log.error(
              message: 'Error getting broker summary accumuluation (v1)',
              error: error,
              stackTrace: stackTrace,
            );
            throw Exception('Error when got broker summary accumulation (v1)');
          },
        ),
        _brokerSummaryAPI.getBrokerSummaryAccumulation(
          version: 'v2',
          stockCode: _companyData.companyCode,
          date: _brokerSummaryDateFrom.toLocal()
        ).then((resp) {
          _brokerSummaryAccumulation.add(resp);
        }).onError(
          (error, stackTrace) {
            Log.error(
              message: 'Error getting broker summary accumulation (v2)',
              error: error,
              stackTrace: stackTrace,
            );
            throw Exception('Error when got broker summary accumulation (v2)');
          },
        ),
        _companyApi.getCompanyTopBroker(
          code: _companyData.companyCode,
          fromDate: _topBrokerDateFrom,
          toDate: _topBrokerDateTo
        ).then((resp) {
          _topBroker = resp;
          _topBrokerDateFrom = (resp.brokerMinDate ?? DateTime.now());
          _topBrokerDateTo = (resp.brokerMaxDate ?? DateTime.now());
        }).onError(
          (error, stackTrace) {
            Log.error(
              message: 'Error getting company top broker',
              error: error,
              stackTrace: stackTrace,
            );
            throw Exception('Error when got company top broker');
          },
        ),
        _priceAPI.getPriceMovingAverage(
          stockCode: _companyData.companyCode
        ).then((resp) {
          _priceMA = resp;
        }).onError(
          (error, stackTrace) {
            Log.error(
              message: 'Error getting moving average price',
              error: error,
              stackTrace: stackTrace,
            );
            throw Exception('Error when got moving average price');
          },
        ),
        _priceAPI.getPriceMovement(
          stockCode: _companyData.companyCode
        ).then((resp) {
          _priceMovement = resp;

          _priceMovementData = [];
          Map<String, double> avgPrice = {};
          Map<String, double> minPrice = {};
          Map<String, double> maxPrice = {};
          // loop thru the _priceMovement price
          for (Price element in _priceMovement.prices) {
            avgPrice[element.date] = element.avgPrice;
            minPrice[element.date] = element.minPrice;
            maxPrice[element.date] = element.maxPrice;
          }
          _priceMovementData.add(avgPrice);
          _priceMovementData.add(minPrice);
          _priceMovementData.add(maxPrice);
        }).onError(
          (error, stackTrace) {
            Log.error(
              message: 'Error getting price movement data',
              error: error,
              stackTrace: stackTrace,
            );
            throw Exception('Error when got price movement data');
          },
        ),
        _infoFundamentalAPI.getInfoFundamental(
          code: _companyData.companyCode,
          quarter: _quarterSelection,
        ).then((resp) {
          _infoFundamental = resp;
        }).onError(
          (error, stackTrace) {
            Log.error(
              message: 'Error getting fundamental information',
              error: error,
              stackTrace: stackTrace,
            );
            throw Exception('Error when got info fundamental');
          },
        ),
        _infoSahamsAPI.getInfoSahamPriceDate(
          code: _companyData.companyCode,
          from: fromDate,
          to: toDate,
        ).then((resp) {
          // clear and initialize the info saham price data
          _infoSahamPriceData.clear();
          _infoSahamPriceData[30] = [];
          _infoSahamPriceData[60] = [];
          _infoSahamPriceData[90] = [];
          _infoSahamPriceData[180] = [];
          _infoSahamPriceData[365] = [];

          // loop thru resp and populate the map accordingly
          for (int i = 0; i < resp.length; i++) {
            // add for 30 days
            if (i < 30) {
              _infoSahamPriceData[30]!.add(resp[i]);
            }

            // add for 60 days
            if (i < 60) {
              _infoSahamPriceData[60]!.add(resp[i]);
            }

            // add for 90 days
            if (i < 90) {
              _infoSahamPriceData[90]!.add(resp[i]);
            }

            // add for 180 days
            if (i < 180) {
              _infoSahamPriceData[180]!.add(resp[i]);
            }

            // rest add to the 365 days
            _infoSahamPriceData[365]!.add(resp[i]);
          }

          // loop thru the 90 days to populate the heat map graph since the
          // maximum heat map graph is 70 (5 * 14).
          // clear the heat map graph
          _heatMapGraphData.clear();
          for (int i = 0;
              (i < _infoSahamPriceData[90]!.length &&
                  _heatMapGraphData.length < 98);
              i++) {
            _heatMapGraphData[_infoSahamPriceData[90]![i].date] = GraphData(
              date: _infoSahamPriceData[90]![i].date,
              price: _infoSahamPriceData[90]![i].lastPrice.toDouble(),
            );
          }

          _heatMapGraphData =
              sortedMap<DateTime, GraphData>(data: _heatMapGraphData);

          // once got we can set the info saham price into the correct data
          _infoSahamPrice = _infoSahamPriceData[_currentInfoSahamPrice]!;
          _generateSahamPriceSort();

          // calculate the high and low for this data
          _calculateMinMaxPrice(_infoSahamPriceData[_currentInfoSahamPrice]!);

          // generate graph data
          _generateGraphData(
              _infoSahamPriceData[_currentInfoSahamPrice]!, _companyDetail);
        }),
        _watchlistAPI.findDetail(
          companyId: _companyData.companyId
        ).then((resp) {
          // if we got response then map it to the map, so later we can sent it
          // to the graph for rendering the time when we buy the share
          DateTime tempDate;
          for (WatchlistDetailListModel data in resp) {
            tempDate = data.watchlistDetailDate.toLocal();
            if (_watchlistDetail.containsKey(
                DateTime(tempDate.year, tempDate.month, tempDate.day))) {
              // if exists get the current value of the _watchlistDetails and put into _bitData
              _bitData.set(_watchlistDetail[
                  DateTime(tempDate.year, tempDate.month, tempDate.day)]!);
              // check whether this is buy or sell
              if (data.watchlistDetailShare >= 0) {
                _bitData[15] = 1;
              } else {
                _bitData[14] = 1;
              }
              _watchlistDetail[
                      DateTime(tempDate.year, tempDate.month, tempDate.day)] =
                  _bitData.toInt();
            } else {
              if (data.watchlistDetailShare >= 0) {
                _watchlistDetail[
                    DateTime(tempDate.year, tempDate.month, tempDate.day)] = 1;
              } else {
                _watchlistDetail[
                    DateTime(tempDate.year, tempDate.month, tempDate.day)] = 2;
              }
            }
          }
        }),
        _companyApi.getSeasonality(
          code: _companyData.companyCode
        ).then((resp) {
          _seasonality = resp;
        }),
        _brokerSummaryAPI.getBrokerSummaryMonthlyStat(
          code: _companyData.companyCode
        ).then((resp) {
          _brokerSummaryMonthlyStat = resp;

          // init the broker summary daily data
          _brokerSummaryMonthlyData = [];

          // loop thru all the _brokerSummaryDailyStat.all
          Map<String, double> buyData = {};
          for (BrokerSummaryDailyStatBuySell data
              in _brokerSummaryDailyStat.all.buy) {
            buyData[data.date] = data.totalLot.toDouble();
          }

          Map<String, double> sellData = {};
          for (BrokerSummaryDailyStatBuySell data
              in _brokerSummaryDailyStat.all.sell) {
            sellData[data.date] = data.totalLot.toDouble();
          }

          // add buy and sell data to dail data
          _brokerSummaryMonthlyData.add(buyData);
          _brokerSummaryMonthlyData.add(sellData);
        }),
        _companyApi
            .getCompanySahamDividend(code: _companyData.companyCode)
            .then((resp) {
          _dividend = resp;
        }),
        _companyApi.getCompanySahamSplit(
          code: _companyData.companyCode
        ).then((resp) {
          _split = resp;
        }),

        // check if user owned this stock or not?
        _checkIfOwned(),
      ]).onError((error, stackTrace) {
        Log.error(
          message: 'Error getting company data',
          error: error,
          stackTrace: stackTrace,
        );

        // throw exception to the caller
        throw Exception("Error when getting Company Data");
      });
    } catch (error, stackTrace) {
      Log.error(
        message: 'Error getting company data from server',
        error: error,
        stackTrace: stackTrace,
      );
      throw 'Error when try to get the data from server';
    }

    return true;
  }

  Future<void> _checkIfOwned() async {
    // loop thru watchlist and check if this company is owned by the user or not?
    for(WatchlistListModel watchlist in _watchlists) {
      if (watchlist.watchlistCompanyId == _companyDetail.companyId) {
        _isOwned = true;
        return;
      }
    }
  }

  Future<void> _getCompanyDetail() async {
    // show the loading screen
    LoadingScreen.instance().show(context: context);

    // get the company detail information that we will use for comparison
    await Future.wait([
      _companyApi.getCompanyByCode(
        companyCode: _otherCompanyCode!,
        type: 'saham',
      ).then((resp) {
        _otherCompanyDetail = resp;
      }),
      _infoFundamentalAPI.getInfoFundamental(
        code: _otherCompanyCode!
      ).then((resp) {
        if (resp.isNotEmpty) {
          _otherInfoFundamental = resp[0];
        }
      }),
    ]);

    // remove the loading screen
    LoadingScreen.instance().hide();
  }

  void _calculateMinMaxPrice(List<InfoSahamPriceModel> data) {
    // loop thru data to get the max volume
    _maxVolume = -1;
    _maxHigh = -1;
    _minLow = 999999999;

    for (InfoSahamPriceModel price in data) {
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
  }

  Future<void> _getIndexData() async {
    // ensure we have _perfDataDaily
    if (_graphData.isNotEmpty) {
      // show loading screen
      LoadingScreen.instance().show(context: context);

      await _indexAPI.getIndexPriceDate(
        indexID: _indexCompare.indexId,
        from: _infoSahamPriceData[365]!.last.date,
        to: _infoSahamPriceData[365]!.first.date
      ).then((resp) async {
        _indexComparePrice = resp;

        // generate the index performance data
        Future.microtask(
          () async {
            // first generate the index map
            await _generateIndexMap();

            // then we generate the graph
            await _generateIndexGraph();
          },
        );

        // once finished just set state so we can rebuild the page
        setState(() {});
      }).onError(
        (error, stackTrace) {
          Log.error(
            message: 'Error getting index price',
            error: error,
            stackTrace: stackTrace,
          );

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
                createSnackBar(message: "Error when get index price"));
          }
        },
      ).whenComplete(
        () {
          // remove the loading screen
          LoadingScreen.instance().hide();
        },
      );
    }
  }

  Future<void> _generateIndexMap() async {
    // convert data from list index price model to map data
    // this is needed so we can have the same data as graph data later on

    // first clear the map
    _indexPriceMap.clear();

    // loop thru the index compare price that we got from API
    for (IndexPriceModel price in _indexComparePrice) {
      _indexPriceMap[price.indexPriceDate.toLocal()] = price.indexPriceValue;
    }
  }

  Future<void> _generateIndexGraph() async {
    // ensure that we have _indexPriceMap
    if (_indexPriceMap.isNotEmpty) {
      // create temporary graph data
      List<GraphData> tempGraph = [];

      // loop thru graph data
      for (GraphData data in _graphData) {
        // check if this date exists in index map or not?
        if (_indexPriceMap.containsKey(data.date.toLocal())) {
          // add this data to the tempGraph
          tempGraph.add(GraphData(
            date: data.date.toLocal(),
            price: _indexPriceMap[data.date.toLocal()]!,
          ));
        } else {
          // check if tempGraph already got data or not?
          if (tempGraph.isNotEmpty) {
            // just use the last one
            GraphData lastData = tempGraph.last;
            tempGraph.add(lastData);
          } else {
            // no data here, just make it 0
            tempGraph.add(GraphData(
              date: data.date.toLocal(),
              price: 0,
            ));
          }
        }
      }

      // clear index data, and copy it from tempGraph
      _indexData.clear();
      _indexData = tempGraph.toList();
    }
  }

  void _generateSahamPriceSort() {
    double? dayDiff;
    Color dayDiffColor;
    Color priceToCurrentColor;
    int lowDiff;
    int highDiff;
    double currPrice;
    double prevPrice;

    // clear the info price saham sort
    _infoSahamPriceSort.clear();

    // loop thru info price saham
    for (int index = 0; index < _infoSahamPrice.length; index++) {
      dayDiff = null;
      dayDiffColor = Colors.transparent;
      priceToCurrentColor = riskColor(
        value: _companyDetail.companyNetAssetValue!,
        cost: _infoSahamPrice[index].lastPrice.toDouble(),
        riskFactor: _userInfo!.risk
      );

      lowDiff = _infoSahamPrice[index].lastPrice - _infoSahamPrice[index].adjustedLowPrice;
      highDiff = (_infoSahamPrice[index].lastPrice - _infoSahamPrice[index].adjustedHighPrice) * -1;

      if ((index + 1) < _infoSahamPrice.length) {
        currPrice = _infoSahamPrice[index].lastPrice.toDouble();
        prevPrice = _infoSahamPrice[index + 1].lastPrice.toDouble();
        dayDiff = currPrice - prevPrice;

        dayDiffColor = riskColor(
          value: currPrice.toDouble(),
          cost: prevPrice.toDouble(),
          riskFactor: _userInfo!.risk
        );
      }

      SahamPriceList data = SahamPriceList(
        date: _infoSahamPrice[index].date,
        volume: _infoSahamPrice[index].volume,
        lastPrice: _infoSahamPrice[index].lastPrice.toDouble(),
        lastPriceColor: priceToCurrentColor,
        adjustedLowPrice: _infoSahamPrice[index].adjustedLowPrice.toDouble(),
        adjustedHighPrice:
            _infoSahamPrice[index].adjustedHighPrice.toDouble(),
        lowDiff: lowDiff.toDouble(),
        highDiff: highDiff.toDouble(),
        dayDiff: dayDiff,
        dayDiffColor: dayDiffColor
      );

      _infoSahamPriceSort.add(data);
    }

    // check whether this is ascending or descending
    if (_priceSort == "D") {
      _infoSahamPriceSort = _infoSahamPriceSort.reversed.toList();
    }
  }
}
