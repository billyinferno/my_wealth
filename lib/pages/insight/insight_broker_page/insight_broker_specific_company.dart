import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ionicons/ionicons.dart';
import 'package:my_wealth/api/broker_summary_api.dart';
import 'package:my_wealth/api/company_api.dart';
import 'package:my_wealth/model/broker_summary_model.dart';
import 'package:my_wealth/model/company_saham_list_model.dart';
import 'package:my_wealth/model/company_top_broker_model.dart';
import 'package:my_wealth/themes/colors.dart';
import 'package:my_wealth/utils/arguments/company_detail_args.dart';
import 'package:my_wealth/utils/dialog/create_snack_bar.dart';
import 'package:my_wealth/utils/function/format_currency.dart';
import 'package:my_wealth/utils/loader/show_loader_dialog.dart';
import 'package:my_wealth/utils/prefs/shared_broker.dart';
import 'package:my_wealth/utils/prefs/shared_company.dart';

class InsightBrokerSpecificCompanyPage extends StatefulWidget {
  const InsightBrokerSpecificCompanyPage({Key? key}) : super(key: key);

  @override
  State<InsightBrokerSpecificCompanyPage> createState() => _InsightBrokerSpecificCompanyPageState();
}

class _InsightBrokerSpecificCompanyPageState extends State<InsightBrokerSpecificCompanyPage> with SingleTickerProviderStateMixin {
  final BrokerSummaryAPI _brokerSummaryAPI = BrokerSummaryAPI();
  final CompanyAPI _companyAPI = CompanyAPI();
  final ScrollController _scrollControllerBrokerSummary = ScrollController();
  final ScrollController _scrollControllerBrokerTop = ScrollController();
  final ScrollController _scrollControllerCompanySahamList = ScrollController();
  late TabController _tabController;
  final DateFormat _df = DateFormat('dd-MM-yyyy');
  final TextStyle _topBrokerHeader = const TextStyle(color: accentColor, fontWeight: FontWeight.bold, fontSize: 10,);
  final TextStyle _topBrokerRow = const TextStyle(fontSize: 10,);

  late List<Widget> _pageItemsSummary;
  late List<Widget> _pageItemsTop;
  late String _companySahamCode;
  late CompanySahamListModel? _companySaham;
  late CompanySahamListModel? _currentCompanySaham;
  late DateTime _dateCurrent;
  late DateTime _dateFrom;
  late DateTime _dateTo;
  late DateTime _brokerMinDate;
  late DateTime _brokerMaxDate;
  late List<CompanySahamListModel> _companySahamList;
  late BrokerSummaryModel? _brokerSummaryData;
  late BrokerSummaryBuySellModel _brokerSummaryCurrent;
  late CompanyTopBrokerModel? _brokerTopData;
  late String _brokerSummarySelected;

  @override
  void initState() {
    // initialize tab controller
    _tabController = TabController(length: 2, vsync: this);

    // initialize the value
    _companySahamCode = "";
    _companySaham = null;
    _currentCompanySaham = null;
    _brokerSummaryData = null;
    _brokerTopData = null;

    _pageItemsSummary = [];
    _pageItemsTop = [];
    
    _dateCurrent = DateTime.now().toLocal();
    _dateFrom = DateTime.now().subtract(const Duration(days: 30)).toLocal();
    _dateTo = DateTime.now().subtract(const Duration(days: 1)).toLocal();
    _brokerMinDate = (BrokerSharedPreferences.getBrokerMinDate() ?? _dateFrom);
    _brokerMaxDate = (BrokerSharedPreferences.getBrokerMaxDate() ?? _dateTo);
    
    _companySahamList = CompanySharedPreferences.getCompanySahamList();

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
    
    super.initState();
  }

  @override
  void dispose() {
    _scrollControllerBrokerSummary.dispose();
    _scrollControllerBrokerTop.dispose();
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
            "Specific Company Code",
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
                                              _companySaham = _companySahamList[index];
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
                    if (_companySahamCode.isEmpty) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return CupertinoAlertDialog(
                            title: const Text("Select Company Code"),
                            content: const Text("Please company code from the list, before run the query."),
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
                      // generate the summary and top page
                      _generateSummaryPage();
                      _generateTopPage();
                      setState(() {
                        _currentCompanySaham = _companySaham;
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
          Expanded(
            child: Visibility(
              visible: (_currentCompanySaham != null),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.all(10),
                    padding: const EdgeInsets.all(10),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: primaryLight,
                        width: 1.0,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                (_currentCompanySaham == null ? '' : _currentCompanySaham!.name),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 5,),
                              Text(
                                "Current Price: ${(_currentCompanySaham == null ? '' : formatIntWithNull(_currentCompanySaham!.lastPrice, false, false, 0))}",
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10,),
                        IconButton(
                          onPressed: (() async {
                            showLoaderDialog(context);
                            await _companyAPI.getCompanyByCode(_companySahamCode, 'saham').then((resp) {
                              CompanyDetailArgs args = CompanyDetailArgs(
                                companyId: resp.companyId,
                                companyName: resp.companyName,
                                companyCode: _companySahamCode,
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
                          icon: const Icon(
                            Ionicons.business_outline,
                            size: 18,
                            color: accentColor,
                          ),
                        )
                      ],
                    ),
                  ),
                  TabBar(
                    controller: _tabController,
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
      )
    );
  }

  Widget _tableRow({required String buyCode, required String buyLot, required String buyValue, required String buyAverage, TextStyle? buyStyle, Color? buyColor, required String sellCode, required String sellLot, required String sellValue, required String sellAverage, TextStyle? sellStyle, Color? sellColor}) {
    TextStyle currBuyStyle = (buyStyle ?? const TextStyle(color: textPrimary));
    currBuyStyle = currBuyStyle.copyWith(
      fontSize: 9,
    );

    TextStyle currSellStyle = (sellStyle ?? const TextStyle(color: textPrimary));
    currSellStyle = currSellStyle.copyWith(
      fontSize: 9,
    );

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
    for(int i=0; i<maxPage; i++) {
      buyCode = '-';
      buyLot = '-';
      buyValue = '-';
      buyAverage = '-';
      sellCode = '-';
      sellLot = '-';
      sellValue = '-';
      sellAverage = '-';

      if(_brokerSummaryCurrent.brokerSummaryBuy.length > i) {
        buyCode = _brokerSummaryCurrent.brokerSummaryBuy[i].brokerSummaryID!;
        buyLot = formatIntWithNull(_brokerSummaryCurrent.brokerSummaryBuy[i].brokerSummaryLot, true, false);
        buyValue = formatCurrencyWithNull(_brokerSummaryCurrent.brokerSummaryBuy[i].brokerSummaryValue, true, false);
        buyAverage = formatCurrencyWithNull(_brokerSummaryCurrent.brokerSummaryBuy[i].brokerSummaryAverage, false, false);
      }

      if(_brokerSummaryCurrent.brokerSummarySell.length > i) {
        sellCode = _brokerSummaryCurrent.brokerSummarySell[i].brokerSummaryID!;
        sellLot = formatIntWithNull(_brokerSummaryCurrent.brokerSummarySell[i].brokerSummaryLot, true, false);
        sellValue = formatCurrencyWithNull(_brokerSummaryCurrent.brokerSummarySell[i].brokerSummaryValue, true, false);
        sellAverage = formatCurrencyWithNull(_brokerSummaryCurrent.brokerSummarySell[i].brokerSummaryAverage, false, false);
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
    if (_brokerSummaryData!.brokerSummaryAll.brokerSummaryBuy.isNotEmpty || _brokerSummaryData!.brokerSummaryAll.brokerSummarySell.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
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
                    _brokerSummaryCurrent = _brokerSummaryData!.brokerSummaryAll;
                    _brokerSummarySelected = "a";
                  }
                  else if(selectedValue == "d") {
                    _brokerSummaryCurrent = _brokerSummaryData!.brokerSummaryDomestic;
                    _brokerSummarySelected = "d";
                  }
                  else if(selectedValue == "f") {
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
              margin: const EdgeInsets.fromLTRB(10, 0, 10, 30),
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
    }
    else {
      return const Center(
        child: Text(
          "No data to be displayed"
        )
      );
    }
  }

  void _generateTopPage() {
    double currentValue;
    double currentDiff;

    // clear current page items for top tab
    _pageItemsTop.clear();

    // loop thru all the broker summary top data
    for(int i=0; i < _brokerTopData!.brokerData.length; i++) {
      currentValue = (_brokerTopData!.brokerData[i].brokerSummaryLot * (_companySaham!.lastPrice ?? 0)) * 100;
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
                  formatIntWithNull(_brokerTopData!.brokerData[i].brokerSummaryLot, false, false),
                  style: _topBrokerRow,
                )
              ),
              const SizedBox(width: 3,),
              Expanded(
                flex: 3,
                child: Text(
                  formatCurrency(_brokerTopData!.brokerData[i].brokerSummaryAverage, false, false, true),
                  style: _topBrokerRow,
                )
              ),
              const SizedBox(width: 3,),
              Expanded(
                flex: 3,
                child: Text(
                  formatCurrencyWithNull(_brokerTopData!.brokerData[i].brokerSummaryValue * 100),
                  style: _topBrokerRow,
                )
              ),
              const SizedBox(width: 3,),
              Expanded(
                flex: 3,
                child: Text(
                  formatCurrency(currentValue, false, false, true),
                  style: _topBrokerRow,
                )
              ),
              const SizedBox(width: 3,),
              Expanded(
                flex: 3,
                child: Text(
                  formatCurrency(currentDiff, false, false, true),
                  style: _topBrokerRow.copyWith(
                    color: (currentDiff < 0 ? secondaryColor : currentDiff > 0 ? Colors.green : textPrimary)
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
        margin: const EdgeInsets.fromLTRB(10, 0, 10, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: primaryDark,
                border: Border.all(color: primaryLight, width: 1.0, style: BorderStyle.solid),
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
                    )
                  ),
                  const SizedBox(width: 3,),
                  Expanded(
                    flex: 3,
                    child: Text(
                      "Lot",
                      style: _topBrokerHeader,
                    )
                  ),
                  const SizedBox(width: 3,),
                  Expanded(
                    flex: 3,
                    child: Text(
                      "Avg",
                      style: _topBrokerHeader,
                    )
                  ),
                  const SizedBox(width: 3,),
                  Expanded(
                    flex: 3,
                    child: Text(
                      "Cost",
                      style: _topBrokerHeader,
                    )
                  ),
                  const SizedBox(width: 3,),
                  Expanded(
                    flex: 3,
                    child: Text(
                      "Value",
                      style: _topBrokerHeader,
                    )
                  ),
                  const SizedBox(width: 3,),
                  Expanded(
                    flex: 3,
                    child: Text(
                      "Diff",
                      style: _topBrokerHeader,
                    )
                  ),
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
              )
            ),
          ],
        ),
      );
    }
    else {
      return const Center(
        child: Text(
          "No data to be displayed"
        )
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
    showLoaderDialog(context);
    await Future.wait([
      // get the data of the broker transaction for this company code
      _brokerSummaryAPI.getBrokerSummary(_companySahamCode, _dateFrom, _dateTo).then((resp) {
        _brokerSummaryData = resp;
        _brokerSummaryCurrent = _brokerSummaryData!.brokerSummaryAll;
        _brokerSummarySelected = "a";
      }),
      _companyAPI.getCompanyTopBroker(_companySahamCode, _dateFrom, _dateTo, 9999).then((resp) {
        _brokerTopData = resp;
      }),
    ]).then((_) {
      // remove the loader dialog
      Navigator.pop(context);
    }).onError((error, stackTrace) {
      // remove the loader dialog
      Navigator.pop(context);

      // print the stack trace and show snackbar
      debugPrintStack(stackTrace: stackTrace);
      ScaffoldMessenger.of(context).showSnackBar(createSnackBar(message: "Error when try to fetch broker data"));
    });
  }
}