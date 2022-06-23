import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_wealth/api/broker_summary_api.dart';
import 'package:my_wealth/api/company_api.dart';
import 'package:my_wealth/model/broker_summary_top_model.dart';
import 'package:my_wealth/provider/broker_provider.dart';
import 'package:my_wealth/themes/colors.dart';
import 'package:my_wealth/utils/arguments/company_detail_args.dart';
import 'package:my_wealth/utils/dialog/create_snack_bar.dart';
import 'package:my_wealth/utils/function/format_currency.dart';
import 'package:my_wealth/utils/loader/show_loader_dialog.dart';
import 'package:my_wealth/utils/prefs/shared_broker.dart';
import 'package:provider/provider.dart';

class InsightBrokerPage extends StatefulWidget {
  const InsightBrokerPage({Key? key}) : super(key: key);

  @override
  State<InsightBrokerPage> createState() => _InsightBrokerPageState();
}

class _InsightBrokerPageState extends State<InsightBrokerPage> {
  final CompanyAPI _companyAPI = CompanyAPI();
  final BrokerSummaryAPI _brokerSummaryAPI = BrokerSummaryAPI();
  final DateFormat _df = DateFormat('dd MMM yyyy');
  final ScrollController _scrollController = ScrollController();
  late BrokerSummaryTopModel? _brokerTopList;
  late List<BrokerSummaryBuyElement> _brokerTopListBuy;
  late List<BrokerSummaryBuyElement> _brokerTopListSell;
  late String _brokerSummarySelected;

  @override
  void initState() {
    _brokerTopList = BrokerSharedPreferences.getBrokerTopList();
    _brokerSummarySelected = 'a';
    _brokerTopListBuy = _brokerTopList!.brokerSummaryAll.brokerSummaryBuy;
    _brokerTopListSell = _brokerTopList!.brokerSummaryAll.brokerSummarySell;

    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();

    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Consumer<BrokerProvider>(
      builder: ((context, brokerProvider, child) {
        _brokerTopList = brokerProvider.brokerTopList;

        return RefreshIndicator(
          onRefresh: (() async {
            showLoaderDialog(context);
            Future.microtask(() async {
              // get the broker summary top list
              await _brokerSummaryAPI.getBrokerSummaryTop().then((resp) async {
                await BrokerSharedPreferences.setBroketTopList(resp);
                if (!mounted) return;
                Provider.of<BrokerProvider>(context, listen: false).setBrokerTopList(resp);
              }).onError((error, stackTrace) {
                // show the snack bar
                ScaffoldMessenger.of(context).showSnackBar(createSnackBar(message: "Unable to get broker top list"));
                debugPrintStack(stackTrace: stackTrace);
              });

            }).whenComplete(() {
              Navigator.pop(context);
            });
          }),
          color: accentColor,
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            child: Container(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  const Center(
                    child: Text(
                      "Broker Top Traded Stock",
                      style: TextStyle(
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      _df.format(_brokerTopList!.brokerSummaryDate.toLocal()),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10,),
                  SizedBox(
                    width: double.infinity,
                    child: CupertinoSegmentedControl(
                      children: const {
                        "a": Text("All"),
                        "d": Text("Domestic"),
                        "f": Text("Foreign"),
                      },
                      onValueChanged: ((value) {
                        String selectedValue = value.toString();
                            
                        setState(() {
                          if(selectedValue == "a") {
                            _brokerTopListBuy = _brokerTopList!.brokerSummaryAll.brokerSummaryBuy;
                            _brokerTopListSell = _brokerTopList!.brokerSummaryAll.brokerSummarySell;
                            _brokerSummarySelected = "a";
                          }
                          else if(selectedValue == "d") {
                            _brokerTopListBuy = _brokerTopList!.brokerSummaryDomestic.brokerSummaryBuy;
                            _brokerTopListSell = _brokerTopList!.brokerSummaryDomestic.brokerSummarySell;
                            _brokerSummarySelected = "d";
                          }
                          else if(selectedValue == "f") {
                            _brokerTopListBuy = _brokerTopList!.brokerSummaryForeign.brokerSummaryBuy;
                            _brokerTopListSell = _brokerTopList!.brokerSummaryForeign.brokerSummarySell;
                            _brokerSummarySelected = "f";
                          }
                        });
                      }),
                      groupValue: _brokerSummarySelected,
                      selectedColor: secondaryColor,
                      borderColor: secondaryDark,
                      pressedColor: primaryDark,
                    ),
                  ),
                  const SizedBox(height: 10,),
                  _generateRow(
                    num: '#',
                    code: 'Code',
                    lastPrice: 'Last',
                    average: 'B.Avg',
                    lot: 'B.Lot',
                    count: 'Cnt',
                    backgroundColor: Colors.green[900],
                    textBold: true,
                  ),
                  _generateBrokerTopListTable(_brokerTopListBuy),
                  const SizedBox(height: 5,),
                  _generateRow(
                    num: '#',
                    code: 'Code',
                    lastPrice: 'Last',
                    average: 'S.Avg',
                    lot: 'S.Lot',
                    count: 'Cnt',
                    backgroundColor: secondaryDark,
                    textBold: true,
                  ),
                  _generateBrokerTopListTable(_brokerTopListSell),
                  // const SizedBox(height: 20,),
                  // const Center(
                  //   child: Text(
                  //     "Broker Big Accumulation",
                  //     style: TextStyle(
                  //       fontWeight: FontWeight.bold
                  //     ),
                  //   ),
                  // ),
                  // const SizedBox(height: 10,),
                  // Text("Data here"),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _generateRow({required String num, required String code, required String lastPrice, required String average, required String lot, required String count, Color? textColor, bool? textBold, Color? backgroundColor}) {
    Color textColorUse = (textColor ?? Colors.white);
    bool textBoldUse = (textBold ?? false);
    Color backgroundColorUse = (backgroundColor ?? Colors.transparent);

    return InkWell(
      onTap: (() async {
        showLoaderDialog(context);
        await _companyAPI.getCompanyByCode(code, 'saham').then((resp) {
          CompanyDetailArgs args = CompanyDetailArgs(
            companyId: resp.companyId,
            companyName: resp.companyName,
            companyCode: code,
            companyFavourite: false,
            favouritesId: -1,
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
      child: SizedBox(
        width: double.infinity,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 35,
              color: backgroundColorUse,
              padding: const EdgeInsets.all(2),
              child: Center(
                child: Text(
                  num,
                  style: TextStyle(
                    fontWeight: (textBoldUse ? FontWeight.bold : FontWeight.normal),
                    color: textColorUse
                  ),
                )
              ),
            ),
            Container(
              color: backgroundColorUse,
              padding: const EdgeInsets.all(2),
              width: 55,
              child: Text(
                code,
                style: TextStyle(
                  fontWeight: (textBoldUse ? FontWeight.bold : FontWeight.normal),
                  color: textColorUse
                ),
              ),
            ),
            Expanded(
              child: Container(
                color: backgroundColorUse,
                padding: const EdgeInsets.all(2),
                child: Text(
                  lastPrice,
                  style: TextStyle(
                    fontWeight: (textBoldUse ? FontWeight.bold : FontWeight.normal),
                    color: textColorUse
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                color: backgroundColorUse,
                padding: const EdgeInsets.all(2),
                child: Text(
                  average,
                  style: TextStyle(
                    fontWeight: (textBoldUse ? FontWeight.bold : FontWeight.normal),
                    color: textColorUse
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                color: backgroundColorUse,
                padding: const EdgeInsets.all(2),
                child: Text(
                  lot,
                  style: TextStyle(
                    fontWeight: (textBoldUse ? FontWeight.bold : FontWeight.normal),
                    color: textColorUse
                  ),
                ),
              ),
            ),
            Container(
              width: 35,
              color: backgroundColorUse,
              padding: const EdgeInsets.all(2),
              child: Center(
                child: Text(
                  count,
                  style: TextStyle(
                    fontWeight: (textBoldUse ? FontWeight.bold : FontWeight.normal),
                    color: textColorUse
                  ),
                )
              ),
            ),
          ], 
        ),
      ),
    );
  }

  Widget _generateBrokerTopListTable(List<BrokerSummaryBuyElement> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        ...List<Widget>.generate(data.length, (index) {
          return _generateRow(
            num: (index+1).toString(),
            code: data[index].brokerSummaryCode,
            lastPrice: formatIntWithNull(data[index].brokerSummaryLastPrice, false, false),
            average: formatIntWithNull(data[index].brokerSummaryAverage, false, false),
            lot: formatIntWithNull(data[index].brokerSummaryLot, true, true),
            count: data[index].brokerSummaryCount
          );
        }),
      ],
    );
  }
}