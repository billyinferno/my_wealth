import 'package:flutter/material.dart';
import 'package:my_wealth/_index.g.dart';
import 'package:provider/provider.dart';

class InsightStockLatestSplitSubPage extends StatefulWidget {
  final Function({required String code}) getCompanyDetailAndGo;

  const InsightStockLatestSplitSubPage({
    super.key,
    required this.getCompanyDetailAndGo,
  });

  @override
  State<InsightStockLatestSplitSubPage> createState() => _InsightStockLatestSplitSubPageState();
}

class _InsightStockLatestSplitSubPageState extends State<InsightStockLatestSplitSubPage> {
  late List<StockSplitListModel> _stockSplitList;

  @override
  void initState() {
    super.initState();

    // get the stock split list from shared preferences for initial data
    _stockSplitList = InsightSharedPreferences.getStockSplitList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<InsightProvider, CompanyProvider>(
      builder: (context, insightProvider, companyProvider, child) {
        // get the stock split list from provider, so we can refresh the page
        // if we got the new data.
        _stockSplitList = (insightProvider.stockSplitList ?? []);
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
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
                    onTap: (() {
                      // click and go to the company
                      widget.getCompanyDetailAndGo(code: _stockSplitList[index].code);
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
                              SmallBox(
                                title: "Ratio",
                                value: _stockSplitList[index].ratio
                              ),
                              const SizedBox(width: 10,),
                              SmallBox(
                                title: "Listed Shares",
                                value: formatIntWithNull(
                                  _stockSplitList[index].listedShares,
                                  checkThousand: true,
                                  decimalNum: 2
                                )
                              ),
                              const SizedBox(width: 10,),
                              SmallBox(
                                title: "Split Date",
                                value: Globals.dfddMMyyyy.formatDateWithNull(
                                  _stockSplitList[index].listingDate
                                )
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