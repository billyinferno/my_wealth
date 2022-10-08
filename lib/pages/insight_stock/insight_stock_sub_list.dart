import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:my_wealth/api/company_api.dart';
import 'package:my_wealth/model/company_detail_model.dart';
import 'package:my_wealth/model/user_login.dart';
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

  late InsightStockSubListArgs _args;
  late List<CompanyDetailModel> _companyList;
  late UserLoginInfoModel? _userInfo;
  bool _isLoading = true;
  
  @override
  void initState() {
    _args = widget.args as InsightStockSubListArgs;
    _userInfo = UserSharedPreferences.getUserInfo();

    // once got the arguments then we can try to call the api to get the list of company
    Future.microtask(() async {
      showLoaderDialog(context);
      
      await _companyAPI.getCompanySectorAndSubSector(_args.type, _args.sectorName, _args.subName).then((resp) {
        _companyList = resp;
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
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _companyList.length,
              itemBuilder: ((context, index) {
                double currentPrice = (_companyList[index].companyNetAssetValue ?? 0);
                double prevPrice = (_companyList[index].companyPrevPrice ?? 0);
                Color color = riskColor(currentPrice, prevPrice, _userInfo!.risk);
                
                return InkWell(
                  onTap: (() async {
                    showLoaderDialog(context);
                    await _companyAPI.getCompanyByCode(_companyList[index].companySymbol!, 'saham').then((resp) {
                      CompanyDetailArgs args = CompanyDetailArgs(
                        companyId: resp.companyId,
                        companyName: resp.companyName,
                        companyCode: _companyList[index].companySymbol!,
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
                                            '(${_companyList[index].companySymbol})',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: accentColor,
                                            ),
                                          ),
                                          const SizedBox(width: 5,),
                                          Expanded(
                                            child: SizedBox(
                                              child: Text(
                                                _companyList[index].companyName,
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
                                      _periodBox(title: "1d", value: (_companyList[index].companyDailyReturn ?? 0)),
                                      _periodBox(title: "1w", value: (_companyList[index].companyWeeklyReturn ?? 0)),
                                      _periodBox(title: "1m", value: (_companyList[index].companyMonthlyReturn ?? 0)),
                                      _periodBox(title: "3m", value: (_companyList[index].companyQuarterlyReturn ?? 0)),
                                      _periodBox(title: "6m", value: (_companyList[index].companySemiAnnualReturn ?? 0)),
                                      _periodBox(title: "1y", value: (_companyList[index].companyYearlyReturn ?? 0)),
                                      _periodBox(title: "3y", value: (_companyList[index].companyThreeYear ?? 0)),
                                      _periodBox(title: "5y", value: (_companyList[index].companyFiveYear ?? 0)),
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
}