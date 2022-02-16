import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ionicons/ionicons.dart';
import 'package:my_wealth/api/company_api.dart';
import 'package:my_wealth/model/company_detail_model.dart';
import 'package:my_wealth/model/user_login.dart';
import 'package:my_wealth/themes/colors.dart';
import 'package:my_wealth/utils/arguments/company_detail_args.dart';
import 'package:my_wealth/utils/function/format_currency.dart';
import 'package:my_wealth/utils/function/risk_color.dart';
import 'package:my_wealth/utils/globals.dart';
import 'package:my_wealth/utils/loader/show_loader_dialog.dart';
import 'package:my_wealth/utils/prefs/shared_user.dart';
import 'package:my_wealth/widgets/company_detail_price_list.dart';
import 'package:my_wealth/widgets/company_info_box.dart';

class CompanyDetailPage extends StatefulWidget {
  final Object? companyData;
  const CompanyDetailPage({ Key? key, required this.companyData }) : super(key: key);

  @override
  _CompanyDetailPageState createState() => _CompanyDetailPageState();
}

class _CompanyDetailPageState extends State<CompanyDetailPage> {
  late CompanyDetailArgs _companyData;
  late CompanyDetailModel _companyDetail;
  late UserLoginInfoModel? _userInfo;
  final ScrollController _scrollController = ScrollController();
  final CompanyAPI _companyApi = CompanyAPI();
  final DateFormat _df = DateFormat("dd/MM/yyyy");
  
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _companyData = widget.companyData as CompanyDetailArgs;
    if (widget.companyData == null) {
      _companyData = CompanyDetailArgs(companyId: -1, companyName: "Unknown Company", companyFavourite: false, favouritesId: -1);
    }
    else {
      _companyData = widget.companyData as CompanyDetailArgs;
    }

    _userInfo = UserSharedPreferences.getUserInfo();

    Future.microtask(() async {
      // show the loader dialog
      showLoaderDialog(context);
      // perform the get company detail information here
      await _companyApi.getCompanyDetail(_companyData.companyId).then((resp) {
        _companyDetail = resp;
      }).whenComplete(() {
        // once finished then remove the loader dialog
        Navigator.pop(context);
        setIsLoading(false);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return _generatePage();
  }

  Widget _generatePage() {
    if (_isLoading) {
      return Container(
        color: primaryColor,
      );
    }
    else {
      int _companyRating;
      int _companyRisk;

      if(_companyDetail.companyYearlyRating == null) {
        _companyRating = 0;
      }
      else {
        _companyRating = _companyDetail.companyYearlyRating!.toInt();
      }

      if(_companyDetail.companyYearlyRisk == null) {
        _companyRisk = 0;
      }
      else {
        _companyRisk = _companyDetail.companyYearlyRisk!.toInt();
      }

      return Scaffold(
        appBar: AppBar(
          title: const Center(
            child: Text(
              "Company Detail",
              style: TextStyle(
                color: secondaryColor,
              ),
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: (() async {
              Navigator.pop(context);
            }),
          ),
          actions: <Widget>[
            Icon(
              (_companyData.companyFavourite ? Ionicons.star : Ionicons.star_outline),
              color: accentColor,
            ),
            const SizedBox(width: 20,),
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              color: riskColor(_companyDetail.companyNetAssetValue!, _companyDetail.companyPrevPrice!, _userInfo!.risk),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(width: 10,),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      color: primaryColor,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            _companyData.companyName,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            formatCurrency(_companyDetail.companyNetAssetValue!),
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Icon(
                                ((_companyDetail.companyNetAssetValue! - _companyDetail.companyPrevPrice!) > 0 ? Ionicons.caret_up : Ionicons.caret_down),
                                color: riskColor(_companyDetail.companyNetAssetValue!, _companyDetail.companyPrevPrice!, _userInfo!.risk),
                              ),
                              const SizedBox(width: 10,),
                              Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: riskColor(_companyDetail.companyNetAssetValue!, _companyDetail.companyPrevPrice!, _userInfo!.risk),
                                      width: 2.0,
                                      style: BorderStyle.solid,
                                    ),
                                  )
                                ),
                                child: Text(formatCurrency(_companyDetail.companyNetAssetValue! - _companyDetail.companyPrevPrice!)),
                              ),
                              Expanded(child: Container(),),
                              const Icon(
                                Ionicons.time_outline,
                                color: primaryLight,
                              ),
                              const SizedBox(width: 10,),
                              // ignore: unnecessary_null_comparison
                              Text((_companyDetail.companyLastUpdate! == null ? "-" : _df.format(_companyDetail.companyLastUpdate!.toLocal()))),
                            ],
                          ),
                          const SizedBox(height: 20,),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              CompanyInfoBox(
                                header: "Weekly",
                                headerAlign: TextAlign.right,
                                child: Text(
                                  formatDecimalWithNull(_companyDetail.companyWeeklyReturn, 100) + "%",
                                  textAlign: TextAlign.right,
                                ),
                              ),
                              const SizedBox(width: 10,),
                              CompanyInfoBox(
                                header: "Monthly",
                                headerAlign: TextAlign.right,
                                child: Text(
                                  formatDecimalWithNull(_companyDetail.companyMonthlyReturn, 100) + "%",
                                  textAlign: TextAlign.right,
                                ),
                              ),
                              const SizedBox(width: 10,),
                              CompanyInfoBox(
                                header: "Quarterly",
                                headerAlign: TextAlign.right,
                                child: Text(
                                  formatDecimalWithNull(_companyDetail.companyQuarterlyReturn, 100) + "%",
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10,),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              CompanyInfoBox(
                                header: "Semi Annual",
                                headerAlign: TextAlign.right,
                                child: Text(
                                  formatDecimalWithNull(_companyDetail.companySemiAnnualReturn, 100) + "%",
                                  textAlign: TextAlign.right,
                                ),
                              ),
                              const SizedBox(width: 10,),
                              CompanyInfoBox(
                                header: "YTD",
                                headerAlign: TextAlign.right,
                                child: Text(
                                  formatDecimalWithNull(_companyDetail.companyYtdReturn, 100) + "%",
                                  textAlign: TextAlign.right,
                                ),
                              ),
                              const SizedBox(width: 10,),
                              CompanyInfoBox(
                                header: "Yearly",
                                headerAlign: TextAlign.right,
                                child: Text(
                                  formatDecimalWithNull(_companyDetail.companyYearlyReturn, 100) + "%",
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10,),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              CompanyInfoBox(
                                header: "Rating",
                                headerAlign: TextAlign.right,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: generateRatingIcon(_companyRating),
                                ),
                              ),
                              const SizedBox(width: 10,),
                              CompanyInfoBox(
                                header: "Risk",
                                headerAlign: TextAlign.right,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: generateRiskIcon(_companyRisk),
                                ),
                              ),
                              const SizedBox(width: 10,),
                              CompanyInfoBox(
                                header: "Type",
                                headerAlign: TextAlign.right,
                                child: Text(
                                  (Globals.companyTypeEnum[_companyDetail.companyType] ?? "Unknown"),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10,),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              CompanyInfoBox(
                                header: "Total Asset",
                                headerAlign: TextAlign.right,
                                child: Text(
                                  formatCurrency(_companyDetail.companyAssetUnderManagement!),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                              const SizedBox(width: 10,),
                              CompanyInfoBox(
                                header: "Total Unit",
                                headerAlign: TextAlign.right,
                                child: Text(
                                  formatCurrency(_companyDetail.companyTotalUnit!),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                              const SizedBox(width: 10,),
                              const Expanded(child: SizedBox()),
                            ],
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 10,),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                const SizedBox(width: 10,),
                Expanded(
                  child: Container(
                    color: primaryColor,
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          flex: 1,
                          child: Container(
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: primaryLight,
                                  width: 1.0,
                                  style: BorderStyle.solid,
                                )
                              )
                            ),
                            child: const Text(
                              "Date",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10,),
                        Expanded(
                          flex: 2,
                          child: Container(
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: primaryLight,
                                  width: 1.0,
                                  style: BorderStyle.solid,
                                )
                              )
                            ),
                            child: const Text(
                              "Price",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          )
                        ),
                        const SizedBox(width: 10,),
                        Expanded(
                          flex: 1,
                          child: Container(
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: primaryLight,
                                  width: 1.0,
                                  style: BorderStyle.solid,
                                )
                              )
                            ),
                            child: const Align(
                              alignment: Alignment.centerRight,
                              child: Icon(
                                Ionicons.swap_vertical,
                                size: 16,
                              ),
                            ),
                          )
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: ListView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                children: List<Widget>.generate(_companyDetail.companyPrices.length, (index) {
                  return CompanyDetailPriceList(
                    date: _df.format(_companyDetail.companyPrices[index].priceDate.toLocal()),
                    price: formatCurrency(_companyDetail.companyPrices[index].priceValue),
                    diff: formatCurrency(_companyDetail.companyNetAssetValue! - _companyDetail.companyPrices[index].priceValue),
                    riskColor: riskColor(_companyDetail.companyNetAssetValue!, _companyDetail.companyPrices[index].priceValue, _userInfo!.risk)
                  );
                }),
              ),
            ),
          ],
        ),
      );
    }
  }

  void setIsLoading(bool isLoading) {
    setState(() {
      _isLoading = isLoading;
    });
  }

  List<Widget> generateRiskIcon(int companyRisk) {
    List<Widget> _ret = [];
    if (companyRisk > 0) {
      _ret = List<Widget>.generate(companyRisk, (index) {
        return const Icon(
          Ionicons.alert,
          color: secondaryLight,
          size: 15,
        );
      });
    }
    else {
      _ret.add(const Icon(
        Ionicons.help,
        color: Colors.blue,
        size: 15,
      ));
    }

    return _ret;
  }

  List<Widget> generateRatingIcon(int companyRating) {
    List<Widget> _ret = [];
    if (companyRating > 0) {
      _ret = List<Widget>.generate(companyRating, (index) {
        return const Icon(
          Ionicons.star,
          color: accentLight,
          size: 15,
        );
      });
    }
    else {
      _ret.add(const Icon(
        Ionicons.help,
        color: Colors.blue,
        size: 15,
      ));
    }

    return _ret;
  }
}