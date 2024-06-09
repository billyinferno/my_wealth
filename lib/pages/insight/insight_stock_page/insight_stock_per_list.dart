import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:my_wealth/api/company_api.dart';
import 'package:my_wealth/model/insight/insight_sector_per_detail_model.dart';
import 'package:my_wealth/model/user/user_login.dart';
import 'package:my_wealth/themes/colors.dart';
import 'package:my_wealth/utils/arguments/company_detail_args.dart';
import 'package:my_wealth/utils/arguments/insight_stock_sub_list_args.dart';
import 'package:my_wealth/utils/dialog/create_snack_bar.dart';
import 'package:my_wealth/utils/function/format_currency.dart';
import 'package:my_wealth/utils/function/risk_color.dart';
import 'package:my_wealth/utils/loader/show_loader_dialog.dart';
import 'package:my_wealth/storage/prefs/shared_user.dart';
import 'package:my_wealth/widgets/components/search_box.dart';

class InsightStockPERListPage extends StatefulWidget {
  final Object? args;
  const InsightStockPERListPage({super.key, required this.args});

  @override
  State<InsightStockPERListPage> createState() => _InsightStockPERListPageState();
}

class _InsightStockPERListPageState extends State<InsightStockPERListPage> {
  final ScrollController _scrollController = ScrollController();

  final CompanyAPI _companyAPI = CompanyAPI();

  late InsightStockSubListArgs _args;
  late SectorPerDetailModel _data;
  late List<CodeList> _codeList;
  late UserLoginInfoModel? _userInfo;
  
  late String _filterMode;
  late String _filterSort;
  final Map<String, String> _filterList = {};
  
  bool _isLoading = true;

  @override
  void initState() {
    _args = widget.args as InsightStockSubListArgs;
    _userInfo = UserSharedPreferences.getUserInfo();

    // list all the filter that we want to put here
    _filterList["AB"] = "Code";
    _filterList["DL"] = "Daily";
    _filterList["PR"] = "Periodic";
    _filterList["AN"] = "Annualized";

    // default filter mode to Code and ASC
    _filterMode = "AB";
    _filterSort = "ASC";

    // get the sector PER from API
    _getSectorPER();

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
      return Container(
        color: primaryColor,
      );
    }

    // if loading finished, return the actual page
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
          _listItem(
            indicatorColor: Colors.white,
            bgColor: primaryDark,
            code: '',
            title: "Average ${_data.averagePerYear}",
            per: formatDecimalWithNull(_data.averagePerDaily, 1, 2),
            periodic: formatDecimalWithNull(_data.averagePerPeriodatic, 1, 2),
            annual: formatDecimalWithNull(_data.averagePerAnnualized, 1, 2),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _codeList.length,
              itemBuilder: ((context, index) {
                Color indicatorColor = Colors.white;
                if (_codeList[index].perDaily! < 0 || _codeList[index].perAnnualized! < 0 || _codeList[index].perPeriodatic! < 0) {
                  indicatorColor = const Color.fromARGB(255, 51, 3, 0);
                }
                else {
                  // compare with average
                  double avgPer = _data.averagePerDaily;
                  double avgPerAnnul = _data.averagePerAnnualized;
                  double avgPerPeriod = _data.averagePerPeriodatic;
                  double addAvgPer = 0;
                  double addAvgPerAnnul = 0;
                  double addAvgPerPeriod = 0;

                  if (avgPer < 0) {
                    avgPer = (avgPer) * (-1);
                    addAvgPer = avgPer;
                  }
                  if (avgPerAnnul < 0) {
                    avgPerAnnul = (avgPerAnnul) * (-1);
                    addAvgPerAnnul = avgPerAnnul;
                  }
                  if (avgPerPeriod < 0) {
                    avgPerPeriod = (avgPerPeriod) * (-1);
                    addAvgPerPeriod = avgPerPeriod;
                  }

                  indicatorColor = riskColor(avgPer + avgPerAnnul + avgPerPeriod, (_codeList[index].perDaily! + addAvgPer) + (_codeList[index].perAnnualized! + addAvgPerAnnul) + (_codeList[index].perPeriodatic! + addAvgPerPeriod), _userInfo!.risk);
                }
          
                return InkWell(
                  onTap: (() async {
                    showLoaderDialog(context);
                    await _companyAPI.getCompanyByCode(_codeList[index].code, 'saham').then((resp) {
                      CompanyDetailArgs args = CompanyDetailArgs(
                        companyId: resp.companyId,
                        companyName: resp.companyName,
                        companyCode: _codeList[index].code,
                        companyFavourite: (resp.companyFavourites ?? false),
                        favouritesId: (resp.companyFavouritesId ?? -1),
                        type: "saham",
                      );
                      
                      if (context.mounted) {
                        // remove the loader dialog
                        Navigator.pop(context);

                        // go to the company page
                        Navigator.pushNamed(context, '/company/detail/saham', arguments: args);
                      }
                    }).onError((error, stackTrace) {
                      if (context.mounted) {
                        // remove the loader dialog
                        Navigator.pop(context);

                        // show the error message
                        ScaffoldMessenger.of(context).showSnackBar(createSnackBar(message: 'Error when try to get the company detail from server'));
                      }
                    });
                  }),
                  child: _listItem(
                    indicatorColor: indicatorColor,
                    code: "(${_codeList[index].code})",
                    codeTextStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: accentColor),
                    title: _codeList[index].name,
                    titleTextStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: textPrimary),
                    per: formatDecimalWithNull(_codeList[index].perDaily, 1, 2),
                    period: _codeList[index].period,
                    year: _codeList[index].year,
                    periodic: formatDecimalWithNull(_codeList[index].perPeriodatic, 1, 2),
                    annual: formatDecimalWithNull(_codeList[index].perAnnualized, 1, 2)
                  ),
                );
              })
            ),
          ),
          const SizedBox(height: 30,),
        ],
      ),
    );
  }

  Future<void> _getSectorPER() async {
    Future.microtask(() async {
      if (mounted) {
        showLoaderDialog(context); 
      }
      await _companyAPI.getCompanySectorPER(_args.sectorName).then((resp) {
        _data = resp;
        _codeList = List<CodeList>.from(_data.codeList);
      });
    }).whenComplete(() {
      if (mounted) {
        // remove loader
        Navigator.pop(context);
      }
      // set the loading as false
      setState(() {
        _isLoading = false;
      });
    });
  }

  Widget _listItem({
      required Color indicatorColor,
      Color? bgColor,
      required String code,
      TextStyle? codeTextStyle,
      required String title,
      TextStyle? titleTextStyle,
      required String per,
      TextStyle? perTextStyle,
      required String periodic,
      int? period,
      int? year,
      TextStyle? periodicTextStyle,
      required String annual,
      TextStyle? annualTextStyle
    }) {
    return Container(
      decoration: BoxDecoration(
        color: indicatorColor,
        border: const Border(
          bottom: BorderSide(
            color: primaryLight,
            width: 1.0,
            style: BorderStyle.solid,
          )
        )
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          const SizedBox( width: 10,),
          Expanded(
            child: Container(
              padding: const EdgeInsets.fromLTRB(5, 5, 10, 5),
              color: (bgColor ?? primaryColor),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Visibility(
                          visible: (code.isNotEmpty),
                          child: SizedBox(
                            width: 50,
                            child: Text(
                              code,
                              style: (codeTextStyle ?? const TextStyle(fontWeight: FontWeight.normal, color: accentColor)),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            title,
                            style: (titleTextStyle ?? const TextStyle(fontWeight: FontWeight.normal, color: textPrimary)),
                          ),
                        )
                      ], 
                    ),
                  ),
                  const SizedBox(width: 10,),
                  SizedBox(
                    width: 135,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            const SizedBox(
                              width: 80,
                              child: Text(
                                "Daily",
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: accentLight
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                per,
                                style: (perTextStyle ?? const TextStyle(fontSize: 10, color: textPrimary)),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5,),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            SizedBox(
                              width: 80,
                              child: Text(
                                (period != null && year != null ? "[${period}M/$year]" : "Periodic"),
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: accentLight
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                periodic,
                                style: (periodicTextStyle ?? const TextStyle(fontSize: 10, color: textPrimary)),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5,),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            const SizedBox(
                              width: 80,
                              child: Text(
                                "Annualized",
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: accentLight
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                annual,
                                style: (annualTextStyle ?? const TextStyle(fontSize: 10, color: textPrimary)),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  void _sortedCompanyList() {
    // clear the current code list as we will rebuild t his
    _codeList.clear();

    // if the filter mode is "AB" which is code, then just copy from the _companyList
    if (_filterMode == "AB") {
      // check the sort methode?
      if (_filterSort == "ASC") {
        _codeList = List<CodeList>.from(_data.codeList);
      }
      else {
        _codeList = List<CodeList>.from(_data.codeList.reversed);
      }
    }
    else {
      List<CodeList> tempFilter = List<CodeList>.from(_data.codeList);
      switch(_filterMode) {
        case "DL":
          tempFilter.sort(((a, b) => (a.perDaily ?? 0).compareTo((b.perDaily ?? 0))));
          break;
        case "PR":
          tempFilter.sort(((a, b) => (a.perPeriodatic ?? 0).compareTo((b.perPeriodatic ?? 0))));
          break;
        case "AN":
          tempFilter.sort(((a, b) => (a.perAnnualized ?? 0).compareTo((b.perAnnualized ?? 0))));
          break;
        default:
          tempFilter.sort(((a, b) => (a.perPeriodatic ?? 0).compareTo((b.perPeriodatic ?? 0))));
          break;
      }

      // check the filter type
      if (_filterSort == "ASC") {
        _codeList = List<CodeList>.from(tempFilter);
      }
      else {
        _codeList = List<CodeList>.from(tempFilter.reversed);
      }
    }
  }
}