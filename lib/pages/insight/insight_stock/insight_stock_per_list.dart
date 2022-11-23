import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:my_wealth/api/company_api.dart';
import 'package:my_wealth/model/sector_per_detail_model.dart';
import 'package:my_wealth/model/user_login.dart';
import 'package:my_wealth/themes/colors.dart';
import 'package:my_wealth/utils/arguments/company_detail_args.dart';
import 'package:my_wealth/utils/arguments/insight_stock_sub_list_args.dart';
import 'package:my_wealth/utils/dialog/create_snack_bar.dart';
import 'package:my_wealth/utils/function/format_currency.dart';
import 'package:my_wealth/utils/function/risk_color.dart';
import 'package:my_wealth/utils/loader/show_loader_dialog.dart';
import 'package:my_wealth/utils/prefs/shared_user.dart';

class InsightStockPERListPage extends StatefulWidget {
  final Object? args;
  const InsightStockPERListPage({Key? key, required this.args}) : super(key: key);

  @override
  State<InsightStockPERListPage> createState() => _InsightStockPERListPageState();
}

class _InsightStockPERListPageState extends State<InsightStockPERListPage> {
  final ScrollController _scrollController = ScrollController();

  final CompanyAPI _companyAPI = CompanyAPI();

  late InsightStockSubListArgs _args;
  late SectorPerDetailModel _data;
  late UserLoginInfoModel? _userInfo;
  bool _isLoading = true;

  @override
  void initState() {
    _args = widget.args as InsightStockSubListArgs;
    _userInfo = UserSharedPreferences.getUserInfo();
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
          _listItem(
            indicatorColor: Colors.white,
            bgColor: primaryDark,
            code: '',
            title: "Average",
            per: formatDecimalWithNull(_data.averagePerDaily, 1, 2),
            periodic: formatDecimalWithNull(_data.averagePerPeriodatic, 1, 2),
            annual: formatDecimalWithNull(_data.averagePerAnnualized, 1, 2),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _data.codeList.length,
              itemBuilder: ((context, index) {
                Color indicatorColor = Colors.white;
                if (_data.codeList[index].perDaily! < 0 || _data.codeList[index].perAnnualized! < 0 || _data.codeList[index].perPeriodatic! < 0) {
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

                  indicatorColor = riskColor(avgPer + avgPerAnnul + avgPerPeriod, (_data.codeList[index].perDaily! + addAvgPer) + (_data.codeList[index].perAnnualized! + addAvgPerAnnul) + (_data.codeList[index].perPeriodatic! + addAvgPerPeriod), _userInfo!.risk);
                }
          
                return InkWell(
                  onTap: (() async {
                    showLoaderDialog(context);
                    await _companyAPI.getCompanyByCode(_data.codeList[index].code, 'saham').then((resp) {
                      CompanyDetailArgs args = CompanyDetailArgs(
                        companyId: resp.companyId,
                        companyName: resp.companyName,
                        companyCode: _data.codeList[index].code,
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
                  child: _listItem(
                    indicatorColor: indicatorColor,
                    code: "(${_data.codeList[index].code})",
                    codeTextStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: accentColor),
                    title: _data.codeList[index].name,
                    titleTextStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: textPrimary),
                    per: formatDecimalWithNull(_data.codeList[index].perDaily, 1, 2),
                    period: _data.codeList[index].period,
                    year: _data.codeList[index].year,
                    periodic: formatDecimalWithNull(_data.codeList[index].perPeriodatic, 1, 2),
                    annual: formatDecimalWithNull(_data.codeList[index].perAnnualized, 1, 2)
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
      showLoaderDialog(context); 
      await _companyAPI.getCompanySectorPER(_args.sectorName).then((resp) {
        _data = resp;
      });
    }).whenComplete(() {
      // remove loader
      Navigator.pop(context);
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
}