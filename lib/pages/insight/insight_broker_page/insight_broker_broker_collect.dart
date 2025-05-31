import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:ionicons/ionicons.dart';
import 'package:my_wealth/_index.g.dart';

class InsightBandarBrokerCollectPage extends StatefulWidget {
  const InsightBandarBrokerCollectPage({super.key});

  @override
  State<InsightBandarBrokerCollectPage> createState() => _InsightBandarBrokerCollectPageState();
}

class _InsightBandarBrokerCollectPageState extends State<InsightBandarBrokerCollectPage> {
  final InsightAPI _insightAPI = InsightAPI();
  final CompanyAPI _companyAPI = CompanyAPI();
  final ScrollController _scrollController = ScrollController();

  final List<FlipFlopItem<CalendarType>> _brokerFlipFlopItem = [];
  late CalendarType _brokerCalendarType;
  
  late BrokerModel _brokerData;
  late String _brokerCode;
  late DateTime _minBrokerDate;
  late DateTime _maxBrokerDate;
  late DateTime _fromDate;
  late DateTime _toDate;
  late int _accumRate;
  late InsightBrokerCollectModel? _brokerCollect;
  late List<BrokerCollectCompany> _brokerCollectCompanyList;
  late List<BrokerCollectCompany> _filteredBrokcerCollectCompanyList;

  late String _filterMode;
  late SortBoxType _filterSort;
  final Map<String, String> _filterList = {};

  @override
  void initState() {
    super.initState();

    // initialize broker code
    _brokerCode = InsightSharedPreferences.getBrokerCollectID();
    
    // get the minimum and maximum broker date
    _minBrokerDate = (BrokerSharedPreferences.getBrokerMinDate() ?? _maxBrokerDate.add(const Duration(days: -14)).toLocal());
    _maxBrokerDate = (BrokerSharedPreferences.getBrokerMaxDate() ?? DateTime.now().toLocal());

    // get the from and to date
    _fromDate = (InsightSharedPreferences.getBrokerCollectDate(type: 'from') ?? DateTime.now().subtract(const Duration(days: 30)).toLocal());
    _toDate = (InsightSharedPreferences.getBrokerCollectDate(type: 'to') ?? DateTime.now().toLocal());

    // check if the from date is beofre the _minBrokerDate
    if (_minBrokerDate.isAfter(_fromDate)) {
      _fromDate = _minBrokerDate;
    }

    // check if the to date is after the _maxBrokerDate
    if (_maxBrokerDate.isBefore(_toDate)) {
      _toDate = _maxBrokerDate;
    }

    // get the accumulation rate
    _accumRate = InsightSharedPreferences.getBrokerCollectAccumulationRate();

    // get the broker collection
    _brokerCollect = InsightSharedPreferences.getBrokerCollect();
    _brokerCollectCompanyList = (_brokerCollect?.data ?? []);
    _filteredBrokcerCollectCompanyList = _brokerCollectCompanyList.toList();

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

    // list all the filter that we want to put here
    _filterList["CD"] = "Code";
    _filterList["BL"] = "Buy Lot";
    _filterList["BV"] = "Buy Value";
    _filterList["BP"] = "AVG Buy Price";
    _filterList["SL"] = "Sell Lot";
    _filterList["SV"] = "Sell Value";
    _filterList["SP"] = "AVG Sell Price";
    _filterList["LL"] = "Left Lot";
    _filterList["LV"] = "Left Value";
    _filterList["LP"] = "AVG Left Price";

    // default filter mode to Code and ASC
    _filterMode = "LL";
    _filterSort = SortBoxType.descending;
  }

  @override
  void dispose() {
    _scrollController.dispose();
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
            "Broker Accumulation",
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
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
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
                                await Navigator.pushNamed(context, '/broker/find').then((value) {
                                  if (value != null) {
                                    // convert value to company list model
                                    _brokerData = value as BrokerModel;
                    
                                    // set the data
                                    setState(() {
                                      _brokerCode = _brokerData.brokerFirmId;
                                    });
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
                                  color: primaryDark,
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
                        flex: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            const Text(
                              "Accum %",
                              style: TextStyle(
                                color: accentColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5,),
                            NumberStepper(
                              height: 29,
                              borderColor: primaryLight,
                              buttonColor: secondaryColor,
                              bgColor: primaryDark,
                              textColor: textPrimary,
                              textSize: 10,
                              iconSize: 15,
                              initialRate: _accumRate,
                              onTap: ((newRate) {
                                _accumRate = newRate;
                              }),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 5,),
                      Expanded(
                        flex: 7,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
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
                                        color: primaryDark,
                                        borderRadius: const BorderRadius.only(
                                          bottomLeft: Radius.circular(5),
                                          topLeft: Radius.circular(5)
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          Globals.dfddMMyy.formatDateWithNull(_fromDate),
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
                                        color: primaryDark,
                                        borderRadius: const BorderRadius.only(
                                          bottomRight: Radius.circular(5),
                                          topRight: Radius.circular(5)
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          Globals.dfddMMyy.formatDateWithNull(_toDate),
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
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const Text(
                            "",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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
                  const SizedBox(height: 10,),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      TransparentButton(
                        icon: Ionicons.search,
                        onTap: () async {
                          // check that broker and code already filled
                          if (_brokerCode.isEmpty) {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return CupertinoAlertDialog(
                                  title: const Text("Select Broker"),
                                  content: const Text(
                                    "Please select broker from the list, before run the query."
                                  ),
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
                            // get the broker collection
                            await _getBrokerCollect().then((_) {  
                              setState(() {
                                // rebuild widget
                              });
                            }).onError((error, stackTrace) {
                              if (context.mounted) {
                                // show the error
                                ScaffoldMessenger.of(context).showSnackBar(
                                  createSnackBar(
                                    message: "Error when trying to get the broker summary data",
                                    icon: const Icon(
                                      Ionicons.warning,
                                      size: 12,
                                    )
                                  )
                                );
                              }
                            },);
                          }
                        },
                        color: secondaryColor,
                        borderColor: secondaryLight,
                        text: "SEARCH",
                      ),
                    ],
                  ),
                  Visibility(
                    visible: (_brokerCollect != null),
                    child: SortBox(
                      initialFilter: _filterMode,
                      filterList: _filterList,
                      filterSort: _filterSort,
                      padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                      onChanged: (filter, sort) {
                        setState(() {
                          _filterMode = filter;
                          _filterSort = sort;
                          _filterData();
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10,),
            _generateSummary(),
            const SizedBox(height: 10,),
            _generateList(),
          ],
        ),
      ),
    );
  }

  Widget _generateSummary() {
    // if broker collection still null, just return sized box
    if (_brokerCollect == null) {
      return const SizedBox.shrink();
    }

    // create the summary box
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
      decoration: BoxDecoration(
        border: Border.all(
          color: primaryLight,
          width: 1.0,
          style: BorderStyle.solid,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            height: 40,
            decoration: const BoxDecoration(
              color: primaryDark,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              )
            ),
            child: const Center(
              child: Text(
                'SUMMARY'
              ),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                      color: Colors.green,
                      child: const Center(
                        child: Text(
                          "BUY",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 5,),
                    Container(
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          const Text(
                            "Lot",
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            formatIntWithNull(
                              _brokerCollect!.summaryTotalBuy,
                              showDecimal: false,
                              decimalNum: 0,
                              shorten: false,
                            ),
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 5,),
                          const Text(
                            "Value",
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            formatIntWithNull(
                              _brokerCollect!.summaryTotalBuyValue,
                              showDecimal: false,
                              decimalNum: 2,
                            ),
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 5,),
                          const Text(
                            "Count",
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            "${formatIntWithNull(
                              _brokerCollect!.summaryCountBuy,
                              showDecimal: false,
                              decimalNum: 0,
                              shorten: false
                            )} time${(_brokerCollect!.summaryCountBuy) > 1 ? 's' : ''}",
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
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
                    )
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                        color: secondaryColor,
                        child: const Center(
                          child: Text(
                            "SELL",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 5,),
                      Container(
                        padding: const EdgeInsets.fromLTRB(10, 0, 10, 5),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            const Text(
                              "Lot",
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              formatIntWithNull(
                                _brokerCollect!.summaryTotalSell,
                                showDecimal: false,
                                decimalNum: 0,
                                shorten: false
                              ),
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 5,),
                            const Text(
                              "Value",
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              formatIntWithNull(
                                _brokerCollect!.summaryTotalSellValue,
                                showDecimal: false,
                                decimalNum: 2,
                              ),
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 5,),
                            const Text(
                              "Count",
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              "${formatIntWithNull(
                                _brokerCollect!.summaryCountSell,
                                showDecimal: false,
                                decimalNum: 0,
                                shorten: false
                              )} time${(_brokerCollect!.summaryCountSell) > 1 ? 's' : ''}",
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                      color: accentDark,
                      child: const Center(
                        child: Text(
                          "LEFT",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 5,),
                    Container(
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          const Text(
                            "Lot",
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            formatIntWithNull(
                              _brokerCollect!.summaryTotalLeft,
                              showDecimal: false,
                              decimalNum: 0,
                              shorten: false
                            ),
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 5,),
                          const Text(
                            "Value",
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            formatIntWithNull(
                              _brokerCollect!.summaryTotalBuyValue - _brokerCollect!.summaryTotalSellValue,
                              showDecimal: false,
                              decimalNum: 2,
                            ),
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 5,),
                          const Text(
                            "Percent Left",
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            "${formatDecimalWithNull(
                              _brokerCollect!.summaryTotalLeft / _brokerCollect!.summaryTotalBuy,
                              times: 100,
                              decimal: 2
                            )} %",
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _generateList() {
    // if broker collection still null, just return sized box
    if (_brokerCollect == null) {
      return const SizedBox.shrink();
    }

    // if broker collection not null, then we can display the list view
    return Expanded(
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _filteredBrokcerCollectCompanyList.length,
        itemBuilder: ((context, index) {
          double avgPrice = (_filteredBrokcerCollectCompanyList[index].totalBuyValue - _filteredBrokcerCollectCompanyList[index].totalSellValue) / (_filteredBrokcerCollectCompanyList[index].totalLeft * 100);
          Color priceColor = primaryDark;
          if (avgPrice > _filteredBrokcerCollectCompanyList[index].lastPrice) {
            priceColor = Colors.green[900]!;
          }
          else if (avgPrice < _filteredBrokcerCollectCompanyList[index].lastPrice) {
            priceColor = secondaryDark;
          }

          return  Slidable(
            endActionPane: ActionPane(
              motion: const ScrollMotion(),
              extentRatio: 0.15,
              children: <Widget>[
                SlideButton(
                  icon: Ionicons.business_outline,
                  iconColor: extendedLight,
                  onTap: () {
                    _getCompanyDetailAndGo(code: _filteredBrokcerCollectCompanyList[index].code);
                  },
                ),
              ],
            ),
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(0, 0, 0, 10),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: primaryLight,
                    width: 1.0,
                    style: BorderStyle.solid,
                  ),
                )
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                    color: primaryDark,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Visibility(
                                visible: _filteredBrokcerCollectCompanyList[index].fca,
                                child: Container(
                                  padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                                  child: Icon(
                                    Ionicons.warning,
                                    size: 12,
                                    color: secondaryColor,
                                  ),
                                ),
                              ),
                              Text(
                                _filteredBrokcerCollectCompanyList[index].code,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: accentColor,
                                ),
                              ),
                              const SizedBox(width: 5,),
                              Expanded(
                                child: Text(
                                  _filteredBrokcerCollectCompanyList[index].name,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10,),
                        Container(
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: priceColor,
                                width: 2.0,
                                style: BorderStyle.solid,
                              )
                            ),
                          ),
                          child: Text(
                            formatIntWithNull(
                              _filteredBrokcerCollectCompanyList[index].lastPrice,
                              showDecimal: false,
                              decimalNum: 0,
                              shorten: false
                            ),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 5,),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              color: Colors.green,
                              padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                              child: const Center(
                                child: Text(
                                  "BUY",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.fromLTRB(10, 2, 10, 5),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  const Text(
                                    "Lot",
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    formatIntWithNull(
                                      _filteredBrokcerCollectCompanyList[index].totalBuy,
                                      showDecimal: false,
                                      decimalNum: 0,
                                      shorten: false
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12,
                                    ),
                                  ),
                                  const Text(
                                    "Value",
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    formatIntWithNull(
                                      _filteredBrokcerCollectCompanyList[index].totalBuyValue,
                                      checkThousand:false,
                                      showDecimal:false,
                                      decimalNum:0,
                                      shorten:false
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12,
                                    ),
                                  ),
                                  const Text(
                                    "AVG",
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    formatDecimalWithNull(
                                      _filteredBrokcerCollectCompanyList[index].totalBuyAvg,
                                      decimal: 2
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12,
                                    ),
                                  ),
                                  const Text(
                                    "Count",
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    "${formatIntWithNull(
                                      _filteredBrokcerCollectCompanyList[index].countBuy,
                                      checkThousand:false,
                                      showDecimal:false,
                                      decimalNum:0,
                                      shorten:false
                                    )}x",
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Container(
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
                            )
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                                color: secondaryColor,
                                child: const Center(
                                  child: Text(
                                    "SELL",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.fromLTRB(10, 2, 10, 5),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    const Text(
                                      "Lot",
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      formatIntWithNull(
                                        _filteredBrokcerCollectCompanyList[index].totalSell,
                                        showDecimal: false,
                                        decimalNum: 0,
                                        shorten: false
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 12,
                                      ),
                                    ),
                                    const Text(
                                      "Value",
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      formatIntWithNull(
                                        _filteredBrokcerCollectCompanyList[index].totalSellValue,
                                        showDecimal: false,
                                        decimalNum: 0,
                                        shorten: false
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 12,
                                      ),
                                    ),
                                    const Text(
                                      "AVG",
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      formatDecimalWithNull(
                                        _filteredBrokcerCollectCompanyList[index].totalSellAvg,
                                        decimal: 2
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 12,
                                      ),
                                    ),
                                    const Text(
                                      "Count",
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      "${formatIntWithNull(
                                        _filteredBrokcerCollectCompanyList[index].countSell,
                                        showDecimal: false,
                                        decimalNum: 0,
                                        shorten: false
                                      )}x",
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                              color: accentDark,
                              child: const Center(
                                child: Text(
                                  "LEFT",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 2,),
                            Container(
                              padding: const EdgeInsets.fromLTRB(10, 0, 10, 5),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  const Text(
                                    "Lot",
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    formatIntWithNull(
                                      _filteredBrokcerCollectCompanyList[index].totalLeft,
                                      showDecimal: false,
                                      decimalNum: 0,
                                      shorten: false
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12,
                                    ),
                                  ),
                                  const Text(
                                    "Value",
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    formatIntWithNull(
                                      _filteredBrokcerCollectCompanyList[index].totalBuyValue - _filteredBrokcerCollectCompanyList[index].totalSellValue,
                                      showDecimal: false,
                                      decimalNum: 0,
                                      shorten: false
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12,
                                    ),
                                  ),
                                  const Text(
                                    "AVG",
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    formatDecimalWithNull(
                                      avgPrice,
                                      decimal: 2
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12,
                                    ),
                                  ),
                                  const Text(
                                    "Percent Left",
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    "${formatDecimalWithNull(
                                      _filteredBrokcerCollectCompanyList[index].totalPercentage,
                                      times: 100,
                                      decimal: 2
                                    )} %",
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
          
        }),
      )
    );
  }

  Future<void> _showCalendar() async {
    if (_brokerCalendarType == CalendarType.day) {
      DateTimeRange? result = await showDateRangePicker(
        context: context,
        firstDate: _minBrokerDate.toLocal(),
        lastDate: _maxBrokerDate.toLocal(),
        initialDateRange: DateTimeRange(start: _fromDate.toLocal(), end: _toDate.toLocal()),
        confirmText: 'Done',
        currentDate: _maxBrokerDate.toLocal(),
        initialEntryMode: DatePickerEntryMode.calendarOnly,
      );

      // check if we got the result or not?
      if (result != null) {
        // check whether the result start and end is different date, if different then we need to get new broker summary data.
        if (
          (result.start.toLocal().compareTo(_fromDate.toLocal()) != 0) ||
          (result.end.toLocal().compareTo(_toDate.toLocal()) != 0)
        ) {                      
          // set the broker from and to date
          setState(() {
            _fromDate = result.start.toLocal();
            _toDate = result.end.toLocal();
          });
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
                firstDate: _minBrokerDate.toLocal(),
                lastDate: _maxBrokerDate.toLocal(),
                startDate: _fromDate.toLocal(),
                endDate: _toDate.toLocal(),
                type: MyYearPickerCalendarType.range,
                onChanged: (value) async {
                  // remove the dialog
                  Navigator.pop(context);
  
                  // check the new date whether it's same year or not?
                  if (
                    value.startDate.toLocal().compareTo(_fromDate.toLocal()) != 0 ||
                    value.endDate.toLocal().compareTo(_toDate.toLocal()) != 0
                  ) {
                    // set the broker from and to date
                    setState(() {                        
                      _fromDate = value.startDate;
                      _toDate = value.endDate;
                    });
                  }
                },
              ),
            ),
          );
        },
      );
    }
  }

  void _filterData() {
    // clear filter list data first
    _filteredBrokcerCollectCompanyList.clear();

    // check which filter currently active
    switch(_filterMode) {
      case "BL":
        // sort the broker collect company list by buy lot
        _filteredBrokcerCollectCompanyList.addAll(
          _brokerCollectCompanyList..sort((a, b) => b.totalBuy.compareTo(a.totalBuy))
        );
        break;
      case "BV":
        // sort the broker collect company list by buy value
        _filteredBrokcerCollectCompanyList.addAll(
          _brokerCollectCompanyList..sort((a, b) => b.totalBuyValue.compareTo(a.totalBuyValue))
        );
        break;
      case "BP":
        // sort the broker collect company list by buy price
        _filteredBrokcerCollectCompanyList.addAll(
          _brokerCollectCompanyList..sort((a, b) => (b.totalBuyValue / b.totalBuy).compareTo(a.totalBuyValue / a.totalBuy))
        );
        break;
      case "SL":
        // sort the broker collect company list by sell lot
        _filteredBrokcerCollectCompanyList.addAll(
          _brokerCollectCompanyList..sort((a, b) => b.totalSell.compareTo(a.totalSell))
        );
        break;
      case "SV":
        // sort the broker collect company list by sell value
        _filteredBrokcerCollectCompanyList.addAll(
          _brokerCollectCompanyList..sort((a, b) => b.totalSellValue.compareTo(a.totalSellValue))
        );
        break;
      case "SP":
        // sort the broker collect company list by sell price
        _filteredBrokcerCollectCompanyList.addAll(
          _brokerCollectCompanyList..sort((a, b) => (b.totalSellValue / b.totalSell).compareTo(a.totalSellValue / a.totalSell))
        );
        break;
      case "LL":
        // sort the broker collect company list by left lot
        _filteredBrokcerCollectCompanyList.addAll(
          _brokerCollectCompanyList..sort((a, b) => b.totalLeft.compareTo(a.totalLeft))
        );
        break;
      case "LV":
        // sort the broker collect company list by left value
        _filteredBrokcerCollectCompanyList.addAll(
          _brokerCollectCompanyList..sort((a, b) => (b.totalBuyValue - b.totalSellValue).compareTo(a.totalBuyValue - a.totalSellValue))
        );
        break;
      case "LP":
        // sort the broker collect company list by left price
        _filteredBrokcerCollectCompanyList.addAll(
          _brokerCollectCompanyList.where((element) => element.totalLeft > 0).toList()
            ..sort((a, b) => ((b.totalBuyValue - b.totalSellValue) / b.totalLeft).compareTo((a.totalBuyValue - a.totalSellValue) / a.totalLeft))
        );
        break;
      default:
        // sort the broker collect company list by code
        _filteredBrokcerCollectCompanyList.addAll(
          _brokerCollectCompanyList..sort((a, b) => b.code.compareTo(a.code))
        );
        break;
    }

    // check if the sort is ascending or descending
    if (_filterSort == SortBoxType.ascending) {
      // reverse the list
      _filteredBrokcerCollectCompanyList = List<BrokerCollectCompany>.from(
        _filteredBrokcerCollectCompanyList.reversed
      );
    }
  }

  Future<void> _getBrokerCollect() async {
    // show loading screen
    LoadingScreen.instance().show(context: context);

    // get the transaction
    await _insightAPI.getBrokerCollect(
      broker: _brokerCode,
      accumLimit: _accumRate,
      dateFrom: _fromDate.toLocal(),
      dateTo: _toDate.toLocal(),
    ).then((resp) async {
      // put the response to the broker collect
      _brokerCollect = resp;
      _brokerCollectCompanyList = (_brokerCollect?.data ?? []);
      _filterData();
      
      // store the broker collection query result to the shared preferences
      await InsightSharedPreferences.setBrokerCollect(
        brokerCollectList: _brokerCollect!,
        brokerId: _brokerCode,
        fromDate: _fromDate.toLocal(),
        toDate: _toDate.toLocal(),
        rate: _accumRate
      );
    }).onError((error, stackTrace) {
      Log.error(
        message: 'Error getting broker summary data',
        error: error,
        stackTrace: stackTrace,
      );

      throw Exception('Error when trying to get the broker summary data');
    }).whenComplete(() {
      // remove the loading screen
      LoadingScreen.instance().hide();
    },);
  }

  Future<void> _getCompanyDetailAndGo({required String code}) async {
    // show loading screen
    LoadingScreen.instance().show(context: context);

    // get the company detail and go
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
  }
}