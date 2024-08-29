import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
  
  late BrokerModel _brokerData;
  late String _brokerCode;
  late DateTime? _minBrokerDate;
  late DateTime? _maxBrokerDate;
  late DateTime? _fromDate;
  late DateTime? _toDate;
  late int _accumRate;
  late InsightBrokerCollectModel? _brokerCollect;

  @override
  void initState() {
    super.initState();

    // initialize broker code
    _brokerCode = InsightSharedPreferences.getBrokerCollectID();
    
    // get the minimum and maximum broker date
    _minBrokerDate = BrokerSharedPreferences.getBrokerMinDate();
    _maxBrokerDate = BrokerSharedPreferences.getBrokerMaxDate();

    // ensure min and max broker date is not null
    if (_minBrokerDate == null || _maxBrokerDate == null) {
      // assume the max broker date is today
      _maxBrokerDate = DateTime.now();
      _minBrokerDate = _maxBrokerDate!.add(const Duration(days: -14));
    }

    // get the from and to date
    _fromDate = InsightSharedPreferences.getBrokerCollectDate(type: 'from');
    _toDate = InsightSharedPreferences.getBrokerCollectDate(type: 'to');

    // check if we got null?
    // if got null, it means that we will defaulted the toDate to the maxBrokerDate
    // and fromDate is -14 days of maxBrokerDate
    if (_fromDate == null || _toDate == null) {
      _toDate = _maxBrokerDate;
      _fromDate = _toDate!.add(const Duration(days: -14));
    }

    // get the accumulation rate
    _accumRate = InsightSharedPreferences.getBrokerCollectAccumulationRate();

    // get the broker collection
    _brokerCollect = InsightSharedPreferences.getBrokerCollect();
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
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                                          Globals.dfddMMyy.format(_fromDate!),
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
                                          Globals.dfddMMyy.format(_toDate!),
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
                      if (_brokerCode.isEmpty) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return CupertinoAlertDialog(
                              title: const Text("Select Broker"),
                              content: const Text("Please select broker from the list, before run the query."),
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
                            ScaffoldMessenger.of(context).showSnackBar(createSnackBar(message: "Error when trying to get the broker summary data", icon: const Icon(Ionicons.warning, size: 12,)));
                          }
                        },);
                      }
                    }),
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: primaryDark,
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
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
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
              color: secondaryColor,
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
          const SizedBox(height: 10,),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        "BUY",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 10,),
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
                          checkThousand: false,
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
                          checkThousand: false,
                          showDecimal: false,
                          decimalNum: 2,
                          shorten: true
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
                          checkThousand: false,
                          showDecimal: false,
                          decimalNum: 0,
                          shorten: false
                        )}x",
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 5,),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
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
                      const Text(
                        "SELL",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: secondaryColor,
                        ),
                      ),
                      const SizedBox(height: 10,),
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
                          checkThousand: false,
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
                          checkThousand: false,
                          showDecimal: false,
                          decimalNum: 2,
                          shorten: true
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
                          checkThousand: false,
                          showDecimal: false,
                          decimalNum: 0,
                          shorten: false
                        )}x",
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 5,),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        "LEFT",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: accentColor,
                        ),
                      ),
                      const SizedBox(height: 10,),
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
                          checkThousand: false,
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
                          checkThousand: false,
                          showDecimal: false,
                          decimalNum: 2,
                          shorten: true
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
                      const SizedBox(height: 5,),
                    ],
                  ),
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
        itemCount: _brokerCollect!.data.length,
        itemBuilder: ((context, index) {
          double avgPrice = (_brokerCollect!.data[index].totalBuyValue - _brokerCollect!.data[index].totalSellValue) / (_brokerCollect!.data[index].totalLeft * 100);
          Color priceColor = primaryDark;
          if (avgPrice > _brokerCollect!.data[index].lastPrice) {
            priceColor = Colors.green[900]!;
          }
          else if (avgPrice < _brokerCollect!.data[index].lastPrice) {
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
                    _getCompanyDetailAndGo(code: _brokerCollect!.data[index].code);
                  },
                ),
              ],
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
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
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            "${_brokerCollect!.data[index].code} - ${_brokerCollect!.data[index].name}",
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10,),
                        Container(
                          height: 20,
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: priceColor,
                          ),
                          child: Text(
                            formatIntWithNull(
                              _brokerCollect!.data[index].lastPrice,
                              checkThousand: false,
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
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              const Text(
                                "BUY",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              const SizedBox(height: 2,),
                              const Text(
                                "Lot",
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                formatIntWithNull(
                                  _brokerCollect!.data[index].totalBuy,
                                  checkThousand: false,
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
                                  _brokerCollect!.data[index].totalBuyValue,
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
                                  _brokerCollect!.data[index].totalBuyAvg,
                                  times: 1,
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
                                  _brokerCollect!.data[index].countBuy,
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
                      ),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
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
                              const Text(
                                "SELL",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: secondaryColor,
                                ),
                              ),
                              const SizedBox(height: 2,),
                              const Text(
                                "Lot",
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                formatIntWithNull(
                                  _brokerCollect!.data[index].totalSell,
                                  checkThousand: false,
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
                                  _brokerCollect!.data[index].totalSellValue,
                                  checkThousand: false,
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
                                  _brokerCollect!.data[index].totalSellAvg,
                                  times: 1,
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
                                  _brokerCollect!.data[index].countSell,
                                  checkThousand: false,
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
                      ),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              const Text(
                                "LEFT",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: accentColor,
                                ),
                              ),
                              const SizedBox(height: 2,),
                              const Text(
                                "Lot",
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                formatIntWithNull(
                                  _brokerCollect!.data[index].totalLeft,
                                  checkThousand: false,
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
                                  _brokerCollect!.data[index].totalBuyValue - _brokerCollect!.data[index].totalSellValue,
                                  checkThousand: false,
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
                                  times: 1,
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
                                  _brokerCollect!.data[index].totalPercentage,
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
    DateTimeRange? result = await showDateRangePicker(
      context: context,
      firstDate: _minBrokerDate!.toLocal(),
      lastDate: _maxBrokerDate!.toLocal(),
      initialDateRange: DateTimeRange(start: _fromDate!.toLocal(), end: _toDate!.toLocal()),
      confirmText: 'Done',
      currentDate: _maxBrokerDate!.toLocal(),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
    );

    // check if we got the result or not?
    if (result != null) {
      // check whether the result start and end is different date, if different then we need to get new broker summary data.
      if ((result.start.compareTo(_fromDate!) != 0) || (result.end.compareTo(_toDate!) != 0)) {                      
        // set the broker from and to date
        setState(() {
          _fromDate = result.start;
          _toDate = result.end;
        });
      }
    }
  }

  Future<void> _getBrokerCollect() async {
    // show loading screen
    LoadingScreen.instance().show(context: context);

    // get the transaction
    await _insightAPI.getBrokerCollect(
      broker: _brokerCode,
      accumLimit: _accumRate,
      dateFrom: _fromDate,
      dateTo: _toDate,
    ).then((resp) async {
      // put the response to the broker collect
      _brokerCollect = resp;
      
      // stre the broker collection query result to the shared preferences
      await InsightSharedPreferences.setBrokerCollect(
        brokerCollectList: _brokerCollect!,
        brokerId: _brokerCode,
        fromDate: _fromDate!,
        toDate: _toDate!,
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