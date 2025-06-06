import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:ionicons/ionicons.dart';
import 'package:my_wealth/_index.g.dart';

class CompanyDetailReksadanaPage extends StatefulWidget {
  final Object? companyData;
  const CompanyDetailReksadanaPage({ super.key, required this.companyData });

  @override
  CompanyDetailReksadanaPageState createState() => CompanyDetailReksadanaPageState();
}

class CompanyDetailReksadanaPageState extends State<CompanyDetailReksadanaPage> with SingleTickerProviderStateMixin {
  late CompanyDetailArgs _companyData;
  late CompanyDetailModel _companyDetail;
  late UserLoginInfoModel? _userInfo;
  late Map<DateTime, int> _watchlistDetail;
  late Future<bool> _getData;
  late CompanyListModel _otherCompany;
  late CompanyDetailModel? _otherCompanyDetail;
  late MinMaxDateModel _minMaxDate;
  
  final ScrollController _summaryController = ScrollController();
  final ScrollController _priceController = ScrollController();
  final ScrollController _calendarScrollController = ScrollController();
  final ScrollController _graphScrollController = ScrollController();
  final ScrollController _calcScrollController = ScrollController();
  final ScrollController _calcTableScrollController = ScrollController();
  final ScrollController _compareController = ScrollController();
  final TextEditingController _monthController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  late TabController _tabController;

  final CompanyAPI _companyApi = CompanyAPI();
  final WatchlistAPI _watchlistAPI = WatchlistAPI();
  final InfoReksadanaAPI _infoReksadanaAPI = InfoReksadanaAPI();
  final IndexAPI _indexAPI = IndexAPI();
  
  final Map<int, List<InfoReksadanaModel>> _infoReksadanaData = {};
  late List<InfoReksadanaModel> _infoReksadana;
  late List<CompanyDetailList> _infoReksadanaSort;

  late String _mapSelection;
  late CompanyWeekdayPerformanceModel _weekdayPerformance;
  late DateTime _weekdayPerformanceDateFrom;
  late DateTime _weekdayPerformanceDateTo;
  late CompanyWeekdayPerformanceModel _monthlyPerformance;
  late DateTime _monthlyPerformanceDateFrom;
  late DateTime _monthlyPerformanceDateTo;
  late CompanyPortofolioAssetModel _portofolioAssetModel;
  late List<BarChartData> _portofolioBarChart;
  late MyYearPickerCalendarType _calendarType;
  late bool _calendarWeeklyType;

  late List<WatchlistListModel> _watchlists;
  late bool _isOwned;

  late int _currentDayIndex;

  final Bit _bitData = Bit();
  final List<Widget> _calcTableResult = [];
  late List<Map<String, double>> _movementData;
  late Map<DateTime, GraphData> _heatMapGraphData;
  late List<GraphData> _graphData;
  late List<GraphData> _unitData;
  late List<GraphData> _assetData;
  late DateTime _from;
  late DateTime _to;

  late IndexModel _indexCompare;
  late String _indexCompareName;
  late List<IndexPriceModel> _indexComparePrice;
  late Map<DateTime, double> _indexPriceMap;
  late List<GraphData> _indexData;
  late BodyPage _bodyPage;
  late ColumnType _columnType;
  late SortType _sortType;
  late bool _isWarning;
  late CompanyLastUpdateModel _lastUpdate;
  
  bool _showCurrentPriceComparison = false;
  bool _recurring = true;
  int _numPrice = 0;
  double? _minPrice;
  double? _maxPrice;
  double? _avgPrice;
  double? _avgDaily;
  int _avgCount = 0;
  int _dateOffset = 3;
  String _graphSelection = "s";

  @override
  void initState() {
    super.initState();

    // initialize tab
    _tabController = TabController(length: 3, vsync: this);

    // initialize variable
    _recurring = true;
    _showCurrentPriceComparison = false;
    _otherCompanyDetail = null;

    _bodyPage = BodyPage.summary;
    _numPrice = 0;

    // default column and sort type
    _columnType = ColumnType.date;
    _sortType = SortType.descending;

    _movementData = [];

    if (widget.companyData == null) {
      _companyData = CompanyDetailArgs(
        companyId: -1,
        companyName: "Unknown Company",
        companyCode: "",
        companyFavourite: false,
        favouritesId: -1,
        type: ""
      );
    }
    else {
      _companyData = widget.companyData as CompanyDetailArgs;
    }

    _userInfo = UserSharedPreferences.getUserInfo();

    // get watchlist for this user
    _watchlists = WatchlistSharedPreferences.getWatchlist(type: "reksadana");
    // assume that user don't own this
    _isOwned = false;

    // get the max company last update
    _lastUpdate = CompanySharedPreferences.getCompanyLastUpdateModel(
      type: CompanyLastUpdateType.max,
    );

    // initialize graph data
    _graphData = [];
    _unitData = [];
    _assetData = [];
    _heatMapGraphData = {};
    
    // assuming we don't have any watchlist detail
    _watchlistDetail = {};

    // default the from and to date as today date
    _from = _to = DateTime.now().toLocal();

    // clear info reksadana
    _infoReksadanaData.clear();
    
    // initialize info reksadana
    _infoReksadanaData[30] = [];
    _infoReksadanaData[60] = [];
    _infoReksadanaData[90] = [];
    _infoReksadanaData[180] = [];
    _infoReksadanaData[365] = [];

    // defaulted the current day index into 90 days
    _currentDayIndex = 90;
    _infoReksadana = [];

    // initialize info reksadana sort, and default the sort to Ascending
    _infoReksadanaSort = [];

    // initialize index compare data
    _indexCompareName = "";
    _indexComparePrice = [];
    _indexPriceMap = {};
    _indexData = [];

    // initialize the map selection for price
    _mapSelection = "p";

    // default the calendar type to single
    _calendarType = MyYearPickerCalendarType.single;

    // default the weekly calendar to range
    _calendarWeeklyType = true;

    // initialize the bar chart
    _portofolioBarChart = [];

    // default the is warning into false
    _isWarning = false;

    // get the data
    _getData = _getInitData();
  }

  @override
  void dispose() {
    _summaryController.dispose();
    _priceController.dispose();
    _graphScrollController.dispose();
    _calendarScrollController.dispose();
    _monthController.dispose();
    _amountController.dispose();
    _calcScrollController.dispose();
    _calcTableScrollController.dispose();
    _compareController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getData,
      builder: ((context, snapshot) {
        if (snapshot.hasError) {
          return const CommonErrorPage(errorText: 'Error loading mutual fund data');
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
    int companyRating;
    int companyRisk;
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

    if(_companyDetail.companyYearlyRating == null) {
      companyRating = 0;
    }
    else {
      companyRating = _companyDetail.companyYearlyRating!.toInt();
    }

    if(_companyDetail.companyYearlyRisk == null) {
      companyRisk = 0;
    }
    else {
      companyRisk = _companyDetail.companyYearlyRisk!.toInt();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            "Mutual Fund Detail",
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
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Visibility(
                                visible: _isWarning,
                                child: Container(
                                  padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                                  child: Icon(
                                    Ionicons.lock_closed,
                                    size: 14,
                                    color: secondaryColor,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  _companyData.companyName,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
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
                                header: "Rating",
                                headerAlign: MainAxisAlignment.end,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: generateRatingIcon(companyRating),
                                ),
                              ),
                              const SizedBox(width: 10,),
                              CompanyInfoBox(
                                header: "Risk",
                                headerAlign: MainAxisAlignment.end,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: generateRiskIcon(companyRisk),
                                ),
                              ),
                              const SizedBox(width: 10,),
                              CompanyInfoBox(
                                header: "Type",
                                headerAlign: MainAxisAlignment.end,
                                child: Text(
                                  (Globals.reksadanaCompanyTypeEnum[_companyDetail.companyType] ?? "Unknown"),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5,),
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
                const SizedBox(width: 5,),
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
                const SizedBox(width: 5,),
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
                const SizedBox(width: 5,),
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
                const SizedBox(width: 5,),
                TransparentButton(
                  text: "Calc",
                  color: primaryDark,
                  borderColor: primaryLight,
                  icon: Ionicons.calculator_outline,
                  onTap: (() {
                    setState(() {
                      _bodyPage = BodyPage.calc;
                    });
                  }),
                  active: (_bodyPage == BodyPage.calc),
                  vertical: true,
                ),
                const SizedBox(width: 10,),
              ],
            ),
            const SizedBox(height: 5,),
            Expanded(child: _detail(),),
          ],
        ),
      ),
    );
  }

  List<Widget> generateRiskIcon(int companyRisk) {
    List<Widget> ret = [];
    if (companyRisk > 0) {
      ret = List<Widget>.generate(companyRisk, (index) {
        return const Icon(
          Ionicons.alert,
          color: secondaryLight,
          size: 15,
        );
      });
    }
    else {
      ret.add(const Icon(
        Ionicons.help,
        color: Colors.blue,
        size: 15,
      ));
    }

    return ret;
  }

  List<Widget> generateRatingIcon(int companyRating) {
    List<Widget> ret = [];
    if (companyRating > 0) {
      ret = List<Widget>.generate(companyRating, (index) {
        return const Icon(
          Ionicons.star,
          color: accentLight,
          size: 15,
        );
      });
    }
    else {
      ret.add(const Icon(
        Ionicons.help,
        color: Colors.blue,
        size: 15,
      ));
    }

    return ret;
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
      case BodyPage.calc:
        return _showCalc();
      default:
        return _showTable();
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
            Tab(text: 'COMPARE'),
            Tab(text: 'PORTOFOLIO',),
          ],
        ),
        const SizedBox(height: 10,),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: <Widget>[
              _tabSummaryInfo(),
              _tabCompareInfo(),
              _tabPortofolioAssetInfo(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _tabSummaryInfo() {
    return Container(
      padding: const EdgeInsets.all(10),
      child: SingleChildScrollView(
        controller: _summaryController,
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
                const SizedBox(width: 10,),
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
            const SizedBox(height: 5,),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                CompanyInfoBox(
                  header: "Quarterly",
                  headerAlign: MainAxisAlignment.end,
                  child: Text(
                    "${formatDecimalWithNull(_companyDetail.companyQuarterlyReturn, times: 100)}%",
                    textAlign: TextAlign.right,
                  ),
                ),
                const SizedBox(width: 10,),
                CompanyInfoBox(
                  header: "Semi Annual",
                  headerAlign: MainAxisAlignment.end,
                  child: Text(
                    "${formatDecimalWithNull(_companyDetail.companySemiAnnualReturn, times: 100)}%",
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
              ],
            ),
            const SizedBox(height: 5,),
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
                  header: "Total Asset",
                  headerAlign: MainAxisAlignment.end,
                  child: Text(
                    formatCurrency(_companyDetail.companyAssetUnderManagement!),
                    textAlign: TextAlign.right,
                  ),
                ),
                const SizedBox(width: 10,),
                CompanyInfoBox(
                  header: "Total Unit",
                  headerAlign: MainAxisAlignment.end,
                  child: Text(
                    formatCurrency(_companyDetail.companyTotalUnit!),
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

  Widget _tabCompareInfo() {
    return Container(
      padding: const EdgeInsets.all(5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                InkWell(
                  onTap: (() async {
                    String? type;
                    switch(_companyDetail.companyType) {
                      case "reksadanapendapatantetap":
                          type = "Pendapatan Tetap";
                          break;
                      case "reksadanacampuran":
                          type = "Campuran";
                          break;
                      case "reksadanapasaruang":
                          type = "Pasar Uang";
                          break;
                      case "reksadanasaham":
                          type = "Saham";
                          break;
                    }

                    CompanyFindOtherArgs args = CompanyFindOtherArgs(
                      type: 'reksadana',
                      filter: type,
                    );

                    await Navigator.pushNamed(context, '/company/detail/find', arguments: args).then((value) async {
                      // check if value is not null?
                      if (value != null) {
                        // convert the value to company list model
                        _otherCompany = value as CompanyListModel;

                        // get the company detail information that we want to compare
                        await _getCompanyDetail();

                        setState(() {
                          // set state to rebuild the widget
                        });
                      }
                    });
                  }),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: primaryLight,
                        style: BorderStyle.solid,
                        width: 1.0,
                      ),
                      color: secondaryColor,
                    ),
                    child: const Center(
                      child: Text("FIND COMPANY"),
                    ),
                  ),
                ),
                const SizedBox(height: 5,),
                Visibility(
                  visible: (_otherCompanyDetail != null),
                  child: Text("Now comparing with ${_otherCompanyDetail?.companyName}")
                ),
              ],
            ),
          ),
          const SizedBox(height: 10,),
          Expanded(
            child: SingleChildScrollView(
              controller: _compareController,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        CompareFields(color: primaryDark, borderColor: primaryLight, text: "Type", fontWeight: FontWeight.bold),
                        CompareFields(color: primaryDark, borderColor: primaryLight, text: "Last Price", fontWeight: FontWeight.bold),
                        CompareFields(color: primaryDark, borderColor: primaryLight, text: "Daily", fontWeight: FontWeight.bold),
                        CompareFields(color: primaryDark, borderColor: primaryLight, text: "Weekly", fontWeight: FontWeight.bold),
                        CompareFields(color: primaryDark, borderColor: primaryLight, text: "Monthly", fontWeight: FontWeight.bold),
                        CompareFields(color: primaryDark, borderColor: primaryLight, text: "Quarterly", fontWeight: FontWeight.bold),
                        CompareFields(color: primaryDark, borderColor: primaryLight, text: "Semi Annual", fontWeight: FontWeight.bold),
                        CompareFields(color: primaryDark, borderColor: primaryLight, text: "Yearly", fontWeight: FontWeight.bold),
                        CompareFields(color: primaryDark, borderColor: primaryLight, text: "YTD", fontWeight: FontWeight.bold),
                        CompareFields(color: primaryDark, borderColor: primaryLight, text: "Total Asset", fontWeight: FontWeight.bold),
                        CompareFields(color: primaryDark, borderColor: primaryLight, text: "Total Unit", fontWeight: FontWeight.bold),
                        CompareFields(color: primaryDark, borderColor: primaryLight, text: "Rating", fontWeight: FontWeight.bold),
                        CompareFields(color: primaryDark, borderColor: primaryLight, text: "Risk", fontWeight: FontWeight.bold),
                      ],
                    ),
                  ),
                  _companyCompareInfo(
                    companyA: _companyDetail,
                    companyB: _otherCompanyDetail,
                    compare: _otherCompanyDetail,
                    color: accentColor
                  ),
                  _companyCompareInfo(
                    companyA: _otherCompanyDetail,
                    companyB: _companyDetail,
                    compare: _otherCompanyDetail,
                    color: extendedLight
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabPortofolioAssetInfo() {
    if (_portofolioAssetModel.portofolioDate == null) {
      return Center(
        child: Text("No portofolio data available"),
      );
    }

    return Container(
      padding: const EdgeInsets.all(5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Center(
            child: Text(
              "Portofolio Date",
              style: TextStyle(
                fontSize: 11,
                color: secondaryLight,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Center(
            child: Text(
              Globals.dfDDMMMyyyy.format(
                _portofolioAssetModel.portofolioDate!,
              ),
            ),
          ),
          BarChart(
            data: _portofolioBarChart,
            showLegend: false,
          ),
          const SizedBox(height: 10,),
          Expanded(
            child: ListView.builder(
              itemCount: _portofolioAssetModel.portofolio.length,
              itemBuilder: (context, index) {
                int colorIndex = index % (Globals.colorList.length - 1);

                return Container(
                  padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                  margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: primaryLight,
                        width: 1.0,
                        style: BorderStyle.solid,
                      )
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        height: 30,
                        width: 30,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: Globals.colorList[colorIndex],
                        ),
                      ),
                      const SizedBox(width: 10,),
                      Expanded(
                        child: Text(
                          "${_portofolioAssetModel.portofolio[index].code.isNotEmpty ? '(${_portofolioAssetModel.portofolio[index].code}) ' : ''}${_portofolioAssetModel.portofolio[index].name}",
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 10,),
                      Text(
                        "${_portofolioAssetModel.portofolio[index].value}%",
                        style: TextStyle(
                          color: accentColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _companyCompareInfo({required CompanyDetailModel? companyA, required CompanyDetailModel? companyB, required CompanyDetailModel? compare, required Color color}) {
    String type = (companyA != null ? companyA.companyType : '-');
    switch(type) {
      case "reksadanapendapatantetap":
          type = "Pendapatan Tetap";
          break;
      case "reksadanacampuran":
          type = "Campuran";
          break;
      case "reksadanapasaruang":
          type = "Pasar Uang";
          break;
      case "reksadanasaham":
          type = "Saham";
          break;
    }

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          CompareFields(
            color: primaryDark,
            borderColor: color,
            text: type,
          ),
          CompareFields(
            color: primaryDark,
            borderColor: color,
            text: formatCurrencyWithNull(companyA?.companyNetAssetValue),
            showCompare: false,
          ),
          CompareFields(
            color: primaryDark,
            borderColor: color,
            text: "${formatDecimalWithNull(companyA?.companyDailyReturn, times: 100)}%",
            isBigger: (companyB != null ? ((companyA?.companyDailyReturn ?? 0) - (companyB.companyDailyReturn ?? 0)) : 0),
            showCompare: (compare != null ? true : false),
          ),
          CompareFields(
            color: primaryDark,
            borderColor: color,
            text: "${formatDecimalWithNull(companyA?.companyWeeklyReturn, times: 100)}%",
            isBigger: (companyB != null ? ((companyA?.companyWeeklyReturn ?? 0) - (companyB.companyWeeklyReturn ?? 0)) : 0),
            showCompare: (compare != null ? true : false),
          ),
          CompareFields(
            color: primaryDark,
            borderColor: color,
            text: "${formatDecimalWithNull(companyA?.companyMonthlyReturn, times: 100)}%",
            isBigger: (companyB != null ? ((companyA?.companyMonthlyReturn ?? 0) - (companyB.companyMonthlyReturn ?? 0)) : 0),
            showCompare: (compare != null ? true : false),
          ),
          CompareFields(
            color: primaryDark,
            borderColor: color,
            text: "${formatDecimalWithNull(companyA?.companyQuarterlyReturn, times: 100)}%",
            isBigger: (companyB != null ? ((companyA?.companyQuarterlyReturn ?? 0) - (companyB.companyQuarterlyReturn ?? 0)) : 0),
            showCompare: (compare != null ? true : false),
          ),
          CompareFields(
            color: primaryDark,
            borderColor: color,
            text: "${formatDecimalWithNull(companyA?.companySemiAnnualReturn, times: 100)}%",
            isBigger: (companyB != null ? ((companyA?.companySemiAnnualReturn ?? 0) - (companyB.companySemiAnnualReturn ?? 0)) : 0),
            showCompare: (compare != null ? true : false),
          ),
          CompareFields(
            color: primaryDark,
            borderColor: color,
            text: "${formatDecimalWithNull(companyA?.companyYearlyReturn, times: 100)}%",
            isBigger: (companyB != null ? ((companyA?.companyYearlyReturn ?? 0) - (companyB.companyYearlyReturn ?? 0)) : 0),
            showCompare: (compare != null ? true : false),
          ),
          CompareFields(
            color: primaryDark,
            borderColor: color,
            text: "${formatDecimalWithNull(companyA?.companyYtdReturn, times: 100)}%",
            isBigger: (companyB != null ? ((companyA?.companyYtdReturn ?? 0) - (companyB.companyYtdReturn ?? 0)) : 0),
            showCompare: (compare != null ? true : false),
          ),
          CompareFields(
            color: primaryDark,
            borderColor: color,
            text: formatCurrencyWithNull(companyA?.companyAssetUnderManagement!),
            isBigger: (companyB != null ? ((companyA?.companyAssetUnderManagement ?? 0) - (companyB.companyAssetUnderManagement ?? 0)) : 0),
            showCompare: (compare != null ? true : false),
          ),
          CompareFields(
            color: primaryDark,
            borderColor: color,
            text: formatCurrencyWithNull(companyA?.companyTotalUnit!),
            isBigger: (companyB != null ? ((companyA?.companyTotalUnit ?? 0) - (companyB.companyTotalUnit ?? 0)) : 0),
            showCompare: (compare != null ? true : false),
          ),
          CompareFields(
            color: primaryDark,
            borderColor: color,
            text: ("${companyA != null ? companyA.companyYearlyRating! : '-'}"),
            isBigger: (companyB != null ? ((companyA?.companyYearlyRating ?? 0) - (companyB.companyYearlyRating ?? 0)) : 0),
            showCompare: (compare != null ? true : false),
          ),
          CompareFields(
            color: primaryDark,
            borderColor: color,
            text: ("${companyA != null ? companyA.companyYearlyRisk! : '-'}"),
            isBigger: (companyB != null ? ((companyB.companyYearlyRisk ?? 0) - (companyA?.companyYearlyRisk ?? 0)) : 0),
            showCompare: (compare != null ? true : false),
          ),
        ],
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
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              if (_columnType == ColumnType.date) {
                                if (_sortType == SortType.ascending) {
                                  _sortType = SortType.descending;
                                }
                                else {
                                  _sortType = SortType.ascending;
                                }

                                // just reverse the current list
                                _infoReksadanaSort = _infoReksadanaSort.reversed.toList();
                              }
                              else {
                                // set the correct column type
                                _columnType = ColumnType.date;
                                
                                // call sort info to get the correct sort
                                _sortInfo();
                              }
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
                              if (_columnType == ColumnType.price) {
                                if (_sortType == SortType.ascending) {
                                  _sortType = SortType.descending;
                                }
                                else {
                                  _sortType = SortType.ascending;
                                }

                                // just reverse the current list
                                _infoReksadanaSort = _infoReksadanaSort.reversed.toList();
                              }
                              else {
                                // set the correct column type
                                _columnType = ColumnType.price;
                                
                                // call sort info to get the correct sort
                                _sortInfo();
                              }
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
                                textAlign: TextAlign.center,
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
                              if (_columnType == ColumnType.diff) {
                                if (_sortType == SortType.ascending) {
                                  _sortType = SortType.descending;
                                }
                                else {
                                  _sortType = SortType.ascending;
                                }

                                // just reverse the current list
                                _infoReksadanaSort = _infoReksadanaSort.reversed.toList();
                              }
                              else {
                                // set the correct column type
                                _columnType = ColumnType.diff;
                                
                                // call sort info to get the correct sort
                                _sortInfo();
                              }
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
                              if (_columnType == ColumnType.gainloss) {
                                if (_sortType == SortType.ascending) {
                                  _sortType = SortType.descending;
                                }
                                else {
                                  _sortType = SortType.ascending;
                                }

                                // just reverse the current list
                                _infoReksadanaSort = _infoReksadanaSort.reversed.toList();
                              }
                              else {
                                // set the correct column type
                                _columnType = ColumnType.gainloss;
                                
                                // call sort info to get the correct sort
                                _sortInfo();
                              }
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
            itemCount: _infoReksadanaSort.length,
            itemBuilder: (context, index) {
              // generate the company detail price list
              return CompanyDetailPriceList(
                date: Globals.dfddMMyyyy.formatLocal(_infoReksadanaSort[index].date),
                price: formatCurrency(_infoReksadanaSort[index].price),
                diff: formatCurrency(_infoReksadanaSort[index].diff),
                riskColor: _infoReksadanaSort[index].riskColor,
                dayDiff: formatCurrencyWithNull(_infoReksadanaSort[index].dayDiff),
                dayDiffColor: _infoReksadanaSort[index].dayDiffColor,
              ); 
            },
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

  Widget _showCalendar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        const SizedBox(height: 10,),
        SizedBox(
          width: double.infinity,
          child: CupertinoSegmentedControl<String>(
            children: const <String, Widget>{
              "p": Text("Price"),
              "w": Text("Weekday"),
              "m": Text("Monthly"),
            },
            onValueChanged: ((value) {
              setState(() {
                _mapSelection = value;
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 5,),
                _selectedMap(),
              ],
            ),
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
                  Expanded(
                    child: InkWell(
                      onTap: (() async {
                        // stored current from and to date
                        DateTime prevDateFrom = _weekdayPerformanceDateFrom;
                        DateTime prevDateTo = _weekdayPerformanceDateTo;
                    
                        // check for the max date to avoid any assertion that the initial date range
                        // is more than the lastDate
                        DateTime maxDate = (_minMaxDate.maxDate).toLocal();
                        if (maxDate.isBefore(_minMaxDate.minDate.toLocal())) {
                          maxDate = _minMaxDate.minDate.toLocal();
                        }

                        if (_calendarWeeklyType) {
                          DateTimeRange? result = await showDateRangePicker(
                            context: context,
                            firstDate: _minMaxDate.minDate.toLocal(),
                            lastDate: maxDate,
                            initialDateRange: DateTimeRange(
                              start: _weekdayPerformanceDateFrom.toLocal(),
                              end: _weekdayPerformanceDateTo.toLocal()
                            ),
                            confirmText: 'Done',
                            currentDate: (_companyDetail.companyLastUpdate ?? DateTime.now()).toLocal(),
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
                                    firstDate: _minMaxDate.minDate.toLocal(),
                                    lastDate: _minMaxDate.maxDate.toLocal(),
                                    startDate: _weekdayPerformanceDateFrom,
                                    endDate: _weekdayPerformanceDateTo,
                                    type: MyYearPickerCalendarType.range,
                                    onChanged: (value) async {
                                      // remove the dialog
                                      Navigator.pop(context);
                      
                                      // check the new date whether it's same year or not?
                                      if (value.startDate.toLocal().year != _weekdayPerformanceDateFrom.year || value.endDate.toLocal().year != _weekdayPerformanceDateTo.year) {
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
                                    },
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
                  const SizedBox(width: 10,),
                  SizedBox(
                    height: 15,
                    width: 30,
                    child: Transform.scale(
                      scale: 0.5,
                      child: CupertinoSwitch(
                        value: _calendarWeeklyType,
                        activeTrackColor: secondaryColor,
                        onChanged: (value) {
                          setState(() {
                            _calendarWeeklyType = value;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 2,),
                  SizedBox(
                    width: 25,
                    child: Text(
                      (_calendarWeeklyType ? "Day" : "Year"),
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
                                  firstDate: _minMaxDate.minDate.toLocal(),
                                  lastDate: _minMaxDate.maxDate.toLocal(),
                                  startDate: _monthlyPerformanceDateFrom,
                                  endDate: _monthlyPerformanceDateTo,
                                  type: _calendarType,
                                  onChanged: (value) async {
                                    // remove the dialog
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
                                  },
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
                    initialKey: _calendarType,
                    icons: const [
                      FlipFlopItem<MyYearPickerCalendarType>(key: MyYearPickerCalendarType.single, icon: LucideIcons.calendar_1),
                      FlipFlopItem<MyYearPickerCalendarType>(key: MyYearPickerCalendarType.range, icon: LucideIcons.calendar_range),
                    ],
                    onChanged: <MyYearPickerCalendarType>(value) {
                      setState(() {
                        _calendarType = value;
                      });
                    },
                  ),
                  const SizedBox(width: 10,),
                ],
              ),
              WeekdayPerformanceChart(
                type: WeekdayPerformanceType.monthly,
                data: _monthlyPerformance,
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
                currentPrice: _companyDetail.companyNetAssetValue!,
                enableDailyComparison: _showCurrentPriceComparison,
              ),
            ],
          ),
        );
    }
  }

  Widget _selectedGraph() {
    switch(_graphSelection) {
      case "a":
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            const Center(
              child: Text(
                "Asset Under Management",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 5,),
            _dayStatSelection(),
            const SizedBox(height: 10,),
            LineChart(
              data: _assetData,
              height: 250,
              watchlist: _watchlistDetail,
              showLegend: false,
              dateOffset: _dateOffset,
              fillDate: true,
            ),
          ],
        );
      case "t":
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            const Center(
              child: Text(
                "Total Unit",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 5,),
            _dayStatSelection(),
            const SizedBox(height: 10,),
            LineChart(
              data: _unitData,
              height: 250,
              watchlist: _watchlistDetail,
              showLegend: false,
              dateOffset: _dateOffset,
              fillDate: true,
            ),
          ],
        );
      case "m":
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            const Center(
              child: Text(
                "Percentage Movement",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 5,),
            _dayStatSelection(),
            const SizedBox(height: 10,),
            MultiLineChart(
              height: 250,
              data: _movementData,
              color: const [Colors.orange, Colors.red, Colors.green, Colors.blue],
              legend: const ["Daily", "Weekly", "Monthly", "Yearly"],
              dateOffset: _dateOffset,
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
                        content: Text("Do you want to clear comparison with $_indexCompareName?"),
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
                            )
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
                    })
                  );
                }
              }),
              child: Container(
                color: Colors.transparent,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text("Price${(_indexCompareName.isNotEmpty ? " (Compare with $_indexCompareName)" : "")}"),
                    Visibility(
                      visible: _indexCompareName.isNotEmpty,
                      child: const SizedBox(width: 5,)
                    ),
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
            const SizedBox(height: 5,),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Expanded(child: _dayStatSelection()),
                InkWell(
                  onTap: (() async {
                    // go to index list page
                    await Navigator.pushNamed(context, '/index/find').then((value) async {
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
                const SizedBox(width: 15,),
              ],
            ),
            const SizedBox(height: 10,),
            LineChart(
              data: _graphData,
              compare: _indexData,
              height: 250,
              watchlist: _watchlistDetail,
              dateOffset: _dateOffset,
              fillDate: true,
            ),
          ],
        );
    }
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
              "s": Text("Price"),
              "a": Text("AUM"),
              "t": Text("Total"),
              "m": Text("Movement"),
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

  Widget _showCalc() {
    if (_avgDaily == 0) {
      return const Center(
        child: Text("Calculate average daily are 0, no calculation needed"),
      );
    }

    return SingleChildScrollView(
      controller: _calcScrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              height: 60,
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: primaryLight,
                    width: 1.0,
                    style: BorderStyle.solid,
                  ),
                )
              ),
              child: InkWell(
                onTap: (() async {
                  await ShowInfoDialog(
                    title: "Average Daily Estimation",
                    text: "We estimate the average daily based on average weight on daily, weekly, monthly, quarterly, semi annual, and yearly.\n\nThis information is only for information and not reflect the actual performance of the mutual funds.",
                    okayColor: accentColor
                  ).show(context);
                }),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    const SizedBox(width: 10,),
                    const Text(
                      "Average Daily Estimation",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: secondaryLight,
                      ),
                    ),
                    const SizedBox(width: 10,),
                    Expanded(
                      child: Text(
                        "${formatDecimalWithNull(_avgDaily, times: 100)}%",
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          color: textPrimary,
                        ),  
                      ),
                    ),
                    const SizedBox(width: 10,),
                  ],
                ),
              ),
            ),
            WatchlistDetailCreateTextFields(
              controller: _monthController,
              title: "Month",
              decimal: 0,
              limit: 4,
              hintText: "0",
            ),
            WatchlistDetailCreateTextFields(
              controller: _amountController,
              title: "Amount",
              decimal: 0,
              hintText: "0",
            ),
            Container(
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: primaryLight,
                    width: 1.0,
                    style: BorderStyle.solid,
                  ),
                )
              ),
              height: 60,
              width: double.infinity,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(width: 10,),
                  const Expanded(
                    child: Text(
                      "Recurring",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: secondaryLight,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10,),
                  CupertinoSwitch(
                    activeTrackColor: secondaryColor,
                    value: _recurring,
                    onChanged: ((value) async {
                      setState(() {
                        _recurring = value;
                      });
                    }),
                  ),
                  const SizedBox(width: 10,),
                ],
              ),
            ),
            const SizedBox(height: 10,),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
              children: [
                TransparentButton(
                  text: "Calculate",
                  color: secondaryDark,
                  borderColor: secondaryLight,
                  icon: Ionicons.calculator,
                  onTap: (() {
                    _simulateReksadana();
                  })
                ),
              ],
            ),
            const SizedBox(height: 10,),
            (
              _calcTableResult.isEmpty ?
              const SizedBox.shrink() :
              _calcRow(
                month: "Mth",
                percentage: "%",
                interest: "Interest",
                value: "Value",
                textAlign: TextAlign.center,
                fontWeight: FontWeight.bold,
                bgColor: primaryDark,
              )
            ),
            ListView.builder(
              controller: _calcTableScrollController,
              shrinkWrap: true,
              itemCount: _calcTableResult.length,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return _calcTableResult[index];
              },
            ),
          ],
        ),
      ),
    );
  }

  void _simulateReksadana() {
    // get all the value from month and amount
    String strMonth = _monthController.text;
    String strAmount = _amountController.text;
    int month;
    double amount;
    double calcAmount;
    double calcPercentage;
    double averagePercentage;
    double totalInterest;
    double totalAmount;
    double avgYearly;

    // ensure that both month and amount is not empty
    if (strMonth.isNotEmpty && strAmount.isNotEmpty) {
      // ensure that both is number
      try {
        month = int.parse(strMonth);
      }
      catch(e) {
        ScaffoldMessenger.of(context).showSnackBar(
          createSnackBar(
            message: "Month need to be numeric",
          )
        );
        return;
      }

      try {
        amount = double.parse(strAmount);
      }
      catch(e) {
        ScaffoldMessenger.of(context).showSnackBar(
          createSnackBar(
            message: "Amount need to be numeric",
          )
        );
        return;
      }

      // both is numeric, we can now perform the calculation
      avgYearly = (_avgDaily! * 260);
      totalAmount = 0;
      averagePercentage = 0;
      totalInterest = 0;

      // clear the widget
      _calcTableResult.clear();

      // loop to all month
      for(int m=1; m<=month; m++) {
        calcPercentage = (((month - m + 1)/12) * avgYearly);
        averagePercentage += calcPercentage;

        calcAmount = calcPercentage * amount;
        totalInterest += calcAmount;

        totalAmount += (calcAmount + amount);

        _calcTableResult.add(_calcRow(
          month: "$m",
          percentage: "${formatDecimalWithNull(
            calcPercentage,
            times: 100,
            decimal: 2
          )}%",
          interest: formatCurrency(
            calcAmount,
            showDecimal: false,
            shorten: false,
            decimalNum: 0,
          ),
          value: formatCurrency(
            (calcAmount + amount),
            showDecimal: false,
            shorten: false,
            decimalNum: 0,
          ),
          textAlign: TextAlign.center,
        ));

        if (!_recurring) {
          // no need to calculate till end of the month
          // since we will only showed 1 record
          m = month + 1;
        }
      }

      _calcTableResult.add(_calcRow(
        month: "Total",
        percentage: "${formatDecimalWithNull(
          (averagePercentage / month),
          times: 100,
          decimal: 2
        )}%",
        interest: formatCurrency(
          totalInterest,
          showDecimal: false,
          shorten: false,
          decimalNum: 0,
        ),
        value: formatCurrency(
          totalAmount,
          showDecimal: false,
          shorten: false,
          decimalNum: 0,
        ),
        textAlign: TextAlign.center,
        fontWeight: FontWeight.bold,
        bgColor: accentDark,
      ));
    }
    else {
      // error, showed error and just return
      ScaffoldMessenger.of(context).showSnackBar(
        createSnackBar(
          message: "Month and Amount cannot be empty",
        )
      );
    }

    // set state, to rebuild the page
    setState(() {
    });
  }

  Widget _calcRow({
    required String month,
    required String percentage,
    required String interest,
    required String value,
    double? borderWidth,
    Color? borderColor,
    double? fontSize,
    FontWeight?
    fontWeight,
    Color? fontColor,
    TextAlign? textAlign,
    Color? bgColor
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: (bgColor ?? Colors.transparent),
        border: Border(
          bottom: BorderSide(
            color: (borderColor ?? primaryLight),
            width: (borderWidth ?? 1),
          )
        )
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(5),
              child: Text(
                month,
                style: TextStyle(
                  fontSize: (fontSize ?? 10),
                  fontWeight: (fontWeight ?? FontWeight.normal),
                  color: (fontColor ?? textPrimary),
                ),
                textAlign: (textAlign ?? TextAlign.left),
              )
            ),
          ),
          const SizedBox(width: 5,),
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.all(5),
              child: Text(
                percentage,
                style: TextStyle(
                  fontSize: (fontSize ?? 10),
                  fontWeight: (fontWeight ?? FontWeight.normal),
                  color: (fontColor ?? textPrimary),
                ),
                textAlign: (textAlign ?? TextAlign.left),
              )
            ),
          ),
          const SizedBox(width: 5,),
          Expanded(
            flex: 6,
            child: Container(
              padding: const EdgeInsets.all(5),
              child: Text(
                interest,
                style: TextStyle(
                  fontSize: (fontSize ?? 10),
                  fontWeight: (fontWeight ?? FontWeight.normal),
                  color: (fontColor ?? textPrimary),
                ),
                textAlign: (textAlign ?? TextAlign.left),
              )
            ),
          ),
          const SizedBox(width: 5,),
          Expanded(
            flex: 6,
            child: Container(
              padding: const EdgeInsets.all(5),
              child: Text(
                value,
                style: TextStyle(
                  fontSize: (fontSize ?? 10),
                  fontWeight: (fontWeight ?? FontWeight.normal),
                  color: (fontColor ?? textPrimary),
                ),
                textAlign: (textAlign ?? TextAlign.left),
              )
            ),
          ),
        ],
      ),
    );
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
            _currentDayIndex = value;
            _infoReksadana = (_infoReksadanaData[_currentDayIndex] ?? []);

            _generateInfoSort();
            _generateGraphData();
            _generateIndexGraph();
          });
        }),
        groupValue: _currentDayIndex,
        selectedColor: extendedColor,
        borderColor: Colors.transparent,
        pressedColor: textPrimary,
      ),
    );
  }

  Future<bool> _getInitData() async {
    try {
      // company detail information is mandatory, so get the company information
      // first before we call the other API
      await _companyApi.getCompanyDetail(
        companyId:  _companyData.companyId,
        type: _companyData.type,
      ).then((resp) {
        _companyDetail = resp;

        // calculate the average daily based on the daily, weekly, monthly, quarterly, semi annual, and yearly
        _avgDaily = 0;
        _avgCount = 0;
        if (_companyDetail.companyDailyReturn != null) {
          _avgDaily = _avgDaily! + _companyDetail.companyDailyReturn!;
          _avgCount++;
        }
        if (_companyDetail.companyWeeklyReturn != null) {
          _avgDaily = _avgDaily! + (_companyDetail.companyDailyReturn! / 5);
          _avgCount++;
        }
        if (_companyDetail.companyMonthlyReturn != null) {
          _avgDaily = _avgDaily! + (_companyDetail.companyMonthlyReturn! / 21.67);
          _avgCount++;
        }
        if (_companyDetail.companyQuarterlyReturn != null) {
          _avgDaily = _avgDaily! + (_companyDetail.companyQuarterlyReturn! / 65);
          _avgCount++;
        }
        if (_companyDetail.companySemiAnnualReturn != null) {
          _avgDaily = _avgDaily! + (_companyDetail.companySemiAnnualReturn! / 130);
          _avgCount++;
        }
        if (_companyDetail.companyYearlyReturn != null) {
          _avgDaily = _avgDaily! + (_companyDetail.companyYearlyReturn! / 260);
          _avgCount++;
        }
        _avgDaily = (_avgDaily! / _avgCount);

        // calculate again the from and to date based on the company last update
        _to = (_companyDetail.companyLastUpdate ?? DateTime.now()).toLocal();
        _from = _to.subtract(const Duration(days: 365));

        // initialize weekday and monthly performance data
        // we will use 3 month data for the weekday performance date
        _weekdayPerformanceDateTo = (_companyDetail.companyLastUpdate ?? DateTime.now());
        _weekdayPerformanceDateFrom = _weekdayPerformanceDateTo.subtract(Duration(days: 90));

        // initialize the monthly performance date
        _monthlyPerformanceDateFrom = DateTime(_weekdayPerformanceDateTo.year, 1, 1);
        _monthlyPerformanceDateTo = _weekdayPerformanceDateTo;

        // check whether the company last update is before the maximum update
        if (_companyDetail.companyLastUpdate != null) {
          if (_companyDetail.companyLastUpdate!.isBeforeDate(date: _lastUpdate.reksadana)) {
            _isWarning = true;
          }
        }
      }).onError((error, stackTrace) {
        Log.error(
          message: "Error when get company information",
          error: error,
          stackTrace: stackTrace,
        );
        throw Exception ("Error when get company information");  
      });

      // get the minimum and maximum date that we can use as barrier when
      // we want to select some data
      await _infoReksadanaAPI.getInfoReksadanaMinMaxDate(
        companyId: _companyData.companyId,
      ).then((resp) {
        _minMaxDate = resp;
      },).onError((error, stackTrace) {
        Log.error(
          message: "Error when get info reksadana min max date",
          error: error,
          stackTrace: stackTrace,
        );
        throw Exception ("Error when get min and max date");  
      },);

      await Future.wait([
        _infoReksadanaAPI.getInfoReksadanaDate(
          companyId: _companyData.companyId,
          from: _from,
          to: _to,
        ).then((resp) {
          // clear info reksadana
          _infoReksadanaData.clear();
          
          // initialize info reksadana
          _infoReksadanaData[30] = [];
          _infoReksadanaData[60] = [];
          _infoReksadanaData[90] = [];
          _infoReksadanaData[180] = [];
          _infoReksadanaData[365] = [];

          // loop thru response to populate the info reksadana map
          for(int i=0; i<resp.length; i++) {
            if (i < 30) {
              _infoReksadanaData[30]!.add(resp[i]);
            }

            if (i < 60) {
              _infoReksadanaData[60]!.add(resp[i]);
            }

            if (i < 90) {
              _infoReksadanaData[90]!.add(resp[i]);
            }

            if (i < 180) {
              _infoReksadanaData[180]!.add(resp[i]);
            }

            if (i < 365) {
              _infoReksadanaData[365]!.add(resp[i]);
            }
          }

          // loop thru the 90 days to populate the heat map graph since the
          // maximum heat map graph is 70 (5 * 14).
          // clear the heat map graph
          _heatMapGraphData.clear();
          
          // loop thru reksadana information to get the heat map data
          for(int i=0; (i < _infoReksadanaData[90]!.length && _heatMapGraphData.length < 98); i++) {
            _heatMapGraphData[_infoReksadanaData[90]![i].date] = GraphData(
              date: _infoReksadanaData[90]![i].date,
              price: _infoReksadanaData[90]![i].netAssetValue,
            );
          }

          // sort the map as it will be in reverse order
          _heatMapGraphData = sortedMap<DateTime, GraphData>(data: _heatMapGraphData);

          // set the info reksadana list based on the current day index
          // selected.
          _infoReksadana = (_infoReksadanaData[_currentDayIndex] ?? []);

          // generate info sort from _infoReksadana
          _generateInfoSort();

          // generate the graph data
          _generateGraphData();
        }),

        _watchlistAPI.findDetail(
          companyId: _companyData.companyId
        ).then((resp) {
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
        }),

        // get the weekday and monthly analysis
        _companyApi.getCompanyWeekdayPerformance(
          type: 'reksadana',
          code: _companyData.companyId.toString(),
          fromDate: _weekdayPerformanceDateFrom,
          toDate: _weekdayPerformanceDateTo
        ).then((resp) {
          _weekdayPerformance = resp;
        }),

        _companyApi.getCompanyMonthlyPerformance(
          type: 'reksadana',
          code: _companyData.companyId.toString(),
          fromDate: _monthlyPerformanceDateFrom,
          toDate: _monthlyPerformanceDateTo,
        ).then((resp) {
          _monthlyPerformance = resp;
        }),

        _companyApi.getCompanyPortofolioAsset(
          companyId: _companyData.companyId,
        ).then((resp) {
          _portofolioAssetModel = resp;

          double totalValue = 0;
          for(int i=0; i<_portofolioAssetModel.portofolio.length; i++) {
            totalValue += _portofolioAssetModel.portofolio[i].value;
          }

          // clear the bar chart data first
          _portofolioBarChart.clear();

          // generate bar chart data based on the portofolio
          for(int i=0; i<_portofolioAssetModel.portofolio.length; i++) {
            int colorIndex = i % (Globals.colorList.length - 1);
            _portofolioBarChart.add(
              BarChartData(
                title: _portofolioAssetModel.portofolio[i].name,
                value: _portofolioAssetModel.portofolio[i].value,
                total: totalValue,
                color: Globals.colorList[colorIndex],
              )
            );
          }
        }),

        // check if this company owned by user or not?
        _checkIfOwned(),
      ]).onError((error, stackTrace) {
        throw Exception('Error when getting data from server');
      });
    }
    catch(error) {
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

    // get the company detail information
    await _companyApi.getCompanyByID(
      companyId: _otherCompany.companyId,
      type: 'reksadana'
    ).then((resp) {
      _otherCompanyDetail = resp;
    }).onError((error, stackTrace) {
      Log.error(
        message: "Error when get other company detail",
        error: error,
        stackTrace: stackTrace,
      );

      // show error on the screen
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(createSnackBar(message: "Error when get other company detail"));
      }
    },);

    // once finished hide the loading screen
    LoadingScreen.instance().hide();
  }

  void _generateGraphData() {
    // map the price date on company
    double totalPrice = 0;
    int totalPriceData = 0;

    // create variable helper for movement chart data
    Map<String, double> daily = {};
    Map<String, double> weekly = {};
    Map<String, double> monthly = {};
    Map<String, double> yearly = {};

    // calculate the date offset for the movement data based on the info
    // reksadana length
    _dateOffset = (_infoReksadana.length ~/ 10);

    // initialize the minimum and maximum price
    _minPrice = _companyDetail.companyNetAssetValue;
    _maxPrice = _companyDetail.companyNetAssetValue;

    // clear the unit and total graph data
    _unitData.clear();
    _assetData.clear();
    _graphData.clear();
    _movementData.clear();

    // loop thru the current info reksadana to generate the graph data
    for (InfoReksadanaModel data in _infoReksadana.toList().reversed) {
      // check the minimum and maximum price
      if(_minPrice! > data.netAssetValue) {
        _minPrice = data.netAssetValue;
      }

      if(_maxPrice! < data.netAssetValue) {
        _maxPrice = data.netAssetValue;
      }

      // calculate the total price to get the average data later
      totalPrice += data.netAssetValue;
      totalPriceData++;

      // create the unit and total graph data
      _graphData.add(GraphData(date: data.date.toLocal(), price: data.netAssetValue));
      _unitData.add(GraphData(date: data.date.toLocal(), price: data.totalUnit));
      _assetData.add(GraphData(date: data.date.toLocal(), price: data.totalUnit * data.netAssetValue));

      // generate the movement chart data
      daily[Globals.dfddMM.formatLocal(data.date)] = data.dailyReturn * 100;
      weekly[Globals.dfddMM.formatLocal(data.date)] = data.weeklyReturn * 100;
      monthly[Globals.dfddMM.formatLocal(data.date)] = data.monthlyReturn * 100;
      yearly[Globals.dfddMM.formatLocal(data.date)] = data.yearlyReturn * 100;
    }

    // add the movement data
    _movementData.add(daily);
    _movementData.add(weekly);
    _movementData.add(monthly);
    _movementData.add(yearly);

    // compute average, assume the average is current price in case the
    // total price data is 0
    _avgPrice = _companyDetail.companyNetAssetValue;
    if (totalPriceData > 0) {
      _avgPrice = totalPrice / totalPriceData;
    }
    _numPrice = totalPriceData;
  }

  Future<void> _getIndexData() async {
    // ensure we have _perfDataDaily
    if (_graphData.isNotEmpty) {
      // show loading screen
      LoadingScreen.instance().show(context: context);

      await _indexAPI.getIndexPriceDate(
        indexID: _indexCompare.indexId,
        from: _infoReksadanaData[365]!.last.date,
        to: _infoReksadanaData[365]!.first.date
      ).then((resp) async {
        _indexComparePrice = resp;

        // generate the index performance data
        await Future.microtask(() async {
          // first generate the index map
          await _generateIndexMap();

          // then we generate the graph
          await _generateIndexGraph();
        },);

        // once finished just set state so we can rebuild the page
        setState(() {
        });
      },).onError((error, stackTrace) {
        Log.error(
          message: "Error when get index price",
          error: error,
          stackTrace: stackTrace,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(createSnackBar(message: "Error when get index price"));
        }
      },).whenComplete(() {
        // remove the loading screen
        LoadingScreen.instance().hide();
      },);
    }
  }

  Future<void> _generateIndexMap() async {
    // convert data from list index price model to map data
    // this is needed so we can have the same data as graph data later on

    // first clear the map
    _indexPriceMap.clear();

    // loop thru the index compare price that we got from API
    for(IndexPriceModel price in _indexComparePrice) {
      _indexPriceMap[price.indexPriceDate.toLocal()] = price.indexPriceValue;
    }
  }

  Future<void> _generateIndexGraph() async {
    // ensure that we have _indexPriceMap
    if (_indexPriceMap.isNotEmpty) {
      // create temporary graph data
      List<GraphData> tempGraph = [];

      // loop thru graph data
      for(GraphData data in _graphData) {
        // check if this date exists in index map or not?
        if (_indexPriceMap.containsKey(data.date.toLocal())) {
          // add this data to the tempGraph
          tempGraph.add(
            GraphData(
              date: data.date.toLocal(),
              price: _indexPriceMap[data.date.toLocal()]!,
            )
          );
        }
        else {
          // check if tempGraph already got data or not?
          if (tempGraph.isNotEmpty) {
            // just use the last one
            GraphData lastData = tempGraph.last;
            tempGraph.add(lastData);
          }
          else {
            // no data here, just make it 0
            tempGraph.add(
              GraphData(
                date: data.date.toLocal(),
                price: 0,
              )
            );
          }
        }
      }

      // clear index data, and copy it from tempGraph
      _indexData.clear();
      _indexData = tempGraph.toList();
    }
  }

  Future<void> _getWeekdayPerformance() async {
    // show loading screen
    LoadingScreen.instance().show(context: context);

    await _companyApi.getCompanyWeekdayPerformance(
      type: 'reksadana',
      code: _companyData.companyId.toString(),
      fromDate: _weekdayPerformanceDateFrom,
      toDate: _weekdayPerformanceDateTo
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

    await _companyApi.getCompanyMonthlyPerformance(
      type: 'reksadana',
      code: _companyData.companyId.toString(),
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

  void _generateInfoSort() {
    double? dayDiff;
    Color dayDiffColor;
    double currPrice;
    double prevPrice;

    // first clear the info reksadana sort
    _infoReksadanaSort.clear();

    // loop thru info reksadana
    for(int index=0; index < _infoReksadana.length; index++) {
      dayDiff = null;
      dayDiffColor = Colors.transparent;

      // check if we already got previous date price
      if((index+1) < _infoReksadana.length) {
        currPrice = _infoReksadana[index].netAssetValue;
        prevPrice = _infoReksadana[index + 1].netAssetValue;
        dayDiff = currPrice - prevPrice;
        dayDiffColor = riskColor(
          value: currPrice,
          cost: prevPrice,
          riskFactor: _userInfo!.risk
        );
      }

      // create the list data
      CompanyDetailList data = CompanyDetailList(
        date: _infoReksadana[index].date,
        price: _infoReksadana[index].netAssetValue,
        diff: _companyDetail.companyNetAssetValue! - _infoReksadana[index].netAssetValue,
        riskColor: riskColor(
          value: _companyDetail.companyNetAssetValue!,
          cost: _infoReksadana[index].netAssetValue,
          riskFactor: _userInfo!.risk
        ),
        dayDiff: dayDiff,
        dayDiffColor: dayDiffColor
      );

      // add to info reksadana sort
      _infoReksadanaSort.add(data);
    }

    // just call sort info here
    _sortInfo();
  }

  void _sortInfo() {
    switch(_columnType) {
      case ColumnType.price:
        _infoReksadanaSort.sort((a, b) => (a.price.compareTo(b.price)));
        break;
      case ColumnType.diff:
        _infoReksadanaSort.sort((a, b) => (a.diff.compareTo(b.diff)));
        break;
      case ColumnType.gainloss:
        _infoReksadanaSort.sort((a, b) => ((a.dayDiff ?? 0).compareTo((b.dayDiff ?? 0))));
        break;
      default:
        _infoReksadanaSort.sort((a, b) => (a.date.compareTo(b.date)));
        break;
    }

    // check if this is descending?
    if (_sortType == SortType.descending) {
      _infoReksadanaSort = _infoReksadanaSort.reversed.toList();
    }
  }
}