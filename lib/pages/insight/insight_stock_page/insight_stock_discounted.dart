import 'package:flutter/material.dart';
import 'package:my_wealth/_index.g.dart';
import 'package:provider/provider.dart';

class InsightStockDiscountedSubPage extends StatefulWidget {
  final Function({required String code}) getCompanyDetailAndGo;

  const InsightStockDiscountedSubPage({
    super.key,
    required this.getCompanyDetailAndGo,
  });

  @override
  State<InsightStockDiscountedSubPage> createState() => _InsightStockDiscountedSubPageState();
}

class _InsightStockDiscountedSubPageState extends State<InsightStockDiscountedSubPage> {
  final ScrollController _scrollController = ScrollController();

  late List<InsightStockDiscountedModel> _stockDiscountedList;
  
  @override
  void initState() {
    // get the stock discounted list from shared preferences
    _stockDiscountedList = InsightSharedPreferences.getStockDiscounted();

    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_stockDiscountedList.isEmpty) {
      return Center(
        child: Text(
          "No data",
        ),
      );
    }

    return Consumer<InsightProvider>(
      builder: (context, insightProvider, child) {
        // get the stock discounted list from provider
        _stockDiscountedList = (insightProvider.stockDiscountedList ?? []);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(
              "Stock discounted are calculated using difference of current price, with forecasting neutral price, and current PBV/R with forecasting neutral PBV/R analysis",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 10,),
            _createRow(
              num: "#",
              code: "CODE",
              price: "PRICE",
              priceNeutral: "NEUTRAL",
              pbv: "PBV",
              pbvNeutral: "NEUTRAL",
              avgDiff: "AVG",
              bgColor: Colors.green[900]!,
              fontWeight: FontWeight.bold,
              align: TextAlign.start,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: List<Widget>.generate(_stockDiscountedList.length, (index) {
                return InkWell(
                  onTap: () {
                    widget.getCompanyDetailAndGo(code: _stockDiscountedList[index].code);
                  },
                  child: _createRow(
                    num: "${index + 1}",
                    code: _stockDiscountedList[index].code,
                    price: formatCurrency(_stockDiscountedList[index].lastPrice, showDecimal: false),
                    priceNeutral: formatCurrency(_stockDiscountedList[index].priceNeutral, showDecimal: false),
                    pbv: formatCurrency(_stockDiscountedList[index].pbr),
                    pbvNeutral: formatCurrency(_stockDiscountedList[index].pbvNeutral),
                    avgDiff: formatCurrency(_stockDiscountedList[index].avgDiff),
                  ),
                );
              }),
            ),
          ],
        );
      },
    );
  }

  Widget _createRow({
    required String num,
    required String code,
    required String price,
    required String priceNeutral,
    required String pbv,
    required String pbvNeutral,
    required String avgDiff,
    Color bgColor = primaryDark,
    Color borderColor = primaryLight,
    FontWeight fontWeight = FontWeight.normal,
    TextAlign align = TextAlign.end,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          bottom: BorderSide(
            color: borderColor,
            width: 1.0,
            style: BorderStyle.solid,
          )
        )
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.fromLTRB(5, 5, 0, 5),
              width: 40,
              height: 55,
              child: Center(
                child: Text(
                  num,
                  style: TextStyle(
                    fontWeight: fontWeight,
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(5, 5, 0, 5),
              width: 80,
              height: 55,
              child: Center(
                child: Text(
                  code,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: fontWeight,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(5, 5, 5, 0),
                    child: Text(
                      price,
                      overflow: TextOverflow.ellipsis,
                      textAlign: align,
                      style: TextStyle(
                        fontWeight: fontWeight,
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(5),
                    child: Text(
                      priceNeutral,
                      overflow: TextOverflow.ellipsis,
                      textAlign: align,
                      style: TextStyle(
                        fontWeight: fontWeight,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(5, 5, 5, 0),
                    child: Text(
                      pbv,
                      overflow: TextOverflow.ellipsis,
                      textAlign: align,
                      style: TextStyle(
                        fontWeight: fontWeight,
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(5),
                    child: Text(
                      pbvNeutral,
                      overflow: TextOverflow.ellipsis,
                      textAlign: align,
                      style: TextStyle(
                        fontWeight: fontWeight,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.fromLTRB(5, 5, 0, 5),
                height: 55,
                child: Center(
                  child: Text(
                    avgDiff,
                    overflow: TextOverflow.ellipsis,
                    textAlign: align,
                    style: TextStyle(
                      fontWeight: fontWeight,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}