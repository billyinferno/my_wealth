import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:ionicons/ionicons.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:my_wealth/_index.g.dart';

class BrokerDetailPage extends StatefulWidget {
  final Object? args;
  const BrokerDetailPage({super.key, required this.args});

  @override
  State<BrokerDetailPage> createState() => _BrokerDetailPageState();
}

class _BrokerDetailPageState extends State<BrokerDetailPage> {
  final BrokerSummaryAPI _brokerSummaryAPI = BrokerSummaryAPI();
  final ScrollController _scrollController = ScrollController();
  
  final List<FlipFlopItem<CalendarType>> _brokerFlipFlopItem = [];
  late CalendarType _brokerCalendarType;

  late BrokerDetailArgs _args;
  late BrokerSummaryBrokerTxnListModel _transactionList;
  late List<bool> _isExpanded;
  late Map<int, BrokerSummaryTxnDetailModel> _transactionDetail;
  late Future<bool> _getData;

  DateTime _fromDateMax = DateTime.now();
  DateTime _toDateMax = DateTime.now();
  DateTime _fromDateCurrent = DateTime.now();
  DateTime _toDateCurrent = DateTime.now();
  int _start = 0;
  int _limit = 20;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _args = widget.args as BrokerDetailArgs;

    // init the transaction detail as empty map
    _transactionDetail = {};

    // init the start and limit
    _start = 0;
    _limit = 20;

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

    _getData = _getInitData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getData,
      builder: ((context, snapshot) {
        if (snapshot.hasError) {
          return const CommonErrorPage(errorText: 'Unable to load broker detail data');
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
    return Scaffold(
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
              Log.error(
                message: "Error when pop to previous screen",
                error: error,
              );
            }
          }),
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
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        '(${_transactionList.brokerSummaryId}) ',
                        style: const TextStyle(
                          color: accentColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        )
                      ),
                      const SizedBox(width: 5,),
                      Expanded(
                        child: Text(
                          _transactionList.brokerSummaryFirmName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
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
                            Text(
                              formatIntWithNull(_transactionList.brokerSummaryVolume)
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
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              formatCurrencyWithNull(_transactionList.brokerSummaryValue)
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
                              "Frequency",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              formatIntWithNull(
                                _transactionList.brokerSummaryFrequency,
                                showDecimal: false
                              )
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
              color: primaryDark,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: InkWell(
                      onTap: (() async {
                        // check whether we want to select date or year in range
                        if (_brokerCalendarType == CalendarType.day) {
                          // show the day range picker
                          DateTimeRange? initialDateRange = DateTimeRange(
                            start: _fromDateCurrent.toLocal(),
                            end: _toDateCurrent.toLocal()
                          );
                          
                          DateTimeRange? result = await showDateRangePicker(
                            context: context,
                            firstDate: _fromDateMax.toLocal(),
                            lastDate: _toDateMax.toLocal(),
                            initialDateRange: initialDateRange,
                            currentDate: DateTime.now().toLocal(),
                            initialEntryMode: DatePickerEntryMode.calendarOnly,
                          );
                      
                          if (result != null) {
                            // means we got the result, ensure it's not the same with from date and to date
                            if (
                              (result.start.toLocal().compareTo(_fromDateCurrent.toLocal()) != 0) ||
                              (result.end.toLocal().compareTo(_toDateCurrent.toLocal()) != 0)) {
                              // set the broker from and to date
                              _fromDateCurrent = result.start.toLocal();
                              _toDateCurrent = result.end.toLocal();
                      
                              // set the start back into 0
                              _start = 0;
                      
                              // get the broker summary
                              await _refreshTransactionList().onError((error, stackTrace) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(createSnackBar(message: error.toString()));
                                }
                              });
                            }
                          }
                        }
                        else {
                          // show multi range year picker instead
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
                                    firstDate: _fromDateMax.toLocal(),
                                    lastDate: _toDateMax.toLocal(),
                                    startDate: _fromDateCurrent.toLocal(),
                                    endDate: _toDateCurrent.toLocal(),
                                    type: MyYearPickerCalendarType.range,
                                    onChanged: (value) async {
                                      // remove the dialog
                                      Navigator.pop(context);
                      
                                      // check the new date whether it's same year or not?
                                      if (
                                        value.startDate.toLocal().compareTo(_fromDateCurrent.toLocal()) != 0 ||
                                        value.endDate.toLocal().compareTo(_toDateCurrent.toLocal()) != 0
                                      ) {
                                        // not same year, set the current year to the monthly performance year
                                        _fromDateCurrent = value.startDate;
                                        _toDateCurrent = value.endDate;
                                      
                                        // set the start back into 0
                                        _start = 0;
                                      
                                        // get the broker summary
                                        await _refreshTransactionList().onError((error, stackTrace) {
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(createSnackBar(message: error.toString()));
                                          }
                                        });
                                      }
                                    },
                                  ),
                                ),
                              );
                            },
                          );
                        }
                      }),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const Text(
                            "From",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: secondaryLight,
                            ),
                          ),
                          const SizedBox(width: 5,),
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: primaryLight,
                                width: 1.0,
                                style: BorderStyle.solid,
                              ),
                              borderRadius: BorderRadius.circular(5),
                              color: primaryDark,
                            ),
                            child: Text(Globals.dfyyyyMMdd.formatLocal(_transactionList.brokerSummaryFromDate))
                          ),
                          const SizedBox(width: 10,),
                          const Text(
                            "To",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: secondaryLight,
                            ),
                          ),
                          const SizedBox(width: 5,),
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: primaryLight,
                                width: 1.0,
                                style: BorderStyle.solid,
                              ),
                              borderRadius: BorderRadius.circular(5),
                              color: primaryDark,
                            ),
                            child: Text(Globals.dfyyyyMMdd.formatLocal(_transactionList.brokerSummaryToDate))
                          ),
                          const SizedBox(width: 10,),
                          const Icon(
                            Ionicons.search,
                            color: secondaryLight,
                            size: 15,
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10,),
                  FlipFlopSwitch<CalendarType>(
                    icons: _brokerFlipFlopItem,
                    initialKey: _brokerCalendarType,
                    onChanged: <CalendarType>(key) {
                      _brokerCalendarType = key;
                    },
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(0, 0, 10, 10),
              decoration: const BoxDecoration(
                color: primaryDark,
                border: Border(
                  bottom: BorderSide(
                    color: primaryLight,
                    width: 1.0,
                    style: BorderStyle.solid,
                  )
                )
              ),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "Item loaded (${_transactionList.brokerSummaryCodeList.length})",
                  style: const TextStyle(
                    fontSize: 10,
                    color: accentColor,
                  ),
                ),
              ),
            ),
            Expanded(
              child: LazyLoadScrollView(
                onEndOfPage: (() async {
                  if (_hasMore) {
                    LoadingScreen.instance().show(context: context);
                    await _getTransactionList().onError((error, stackTrace) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(createSnackBar(message: 'Error when load more data'));
                      }
                    });
                    LoadingScreen.instance().hide();
                  }
                }),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const AlwaysScrollableScrollPhysics(),
                  controller: _scrollController,
                  itemCount: _transactionList.brokerSummaryCodeList.length,
                  itemBuilder: (context, index) {
                    // generate the diff color
                    int? diffPrice;
                    int? currLeftPrice;
                          
                    if (_transactionList.brokerSummaryCodeList[index].brokerSummaryLot > 0) {
                      currLeftPrice = (_transactionList.brokerSummaryCodeList[index].brokerSummaryValue ~/ (_transactionList.brokerSummaryCodeList[index].brokerSummaryLot * 100));
                      diffPrice = currLeftPrice - _transactionList.brokerSummaryCodeList[index].brokerSummaryLastPrice;
                    }
                    Color diffColor = textPrimary;
                    if (diffPrice != null) {
                      if (diffPrice < 0) {
                        diffColor = secondaryColor;
                      }
                      if (diffPrice > 0) {
                        diffColor = Colors.green;
                      }
                    }
              
                    // generate the company detail arguments to call the company detail page
                    CompanyDetailArgs args = CompanyDetailArgs(
                      companyId: _transactionList.brokerSummaryCodeList[index].brokerSummaryCompanyId,
                      companyName: _transactionList.brokerSummaryCodeList[index].brokerSummaryName,
                      companyCode: _transactionList.brokerSummaryCodeList[index].brokerSummaryCode,
                      companyFavourite: (_transactionList.brokerSummaryCodeList[index].brokerSummaryFavouriteId > 0 ? true : false),
                      favouritesId: _transactionList.brokerSummaryCodeList[index].brokerSummaryFavouriteId,
                      type: 'saham'
                    );
              
                    return Slidable(
                      endActionPane: ActionPane(
                        motion: const ScrollMotion(),
                        extentRatio: 0.2,
                        children: <Widget>[
                          SlideButton(
                            icon: Ionicons.open_outline,
                            iconColor: Colors.green,
                            border: const Border(
                              bottom: BorderSide(
                                color: primaryLight,
                                width: 1.0,
                                style: BorderStyle.solid,
                              )
                            ),
                            onTap: () {
                              Navigator.pushNamed(context, '/company/detail/saham', arguments: args);
                            },
                          ),
                        ],
                      ),
                      child: Container(
                        // padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                        decoration: const BoxDecoration(
                          border: Border(bottom: BorderSide(color: primaryLight, style: BorderStyle.solid, width: 1.0))
                        ),
                        child: Theme(
                          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                          child: ListTileTheme(
                            contentPadding: EdgeInsets.zero,
                            child: ExpansionTile(
                              key: Key(_transactionList.brokerSummaryCodeList[index].brokerSummaryCode),
                              tilePadding: EdgeInsets.zero,
                              childrenPadding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                              trailing: (
                                _isExpanded[index] ? const Icon(Ionicons.chevron_up, color: accentColor,) : const Icon(Ionicons.chevron_down, color: Colors.white)
                              ),
                              title: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  const SizedBox(width: 10,),
                                  Visibility(
                                    visible: _transactionList.brokerSummaryCodeList[index].brokerSummaryFCA,
                                    child: const Icon(
                                      Ionicons.warning,
                                      color: secondaryColor,
                                      size: 15,
                                    )
                                  ),
                                  Visibility(
                                    visible: _transactionList.brokerSummaryCodeList[index].brokerSummaryFCA,
                                    child: const SizedBox(width: 5,)
                                  ),
                                  Text(
                                    '(${_transactionList.brokerSummaryCodeList[index].brokerSummaryCode}) ',
                                    style: const TextStyle(
                                      color: accentColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      _transactionList.brokerSummaryCodeList[index].brokerSummaryName,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  const SizedBox(width: 10,),
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
                                          (
                                            _transactionList.brokerSummaryCodeList[index].brokerSummaryLot > 1000000 ?
                                            formatIntWithNull(
                                              _transactionList.brokerSummaryCodeList[index].brokerSummaryLot,
                                            ) :
                                            formatIntWithNull(
                                              _transactionList.brokerSummaryCodeList[index].brokerSummaryLot,
                                              showDecimal: false
                                            )
                                          ),
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
                                          formatCurrencyWithNull(
                                            _transactionList.brokerSummaryCodeList[index].brokerSummaryValue,
                                          ),
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
                                        Text(
                                          formatIntWithNull(
                                            _transactionList.brokerSummaryCodeList[index].brokerSummaryLastPrice,
                                            showDecimal: false
                                          ),
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(width: 5,),
                                        Text(
                                          '(${formatIntWithNull(
                                            currLeftPrice,
                                            showDecimal: false,
                                          )})',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: diffColor,
                                          ),
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
                                  await _getTransactionDetail(index);
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
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
    Color sellColor = secondaryColor }) {
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

  List<Widget> _generateCombineRows(Map<DateTime, BrokerSummaryTxnCombineModel> data) {
    List<Widget> result = [];

    // iterate thru data
    data.forEach((key, value) {
      result.add(_generateRow(
        date: Globals.dfddMM.formatLocal(key),
        buyLot: formatIntWithNull(
          value.brokerSummaryBuyLot,
          showDecimal: false,
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
          showDecimal: false,
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
        date: "Total",
        buyLot: formatIntWithNull(
          totalBuyLot,
          showDecimal: false,
        ),
        buyValue: formatCurrencyWithNull(
          totalBuyValue,
          checkThousand: true,
        ),
        buyAverage: formatCurrencyWithNull(
          totalBuyAverage,
          showDecimal: false,
        ),
        sellLot: formatIntWithNull(
          totalSellLot,
          showDecimal: false,
        ),
        sellValue: formatCurrencyWithNull(
          totalSellValue,
          checkThousand: true,
        ),
        sellAverage: formatCurrencyWithNull(
          totalSellAverage,
          showDecimal: false,
        ),
        isBold: false,
        isBackground: true,
        dateColor:  Colors.amber[900]!,
        buyColor: Colors.green[900]!,
        sellColor: secondaryDark,
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
              _generateRow(
                date: "Date",
                buyLot: "B.lot",
                buyValue: "B.val",
                buyAverage: "B.avg",
                sellLot: "S.lot",
                sellValue: "S.val",
                sellAverage: "S.avg",
                isBold: true,
                isBackground: true,
              ),
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
              _generateRow(
                date: "Date",
                buyLot: "B.lot",
                buyValue: "B.val",
                buyAverage: "B.avg",
                sellLot: "S.lot",
                sellValue: "S.val",
                sellAverage: "S.avg",
                isBold: true,
                isBackground: true,
              ),
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
              _generateRow(
                date: "Date",
                buyLot: "B.lot",
                buyValue: "B.val",
                buyAverage: "B.avg",
                sellLot: "S.lot",
                sellValue: "S.val",
                sellAverage: "S.avg",
                isBold: true,
                isBackground: true
              ),
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

  Future<void> _refreshTransactionList() async {
    LoadingScreen.instance().show(context: context);
    await _getTransactionList().onError((error, stackTrace) {
      Log.error(
        message: 'Error when get transaction list',
        error: error,
        stackTrace: stackTrace,
      );
      throw Exception();
    });
    LoadingScreen.instance().hide();                       
  }

  void _updateTransactionList(BrokerSummaryBrokerTxnListModel updateTxn) {
    // check if start is 0, if 0, it means that this is the first transaction
    if (_start == 0) {
      // assume that all is not expanded
      _isExpanded = List<bool>.generate(updateTxn.brokerSummaryCodeList.length, (index) {
        return false;
      });

      // and clear all transaction detail
      _transactionDetail.clear();

      setState(() {
        // set the transaction list
        _transactionList = updateTxn;

        // set the limit
        _start = _limit;

        // enable the has more again
        _hasMore = true;
      });
    }
    else {
      // get the previous code list
      List<BrokerSummaryCodeListModel> currentCodeList = _transactionList.brokerSummaryCodeList;
      // add the updated code list to the current code list
      currentCodeList.addAll(updateTxn.brokerSummaryCodeList);

      // assuming that all will be closed when we get a new data
      _isExpanded = List<bool>.generate(currentCodeList.length, (index) {
        return false;
      });

      // now we need to generate a new BrokerSummaryTransaction model with additional code list added
      BrokerSummaryBrokerTxnListModel tmpTransactionList = BrokerSummaryBrokerTxnListModel(
        brokerSummaryId: updateTxn.brokerSummaryId,
        brokerSummaryFromDate: updateTxn.brokerSummaryFromDate,
        brokerSummaryToDate: updateTxn.brokerSummaryToDate,
        brokerSummaryFirmName: updateTxn.brokerSummaryFirmName,
        brokerSummaryVolume: updateTxn.brokerSummaryVolume,
        brokerSummaryValue: updateTxn.brokerSummaryValue,
        brokerSummaryFrequency: updateTxn.brokerSummaryFrequency,
        brokerSummaryCodeList: currentCodeList
      );

      // check if we still have data or not?
      if (updateTxn.brokerSummaryCodeList.length < _limit) {
        _hasMore = false;
      }

      setState(() {
        // set the transaction list with the update transaction list
        _transactionList = tmpTransactionList;
        
        // add limit to the start
        _start = _start + _limit;
      });
    }
  }

  Future<void> _getTransactionList() async {
    await _brokerSummaryAPI.getBrokerTransactionList(
      brokerCode: _args.brokerFirmID,
      start: _start,
      limit: _limit,
      dateFrom: _fromDateCurrent.toLocal(),
      dateTo: _toDateCurrent.toLocal(),
    ).then((resp) {
      _updateTransactionList(resp);
    }).onError((error, stackTrace) {
      Log.error(
        message: "Error when loading more data",
        error: error,
        stackTrace: stackTrace,
      );
      throw Exception('Error when loading more data');
    });
  }

  Future<void> _getTransactionDetail(int index) async {
    // check if this is on the transaction detail map already or not?
    if (!_transactionDetail.containsKey(index)) {
      LoadingScreen.instance().show(context: context);
      await _brokerSummaryAPI.getBrokerTransactionDetail(
        brokerCode: _transactionList.brokerSummaryId,
        stockCode: _transactionList.brokerSummaryCodeList[index].brokerSummaryCode,
        dateFrom: _transactionList.brokerSummaryFromDate.toLocal(),
        dateTo: _transactionList.brokerSummaryToDate.toLocal()
      ).then((resp) {
        // got the response from the API, we will put this on the map of transaction detail
        _transactionDetail[index] = resp;
      });
      LoadingScreen.instance().hide();
    }
  }

  Future<bool> _getInitData() async {
    try {
      // first let's get the min and max date
      await _brokerSummaryAPI.getBrokerSummaryBrokerDate(
        brokerID: _args.brokerFirmID
      ).then((resp) {
        _fromDateMax = resp.minDate.toLocal();
        _toDateMax = resp.maxDate.toLocal();
        _fromDateCurrent = _toDateMax.toLocal();
        _toDateCurrent = _toDateMax.toLocal();
      });

      // we will use the max date when we query the data
      await _brokerSummaryAPI.getBrokerTransactionList(
        brokerCode: _args.brokerFirmID,
        start: _start,
        limit: _limit,
        dateFrom: _fromDateCurrent.toLocal(),
        dateTo: _toDateCurrent.toLocal(),
      ).then((resp) {
        // set the current transaction list
        _transactionList = resp;

        // add start with limit
        _start = _start + _limit;

        // assume that all is not expanded
        _isExpanded = List<bool>.generate(_transactionList.brokerSummaryCodeList.length, (index) {
          return false;
        });
      });
    } catch(error) {
      Log.error(
        message: "Error when get broker detail data",
        error: error,
      );
      throw 'Error when get broker detail data';
    }

    return true;
  }
}