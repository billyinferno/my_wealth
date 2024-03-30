import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:my_wealth/api/insight_api.dart';
import 'package:my_wealth/model/insight/insight_stock_collect_model.dart';
import 'package:my_wealth/storage/prefs/shared_broker.dart';
import 'package:my_wealth/storage/prefs/shared_insight.dart';
import 'package:my_wealth/themes/colors.dart';
import 'package:my_wealth/utils/dialog/create_snack_bar.dart';
import 'package:my_wealth/utils/globals.dart';
import 'package:my_wealth/utils/loader/show_loader_dialog.dart';
import 'package:my_wealth/widgets/components/number_stepper.dart';
import 'package:my_wealth/widgets/list/stock_collect_expanded.dart';

class InsightBandarStockCollectPage extends StatefulWidget {
  const InsightBandarStockCollectPage({Key? key}) : super(key: key);

  @override
  State<InsightBandarStockCollectPage> createState() => InsightBandarStockCollectPageState();
}

class InsightBandarStockCollectPageState extends State<InsightBandarStockCollectPage> {
  final InsightAPI _insightAPI = InsightAPI();
  final ScrollController _scrollController = ScrollController();

  late DateTime? _minBrokerDate;
  late DateTime? _maxBrokerDate;
  late DateTime? _fromDate;
  late DateTime? _toDate;
  late int _accumRate;
  late List<InsightStockCollectModel>? _stockCollectList;
  late Future<bool> _getData;

  @override
  void initState() {
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
    _fromDate = InsightSharedPreferences.getStockCollectDate('from');
    _toDate = InsightSharedPreferences.getStockCollectDate('to');

    // check if we got null?
    // if got null, it means that we will defaulted the toDate to the maxBrokerDate
    // and fromDate is -14 days of maxBrokerDate
    if (_fromDate == null || _toDate == null) {
      _toDate = _maxBrokerDate;
      _fromDate = _toDate!.add(const Duration(days: -14));
    }

    // get the accumulation rate
    _accumRate = InsightSharedPreferences.getStockCollectAccumulationRate();

    // get the stock collect list from shared preferences
    _getData = _initGetData();

    super.initState();
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
          return _commonError(errorText: 'Error loading stock collection data');
        }
        else if (snapshot.hasData) {
          return _generatePage();
        }
        else {
          return _commonLoading();
        }
      })
    );
  }

  Widget _generatePage() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
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
                      "From",
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
                      child: Container(
                        height: 30,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: primaryLight,
                            width: 1.0,
                            style: BorderStyle.solid
                          ),
                          color: primaryDark,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Center(
                          child: Text(
                            Globals.dfyyyyMMdd.format(_fromDate!),
                            style: const TextStyle(
                              color: textPrimary,
                            ),
                          ),
                        ),
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
                      "To",
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
                      child: Container(
                        height: 30,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: primaryLight,
                            width: 1.0,
                            style: BorderStyle.solid
                          ),
                          color: primaryDark,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Center(
                          child: Text(
                            Globals.dfyyyyMMdd.format(_toDate!),
                            style: const TextStyle(
                              color: textPrimary,
                            ),
                          ),
                        ),
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
                      "Accum Rate",
                      style: TextStyle(
                        color: accentColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5,),
                    NumberStepper(
                      height: 30,
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
            ],
          ),
          const SizedBox(height: 10,),
          InkWell(
            onTap: (() async {
              // get the accumulation result from the insight API
              showLoaderDialog(context);
              
              await _insightAPI.getStockCollect(_accumRate, _fromDate, _toDate).then((resp) {      
                // set the collection list as resp
                setState(() {
                  _stockCollectList!.clear();
                  _stockCollectList!.addAll(resp);
                  
                  // stored the response to the insight preferences
                  InsightSharedPreferences.setStockCollect(_stockCollectList!, _fromDate!, _toDate!, _accumRate);
                });
              }).onError((error, stackTrace) {
                debugPrintStack(stackTrace: stackTrace);
                ScaffoldMessenger.of(context).showSnackBar(createSnackBar(message: "Error when trying to get accumulation data"));
              }).whenComplete(() {
                // remove the loader
                Navigator.pop(context);
              });
            }),
            child: Container(
              height: 30,
              width: double.infinity,
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: primaryDark,
                border: Border.all(
                  color: primaryLight,
                  width: 1.0,
                  style: BorderStyle.solid
                )
              ),
              child: const Center(
                child: Text(
                  "Show Result",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                )
              ),
            ),
          ),
          const SizedBox(height: 10,),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: _stockCollectList!.length,
              itemBuilder: (
                (context, index) {
                  return StockCollectExpanded(
                    data: _stockCollectList![index]
                    );
                }
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _commonLoading() {
    return const Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SpinKitCubeGrid(
              color: secondaryColor,
              size: 25,
            ),
            SizedBox(height: 5,),
            Text(
              "Loading data...",
              style: TextStyle(
                color: secondaryColor,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _commonError({required String errorText}) {
    return Container(
      width: double.infinity,
      color: primaryColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          const SizedBox(height: 5,),
          Text(
            errorText,
            style: const TextStyle(
              color: secondaryColor,
              fontSize: 10,
            ),
          ),
        ],
      ),
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

  Future<bool> _initGetData() async {
    try {
      // try to get the stock collect list data from shared preferences
      _stockCollectList = InsightSharedPreferences.getStockCollect();

      // check if this is empty or not?
      if (_stockCollectList!.isEmpty) {
        // no stock collection data, means this is the first time
        // so we call the API and stored the stock collection data to the
        // shared preferences for next use
        await _insightAPI.getStockCollect(_accumRate, _fromDate, _toDate).then((resp) {
          _stockCollectList!.clear();
          _stockCollectList!.addAll(resp);
          
          // stored the response to the insight preferences
          InsightSharedPreferences.setStockCollect(_stockCollectList!, _fromDate!, _toDate!, _accumRate);
        });
      }

      // already got the data show the page
      return true;
    }
    catch(error) {
      debugPrint(error.toString());
      throw 'Error when try to get the stock collection data from server';
    }
  }
}