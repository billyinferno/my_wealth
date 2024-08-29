import 'package:flutter/material.dart';
import 'package:my_wealth/_index.g.dart';

class InsightBandarAccumulationPage extends StatefulWidget {
  const InsightBandarAccumulationPage({super.key});

  @override
  State<InsightBandarAccumulationPage> createState() => _InsightBandarAccumulationPageState();
}

class _InsightBandarAccumulationPageState extends State<InsightBandarAccumulationPage> {
  final InsightAPI _insightAPI = InsightAPI();
  final BrokerSummaryAPI _brokerSummaryAPI = BrokerSummaryAPI();
  final CompanyAPI _companyAPI = CompanyAPI();

  final ScrollController _scrollController = ScrollController();

  // sort helper
  late String _filterMode;
  late String _filterSort;
  final Map<String, String> _filterList = {};

  late int _oneDayRate;
  late DateTime _fromDate;
  late DateTime _toDate;
  late DateTime _currentDate;
  late List<InsightAccumulationModel> _listAccumulation;
  late BrokerSummaryDateModel _brokerSummaryDate;

  late Future<bool> _getData;

  @override
  void initState() {
    // initialize the data we will use for query the accumulation
    _oneDayRate = InsightSharedPreferences.getTopAccumulationRate(); // default 8%
    _toDate = InsightSharedPreferences.getTopAccumulationToDate(); // today date
    _currentDate = _toDate; // today date
    _fromDate = InsightSharedPreferences.getTopAccumulationFromDate(); // 7 days before today
    _listAccumulation = InsightSharedPreferences.getTopAccumulationResult(); // empty list accumulation

    // list all the filter that we want to put here
    _filterList["pr"] = "Price";
    _filterList["1d"] = "One Day";
    _filterList["by"] = "Buy Lot";
    _filterList["sl"] = "Sell Lot";
    _filterList["df"] = "Diff";

    // default filter mode to Code and ASC
    _filterMode = "df";
    _filterSort = "DESC";

    // get the data either from server or cache
    _getData = _getInitData();

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
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const CommonErrorPage(
            errorText: 'Error loading bandar accumulation page',
            isNeedScaffold: false,
          );
        }
        else if (snapshot.hasData) {
          return _body();
        }
        else {
          return const CommonLoadingPage(isNeedScaffold: false,);
        }
      },
    );
  }

  Widget _body() {
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
                            Globals.dfyyyyMMdd.format(_fromDate),
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
                            Globals.dfyyyyMMdd.format(_toDate),
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
              // show loading screen
              LoadingScreen.instance().show(context: context);

              // get the accumulation result from the insight API
              await _insightAPI.getTopAccumulation(
                oneDayRate: _oneDayRate,
                fromDate: _fromDate,
                toDate: _toDate,
              ).then((resp) async {
                // stored all the data to shared preferences
                await InsightSharedPreferences.setTopAccumulation(
                  fromDate: _fromDate,
                  toDate: _toDate,
                  rate: _oneDayRate,
                  accum: resp
                );

                setState(() {
                  _listAccumulation = resp;
                });
              }).onError((error, stackTrace) {
                Log.error(
                  message: 'Error getting accumulation data',
                  error: error,
                  stackTrace: stackTrace,
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    createSnackBar(
                      message: "Error when trying to get accumulation data"
                    )
                  );
                }
              }).whenComplete(() {
                // remove the loading screen
                LoadingScreen.instance().hide();
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
          Visibility(
            visible: _listAccumulation.isNotEmpty,
            child: SearchBox(
              filterMode: _filterMode,
              filterList: _filterList,
              filterSort: _filterSort,
              bgColor: Colors.transparent,
              onFilterSelect: ((newFilter) {
                if (newFilter != _filterMode) {
                  setState(() {
                    _filterMode = newFilter;
                    _filterData();
                  });
                }
              }),
              onSortSelect: ((newSort) {
                if (newSort != _filterSort) {
                  setState(() {
                    _filterSort = newSort;
                    _sortData();
                  });
                }
              }),
            ),
          ),
          const SizedBox(height: 10,),
          Expanded(
            child: ListView.builder(
              itemCount: _listAccumulation.length,
              itemBuilder: ((context, index) {
                return InkWell(
                  onTap: (() {
                    _getCompanyDetailAndGo(code: _listAccumulation[index].code);
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
                            const SizedBox(width: 5,),
                            Expanded(
                              child: Text(
                                _listAccumulation[index].name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10,),
                            Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: primaryDark,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  Text(
                                    formatIntWithNull(
                                      _listAccumulation[index].lastPrice,
                                      checkThousand: false,
                                      showDecimal: false
                                    ),
                                  ),
                                  Text(
                                    '(${formatDecimalWithNull(
                                      _listAccumulation[index].oneDay,
                                      times: 100,
                                      decimal: 2
                                    )}%)',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.green
                                    ),
                                  ),
                                ],
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
                              value: formatIntWithNull(
                                _listAccumulation[index].buyLot,
                                checkThousand: false,
                                showDecimal: false,
                                decimalNum: 0,
                                shorten: false
                              ),
                              valueSize: 15,
                            ),
                            ColumnInfo(
                              title: 'Sell',
                              titleColor: secondaryColor,
                              value: formatIntWithNull(
                                _listAccumulation[index].sellLot,
                                checkThousand: false,
                                showDecimal: false,
                                decimalNum: 0,
                                shorten: false,
                              ),
                              valueSize: 15,
                            ),
                            ColumnInfo(
                              title: 'Diff',
                              value: formatIntWithNull(
                                _listAccumulation[index].diff,
                                checkThousand: false,
                                showDecimal: false,
                                decimalNum: 0,
                                shorten: false,
                              ),
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

  void _filterData() {
    // create a temporary list to contain all the result from filter
    List<InsightAccumulationModel> tempFilter = List<InsightAccumulationModel>.from(_listAccumulation);
    
    // check which filter mode is being selected
    switch(_filterMode) {
      case "1d":
        tempFilter.sort(((a, b) => ((a.oneDay)).compareTo((b.oneDay))));
        break;
      case "by":
        tempFilter.sort(((a, b) => ((a.buyLot)).compareTo((b.buyLot))));
        break;
      case "sl":
        tempFilter.sort(((a, b) => ((a.sellLot)).compareTo((b.sellLot))));
        break;
      case "df":
        tempFilter.sort(((a, b) => ((a.diff)).compareTo((b.diff))));
        break;
      case "pr":
      default:
        tempFilter.sort(((a, b) => (a.lastPrice).compareTo((b.lastPrice))));
        break;
    }

    // clear the sorted list
    _listAccumulation.clear();

    // check the filter type
    if (_filterSort == "ASC") {
      _listAccumulation = List<InsightAccumulationModel>.from(tempFilter);
    }
    else {
      _listAccumulation = List<InsightAccumulationModel>.from(tempFilter.reversed);
    }
  }

  void _sortData() {
    // regardless the data just reverse the current result
    _listAccumulation = _listAccumulation.reversed.toList();
  }

  Future<bool> _getInitData() async {
    // once got then check if we got result or not? if got result then no need to query to server
    // we can display the one that already stored on the cache.
    if (_listAccumulation.isEmpty) {
      // get the data from server
      await Future.microtask(() async {
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

          await BrokerSharedPreferences.setBrokerMinMaxDate(
            minDate: _brokerSummaryDate.brokerMinDate,
            maxDate: _brokerSummaryDate.brokerMaxDate
          );
        }).onError((error, stackTrace) {
          Log.error(
            message: 'Error getting broker summary date',
            error: error,
            stackTrace: stackTrace,
          );

          throw Exception('Error when get broker summary date');
        },);

        // get the accumulation list
        await _insightAPI.getTopAccumulation(
          oneDayRate: _oneDayRate,
          fromDate: _fromDate,
          toDate: _toDate,
        ).then((resp) async {
          _listAccumulation = resp;

          // stored all the data to shared preferences
          await InsightSharedPreferences.setTopAccumulation(
            fromDate: _fromDate,
            toDate: _toDate,
            rate: _oneDayRate,
            accum: _listAccumulation
          );
        }).onError((error, stackTrace) {
          Log.error(
            message: 'Error getting broker top accumulation',
            error: error,
            stackTrace: stackTrace,
          );

          throw Exception('Error when get top accumulation');
        },);
      });
    }
    else {
      // already got the data, so we can just get the broker min max date from the shared preferences
      DateTime brokerMinDate = BrokerSharedPreferences.getBrokerMinDate()!;
      DateTime brokerMaxDate = BrokerSharedPreferences.getBrokerMaxDate()!;

      _brokerSummaryDate = BrokerSummaryDateModel(brokerMinDate: brokerMinDate, brokerMaxDate: brokerMaxDate);
    }

    return true;
  }

  Future<void> _getCompanyDetailAndGo({required String code}) async {
    // show the loading screen
    LoadingScreen.instance().show(context: context);

    // get the company detail information
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