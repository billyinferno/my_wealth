import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_wealth/api/company_api.dart';
import 'package:my_wealth/api/insight_api.dart';
import 'package:my_wealth/model/insight/insight_sector_name_list_model.dart';
import 'package:my_wealth/model/insight/insight_sector_summary_model.dart';
import 'package:my_wealth/model/insight/insight_stock_dividend_list_model.dart';
import 'package:my_wealth/model/insight/insight_stock_new_listed_model.dart';
import 'package:my_wealth/model/insight/insight_stock_split_list_model.dart';
import 'package:my_wealth/model/insight/insight_top_worse_company_list_model.dart';
import 'package:my_wealth/model/user/user_login.dart';
import 'package:my_wealth/provider/company_provider.dart';
import 'package:my_wealth/provider/inisght_provider.dart';
import 'package:my_wealth/themes/colors.dart';
import 'package:my_wealth/utils/arguments/company_detail_args.dart';
import 'package:my_wealth/utils/arguments/industry_summary_args.dart';
import 'package:my_wealth/utils/arguments/insight_stock_sub_list_args.dart';
import 'package:my_wealth/utils/dialog/create_snack_bar.dart';
import 'package:my_wealth/utils/function/date_utils.dart';
import 'package:my_wealth/utils/function/format_currency.dart';
import 'package:my_wealth/utils/function/risk_color.dart';
import 'package:my_wealth/utils/globals.dart';
import 'package:my_wealth/utils/loader/show_loader_dialog.dart';
import 'package:my_wealth/storage/prefs/shared_company.dart';
import 'package:my_wealth/storage/prefs/shared_insight.dart';
import 'package:my_wealth/storage/prefs/shared_user.dart';
import 'package:my_wealth/widgets/components/selectable_list.dart';
import 'package:provider/provider.dart';

class InsightStockPage extends StatefulWidget {
  const InsightStockPage({super.key});

  @override
  State<InsightStockPage> createState() => _InsightStockPageState();
}

class _InsightStockPageState extends State<InsightStockPage> {
  final ScrollController _scrollController = ScrollController();
  final InsightAPI _insightAPI = InsightAPI();
  final CompanyAPI _companyAPI = CompanyAPI();
  final DateTime _todayDate = DateTime.now();

  late List<SectorSummaryModel> _sectorSummaryList;
  late TopWorseCompanyListModel _topCompanyList;
  late TopWorseCompanyListModel _worseCompanyList;
  late List<SectorNameModel> _sectorNameList;
  late UserLoginInfoModel? _userInfo;
  late List<SelectableItem> _selectableItemList;
  late List<StockNewListedModel> _stockNewListedList;
  late List<StockDividendListModel> _stockDividendList;
  late List<StockSplitListModel> _stockSplitList;

  String _sectorSummaryPeriod = "1d";
  String _topCompanyPeriod = "1d";
  String _worseCompanyPeriod = "1d";

  @override
  void initState() {
    _sectorSummaryList = InsightSharedPreferences.getSectorSummaryList();
    _topCompanyList = InsightSharedPreferences.getTopWorseCompanyList('top');
    _topCompanyList = InsightSharedPreferences.getTopWorseCompanyList('worse');
    _sectorNameList = CompanySharedPreferences.getSectorNameList();
    _stockNewListedList = InsightSharedPreferences.getStockNewListed();
    _stockDividendList = InsightSharedPreferences.getStockDividendList();
    _stockSplitList = InsightSharedPreferences.getStockSplitList();

    _userInfo = UserSharedPreferences.getUserInfo();

    // initialize the selectable item list
    _selectableItemList = [
      const SelectableItem(name: '1d', value: '1d'),
      const SelectableItem(name: '1w', value: '1w'),
      const SelectableItem(name: 'mtd', value: 'mtd'),
      const SelectableItem(name: '1m', value: '1m'),
      const SelectableItem(name: '3m', value: '3m'),
      const SelectableItem(name: '6m', value: '6m'),
      const SelectableItem(name: 'ytd', value: 'ytd'),
      const SelectableItem(name: '1y', value: '1y'),
      const SelectableItem(name: '3y', value: '3y'),
      const SelectableItem(name: '5y', value: '5y'),
    ];
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<InsightProvider, CompanyProvider>(
      builder: ((context, insightProvider, companyProvider, child) {
        _sectorSummaryList = (insightProvider.sectorSummaryList ?? []);
        _topCompanyList = insightProvider.topCompanyList!;
        _worseCompanyList = insightProvider.worseCompanyList!;
        _sectorNameList = (companyProvider.sectorNameList ?? []);
        _stockNewListedList = (insightProvider.stockNewListed ?? []);
        _stockDividendList = (insightProvider.stockDividendList ?? []);
        _stockSplitList = (insightProvider.stockSplitList ?? []);


        return RefreshIndicator(
          color: accentColor,
          onRefresh: (() async {
            showLoaderDialog(context);

            // refresh all the information
            await _refreshInformation(context).onError((error, stackTrace) {
              debugPrint("Error ${error.toString()}");
              debugPrintStack(stackTrace: stackTrace);
            }).then((_) {
              // rebuild widget once finished
              setState(() {
                // just rebuild
              });
            }).whenComplete(() {
              if (context.mounted) {
                // remove the loader
                Navigator.pop(context);
              }
            });
          }),
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Container(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  const Center(
                    child: Text(
                      "Sector Summary",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10,),
                  SelectableList(
                    items: _selectableItemList,
                    initialValue: _sectorSummaryPeriod,
                    onPress: ((value) {
                      _setSectorSummaryPeriod(value);
                    })
                  ),
                  const SizedBox(height: 10,),
                  SizedBox(
                    width: double.infinity,
                    child: GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 3,
                      children: List<Widget>.generate(_sectorSummaryList.length, (index) {
                        double sectorAverage = 0;
                        IndustrySummaryArgs industryArgs = IndustrySummaryArgs(sectorData: _sectorSummaryList[index]);
                        
                        switch (_sectorSummaryPeriod) {
                          case '1d':
                            sectorAverage = _sectorSummaryList[index].sectorAverage.the1D;
                            break;
                          case '1w':
                            sectorAverage = _sectorSummaryList[index].sectorAverage.the1W;
                            break;
                          case 'mtd':
                            sectorAverage = _sectorSummaryList[index].sectorAverage.theMTD;
                            break;
                          case '1m':
                            sectorAverage = _sectorSummaryList[index].sectorAverage.the1M;
                            break;
                          case '3m':
                            sectorAverage = _sectorSummaryList[index].sectorAverage.the3M;
                            break;
                          case '6m':
                            sectorAverage = _sectorSummaryList[index].sectorAverage.the6M;
                            break;
                          case 'ytd':
                            sectorAverage = _sectorSummaryList[index].sectorAverage.theYTD;
                            break;
                          case '1y':
                            sectorAverage = _sectorSummaryList[index].sectorAverage.the1Y;
                            break;
                          case '3y':
                            sectorAverage = _sectorSummaryList[index].sectorAverage.the3Y;
                            break;
                          case '5y':
                            sectorAverage = _sectorSummaryList[index].sectorAverage.the5Y;
                            break;
                          default:
                            sectorAverage = _sectorSummaryList[index].sectorAverage.the1D;
                            break;
                        }
                        
                        // Color bgColor = (sectorAverage >= 0 ? Colors.green : secondaryColor);
                        Color bgColor = riskColor((1 + sectorAverage), 1, _userInfo!.risk);
                        Color textColor = riskColorReverse((1 + sectorAverage), 1);
                        Color borderColor = (sectorAverage >= 0 ? const Color.fromARGB(255, 15, 88, 17) : secondaryDark);
                  
                        return InkWell(
                          onTap: (() {
                            Navigator.pushNamed(context, '/insight/stock/industry', arguments: industryArgs);
                          }),
                          child: Container(
                            margin: const EdgeInsets.all(5),
                            height: 90,
                            width: 90,
                            decoration: BoxDecoration(
                              color: bgColor,
                              border: Border.all(
                                color: borderColor,
                                style: BorderStyle.solid,
                                width: 1.0,
                              )
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(
                                  Globals.sectorIcon[_sectorSummaryList[index].sectorName]!,
                                  size: 25,
                                  color: textColor,
                                ),
                                const SizedBox(height: 5,),
                                Center(
                                  child: Text(
                                    Globals.sectorName[_sectorSummaryList[index].sectorName]!,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                    ),
                                  ),
                                ),
                                Center(
                                  child: Text(
                                    "${formatDecimal((sectorAverage * 100), 2)}%",
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 20,),
                  const Center(
                    child: Text(
                      "Top Gainer",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ),
                  const SizedBox(height: 10,),
                  SelectableList(
                    items: _selectableItemList,
                    initialValue: _topCompanyPeriod,
                    onPress: ((value) {
                      _setTopCompanyPeriod(value);
                    })
                  ),
                  const SizedBox(height: 10,),
                  _generateTopWorseList(type: 'top', codeColor: accentColor, gainColor: Colors.green),
                  const SizedBox(height: 20,),
                  const Center(
                    child: Text(
                      "Top Loser",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ),
                  const SizedBox(height: 10,),
                  SelectableList(
                    items: _selectableItemList,
                    initialValue: _worseCompanyPeriod,
                    onPress: ((value) {
                      _setWorseCompanyPeriod(value);
                    })
                  ),
                  const SizedBox(height: 10,),
                  _generateTopWorseList(type: 'worse', codeColor: accentColor, gainColor: secondaryLight),
                  const SizedBox(height: 20,),
                  const Center(
                    child: Text(
                      "PER Per Sector",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ),
                  const SizedBox(height: 10,),
                  SizedBox(
                    width: double.infinity,
                    child: GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 3,
                      children: List<Widget>.generate(_sectorNameList.length, (index) {             
                        InsightStockSubListArgs args = InsightStockSubListArgs(
                          type: 'PER',
                          sectorName: _sectorNameList[index].sectorName,
                          subName: _sectorNameList[index].sectorFriendlyname
                        );

                        return InkWell(
                          onTap: (() {
                            Navigator.pushNamed(context, '/insight/stock/per', arguments: args);
                          }),
                          child: Container(
                            margin: const EdgeInsets.all(5),
                            height: 90,
                            width: 90,
                            decoration: BoxDecoration(
                              color: extendedColor,
                              border: Border.all(
                                color: extendedDark,
                                style: BorderStyle.solid,
                                width: 1.0,
                              )
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(
                                  Globals.sectorIcon[_sectorNameList[index].sectorName.replaceAll('&amp;', '&')]!,
                                  size: 25,
                                  color: extendedLight,
                                ),
                                Center(
                                  child: Text(
                                    _sectorNameList[index].sectorFriendlyname,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: extendedLight,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 20,),
                  const Center(
                    child: Text(
                      "Stock Newly Listed",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ),
                  const SizedBox(height: 10,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: List<Widget>.generate(
                      _stockNewListedList.length,
                      ((index) {
                        return InkWell(
                          onTap: (() async {
                            // check if the listed date is more than today date?
                            if (_stockNewListedList[index].listedDate != null) {
                              if (_stockNewListedList[index].listedDate!.isBefore(_todayDate)) {
                                // able to click and go to the company
                                showLoaderDialog(context);
                                await _companyAPI.getCompanyByCode(_stockNewListedList[index].code, 'saham').then((resp) {
                                  CompanyDetailArgs args = CompanyDetailArgs(
                                    companyId: resp.companyId,
                                    companyName: resp.companyName,
                                    companyCode: _stockNewListedList[index].code,
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
                                  }

                                  // show the error message
                                  _showScaffoldMessage(text: 'Error when try to get the company detail from server');
                                });
                              }
                            }
                            else {
                              showCupertinoDialog(
                                context: context,
                                builder: ((BuildContext context) {
                                  return CupertinoAlertDialog(
                                    title: const Text("Not Available"),
                                    content: Text("Listed date for ${_stockNewListedList[index].code} is not exists"),
                                    actions: <CupertinoDialogAction>[
                                      CupertinoDialogAction(
                                        onPressed: (() {
                                          Navigator.pop(context);
                                        }),
                                        child: const Text("OK")
                                      )
                                    ],
                                  );
                                })
                              );
                            }
                          }),
                          child: Container(
                            width: double.infinity,
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
                                Text.rich(
                                  TextSpan(
                                    children: <TextSpan>[
                                      TextSpan(
                                        text: "(${_stockNewListedList[index].code}) ",
                                        style: const TextStyle(
                                          color: accentColor,
                                          fontWeight: FontWeight.bold,
                                        )
                                      ),
                                      TextSpan(
                                        text: _stockNewListedList[index].name,
                                        style: const TextStyle(
                                          color: textPrimary,
                                          fontWeight: FontWeight.bold,
                                          overflow: TextOverflow.ellipsis,
                                        )
                                      ),
                                    ]
                                  ),
                                ),
                                const SizedBox(height: 5,),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    _smallBox(title: "Listed Shares", value: formatIntWithNull(_stockNewListedList[index].listedShares, true, true, 2)),
                                    const SizedBox(width: 10,),
                                    _smallBox(title: "Shares Offered", value: formatIntWithNull(_stockNewListedList[index].numOfShares, true, true, 2)),
                                    const SizedBox(width: 10,),
                                    _smallBox(title: "% Shares", value: "${formatDecimalWithNull((_stockNewListedList[index].numOfShares ?? 0) / (_stockNewListedList[index].listedShares ?? 1), 100, 2)}%"),
                                  ],
                                ),
                                const SizedBox(height: 5,),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    _smallBox(title: "Offering Price", value: formatCurrencyWithNull(_stockNewListedList[index].offering as double, false, false, false, 0)),
                                    const SizedBox(width: 10,),
                                    _smallBox(title: "Fund Raised", value: formatIntWithNull(_stockNewListedList[index].fundRaised, true, true, 2)),
                                    const SizedBox(width: 10,),
                                    _smallBox(title: "Listed Date", value: formatDateWithNulll(date: _stockNewListedList[index].listedDate)),
                                  ],
                                ),
                                const SizedBox(height: 5,),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    _smallBox(title: "Current Price", value: formatCurrencyWithNull(_stockNewListedList[index].currentPrice as double, false, false, false, 0)),
                                    const SizedBox(width: 10,),
                                    _smallBox(title: "Diff Price", value: formatIntWithNull((_stockNewListedList[index].currentPrice! > 0 ? _stockNewListedList[index].currentPrice! - _stockNewListedList[index].offering! : null), false, false, 0)),
                                    const SizedBox(width: 10,),
                                    _smallBox(title: "% Diff", value: "${formatDecimalWithNull((_stockNewListedList[index].currentPrice! > 0 ? (_stockNewListedList[index].currentPrice! - _stockNewListedList[index].offering!) / _stockNewListedList[index].offering! : null), 100, 2)}%"),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 20,),
                  const Center(
                    child: Text(
                      "Latest Stock Dividend List",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ),
                  const SizedBox(height: 10,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: List<Widget>.generate(
                      _stockDividendList.length,
                      ((index) {
                        return InkWell(
                          onTap: (() async {
                            // click and go to the company
                            showLoaderDialog(context);
                            await _companyAPI.getCompanyByCode(_stockDividendList[index].code, 'saham').then((resp) {
                              CompanyDetailArgs args = CompanyDetailArgs(
                                companyId: resp.companyId,
                                companyName: resp.companyName,
                                companyCode: _stockDividendList[index].code,
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
                              }

                              // show the error message
                              _showScaffoldMessage(text: 'Error when try to get the company detail from server');
                            });
                          }),
                          child: Container(
                            width: double.infinity,
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
                                Text.rich(
                                  TextSpan(
                                    children: <TextSpan>[
                                      TextSpan(
                                        text: "(${_stockDividendList[index].code}) ",
                                        style: const TextStyle(
                                          color: accentColor,
                                          fontWeight: FontWeight.bold,
                                        )
                                      ),
                                      TextSpan(
                                        text: _stockDividendList[index].name,
                                        style: const TextStyle(
                                          color: textPrimary,
                                          fontWeight: FontWeight.bold,
                                          overflow: TextOverflow.ellipsis,
                                        )
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 5,),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    _smallBox(title: "Cum Date", value: formatDateWithNulll(date: _stockDividendList[index].cumDividend)),
                                    const SizedBox(width: 10,),
                                    _smallBox(title: "Ex Date", value: formatDateWithNulll(date: _stockDividendList[index].exDividend)),
                                    const SizedBox(width: 10,),
                                    _smallBox(title: "Dividend", value: formatDecimalWithNull(_stockDividendList[index].cashDividend, 1, 2)),
                                  ],
                                ),
                                const SizedBox(height: 5,),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    _smallBox(title: "Record Date", value: formatDateWithNulll(date: _stockDividendList[index].recordDate)),
                                    const SizedBox(width: 10,),
                                    _smallBox(title: "Payment Date", value: formatDateWithNulll(date: _stockDividendList[index].paymentDate)),
                                    const SizedBox(width: 10,),
                                    const Expanded(child: SizedBox(width: double.infinity,),),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 20,),
                  const Center(
                    child: Text(
                      "Latest Stock Split",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ),
                  const SizedBox(height: 10,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: List<Widget>.generate(
                      _stockSplitList.length,
                      ((index) {
                        return InkWell(
                          onTap: (() async {
                            // click and go to the company
                            showLoaderDialog(context);
                            await _companyAPI.getCompanyByCode(_stockSplitList[index].code, 'saham').then((resp) {
                              CompanyDetailArgs args = CompanyDetailArgs(
                                companyId: resp.companyId,
                                companyName: resp.companyName,
                                companyCode: _stockSplitList[index].code,
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
                              }

                              // show the error message
                              _showScaffoldMessage(text: 'Error when try to get the company detail from server');
                            });
                          }),
                          child: Container(
                            width: double.infinity,
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
                                Text.rich(
                                  TextSpan(
                                    children: <TextSpan>[
                                      TextSpan(
                                        text: "(${_stockSplitList[index].code}) ",
                                        style: const TextStyle(
                                          color: accentColor,
                                          fontWeight: FontWeight.bold,
                                        )
                                      ),
                                      TextSpan(
                                        text: _stockSplitList[index].name,
                                        style: const TextStyle(
                                          color: textPrimary,
                                          fontWeight: FontWeight.bold,
                                          overflow: TextOverflow.ellipsis,
                                        )
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 5,),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    _smallBox(title: "Ratio", value: _stockSplitList[index].ratio),
                                    const SizedBox(width: 10,),
                                    _smallBox(title: "Current Price", value: formatIntWithNull(_stockSplitList[index].lastPrice, false, false, 0)),
                                    const SizedBox(width: 10,),
                                    _smallBox(title: "New Price", value: formatCurrencyWithNull((_stockSplitList[index].lastPrice! * _stockSplitList[index].nominalNew!) / _stockSplitList[index].nomimal!, false, false, false, 0)),
                                  ],
                                ),
                                const SizedBox(height: 5,),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    _smallBox(title: "Listed Shares", value: formatIntWithNull(_stockSplitList[index].listedShares, true, true, 2)),
                                    const SizedBox(width: 10,),
                                    _smallBox(title: "Split Date", value: formatDateWithNulll(date: _stockSplitList[index].listingDate)),
                                    const SizedBox(width: 10,),
                                    const Expanded(child: SizedBox(width: double.infinity,),),
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
            ),
          ),
        );
      }),
    );
  }

  Widget _smallBox({required String title, required String value}) {
    return Expanded(
      child: SizedBox(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: extendedLight,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 12
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _generateTopWorseList({required String type, required Color codeColor, required Color gainColor}) {
    List<CompanyInfo> info = [];
    
    if (type == 'top') {
      // select which info we will display based on the _topPeriod
      switch(_topCompanyPeriod) {
        case '1d':
          info = _topCompanyList.companyList.the1D;
          break;
        case '1w':
          info = _topCompanyList.companyList.the1W;
          break;
        case 'mtd':
          info = _topCompanyList.companyList.theMTD;
          break;
        case '1m':
          info = _topCompanyList.companyList.the1M;
          break;
        case '3m':
          info = _topCompanyList.companyList.the3M;
          break;
        case '6m':
          info = _topCompanyList.companyList.the6M;
          break;
        case 'ytd':
          info = _topCompanyList.companyList.theYTD;
          break;
        case '1y':
          info = _topCompanyList.companyList.the1Y;
          break;
        case '3y':
          info = _topCompanyList.companyList.the3Y;
          break;
        case '5y':
          info = _topCompanyList.companyList.the5Y;
          break;
        default:
          info = _topCompanyList.companyList.the1D;
          break;
      }
    }
    else if (type == 'worse') {
      // select which info we will display based on the _topPeriod
      switch(_worseCompanyPeriod) {
        case '1d':
          info = _worseCompanyList.companyList.the1D;
          break;
        case '1w':
          info = _worseCompanyList.companyList.the1W;
          break;
        case 'mtd':
          info = _worseCompanyList.companyList.theMTD;
          break;
        case '1m':
          info = _worseCompanyList.companyList.the1M;
          break;
        case '3m':
          info = _worseCompanyList.companyList.the3M;
          break;
        case '6m':
          info = _worseCompanyList.companyList.the6M;
          break;
        case 'ytd':
          info = _worseCompanyList.companyList.theYTD;
          break;
        case '1y':
          info = _worseCompanyList.companyList.the1Y;
          break;
        case '3y':
          info = _worseCompanyList.companyList.the3Y;
          break;
        case '5y':
          info = _worseCompanyList.companyList.the5Y;
          break;
        default:
          info = _worseCompanyList.companyList.the1D;
          break;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: List.generate(info.length, (index) {
        return InkWell(
          onTap: () async {
            showLoaderDialog(context);
            await _companyAPI.getCompanyByCode(info[index].code, 'saham').then((resp) {
              CompanyDetailArgs args = CompanyDetailArgs(
                companyId: resp.companyId,
                companyName: resp.companyName,
                companyCode: info[index].code,
                companyFavourite: (resp.companyFavourites ?? false),
                favouritesId: (resp.companyFavouritesId ?? -1),
                type: "saham",
              );
              
              if (mounted) {
                // remove the loader dialog
                Navigator.pop(context);

                // go to the company page
                Navigator.pushNamed(context, '/company/detail/saham', arguments: args);
              }
            }).onError((error, stackTrace) {
              if (mounted) {
                // remove the loader dialog
                Navigator.pop(context);
              }

              // show the error message
              _showScaffoldMessage(text: 'Error when try to get the company detail from server');
            });
          },
          child: Container(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  width: 20,
                  child: Text(
                    (index + 1).toString(),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold
                    ),
                  )
                ),
                const SizedBox(width: 5,),
                Text(
                  "(${info[index].code})",
                  style: TextStyle(
                    color: codeColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 5,),
                Expanded(
                  child: Text(
                    info[index].name,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 5,),
                Text(
                  '${formatDecimal(info[index].gain * 100, 2)}%',
                  style: TextStyle(
                    color: gainColor,
                    fontSize: 12,
                  ),
                )
              ],
            ),
          ),
        );
      }),
    );
  }

  Future<void> _refreshInformation(BuildContext context) async {
    // refresh all the information
    await Future.wait([
      _insightAPI.getSectorSummary().then((resp) async {
        debugPrint("🔃 Refresh Sector Summary");
        await InsightSharedPreferences.setSectorSummaryList(resp);
        if (!context.mounted) return;
        Provider.of<InsightProvider>(context, listen: false).setSectorSummaryList(resp);
      }),
      _insightAPI.getTopWorseCompany('top').then((resp) async {
        debugPrint("🔃 Refresh Top Company Summary");
        await InsightSharedPreferences.setTopWorseCompanyList('top', resp);
        if (!context.mounted) return;
        Provider.of<InsightProvider>(context, listen: false).setTopWorseCompanyList('top', resp);
      }),
      _insightAPI.getTopWorseCompany('worse').then((resp) async {
        debugPrint("🔃 Refresh Worse Company Summary");
        await InsightSharedPreferences.setTopWorseCompanyList('worse', resp);
        if (!context.mounted) return;
        Provider.of<InsightProvider>(context, listen: false).setTopWorseCompanyList('worse', resp);
      }),
      _insightAPI.getStockNewListed().then((resp) async {
        debugPrint("🔃 Refresh Stock Newly Listed");
        await InsightSharedPreferences.setStockNewListed(resp);
        if (!context.mounted) return;
        Provider.of<InsightProvider>(context, listen: false).setStockNewListed(resp);
      }),
      _insightAPI.getStockDividendList().then((resp) async {
        debugPrint("🔃 Refresh Stock Dividend List");
        await InsightSharedPreferences.setStockDividendList(resp);
        if (!context.mounted) return;
        Provider.of<InsightProvider>(context, listen: false).setStockDividendList(resp);
      }),
      _insightAPI.getStockSplitList().then((resp) async {
        debugPrint("🔃 Refresh Stock Split");
        await InsightSharedPreferences.setStockSplitList(resp);
        if (!context.mounted) return;
        Provider.of<InsightProvider>(context, listen: false).setStockSplitList(resp);
      }),
    ]).onError((error, stackTrace) {
      debugPrint("Error ${error.toString()}");
      debugPrintStack(stackTrace: stackTrace);
      throw Exception("Error when get price gold data");
    });
  }

  void _setSectorSummaryPeriod(String period) {
    setState(() {
      _sectorSummaryPeriod = period;
    });
  }

  void _setTopCompanyPeriod(String period) {
    setState(() {
      _topCompanyPeriod = period;
    });
  }

  void _setWorseCompanyPeriod(String period) {
    setState(() {
      _worseCompanyPeriod = period;
    });
  }

  void _showScaffoldMessage({required String text}) {
    ScaffoldMessenger.of(context).showSnackBar(createSnackBar(message: text));
  }
 }