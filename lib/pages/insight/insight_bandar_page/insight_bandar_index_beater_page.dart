import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:my_wealth/api/company_api.dart';
import 'package:my_wealth/api/insight_api.dart';
import 'package:my_wealth/model/index/index_beater_model.dart';
import 'package:my_wealth/themes/colors.dart';
import 'package:my_wealth/utils/arguments/company_detail_args.dart';
import 'package:my_wealth/utils/dialog/create_snack_bar.dart';
import 'package:my_wealth/utils/dialog/show_info_dialog.dart';
import 'package:my_wealth/utils/function/format_currency.dart';
import 'package:my_wealth/utils/loader/show_loader_dialog.dart';
import 'package:my_wealth/storage/prefs/shared_insight.dart';

class InsightBandarIndexBeaterPage extends StatefulWidget {
  const InsightBandarIndexBeaterPage({Key? key}) : super(key: key);

  @override
  State<InsightBandarIndexBeaterPage> createState() => InsightBandarIndexBeaterPageState();
}

class InsightBandarIndexBeaterPageState extends State<InsightBandarIndexBeaterPage> {
  final InsightAPI _insightAPI = InsightAPI();
  final CompanyAPI _companyAPI = CompanyAPI();

  late List<IndexBeaterModel> _indexBeaterList;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _isLoading = true;
    _indexBeaterList = InsightSharedPreferences.getIndexBeater();

    // check if the list is empty, if empty it means we haven't inquiry any data to server
    if (_indexBeaterList.isEmpty) {
      Future.microtask(() async {
        showLoaderDialog(context);

        await _insightAPI.getIndexBeater().then((resp) {
          _indexBeaterList = resp;

          InsightSharedPreferences.setIndexBeater(resp);
        });
      }).whenComplete(() {
        // remove loader dialog
        Navigator.pop(context);
        // set loading into false
        _setLoading(false);
      });
    }
    else {
      // already got data, just set loading into false
      _setLoading(false);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // if loading show this
    if (_isLoading) {
      return const Center(child: Text("Load Index Beater data..."),);
    }

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          GestureDetector(
            onTap: (() async {
              await ShowInfoDialog(
                title: "Index Beater",
                text: "List of stocks that beat the average daily, weekly, mtd, and ytd of Index on this lists: Sri Kehati, Bisnis 27, IDX 30, IDX Growth 30, IHSG, ISSI, JII, JII 70, and LQ45",
                okayColor: secondaryLight,
              ).show(context);
            }),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  "Index Beater",
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
          Expanded(
            child: ListView.builder(
              itemCount: _indexBeaterList.length,
              itemBuilder: ((context, index) {
                int priceDiff = (_indexBeaterList[index].lastPrice - _indexBeaterList[index].prevClosingPrice!);
    
                return InkWell(
                  onTap: (() async {
                    showLoaderDialog(context);
                    await _companyAPI.getCompanyByCode(_indexBeaterList[index].code, 'saham').then((resp) {
                      CompanyDetailArgs args = CompanyDetailArgs(
                        companyId: resp.companyId,
                        companyName: resp.companyName,
                        companyCode: _indexBeaterList[index].code,
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
                    padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: primaryLight,
                          width: 1.0,
                          style: BorderStyle.solid,
                        )
                      ),
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
                              "(${_indexBeaterList[index].code})",
                              style: const TextStyle(
                                color: accentColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 5,),
                            Expanded(
                              child: Text(
                                _indexBeaterList[index].name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 5,),
                            Text(
                              formatIntWithNull(_indexBeaterList[index].lastPrice, false, false),
                              style: const TextStyle(
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 2,),
                            Text(
                              "(${(priceDiff > 0 ? "+" : "-")}${formatIntWithNull(priceDiff, false, false)})",
                              style: TextStyle(
                                fontSize: 10,
                                color: (priceDiff < 0 ? secondaryColor : (priceDiff > 0 ? Colors.green : textPrimary)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10,),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            _columnText(header: "One Day", value: _indexBeaterList[index].oneDay),
                            const SizedBox(width: 10,),
                            _columnText(header: "One Week", value: _indexBeaterList[index].oneWeek),
                            const SizedBox(width: 10,),
                            _columnText(header: "MTD", value: _indexBeaterList[index].mtd),
                            const SizedBox(width: 10,),
                            _columnText(header: "One Month", value: _indexBeaterList[index].oneMonth),
                          ],
                        ),
                        const SizedBox(height: 5,),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            _columnText(header: "Three Month", value: _indexBeaterList[index].threeMonth),
                            const SizedBox(width: 10,),
                            _columnText(header: "Six Month", value: _indexBeaterList[index].sixMonth),
                            const SizedBox(width: 10,),
                            _columnText(header: "YTD", value: _indexBeaterList[index].ytd),
                            const SizedBox(width: 10,),
                            _columnText(header: "One Year", value: _indexBeaterList[index].oneYear),
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

  Widget _columnText({required String header, required double value}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Text(
            header,
            style: const TextStyle(
              fontSize: 10,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 5,),
          Text(
            "${formatDecimalWithNull(value, 100, 2)}%",
            style: TextStyle(
              fontSize: 10,
              color: (value == 0 ? Colors.white : (value > 0 ? Colors.green : secondaryColor)),
            ),
          ),
        ],
      ),
    );
  }

  void _setLoading(bool value) {
    setState(() {
      _isLoading = value;
    });
  }
}