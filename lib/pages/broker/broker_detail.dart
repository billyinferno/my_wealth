import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ionicons/ionicons.dart';
import 'package:my_wealth/api/broker_summary_api.dart';
import 'package:my_wealth/model/broker_summary_broker_txn_list_model.dart';
import 'package:my_wealth/model/broker_summary_txn_detail_model.dart';
import 'package:my_wealth/themes/colors.dart';
import 'package:my_wealth/utils/arguments/broker_detail_args.dart';
import 'package:my_wealth/utils/function/format_currency.dart';
import 'package:my_wealth/utils/loader/show_loader_dialog.dart';

class BrokerDetailPage extends StatefulWidget {
  final Object? args;
  const BrokerDetailPage({Key? key, required this.args}) : super(key: key);

  @override
  State<BrokerDetailPage> createState() => _BrokerDetailPageState();
}

class _BrokerDetailPageState extends State<BrokerDetailPage> {
  final BrokerSummaryAPI _brokerSummaryAPI = BrokerSummaryAPI();
  final DateFormat _df = DateFormat('yyyy-MM-dd');
  final DateFormat _dfs = DateFormat('dd/MM');

  late BrokerDetailArgs _args;
  late BrokerSummaryBrokerTxnListModel _transactionList;
  late List<bool> _isExpanded;
  late Map<int, BrokerSummaryTxnDetailModel> _transactionDetail;
  bool _isLoading = true;
  DateTime _fromDateMax = DateTime.now();
  DateTime _toDateMax = DateTime.now();
  DateTime _fromDateCurrent = DateTime.now();
  DateTime _toDateCurrent = DateTime.now();

  @override
  void initState() {
    super.initState();
    _args = widget.args as BrokerDetailArgs;

    // init the transaction detail as empty map
    _transactionDetail = {};

    Future.microtask(() async {
      // first let's get the min and max date
      await _brokerSummaryAPI.getBrokerSummaryBrokerDate(_args.brokerFirmID).then((resp) {
        _fromDateMax = resp.brokerMinDate;
        _toDateMax = resp.brokerMaxDate;
        _fromDateCurrent = _toDateMax;
        _toDateCurrent = _toDateMax;
      });

      // we will use the max date when we query the data
      await _brokerSummaryAPI.getBrokerTransactionList(_args.brokerFirmID, _fromDateCurrent, _toDateCurrent).then((resp) {
        _transactionList = resp;

        // assume that all is not expanded
        _isExpanded = List<bool>.generate(_transactionList.brokerSummaryCodeList.length, (index) {
          return false;
        });
      });
    }).whenComplete(() {
      // once finished then set the loading into false
      setLoading(false);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(color: primaryColor,);
    }
    // if not loading return the main page
    return _generatePage();
  }

  Widget _generatePage() {
    return WillPopScope(
      onWillPop: (() async {
        return false;
      }),
      child: Scaffold(
        appBar: AppBar(
          title: const Center(
            child: Text(
              "Broker Detail",
              style: TextStyle(
                color: secondaryColor,
              ),
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: (() async {
              try {
                Navigator.pop(context);
              }
              catch(error) {
                debugPrint(error.toString());
              }
            }),
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
                  RichText(
                    text: TextSpan(
                      text: '(${_transactionList.brokerSummaryId}) ',
                      style: const TextStyle(
                        color: accentColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      children: [
                        TextSpan(
                          text: _transactionList.brokerSummaryFirmName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    )
                  ),
                  const SizedBox(height: 10,),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            const Text(
                              "Volume",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(formatIntWithNull(_transactionList.brokerSummaryVolume)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10,),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            const Text(
                              "Value",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(formatIntWithNull(_transactionList.brokerSummaryValue)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10,),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            const Text(
                              "Frequency",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(formatIntWithNull(_transactionList.brokerSummaryFrequency, false, false)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10,),
            InkWell(
              onTap: (() async {
                DateTimeRange? result = await showDateRangePicker(
                  context: context,
                  firstDate: _fromDateMax,
                  lastDate: _toDateMax
                );

                if (result != null) {
                  // means we got the result, ensure it's not the same with from date and to date
                  if ((result.start.compareTo(_fromDateCurrent) != 0) || (result.end.compareTo(_toDateCurrent) != 0)) {                      
                    // set the broker from and to date
                    _fromDateCurrent = result.start;
                    _toDateCurrent = result.end;

                    // get the broker summary
                    setLoading(true);
                    await _brokerSummaryAPI.getBrokerTransactionList(_args.brokerFirmID, _fromDateCurrent, _toDateCurrent).then((resp) {
                      _transactionList = resp;

                      // clear all the detail
                      _transactionDetail.clear();

                      // assume that all is not expanded
                      _isExpanded = List<bool>.generate(_transactionList.brokerSummaryCodeList.length, (index) {
                        return false;
                      });
                    }).whenComplete(() {
                      setLoading(false);
                    });
                  }
                }
              }),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    '${_df.format(_transactionList.brokerSummaryFromDate.toLocal())} - ${_df.format(_transactionList.brokerSummaryToDate.toLocal())}',
                    style: const TextStyle(
                      color: secondaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 5,),
                  const Icon(
                    Ionicons.calendar_outline,
                    color: secondaryColor,
                  )
                ],
              ),
            ),
            const SizedBox(height: 10,),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: List<Widget>.generate(_transactionList.brokerSummaryCodeList.length, (index) {
                    int? diffPrice = (_transactionList.brokerSummaryCodeList[index].brokerSummaryLot > 0 ? ((_transactionList.brokerSummaryCodeList[index].brokerSummaryValue ~/ _transactionList.brokerSummaryCodeList[index].brokerSummaryLot) - _transactionList.brokerSummaryCodeList[index].brokerSummaryLastPrice) : null);
                    Color diffColor = textPrimary;
                    if (diffPrice != null) {
                      if (diffPrice < 0) {
                        diffColor = secondaryColor;
                      }
                      if (diffPrice > 0) {
                        diffColor = Colors.green;
                      }
                    }
                    return Container(
                      padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                      decoration: const BoxDecoration(
                        border: Border(bottom: BorderSide(color: primaryLight, style: BorderStyle.solid, width: 1.0))
                      ),
                      child: Theme(
                        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                        child: ListTileTheme(
                          contentPadding: const EdgeInsets.all(0), // remove the expansion tile default padding
                          child: ExpansionTile(
                            trailing: (
                              _isExpanded[index] ? const Icon(Ionicons.chevron_up, color: accentColor,) : const Icon(Ionicons.chevron_down, color: Colors.white)
                            ),
                            title: RichText(
                              text: TextSpan(
                                text: '(${_transactionList.brokerSummaryCodeList[index].brokerSummaryCode}) ',
                                style: const TextStyle(
                                  color: accentColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                                children: [
                                  TextSpan(
                                    text: _transactionList.brokerSummaryCodeList[index].brokerSummaryName,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ]
                              ),
                            ),
                            subtitle: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      const Text(
                                        "Lot",
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        formatIntWithNull(_transactionList.brokerSummaryCodeList[index].brokerSummaryLot, false, false),
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10,),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      const Text(
                                        "Value",
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        formatIntWithNull(_transactionList.brokerSummaryCodeList[index].brokerSummaryValue, false, true),
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10,),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      const Text(
                                        "Price",
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            formatIntWithNull(_transactionList.brokerSummaryCodeList[index].brokerSummaryLastPrice, false, false),
                                            style: const TextStyle(
                                              fontSize: 10,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(width: 5,),
                                          Text(
                                            '(${formatIntWithNull(diffPrice, false, false)})',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: diffColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10,),
                                SizedBox(
                                  width: 50,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      const Text(
                                        "Count",
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        _transactionList.brokerSummaryCodeList[index].brokerSummaryCount,
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            onExpansionChanged: ((value) async {
                              // check if expanded
                              if (value) {
                                // try to get the data if not available
                                showLoaderDialog(context);
                                await _getTransactionDetail(index).whenComplete(() {
                                  // remove loader dialog
                                  Navigator.pop(context);
                                });
                              }

                              // set the state, so we will rebuild the whatever happen
                              setState(() {
                                // set that this is expanded
                                _isExpanded[index] = value;
                              });
                            }),
                            children: _generateExpanstionTileChildren(index),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
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

  Map<DateTime, BrokerSummaryTxnCombineModel> _combineBrokerTransaction(BrokerSummaryTxnDetailAllModel txnData) {
    Map<DateTime, BrokerSummaryTxnCombineModel> result = {};

    // loop thru txnData for buy and sell
    for (BrokerSummaryTxnBuySellElement buy in txnData.brokerSummaryBuy) {
      // assuming that we will not have any data on result yet
      result[buy.brokerSummaryDate] = BrokerSummaryTxnCombineModel(
        brokerSummaryBuyLot: buy.brokerSummaryLot,
        brokerSummaryBuyValue: buy.brokerSummaryValue,
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
        // already there, so we extract this and change the data
        BrokerSummaryTxnCombineModel combine = BrokerSummaryTxnCombineModel(
          brokerSummaryBuyLot: result[sell.brokerSummaryDate]!.brokerSummaryBuyLot,
          brokerSummaryBuyValue: result[sell.brokerSummaryDate]!.brokerSummaryBuyValue,
          brokerSummaryBuyAverage: result[sell.brokerSummaryDate]!.brokerSummaryBuyAverage,
          brokerSummarySellLot: sell.brokerSummaryLot,
          brokerSummarySellValue: sell.brokerSummaryValue,
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
          brokerSummarySellValue: sell.brokerSummaryValue,
          brokerSummarySellAverage: sell.brokerSummaryAverage
        );
      }
    }

    // finished, return the combine data
    return result;
  }

  List<Widget> _generateCombineRows(Map<DateTime, BrokerSummaryTxnCombineModel> data) {
    List<Widget> result = [];

    // iterate thru data
    data.forEach((key, value) {
      result.add(_generateRow(
        _dfs.format(key.toLocal()),
        formatIntWithNull(value.brokerSummaryBuyLot, false, false),
        formatIntWithNull(value.brokerSummaryBuyValue, true, true),
        formatIntWithNull(value.brokerSummaryBuyAverage, false, false),
        formatIntWithNull(value.brokerSummarySellLot, false, false),
        formatIntWithNull(value.brokerSummarySellValue, true, true),
        formatIntWithNull(value.brokerSummarySellAverage, false, false)
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
      int totalBuyValue = 0;
      int totalBuyLot = 0;
      int totalBuyAverage = 0;
      int totalSellValue = 0;
      int totalSellLot = 0;
      int totalSellAverage = 0;

      data.forEach((key, value) {
        totalBuyValue += value.brokerSummaryBuyLot * value.brokerSummaryBuyAverage;
        totalBuyLot += value.brokerSummaryBuyLot;
        totalSellValue += value.brokerSummarySellLot * value.brokerSummarySellAverage;
        totalSellLot += value.brokerSummarySellLot;
      });

      if (totalBuyLot > 0) {
        totalBuyAverage = (totalBuyValue / totalBuyLot).round();
      }

      if (totalSellLot > 0) {
        totalSellAverage = (totalSellValue / totalSellLot).round();
      }

      return _generateRow(
        "Total",
        formatIntWithNull(totalBuyLot, false, false),
        formatIntWithNull(totalBuyValue, true, true),
        formatIntWithNull(totalBuyAverage, false, false),
        formatIntWithNull(totalSellLot, false, false),
        formatIntWithNull(totalSellValue, true, true),
        formatIntWithNull(totalSellAverage, false, false),
        false,
        true,
        Colors.amber[900]!,
        Colors.green[900],
        secondaryDark,
      );
    }
  }

  List<Widget> _generateExpanstionTileChildren(int index) {
    Map<DateTime, BrokerSummaryTxnCombineModel> combineAll = (_transactionDetail[index]?.brokerSummaryAll == null ? {} : _combineBrokerTransaction(_transactionDetail[index]!.brokerSummaryAll));
    Map<DateTime, BrokerSummaryTxnCombineModel> combineDomestic = (_transactionDetail[index]?.brokerSummaryDomestic == null ? {} : _combineBrokerTransaction(_transactionDetail[index]!.brokerSummaryDomestic));
    Map<DateTime, BrokerSummaryTxnCombineModel> combineForeign = (_transactionDetail[index]?.brokerSummaryForeign == null ? {} : _combineBrokerTransaction(_transactionDetail[index]!.brokerSummaryForeign));

    if (_transactionDetail.containsKey(index)) {
      return [
        Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            border: Border.all(color: primaryDark, style: BorderStyle.solid, width: 1.0),
            color: primaryDark,
          ),
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
      ];
    }
    else {
      // nothing to return
      return [];
    }
  }

  Future<void> _getTransactionDetail(int index) async {
    // check if this is on the transaction detail map already or not?
    if (!_transactionDetail.containsKey(index)) {
      await _brokerSummaryAPI.getBrokerTransactionDetail(
        _transactionList.brokerSummaryId,
        _transactionList.brokerSummaryCodeList[index].brokerSummaryCode,
        _transactionList.brokerSummaryFromDate.toLocal(),
        _transactionList.brokerSummaryToDate.toLocal()).then((resp) {
          // got the response from the API, we will put this on the map of transaction detail
          _transactionDetail[index] = resp;
      });
    }
  }

  void setLoading(bool value) {
    setState(() {
      _isLoading = value;
    });
  }
}