import 'package:flutter/material.dart';
import 'package:my_wealth/_index.g.dart';
import 'package:provider/provider.dart';

class InsightStockLatestDividendSubPage extends StatefulWidget {
  final Function({required String code}) getCompanyDetailAndGo;
  
  const InsightStockLatestDividendSubPage({
    super.key,
    required this.getCompanyDetailAndGo,
  });

  @override
  State<InsightStockLatestDividendSubPage> createState() => _InsightStockLatestDividendSubPageState();
}

class _InsightStockLatestDividendSubPageState extends State<InsightStockLatestDividendSubPage> {
  late List<StockDividendListModel> _stockDividendList;

  @override
  void initState() {
    super.initState();

    // get the stock latest dividend from shared preferences for the initial
    // data
    _stockDividendList = InsightSharedPreferences.getStockDividendList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<InsightProvider>(
      builder: (context, insightProvider, child) {
        // get the stock list from provider, so in case we refresh the data
        // the page will be refreshed also
        _stockDividendList = (insightProvider.stockDividendList ?? []);
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
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
                    onTap: (() {
                      widget.getCompanyDetailAndGo(code: _stockDividendList[index].code);
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
                              SmallBox(
                                title: "Cum Date",
                                value: Globals.dfddMMyyyy.formatDateWithNull(
                                  _stockDividendList[index].cumDividend
                                )
                              ),
                              const SizedBox(width: 10,),
                              SmallBox(
                                title: "Ex Date",
                                value: Globals.dfddMMyyyy.formatDateWithNull(
                                  _stockDividendList[index].exDividend
                                )
                              ),
                              const SizedBox(width: 10,),
                              SmallBox(
                                title: "Dividend",
                                value: formatDecimalWithNull(
                                  _stockDividendList[index].cashDividend,
                                  decimal: 2
                                )
                              ),
                            ],
                          ),
                          const SizedBox(height: 5,),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              SmallBox(
                                title: "Record Date",
                                value: Globals.dfddMMyyyy.formatDateWithNull(
                                  _stockDividendList[index].recordDate
                                )
                              ),
                              const SizedBox(width: 10,),
                              SmallBox(
                                title: "Payment Date",
                                value: Globals.dfddMMyyyy.formatDateWithNull(
                                  _stockDividendList[index].paymentDate
                                )
                              ),
                              const SizedBox(width: 10,),
                              const Expanded(
                                child: SizedBox(
                                  width: double.infinity,
                                ),
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
        );  
      },
    );
  }
}