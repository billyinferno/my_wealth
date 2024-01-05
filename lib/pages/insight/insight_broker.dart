import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ionicons/ionicons.dart';
import 'package:my_wealth/api/broker_summary_api.dart';
import 'package:my_wealth/api/company_api.dart';
import 'package:my_wealth/api/insight_api.dart';
import 'package:my_wealth/model/broker/broker_summary_top_model.dart';
import 'package:my_wealth/model/broker/broker_top_transaction_model.dart';
import 'package:my_wealth/model/insight/insight_market_cap_model.dart';
import 'package:my_wealth/model/insight/insight_market_today_model.dart';
import 'package:my_wealth/provider/broker_provider.dart';
import 'package:my_wealth/provider/inisght_provider.dart';
import 'package:my_wealth/themes/colors.dart';
import 'package:my_wealth/utils/arguments/broker_detail_args.dart';
import 'package:my_wealth/utils/arguments/company_detail_args.dart';
import 'package:my_wealth/utils/dialog/create_snack_bar.dart';
import 'package:my_wealth/utils/function/format_currency.dart';
import 'package:my_wealth/utils/loader/show_loader_dialog.dart';
import 'package:my_wealth/storage/prefs/shared_broker.dart';
import 'package:my_wealth/storage/prefs/shared_insight.dart';
import 'package:my_wealth/widgets/components/transparent_button.dart';
import 'package:provider/provider.dart';

class InsightBrokerPage extends StatefulWidget {
  const InsightBrokerPage({Key? key}) : super(key: key);

  @override
  State<InsightBrokerPage> createState() => _InsightBrokerPageState();
}

class _InsightBrokerPageState extends State<InsightBrokerPage> {
  final CompanyAPI _companyAPI = CompanyAPI();
  final BrokerSummaryAPI _brokerSummaryAPI = BrokerSummaryAPI();
  final InsightAPI _insightAPI = InsightAPI();

  final DateFormat _df = DateFormat('dd MMM yyyy');
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
    _brokerTopList = BrokerSharedPreferences.getBrokerTopList();
    _brokerTopTransaction = InsightSharedPreferences.getBrokerTopTxn();
    _marketToday = InsightSharedPreferences.getBrokerMarketToday();
    _marketCap = InsightSharedPreferences.getMarketCap();

    _brokerSummarySelected = 'a';    
    _brokerTopListBuy = _brokerTopList!.brokerSummaryAll.brokerSummaryBuy;
    _brokerTopListSell = _brokerTopList!.brokerSummaryAll.brokerSummarySell;

    _brokerTopTransactionSelected = 'a';
    _brokerTopTransactionBuySell = _brokerTopTransaction.all;

    super.initState();
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
            showLoaderDialog(context);
            Future.microtask(() async {
              // get the broker summary top list
              await _brokerSummaryAPI.getBrokerSummaryTop().then((resp) async {
                debugPrint("🔃 Refresh Broker Summary Top");
                await BrokerSharedPreferences.setBroketTopList(resp);
                if (!mounted) return;
                Provider.of<BrokerProvider>(context, listen: false).setBrokerTopList(resp);
              }).onError((error, stackTrace) {
                // show the snack bar
                ScaffoldMessenger.of(context).showSnackBar(createSnackBar(message: "Unable to get broker top list"));
                debugPrintStack(stackTrace: stackTrace);
              });

              await _insightAPI.getBrokerTopTransaction().then((resp) async {
                debugPrint("🔃 Refresh Broker Top Transaction List");
                await InsightSharedPreferences.setBrokerTopTxn(resp);
                if (!mounted) return;
                Provider.of<InsightProvider>(context, listen: false).setBrokerTopTransactionList(resp);
              }).onError((error, stackTrace) {
                // show the snack bar
                ScaffoldMessenger.of(context).showSnackBar(createSnackBar(message: "Unable to get broker top transaction"));
                debugPrintStack(stackTrace: stackTrace);
              });

              await _insightAPI.getMarketToday().then((resp) async {
                debugPrint("🔃 Refresh Broker Market Today");
                await InsightSharedPreferences.setBrokerMarketToday(resp);
                if (!mounted) return;
                Provider.of<InsightProvider>(context, listen: false).setBrokerMarketToday(resp);
              }).onError((error, stackTrace) {
                // show the snack bar
                ScaffoldMessenger.of(context).showSnackBar(createSnackBar(message: "Unable to get market today"));
                debugPrintStack(stackTrace: stackTrace);
              });

              await _insightAPI.getMarketCap().then((resp) async {
                debugPrint("🔃 Refresh Broker Market Cap");
                await InsightSharedPreferences.setMarketCap(resp);
                if (!mounted) return;
                Provider.of<InsightProvider>(context, listen: false).setMarketCap(resp);
              }).onError((error, stackTrace) {
                // show the snack bar
                ScaffoldMessenger.of(context).showSnackBar(createSnackBar(message: "Unable to get market cap"));
                debugPrintStack(stackTrace: stackTrace);
              });
            }).whenComplete(() {
              Navigator.pop(context);

              setState(() {
                // rebuild to refresh the widget
              });
            });
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
                      Expanded(
                        child: Container(
                          color: Colors.green[900],
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              const SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  color: primaryDark,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      const Text(
                                        "Buy",
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
                                              formatIntWithNull(_marketToday.buy.brokerSummaryTotalLot, false, true),
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
                                              formatIntWithNull(_marketToday.buy.brokerSummaryTotalValue, false, true),
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
                      ),
                      const SizedBox(width: 10,),
                      Expanded(
                        child: Container(
                          color: secondaryDark,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              const SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  color: primaryDark,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      const Text(
                                        "Sell",
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
                                              formatIntWithNull(_marketToday.sell.brokerSummaryTotalLot, false, true),
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
                                              formatIntWithNull(_marketToday.sell.brokerSummaryTotalValue, false, true),
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
                            bgColor: primaryDark,
                            borderColor: primaryLight,
                            text: "Broker and Code",
                            // vertical: true,
                            callback: (() {
                              Navigator.pushNamed(context, '/insight/broker/specificquery');
                            })
                          ),
                          const SizedBox(width: 10,),
                          TransparentButton(
                            icon: Ionicons.funnel,
                            iconSize: 12,
                            bgColor: primaryDark,
                            borderColor: primaryLight,
                            text: "Code Only",
                            // vertical: true,
                            callback: (() {
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
                      _df.format(_brokerTopList!.brokerSummaryDate.toLocal()),
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
                      _df.format(_brokerTopTransaction.brokerSummaryDate.toLocal()),
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
        showLoaderDialog(context);
        await _companyAPI.getCompanyByCode(code, 'saham').then((resp) {
          CompanyDetailArgs args = CompanyDetailArgs(
            companyId: resp.companyId,
            companyName: resp.companyName,
            companyCode: code,
            companyFavourite: (resp.companyFavourites ?? false),
            favouritesId: (resp.companyFavouritesId ?? -1),
            type: "saham",
          );
          
          // remove the loader dialog
          Navigator.pop(context);

          // go to the company page
          Navigator.pushNamed(context, '/company/detail/saham', arguments: args);
        }).onError((error, stackTrace) {
          // remove the loader dialog
          Navigator.pop(context);

          // show the error message
          ScaffoldMessenger.of(context).showSnackBar(createSnackBar(message: 'Error when try to get the company detail from server'));
        });
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
              formatIntWithNull(price, false, false),
              textAlign: TextAlign.center,
            )
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(5),
              color: primaryDark,
              child: Text(
                formatIntWithNull(marketCap, false, true),
                textAlign: TextAlign.center,
              )
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(5),
              color: primaryDark,
              child: Text(
                formatIntWithNull(shareOut, false, true),
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

        showLoaderDialog(context);
        await _companyAPI.getCompanyByCode(code, 'saham').then((resp) {
          CompanyDetailArgs args = CompanyDetailArgs(
            companyId: resp.companyId,
            companyName: resp.companyName,
            companyCode: code,
            companyFavourite: (resp.companyFavourites ?? false),
            favouritesId: (resp.companyFavouritesId ?? -1),
            type: "saham",
          );
          
          // remove the loader dialog
          Navigator.pop(context);

          // go to the company page
          Navigator.pushNamed(context, '/company/detail/saham', arguments: args);
        }).onError((error, stackTrace) {
          // remove the loader dialog
          Navigator.pop(context);

          // show the error message
          ScaffoldMessenger.of(context).showSnackBar(createSnackBar(message: 'Error when try to get the company detail from server'));
        });
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
              lastPrice: formatIntWithNull(data[index].brokerSummaryLastPrice, false, false),
              average: formatIntWithNull(data[index].brokerSummaryAverage, false, false),
              lot: formatIntWithNull(data[index].brokerSummaryLot, true, true),
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
            lotText: formatCurrency(data[index].brokerTotalLot, true, false, true),
            align: Alignment.center,
          ),
        );
      });
    }
  }
}