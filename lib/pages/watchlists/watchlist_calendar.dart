import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ionicons/ionicons.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:my_wealth/api/watchlist_api.dart';
import 'package:my_wealth/model/user/user_login.dart';
import 'package:my_wealth/model/watchlist/watchlist_performance_model.dart';
import 'package:my_wealth/model/watchlist/watchlist_performance_year_model.dart';
import 'package:my_wealth/storage/prefs/shared_broker.dart';
import 'package:my_wealth/storage/prefs/shared_user.dart';
import 'package:my_wealth/themes/colors.dart';
import 'package:my_wealth/utils/arguments/company_detail_args.dart';
import 'package:my_wealth/utils/arguments/watchlist_list_args.dart';
import 'package:my_wealth/utils/function/computation.dart';
import 'package:my_wealth/utils/function/format_currency.dart';
import 'package:my_wealth/widgets/components/performance_calendar.dart';
import 'package:my_wealth/widgets/list/row_child.dart';
import 'package:my_wealth/widgets/page/common_error_page.dart';
import 'package:my_wealth/widgets/page/common_loading_page.dart';

class WatchlistCalendarPage extends StatefulWidget {
  final Object? args;
  const WatchlistCalendarPage({Key? key, required this.args}) : super(key: key);

  @override
  State<WatchlistCalendarPage> createState() => _WatchlistCalendarPageState();
}

class _WatchlistCalendarPageState extends State<WatchlistCalendarPage> {
  final ScrollController _scrollController = ScrollController();
  
  final DateFormat _df = DateFormat('dd/MM/yyyy');
  final DateFormat _df2 = DateFormat('yyyy/MM');
  final DateFormat _df3 = DateFormat('MMM yyyy');
  final DateFormat _df4 = DateFormat('MMM');

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
  late Map<DateTime, WatchlistPerformanceYearModel> _watchlistMapYearPerformance;
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

    // get the first and last date from broker, well assume that this is the
    // same as price date so we don't need to call another API just to get the
    // first and last date
    _firstDate = BrokerSharedPreferences.getBrokerMinDate()!;
    _endDate = BrokerSharedPreferences.getBrokerMaxDate()!;

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
    _watchlistComputation = detailWatchlistComputation(watchlist: _watchlistArgs.watchList, riskFactor: _userInfo.risk);

    // set the unrealised and realised default color
    _unrealisedColor = textPrimary;
    _realisedColor = textPrimary;

    // check the unrealised and realised after computation to showed the correct color
    if (_watchlistComputation.totalUnrealisedGain > 0) {
      _unrealisedColor = Colors.green;
    }
    else if (_watchlistComputation.totalUnrealisedGain < 0) {
      _unrealisedColor = secondaryColor;
    }

    if (_watchlistComputation.totalRealisedGain > 0) {
      _realisedColor = Colors.green;
    }
    else if (_watchlistComputation.totalRealisedGain < 0) {
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
    _watchlistMapYearPerformance = {};
    
    // initialize the calendar PL
    _monthYearCalendarPL = [];
    _yearCalendarPL = [];

    // get the data from API
    _getData = _getInitData();
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
        actions: <Widget>[
          IconButton(
            onPressed: (() {
              Navigator.pushNamed(context, '/company/detail/${_watchlistArgs.type}', arguments: _companyArgs);
            }),
            icon: const Icon(
              Ionicons.business_outline
            ),
          )
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
      body: SingleChildScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
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
                  const SizedBox(width: 10,),
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
                                    formatCurrencyWithNull(_watchlistArgs.watchList.watchlistCompanyNetAssetValue, false, true, false, 2),
                                  ),
                                  const SizedBox(width: 5,),
                                  (_watchlistComputation.priceDiff == 0 ? const Icon(Ionicons.remove_outline, color: textPrimary, size: 15,) : (_watchlistComputation.priceDiff > 0 ? const Icon(Ionicons.caret_up, color: Colors.green, size: 12,) : const Icon(Ionicons.caret_down, color: secondaryColor, size: 12,))),
                                  const SizedBox(width: 5,),
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: (_watchlistComputation.priceDiff == 0 ? textPrimary : (_watchlistComputation.priceDiff > 0 ? Colors.green : secondaryColor)),
                                          width: 2.0,
                                          style: BorderStyle.solid,
                                        )
                                      )
                                    ),
                                    child: Text(
                                      formatCurrencyWithNull(_watchlistComputation.priceDiff, false, true, false, 2),
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
                                    _df.format(_watchlistArgs.watchList.watchlistCompanyLastUpdate!.toLocal()),
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
                              RowChild(headerText: "AVG PRICE", valueText: (_watchlistComputation.totalCurrentShares > 0 ? formatCurrency(_watchlistComputation.totalCost / _watchlistComputation.totalCurrentShares) : "-")),
                              const SizedBox(width: 10,),
                              RowChild(headerText: "COST", valueText: formatCurrency(_watchlistComputation.totalCost)),
                              const SizedBox(width: 10,),
                              RowChild(headerText: "VALUE", valueText: formatCurrency(_watchlistComputation.totalValue)),
                            ],
                          ),
                          const SizedBox(height: 5,),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              RowChild(headerText: "SHARES", valueText: formatCurrency(_watchlistComputation.totalCurrentShares)),
                              const SizedBox(width: 10,),
                              RowChild(headerText: "UNREALISED", valueText: formatCurrency(_watchlistComputation.totalUnrealisedGain), valueColor: _unrealisedColor),
                              const SizedBox(width: 10,),
                              RowChild(headerText: "REALISED", valueText: formatCurrency(_watchlistComputation.totalRealisedGain), valueColor: _realisedColor),
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                SizedBox(
                  width: 150,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                    child: const Text("Select Month")
                  ),
                  // TODO: unremark once the API fixed
                  // child: CupertinoSegmentedControl(
                  //   children: const {
                  //     "m": Text("Month"),
                  //     "y": Text("Year"),
                  //   },
                  //   onValueChanged: ((value) {
                  //     String selectedValue = value.toString();
                      
                  //     setState(() {
                  //       _calendarSelection = selectedValue;
                  //     });
                  //   }),
                  //   groupValue: _calendarSelection,
                  //   selectedColor: secondaryColor,
                  //   borderColor: secondaryDark,
                  //   pressedColor: primaryDark,
                  // ),
                ),
                _dateSelector(),
              ],
            ),
            const SizedBox(height: 15,),
            _getSubPage(),
          ],
        ),
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
                  _currentDate = newDate;
                  _getData = _getInitData();
                });
              }
            });
          }),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Text(_df2.format(_currentDate)),
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
    else {
      return Container(
        width: 100,
        height: 20,
        padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
        child: GestureDetector(
          onTap: (() {
            // TODO: show year only
            debugPrint("Show year selection");
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
                    "${_df3.format(_currentDate)} P&L",
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

  Future<bool> _getInitData() async {
    await Future.wait([
      _watchlistAPI.getWatchlistPerformanceMonthYear(
        _watchlistArgs.type,
        _watchlistArgs.watchList.watchlistId,
        _currentDate.month,
        _currentDate.year
      ).then((resp) {
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
          plCurrent = (resp[i].buyTotal * resp[i].currentPrice) - (resp[i].buyTotal * resp[i].buyAvg);

          // check if pl before is null? if null then assign current pl
          if (plBefore == null) {
            plBefore = plCurrent;
          }
          else {
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
            debugPrint("[ERROR] duplicate date in the API result");
            throw 'Duplicate Key found in the API Result';
          }
          else {
            // this is new data
            _watchlistMapPerformance[resp[i].buyDate] = resp[i];
          }
        }

        // divide the pl ratio with the total data - 1
        _plRatio = (_plRatio / (resp.length - 1)) * 100;

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
        _monthYearCalendarPL = _generateDateMonthYear();
      }),
      // get the performance year
      _watchlistAPI.getWatchlistPerformanceYear(
        _watchlistArgs.type,
        _watchlistArgs.watchList.watchlistId,
        _currentDate.year
      ).then((resp) {
        // pl calculation helper
        double? plBefore;
        double plCurrent;
        double plCurrentRatio;
        double? prevTotalAmount;
        double? prevTotalShare;
        DateTime priceDate;

        // initialize pl total and pl ratio
        _plTotalYear = 0;
        _plRatioYear = 0;
        _plTotalYearColor = primaryLight;
        _plRatioYearColor = primaryLight;

        // generate the map for the watchlist performance, as we will pass this
        // to the performance calendar so it can generate the correct P/L in
        // the performance calendar widget
        _watchlistMapYearPerformance.clear();
        
        // generate year calendar here
        _yearCalendarPL.clear();
        _yearCalendarPL = List<CalendarDatePL>.generate(12, (index) {
          return CalendarDatePL(
            date: _df4.format(DateTime(_currentDate.year, index, 1)),
            pl: null,
            plRatio: null,
          );
        });

        for (int i = 0; i < resp.length; i++) {
          // generate the price date
          priceDate = DateTime.parse("${resp[i].priceDate}-01");

          // ensure that the share is not null
          if (resp[i].watchlistTotalShare != null) {
            // get the previous total amount
            prevTotalAmount = resp[i].watchlistTotalAmount!;
            prevTotalShare = resp[i].watchlistTotalShare!;
            
            // we got data, check whether this is first data or not?
            if (plBefore == null) {
              // this is first data
              plBefore = (resp[i].watchlistTotalShare! * resp[i].priceAvg) - (resp[i].watchlistTotalAmount!);
            }
            else {
              // this is not the first data, we can calculate the current pl here.
              plCurrent = (resp[i].watchlistTotalShare! * resp[i].priceAvg) - (resp[i].watchlistTotalAmount!);

              // then we can get the pl total year
              _plTotalYear += (plCurrent - plBefore);
              
              // check the buy amount ensure not null and more than zero
              if ((resp[i].watchlistTotalAmount ?? 0) > 0) {
                plCurrentRatio = (plCurrent - plBefore) / resp[i].watchlistTotalAmount!; 
              }
              else {
                plCurrentRatio = 0;
              }
              _plRatioYear += plCurrentRatio;

              // update year calendar PL
              _yearCalendarPL[priceDate.month-1] = CalendarDatePL(
                date: _df4.format(priceDate),
                pl: (plCurrent - plBefore),
                plRatio: (plCurrentRatio * 100),
              );

              // set pl before as pl current
              plBefore = plCurrent;
            }
          }
          else {
            // the total share is null, check if we already have plBefore?
            // if got it means that we can use plBefore as plCurrent
            if (plBefore != null) {
              // pl before is not null means we already have data previously
              plCurrent = ((prevTotalShare ?? 0) * resp[i].priceAvg) - (prevTotalAmount ?? 0);
              
              _plTotalYear += (plCurrent - plBefore);
              
              // check the buy amount ensure not null and more than zero
              if ((prevTotalAmount ?? 0) > 0) {
                plCurrentRatio = (plCurrent - plBefore) / prevTotalAmount!; 
              }
              else {
                plCurrentRatio = 0;
              }
              _plRatioYear += plCurrentRatio;

              // update year calendar
              _yearCalendarPL[priceDate.month-1] = CalendarDatePL(
                date: _df4.format(priceDate),
                pl: (plCurrent - plBefore),
                plRatio: (plCurrentRatio * 100),
              );

              // set pl before as pl current
              plBefore = plCurrent;
            }
          }

          // date shouldn't be duplicate, but if duplicate then API is fucked
          // up, just throw some error here if we found the date is duplicate
          if (_watchlistMapYearPerformance.containsKey(priceDate)) {
            debugPrint("[ERROR] duplicate date in the API result");
            throw 'Duplicate Key found in the API Result';
          }
          else {
            // this is new data
            _watchlistMapYearPerformance[priceDate] = resp[i];
          }
        }

        // divide the pl ratio with the total data - 1
        _plRatioYear = (_plRatioYear / (resp.length - 1)) * 100;

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
      }),
    ]).onError((error, stackTrace) {
      debugPrint(error.toString());
      throw 'Error when try to get the data from server';
    });

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
        plBefore = 
          (_watchlistMapPerformance[beforeDate]!.buyTotal * _watchlistMapPerformance[beforeDate]!.currentPrice) -
          (_watchlistMapPerformance[beforeDate]!.buyTotal * _watchlistMapPerformance[beforeDate]!.buyAvg);
      }

      if (_watchlistMapPerformance.containsKey(firstDate) && plBefore != null) {
        plCurrent = 
          (_watchlistMapPerformance[firstDate]!.buyTotal * _watchlistMapPerformance[firstDate]!.currentPrice) -
          (_watchlistMapPerformance[firstDate]!.buyTotal * _watchlistMapPerformance[firstDate]!.buyAvg);

        // calculate pl and pl ratio
        pl = plCurrent - plBefore;
        if (_watchlistMapPerformance[firstDate]!.buyAmount > 0) {
          plRatio = (pl / _watchlistMapPerformance[firstDate]!.buyAmount);
        }
        else {
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