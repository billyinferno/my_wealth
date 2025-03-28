import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:my_wealth/_index.g.dart';

class WatchlistSummaryCalendarPage extends StatefulWidget {
  final Object? args;
  const WatchlistSummaryCalendarPage({super.key, required this.args});

  @override
  State<WatchlistSummaryCalendarPage> createState() => _WatchlistSummaryCalendarPageState();
}

class _WatchlistSummaryCalendarPageState extends State<WatchlistSummaryCalendarPage> {
  final ScrollController _pageScrollController = ScrollController();
  final ScrollController _scrollYearController = ScrollController();

  final WatchlistAPI _watchlistAPI = WatchlistAPI();

  late WatchlistSummaryPerformanceArgs _args;
  late List<SummaryPerformanceModel> _summaryPerfData;
  late Map<DateTime, List<CalendarDatePL>> _monthYearCalendarPLMap;
  late Map<DateTime, List<CalendarDatePL>> _yearCalendarPLMap;
  late List<CalendarDatePL> _monthYearCalendarPL;
  late List<CalendarDatePL> _yearCalendarPL;

  late UserLoginInfoModel? _userInfo;
  late DateTime _currentDate;
  
  // calendar first and end date
  late DateTime _firstDate;
  late DateTime _endDate;

  late double _totalDayGain;
  late double _totalCost;
  late double _totalValue;
  late double _totalRealised;
  late double _totalUnrealised;
  late double _totalPotentialPL;

  late double _plTotal;
  late double _plRatio;
  late Color _plTotalColor;
  late Color _plRatioColor;
  late double _plTotalYear;
  late double _plRatioYear;
  late Color _plTotalYearColor;
  late Color _plRatioYearColor;

  late String _calendarSelection;

  late Future<bool> _getData;

  @override
  void initState() {
    super.initState();

    // convert args to watchlist summary performance args
    _args = widget.args as WatchlistSummaryPerformanceArgs;

    // get the shared date
    _userInfo = UserSharedPreferences.getUserInfo();
    
    // initialize variable
    _currentDate = DateTime.now();
    _calendarSelection = 'm'; // calendar selected as month

    // initialize first and end date
    _firstDate = _endDate = DateTime.now();
    
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

    // initialize the map for generating performance and calendar
    _summaryPerfData = [];

    // initialize the month and year calendar PL data
    _monthYearCalendarPLMap = {};
    _yearCalendarPLMap = {};
    _monthYearCalendarPL = [];
    _yearCalendarPL = [];

    // perform calculation for known data
    _totalDayGain = _args.computeResult!.getTotalDayGain(type: _args.type);
    _totalCost = _args.computeResult!.getTotalCost(type: _args.type);
    _totalValue = _args.computeResult!.getTotalValue(type: _args.type);
    _totalRealised = _args.computeResult!.getTotalRealised(type: _args.type);
    _totalUnrealised = _totalValue - _totalCost;
    _totalPotentialPL = _totalRealised + _totalUnrealised;

    // get the performance summary for this data
    _getData = _getPerformanceData(
      type: _args.type,
      currentDate: _currentDate,
      firstRun: true
    );
  }

  @override
  void dispose() {
    _pageScrollController.dispose();
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
        leading: IconButton(
          onPressed: ((() {
            // return back to the previous page
            Navigator.pop(context);
          })),
          icon: const Icon(
            Ionicons.arrow_back,
          )
        ),
        title: Center(
          child: Text(
            "Performance ${_args.type.toTitleCase()}",
            style: const TextStyle(
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
                controller: _pageScrollController,
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
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 10,
            color: riskColor(
              value: _totalValue,
              cost: _totalCost,
              riskFactor: _userInfo!.risk
            ),
          ),
          Expanded(
            child: Container(
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
                      _rowItem(text: "DAY GAIN", value: _totalDayGain, needColor: true),
                      const SizedBox(width: 10,),
                      _rowItem(text: "COST", value: _totalCost),
                      const SizedBox(width: 10,),
                      _rowItem(text: "VALUE", value: _totalValue),
                    ],
                  ),
                  const SizedBox(height: 5,),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      _rowItem(text: "UNREALISED", value: _totalUnrealised, needColor: true),
                      const SizedBox(width: 10,),
                      _rowItem(text: "REALISED", value: _totalRealised, needColor: true),
                      const SizedBox(width: 10,),
                      _rowItem(text: "POTENTIAL PL", value: _totalPotentialPL, needColor: true),
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
      return _dateSelectorMonthYear();
    }
    else {
      return _dateSelectorYear();
    }
  }

  Widget _dateSelectorMonthYear() {
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
              // check if newDate is same as current date or not?
              if (newDate != _currentDate) {                
                setState(() {
                  // get the data from map
                  _monthYearCalendarPL = (_monthYearCalendarPLMap[DateTime(newDate.year, newDate.month, 1)] ?? []);

                  // re-calculate the pl ratio for month
                  _calculateMonthYearPLTotal();

                  // check if we need to refresh the year also or not?
                  if (newDate.year != _currentDate.year) {
                    // different year, get the new data
                    _yearCalendarPL = (_yearCalendarPLMap[DateTime(newDate.year, 1, 1)] ?? []);

                    // re-calculate the pl ratio for year
                    _calculateYearPLTotal();
                  }

                  // set new date as current date, in case the same it will not
                  // matter also.
                  _currentDate = newDate;
                });
              }
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
  }

  Widget _dateSelectorYear() {
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

                      // check the new date year and current date year
                      // if different then process to get the data
                      if (newDate.year != _currentDate.year) {
                        // set state and get the data if the selected year is
                        // different with current year.
                        setState(() {
                          // get the year and month data as this is new year
                          _monthYearCalendarPL = (_monthYearCalendarPLMap[DateTime(newDate.year, newDate.month, 1)] ?? []);
                          _yearCalendarPL = (_yearCalendarPLMap[DateTime(newDate.year, 1, 1)] ?? []);

                          // re-calculate the pl total
                          _calculateMonthYearPLTotal();
                          _calculateYearPLTotal();

                          // set the current date with the selected
                          // year.
                          _currentDate = newDate;
                        });
                      }
                    }),
                  ),
                ),
              );
            })
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
      )
    );
  }

  Widget _getSubPage() {
    if (_calendarSelection == "m") {
      return _getSubPageMonthYear();
    }
    else {
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
                      decimal: 2,
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
                    "${formatDecimal(_plRatioYear, decimal: 2)}%",
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

  Widget _rowItem({required String text, required double value, bool? needColor}) {
    bool isNeedColor = (needColor ?? false);    
    Color textColor = textPrimary;

    if (isNeedColor) {
      if (value < 0) {
        textColor = secondaryColor;
      }
      if (value > 0) {
        textColor = Colors.green;
      }
    }

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Text(
            text,
            style: const TextStyle(
              fontSize: 10,
            ),
          ),
          Text(
            formatCurrency(
              value,
              decimalNum: 2
            ),
            style: TextStyle(
              color: textColor
            ),
          )
        ],
      ),
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

  Future<bool> _getPerformanceData({
    required String type,
    required DateTime currentDate,

    bool? firstRun
  }) async {
    // check if this is first run or not?
    // if not first run, then show the loading screen
    if ((firstRun ?? false) == false) {
      LoadingScreen.instance().show(context: context);
    }

    // get the data
    Map<String, List<SummaryPerformanceModel>> perfData = {};
    if (type.toLowerCase() == 'all') {

      await Future.wait([
        _watchlistAPI.getWatchlistPerformanceSummary(
          type: 'reksadana'
        ).then((resp) {
          perfData['reksadana'] = resp;
        }),
        _watchlistAPI.getWatchlistPerformanceSummary(
          type: 'saham'
        ).then((resp) {
          perfData['saham'] = resp;
        }),
        _watchlistAPI.getWatchlistPerformanceSummary(
          type: 'gold'
        ).then((resp) {
          perfData['gold'] = resp;
        }),
        _watchlistAPI.getWatchlistPerformanceSummary(
          type: 'crypto'
        ).then((resp) {
          perfData['crypto'] = resp;
        }),
      ]).onError((error, stackTrace) {
        Log.error(
          message: 'Error getting data from server',
          error: error,
          stackTrace: stackTrace,
        );
        throw Exception('Error when try to get the data from server');
      },).whenComplete(() {
        // if not first run, remove the loading screen
        if ((firstRun ?? false) == false) {
          LoadingScreen.instance().hide();
        }
      },);
    }
    else {
      await _watchlistAPI.getWatchlistPerformanceSummary(
        type: type.toLowerCase(),
      ).then((resp) {
        perfData[type.toLowerCase()] = resp;
      });
    }

    // generate the calendar PL data for all the data
    // first get all the list dates from all the performance data
    List<DateTime> listAllDates = [];
    List<DateTime> listDates = [];

    // loop thru all the perf data to get the dates
    perfData.forEach((key, data) {
      for(int i=0; i < data.length; i++) {
        listAllDates.add(data[i].plDate);
      }
    });
    
    // sort the dates so we can use it later when we want to generate the performance data
    listDates = LinkedHashSet<DateTime>.from(listAllDates).toList()..sort();

    // set the first and last date
    _firstDate = listDates.first;
    _endDate = listDates.last;

    // convert the performance data to map, so we can check whether the date is available or not?
    Map<DateTime, SummaryPerformanceModel> tmpSummaryPerfData = {};
    Map<DateTime, SummaryPerformanceModel> tmpPerfData = {};
    SummaryPerformanceModel tmpCurrentSummaryPerfModel;
    SummaryPerformanceModel tmpNextSummaryPerfModel;

    // loop thru all the perfData
    perfData.forEach((key, data) {
      // clear the map first before we add
      tmpPerfData.clear();

      // loop thru all the performance model
      for(int i=0; i < data.length; i++) {
        tmpPerfData[data[i].plDate] = data[i];
      }

      // loop thru the list of dates
      double prevValue = 0;
      double prevAmount = 0;
      for(int i=0; i < listDates.length; i++) {
        // check if this date is available or not on the tmpPerfData
        if (tmpPerfData.containsKey(listDates[i])) {
          // just add the data
          prevValue = tmpPerfData[listDates[i]]!.plValue;
          prevAmount = tmpPerfData[listDates[i]]!.totalAmount;
        }

        // add this prevValue and totalAmount to the tmpSummaryPerfData
        // first check if exists or not on the tmpSummaryPerfData
        if (tmpSummaryPerfData.containsKey(listDates[i])) {
          // get the current value
          tmpCurrentSummaryPerfModel = tmpSummaryPerfData[listDates[i]]!;
          // create the next data
          tmpNextSummaryPerfModel = SummaryPerformanceModel(
            plDate: listDates[i],
            plValue: tmpCurrentSummaryPerfModel.plValue + prevValue,
            totalAmount: tmpCurrentSummaryPerfModel.totalAmount + prevAmount,
          );
          // add to the tmpSummaryPerfData
          tmpSummaryPerfData[listDates[i]] = tmpNextSummaryPerfModel;
        }
        else {
          tmpSummaryPerfData[listDates[i]] = SummaryPerformanceModel(
            plDate: listDates[i],
            plValue: prevValue,
            totalAmount: prevAmount,
          );
        }
      }
    });

    // once finished loop all the performance data, and combine it
    // extract the data from map to list of _summaryPerfData and _perfData
    _summaryPerfData.clear();
    tmpSummaryPerfData.forEach((key, data) {          
      // add this data to the summary perf data
      _summaryPerfData.add(data);
    });

    // once we got the summary performance data, then we can generate the
    // calendar PL that we can use to showed the calendar performance
    _monthYearCalendarPLMap.clear();
    _yearCalendarPLMap.clear();

    // loop thru summary performance data
    DateTime currentMonthYear;
    DateTime currentYear;
    double? pl;
    double? plRatio;
    double plBefore = 0;
    Map<DateTime, Map<DateTime, CalendarDatePL>> tmpYearCalendarPLMap = {};
    CalendarDatePL tmpYearCalendarPL;

    for(int i=0; i<_summaryPerfData.length; i++) {
      // default the current month year into first date of month
      currentMonthYear = DateTime(
        _summaryPerfData[i].plDate.year,
        _summaryPerfData[i].plDate.month,
        1
      );
      
      // default the current year into 1st jan
      currentYear = DateTime(_summaryPerfData[i].plDate.year, 1, 1);

      // check if the month year PL map already exists or not for this month
      // year date?
      if (!_monthYearCalendarPLMap.containsKey(currentMonthYear)) {
        // create the list for this map
        _monthYearCalendarPLMap[currentMonthYear] = [];
      }

      // check if the year PL map already exists or not for this year date
      if (!tmpYearCalendarPLMap.containsKey(currentYear)) {
        // create the map for this temp map data
        tmpYearCalendarPLMap[currentYear] = {};
      }

      // calculate the pl only if we already pass the first record
      if (i > 0) {
        pl = _summaryPerfData[i].plValue - plBefore;
        plRatio = (pl / _summaryPerfData[i].totalAmount);
      }
      
      // create the CalendarPL data for month year
      _monthYearCalendarPLMap[currentMonthYear]!.add(CalendarDatePL(
        date: _summaryPerfData[i].plDate.day.toString(),
        pl: pl,
        plRatio: plRatio,
      ));

      // check if this month and year already in the temp map for year
      // calendar PL
      if (!tmpYearCalendarPLMap[currentYear]!.containsKey(currentMonthYear)) {
        // just add the data to this map
        tmpYearCalendarPLMap[currentYear]![currentMonthYear] = CalendarDatePL(
          date: Globals.dfMMM.formatLocal(
            DateTime(
              _summaryPerfData[i].plDate.year,
              _summaryPerfData[i].plDate.month,
              1
            )
          ),
          pl: pl,
          plRatio: plRatio,
        );
      }
      else {
        tmpYearCalendarPL = tmpYearCalendarPLMap[currentYear]![currentMonthYear]!;
        tmpYearCalendarPLMap[currentYear]![currentMonthYear] = CalendarDatePL(
          date: Globals.dfMMM.formatLocal(
            DateTime(
              _summaryPerfData[i].plDate.year,
              _summaryPerfData[i].plDate.month,
              1
            )
          ),
          pl: (pl ?? 0) + (tmpYearCalendarPL.pl ?? 0),
          plRatio: (plRatio ?? 0) + (tmpYearCalendarPL.plRatio ?? 0),
        );
      }

      // store the PL before
      plBefore = _summaryPerfData[i].plValue;
    }

    // convert the temp year calendar PL map into map that we can use
    tmpYearCalendarPLMap.forEach((year, value) {
      // create new data for year calendar PL map
      _yearCalendarPLMap[year] = [];

      // loop on the value to add to map
      value.forEach((key, calendarPL) {
        _yearCalendarPLMap[year]!.add(calendarPL);
      },);
    },);

    // set the month year calendar data based on the current date
    _monthYearCalendarPL = (_monthYearCalendarPLMap[DateTime(_currentDate.year, _currentDate.month, 1)] ?? []);

    // set the year calendar data based on the current date
    _yearCalendarPL = (_yearCalendarPLMap[DateTime(_currentDate.year, 1, 1)] ?? []);

    // re-calculate the pl total for both month and year
    _calculateMonthYearPLTotal();
    _calculateYearPLTotal();

    return true;
  }
}