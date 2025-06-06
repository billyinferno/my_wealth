import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:ionicons/ionicons.dart';
import 'package:my_wealth/_index.g.dart';

class InsightBrokerSpecificCompanyPage extends StatefulWidget {
  const InsightBrokerSpecificCompanyPage({super.key});

  @override
  State<InsightBrokerSpecificCompanyPage> createState() => _InsightBrokerSpecificCompanyPageState();
}

class _InsightBrokerSpecificCompanyPageState extends State<InsightBrokerSpecificCompanyPage> with SingleTickerProviderStateMixin {
  final BrokerSummaryAPI _brokerSummaryAPI = BrokerSummaryAPI();
  final CompanyAPI _companyAPI = CompanyAPI();
  final ScrollController _scrollControllerBrokerSummary = ScrollController();
  final ScrollController _scrollControllerBrokerTop = ScrollController();
  final ScrollController _scrollControllerCompanySahamList = ScrollController();
  final ScrollController _chipController = ScrollController();
  late TabController _tabController;

  final TextStyle _topBrokerHeader = const TextStyle(
    color: accentColor,
    fontWeight: FontWeight.bold,
    fontSize: 10,
  );
  final TextStyle _topBrokerRow = const TextStyle(
    fontSize: 10,
  );
  final CompanyFindOtherArgs _companyFindOtherArgs = const CompanyFindOtherArgs(
    type: 'saham',
  );

  final List<FlipFlopItem<CalendarType>> _brokerFlipFlopItem = [];
  late CalendarType _brokerCalendarType;

  late List<Widget> _pageItemsSummary;
  late List<Widget> _pageItemsTop;
  late String _companySahamCode;
  late DateTime _dateCurrent;
  late DateTime _dateFrom;
  late DateTime _dateTo;
  late DateTime _brokerMinDate;
  late DateTime _brokerMaxDate;
  late CompanyListModel? _companyData;
  late CompanyDetailModel? _companyDetail;
  late BrokerSummaryModel? _brokerSummaryData;
  late BrokerSummaryModel? _brokerSummaryDataGross;
  late BrokerSummaryModel? _brokerSummaryDataNet;
  late BrokerSummaryBuySellModel _brokerSummaryCurrent;
  late CompanyTopBrokerModel? _brokerTopData;
  late String _brokerSummarySelected;
  late bool _showNet;
  late UserLoginInfoModel? _userInfo;

  @override
  void initState() {
    super.initState();

    // initialize tab controller
    _tabController = TabController(length: 2, vsync: this);

    // get user information
    _userInfo = UserSharedPreferences.getUserInfo();

    // initialize the value
    _brokerSummaryDataGross = InsightSharedPreferences.getBrokerCompanyGross();
    _brokerSummaryDataNet = InsightSharedPreferences.getBrokerCompanyNet();

    _companySahamCode = InsightSharedPreferences.getBrokerCompanyStockCode();
    _brokerSummaryData = _brokerSummaryDataGross;
    _brokerSummarySelected = "a";
    _showNet = false;

    _brokerTopData = InsightSharedPreferences.getBrokerCompanyTopBroker();
    _companyData = InsightSharedPreferences.getBrokerCompanyList();
    _companyDetail = InsightSharedPreferences.getBrokerCompanyDetail();

    // page result
    _pageItemsSummary = [];
    _pageItemsTop = [];

    // check whether broker summary data is null or not?
    // if not null, it means the cache result is still there so we can default
    // the initial current data to the broker summary data in cache.
    if (_brokerSummaryData != null) {
      _brokerSummaryCurrent = _brokerSummaryData!.brokerSummaryAll;
      _generateSummaryPage();
    }

    // if broker top data is not null then generate the top page
    if (_brokerTopData != null) {
      _generateTopPage();
    }

    _dateCurrent = DateTime.now().toLocal();
    _dateFrom = (InsightSharedPreferences.getBrokerCompanyDate(type: DateType.from) ?? DateTime.now().subtract(const Duration(days: 30)).toLocal());
    _dateTo = (InsightSharedPreferences.getBrokerCompanyDate(type: DateType.to) ?? DateTime.now().subtract(const Duration(days: 1)).toLocal());
    _brokerMinDate = (BrokerSharedPreferences.getBrokerMinDate() ?? _dateFrom).toLocal();
    _brokerMaxDate = (BrokerSharedPreferences.getBrokerMaxDate() ?? _dateTo).toLocal();

    // check brokerMinDate is more than _dateFrom or not?
    if (_brokerMinDate.isAfter(_dateFrom)) {
      // means that we cannot parse from that date, we can only parse from
      // _brokerMinDate
      _dateFrom = _brokerMinDate;
    }

    // check if brokerMaxDate if lesser than _dateTo or not?
    if (_brokerMaxDate.isBefore(_dateTo)) {
      // means that we cannot parse to that date, we can only parse until
      // _brokerMaxDate
      _dateTo = _brokerMaxDate;
    }

    // add the flip flop items for top broker
    _brokerCalendarType = CalendarType.day;
    _brokerFlipFlopItem.add(FlipFlopItem(
      key: CalendarType.day,
      icon: LucideIcons.calendar_1,
    ));
    _brokerFlipFlopItem.add(FlipFlopItem(
      key: CalendarType.year,
      icon: LucideIcons.calendar_range,
    ));
  }

  @override
  void dispose() {
    _scrollControllerBrokerSummary.dispose();
    _scrollControllerBrokerTop.dispose();
    _scrollControllerCompanySahamList.dispose();
    _chipController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            "Specific Company Code",
            style: TextStyle(
              color: secondaryColor,
            ),
          ),
        ),
      ),
      body: MySafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(10),
              color: primaryDark,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(height: 10,),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            const Text(
                              "Stock",
                              style: TextStyle(
                                color: accentColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5,),
                            InkWell(
                              onTap: (() async {
                                // navigate to the find other company list and we will get the value from there
                                await Navigator.pushNamed(
                                  context, '/company/detail/find',
                                  arguments: _companyFindOtherArgs
                                ).then((value) {
                                  if (value != null) {
                                    // convert value to company list model
                                    _companyData = value as CompanyListModel;
        
                                    _getCompanyDataAndSearch();
                                  }
                                });
                              }),
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: primaryLight,
                                    width: 1.0,
                                    style: BorderStyle.solid,
                                  ),
                                  color: primaryColor,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Center(
                                  child: Text(
                                    (_companySahamCode.isEmpty ? '-' : _companySahamCode),
                                    style: const TextStyle(
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(width: 5,),
                      Expanded(
                        flex: 5,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            const Text(
                              "Date",
                              style: TextStyle(
                                color: accentColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5,),
                            InkWell(
                              onTap: (() async {
                                await _showCalendar().onError((error, stackTrace) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(createSnackBar(message: error.toString()));
                                  }
                                },);
                              }),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: primaryLight,
                                          width: 1.0,
                                          style: BorderStyle.solid,
                                        ),
                                        color: primaryColor,
                                        borderRadius: const BorderRadius.only(
                                          bottomLeft: Radius.circular(5),
                                          topLeft: Radius.circular(5)
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          Globals.dfddMMyyyy2.formatLocal(_dateFrom),
                                          style: const TextStyle(
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: primaryLight,
                                          width: 1.0,
                                          style: BorderStyle.solid,
                                        ),
                                        color: primaryColor,
                                        borderRadius: const BorderRadius.only(
                                          bottomRight: Radius.circular(5),
                                          topRight: Radius.circular(5)
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          Globals.dfddMMyyyy2.formatLocal(_dateTo),
                                          style: const TextStyle(
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 5,),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          const Text(""),
                          const SizedBox(height: 5,),
                          InkWell(
                            onTap: (() async {
                              // check that broker and code already filled
                              if (_companySahamCode.isEmpty) {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return CupertinoAlertDialog(
                                      title: const Text("Select Company Code"),
                                      content: const Text("Please company code from the list, before run the query."),
                                      actions: <CupertinoDialogAction>[
                                        CupertinoDialogAction(
                                          onPressed: (() {
                                            Navigator.pop(context);
                                          }),
                                          child: const Text("OK"),
                                        )
                                      ],
                                    );
                                  }
                                );
                              }
                              else {
                                await _getBrokerTransaction().then((_) {  
                                  setState(() {
                                    // generate the summary and top page
                                    _generateSummaryPage();
                                    _generateTopPage();
                                  });
                                },);
                              }
                            }),
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: secondaryDark,
                                  width: 1.0,
                                  style: BorderStyle.solid,
                                ),
                                borderRadius: BorderRadius.circular(5),
                                color: secondaryColor,
                              ),
                              child: const Icon(
                                Ionicons.search,
                                color: textPrimary,
                                size: 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 5,),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          const Text(""),
                          const SizedBox(height: 5,),
                          FlipFlopSwitch<CalendarType>(
                            icons: _brokerFlipFlopItem,
                            initialKey: _brokerCalendarType,
                            onChanged: <CalendarType>(key) {
                              _brokerCalendarType = key;
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Visibility(
                visible: (_companyDetail != null),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    SimpleCompanyInfo(
                      controller: _chipController,
                      company: _companyDetail,
                      risk: _userInfo!.risk,
                      onTap: () async {
                        await _getCompanyAndGo(code: _companySahamCode);
                      },
                    ),
                    TabBar(
                      controller: _tabController,
                      indicatorColor: accentColor,
                      indicatorSize: TabBarIndicatorSize.tab,
                      labelColor: textPrimary,
                      unselectedLabelColor: textPrimary,
                      dividerHeight: 0,
                      tabs: const <Widget>[
                        Tab(text: 'BROKER SUMMARY'),
                        Tab(text: 'TOP BROKER',)
                      ]
                    ),
                    const SizedBox(height: 10,),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: <Widget>[
                          _brokerSummaryPage(),
                          _brokerTopPage(),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      )
    );
  }

  Widget _tableRow({
    required String buyCode,
    required String buyLot,
    required String buyValue,
    required String buyAverage,
    TextStyle? buyStyle,
    Color? buyColor,
    required String sellCode,
    required String sellLot,
    required String sellValue,
    required String sellAverage,
    TextStyle? sellStyle,
    Color? sellColor
  }) {
    TextStyle currBuyStyle = (buyStyle ?? const TextStyle(color: textPrimary));
    currBuyStyle = currBuyStyle.copyWith(fontSize: 9,);

    TextStyle currSellStyle = (sellStyle ?? const TextStyle(color: textPrimary));
    currSellStyle = currSellStyle.copyWith(fontSize: 9,);

    return SizedBox(
      width: double.infinity,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          /* buy part */
          Expanded(
            child: Container(
              color: (buyColor ?? Colors.transparent),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                    width: 30,
                    child: Text(
                      buyCode,
                      style: currBuyStyle,
                    ),
                  ),
                  const SizedBox(width: 5,),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                      child: Text(
                        buyLot,
                        style: currBuyStyle,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(width: 5,),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                      child: Text(
                        buyValue,
                        style: currBuyStyle,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(width: 5,),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                      child: Text(
                        buyAverage,
                        style: currBuyStyle,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          /* sell part */
          Expanded(
            child: Container(
              color: (sellColor ?? Colors.transparent),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                    width: 30,
                    child: Text(
                      sellCode,
                      style: currSellStyle,
                    ),
                  ),
                  const SizedBox(width: 5,),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                      child: Text(
                        sellLot,
                        style: currSellStyle,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(width: 5,),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                      child: Text(
                        sellValue,
                        style: currSellStyle,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(width: 5,),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                      child: Text(
                        sellAverage,
                        style: currSellStyle,
                        overflow: TextOverflow.ellipsis,
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
  }

  void _generateSummaryPage() {
    // clear the page
    _pageItemsSummary.clear();

    // get which one is larger the buy or sell?
    int maxPage = _brokerSummaryCurrent.brokerSummaryBuy.length;
    if (maxPage < _brokerSummaryCurrent.brokerSummarySell.length) {
      maxPage = _brokerSummaryCurrent.brokerSummarySell.length;
    }

    String buyCode;
    String buyLot;
    String buyValue;
    String buyAverage;
    String sellCode;
    String sellLot;
    String sellValue;
    String sellAverage;

    // now loop thru maxPage
    for (int i = 0; i < maxPage; i++) {
      buyCode = '-';
      buyLot = '-';
      buyValue = '-';
      buyAverage = '-';
      sellCode = '-';
      sellLot = '-';
      sellValue = '-';
      sellAverage = '-';

      if (_brokerSummaryCurrent.brokerSummaryBuy.length > i) {
        buyCode = _brokerSummaryCurrent.brokerSummaryBuy[i].brokerSummaryID!;
        buyLot = formatIntWithNull(
          _brokerSummaryCurrent.brokerSummaryBuy[i].brokerSummaryLot,
          checkThousand: true,
          showDecimal: false
        );
        buyValue = formatCurrencyWithNull(
          _brokerSummaryCurrent.brokerSummaryBuy[i].brokerSummaryValue,
          checkThousand: true,
          showDecimal: false
        );
        buyAverage = formatCurrencyWithNull(
          _brokerSummaryCurrent.brokerSummaryBuy[i].brokerSummaryAverage,
          showDecimal: false
        );
      }

      if (_brokerSummaryCurrent.brokerSummarySell.length > i) {
        sellCode = _brokerSummaryCurrent.brokerSummarySell[i].brokerSummaryID!;
        sellLot = formatIntWithNull(
          _brokerSummaryCurrent.brokerSummarySell[i].brokerSummaryLot,
          checkThousand: true,
          showDecimal: false
        );
        sellValue = formatCurrencyWithNull(
          _brokerSummaryCurrent.brokerSummarySell[i].brokerSummaryValue,
          checkThousand: true,
          showDecimal: false
        );
        sellAverage = formatCurrencyWithNull(
          _brokerSummaryCurrent.brokerSummarySell[i].brokerSummaryAverage,
          showDecimal: false
        );
      }

      _pageItemsSummary.add(
        _tableRow(
          buyCode: buyCode,
          buyLot: buyLot,
          buyValue: buyValue,
          buyAverage: buyAverage,
          sellCode: sellCode,
          sellLot: sellLot,
          sellValue: sellValue,
          sellAverage: sellAverage
        )
      );
    }
  }

  Widget _brokerSummaryPage() {
    if (_brokerSummaryData == null) {
      return const SizedBox.shrink();
    }

    // ensure that we have data
    if ( _brokerSummaryData!.brokerSummaryAll.brokerSummaryBuy.isNotEmpty ||
         _brokerSummaryData!.brokerSummaryAll.brokerSummarySell.isNotEmpty ) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Row(
            children: [
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
                      if (selectedValue == "a") {
                        _brokerSummaryCurrent = _brokerSummaryData!.brokerSummaryAll;
                        _brokerSummarySelected = "a";
                      } else if (selectedValue == "d") {
                        _brokerSummaryCurrent = _brokerSummaryData!.brokerSummaryDomestic;
                        _brokerSummarySelected = "d";
                      } else if (selectedValue == "f") {
                        _brokerSummaryCurrent = _brokerSummaryData!.brokerSummaryForeign;
                        _brokerSummarySelected = "f";
                      }
                      _generateSummaryPage();
                    });
                  }),
                  groupValue: _brokerSummarySelected,
                  selectedColor: secondaryColor,
                  borderColor: secondaryDark,
                  pressedColor: primaryDark,
                ),
              ),
              const SizedBox(width: 5,),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
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
                            _setBrokerSummary(_brokerSummaryDataNet);
                          } else {
                            _setBrokerSummary(_brokerSummaryDataGross);
                          }
                        }),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10,),
          Container(
            margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
            child: _tableRow(
              buyCode: "BY",
              buyLot: "B.Lot",
              buyValue: "B.Val",
              buyAverage: "B.Avg",
              buyStyle: const TextStyle(fontWeight: FontWeight.bold),
              buyColor: secondaryDark,
              sellCode: "SY",
              sellLot: "S.Lot",
              sellValue: "S.Val",
              sellAverage: "S.Avg",
              sellStyle: const TextStyle(fontWeight: FontWeight.bold),
              sellColor: Colors.green[900],
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              decoration: BoxDecoration(
                border: Border.all(
                  color: primaryLight,
                  width: 1.0,
                  style: BorderStyle.solid,
                )
              ),
              child: ListView.builder(
                controller: _scrollControllerBrokerSummary,
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: _pageItemsSummary.length,
                itemBuilder: (context, index) {
                  return _pageItemsSummary[index];
                },
              ),
            ),
          ),
        ],
      );
    } else {
      return const Center(child: Text("No data to be displayed"));
    }
  }

  void _generateTopPage() {
    double currentValue;
    double currentDiff;

    // clear current page items for top tab
    _pageItemsTop.clear();

    // loop thru all the broker summary top data
    for (int i = 0; i < _brokerTopData!.brokerData.length; i++) {
      currentValue = (_brokerTopData!.brokerData[i].brokerSummaryLot * (_companyDetail!.companyNetAssetValue ?? 0)) * 100;
      currentDiff = (currentValue - (_brokerTopData!.brokerData[i].brokerSummaryValue * 100));

      _pageItemsTop.add(
        Container(
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
                  _brokerTopData!.brokerData[i].brokerSummaryId,
                  style: _topBrokerRow,
                )
              ),
              const SizedBox(width: 3,),
              Expanded(
                flex: 3,
                child: Text(
                  formatIntWithNull(
                    _brokerTopData!.brokerData[i].brokerSummaryLot,
                    showDecimal: false
                  ),
                  style: _topBrokerRow,
                )
              ),
              const SizedBox(width: 3,),
              Expanded(
                flex: 3,
                child: Text(
                  formatCurrency(
                    _brokerTopData!.brokerData[i].brokerSummaryAverage,
                    showDecimal: false,
                  ),
                  style: _topBrokerRow,
                )
              ),
              const SizedBox(width: 3,),
              Expanded(
                flex: 3,
                child: Text(
                  formatCurrencyWithNull(
                    _brokerTopData!.brokerData[i].brokerSummaryValue * 100
                  ),
                  style: _topBrokerRow,
                )
              ),
              const SizedBox(width: 3,),
              Expanded(
                flex: 3,
                child: Text(
                  formatCurrency(
                    currentValue,
                    showDecimal: false,
                  ),
                  style: _topBrokerRow,
                )
              ),
              const SizedBox(width: 3,),
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
                )
              ),
            ],
          ),
        )
      );
    }
  }

  Widget _brokerTopPage() {
    if (_brokerTopData == null) {
      return const SizedBox.shrink();
    }

    if (_brokerTopData!.brokerData.isNotEmpty) {
      return Container(
        margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: primaryDark,
                border: Border.all(
                    color: primaryLight, width: 1.0, style: BorderStyle.solid),
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
            Expanded(
                child: ListView.builder(
              controller: _scrollControllerBrokerTop,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: _pageItemsTop.length,
              itemBuilder: (context, index) {
                return _pageItemsTop[index];
              },
            )),
          ],
        ),
      );
    } else {
      return const Center(child: Text("No data to be displayed"));
    }
  }

  Future<void> _showCalendar() async {
    if (_brokerCalendarType == CalendarType.day) {
      DateTimeRange? result = await showDateRangePicker(
        context: context,
        firstDate: _brokerMinDate.toLocal(),
        lastDate: _brokerMaxDate.toLocal(),
        initialDateRange:
            DateTimeRange(start: _dateFrom.toLocal(), end: _dateTo.toLocal()),
        confirmText: 'Done',
        currentDate: _dateCurrent.toLocal(),
        initialEntryMode: DatePickerEntryMode.calendarOnly,
      );

      // check if we got the result or not?
      if (result != null) {
        // check whether the result start and end is different date, if different then we need to get new broker summary data.
        if ((result.start.compareTo(_dateFrom) != 0) ||
            (result.end.compareTo(_dateTo) != 0)) {
          // set the broker from and to date
          _dateFrom = result.start;
          _dateTo = result.end;
          
          // check if all data is already available
          if (_companySahamCode.isEmpty) {
            setState(() {              
            });
          }
          else {
            // directly get the result so it will feel instant
            await _getBrokerTransaction().then((_) {  
              setState(() {
                // generate the summary and top page
                _generateSummaryPage();
                _generateTopPage();
              });
            },);
          }
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
                firstDate: _brokerMinDate.toLocal(),
                lastDate: _brokerMaxDate.toLocal(),
                startDate: _dateFrom.toLocal(),
                endDate: _dateTo.toLocal(),
                type: MyYearPickerCalendarType.range,
                onChanged: (value) async {
                  // remove the dialog
                  Navigator.pop(context);
  
                  // check the new date whether it's same year or not?
                  if (
                    value.startDate.toLocal().compareTo(_dateFrom.toLocal()) != 0 ||
                    value.endDate.toLocal().compareTo(_dateTo.toLocal()) != 0
                  ) {
                    // set the broker from and to date
                    _dateFrom = value.startDate;
                    _dateTo = value.endDate;
                    
                    // check whether all data is already present or not?
                    if (_companySahamCode.isEmpty) {
                      setState(() {                        
                      });
                    }
                    else {
                      // directly get the result so it will feel instant
                      await _getBrokerTransaction().then((_) {  
                        setState(() {
                          // generate the summary and top page
                          _generateSummaryPage();
                          _generateTopPage();
                        });
                      },);
                    }
                  }
                },
              ),
            ),
          );
        },
      );
    }
  }

  void _setBrokerSummary(BrokerSummaryModel? value) {
    if (value == null) {
      return;
    }

    setState(() {
      _brokerSummaryData = value;
      // check what is current broker summary being selected
      if (_brokerSummarySelected == 'a') {
        _brokerSummaryCurrent = value.brokerSummaryAll;
      } else if (_brokerSummarySelected == 'd') {
        _brokerSummaryCurrent = value.brokerSummaryDomestic;
      } else if (_brokerSummarySelected == 'f') {
        _brokerSummaryCurrent = value.brokerSummaryForeign;
      }
      _generateSummaryPage();
    });
  }

  Future<void> _getBrokerTransaction() async {
    // show the loading screen
    LoadingScreen.instance().show(context: context);

    await Future.wait([
      // get the data of the broker transaction for this company code
      _brokerSummaryAPI.getBrokerSummary(
        stockCode: _companySahamCode,
        dateFrom: _dateFrom,
        dateTo: _dateTo
      ).then((resp) {
        _brokerSummaryData = resp;
        _brokerSummaryDataGross = resp;
      }),

      _brokerSummaryAPI.getBrokerSummaryNet(
        stockCode: _companySahamCode,
        dateFrom: _dateFrom,
        dateTo: _dateTo
      ).then((resp) {
        _brokerSummaryDataNet = resp;
      }),

      _companyAPI.getCompanyTopBroker(
        code: _companySahamCode,
        fromDate: _dateFrom,
        toDate: _dateTo,
        limit: 9999,
      ).then((resp) {
        _brokerTopData = resp;
      }),
    ]).then((_) {
      // reset the showed also
      _brokerSummaryCurrent = _brokerSummaryData!.brokerSummaryAll;
      _brokerSummarySelected = "a";
      _showNet = false;

      // stored all the information to shared preferences
      InsightSharedPreferences.setBrokerCompany(
        stockCode: _companySahamCode,
        fromDate: _dateFrom,
        toDate: _dateTo,
        companyDetail: _companyDetail!,
        companyList: _companyData!,
        summaryGross: _brokerSummaryDataGross!,
        summaryNet: _brokerSummaryDataNet!,
        topBroker: _brokerTopData!
      );
    }).onError((error, stackTrace) {
      // print the stack trace
      Log.error(
        message: 'Error getting broker data',
        error: error,
        stackTrace: stackTrace,
      );
      if (mounted) {
        // show snack bar for the error
        ScaffoldMessenger.of(context).showSnackBar(createSnackBar(message: "Error when try to fetch broker data"));
      }
    }).whenComplete(() {
      // remove loading screen when finished
      LoadingScreen.instance().hide();
    },);
  }

  Future<void> _getCompanyDataAndSearch() async {
    // check if current company saham code the same as the company code that
    // we query above
    if (_companySahamCode != _companyData!.companySymbol) {
      // show the loading screen
      LoadingScreen.instance().show(context: context);

      // get the company detail
      await _companyAPI.getCompanyByCode(
        companyCode: _companyData!.companySymbol,
        type: 'saham'
      ).then((resp) {
        _companyDetail = resp;
      }).onError((error, stackTrace) {
        Log.error(
          message: 'Error getting company info',
          error: error,
          stackTrace: stackTrace,
        );
        if (mounted) {
          // show snack bar for the error
          ScaffoldMessenger.of(context).showSnackBar(createSnackBar(message: "Error when try to fetch company info"));
        }
        return;
      },).whenComplete(() {
        // remove loading screen
        LoadingScreen.instance().hide();
      },);

      // set the company saham code with the company data that we got
      _companySahamCode = _companyDetail!.companySymbol!;

      // clear the current search result
      _brokerSummaryData = null;
      _brokerTopData = null;

      // directly get the broker transaction for this stock so the result will
      // feel instantious instead ask user to press search again.
      // on error is already handle on the _getBrokerTransaction method.
      await _getBrokerTransaction().then((_) {  
        setState(() {
          // generate the summary and top page
          _generateSummaryPage();
          _generateTopPage();
        });
      },);
    }
  }

  Future<void> _getCompanyAndGo({required String code}) async {
    // show loading screen
    LoadingScreen.instance().show(context: context);

    // get the company detail and navigate to the company page
    await _companyAPI.getCompanyByCode(
      companyCode: _companySahamCode,
      type: 'saham',
    ).then((resp) {
      CompanyDetailArgs args = CompanyDetailArgs(
        companyId: resp.companyId,
        companyName: resp.companyName,
        companyCode: _companySahamCode,
        companyFavourite: (resp.companyFavourites ?? false),
        favouritesId: (resp.companyFavouritesId ?? -1),
        type: "saham",
      );

      if (mounted) {
        // go to the company page
        Navigator.pushNamed(context, '/company/detail/saham', arguments: args);
      }
    }).onError((error, stackTrace) {
      if (mounted) {
        // show the error message
        ScaffoldMessenger.of(context).showSnackBar(createSnackBar(message:'Error when try to get the company detail from server'));
      }
    }).whenComplete(() {
      // remove the loading screen when finished
      LoadingScreen.instance().hide();
    },);
  }
}
