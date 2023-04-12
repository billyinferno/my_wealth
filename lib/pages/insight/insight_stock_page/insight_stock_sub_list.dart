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
import 'package:my_wealth/utils/loader/show_loader_dialog.dart';
import 'package:my_wealth/utils/prefs/shared_user.dart';

class InsightStockSubListPage extends StatefulWidget {
  final Object? args;
  const InsightStockSubListPage({Key? key, required this.args}) : super(key: key);

  @override
  State<InsightStockSubListPage> createState() => _InsightStockSubListPageState();
}

class _InsightStockSubListPageState extends State<InsightStockSubListPage> {
  final CompanyAPI _companyAPI = CompanyAPI();
  final ScrollController _scrollController = ScrollController();
  final TextStyle _filterTypeSelected = const TextStyle(fontSize: 10, color: accentColor, fontWeight: FontWeight.bold);
  final TextStyle _filterTypeUnselected = const TextStyle(fontSize: 10, color: primaryLight, fontWeight: FontWeight.normal);

  late InsightStockSubListArgs _args;
  late List<CompanyDetailModel> _companyList;
  late List<CompanyDetailModel> _companyFilter;
  late String _filterMode;
  late String _filterSort;
  final Map<String, String> _filterList = {};
  late UserLoginInfoModel? _userInfo;
  bool _isLoading = true;
  
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

    // once got the arguments then we can try to call the api to get the list of company
    Future.microtask(() async {
      showLoaderDialog(context);
      
      await _companyAPI.getCompanySectorAndSubSector(_args.type, _args.sectorName, _args.subName).then((resp) {
        _companyList = resp;
        _companyFilter = List<CompanyDetailModel>.generate(_companyList.length, (index) => _companyList[index]);
        _filterMode = "AB";
        _filterSort = "ASC";
      });
    }).whenComplete(() {
      // remove the loader
      Navigator.pop(context);
      
      // set is loading into false
      setState(() {
        _isLoading = false;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container();
    }

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
          Container(
            padding: const EdgeInsets.all(5),
            color: primaryDark,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                const Text(
                  "SORT",
                  style: TextStyle(
                    color: primaryLight,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(width: 5,),
                Expanded(
                  child: GestureDetector(
                    onTap: (() {
                      showModalBottomSheet<void>(
                        context: context,
                        backgroundColor: Colors.transparent,
                        isDismissible: true,
                        builder:(context) {
                          return Container(
                            height: 410,
                            margin: const EdgeInsets.fromLTRB(10, 10, 10, 25),
                            padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                const Center(
                                  child: Text("Select Filter"),
                                ),
                                ..._filterList.entries.map((e) => GestureDetector(
                                  onTap: (() {
                                    setState(() {
                                      _filterMode = e.key;
                                      _sortedCompanyList();
                                    });
                                    // remove the modal sheet
                                    Navigator.pop(context);
                                  }),
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(10),
                                    decoration: const BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: primaryLight,
                                          width: 1.0,
                                          style: BorderStyle.solid,
                                        )
                                      )
                                    ),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 20,
                                          height: 20,
                                          decoration: BoxDecoration(
                                            color: (_filterMode == e.key ? accentDark : Colors.transparent),
                                            borderRadius: BorderRadius.circular(2),
                                            border: Border.all(
                                              color: accentDark,
                                              width: 1.0,
                                              style: BorderStyle.solid,
                                            )
                                          ),
                                          child: Center(
                                            child: Text(
                                              e.key,
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: (_filterMode == e.key ? textPrimary : accentColor),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10,),
                                        Text(
                                          e.value,
                                          style: TextStyle(
                                            color: (_filterMode == e.key ? accentColor : textPrimary),
                                            fontWeight: (_filterMode == e.key ? FontWeight.bold : FontWeight.normal),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )).toList(),
                              ],
                            )
                          );
                        },
                      );
                    }),
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: primaryLight,
                          width: 1.0,
                          style: BorderStyle.solid,
                        ),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            child: Text(_filterList[_filterMode] ?? 'Code'),
                          ),
                          const SizedBox(width: 5,),
                          const Icon(
                            Ionicons.caret_down,
                            color: accentColor,
                            size: 15,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 5,),
                GestureDetector(
                  onTap: (() {
                    if (_filterSort != "ASC") {
                      // set state
                      setState(() {
                        _filterSort = "ASC";
                        _sortedCompanyList();
                      });
                    }
                  }),
                  child: SizedBox(
                    width: 35,
                    child: Center(
                      child: Text(
                        "ASC",
                        style: (_filterSort == "ASC" ? _filterTypeSelected : _filterTypeUnselected),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 2,),
                GestureDetector(
                  onTap: (() {
                    if (_filterSort != "DESC") {
                      // set state
                      setState(() {
                        _filterSort = "DESC";
                        _sortedCompanyList();
                      });
                    }
                  }),
                  child: SizedBox(
                    width: 35,
                    child: Center(
                      child: Text(
                        "DESC",
                        style: (_filterSort == "DESC" ? _filterTypeSelected : _filterTypeUnselected),
                      ),
                    ),
                  ),
                ),
              ],
            ),
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
                  onTap: (() async {
                    showLoaderDialog(context);
                    await _companyAPI.getCompanyByCode(_companyFilter[index].companySymbol!, 'saham').then((resp) {
                      CompanyDetailArgs args = CompanyDetailArgs(
                        companyId: resp.companyId,
                        companyName: resp.companyName,
                        companyCode: _companyFilter[index].companySymbol!,
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
}