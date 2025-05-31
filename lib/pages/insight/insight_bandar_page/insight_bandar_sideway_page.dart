import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:my_wealth/_index.g.dart';

class InsightBandarSidewayPage extends StatefulWidget {
  const InsightBandarSidewayPage({super.key});

  @override
  State<InsightBandarSidewayPage> createState() => _InsightBandarSidewayPageState();
}

class _InsightBandarSidewayPageState extends State<InsightBandarSidewayPage> {
  final InsightAPI _insightAPI = InsightAPI();
  final CompanyAPI _companyAPI = CompanyAPI();
  final TextStyle _headerStyle = const TextStyle(color: accentColor, fontWeight: FontWeight.bold, fontSize: 12, overflow: TextOverflow.ellipsis);
  final ScrollController _scrollController = ScrollController();

  // sort helper
  late String _filterMode;
  late SortBoxType _filterSort;
  final Map<String, String> _filterList = {};

  late List<InsightSidewayModel> _sidewayList;
  late List<InsightSidewayModel> _sortedList;
  late int _maxOneDay;
  late int _avgOneDay;
  late int _avgOneWeek;

  late Future<bool> _getData;

  @override
  void initState() {
    super.initState();

    // list all the filter that we want to put here
    _filterList["nm"] = "Name";
    _filterList["pr"] = "Price";
    _filterList["pv"] = "Previous Price";
    _filterList["ad"] = "AVG Daily";
    _filterList["aw"] = "AVG Weekly";
    _filterList["1d"] = "One Day";
    _filterList["1w"] = "One Week";
    _filterList["1m"] = "One Month";

    // default filter mode to Code and ASC
    _filterMode = "nm";
    _filterSort = SortBoxType.ascending;

    // initialize all the default variable
    _maxOneDay = InsightSharedPreferences.getSidewayOneDayRate();
    _avgOneDay = InsightSharedPreferences.getSidewayAvgOneDay();
    _avgOneWeek = InsightSharedPreferences.getSidewayAvgOneWeek();
    _sidewayList = InsightSharedPreferences.getSidewayResult();

    // get the initial data either from API or from cache
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
          return const CommonErrorPage(
            errorText: 'Error loading bandar sideway page',
            isNeedScaffold: false,
          );
        }
        else if (snapshot.hasData) {
          return _body();
        }
        else {
          return const CommonLoadingPage(
            isNeedScaffold: false,
          );
        }
      })
    );
  }

  Widget _body() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          GestureDetector(
            onTap: (() async {
              await ShowInfoDialog(
                title: "Sideways",
                text: "This will find the average one day increment/decrement for 5 days, and one week increment/decrement for 10 days, based on the parameter configured above.\n\nThe parameter for the average one day or one week will be calculate between (+ and -).",
                okayColor: secondaryLight,
              ).show(context);
            }),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  "Sideways",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: accentColor
                  ),
                ),
                SizedBox(width: 5,),
                Icon(
                  Ionicons.information_circle,
                  size: 15,
                  color: accentColor,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10,),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Max 1 Day",
                      style: _headerStyle,
                    ),
                    const SizedBox(height: 5,),
                    NumberStepper(
                      bgColor: primaryDark,
                      textColor: textPrimary,
                      borderColor: primaryLight,
                      initialRate: _maxOneDay,
                      onTap: ((value) {
                        _maxOneDay = value;
                      })
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
                    Text(
                      "Avg 1 Day (+/-)",
                      style: _headerStyle,
                    ),
                    const SizedBox(height: 5,),
                    NumberStepper(
                      bgColor: primaryDark,
                      textColor: textPrimary,
                      borderColor: primaryLight,
                      initialRate: _avgOneDay,
                      onTap: ((value) {
                        _avgOneDay = value;
                      })
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
                    Text(
                      "Avg 1 Week (+/-)",
                      style: _headerStyle,
                    ),
                    const SizedBox(height: 5,),
                    NumberStepper(
                      bgColor: primaryDark,
                      textColor: textPrimary,
                      borderColor: primaryLight,
                      initialRate: _avgOneWeek,
                      onTap: ((value) {
                        _avgOneWeek = value;
                      })
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

              // get stock that currently sideway from API
              await _insightAPI.getSideway(
                maxOneDay: _maxOneDay,
                oneDayRange: _avgOneDay,
                oneWeekRange: _avgOneWeek,
              ).then((resp) async {
                // clear the sideway list and set response as sidewaylist
                _sidewayList.clear();
                _sidewayList = resp;
                
                // clear the sorted list and copy from the sideway list
                _sortedList.clear();
                _sortedList = List<InsightSidewayModel>.from(_sidewayList);

                // stored the sideway result to shared preferences
                await InsightSharedPreferences.setSideway(
                  oneDay: _maxOneDay,
                  avgOneDay: _avgOneDay,
                  avgOneWeek: _avgOneWeek,
                  sidewayList: _sidewayList
                );

                setState(() {
                  // just set stat to refresh the widget
                });
              }).whenComplete(() {
                // remove loading screen
                LoadingScreen.instance().hide();
              }).onError((error, stackTrace) {
                Log.error(
                  message: 'Error getting sideway data',
                  error: error,
                  stackTrace: stackTrace,
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(createSnackBar(message: "Error when try to retrieve sideway data"));
                }
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
            visible: (_sortedList.isNotEmpty),
            child: SortBox(
              bgColor: Colors.transparent,
              initialFilter: _filterMode,
              filterList: _filterList,
              filterSort: _filterSort,
              onChanged: (filter, sort) {
                setState(() {
                  if (_filterMode != filter) {
                    _filterMode = filter;
                    _filterData();
                  }

                  if (_filterSort != sort) {
                    _filterSort = sort;
                    _sortData();
                  }
                });
              },
            ),
          ),
          const SizedBox(height: 10,),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _sortedList.length,
              itemBuilder: ((context, index) {
                return InkWell(
                  onTap: (() {
                    _getCompanyDataAndGo(code: _sortedList[index].code);
                  }),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(0, 5, 0, 10),
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
                              _sortedList[index].code,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: accentColor,
                              ),
                            ),
                            const SizedBox(width: 5,),
                            Text(
                              _sortedList[index].name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            )
                          ],
                        ),
                        const SizedBox(height: 5,),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            ColumnInfo(
                              title: "Price",
                              titleColor: Colors.grey,
                              value: formatCurrency(
                                _sortedList[index].lastPrice.toDouble(),
                                showDecimal: false,
                                shorten: false
                              ),
                              valueColor: _getValueColorInt(
                                _sortedList[index].lastPrice,
                                _sortedList[index].prevClosingPrice
                              ),
                              valueSize: 15,
                            ),
                            ColumnInfo(
                              title: "Prev Price",
                              titleColor: Colors.grey,
                              value: formatCurrency(
                                _sortedList[index].prevClosingPrice.toDouble(),
                                showDecimal: false,
                                shorten: false
                              ),
                              valueSize: 15,
                            ),
                            ColumnInfo(
                              title: "AVG Daily",
                              titleColor: Colors.grey,
                              value: "${formatDecimalWithNull(
                                _sortedList[index].avgDaily,
                                times: 100,
                                decimal: 2
                              )}%",
                              valueColor: _getValueColorDouble(_sortedList[index].avgDaily, 0),
                              valueSize: 15,
                            ),
                          ],
                        ),
                        const SizedBox(height: 5,),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            ColumnInfo(
                              title: "One Day",
                              titleColor: Colors.grey,
                              value: "${formatDecimalWithNull(
                                _sortedList[index].oneDay,
                                times: 100,
                                decimal: 2
                              )}%",
                              valueColor: _getValueColorDouble(_sortedList[index].oneDay, 0),
                              valueSize: 15,
                            ),
                            ColumnInfo(
                              title: "One Week",
                              titleColor: Colors.grey,
                              value: "${formatDecimalWithNull(
                                _sortedList[index].oneWeek,
                                times: 100,
                                decimal: 2
                              )}%",
                              valueColor: _getValueColorDouble(_sortedList[index].oneWeek,  0),
                              valueSize: 15,
                            ),
                            ColumnInfo(
                              title: "One Month",
                              titleColor: Colors.grey,
                              value: "${formatDecimalWithNull(
                                _sortedList[index].oneMonth,
                                times: 100,
                                decimal: 2
                              )}%",
                              valueColor: _getValueColorDouble(_sidewayList[index].oneMonth, 0),
                              valueSize: 15,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Color _getValueColorInt(int? value, int? compare) {
    if (value == null || compare == null) {
      return Colors.white70;
    }

    if (value < compare) {
      return secondaryColor;
    }
    else if (value > compare) {
      return Colors.green;
    }
    else {
      return textPrimary;
    }
  }

  Color _getValueColorDouble(double? value, double? compare) {
    if (value == null || compare == null) {
      return Colors.white70;
    }

    if (value < compare) {
      return secondaryColor;
    }
    else if (value > compare) {
      return Colors.green;
    }
    else {
      return textPrimary;
    }
  }
  
  void _filterData() {
    // create a temporary list to contain all the result from filter
    List<InsightSidewayModel> tempFilter = List<InsightSidewayModel>.from(_sidewayList);
    
    // check which filter mode is being selected
    switch(_filterMode) {
      case "pr":
        tempFilter.sort(((a, b) => (a.lastPrice).compareTo((b.lastPrice))));
        break;
      case "pv":
        tempFilter.sort(((a, b) => ((a.prevClosingPrice)).compareTo((b.prevClosingPrice))));
        break;
      case "ad":
        tempFilter.sort(((a, b) => ((a.avgDaily ?? 0)).compareTo((b.oneDay ?? 0))));
        break;
      case "aw":
        tempFilter.sort(((a, b) => ((a.avgWeekly ?? 0)).compareTo((b.avgWeekly ?? 0))));
        break;
      case "1d":
        tempFilter.sort(((a, b) => ((a.oneDay ?? 0)).compareTo((b.oneDay ?? 0))));
        break;
      case "1w":
        tempFilter.sort(((a, b) => (a.oneWeek ?? 0).compareTo((b.oneWeek ?? 0))));
        break;
      case "1m":
        tempFilter.sort(((a, b) => (a.oneMonth ?? 0).compareTo((b.oneMonth ?? 0))));
        break;
      default:
        // nothing to do as we already copy it from the sideway list
        break;
    }

    // clear the sorted list
    _sortedList.clear();

    // check the filter type
    if (_filterSort == SortBoxType.ascending) {
      _sortedList = List<InsightSidewayModel>.from(tempFilter);
    }
    else {
      _sortedList = List<InsightSidewayModel>.from(tempFilter.reversed);
    }
  }

  void _sortData() {
    // regardless the data just reverse the current result
    _sortedList = _sortedList.reversed.toList();
  }

  Future<bool> _getInitData() async {
    // check if we already got result or not?
    if (_sidewayList.isEmpty) {
      // get the sideway data
      await _insightAPI.getSideway(
        maxOneDay: _maxOneDay,
        oneDayRange: _avgOneDay,
        oneWeekRange: _avgOneWeek,
      ).then((resp) async {
        _sidewayList = resp;

        // stored the sideway result to shared preferences
        await InsightSharedPreferences.setSideway(
          oneDay: _maxOneDay,
          avgOneDay: _avgOneDay,
          avgOneWeek: _avgOneWeek,
          sidewayList: _sidewayList
        );

        // set the sorted from side way
        _sortedList = List<InsightSidewayModel>.from(_sidewayList);
      }).onError((error, stackTrace) {
        Log.error(
          message: 'Error getting sideway data',
          error: error,
          stackTrace: stackTrace,
        );
        throw Exception('Error when get sideway data');
      },);
    }
    else {
      // already got result, just set the loading into false
      // so we can render the page automatically
      _sortedList = List<InsightSidewayModel>.from(_sidewayList);
    }
    
    return true;
  }

  Future<void> _getCompanyDataAndGo({required String code}) async {
    // show loading screen
    LoadingScreen.instance().show(context: context);

    // get the company data and navigate to the company page
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
      // remove the loading screen once finished
      LoadingScreen.instance().hide();
    },);
  }
}