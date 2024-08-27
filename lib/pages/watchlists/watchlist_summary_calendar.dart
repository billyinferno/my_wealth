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
    
    super.initState();
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
            Container(
              width: double.infinity,
              color: riskColor(
                _totalValue,
                _totalCost,
                _userInfo!.risk
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(width: 10,),
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: primaryDark,
                        border: Border(
                          bottom: BorderSide(
                            color: primaryLight,
                            width: 1.0,
                            style: BorderStyle.solid,
                          )
                        )
                      ),
                      padding: const EdgeInsets.all(10),
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
            ),
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
                            onValueChanged: ((value) {
                              String selectedValue = value.toString();
                              
                              setState(() {
                                _calendarSelection = selectedValue;
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
              setState(() {
                // get the data
                _getData = _getPerformanceData(
                  type: _args.type,
                  currentDate: _currentDate,
                  newDate: newDate
                );

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
            Text(Globals.dfyyyyMM.format(_currentDate)),
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
                          // get the data
                          _getData = _getPerformanceData(
                            type: _args.type,
                            currentDate: _currentDate,
                            newDate: newDate);

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
                    "${Globals.dfMMMyyyy.format(_currentDate)} P&L",
                    style: const TextStyle(
                      color: textPrimary,
                      fontSize: 10,
                    ),
                  ),
                  Text(
                    formatCurrency(_plTotal, false, true, false, 2),
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
                    "${formatDecimal(_plRatio, 2)}%",
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
                    formatCurrency(_plTotalYear, false, true, false, 2),
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
                    "${formatDecimal(_plRatioYear, 2)}%",
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
            formatCurrency(value, false, true, true, 2),
            style: TextStyle(
              color: textColor
            ),
          )
        ],
      ),
    );
  }

  Future<void> _getPerformanceDataMonthYear({
    required String type,
    required DateTime currentDate,
    DateTime? newDate
  }) async {
    DateTime useDate = currentDate;
    // check if new date is not null
    if (newDate != null) {
      // check and ensure that this is not the same as the current date
      if (currentDate.month == newDate.month && currentDate.year == newDate.month) {
        // just return
        return;
      }
      else {
        useDate = newDate;
      }
    }

    // create the map that we will use for computation later on once we got
    // all the data
    Map<String, List<SummaryPerformanceModel>> perfData = {};

    // if not then we can get the data
    if (type.toLowerCase() == 'all') {
      await Future.wait([
        _watchlistAPI.getWatchlistPerformanceSummaryMonthYear(
          type: 'reksadana',
          month: useDate.month,
          year: useDate.year,
        ).then((resp) {
          perfData['reksadana'] = resp;
        }),
        _watchlistAPI.getWatchlistPerformanceSummaryMonthYear(
          type: 'saham',
          month: useDate.month,
          year: useDate.year,
        ).then((resp) {
          perfData['saham'] = resp;
        }),
        _watchlistAPI.getWatchlistPerformanceSummaryMonthYear(
          type: 'gold',
          month: useDate.month,
          year: useDate.year,
        ).then((resp) {
          perfData['gold'] = resp;
        }),
        _watchlistAPI.getWatchlistPerformanceSummaryMonthYear(
          type: 'crypto',
          month: useDate.month,
          year: useDate.year,
        ).then((resp) {
          perfData['crypto'] = resp;
        }),
      ]);
    }
    else {
      await _watchlistAPI.getWatchlistPerformanceSummaryMonthYear(
        type: type.toLowerCase(),
        month: useDate.month,
        year: useDate.year,
      ).then((resp) {
        perfData[type.toLowerCase()] = resp;
      });
    }

    Map<DateTime, SummaryPerformanceModel> watchlistMapPerformance = {};

    // for type all, we need to fill the gap, because gold have price on saturday
    // but other doesn't have, so it will not counting the pl that we got
    // for other during saturday, which causing odd issue when calculating the
    // calendar PL.
    if (type == 'all') {
      DateTime firstDate = DateTime(_currentDate.year, _currentDate.month, 1).subtract(const Duration(days: 1)).toLocal();
      DateTime endDate = DateTime(_currentDate.year, _currentDate.month + 1, 1).toLocal();
      
      // check end date, whether end date is more than end date that we got
      // from API or not? This is to avoid we put the data until end of month,
      // where we don't reach that date yet.
      if (endDate.isAfter(_endDate.toLocal())) {
        // set end date as today date + 1
        endDate = _endDate.toLocal();
      }

      Map<String, Map<DateTime, SummaryPerformanceModel>> combPerf = {};
      Map<DateTime, SummaryPerformanceModel> tmpPerf = {};
      
      // first generate all the date from first to end date
      while(isSameOrBefore(date: firstDate, checkDate: endDate)) {
        tmpPerf[firstDate] = SummaryPerformanceModel(
          plDate: firstDate,
          plValue: double.negativeInfinity,
          totalAmount: double.negativeInfinity
        );
        firstDate = firstDate.add(const Duration(days: 1));
      }

      // loop thru all the performance data we have and generate the combination
      perfData.forEach((key, perfList) {
        Map<DateTime, SummaryPerformanceModel> newCombPerf = Map<DateTime, SummaryPerformanceModel>.from(tmpPerf);

        // check if we got perf list, in case no data, it means we need to
        // default it to all 0
        if (perfList.isNotEmpty) {
          // loop thru perf list
          for (int i=0; i<perfList.length; i++) {
            newCombPerf[perfList[i].plDate] = perfList[i];
          }

          // once filled the newCombPerf, loop thru newCombPerf to fill all
          // the voids when the date is not yet filled
          
          // default the previousPerf as 0
          SummaryPerformanceModel prevPerf = perfList[0];
          
          newCombPerf.forEach((date, perf) {
            // check if current perf plValue and totalAmount is negative
            // infinity
            if (
              perf.plValue == double.negativeInfinity &&
              perf.totalAmount == double.negativeInfinity
            ) {
              // means that we don't have data for this date, copy the data
              // from the previous perf
              newCombPerf[date] = prevPerf;
            }

            // set  the prev data as current perf
            prevPerf = newCombPerf[date]!;
          },);
        }
        else {
          newCombPerf.forEach((key, value) {
            newCombPerf.update(key, (_) {
              return SummaryPerformanceModel(
                plDate: key,
                plValue: 0,
                totalAmount: 0
              );
            });
          });
        }

        // set the comb perf
        combPerf[key] = newCombPerf;
      });

      // now combine all the data in the comb perf to the watchlistMapPerformance
      watchlistMapPerformance.clear();
      combPerf.forEach((type, list) {
        list.forEach((date, data) {
          // check whether we got this date on the watchlist performance or not?
          if(watchlistMapPerformance.containsKey(date)) {
            // extract the data and update it
            SummaryPerformanceModel before = watchlistMapPerformance[date]!;

            // update the watchlist map performance
            watchlistMapPerformance.update(date, (_) {
              return SummaryPerformanceModel(
                plDate: date,
                plValue: before.plValue + data.plValue,
                totalAmount: before.totalAmount + data.totalAmount
              );
            });
          }
          else {
            // first data, yay
            watchlistMapPerformance[date] = data;
          }
        });
      });
    }
    else {
      // loop thru all the keys and generate the watchlist performance map
      perfData.forEach((key, perfList) {
        // loop thru perfList
        for (int i=0; i<perfList.length; i++) {
          // check if we got this date already or not?
          if (watchlistMapPerformance.containsKey(perfList[i].plDate)) {
            // exists already, extract the performance data, and combine it
            SummaryPerformanceModel tmp = watchlistMapPerformance[perfList[i].plDate]!;
            SummaryPerformanceModel newData = SummaryPerformanceModel(
              plDate: perfList[i].plDate,
              plValue: tmp.plValue + perfList[i].plValue,
              totalAmount: tmp.totalAmount + perfList[i].totalAmount
            );

            // put the new data in the map
            watchlistMapPerformance[perfList[i].plDate] = newData;
          }
          else {
            // not exists, we can create new data here
            watchlistMapPerformance[perfList[i].plDate] = perfList[i];
          }
        }
      });
    }
    

    // sort the map based on the keys
    watchlistMapPerformance = sortedMap<DateTime, SummaryPerformanceModel>(data: watchlistMapPerformance);

    // once sorted we can calculate the pl total and pl ratio
    // initialize pl total and pl ratio
    double? plBefore;
    _plTotal = 0;
    _plRatio = 0;
    _plTotalColor = primaryLight;
    _plRatioColor = primaryLight;

    // loop thru the sorted watchlist performance
    watchlistMapPerformance.forEach((key, value) {
      // check if pl before is null, if null, then this is means that this
      // is the first date so ignore this.
      if (plBefore == null) {
        plBefore = value.plValue;
      }
      else {
        _plTotal += value.plValue - plBefore!;
        if (value.totalAmount > 0) {
          _plRatio += (value.plValue - plBefore!) / value.totalAmount;
        }
      }

      // set the pl before as current pl value
      plBefore = value.plValue;
    });

    // divide the pl ratio with the total data - 1
    _plRatio = (_plRatio / (watchlistMapPerformance.length - 1)) * 100;

    // get the correct pl color
    if (_plTotal > 0) {
      _plTotalColor = Colors.green;
    }
    else if (_plTotal < 0) {
      _plTotalColor = secondaryColor;
    }

    if (_plRatio > 0) {
      _plRatioColor = Colors.green;
    }
    else if (_plRatio < 0) {
      _plRatioColor = secondaryColor;
    }

    // generate the calendar PL
    _monthYearCalendarPL.clear();
    _monthYearCalendarPL = _generateDateMonthYear(data: watchlistMapPerformance);
  }

  List<CalendarDatePL> _generateDateMonthYear({required Map<DateTime, SummaryPerformanceModel> data}) {
    // generate 42 string of list
    List<CalendarDatePL> dateList = List<CalendarDatePL>.generate(42, (index) {
      return const CalendarDatePL(
        date: "",
        pl: null,
        plRatio: null,
      );
    });

    // generate the first and last date
    DateTime firstDate = DateTime(_currentDate.year, _currentDate.month, 1);
    DateTime beforeDate;
    DateTime endDate = DateTime(_currentDate.year, _currentDate.month + 1, 1);

    // first row
    int row = 0;
    double? pl;
    double? plRatio;
    double? plBefore;
    double plCurrent;

    // loop from 1st date to end date
    while (firstDate.isBefore(endDate)) {
      // initialize default pl and plRatio
      pl = null;
      plRatio = null;

      // get the pl and pl ratio for this by checking if this date is exists
      // in the watchlist map performance.
      beforeDate = firstDate.subtract(const Duration(days: 1));
      if (data.containsKey(beforeDate)) {
        plBefore = data[beforeDate]!.plValue;
      }

      if (data.containsKey(firstDate) && plBefore != null) {
        plCurrent = data[firstDate]!.plValue;

        // calculate pl and pl ratio
        pl = plCurrent - plBefore;
        if (data[firstDate]!.totalAmount > 0) {
          plRatio = (pl / data[firstDate]!.totalAmount);
        }
        else {
          plRatio = 0;
        }

        // set pl current as pl before
        plBefore = plCurrent;
      }

      // calculate this and add to the according date array
      dateList[(row + (firstDate.weekday - 1))] = CalendarDatePL(
        date: firstDate.day.toString(),
        pl: pl,
        plRatio: plRatio,
      );
      
      // check if this is sunday
      if (firstDate.weekday == 7) {
        // add row + 7, since we will need go to the next row in calendar
        row += 7;
      }
      
      // move to the next day
      firstDate = firstDate.add(const Duration(days: 1));
    }

    return dateList;
  }

  Future<void> _getPerformanceDataYear({
    required String type,
    required DateTime currentDate,
    DateTime? newDate
  }) async {
    DateTime useDate = currentDate;
    // check if new date is not null
    if (newDate != null) {
      // check and ensure that this is not the same as the current date
      if (currentDate.year == newDate.year) {
        // just return
        return;
      }
      else {
        useDate = newDate;
      }
    }

    // create the map that we will use for computation later on once we got
    // all the data
    Map<String, List<SummaryPerformanceModel>> perfData = {};

    // if not then we can get the data
    if (type.toLowerCase() == 'all') {
      await Future.wait([
        _watchlistAPI.getWatchlistPerformanceSummaryYear(
          type: 'reksadana',
          year: useDate.year,
        ).then((resp) {
          perfData['reksadana'] = resp;
        }),
        _watchlistAPI.getWatchlistPerformanceSummaryYear(
          type: 'saham',
          year: useDate.year,
        ).then((resp) {
          perfData['saham'] = resp;
        }),
        _watchlistAPI.getWatchlistPerformanceSummaryYear(
          type: 'gold',
          year: useDate.year,
        ).then((resp) {
          perfData['gold'] = resp;
        }),
        _watchlistAPI.getWatchlistPerformanceSummaryYear(
          type: 'crypto',
          year: useDate.year,
        ).then((resp) {
          perfData['crypto'] = resp;
        }),
      ]);
    }
    else {
      await _watchlistAPI.getWatchlistPerformanceSummaryYear(
        type: type.toLowerCase(),
        year: useDate.year,
      ).then((resp) {
        perfData[type.toLowerCase()] = resp;
      });
    }

    // create variable to combine all the performance data
    Map<DateTime, SummaryPerformanceModel> watchlistMapPerformance = {};

    // loop thru all the keys and generate teh watchlist performance map
    perfData.forEach((key, perfList) {
      // loop thru perfList
      for (int i=0; i<perfList.length; i++) {
        // create the performance date, as each reksadna, saham, etc.
        // will have different end day based on their price. 
        DateTime perfDate = DateTime(perfList[i].plDate.year, perfList[i].plDate.month, 1);
        
        // check if we got this date already or not?
        if (watchlistMapPerformance.containsKey(perfDate)) {
          // exists already, extract the performance data, and combine it
          SummaryPerformanceModel tmp = watchlistMapPerformance[perfDate]!;
          SummaryPerformanceModel newData = SummaryPerformanceModel(
            plDate: perfDate,
            plValue: tmp.plValue + perfList[i].plValue,
            totalAmount: tmp.totalAmount + perfList[i].totalAmount
          );

          // put the new data in the map
          watchlistMapPerformance[perfDate] = newData;
        }
        else {
          // not exists, we can create new data here
          watchlistMapPerformance[perfDate] = perfList[i];
        }
      }
    });

    // sort the map based on the keys
    watchlistMapPerformance = sortedMap<DateTime, SummaryPerformanceModel>(data: watchlistMapPerformance);

    // pl calculation helper
    double plCurrent;
    double plCurrentRatio;
    double? plBefore;
    DateTime priceDate;

    // initialize pl total and pl ratio
    _plTotalYear = 0;
    _plRatioYear = 0;
    _plTotalYearColor = primaryLight;
    _plRatioYearColor = primaryLight;

    // generate the year performance PL calendar list, as we will pass this
    // to the performance calendar so it can generate the correct P/L in
    // the performance calendar widget
    _yearCalendarPL.clear();
    _yearCalendarPL = List<CalendarDatePL>.generate(12, (index) {
      return CalendarDatePL(
        date: Globals.dfMMM.format(DateTime(useDate.year, (index+1), 1)),
        pl: null,
        plRatio: null,
      );
    });

    // loop thru all the response data, as this response data should have
    // all the 12 month + 1 last year one
    watchlistMapPerformance.forEach((key, value) {
      // check if we already have pl before?
      // if don't have, it means that it was the 1st data which we will
      // ignore as this will be used as base to calculate the rest.
      if (plBefore == null) {
        // calculate the plBefore
        plBefore = value.plValue;
      }
      else {
        // we already have pl before, so we can perform the calculation
        // for the current pl and pl ratio.

        // generate the price date
        priceDate = DateTime(key.year, key.month, 1);

        // no need to perform sophisticated calculation for this as
        // we can just perform normal pl calculation
        plCurrent = value.plValue;
        _plTotalYear += (plCurrent - plBefore!);

        plCurrentRatio = 0;
        if (value.totalAmount > 0) {
          plCurrentRatio = (plCurrent - plBefore!) / value.totalAmount;
        }
        _plRatioYear += plCurrentRatio;

        // update the year calendar PL list for this month
        _yearCalendarPL[key.month-1] = CalendarDatePL(
          date: Globals.dfMMM.format(priceDate),
          pl: (plCurrent - plBefore!),
          plRatio: (plCurrentRatio * 100),
        );

        // set pl before as pl current
        plBefore = plCurrent;
      }
    });

    // divide the pl ratio with the total data - 1
    _plRatioYear = (_plRatioYear / (watchlistMapPerformance.length - 1)) * 100;

    // get the correct pl color
    if (_plTotalYear > 0) {
      _plTotalYearColor = Colors.green;
    }
    else if (_plTotalYear < 0) {
      _plTotalYearColor = secondaryColor;
    }

    if (_plRatioYear > 0) {
      _plRatioYearColor = Colors.green;
    }
    else if (_plRatioYear < 0) {
      _plRatioYearColor = secondaryColor;
    }
  }

  Future<void> _getFirstAndLastDate(bool firstRun) async {
    if (firstRun) {
      // get first and last date
      await _watchlistAPI.findFirstLastDate(
        type: _args.type, 
        id: (_args.type != 'all' ? -1 : null)
      ).then((resp) {
        // set the first and end date
        _firstDate = resp.firstdate;
        _endDate = resp.enddate;

        // check if _endDate is lesser than end date
        // if so, then set current date as end date
        if (_currentDate.isAfter(_endDate)) {
          _currentDate = _endDate;
        }
      });
    }
  }

  Future<bool> _getPerformanceData({
    required String type,
    required DateTime currentDate,
    DateTime? newDate,
    bool? firstRun
  }) async {
    // check if this is first run or not?
    // if not first run, then show the loading screen
    if ((firstRun ?? false) == false) {
      LoadingScreen.instance().show(context: context);
    }

    // get the data
    await Future.wait([
      _getPerformanceDataMonthYear(type: type, currentDate: currentDate, newDate: newDate),
      _getPerformanceDataYear(type: type, currentDate: currentDate, newDate: newDate),
      _getFirstAndLastDate((firstRun ?? false)),
    ]).onError((error, stackTrace) {
      Log.error(
        message: 'Error getting data from server',
        error: error,
        stackTrace: stackTrace,
      );
      throw Exception('Error when try to get the data from server');
    }).whenComplete(() {
      // if not first run, remove the loading screen
      if ((firstRun ?? false) == false) {
        LoadingScreen.instance().hide();
      }
    },);

    return true;
  }
}