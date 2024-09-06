import 'dart:collection';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:my_wealth/_index.g.dart';

class InsightBrokerSpecificQueryPage extends StatefulWidget {
  const InsightBrokerSpecificQueryPage({super.key});

  @override
  State<InsightBrokerSpecificQueryPage> createState() => _InsightBrokerSpecificQueryPageState();
}

class _InsightBrokerSpecificQueryPageState extends State<InsightBrokerSpecificQueryPage> {
  final BrokerSummaryAPI _brokerSummaryAPI = BrokerSummaryAPI();
  final CompanyAPI _companyAPI = CompanyAPI();
  final ScrollController _scrollController = ScrollController();
  final ScrollController _scrollControllerBrokerList = ScrollController();
  final ScrollController _scrollControllerCompanySahamList = ScrollController();
  final CompanyFindOtherArgs _companyFindOtherArgs = const CompanyFindOtherArgs(
    type: 'saham',
  );

  late CompanyListModel? _companyData;
  late CompanyDetailModel? _companyDetail;
  late BrokerModel _brokerData;
  late List<Widget> _pageItems;
  late String _brokerCode;
  late String _companySahamCode;
  late double _companySahamCodePrice;
  late double _currentCompanySahamCodePrice;
  late DateTime _dateCurrent;
  late DateTime _dateFrom;
  late DateTime _dateTo;
  late DateTime _brokerMinDate;
  late DateTime _brokerMaxDate;
  late BrokerSummaryTxnDetailModel? _brokerSummaryData;
  late int _totalBuyLot;
  late double _totalBuyAverage;
  late int _totalSellLot;

  @override
  void initState() {
    // initialize the value
    _brokerCode = "";
    _companySahamCode = "";
    _companySahamCodePrice = -1;
    _currentCompanySahamCodePrice = -1;
    _pageItems = [];
    _dateCurrent = DateTime.now().toLocal();
    _dateFrom = DateTime.now().subtract(const Duration(days: 30)).toLocal();
    _dateTo = DateTime.now().subtract(const Duration(days: 1)).toLocal();
    _brokerMinDate = (BrokerSharedPreferences.getBrokerMinDate() ?? _dateFrom);
    _brokerMaxDate = (BrokerSharedPreferences.getBrokerMaxDate() ?? _dateTo);
    
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

    _brokerSummaryData = null;

    // get the company saham list
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _scrollControllerBrokerList.dispose();
    _scrollControllerCompanySahamList.dispose();
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
            "Specific Broker and Code",
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            const Text(
                              "Broker",
                              style: TextStyle(
                                color: accentColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5,),
                            InkWell(
                              onTap: (() async {
                                // navigate to the find other company list and we will get the value from there
                                await Navigator.pushNamed(context, '/broker/find').then((value) async {
                                  if (value != null) {
                                    // convert value to company list model
                                    _brokerData = value as BrokerModel;
        
                                    // set the data
                                    _brokerCode = _brokerData.brokerFirmId;
                                    await _getBrokerTransaction().then((_) {  
                                      setState(() {
                                        // set state just to rebuild
                                      });
                                    },);
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
                                    (_brokerCode.isEmpty ? '-' : _brokerCode),
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
                                await Navigator.pushNamed(context, '/company/detail/find', arguments: _companyFindOtherArgs).then((value) {
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
                                await _showCalendar();
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
                                      title: const Text("Select Broker and Company"),
                                      content: const Text("Please select broker and company from the list, before run the query."),
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
                                    // rebuild widget
                                    _currentCompanySahamCodePrice = _companySahamCodePrice;
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
                    ],
                  ),
                ],
              ),
            ),
            Visibility(
              visible: (_companySahamCodePrice > 0),
              child: Container(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                child: Text.rich(
                  TextSpan(
                    children: <TextSpan>[
                      const TextSpan(
                        text: "Current Price of "
                      ),
                      TextSpan(
                        text: _companySahamCode,
                        style: const TextStyle(
                          color: accentColor,
                          fontWeight: FontWeight.bold,
                        )
                      ),
                      const TextSpan(
                        text: " is ",
                      ),
                      TextSpan(
                        text: formatDecimalWithNull(
                          _companySahamCodePrice,
                          decimal: 0
                        ),
                        style: const TextStyle(
                          color: accentColor,
                          fontWeight: FontWeight.bold,
                        )
                      ),
                    ]
                  ),
                ),
              ),
            ),
            _generateBrokerData(),
          ],
        ),
      ),
    );
  }

  Widget _generateBrokerData() {
    // check if the data is null or not?
    if (_brokerSummaryData == null) {
      return const SizedBox.shrink();
    }

    Map<DateTime, BrokerSummaryTxnCombineModel> combineAll = (_brokerSummaryData?.brokerSummaryAll == null ? {} : _combineBrokerTransaction(_brokerSummaryData!.brokerSummaryAll));
    Map<DateTime, BrokerSummaryTxnCombineModel> combineDomestic = (_brokerSummaryData?.brokerSummaryDomestic == null ? {} : _combineBrokerTransaction(_brokerSummaryData!.brokerSummaryDomestic));
    Map<DateTime, BrokerSummaryTxnCombineModel> combineForeign = (_brokerSummaryData?.brokerSummaryForeign == null ? {} : _combineBrokerTransaction(_brokerSummaryData!.brokerSummaryForeign));

    // check and ensure that at least we have data to render
    // for this we can check on the all since all will be combination of
    // both domestic and foreign
    if (_brokerSummaryData!.brokerSummaryAll.brokerSummaryBuy.isEmpty && _brokerSummaryData!.brokerSummaryAll.brokerSummarySell.isEmpty) {
      return const Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(height: 10,),
          Center(
            child: Text(
              "No data for this query",
            ),
          ),
        ],
      );
    }

    // generate the items that we will render
    // as if we using column, the performance will be slugish, instead of using ListView builder
    _pageItems.clear();

    // generate for all
    _pageItems.add(const Text(
      "All",
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.bold
      ),
    ));
    _pageItems.add(_generateRow(
      date: "Date",
      buyLot: "B.lot",
      buyValue: "B.val",
      buyAverage: "B.avg",
      sellLot: "S.lot",
      sellValue: "S.val",
      sellAverage: "S.avg",
      isBold: true,
      isBackground: true
    ));
    _pageItems.addAll(_generateCombineRows(combineAll));
    _pageItems.add(_generateAverage(combineAll, true));
    _pageItems.add(const SizedBox(height: 10,));

    // generate for domestic
    _pageItems.add(const Text(
      "Domestic",
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.bold
      ),
    ));
    _pageItems.add(_generateRow(
      date: "Date",
      buyLot: "B.lot",
      buyValue: "B.val",
      buyAverage: "B.avg",
      sellLot: "S.lot",
      sellValue: "S.val",
      sellAverage: "S.avg",
      isBold: true,
      isBackground: true,
    ));
    _pageItems.addAll(_generateCombineRows(combineDomestic));
    _pageItems.add(_generateAverage(combineDomestic));
    _pageItems.add(const SizedBox(height: 10,));

    // generate for foreign
    _pageItems.add(const Text(
      "Foreign",
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.bold
      ),
    ));
    _pageItems.add(_generateRow(
      date: "Date",
      buyLot: "B.lot",
      buyValue: "B.val",
      buyAverage: "B.avg",
      sellLot: "S.lot",
      sellValue: "S.val",
      sellAverage: "S.avg",
      isBold: true,
      isBackground: true,
    ));
    _pageItems.addAll(_generateCombineRows(combineForeign));
    _pageItems.add(_generateAverage(combineForeign));

    double companySahamCodePrice = _currentCompanySahamCodePrice;
    int shareLeft = (_totalBuyLot - _totalSellLot) * 100;
    Color shareLeftColor = (shareLeft == 0 ? textPrimary : (shareLeft < 0 ? secondaryColor : Colors.green));
    double shareValue = shareLeft * _totalBuyAverage;
    Color shareValueColor = (shareValue == 0 ? textPrimary : (shareValue < 0 ? secondaryColor : Colors.green));
    double shareAvg = shareValue / shareLeft;
    Color shareAvgColor = (shareAvg == companySahamCodePrice ? textPrimary : (shareAvg < companySahamCodePrice ? Colors.green : secondaryColor ));
    double sharePL = (companySahamCodePrice - shareAvg) * shareLeft;
    Color sharePLColor = (sharePL == companySahamCodePrice ? textPrimary : (sharePL < companySahamCodePrice ? Colors.green : secondaryColor));
    
    // in case sharePL is minus, make it plus
    if (sharePL < 0) {
      sharePL = sharePL * -1;
    }

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    const SizedBox(
                      width: 85,
                      child: Text(
                        "Share Left :",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 5,),
                    Text(
                      "${formatDecimal(shareLeft/100, decimal: 0)} lots",
                      style: TextStyle(
                        fontSize: 10,
                        color: shareLeftColor,
                      ),
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    const SizedBox(
                      width: 85,
                      child: Text(
                        "Share Value :",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 5,),
                    Text(
                      formatCurrency(
                        shareValue,
                        showDecimal: false,
                        shorten: false,
                        decimalNum: 0
                      ),
                      style: TextStyle(
                        fontSize: 10,
                        color: shareValueColor,
                      ),
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    const SizedBox(
                      width: 85,
                      child: Text(
                        "Share AVG :",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 5,),
                    Text(
                      "${
                        formatCurrency(
                          shareAvg,
                          showDecimal: false,
                          shorten: false,
                          decimalNum: 0
                        )
                      } (${
                        formatDecimal(
                          companySahamCodePrice - shareAvg,
                          decimal: 0,
                        )
                      })",
                      style: TextStyle(
                        fontSize: 10,
                        color: shareAvgColor,
                      ),
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    const SizedBox(
                      width: 85,
                      child: Text(
                        "Estimated PL :",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 5,),
                    Text(
                      formatCurrency(
                        sharePL,
                        showDecimal: false,
                        shorten: false,
                        decimalNum: 0
                      ),
                      style: TextStyle(
                        fontSize: 10,
                        color: sharePLColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10,),
            Expanded(
              child: ListView.builder(
                itemCount: _pageItems.length,
                itemBuilder: (context, index) {
                  return _pageItems[index];
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  SplayTreeMap<DateTime, BrokerSummaryTxnCombineModel> _combineBrokerTransaction(BrokerSummaryTxnDetailAllModel txnData) {
    SplayTreeMap<DateTime, BrokerSummaryTxnCombineModel> result = SplayTreeMap<DateTime, BrokerSummaryTxnCombineModel>();

    // loop thru txnData for buy and sell
    for (BrokerSummaryTxnBuySellElement buy in txnData.brokerSummaryBuy) {
      // assuming that we will not have any data on result yet
      result[buy.brokerSummaryDate] = BrokerSummaryTxnCombineModel(
        brokerSummaryBuyLot: buy.brokerSummaryLot,
        brokerSummaryBuyValue: (buy.brokerSummaryLot * buy.brokerSummaryAverage * 100),
        brokerSummaryBuyAverage: buy.brokerSummaryAverage,
        brokerSummarySellLot: 0,
        brokerSummarySellValue: 0,
        brokerSummarySellAverage: 0
      );
    }

    // loop thru txnData for buy and sell
    for (BrokerSummaryTxnBuySellElement sell in txnData.brokerSummarySell) {
      // check if data exists already or not?
      if (result.containsKey(sell.brokerSummaryDate)) {
        BrokerSummaryTxnCombineModel prevBuy = result[sell.brokerSummaryDate]!;

        // already there, so we extract this and change the data
        BrokerSummaryTxnCombineModel combine = BrokerSummaryTxnCombineModel(
          brokerSummaryBuyLot: prevBuy.brokerSummaryBuyLot,
          brokerSummaryBuyValue: prevBuy.brokerSummaryBuyValue,
          brokerSummaryBuyAverage: prevBuy.brokerSummaryBuyAverage,
          brokerSummarySellLot: sell.brokerSummaryLot,
          brokerSummarySellValue: (sell.brokerSummaryLot * sell.brokerSummaryAverage * 100),
          brokerSummarySellAverage: sell.brokerSummaryAverage
        );

        // change the _result data
        result[sell.brokerSummaryDate] = combine;
      }
      else {
        result[sell.brokerSummaryDate] = BrokerSummaryTxnCombineModel(
          brokerSummaryBuyLot: 0,
          brokerSummaryBuyValue: 0,
          brokerSummaryBuyAverage: 0,
          brokerSummarySellLot: sell.brokerSummaryLot,
          brokerSummarySellValue: (sell.brokerSummaryLot * sell.brokerSummaryAverage * 100),
          brokerSummarySellAverage: sell.brokerSummaryAverage
        );
      }
    }

    // finished, return the combine data
    return result;
  }

  Widget _generateRow({
    required String date,
    required String buyLot,
    required String buyValue,
    required String buyAverage,
    required String sellLot,
    required String sellValue,
    required String sellAverage,
    bool isBold = false,
    bool isBackground = false,
    Color? dateColor,
    Color buyColor = Colors.green,
    Color sellColor = secondaryColor,
  }) {
    Color dateColorUse = (dateColor ?? Colors.amber[700]!);

    TextStyle textStyleBuy = TextStyle(
      fontSize: 10,
      fontWeight: (isBold ? FontWeight.bold : FontWeight.normal),
      color: (isBackground ? Colors.white : buyColor),
    );

    TextStyle textStyleSell = TextStyle(
      fontSize: 10,
      fontWeight: (isBold ? FontWeight.bold : FontWeight.normal),
      color: (isBackground ? Colors.white : sellColor),
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Container(
          width: 40,
          color: (isBackground ? accentDark : Colors.transparent),
          child: Text(
            date,
            style: TextStyle(
              fontSize: 10,
              color: (isBackground ? Colors.white : dateColorUse)
            ),
          ),
        ),
        Expanded(
          child: Container(
            color: (isBackground ? buyColor : Colors.transparent),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Text(
                    buyLot,
                    style: textStyleBuy,
                  ),
                ),
                Expanded(
                  child: Text(
                    buyValue,
                    style: textStyleBuy,
                  ),
                ),
                Expanded(
                  child: Text(
                    buyAverage,
                    style: textStyleBuy,
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Container(
            color: (isBackground ? sellColor : Colors.transparent),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Text(
                    sellLot,
                    style: textStyleSell,
                  ),
                ),
                Expanded(
                  child: Text(
                    sellValue,
                    style: textStyleSell,
                  ),
                ),
                Expanded(
                  child: Text(
                    sellAverage,
                    style: textStyleSell,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _generateCombineRows(Map<DateTime, BrokerSummaryTxnCombineModel> data) {
    List<Widget> result = [];

    // iterate thru data
    data.forEach((key, value) {
      result.add(_generateRow(
        date: Globals.dfddMM.formatLocal(key),
        buyLot: formatIntWithNull(
          value.brokerSummaryBuyLot,
          showDecimal: false
        ),
        buyValue: formatCurrencyWithNull(
          value.brokerSummaryBuyValue,
          checkThousand: true,
        ),
        buyAverage: formatCurrencyWithNull(
          value.brokerSummaryBuyAverage,
          showDecimal: false
        ),
        sellLot: formatIntWithNull(
          value.brokerSummarySellLot,
          showDecimal: false
        ),
        sellValue: formatCurrencyWithNull(
          value.brokerSummarySellValue,
          checkThousand: true,
        ),
        sellAverage: formatCurrencyWithNull(
          value.brokerSummarySellAverage,
          showDecimal: false
        )
      ));
    });

    // ensure that we have at least 1 result, if not then generate a dummy result with all '-'
    if (result.isEmpty) {
      result.add(_generateRow(
        date: '-',
        buyLot: '-',
        buyValue: '-',
        buyAverage: '-',
        sellLot: '-',
        sellValue: '-',
        sellAverage: '-'
      ));
    }

    return result;
  }

  Widget _generateAverage(Map<DateTime, BrokerSummaryTxnCombineModel> data, [bool? isNeedSaved]) {
    // loop thru the data if available
    if(data.isEmpty) {
      return const SizedBox.shrink();
    }
    else {
      double totalBuyValue = 0;
      int totalBuyLot = 0;
      double totalBuyAverage = 0;
      double totalSellValue = 0;
      int totalSellLot = 0;
      double totalSellAverage = 0;

      data.forEach((key, value) {
        totalBuyValue += value.brokerSummaryBuyLot * value.brokerSummaryBuyAverage * 100;
        totalBuyLot += value.brokerSummaryBuyLot;
        totalSellValue += value.brokerSummarySellLot * value.brokerSummarySellAverage * 100;
        totalSellLot += value.brokerSummarySellLot;
      });

      if (totalBuyLot > 0) {
        totalBuyAverage = (totalBuyValue / (totalBuyLot * 100));
      }

      if (totalSellLot > 0) {
        totalSellAverage = (totalSellValue / (totalSellLot * 100));
      }

      // check whether we need to save this data or not?
      if (isNeedSaved != null) {
        if (isNeedSaved) {
          // save the total data to the variable so we can display it on the screen
          // without perform other calculation.
          _totalBuyLot = totalBuyLot;
          _totalBuyAverage = totalBuyAverage;
          _totalSellLot = totalSellLot;
        }
      }

      return _generateRow(
        date: "Total",
        buyLot: formatIntWithNull(
          totalBuyLot,
          showDecimal: false
        ),
        buyValue: formatCurrencyWithNull(
          totalBuyValue,
          checkThousand: true,
        ),
        buyAverage: formatCurrencyWithNull(
          totalBuyAverage,
          showDecimal: false
        ),
        sellLot: formatIntWithNull(
          totalSellLot,
          showDecimal: false
        ),
        sellValue: formatCurrencyWithNull(
          totalSellValue,
          checkThousand: true,
        ),
        sellAverage: formatCurrencyWithNull(
          totalSellAverage,
          showDecimal: false
        ),
        isBold: false,
        isBackground: true,
        dateColor: Colors.amber[900]!,
        buyColor: Colors.green[900]!,
        sellColor: secondaryDark,
      );
    }
  }

  Future<void> _showCalendar() async {
    DateTimeRange? result = await showDateRangePicker(
      context: context,
      firstDate: _brokerMinDate.toLocal(),
      lastDate: _brokerMaxDate.toLocal(),
      initialDateRange: DateTimeRange(start: _dateFrom.toLocal(), end: _dateTo.toLocal()),
      confirmText: 'Done',
      currentDate: _dateCurrent.toLocal(),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
    );

    // check if we got the result or not?
    if (result != null) {
      // check whether the result start and end is different date, if different then we need to get new broker summary data.
      if ((result.start.compareTo(_dateFrom) != 0) || (result.end.compareTo(_dateTo) != 0)) {                      
        // set the broker from and to date
        setState(() {
          _dateFrom = result.start;
          _dateTo = result.end;
        });
      }
    }
  }

  Future<void> _getBrokerTransaction() async {
    if (_brokerCode.isNotEmpty && _companySahamCode.isNotEmpty) {
      // show the loading screen
      LoadingScreen.instance().show(context: context);

      // get the transaction
      await _brokerSummaryAPI.getBrokerTransactionDetail(
        brokerCode: _brokerCode,
        stockCode: _companySahamCode,
        dateFrom: _dateFrom,
        dateTo: _dateTo
      ).then((resp) {
        _brokerSummaryData = resp;
      }).onError((error, stackTrace) {
        if (mounted) {
          // show the error
          ScaffoldMessenger.of(context).showSnackBar(createSnackBar(message: "Error when trying to get the broker summary data", icon: const Icon(Ionicons.warning, size: 12,)));
        }
      }).whenComplete(() {
        // remove loading screen when finished
        LoadingScreen.instance().hide();
      },);
    }
  }

  Future<void> _getCompanyDataAndSearch() async {
    // check if this is the same as previous saham code or not?
    if (_companySahamCode != _companyData!.companySymbol) {
      // show the loading screen
      LoadingScreen.instance().show(context: context);

      // get the company detail
      await _companyAPI.getCompanyByCode(
        companyCode: _companyData!.companySymbol,
        type: 'saham',
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

      // directly get the broker transaction for this stock so the result will
      // feel instantious instead ask user to press search again.
      // on error is already handle on the _getBrokerTransaction method.
      _companySahamCode = _companyDetail!.companySymbol!;
      _companySahamCodePrice = (_companyDetail!.companyNetAssetValue ?? -1);
      await _getBrokerTransaction().then((_) {  
        setState(() {        
          // set state just to rebuild
        });
      },);
    }
  }
}