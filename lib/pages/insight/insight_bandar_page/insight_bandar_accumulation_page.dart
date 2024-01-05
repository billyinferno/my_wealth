import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_wealth/api/broker_summary_api.dart';
import 'package:my_wealth/api/company_api.dart';
import 'package:my_wealth/api/insight_api.dart';
import 'package:my_wealth/model/broker/broker_summary_date_model.dart';
import 'package:my_wealth/model/insight/insight_accumulation_model.dart';
import 'package:my_wealth/themes/colors.dart';
import 'package:my_wealth/utils/arguments/company_detail_args.dart';
import 'package:my_wealth/utils/dialog/create_snack_bar.dart';
import 'package:my_wealth/utils/function/format_currency.dart';
import 'package:my_wealth/utils/loader/show_loader_dialog.dart';
import 'package:my_wealth/storage/prefs/shared_broker.dart';
import 'package:my_wealth/storage/prefs/shared_insight.dart';
import 'package:my_wealth/widgets/components/number_stepper.dart';
import 'package:my_wealth/widgets/list/column_info.dart';

class InsightBandarAccumulationPage extends StatefulWidget {
  const InsightBandarAccumulationPage({Key? key}) : super(key: key);

  @override
  State<InsightBandarAccumulationPage> createState() => _InsightBandarAccumulationPageState();
}

class _InsightBandarAccumulationPageState extends State<InsightBandarAccumulationPage> {
  final InsightAPI _insightAPI = InsightAPI();
  final BrokerSummaryAPI _brokerSummaryAPI = BrokerSummaryAPI();
  final CompanyAPI _companyAPI = CompanyAPI();

  final DateFormat _df = DateFormat('yyyy-MM-dd');
  final ScrollController _scrollController = ScrollController();

  late int _oneDayRate;
  late DateTime _fromDate;
  late DateTime _toDate;
  late DateTime _currentDate;
  late List<InsightAccumulationModel> _listAccumulation;
  late BrokerSummaryDateModel _brokerSummaryDate;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    // initialize the data we will use for query the accumulation
    _oneDayRate = InsightSharedPreferences.getTopAccumulationRate(); // default 8%
    _toDate = InsightSharedPreferences.getTopAccumulationToDate(); // today date
    _currentDate = _toDate; // today date
    _fromDate = InsightSharedPreferences.getTopAccumulationFromDate(); // 7 days before today
    _listAccumulation = InsightSharedPreferences.getTopAccumulationResult(); // empty list accumulation

    // once got then check if we got result or not? if got result then no need to query to server
    // we can display the one that already stored on the cache.

    if (_listAccumulation.isEmpty) {
      Future.microtask(() async {
        showLoaderDialog(context);

        // get the min and max broker summary date
        await _brokerSummaryAPI.getBrokerSummaryDate().then((resp) async {
          _brokerSummaryDate = resp;

          // check whether the toDate is more than maxDate, and whether fromDate is lesser than minDate
          if (_brokerSummaryDate.brokerMaxDate.isBefore(_toDate)) {
            _toDate = _brokerSummaryDate.brokerMaxDate.toLocal();
            // here todate should be current date, but since maxdate is lesser than today date
            // we will assume that current date is same as todate
            _currentDate = _toDate;

            // in case there are changes on the todate, we also need to perform the calculation
            // of from date, in case the from date is now after the to date.
            if (_fromDate.isAfter(_toDate)) {
              _fromDate = _toDate.add(const Duration(days: -7)); // 7 days before to date is the from date is passed the to date
            }
          }

          // check if the broker minimum date is after the from date, if so, then change the from date to
          // broker minimum date.
          if (_brokerSummaryDate.brokerMinDate.isAfter(_fromDate)) {
            _fromDate = _brokerSummaryDate.brokerMinDate.toLocal();
          }

          await BrokerSharedPreferences.setBrokerMinMaxDate(_brokerSummaryDate.brokerMinDate, _brokerSummaryDate.brokerMaxDate);
        });

        // get the accumulation list
        await _insightAPI.getTopAccumulation(_oneDayRate, _fromDate, _toDate).then((resp) async {
          _listAccumulation = resp;

          // stored all the data to shared preferences
          await InsightSharedPreferences.setTopAccumulation(_fromDate, _toDate, _oneDayRate, _listAccumulation);
        });
      }).whenComplete(() {
        // remove the loader
        Navigator.pop(context);

        // then set the isloading state into false
        _setLoading(false);
      });
    }
    else {
      // already got the data, so we can just get the broker min max date from the shared preferences
      DateTime brokerMinDate = BrokerSharedPreferences.getBrokerMinDate()!;
      DateTime brokerMaxDate = BrokerSharedPreferences.getBrokerMaxDate()!;

      _brokerSummaryDate = BrokerSummaryDateModel(brokerMinDate: brokerMinDate, brokerMaxDate: brokerMaxDate);
      
      // then set the isloading state into false
      _setLoading(false);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // if loading then just show that we are loading the data
    if (_isLoading) {
      return const Center(child: Text("Loading data"),);
    }

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
                            _df.format(_fromDate),
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
                            _df.format(_toDate),
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
                      "One Day",
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
                      initialRate: _oneDayRate,
                      onTap: ((newRate) {
                        _oneDayRate = newRate;
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
              await _insightAPI.getTopAccumulation(_oneDayRate, _fromDate, _toDate).then((resp) async {
                // stored all the data to shared preferences
                await InsightSharedPreferences.setTopAccumulation(_fromDate, _toDate, _oneDayRate, resp);

                setState(() {
                  _listAccumulation = resp;
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
              itemCount: _listAccumulation.length,
              itemBuilder: ((context, index) {
                return InkWell(
                  onTap: (() async {
                    showLoaderDialog(context);
                    await _companyAPI.getCompanyByCode(_listAccumulation[index].code, 'saham').then((resp) {
                      CompanyDetailArgs args = CompanyDetailArgs(
                        companyId: resp.companyId,
                        companyName: resp.companyName,
                        companyCode: _listAccumulation[index].code,
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
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: primaryLight,
                          width: 1.0,
                          style: BorderStyle.solid,
                        )
                      )
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              _listAccumulation[index].code,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: accentColor,
                              ),
                            ),
                            const Expanded(child: SizedBox()),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            Text(
                              formatIntWithNull(_listAccumulation[index].lastPrice, false, false),
                            ),
                            const SizedBox(width: 5,),
                            Text(
                              '(${formatDecimalWithNull(_listAccumulation[index].oneDay, 100, 2)}%)',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.green
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5,),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            ColumnInfo(
                              title: 'Buy',
                              titleColor: Colors.green,
                              value: formatIntWithNull(_listAccumulation[index].buyLot, false, false, 0, false),
                              valueSize: 15,
                            ),
                            ColumnInfo(
                              title: 'Sell',
                              titleColor: secondaryColor,
                              value: formatIntWithNull(_listAccumulation[index].sellLot, false, false, 0, false),
                              valueSize: 15,
                            ),
                            ColumnInfo(
                              title: 'Diff',
                              value: formatIntWithNull(_listAccumulation[index].diff, false, false, 0, false),
                              valueSize: 15,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              })
            ),
          ),
        ],
      ),
    );
  }

  void _setLoading(bool value) {
    setState(() {
      _isLoading = value;
    });
  }

  Future<void> _showCalendar() async {
    DateTimeRange? result = await showDateRangePicker(
      context: context,
      firstDate: _brokerSummaryDate.brokerMinDate.toLocal(),
      lastDate: _brokerSummaryDate.brokerMaxDate.toLocal(),
      initialDateRange: DateTimeRange(start: _fromDate.toLocal(), end: _toDate.toLocal()),
      confirmText: 'Done',
      currentDate: _currentDate.toLocal(),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
    );

    // check if we got the result or not?
    if (result != null) {
      // check whether the result start and end is different date, if different then we need to get new broker summary data.
      if ((result.start.compareTo(_fromDate) != 0) || (result.end.compareTo(_toDate) != 0)) {                      
        // set the broker from and to date
        setState(() {
          _fromDate = result.start;
          _toDate = result.end;
        });
      }
    }
  }
}