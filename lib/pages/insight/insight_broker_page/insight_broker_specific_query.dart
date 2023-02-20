import 'dart:collection';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ionicons/ionicons.dart';
import 'package:my_wealth/api/broker_summary_api.dart';
import 'package:my_wealth/model/broker_model.dart';
import 'package:my_wealth/model/broker_summary_txn_detail_model.dart';
import 'package:my_wealth/model/company_saham_list_model.dart';
import 'package:my_wealth/themes/colors.dart';
import 'package:my_wealth/utils/dialog/create_snack_bar.dart';
import 'package:my_wealth/utils/function/format_currency.dart';
import 'package:my_wealth/utils/loader/show_loader_dialog.dart';
import 'package:my_wealth/utils/prefs/shared_broker.dart';
import 'package:my_wealth/utils/prefs/shared_company.dart';

class InsightBrokerSpecificQueryPage extends StatefulWidget {
  const InsightBrokerSpecificQueryPage({Key? key}) : super(key: key);

  @override
  State<InsightBrokerSpecificQueryPage> createState() => _InsightBrokerSpecificQueryPageState();
}

class _InsightBrokerSpecificQueryPageState extends State<InsightBrokerSpecificQueryPage> {
  final BrokerSummaryAPI _brokerSummaryAPI = BrokerSummaryAPI();
  final ScrollController _scrollController = ScrollController();
  final ScrollController _scrollControllerBrokerList = ScrollController();
  final ScrollController _scrollControllerCompanySahamList = ScrollController();
  final DateFormat _df = DateFormat('dd-MM-yyyy');
  final DateFormat _dfs = DateFormat('dd/MM');

  late List<BrokerModel> _brokerList;
  late List<CompanySahamListModel> _companySahamList;
  late String _brokerCode;
  late String _companySahamCode;
  late int _companySahamCodePrice;
  late DateTime _dateCurrent;
  late DateTime _dateFrom;
  late DateTime _dateTo;
  late DateTime _brokerMinDate;
  late DateTime _brokerMaxDate;
  late BrokerSummaryTxnDetailModel? _brokerSummaryData;

  @override
  void initState() {
    // initialize the value
    _brokerCode = "";
    _companySahamCode = "";
    _companySahamCodePrice = -1;
    _dateCurrent = DateTime.now().toLocal();
    _dateFrom = DateTime.now().subtract(const Duration(days: 30)).toLocal();
    _dateTo = DateTime.now().subtract(const Duration(days: 1)).toLocal();
    _brokerMinDate = (BrokerSharedPreferences.getBrokerMinDate() ?? _dateFrom);
    _brokerMaxDate = (BrokerSharedPreferences.getBrokerMaxDate() ?? _dateTo);

    // get the broker list from shared preferences
    _brokerList = BrokerSharedPreferences.getBrokerList();
    _companySahamList = CompanySharedPreferences.getCompanySahamList();
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
      body: Column(
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
                            onTap: (() {
                              // create the bottom sheet and show the list of the broker
                              showModalBottomSheet(
                                context: context,
                                isDismissible: true,
                                useSafeArea: true,
                                builder: ((BuildContext context) {
                                  return Container(
                                    padding: const EdgeInsets.fromLTRB(0, 10, 0, 30),
                                    height: 350,
                                    child: ListView.builder(
                                      controller: _scrollControllerBrokerList,
                                      itemCount: _brokerList.length,
                                      itemBuilder: ((context, index) {
                                        return InkWell(
                                          onTap: (() {
                                            setState(() {
                                              _brokerCode = _brokerList[index].brokerFirmId;
                                              Navigator.pop(context);
                                            });
                                          }),
                                          child: Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: const BoxDecoration(
                                              border: Border(
                                                bottom: BorderSide(
                                                  color: primaryLight,
                                                  width: 1.0,
                                                  style: BorderStyle.solid,
                                                )
                                              )
                                            ),
                                            child: Text.rich(
                                              TextSpan(
                                                children: <TextSpan>[
                                                  TextSpan(
                                                    text: "(${_brokerList[index].brokerFirmId}) ",
                                                    style: const TextStyle(
                                                      color: accentColor,
                                                      fontWeight: FontWeight.bold,
                                                    )
                                                  ),
                                                  TextSpan(
                                                    text: _brokerList[index].brokerFirmName,
                                                  )
                                                ]
                                              ),
                                              style: const TextStyle(
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ),
                                        );
                                      }),
                                    ),
                                  );
                                }),
                              );
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
                            onTap: (() {
                              // create the bottom sheet and show the list of the company saham
                              showModalBottomSheet(
                                context: context,
                                isDismissible: true,
                                useSafeArea: true,
                                builder: ((BuildContext context) {
                                  return Container(
                                    padding: const EdgeInsets.fromLTRB(0, 10, 0, 30),
                                    height: 350,
                                    child: ListView.builder(
                                      controller: _scrollControllerCompanySahamList,
                                      itemCount: _companySahamList.length,
                                      itemBuilder: ((context, index) {
                                        return InkWell(
                                          onTap: (() {
                                            setState(() {
                                              _companySahamCode = _companySahamList[index].code;
                                              _companySahamCodePrice = (_companySahamList[index].lastPrice ?? -1);
                                              Navigator.pop(context);
                                            });
                                          }),
                                          child: Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: const BoxDecoration(
                                              border: Border(
                                                bottom: BorderSide(
                                                  color: primaryLight,
                                                  width: 1.0,
                                                  style: BorderStyle.solid,
                                                )
                                              )
                                            ),
                                            child: Text.rich(
                                              TextSpan(
                                                children: <TextSpan>[
                                                  TextSpan(
                                                    text: "(${_companySahamList[index].code}) ",
                                                    style: const TextStyle(
                                                      color: accentColor,
                                                      fontWeight: FontWeight.bold,
                                                    )
                                                  ),
                                                  TextSpan(
                                                    text: _companySahamList[index].name,
                                                  )
                                                ]
                                              ),
                                              style: const TextStyle(
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ),
                                        );
                                      }),
                                    ),
                                  );
                                }),
                              );
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
                                        _df.format(_dateFrom),
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
                                        _df.format(_dateTo),
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
                  ],
                ),
                const SizedBox(height: 5,),
                InkWell(
                  onTap: (() async {
                    // check that broker and code already filled
                    if (_brokerCode.isEmpty || _companySahamCode.isEmpty) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return CupertinoAlertDialog(
                            title: const Text("Select Broker and Company"),
                            content: const Text("Please select broker and company from the list, before run the query."),
                            actions: <CupertinoActionSheetAction>[
                              CupertinoActionSheetAction(
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
                      await _getBrokerTransaction();
                      setState(() {
                        // rebuild widget
                      });
                    }
                  }),
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: secondaryColor,
                      border: Border.all(
                        color: primaryLight,
                        width: 1.0,
                        style: BorderStyle.solid,
                      )
                    ),
                    child: const Center(
                      child: Text(
                        "SEARCH",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
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
                      text: formatIntWithNull(_companySahamCodePrice, false, false, 0),
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
          Expanded(
            child: Container(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 30),
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    _generateExpanstionTileChildren(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _generateExpanstionTileChildren() {
    // check if the data is null or not?
    if (_brokerSummaryData == null) {
      return const SizedBox.shrink();
    }

    Map<DateTime, BrokerSummaryTxnCombineModel> combineAll = (_brokerSummaryData?.brokerSummaryAll == null ? {} : _combineBrokerTransaction(_brokerSummaryData!.brokerSummaryAll));
    Map<DateTime, BrokerSummaryTxnCombineModel> combineDomestic = (_brokerSummaryData?.brokerSummaryDomestic == null ? {} : _combineBrokerTransaction(_brokerSummaryData!.brokerSummaryDomestic));
    Map<DateTime, BrokerSummaryTxnCombineModel> combineForeign = (_brokerSummaryData?.brokerSummaryForeign == null ? {} : _combineBrokerTransaction(_brokerSummaryData!.brokerSummaryForeign));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(2),
          // decoration: BoxDecoration(
          //   border: Border.all(color: primaryDark, style: BorderStyle.solid, width: 1.0),
          //   color: primaryDark,
          // ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              const Text(
                "All",
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold
                ),
              ),
              _generateRow("Date", "B.lot", "B.val", "B.avg", "S.lot", "S.val", "S.avg", true, true),
              ..._generateCombineRows(combineAll),
              _generateAverage(combineAll),
              const SizedBox(height: 10,),
              const Text(
                "Domestic",
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold
                ),
              ),
              _generateRow("Date", "B.lot", "B.val", "B.avg", "S.lot", "S.val", "S.avg", true, true),
              ..._generateCombineRows(combineDomestic),
              _generateAverage(combineDomestic),
              const SizedBox(height: 10,),
              const Text(
                "Foreign",
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold
                ),
              ),
              _generateRow("Date", "B.lot", "B.val", "B.avg", "S.lot", "S.val", "S.avg", true, true),
              ..._generateCombineRows(combineForeign),
              _generateAverage(combineForeign),
            ],
          ),
        ),
      ],
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

  Widget _generateRow(String date, String buyLot, String buyValue, String buyAverage, String sellLot, String sellValue, String sellAverage, [bool? isBold, bool? isBackground, Color? dateColor, Color? buyColor, Color? sellColor]) {
    bool isBoldUse = (isBold ?? false);
    bool isBackgroundUse = (isBackground ?? false);
    Color dateColorUse = (dateColor ?? Colors.amber[700]!);
    Color buyColorUse = (buyColor ?? Colors.green);
    Color sellColorUse = (sellColor ?? secondaryColor);

    TextStyle textStyleBuy = TextStyle(
      fontSize: 10,
      fontWeight: (isBoldUse ? FontWeight.bold : FontWeight.normal),
      color: (isBackgroundUse ? Colors.white : buyColorUse),
    );

    TextStyle textStyleSell = TextStyle(
      fontSize: 10,
      fontWeight: (isBoldUse ? FontWeight.bold : FontWeight.normal),
      color: (isBackgroundUse ? Colors.white : sellColorUse),
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Container(
          width: 40,
          color: (isBackgroundUse ? accentDark : Colors.transparent),
          child: Text(
            date,
            style: TextStyle(
              fontSize: 10,
              color: (isBackgroundUse ? Colors.white : dateColorUse)
            ),
          ),
        ),
        Expanded(
          child: Container(
            color: (isBackgroundUse ? buyColorUse : Colors.transparent),
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
            color: (isBackgroundUse ? sellColorUse : Colors.transparent),
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
        _dfs.format(key.toLocal()),
        formatIntWithNull(value.brokerSummaryBuyLot, false, false),
        formatCurrencyWithNull(value.brokerSummaryBuyValue, true, true),
        formatCurrencyWithNull(value.brokerSummaryBuyAverage, false, false),
        formatIntWithNull(value.brokerSummarySellLot, false, false),
        formatCurrencyWithNull(value.brokerSummarySellValue, true, true),
        formatCurrencyWithNull(value.brokerSummarySellAverage, false, false)
      ));
    });

    // ensure that we have at least 1 result, if not then generate a dummy result with all '-'
    if (result.isEmpty) {
      result.add(_generateRow('-', '-', '-', '-', '-', '-', '-'));
    }

    return result;
  }

  Widget _generateAverage(Map<DateTime, BrokerSummaryTxnCombineModel> data) {
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

      return _generateRow(
        "Total",
        formatIntWithNull(totalBuyLot, false, false),
        formatCurrencyWithNull(totalBuyValue, true, true),
        formatCurrencyWithNull(totalBuyAverage, false, false),
        formatIntWithNull(totalSellLot, false, false),
        formatCurrencyWithNull(totalSellValue, true, true),
        formatCurrencyWithNull(totalSellAverage, false, false),
        false,
        true,
        Colors.amber[900]!,
        Colors.green[900],
        secondaryDark,
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
    // show the loader dialog
    showLoaderDialog(context);

    // get the transaction
    await _brokerSummaryAPI.getBrokerTransactionDetail(_brokerCode, _companySahamCode, _dateFrom, _dateTo).then((resp) {
      _brokerSummaryData = resp;

      // remove the loader
      Navigator.pop(context);
    }).onError((error, stackTrace) {
      // remove the loader
      Navigator.pop(context);
      // show the error
      ScaffoldMessenger.of(context).showSnackBar(createSnackBar(message: "Error when trying to get the broker summary data", icon: const Icon(Ionicons.warning, size: 12,)));
    });
  }
}