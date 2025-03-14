import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';
import 'package:my_wealth/_index.g.dart';

class InsightBrokerPage extends StatefulWidget {
  const InsightBrokerPage({super.key});

  @override
  State<InsightBrokerPage> createState() => _InsightBrokerPageState();
}

class _InsightBrokerPageState extends State<InsightBrokerPage> {
  final CompanyAPI _companyAPI = CompanyAPI();
  final BrokerSummaryAPI _brokerSummaryAPI = BrokerSummaryAPI();
  final InsightAPI _insightAPI = InsightAPI();

  final ScrollController _scrollController = ScrollController();

  late BrokerSummaryTopModel? _brokerTopList;
  late List<BrokerSummaryBuyElement> _brokerTopListBuy;
  late List<BrokerSummaryBuyElement> _brokerTopListSell;
  late BrokerTopTransactionModel _brokerTopTransaction;
  late BuySell _brokerTopTransactionBuySell;
  late MarketTodayModel _marketToday;
  late List<MarketCapModel> _marketCap;

  String _brokerSummarySelected = 'a';
  String _brokerTopTransactionSelected = 'a';

  @override
  void initState() {
    super.initState();

    _brokerTopList = BrokerSharedPreferences.getBrokerTopList();
    _brokerTopTransaction = InsightSharedPreferences.getBrokerTopTxn();
    _marketToday = InsightSharedPreferences.getBrokerMarketToday();
    _marketCap = InsightSharedPreferences.getMarketCap();

    _brokerSummarySelected = 'a';    
    _brokerTopListBuy = _brokerTopList!.brokerSummaryAll.brokerSummaryBuy;
    _brokerTopListSell = _brokerTopList!.brokerSummaryAll.brokerSummarySell;

    _brokerTopTransactionSelected = 'a';
    _brokerTopTransactionBuySell = _brokerTopTransaction.all;
  }

  @override
  void dispose() {
    _scrollController.dispose();

    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Consumer2<BrokerProvider, InsightProvider>(
      builder: ((context, brokerProvider, insightProvider, child) {
        _brokerTopList = brokerProvider.brokerTopList;
        _brokerTopTransaction = insightProvider.brokerTopTransactionList!;
        _marketToday = insightProvider.brokerMarketToday!;
        _marketCap = insightProvider.marketCap!;

        return RefreshIndicator(
          onRefresh: (() async {
            await _getInsightInformation().onError((error, stackTrace) {
              // got error show the snack bar
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(createSnackBar(message: error.toString()));
              }
            },).then((_) {
              // if all good rebuild the state
              setState(() {
                // rebuild to refresh the widget
              });
            },);
          }),
          color: accentColor,
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            child: Container(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  const Center(
                    child: Text(
                      "Market Today",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10,),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      _marketTodayBox(
                        color: Colors.green[900]!,
                        type: "Buy",
                        totalLot: _marketToday.buy.brokerSummaryTotalLot,
                        totalValue: _marketToday.buy.brokerSummaryTotalValue,
                      ),
                      const SizedBox(width: 10,),
                      _marketTodayBox(
                        color: secondaryDark,
                        type: "Sell",
                        totalLot: _marketToday.sell.brokerSummaryTotalLot,
                        totalValue: _marketToday.sell.brokerSummaryTotalValue,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20,),
                  const Center(
                    child: Text(
                      "Broker Query",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          TransparentButton(
                            icon: Ionicons.funnel,
                            iconSize: 12,
                            color: primaryDark,
                            borderColor: primaryLight,
                            text: "Broker\nAccumulation",
                            vertical: true,
                            onTap: (() {
                              Navigator.pushNamed(context, '/insight/broker/specificbroker');
                            })
                          ),
                          const SizedBox(width: 10,),
                          TransparentButton(
                            icon: Ionicons.funnel,
                            iconSize: 12,
                            color: primaryDark,
                            borderColor: primaryLight,
                            text: "Broker and\nCode",
                            vertical: true,
                            onTap: (() {
                              Navigator.pushNamed(context, '/insight/broker/specificquery');
                            })
                          ),
                          const SizedBox(width: 10,),
                          TransparentButton(
                            icon: Ionicons.funnel,
                            iconSize: 12,
                            color: primaryDark,
                            borderColor: primaryLight,
                            text: "Code\nOnly",
                            vertical: true,
                            onTap: (() {
                              Navigator.pushNamed(context, '/insight/broker/specificcode');
                            })
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20,),
                  const Center(
                    child: Text(
                      "Broker Top Traded Stock",
                      style: TextStyle(
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                  const SizedBox(height: 5,),
                  Center(
                    child: Text(
                      Globals.dfDDMMMyyyy.formatLocal(_brokerTopList!.brokerSummaryDate),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: secondaryLight,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8,),
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
                            _brokerTopListBuy = _brokerTopList!.brokerSummaryAll.brokerSummaryBuy;
                            _brokerTopListSell = _brokerTopList!.brokerSummaryAll.brokerSummarySell;
                            _brokerSummarySelected = "a";
                          }
                          else if(selectedValue == "d") {
                            _brokerTopListBuy = _brokerTopList!.brokerSummaryDomestic.brokerSummaryBuy;
                            _brokerTopListSell = _brokerTopList!.brokerSummaryDomestic.brokerSummarySell;
                            _brokerSummarySelected = "d";
                          }
                          else if(selectedValue == "f") {
                            _brokerTopListBuy = _brokerTopList!.brokerSummaryForeign.brokerSummaryBuy;
                            _brokerTopListSell = _brokerTopList!.brokerSummaryForeign.brokerSummarySell;
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
                  _generateRow(
                    num: '#',
                    code: 'Code',
                    lastPrice: 'Last',
                    average: 'B.Avg',
                    lot: 'B.Lot',
                    count: 'Cnt',
                    backgroundColor: Colors.green[900],
                    textBold: true,
                    enableTap: false,
                  ),
                  _generateBrokerTopListTable(_brokerTopListBuy),
                  _generateRow(
                    num: '#',
                    code: 'Code',
                    lastPrice: 'Last',
                    average: 'S.Avg',
                    lot: 'S.Lot',
                    count: 'Cnt',
                    backgroundColor: secondaryDark,
                    textBold: true,
                    enableTap: false,
                  ),
                  _generateBrokerTopListTable(_brokerTopListSell),
                  const SizedBox(height: 20,),
                  const Center(
                    child: Text(
                      "Broker Top Transaction",
                      style: TextStyle(
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                  const SizedBox(height: 5,),
                  Center(
                    child: Text(
                      Globals.dfDDMMMyyyy.formatLocal(_brokerTopTransaction.brokerSummaryDate),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: secondaryLight,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8,),
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
                            _brokerTopTransactionBuySell = _brokerTopTransaction.all;
                            _brokerTopTransactionSelected = "a";
                          }
                          else if(selectedValue == "d") {
                            _brokerTopTransactionBuySell = _brokerTopTransaction.domestic;
                            _brokerTopTransactionSelected = "d";
                          }
                          else if(selectedValue == "f") {
                            _brokerTopTransactionBuySell = _brokerTopTransaction.foreign;
                            _brokerTopTransactionSelected = "f";
                          }
                        });
                      }),
                      groupValue: _brokerTopTransactionSelected,
                      selectedColor: secondaryColor,
                      borderColor: secondaryDark,
                      pressedColor: primaryDark,
                    ),
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
                            _brokerTopItem(byText: 'BY', txnText: 'Txn', lotText: 'Lot', bgColor: Colors.green[900], align: Alignment.center, fontWeight: FontWeight.bold),
                            ..._generateBroketTopTransactionTable(data: _brokerTopTransactionBuySell.buy),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            _brokerTopItem(byText: 'SY', txnText: 'Txn', lotText: 'Lot', bgColor: secondaryDark, align: Alignment.center, fontWeight: FontWeight.bold),
                            ..._generateBroketTopTransactionTable(data: _brokerTopTransactionBuySell.sell),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20,),
                  const Center(
                    child: Text(
                      "Market Cap",
                      style: TextStyle(
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                  const SizedBox(height: 8,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      _marketCapHeader(),
                      ...List<Widget>.generate(_marketCap.length, (index) {
                        return _marketCapRow(
                          no: (index + 1),
                          code: _marketCap[index].code,
                          price: _marketCap[index].lastPrice,
                          marketCap: _marketCap[index].capitalization.toInt(),
                          shareOut: _marketCap[index].shareOut
                        );
                      }),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _marketCapHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Container(
          width: 40,
          padding: const EdgeInsets.all(5),
          color: Colors.green[900],
          child: const Text(
            "No",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          )
        ),
        Container(
          width: 70,
          padding: const EdgeInsets.all(5),
          color: Colors.green[900],
          child: const Text(
            "Code",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          )
        ),
        Container(
          width: 70,
          padding: const EdgeInsets.all(5),
          color: Colors.green[900],
          child: const Text(
            "Price",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          )
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(5),
            color: Colors.green[900],
            child: const Text(
              "Market Cap",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            )
          ),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(5),
            color: Colors.green[900],
            child: const Text(
              "Share Out",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            )
          ),
        ),
      ],
    );
  }

  Widget _marketCapRow({required int no, required String code, required int price, required int marketCap, required int shareOut}) {
    return InkWell(
      onTap: (() async {
        // show loading screen
        LoadingScreen.instance().show(context: context);

        // get the stock information by code
        await _companyAPI.getCompanyByCode(
          companyCode: code,
          type: 'saham',
        ).then((resp) {
          CompanyDetailArgs args = CompanyDetailArgs(
            companyId: resp.companyId,
            companyName: resp.companyName,
            companyCode: code,
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
            ScaffoldMessenger.of(context).showSnackBar(createSnackBar(message: 'Error when try to get the company detail from server'));
          }
        }).whenComplete(() {
          // remove the loading screen
          LoadingScreen.instance().hide();
        },);
      }),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 40,
            padding: const EdgeInsets.all(5),
            color: primaryDark,
            child: Text(
              "$no",
              textAlign: TextAlign.center,
            )
          ),
          Container(
            width: 70,
            padding: const EdgeInsets.all(5),
            color: primaryDark,
            child: Text(
              code,
              textAlign: TextAlign.center,
            )
          ),
          Container(
            width: 70,
            padding: const EdgeInsets.all(5),
            color: primaryDark,
            child: Text(
              formatIntWithNull(
                price,
                showDecimal: false
              ),
              textAlign: TextAlign.center,
            )
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(5),
              color: primaryDark,
              child: Text(
                formatIntWithNull(marketCap,),
                textAlign: TextAlign.center,
              )
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(5),
              color: primaryDark,
              child: Text(
                formatIntWithNull(shareOut,),
                textAlign: TextAlign.center,
              )
            ),
          ),
        ],
      ),
    );
  }

  Widget _brokerTopItem({required Color? bgColor, required String byText, required String txnText, required String lotText, AlignmentGeometry? align, FontWeight? fontWeight}) {
    AlignmentGeometry currentAlign = (align ?? Alignment.centerLeft);
    FontWeight currentFontWeight = (fontWeight ?? FontWeight.normal);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Container(
          color: bgColor,
          width: 40,
          padding: const EdgeInsets.all(2),
          child: Align(
            alignment: currentAlign,
            child: Text(
              byText,
              style: TextStyle(
                fontWeight: currentFontWeight,
              ),
            )
          ),
        ),
        Expanded(
          child: Container(
            color: bgColor,
            padding: const EdgeInsets.all(2),
            child: Align(
              alignment: currentAlign,
              child: Text(
                txnText,
                style: TextStyle(
                  fontWeight: currentFontWeight,
                ),
              )
            ),
          ),
        ),
        Expanded(
          child: Container(
            color: bgColor,
            padding: const EdgeInsets.all(2),
            child: Align(
              alignment: currentAlign,
              child: Text(
                lotText,
                style: TextStyle(
                  fontWeight: currentFontWeight,
                ),
              )
            ),
          ),
        ),
      ],
    );
  }

  Widget _generateRow({required String num, required String code, required String lastPrice, required String average, required String lot, required String count, Color? textColor, bool? textBold, Color? backgroundColor, bool? enableTap}) {
    Color textColorUse = (textColor ?? Colors.white);
    bool textBoldUse = (textBold ?? false);
    Color backgroundColorUse = (backgroundColor ?? Colors.transparent);
    bool isTapEnabled = (enableTap ?? true);

    return InkWell(
      onTap: (() async {
        if (!isTapEnabled) {
          return;
        }

        // show loading screen
        LoadingScreen.instance().show(context: context);

        // get the stock information using code
        await _companyAPI.getCompanyByCode(
          companyCode: code,
          type: 'saham',
        ).then((resp) {
          CompanyDetailArgs args = CompanyDetailArgs(
            companyId: resp.companyId,
            companyName: resp.companyName,
            companyCode: code,
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
            ScaffoldMessenger.of(context).showSnackBar(createSnackBar(message: 'Error when try to get the company detail from server'));
          }
        }).whenComplete(() {
          // remove loading screen
          LoadingScreen.instance().hide();
        },);
      }),
      child: SizedBox(
        width: double.infinity,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 35,
              color: backgroundColorUse,
              padding: const EdgeInsets.all(2),
              child: Center(
                child: Text(
                  num,
                  style: TextStyle(
                    fontWeight: (textBoldUse ? FontWeight.bold : FontWeight.normal),
                    color: textColorUse
                  ),
                )
              ),
            ),
            Container(
              color: backgroundColorUse,
              padding: const EdgeInsets.all(2),
              width: 55,
              child: Text(
                code,
                style: TextStyle(
                  fontWeight: (textBoldUse ? FontWeight.bold : FontWeight.normal),
                  color: textColorUse
                ),
              ),
            ),
            Expanded(
              child: Container(
                color: backgroundColorUse,
                padding: const EdgeInsets.all(2),
                child: Text(
                  lastPrice,
                  style: TextStyle(
                    fontWeight: (textBoldUse ? FontWeight.bold : FontWeight.normal),
                    color: textColorUse
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                color: backgroundColorUse,
                padding: const EdgeInsets.all(2),
                child: Text(
                  average,
                  style: TextStyle(
                    fontWeight: (textBoldUse ? FontWeight.bold : FontWeight.normal),
                    color: textColorUse
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                color: backgroundColorUse,
                padding: const EdgeInsets.all(2),
                child: Text(
                  lot,
                  style: TextStyle(
                    fontWeight: (textBoldUse ? FontWeight.bold : FontWeight.normal),
                    color: textColorUse
                  ),
                ),
              ),
            ),
            Container(
              width: 35,
              color: backgroundColorUse,
              padding: const EdgeInsets.all(2),
              child: Center(
                child: Text(
                  count,
                  style: TextStyle(
                    fontWeight: (textBoldUse ? FontWeight.bold : FontWeight.normal),
                    color: textColorUse
                  ),
                )
              ),
            ),
          ], 
        ),
      ),
    );
  }

  Widget _generateBrokerTopListTable(List<BrokerSummaryBuyElement> data) {
    // check the data length, if it's zero then return it as "data not yet available"
    // instead generate an empty data
    if (data.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(2),
        color: primaryDark,
        child: const Center(
          child: Text(
            "Data Not Yet Available"
          ),
        ),
      );
    }
    else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          ...List<Widget>.generate(data.length, (index) {
            return _generateRow(
              num: (index+1).toString(),
              code: data[index].brokerSummaryCode,
              lastPrice: formatIntWithNull(
                data[index].brokerSummaryLastPrice,
                showDecimal: false
              ),
              average: formatIntWithNull(
                data[index].brokerSummaryAverage,
                showDecimal: false
              ),
              lot: formatIntWithNull(
                data[index].brokerSummaryLot,
                checkThousand: true,
              ),
              count: data[index].brokerSummaryCount,
              backgroundColor: primaryDark
            );
          }),
        ],
      );
    }
  }

  List<Widget> _generateBroketTopTransactionTable({required List<BuySellItem> data}) {
    // check if data is empty, if empty then we can just print "Data N/A"
    if (data.isEmpty) {
      return [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Expanded (
              child: Container(
                color: primaryDark,
                padding: const EdgeInsets.all(2),
                child: const Center(
                  child: Text(
                    "Data N/A",
                  )
                ),
              ),
            ),
          ],
        ),
      ];
    }
    else {
      return List<Widget>.generate(data.length, (index) {
        BrokerDetailArgs args = BrokerDetailArgs(brokerFirmID: data[index].brokerSummaryId);

        return InkWell(
          onTap: (() {
            Navigator.pushNamed(context, '/broker/detail', arguments: args);
          }),
          child: _brokerTopItem(
            bgColor: primaryDark,
            byText: data[index].brokerSummaryId,
            txnText: data[index].brokerTotalTxn,
            lotText: formatCurrency(
              data[index].brokerTotalLot,
              checkThousand: true,
              showDecimal: false,
            ),
            align: Alignment.center,
          ),
        );
      });
    }
  }

  Future<void> _getInsightInformation() async {
    // show loading screen
    LoadingScreen.instance().show(context: context);

    // get all the insight and broker summary information
    await Future.wait([
      _brokerSummaryAPI.getBrokerSummaryTop().then((resp) async {
        Log.success(message: "🔃 Refresh Broker Summary Top");
        await BrokerSharedPreferences.setBroketTopList(topList: resp);
        if (mounted) {
          Provider.of<BrokerProvider>(
            context,
            listen: false
          ).setBrokerTopList(brokerTopListData: resp);
        }
      }),
      
      _insightAPI.getBrokerTopTransaction().then((resp) async {
        Log.success(message: "🔃 Refresh Broker Top Transaction List");
        await InsightSharedPreferences.setBrokerTopTxn(brokerTopList: resp);
        if (mounted) {
          Provider.of<InsightProvider>(
            context,
            listen: false
          ).setBrokerTopTransactionList(data: resp);
        }
      }),

      _insightAPI.getMarketToday().then((resp) async {
        Log.success(message: "🔃 Refresh Broker Market Today");
        await InsightSharedPreferences.setBrokerMarketToday(marketToday: resp);
        if (mounted) {
          Provider.of<InsightProvider>(
            context,
            listen: false
          ).setBrokerMarketToday(data: resp);
        }
      }),

       _insightAPI.getMarketCap().then((resp) async {
        Log.success(message: "🔃 Refresh Broker Market Cap");
        await InsightSharedPreferences.setMarketCap(marketCapList: resp);
        if (mounted) {
          Provider.of<InsightProvider>(
            context,
            listen: false
          ).setMarketCap(data: resp);
        }
      }),
    ]).onError((error, stackTrace) {
      Log.error(
        message: 'Error getting broker insight information',
        error: error,
        stackTrace: stackTrace,
      );

      throw Exception('Error when get broker insight information');
    }).whenComplete(() {
      // remove the loading screen
      LoadingScreen.instance().hide();
    });
  }

  Widget _marketTodayBox({
    required Color color,
    required String type,
    required int totalLot,
    required int totalValue,
  }) {
    return Expanded(
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 10,
              color: color,
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(10),
                color: primaryDark,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      type,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2,),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        const Expanded(
                          child: Text(
                            "Lot",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            formatIntWithNull(
                              totalLot,
                            ),
                          )
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        const Expanded(
                          child: Text(
                            "Value",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            formatIntWithNull(
                              totalValue,
                            ),
                          )
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}