import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:my_wealth/api/watchlist_api.dart';
import 'package:my_wealth/model/user/user_login.dart';
import 'package:my_wealth/model/watchlist/watchlist_performance_model.dart';
import 'package:my_wealth/storage/prefs/shared_user.dart';
import 'package:my_wealth/themes/colors.dart';
import 'package:my_wealth/utils/arguments/company_detail_args.dart';
import 'package:my_wealth/utils/arguments/watchlist_list_args.dart';
import 'package:my_wealth/utils/function/computation.dart';
import 'package:my_wealth/utils/function/format_currency.dart';
import 'package:my_wealth/utils/globals.dart';
import 'package:my_wealth/utils/log.dart';
import 'package:my_wealth/widgets/components/performance_calendar.dart';
import 'package:my_wealth/widgets/list/row_child.dart';
import 'package:my_wealth/widgets/modal/overlay_loading_modal.dart';
import 'package:my_wealth/widgets/page/common_error_page.dart';
import 'package:my_wealth/widgets/page/common_loading_page.dart';

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

  late Color _unrealisedColor;
  late Color _realisedColor;

  late Future<bool> _getData;
  late Map<DateTime, WatchlistPerformanceModel> _watchlistMapPerformance;
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
        companyFavourite:
            (_watchlistArgs.watchList.watchlistFavouriteId > 0 ? true : false),
        favouritesId: _watchlistArgs.watchList.watchlistFavouriteId,
        type: _watchlistArgs.type);

    // default the calendar selection to month
    _calendarSelection = "m";

    // default calendar selection to this month and year
    _currentDate = DateTime.now();

    // get the computation for the watchlist
    _watchlistComputation = detailWatchlistComputation(
        watchlist: _watchlistArgs.watchList, riskFactor: _userInfo.risk);

    // set the unrealised and realised default color
    _unrealisedColor = textPrimary;
    _realisedColor = textPrimary;

    // check the unrealised and realised after computation to showed the correct color
    if (_watchlistComputation.totalUnrealisedGain > 0) {
      _unrealisedColor = Colors.green;
    } else if (_watchlistComputation.totalUnrealisedGain < 0) {
      _unrealisedColor = secondaryColor;
    }

    if (_watchlistComputation.totalRealisedGain > 0) {
      _realisedColor = Colors.green;
    } else if (_watchlistComputation.totalRealisedGain < 0) {
      _realisedColor = secondaryColor;
    }

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

    // initialize the map
    _watchlistMapPerformance = {};

    // initialize the calendar PL
    _monthYearCalendarPL = [];
    _yearCalendarPL = [];

    // get the data from API
    _getData =
        _getInitData(currentDate: _currentDate, newDate: null, firstRun: true);
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
            return const CommonErrorPage(
                errorText: 'Error loading watchlist performance');
          } else if (snapshot.hasData) {
            return _generatePage();
          } else {
            return const CommonLoadingPage();
          }
        }));
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
            )),
        actions: <Widget>[
          IconButton(
            onPressed: (() {
              Navigator.pushNamed(
                  context, '/company/detail/${_watchlistArgs.type}',
                  arguments: _companyArgs);
            }),
            icon: const Icon(Ionicons.business_outline),
          )
        ],
        title: const Center(
            child: Text(
          "Performance Calendar",
          style: TextStyle(
            color: secondaryColor,
          ),
        )),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            width: double.infinity,
            color: _watchlistComputation.riskColor,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    color: primaryDark,
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
                                      _watchlistArgs.watchList
                                          .watchlistCompanyNetAssetValue,
                                      false,
                                      true,
                                      false,
                                      2),
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                (_watchlistComputation.priceDiff == 0
                                    ? const Icon(
                                        Ionicons.remove_outline,
                                        color: textPrimary,
                                        size: 15,
                                      )
                                    : (_watchlistComputation.priceDiff > 0
                                        ? const Icon(
                                            Ionicons.caret_up,
                                            color: Colors.green,
                                            size: 12,
                                          )
                                        : const Icon(
                                            Ionicons.caret_down,
                                            color: secondaryColor,
                                            size: 12,
                                          ))),
                                const SizedBox(
                                  width: 5,
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(
                                    color: (_watchlistComputation.priceDiff == 0
                                        ? textPrimary
                                        : (_watchlistComputation.priceDiff > 0
                                            ? Colors.green
                                            : secondaryColor)),
                                    width: 2.0,
                                    style: BorderStyle.solid,
                                  ))),
                                  child: Text(
                                    formatCurrencyWithNull(
                                        _watchlistComputation.priceDiff,
                                        false,
                                        true,
                                        false,
                                        2),
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
                                const SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  Globals.dfddMMyyyy.format(_watchlistArgs
                                      .watchList.watchlistCompanyLastUpdate!
                                      .toLocal()),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            RowChild(
                                headerText: "AVG PRICE",
                                valueText:
                                    (_watchlistComputation.totalCurrentShares >
                                            0
                                        ? formatCurrency(
                                            _watchlistComputation.totalCost /
                                                _watchlistComputation
                                                    .totalCurrentShares)
                                        : "-")),
                            const SizedBox(
                              width: 10,
                            ),
                            RowChild(
                                headerText: "COST",
                                valueText: formatCurrency(
                                    _watchlistComputation.totalCost)),
                            const SizedBox(
                              width: 10,
                            ),
                            RowChild(
                                headerText: "VALUE",
                                valueText: formatCurrency(
                                    _watchlistComputation.totalValue)),
                          ],
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            RowChild(
                                headerText: "SHARES",
                                valueText: formatCurrency(
                                    _watchlistComputation.totalCurrentShares)),
                            const SizedBox(
                              width: 10,
                            ),
                            RowChild(
                                headerText: "UNREALISED",
                                valueText: formatCurrency(
                                    _watchlistComputation.totalUnrealisedGain),
                                valueColor: _unrealisedColor),
                            const SizedBox(
                              width: 10,
                            ),
                            RowChild(
                                headerText: "REALISED",
                                valueText: formatCurrency(
                                    _watchlistComputation.totalRealisedGain),
                                valueColor: _realisedColor),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 15,
          ),
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
                  const SizedBox(
                    height: 15,
                  ),
                  _getSubPage(),
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
                    // get the data
                    _getData = _getInitData(
                        currentDate: _currentDate, newDate: newDate);

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
                const SizedBox(
                  width: 5,
                ),
                const Icon(
                  Ionicons.caret_down_sharp,
                  color: primaryLight,
                  size: 10,
                ),
              ],
            ),
          ));
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

                            // check the new date year and current date year
                            // if different then process to get the data
                            if (newDate.year == _currentDate.year) {
                              // check month whether same or not??
                              if (newDate.month == _currentDate.month) {
                                // all the same, no need to fetch the data
                                return;
                              }
                            }

                            // set state and get the data if the selected year is
                            // different with current year.
                            setState(() {
                              // get the data
                              _getData = _getInitData(
                                  currentDate: _currentDate, newDate: newDate);

                              // set the current date with the selected
                              // year.
                              _currentDate = newDate;
                            });
                          }),
                        ),
                      ),
                    );
                  }));
            }),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Text("${_currentDate.year}"),
                const SizedBox(
                  width: 5,
                ),
                const Icon(
                  Ionicons.caret_down_sharp,
                  color: primaryLight,
                  size: 10,
                ),
              ],
            ),
          ));
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
        const SizedBox(
          height: 10,
        ),
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
        const SizedBox(
          height: 10,
        ),
        PerformanceCalendar(
          month: _currentDate.month,
          year: _currentDate.year,
          data: _yearCalendarPL,
          type: PerformanceCalendarType.year,
        ),
      ],
    );
  }

  Future<void> _getMonthYearData(
      {required DateTime currentDate, DateTime? newDate}) async {
    // create variable to knew which date to use
    DateTime useDate = currentDate;

    // check whether this is the same month and year or not?
    // if same then skip
    if (newDate != null) {
      if (currentDate.year == newDate.year &&
          currentDate.month == newDate.month) {
        return;
      } else {
        useDate = newDate;
      }
    } else {
      useDate = currentDate;
    }

    // if not then fetch the data
    await _watchlistAPI
        .getWatchlistPerformanceMonthYear(_watchlistArgs.type,
            _watchlistArgs.watchList.watchlistId, useDate.month, useDate.year)
        .then((resp) {
      // pl calculation helper
      double? plBefore;
      double plCurrent;

      // initialize pl total and pl ratio
      _plTotal = 0;
      _plRatio = 0;
      _plTotalColor = primaryLight;
      _plRatioColor = primaryLight;

      // generate the map for the watchlist performance, as we will pass this
      // to the performance calendar so it can generate the correct P/L in
      // the performance calendar widget
      _watchlistMapPerformance.clear();
      for (int i = 0; i < resp.length; i++) {
        // calculate pl
        plCurrent = (resp[i].buyTotal * resp[i].currentPrice) -
            (resp[i].buyTotal * resp[i].buyAvg);

        // check if pl before is null? if null then assign current pl
        if (plBefore == null) {
          plBefore = plCurrent;
        } else {
          // if already here it means we already have both previous and
          // current pl, so we can calculate the pl difference
          _plTotal += (plCurrent - plBefore);

          // calculate the _plRatio
          if (resp[i].buyAmount > 0) {
            _plRatio += ((plCurrent - plBefore) / resp[i].buyAmount);
          }

          // set pl before to pl current
          plBefore = plCurrent;
        }

        // date shouldn't be duplicate, but if duplicate then API is fucked
        // up, just throw some error here if we found the date is duplicate
        if (_watchlistMapPerformance.containsKey(resp[i].buyDate)) {
          Log.error(message: 'Duplicate date in the API result');
          throw Exception('Duplicate Key found in the API Result');
        } else {
          // this is new data
          _watchlistMapPerformance[resp[i].buyDate] = resp[i];
        }
      }

      // divide the pl ratio with the total data - 1
      _plRatio = (_plRatio / (resp.length - 1)) * 100;

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

      // generate the calendar PL
      _monthYearCalendarPL.clear();
      _monthYearCalendarPL = _generateDateMonthYear();
    });
  }

  Future<void> _getYearData(
      {required DateTime currentDate, DateTime? newDate}) async {
    // create variable to knew which date to use
    DateTime useDate = currentDate;

    // check if the year is the same or not? if the same then no need to do.
    if (newDate != null) {
      if (currentDate.year == newDate.year) {
        return;
      } else {
        useDate = newDate;
      }
    } else {
      useDate = currentDate;
    }

    // get the performance year
    await _watchlistAPI
        .getWatchlistPerformanceYear(_watchlistArgs.type,
            _watchlistArgs.watchList.watchlistId, useDate.year)
        .then((resp) {
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
          date: Globals.dfMMM.format(DateTime(useDate.year, (index + 1), 1)),
          pl: null,
          plRatio: null,
        );
      });

      for (int i = 0; i < resp.length; i++) {
        // check if we already have pl before?
        // if don't have, it means that it was the 1st data which we will
        // ignore as this will be used as base to calculate the rest.
        if (plBefore == null) {
          // calculate the plBefore
          plBefore =
              (resp[i].buyTotal * resp[i].currentPrice) - resp[i].buyAmount;
        } else {
          // we already have pl before, so we can perform the calculation
          // for the current pl and pl ratio.

          // generate the price date
          priceDate = DateTime(resp[i].buyDate.year, resp[i].buyDate.month, 1);

          // no need to perform sophisticated calculation for this as
          // we can just perform normal pl calculation
          plCurrent =
              (resp[i].buyTotal * resp[i].currentPrice) - resp[i].buyAmount;
          _plTotalYear += (plCurrent - plBefore);

          plCurrentRatio = 0;
          if (resp[i].buyAmount > 0) {
            plCurrentRatio = (plCurrent - plBefore) / resp[i].buyAmount;
          }
          _plRatioYear += plCurrentRatio;

          // update the year calendar PL list for this month
          _yearCalendarPL[resp[i].buyDate.month - 1] = CalendarDatePL(
            date: Globals.dfMMM.format(priceDate),
            pl: (plCurrent - plBefore),
            plRatio: (plCurrentRatio * 100),
          );

          // set pl before as pl current
          plBefore = plCurrent;
        }
      }

      // divide the pl ratio with the total data - 1
      _plRatioYear = (_plRatioYear / (resp.length - 1)) * 100;

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
    });
  }

  Future<void> _getFirstAndLastDate(bool firstRun) async {
    if (firstRun) {
      // get first and last date
      await _watchlistAPI
          .findFirstLastDate(
              _watchlistArgs.type, _watchlistArgs.watchList.watchlistId)
          .then((resp) {
        // set the first and end date
        _firstDate = resp.firstdate;
        _endDate = resp.enddate;

        // check if current date is after end date
        // if so then set current date as end
        if (_currentDate.isAfter(_endDate)) {
          _currentDate = _endDate;
        }
      });
    }
  }

  Future<bool> _getInitData({
    required DateTime currentDate,
    DateTime? newDate,
    bool? firstRun,
  }) async {
    // if this is not a first run then show the loader dialog
    if ((firstRun ?? false) == false) {
      LoadingScreen.instance().show(context: context);
    }

    await Future.wait([
      _getMonthYearData(currentDate: currentDate, newDate: newDate),
      _getYearData(currentDate: currentDate, newDate: newDate),
      _getFirstAndLastDate((firstRun ?? false)),
    ]).onError((error, stackTrace) {
      Log.error(
        message: 'Error getting data from server',
        error: error,
        stackTrace: stackTrace,
      );
      throw Exception('Error when try to get the data from server');
    }).whenComplete(
      () {
        // if this is not the  first run, it means that the loader dialog is being
        // called on top, close the loader dialog.
        if ((firstRun ?? false) == false) {
          LoadingScreen.instance().hide();
        }
      },
    );

    return true;
  }

  List<CalendarDatePL> _generateDateMonthYear() {
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
      if (_watchlistMapPerformance.containsKey(beforeDate)) {
        plBefore = (_watchlistMapPerformance[beforeDate]!.buyTotal *
                _watchlistMapPerformance[beforeDate]!.currentPrice) -
            (_watchlistMapPerformance[beforeDate]!.buyTotal *
                _watchlistMapPerformance[beforeDate]!.buyAvg);
      }

      if (_watchlistMapPerformance.containsKey(firstDate) && plBefore != null) {
        plCurrent = (_watchlistMapPerformance[firstDate]!.buyTotal *
                _watchlistMapPerformance[firstDate]!.currentPrice) -
            (_watchlistMapPerformance[firstDate]!.buyTotal *
                _watchlistMapPerformance[firstDate]!.buyAvg);

        // calculate pl and pl ratio
        pl = plCurrent - plBefore;
        if (_watchlistMapPerformance[firstDate]!.buyAmount > 0) {
          plRatio = (pl / _watchlistMapPerformance[firstDate]!.buyAmount);
        } else {
          plRatio = 0;
        }
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
}
