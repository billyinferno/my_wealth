import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_wealth/_index.g.dart';
import 'package:provider/provider.dart';

class InsightStockNewlyListedSubPage extends StatefulWidget {
  final Function({required String code}) getCompanyDetailAndGo;

  const InsightStockNewlyListedSubPage({
    super.key,
    required this.getCompanyDetailAndGo,
  });

  @override
  State<InsightStockNewlyListedSubPage> createState() => _InsightStockNewlyListedSubPageState();
}

class _InsightStockNewlyListedSubPageState extends State<InsightStockNewlyListedSubPage> {
  late List<StockNewListedModel> _stockNewListedList;

  @override
  void initState() {
    super.initState();

    // get the stock newly listed from the shared preferences for the initial
    // data.
    _stockNewListedList = InsightSharedPreferences.getStockNewListed();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<InsightProvider, CompanyProvider>(
      builder: (context, insightProvider, companyProvider, child) {
        // get the stock newly listed from provider, so incase any update we
        // can update the page also
        _stockNewListedList = (insightProvider.stockNewListed ?? []);
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
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
                    onTap: (() {
                      // check if the listed date is more than today date?
                      if (_stockNewListedList[index].listedDate != null) {
                        if (_stockNewListedList[index].listedDate!.isBefore(DateTime.now())) {
                          widget.getCompanyDetailAndGo(code: _stockNewListedList[index].code);
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
                              SmallBox(
                                title: "Listed Shares",
                                value: formatIntWithNull(
                                  _stockNewListedList[index].listedShares,
                                  checkThousand: true,
                                  decimalNum: 2
                                )
                              ),
                              const SizedBox(width: 10,),
                              SmallBox(
                                title: "Shares Offered",
                                value: formatIntWithNull(
                                  _stockNewListedList[index].numOfShares,
                                  checkThousand: true,
                                  decimalNum: 2
                                )
                              ),
                              const SizedBox(width: 10,),
                              SmallBox(
                                title: "% Shares",
                                value: "${formatDecimalWithNull(
                                  (_stockNewListedList[index].numOfShares ?? 0) / (_stockNewListedList[index].listedShares ?? 1),
                                  times: 100,
                                  decimal: 2
                                )}%"
                              ),
                            ],
                          ),
                          const SizedBox(height: 5,),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              SmallBox(
                                title: "Offering Price",
                                value: formatCurrencyWithNull(
                                  (_stockNewListedList[index].offering ?? 0).toDouble(),
                                  showDecimal: false,
                                  shorten: false,
                                  decimalNum: 0
                                )),
                              const SizedBox(width: 10,),
                              SmallBox(
                                title: "Fund Raised",
                                value: formatIntWithNull(
                                  _stockNewListedList[index].fundRaised,
                                  checkThousand: true,
                                  decimalNum: 2
                                )
                              ),
                              const SizedBox(width: 10,),
                              SmallBox(
                                title: "Listed Date",
                                value: Globals.dfddMMyyyy.formatDateWithNull(
                                  _stockNewListedList[index].listedDate
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
                                title: "Current Price",
                                value: formatCurrencyWithNull(
                                  (_stockNewListedList[index].currentPrice ?? 0).toDouble(),
                                  showDecimal: false,
                                  shorten: false,
                                  decimalNum: 0
                                )),
                              const SizedBox(width: 10,),
                              SmallBox(
                                title: "Diff Price",
                                value: formatIntWithNull(
                                  (_stockNewListedList[index].currentPrice! > 0 ? _stockNewListedList[index].currentPrice! - _stockNewListedList[index].offering! : null),
                                  showDecimal: false,
                                  decimalNum: 0
                                )
                              ),
                              const SizedBox(width: 10,),
                              SmallBox(
                                title: "% Diff",
                                value: "${formatDecimalWithNull(
                                  (_stockNewListedList[index].currentPrice! > 0 ? (_stockNewListedList[index].currentPrice! - _stockNewListedList[index].offering!) / _stockNewListedList[index].offering! : null),
                                  times: 100,
                                  decimal: 2
                                )}%"),
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