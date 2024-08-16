import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:my_wealth/api/company_api.dart';
import 'package:my_wealth/model/company/company_detail_model.dart';
import 'package:my_wealth/model/user/user_login.dart';
import 'package:my_wealth/themes/colors.dart';
import 'package:my_wealth/utils/arguments/company_detail_args.dart';
import 'package:my_wealth/utils/arguments/insight_stock_sub_list_args.dart';
import 'package:my_wealth/utils/dialog/create_snack_bar.dart';
import 'package:my_wealth/utils/function/format_currency.dart';
import 'package:my_wealth/utils/function/risk_color.dart';
import 'package:my_wealth/storage/prefs/shared_user.dart';
import 'package:my_wealth/utils/log.dart';
import 'package:my_wealth/widgets/components/search_box.dart';
import 'package:my_wealth/widgets/modal/overlay_loading_modal.dart';
import 'package:my_wealth/widgets/page/common_error_page.dart';
import 'package:my_wealth/widgets/page/common_loading_page.dart';

class InsightStockSubListPage extends StatefulWidget {
  final Object? args;
  const InsightStockSubListPage({super.key, required this.args});

  @override
  State<InsightStockSubListPage> createState() => _InsightStockSubListPageState();
}

class _InsightStockSubListPageState extends State<InsightStockSubListPage> {
  final CompanyAPI _companyAPI = CompanyAPI();
  final ScrollController _scrollController = ScrollController();

  late InsightStockSubListArgs _args;
  late List<CompanyDetailModel> _companyList;
  late List<CompanyDetailModel> _companyFilter;
  late String _filterMode;
  late String _filterSort;
  final Map<String, String> _filterList = {};
  late UserLoginInfoModel? _userInfo;

  late Future<bool> _getData;

  @override
  void initState() {
    _args = widget.args as InsightStockSubListArgs;
    _userInfo = UserSharedPreferences.getUserInfo();

    // generate the filter list
    _filterList["AB"] = "Code";
    _filterList["1d"] = "One Day";
    _filterList["1w"] = "One Week";
    _filterList["1m"] = "One Month";
    _filterList["3m"] = "Three Month";
    _filterList["6m"] = "Six Month";
    _filterList["1y"] = "One Year";
    _filterList["3y"] = "Three Year";
    _filterList["5y"] = "Five Year";

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
            errorText: 'Error loading Sub Sector Information',
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
      },
    );
  }

  Widget _body() {
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
        title: Center(
          child: Text(
            _args.subName,
            style: const TextStyle(
              color: secondaryColor,
            ),
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SearchBox(
            filterMode: _filterMode,
            filterList: _filterList,
            filterSort: _filterSort,
            onFilterSelect: ((value) {
              setState(() {
                _filterMode = value;
                _sortedCompanyList();
              });
            }),
            onSortSelect: ((value) {
              setState(() {
                _filterSort = value;
                _sortedCompanyList();
              });
            })
          ),
          const SizedBox(height: 10,),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _companyFilter.length,
              itemBuilder: ((context, index) {
                double currentPrice = (_companyFilter[index].companyNetAssetValue ?? 0);
                double prevPrice = (_companyFilter[index].companyPrevPrice ?? 0);
                Color color = riskColor(currentPrice, prevPrice, _userInfo!.risk);
                
                return InkWell(
                  onTap: (() {
                    _getCompanyAndGo(code: _companyFilter[index].companySymbol!);
                  }),
                  child: Container(
                    color: color,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        const SizedBox(width: 10,),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: const BoxDecoration(
                              color: primaryColor,
                              border: Border(
                                bottom: BorderSide(
                                  color: primaryLight,
                                  style: BorderStyle.solid,
                                  width: 1.0,
                                )
                              )
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Expanded(
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            '(${_companyFilter[index].companySymbol})',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: accentColor,
                                            ),
                                          ),
                                          const SizedBox(width: 5,),
                                          Expanded(
                                            child: SizedBox(
                                              child: Text(
                                                _companyFilter[index].companyName,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    ),
                                    const SizedBox(width: 5,),
                                    Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                            color: color,
                                            style: BorderStyle.solid,
                                            width: 2.0,
                                          )
                                        )
                                      ),
                                      child: Text(
                                        '${formatCurrency(currentPrice, false, false, false)} (${formatCurrency((currentPrice-prevPrice), false, false, false)})',
                                        style: const TextStyle(
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10,),
                                Container(
                                  color: primaryDark,
                                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: <Widget>[
                                      _periodBox(title: "1d", value: (_companyFilter[index].companyDailyReturn ?? 0)),
                                      _periodBox(title: "1w", value: (_companyFilter[index].companyWeeklyReturn ?? 0)),
                                      _periodBox(title: "1m", value: (_companyFilter[index].companyMonthlyReturn ?? 0)),
                                      _periodBox(title: "3m", value: (_companyFilter[index].companyQuarterlyReturn ?? 0)),
                                      _periodBox(title: "6m", value: (_companyFilter[index].companySemiAnnualReturn ?? 0)),
                                      _periodBox(title: "1y", value: (_companyFilter[index].companyYearlyReturn ?? 0)),
                                      _periodBox(title: "3y", value: (_companyFilter[index].companyThreeYear ?? 0)),
                                      _periodBox(title: "5y", value: (_companyFilter[index].companyFiveYear ?? 0)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 30,),
        ],
      ),
    );
  }

  Widget _periodBox({required String title, required double value}) {
    Color color = Colors.white;
    if (value < 0) {
      color = secondaryColor;
    }
    else if (value > 0) {
      color = Colors.green;
    }

    return Expanded(
      child: Container(
        padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.fromLTRB(0, 0, 0, 5),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: color,
                    style: BorderStyle.solid,
                    width: 1.0,
                  )
                )
              ),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Text(
              formatDecimalWithNull(value, 100, 1),
              style: TextStyle(
                fontSize: 10,
                color: color
              ),
            ),
          ],
        ),
      ),
    );
  }

  // here we will sorted the company list based on the filter type and filter mode
  void _sortedCompanyList() {
    // clear the company filter first
    _companyFilter.clear();

    // if the filter mode is "AB" which is code, then just copy from the _companyList
    if (_filterMode == "AB") {
      // check the sort methode?
      if (_filterSort == "ASC") {
        _companyFilter = List<CompanyDetailModel>.from(_companyList);
      }
      else {
        _companyFilter = List<CompanyDetailModel>.from(_companyList.reversed);
      }
    }
    else {
      List<CompanyDetailModel> tempFilter = List<CompanyDetailModel>.from(_companyList);
      switch(_filterMode) {
        case "1d":
          tempFilter.sort(((a, b) => (a.companyDailyReturn ?? 0).compareTo((b.companyDailyReturn ?? 0))));
          break;
        case "1w":
          tempFilter.sort(((a, b) => (a.companyWeeklyReturn ?? 0).compareTo((b.companyWeeklyReturn ?? 0))));
          break;
        case "1m":
          tempFilter.sort(((a, b) => (a.companyMonthlyReturn ?? 0).compareTo((b.companyMonthlyReturn ?? 0))));
          break;
        case "3m":
          tempFilter.sort(((a, b) => (a.companyQuarterlyReturn ?? 0).compareTo((b.companyQuarterlyReturn ?? 0))));
          break;
        case "6m":
          tempFilter.sort(((a, b) => (a.companySemiAnnualReturn ?? 0).compareTo((b.companySemiAnnualReturn ?? 0))));
          break;
        case "1y":
          tempFilter.sort(((a, b) => (a.companyYearlyReturn ?? 0).compareTo((b.companyYearlyReturn ?? 0))));
          break;
        case "3y":
          tempFilter.sort(((a, b) => (a.companyThreeYear ?? 0).compareTo((b.companyThreeYear ?? 0))));
          break;
        case "5y":
          tempFilter.sort(((a, b) => (a.companyFiveYear ?? 0).compareTo((b.companyFiveYear ?? 0))));
          break;
        default:
          tempFilter.sort(((a, b) => (a.companyDailyReturn ?? 0).compareTo((b.companyDailyReturn ?? 0))));
          break;
      }

      // check the filter type
      if (_filterSort == "ASC") {
        _companyFilter = List<CompanyDetailModel>.from(tempFilter);
      }
      else {
        _companyFilter = List<CompanyDetailModel>.from(tempFilter.reversed);
      }
    }
  }

  Future<bool> _getInitData() async {
    // get the company sector and sub sector information
    await _companyAPI.getCompanySectorAndSubSector(_args.type, _args.sectorName, _args.subName).then((resp) {
      _companyList = resp;
      _companyFilter = List<CompanyDetailModel>.generate(_companyList.length, (index) => _companyList[index]);
      _filterMode = "AB";
      _filterSort = "ASC";
    }).onError((error, stackTrace) {
      Log.error(
        message: 'Error getting sub sector data',
        error: error,
        stackTrace: stackTrace,
      );
      throw Exception('Error when get sub sector data');
    },);
    
    return true;
  }

  Future<void> _getCompanyAndGo({required String code}) async {
    // show loading screen
    LoadingScreen.instance().show(context: context);

    // get the company detail and navigate to company page
    await _companyAPI.getCompanyByCode(code, 'saham').then((resp) {
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
      // remove loading screen once finished
      LoadingScreen.instance().hide();
    },);
  }
}