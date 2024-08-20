import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:intl/intl.dart';
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

  late List<WatchlistListModel> _watchlists;
  late bool _isOwned;

  late String _infoSort;
  late int _currentDayIndex;

  final DateFormat _df = DateFormat("dd/MM/yyyy");
  final DateFormat _dfShort = DateFormat("dd/MM");
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
  
  bool _showCurrentPriceComparison = false;
  bool _recurring = true;
  int _bodyPage = 0;
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
    // initialize tab
    _tabController = TabController(length: 2, vsync: this);

    // initialize variable
    _recurring = true;
    _showCurrentPriceComparison = false;
    _otherCompanyDetail = null;

    _bodyPage = 0;
    _numPrice = 0;

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
    _watchlists = WatchlistSharedPreferences.getWatchlist("reksadana");
    // assume that user don't own this
    _isOwned = false;

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
    _infoSort = "A";

    // initialize index compare data
    _indexCompareName = "";
    _indexComparePrice = [];
    _indexPriceMap = {};
    _indexData = [];

    _getData = _getInitData();

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
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
          IconButton(
            icon: Icon(
              (_infoSort == "A" ? LucideIcons.arrow_up_a_z : LucideIcons.arrow_down_z_a),
              color: textPrimary,
            ),
            onPressed: (() {
              setState(() {
                if (_infoSort == "A") {
                  _infoSort = "D";
                }
                else {
                  _infoSort = "A";
                }
    
                // just reversed the list
                _infoReksadanaSort = _infoReksadanaSort.reversed.toList();
              });
            }),
          ),
          const SizedBox(width: 10,),
        ],
      ),
      body: MySafeArea(
        child: Column(
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
                      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                      color: primaryColor,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            _companyData.companyName,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
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
                              Text(formatDateWithNulll(date: _companyDetail.companyLastUpdate, format: _df)),
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
                const SizedBox(width: 5,),
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
                const SizedBox(width: 5,),
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
                const SizedBox(width: 5,),
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
                const SizedBox(width: 5,),
                TransparentButton(
                  text: "Calc",
                  bgColor: primaryDark,
                  icon: Ionicons.calculator_outline,
                  callback: (() {
                    setState(() {
                      _bodyPage = 4;
                    });
                  }),
                  active: (_bodyPage == 4),
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
      case 0:
        return _showSummary();
      case 1:
        return _showTable();
      case 2:
        return _showCalendar();
      case 3:
        return _showGraph();
      case 4:
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
          ],
        ),
        const SizedBox(height: 10,),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: <Widget>[
              _tabSummaryInfo(),
              _tabCompareInfo(),
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
                const SizedBox(width: 10,),
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
            const SizedBox(height: 5,),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                CompanyInfoBox(
                  header: "Quarterly",
                  headerAlign: MainAxisAlignment.end,
                  child: Text(
                    "${formatDecimalWithNull(_companyDetail.companyQuarterlyReturn, 100)}%",
                    textAlign: TextAlign.right,
                  ),
                ),
                const SizedBox(width: 10,),
                CompanyInfoBox(
                  header: "Semi Annual",
                  headerAlign: MainAxisAlignment.end,
                  child: Text(
                    "${formatDecimalWithNull(_companyDetail.companySemiAnnualReturn, 100)}%",
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
                    "${formatDecimalWithNull(_companyDetail.companyYtdReturn, 100)}%",
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
                      child: Text("ADD COMPANY"),
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
            text: formatCurrencyWithNull((companyA?.companyNetAssetValue)),
            showCompare: false,
          ),
          CompareFields(
            color: primaryDark,
            borderColor: color,
            text: "${formatDecimalWithNull(companyA?.companyDailyReturn, 100)}%",
            isBigger: (companyB != null ? ((companyA?.companyDailyReturn ?? 0) - (companyB.companyDailyReturn ?? 0)) : 0),
            showCompare: (compare != null ? true : false),
          ),
          CompareFields(
            color: primaryDark,
            borderColor: color,
            text: "${formatDecimalWithNull(companyA?.companyWeeklyReturn, 100)}%",
            isBigger: (companyB != null ? ((companyA?.companyWeeklyReturn ?? 0) - (companyB.companyWeeklyReturn ?? 0)) : 0),
            showCompare: (compare != null ? true : false),
          ),
          CompareFields(
            color: primaryDark,
            borderColor: color,
            text: "${formatDecimalWithNull(companyA?.companyMonthlyReturn, 100)}%",
            isBigger: (companyB != null ? ((companyA?.companyMonthlyReturn ?? 0) - (companyB.companyMonthlyReturn ?? 0)) : 0),
            showCompare: (compare != null ? true : false),
          ),
          CompareFields(
            color: primaryDark,
            borderColor: color,
            text: "${formatDecimalWithNull(companyA?.companyQuarterlyReturn, 100)}%",
            isBigger: (companyB != null ? ((companyA?.companyQuarterlyReturn ?? 0) - (companyB.companyQuarterlyReturn ?? 0)) : 0),
            showCompare: (compare != null ? true : false),
          ),
          CompareFields(
            color: primaryDark,
            borderColor: color,
            text: "${formatDecimalWithNull(companyA?.companySemiAnnualReturn, 100)}%",
            isBigger: (companyB != null ? ((companyA?.companySemiAnnualReturn ?? 0) - (companyB.companySemiAnnualReturn ?? 0)) : 0),
            showCompare: (compare != null ? true : false),
          ),
          CompareFields(
            color: primaryDark,
            borderColor: color,
            text: "${formatDecimalWithNull(companyA?.companyYearlyReturn, 100)}%",
            isBigger: (companyB != null ? ((companyA?.companyYearlyReturn ?? 0) - (companyB.companyYearlyReturn ?? 0)) : 0),
            showCompare: (compare != null ? true : false),
          ),
          CompareFields(
            color: primaryDark,
            borderColor: color,
            text: "${formatDecimalWithNull(companyA?.companyYtdReturn, 100)}%",
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
                            const SizedBox(width: 5,),
                            Icon(
                              (_infoSort == "A" ? Ionicons.arrow_up : Ionicons.arrow_down),
                              size: 10,
                              color: textPrimary,
                            ),
                          ],
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
          child: ListView.builder(
            controller: _priceController,
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: _infoReksadanaSort.length,
            itemBuilder: (context, index) {
              // generate the company detail price list
              return CompanyDetailPriceList(
                date: _df.format(_infoReksadanaSort[index].date.toLocal()),
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

  Widget _showCalendar() {
    return SingleChildScrollView(
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
            ),
          ],
        ),
      ),
    );
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
        const SizedBox(height: 15,),
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
                        "${formatDecimalWithNull(_avgDaily, 100)}%",
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
                    activeColor: secondaryColor,
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
                  bgColor: secondaryDark,
                  icon: Ionicons.calculator,
                  callback: (() {
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
          percentage: "${formatDecimalWithNull(calcPercentage, 100, 2)}%",
          interest: formatCurrency(calcAmount, false, false, false, 0),
          value: formatCurrency((calcAmount + amount), false, false, false, 0),
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
        percentage: "${formatDecimalWithNull((averagePercentage / month), 100, 2)}%",
        interest: formatCurrency(totalInterest, false, false, false, 0),
        value: formatCurrency(totalAmount, false, false, false, 0),
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
      await _companyApi.getCompanyDetail(_companyData.companyId, _companyData.type).then((resp) {
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
      }).onError((error, stackTrace) {
        Log.error(
          message: "Error when get company information",
          error: error,
          stackTrace: stackTrace,
        );
        throw Exception ("Error when get company information");  
      });

      await Future.wait([
        _infoReksadanaAPI.getInfoReksadanaDate(_companyData.companyId, _from, _to).then((resp) {
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

        _watchlistAPI.findDetail(_companyData.companyId).then((resp) {
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
    await _companyApi.getCompanyByID(_otherCompany.companyId, 'reksadana').then((resp) {
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
    Map<String, double> monhtly = {};
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
      daily[_dfShort.format(data.date)] = data.dailyReturn * 100;
      weekly[_dfShort.format(data.date)] = data.weeklyReturn * 100;
      monhtly[_dfShort.format(data.date)] = data.monthlyReturn * 100;
      yearly[_dfShort.format(data.date)] = data.yearlyReturn * 100;
    }

    // add the movement data
    _movementData.add(daily);
    _movementData.add(weekly);
    _movementData.add(monhtly);
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
        _indexCompare.indexId,
        _infoReksadanaData[365]!.last.date,
        _infoReksadanaData[365]!.first.date
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
        dayDiffColor = riskColor(currPrice, prevPrice, _userInfo!.risk);
      }

      // create the list data
      CompanyDetailList data = CompanyDetailList(
        date: _infoReksadana[index].date,
        price: _infoReksadana[index].netAssetValue,
        diff: _companyDetail.companyNetAssetValue! - _infoReksadana[index].netAssetValue,
        riskColor: riskColor(_companyDetail.companyNetAssetValue!, _infoReksadana[index].netAssetValue, _userInfo!.risk),
        dayDiff: dayDiff,
        dayDiffColor: dayDiffColor
      );

      // add to info reksadana sort
      _infoReksadanaSort.add(data);
    }

    // check whether it's descending, if so then reverse the list
    if (_infoSort == "D") {
      _infoReksadanaSort = _infoReksadanaSort.reversed.toList();
    }
  }
}