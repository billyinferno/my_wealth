import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:my_wealth/_index.g.dart';

class WatchlistCalendarPage extends StatefulWidget {
  final Object? args;
  const WatchlistCalendarPage({super.key, required this.args});

  @override
  State<WatchlistCalendarPage> createState() => _WatchlistCalendarPageState();
}

class _WatchlistCalendarPageState extends State<WatchlistCalendarPage> {
  final ScrollController _scrollController = ScrollController();
  final ScrollController _scrollYearController = ScrollController();

  final WatchlistAPI _watchlistAPI = WatchlistAPI();

  late UserLoginInfoModel _userInfo;
  late DateTime _firstDate;
  late DateTime _endDate;
  late WatchlistListArgs _watchlistArgs;
  late WatchlistComputationResult _watchlistComputation;
  late CompanyDetailArgs _companyArgs;

  late String _calendarSelection;
  late DateTime _currentDate;

  late Future<bool> _getData;
  late Map<DateTime, List<CalendarDatePL>> _monthYearCalendarPLMap;
  late Map<DateTime, List<CalendarDatePL>> _yearCalendarPLMap;
  late List<CalendarDatePL> _monthYearCalendarPL;
  late List<CalendarDatePL> _yearCalendarPL;

  late double _plTotal;
  late Color _plTotalColor;
  late double _plRatio;
  late Color _plRatioColor;

  late double _plTotalYear;
  late Color _plTotalYearColor;
  late double _plRatioYear;
  late Color _plRatioYearColor;

  @override
  void initState() {
    super.initState();

    // get the user information
    _userInfo = UserSharedPreferences.getUserInfo()!;

    // Initialize first and end date as today's date.
    // we will assign the correct first and end date after we received the
    // response from API.
    _firstDate = DateTime.now();
    _endDate = DateTime.now();

    // convert the args to watchlist args
    _watchlistArgs = widget.args as WatchlistListArgs;

    // set the company args so we can navigate to company detail page
    _companyArgs = CompanyDetailArgs(
      companyId: _watchlistArgs.watchList.watchlistCompanyId,
      companyName: _watchlistArgs.watchList.watchlistCompanyName,
      companyCode: _watchlistArgs.watchList.watchlistCompanySymbol ?? '',
      companyFavourite: (_watchlistArgs.watchList.watchlistFavouriteId > 0 ? true : false),
      favouritesId: _watchlistArgs.watchList.watchlistFavouriteId,
      type: _watchlistArgs.type
    );

    // default the calendar selection to month
    _calendarSelection = "m";

    // default calendar selection to this month and year
    _currentDate = DateTime.now();

    // get the computation for the watchlist
    _watchlistComputation = detailWatchlistComputation(
      watchlist: _watchlistArgs.watchList, riskFactor: _userInfo.risk
    );

    // initialize pl month and year
    _plTotal = 0;
    _plRatio = 0;
    _plTotalColor = primaryLight;
    _plRatioColor = primaryLight;

    // initialize pl year
    _plTotalYear = 0;
    _plRatioYear = 0;
    _plTotalYearColor = primaryLight;
    _plRatioYearColor = primaryLight;

    // default to empty calendar PL map
    _monthYearCalendarPLMap = {};
    _yearCalendarPLMap = {};

    // initialize the calendar PL
    _monthYearCalendarPL = [];
    _yearCalendarPL = [];

    // get the data from API
    _getData = _getInitData(
      currentDate: _currentDate,
      newDate: null,
      showLoader: true
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _scrollYearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getData,
      builder: ((context, snapshot) {
        if (snapshot.hasError) {
          return const CommonErrorPage(errorText: 'Error loading watchlist performance');
        } else if (snapshot.hasData) {
          return _generatePage();
        } else {
          return const CommonLoadingPage();
        }
      }
    ));
  }

  Widget _generatePage() {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: (() {
            // return back to the previous page
            Navigator.pop(context);
          }),
          icon: const Icon(
            Ionicons.arrow_back,
          ),
        ),
        actions: <Widget>[
          IconButton(
            onPressed: (() {
              Navigator.pushNamed(context, '/company/detail/${_watchlistArgs.type}', arguments: _companyArgs);
            }),
            icon: const Icon(Ionicons.business_outline),
          ),
        ],
        title: const Center(
          child: Text(
            "Performance Calendar",
            style: TextStyle(
              color: secondaryColor,
            ),
          )
        ),
      ),
      body: MySafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            _summaryBoxInfo(),
            const SizedBox(height: 15,),
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        SizedBox(
                          width: 150,
                          child: CupertinoSegmentedControl(
                            children: const {
                              "m": Text("Month"),
                              "y": Text("Year"),
                            },
                            onValueChanged: (<String>(value) {
                              setState(() {
                                _calendarSelection = value;
                              });
                            }),
                            groupValue: _calendarSelection,
                            selectedColor: secondaryColor,
                            borderColor: secondaryDark,
                            pressedColor: primaryDark,
                          ),
                        ),
                        _dateSelector(),
                      ],
                    ),
                    const SizedBox(height: 15,),
                    _getSubPage(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryBoxInfo() {
    Color color = textPrimary;
    IconData iconToUsed = Ionicons.remove_outline;
    double? avgPrice;

    // get the icon and color that we will used on the page
    if (_watchlistComputation.priceDiff > 0) {
      color = Colors.green;
      iconToUsed = Ionicons.caret_up;
    }
    else if (_watchlistComputation.priceDiff < 0) {
      color = secondaryColor;
      iconToUsed = Ionicons.caret_down;
    }

    // check whether we need to calculate the average price or not?
    if (_watchlistComputation.totalCurrentShares > 0 ) {
      avgPrice = _watchlistComputation.totalCost / _watchlistComputation.totalCurrentShares;
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 10,
            color: _watchlistComputation.riskColor,
          ),
          Expanded(
            child: Container(
              color: primaryDark,
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text(
                    _watchlistArgs.watchList.watchlistCompanyName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            formatCurrencyWithNull(
                              _watchlistArgs.watchList.watchlistCompanyNetAssetValue,
                              shorten: false,
                              decimalNum: 2
                            ),
                          ),
                          const SizedBox(width: 5,),
                          Icon(
                            iconToUsed,
                            color: color,
                            size: 15,
                          ),
                          const SizedBox(width: 5,),
                          Container(
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: color,
                                  width: 2.0,
                                  style: BorderStyle.solid,
                                )
                              )
                            ),
                            child: Text(
                              formatCurrencyWithNull(
                                _watchlistComputation.priceDiff,
                                shorten: false,
                                decimalNum: 2
                              ),
                            ),
                          )
                        ],
                      ),
                      const Expanded(child: SizedBox()),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          const Icon(
                            Ionicons.time_outline,
                            color: primaryLight,
                            size: 15,
                          ),
                          const SizedBox(width: 5,),
                          Text(
                            Globals.dfddMMyyyy.formatDateWithNull(
                              _watchlistArgs.watchList.watchlistCompanyLastUpdate
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8,),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      RowChild(
                        headerText: "AVG PRICE",
                        value: avgPrice
                      ),
                      const SizedBox(width: 10,),
                      RowChild(
                        headerText: "COST",
                        value: _watchlistComputation.totalCost
                      ),
                      const SizedBox(width: 10,),
                      RowChild(
                        headerText: "VALUE",
                        value: _watchlistComputation.totalValue
                      ),
                    ],
                  ),
                  const SizedBox(height: 5,),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      RowChild(
                        headerText: "SHARES",
                        value: _watchlistComputation.totalCurrentShares,
                      ),
                      const SizedBox(width: 10,),
                      RowChild(
                        headerText: "UNREALISED",
                        value: _watchlistComputation.totalUnrealisedGain,
                        autoColor: true,
                      ),
                      const SizedBox(width: 10,),
                      RowChild(
                        headerText: "REALISED",
                        value: _watchlistComputation.totalRealisedGain,
                        autoColor: true,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dateSelector() {
    if (_calendarSelection == "m") {
      return Container(
        width: 100,
        height: 20,
        padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
        child: GestureDetector(
          onTap: (() {
            showMonthPicker(
              context: context,
              initialDate: _currentDate,
              firstDate: _firstDate,
              lastDate: _endDate,
            ).then((newDate) {
              if (newDate != null) {
                setState(() {
                  // get the data from the map
                  _monthYearCalendarPL = (_monthYearCalendarPLMap[newDate] ?? []);
                  _yearCalendarPL = (_yearCalendarPLMap[DateTime(newDate.year, 1, 1)] ?? []);

                  // calculate again the pl total for all the data
                  _calculateMonthYearPLTotal();
                  _calculateYearPLTotal();
                  
                  // set new date as current date, in case the same it will not
                  // matter also.
                  _currentDate = newDate;
                });
              }
            });
          }),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Text(Globals.dfyyyyMM.formatLocal(_currentDate)),
              const SizedBox(width: 5,),
              const Icon(
                Ionicons.caret_down_sharp,
                color: primaryLight,
                size: 10,
              ),
            ],
          ),
        )
      );
    } else {
      return Container(
        width: 100,
        height: 20,
        padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
        child: GestureDetector(
          onTap: (() {
            showDialog(
              context: context,
              builder: ((context) {
                return AlertDialog(
                  title: const Text("Select Year"),
                  content: SizedBox(
                    width: 300,
                    height: 300,
                    child: YearPicker(
                      firstDate: _firstDate,
                      lastDate: _endDate,
                      selectedDate: _currentDate,
                      onChanged: ((newDate) {
                        // remove the dialog
                        Navigator.pop(context);

                        // set state and get the data if the selected year is
                        // different with current year.
                        setState(() {
                          // check the new date year and current date year
                          // if different then process to get the data
                          if (newDate.year == _currentDate.year) {
                            // check month whether same or not??
                            if (newDate.month == _currentDate.month) {
                              // all the same, no need to fetch the data
                              return;
                            }
                            else {
                              // different month, so get the month data only
                              _monthYearCalendarPL = (_monthYearCalendarPLMap[DateTime(newDate.year, newDate.month, 1)] ?? []);

                              // calculate the PL total for the month data
                              _calculateMonthYearPLTotal();

                              // set the current date with the selected year.
                              _currentDate = newDate;
                            }
                          }
                          else {
                            // get the calendar PL data from map for both
                            _monthYearCalendarPL = (_monthYearCalendarPLMap[DateTime(newDate.year, newDate.month, 1)] ?? []);
                            _yearCalendarPL = (_yearCalendarPLMap[DateTime(newDate.year, 1, 1)] ?? []);

                            // calculate the pl total for the data
                            _calculateMonthYearPLTotal();
                            _calculateYearPLTotal();

                            // set the current date with the selected year.
                            _currentDate = newDate;
                          }
                        });
                      }),
                    ),
                  ),
                );
              }),
            );
          }),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Text("${_currentDate.year}"),
              const SizedBox(width: 5,),
              const Icon(
                Ionicons.caret_down_sharp,
                color: primaryLight,
                size: 10,
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _getSubPage() {
    if (_calendarSelection == "m") {
      return _getSubPageMonthYear();
    } else {
      return _getSubPageYear();
    }
  }

  Widget _getSubPageMonthYear() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Container(
          margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: primaryDark,
            borderRadius: BorderRadius.circular(5),
          ),
          width: double.infinity,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "${Globals.dfMMMyyyy.formatLocal(_currentDate)} P&L",
                    style: const TextStyle(
                      color: textPrimary,
                      fontSize: 10,
                    ),
                  ),
                  Text(
                    formatCurrency(
                      _plTotal,
                      shorten: false,
                      decimalNum: 2
                    ),
                    style: TextStyle(
                      color: _plTotalColor,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    "P&L Ratio",
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 10,
                    ),
                  ),
                  Text(
                    "${formatDecimal(
                      _plRatio,
                      decimal: 2
                    )}%",
                    style: TextStyle(
                      color: _plRatioColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 10,),
        PerformanceCalendar(
          month: _currentDate.month,
          year: _currentDate.year,
          data: _monthYearCalendarPL,
          type: PerformanceCalendarType.monthYear,
        ),
      ],
    );
  }

  Widget _getSubPageYear() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Container(
          margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: primaryDark,
            borderRadius: BorderRadius.circular(5),
          ),
          width: double.infinity,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "${_currentDate.year} P&L",
                    style: const TextStyle(
                      color: textPrimary,
                      fontSize: 10,
                    ),
                  ),
                  Text(
                    formatCurrency(
                      _plTotalYear,
                      shorten: false,
                      decimalNum: 2
                    ),
                    style: TextStyle(
                      color: _plTotalYearColor,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    "P&L Ratio",
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 10,
                    ),
                  ),
                  Text(
                    "${formatDecimal(
                      _plRatioYear,
                      decimal: 2
                    )}%",
                    style: TextStyle(
                      color: _plRatioYearColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 10,),
        PerformanceCalendar(
          month: _currentDate.month,
          year: _currentDate.year,
          data: _yearCalendarPL,
          type: PerformanceCalendarType.year,
        ),
      ],
    );
  }

  void _calculateMonthYearPLTotal() {
    // initialize pl total and pl ratio
    _plTotal = 0;
    _plRatio = 0;
    _plTotalColor = primaryLight;
    _plRatioColor = primaryLight;

    // loop thru current month data
    for(int i=0; i<_monthYearCalendarPL.length; i++) {
      _plTotal += (_monthYearCalendarPL[i].pl ?? 0);
      _plRatio += (_monthYearCalendarPL[i].plRatio ?? 0);
    }

    // get the correct pl color
    if (_plTotal > 0) {
      _plTotalColor = Colors.green;
    } else if (_plTotal < 0) {
      _plTotalColor = secondaryColor;
    }

    if (_plRatio > 0) {
      _plRatioColor = Colors.green;
    } else if (_plRatio < 0) {
      _plRatioColor = secondaryColor;
    }
  }

  void _calculateYearPLTotal() {
    // initialize pl total and pl ratio
    _plTotalYear = 0;
    _plRatioYear = 0;
    _plTotalYearColor = primaryLight;
    _plRatioYearColor = primaryLight;

    // loop thru current year data
    for(int i=0; i<_yearCalendarPL.length; i++) {
      _plTotalYear += (_yearCalendarPL[i].pl ?? 0);
      _plRatioYear += (_yearCalendarPL[i].plRatio ?? 0);
    }

    // get the correct pl color
      if (_plTotalYear > 0) {
        _plTotalYearColor = Colors.green;
      } else if (_plTotalYear < 0) {
        _plTotalYearColor = secondaryColor;
      }

      if (_plRatioYear > 0) {
        _plRatioYearColor = Colors.green;
      } else if (_plRatioYear < 0) {
        _plRatioYearColor = secondaryColor;
      }
  }

  Future<bool> _getInitData({
    required DateTime currentDate,
    DateTime? newDate,
    bool? showLoader,
  }) async {
    // if this is not a first run then show the loader dialog
    if ((showLoader ?? false) == false) {
      LoadingScreen.instance().show(context: context);
    }

    // get the same data as watchlist performance, as we will generate
    // the calendar data based on that result, since we still haven't found
    // how to calculate the realized, unrealized PL correctly using SQL
    // query based on the month and year.

    await _watchlistAPI.getWatchlistPerformance(
      type: _watchlistArgs.type,
      id: _watchlistArgs.watchList.watchlistId
    ).then((resp) {
      // format the data, we can get the first and last date based on the
      // result given
      if (resp.isNotEmpty) {
        // get the first and last date
        _firstDate = resp.first.buyDate;
        _endDate = resp.last.buyDate;

        // now we can generate the map needed for calendar, month year will
        // be straight forward
        DateTime currentMonthYear;
        DateTime currentYear;
        double? pl;
        double? plBefore;
        double? plRatio;
        Map<int, CalendarDatePL> tmpYearMap;
        Map<DateTime, Map<int, CalendarDatePL>> yearCalendarPLMapHelper = {};

        // clear month year calendar pl
        _monthYearCalendarPLMap.clear();

        // convert the watchlist performance to map
        Map<DateTime, WatchlistPerformanceModel> mapPerformance = {};
        for(int i=0; i<resp.length; i++) {
          mapPerformance[resp[i].buyDate] = resp[i];
        }

        DateTime startDate = DateTime(resp.first.buyDate.year, resp.first.buyDate.month, 1);
        DateTime endDate = DateTime(resp.last.buyDate.year, resp.last.buyDate.month + 1, 1);

        while (startDate.isBefore(endDate)) {
          // set current month year to current resp buy date, default to date 1
          currentMonthYear = DateTime(startDate.year, startDate.month, 1);

          // set current year to current resp buy date year, default to 1st jan
          currentYear = DateTime(startDate.year, 1, 1);

          // initialize pl and plratio to null
          pl = null;
          plRatio = null;

          // check if we have data for this or not?
          if (mapPerformance.containsKey(startDate)) {
            // got data, check if pl before is not null
            if (plBefore != null) {
              // then can calculate pl and pl ratio
              pl = (
                (
                  (mapPerformance[startDate]!.buyTotal * mapPerformance[startDate]!.currentPrice) -
                  mapPerformance[startDate]!.buyAmount
                ) + mapPerformance[startDate]!.realizedPL
              ) - plBefore;
              plRatio = pl / mapPerformance[startDate]!.buyAmount;
            }

            // set plBefore to the current PL
            plBefore = (
              (mapPerformance[startDate]!.buyTotal * mapPerformance[startDate]!.currentPrice) -
              mapPerformance[startDate]!.buyAmount
            ) + mapPerformance[startDate]!.realizedPL;
          }

          // generate the Calendar PL
          CalendarDatePL data = CalendarDatePL(
            date: startDate.day.toString(),
            pl: pl,
            plRatio: plRatio,
          );

          // check if the month year data is already exists on the map or not?
          if (!_monthYearCalendarPLMap.containsKey(currentMonthYear)) {
            // create a new list for this
            _monthYearCalendarPLMap[currentMonthYear] = [];
          }

          // check if the year data is already exists onr the map or not?
          if (!yearCalendarPLMapHelper.containsKey(currentYear)) {
            // create a new list for this
            yearCalendarPLMapHelper[currentYear] = {};
          }
          else {
            // put the data in the temporary variable
            tmpYearMap = yearCalendarPLMapHelper[currentYear]!;

            // check if we already have this month or not on the map
            if (!tmpYearMap.containsKey(startDate.month)) {
              // just add this to tmpYearMap
              tmpYearMap[startDate.month] = CalendarDatePL(
                date: Globals.dfMMM.formatLocal(
                  DateTime(
                    startDate.year,
                    startDate.month,
                    1
                  )
                ),
                pl: pl,
                plRatio: plRatio,
              );
            }
            else {
              // we need to add the previous PL to this data
              CalendarDatePL prevData = tmpYearMap[startDate.month]!;
              CalendarDatePL newData = CalendarDatePL(
                date: Globals.dfMMM.formatLocal(
                  DateTime(
                    startDate.year,
                    startDate.month,
                    1
                  )
                ),
                pl: (pl ?? 0) + (prevData.pl ?? 0),
                plRatio: (plRatio ?? 0) + (prevData.plRatio ?? 0),
              );

              // put the new data into the tmpYearMap
              tmpYearMap[startDate.month] = newData;

              // update the year calendar map for this year
              yearCalendarPLMapHelper[currentYear] = tmpYearMap;
            }
          }

          // add calendar ate PL data to the map
          _monthYearCalendarPLMap[currentMonthYear]!.add(data);

          // go for next day
          startDate = startDate.add(Duration(days: 1));
        }

        // convert the year map helper to actual year calendar PL
        _yearCalendarPLMap.clear();
        yearCalendarPLMapHelper.forEach((key, value) {
          // initialize this data as list
          _yearCalendarPLMap[key] = [];

          // loop thru all the value
          value.forEach((month, calendarPL) {
            _yearCalendarPLMap[key]!.add(calendarPL);
          },);
        },);

        // get the current date data and put it on the month year PL list
        _monthYearCalendarPL = (_monthYearCalendarPLMap[DateTime(_currentDate.year, _currentDate.month, 1)] ?? []);

        // get the current year and put it on the year PL list
        _yearCalendarPL = (_yearCalendarPLMap[DateTime(_currentDate.year, 1, 1)] ?? []);

        // calculate the pl total and ratio for month
        _calculateMonthYearPLTotal();

        // calculate the pl total and ratio for year
        _calculateYearPLTotal();
      }
    }).onError((error, stackTrace) {
      Log.error(
        message: 'Error getting data from server',
        error: error,
        stackTrace: stackTrace,
      );
    }).whenComplete(() {
      // if this is not the  first run, it means that the loader dialog is being
      // called on top, close the loader dialog.
      if ((showLoader ?? false) == false) {
        LoadingScreen.instance().hide();
      }
    });

    return true;
  }
}
