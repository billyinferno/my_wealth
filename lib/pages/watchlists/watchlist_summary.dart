import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:my_wealth/model/user_login.dart';
import 'package:my_wealth/themes/colors.dart';
import 'package:my_wealth/utils/arguments/watchlist_summary_args.dart';
import 'package:my_wealth/utils/function/format_currency.dart';
import 'package:my_wealth/utils/function/risk_color.dart';
import 'package:my_wealth/utils/prefs/shared_user.dart';

class WatchlistSummaryPage extends StatefulWidget {
  final Object? args;
  const WatchlistSummaryPage({Key? key, required this.args}) : super(key: key);

  @override
  State<WatchlistSummaryPage> createState() => _WatchlistSummaryPageState();
}

class _WatchlistSummaryPageState extends State<WatchlistSummaryPage> {
  late WatchlistSummaryArgs _args;
  late UserLoginInfoModel _userInfo;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    _args = widget.args as WatchlistSummaryArgs;
    _userInfo = UserSharedPreferences.getUserInfo()!;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: ((() {
            // return back to the previous page
            Navigator.pop(context);
          })),
          icon: const Icon(
            Ionicons.arrow_back,
          )
        ),
        title: const Center(
          child: Text(
            "Watchlist Summary",
            style: TextStyle(
              color: secondaryColor,
            ),
          )
        ),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            _summaryBox(
              barColor: riskColor(_args.totalValue, _args.totalCost, _userInfo.risk),
              backgroundColor: primaryDark,
              value: _args.totalValue,
              cost: _args.totalCost,
            ),
            const SizedBox(height: 10,),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: _generateBar(),
              ),
            ),
            const SizedBox(height: 5,),
            Container(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  _barLegend("Reksadana", Colors.green),
                  _barLegend("Stock", Colors.pink),
                  _barLegend("Crypto", Colors.purple),
                  _barLegend("Gold", Colors.amber),
                ],
              ),
            ),
            const SizedBox(height: 10,),
            _summaryBox(
              barColor: Colors.green,
              title: "Reksadana",
              value: _args.totalValueReksadana,
              cost: _args.totalCostReksadana,
              fontSize: 15,
            ),
            _summaryBox(
              barColor: Colors.pink,
              title: "Stock",
              value: _args.totalValueSaham,
              cost: _args.totalCostSaham,
              fontSize: 15,
            ),
            _summaryBox(
              barColor: Colors.purple,
              title: "Crypto",
              value: _args.totalValueCrypto,
              cost: _args.totalCostCrypto,
              fontSize: 15,
            ),
            _summaryBox(
              barColor: Colors.amber,
              title: "Gold",
              value: _args.totalValueGold,
              cost: _args.totalValueGold,
              fontSize: 15,
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryBox({required Color barColor, required double value, required double cost, Color? backgroundColor, String? title, double? fontSize}) {
    Color bgColor = backgroundColor ?? primaryColor;
    bool gotTitle = title == null ? false : true;
    String titleText = title ?? '';
    double summarySize = fontSize ?? 20;

    return Container(
      color: barColor,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          const SizedBox(width: 10,),
          Expanded(
            child: Container(
              color: bgColor,
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Visibility(
                    visible: gotTitle,
                    child: Text(
                      titleText,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    )
                  ),
                  Visibility(visible: gotTitle, child: const SizedBox(height: 10,)),
                  _smallText("Total Value"),
                  _largeText("IDR ${formatCurrency(value, false, true, false)}", summarySize),
                  const SizedBox(height: 10,),
                  _smallText("Total Cost"),
                  _largeText("IDR ${formatCurrency(cost, false, true, false)}", summarySize),
                  const SizedBox(height: 10,),
                  _smallText("Total Gain"),
                  _largeText("IDR ${formatCurrency((value - cost), false, true, false)}", summarySize),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _barLegend(String text, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          height: 10,
          width: 10,
          color: color,
        ),
        const SizedBox(width: 5,),
        Text(
          text,
          style: const TextStyle(
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  List<Widget> _generateBar() {
    List<Widget> result = [];
    int flexCalc = 0;

    // add each as expanded with flex
    if (_args.totalValueReksadana > 0) {
      flexCalc = ((_args.totalValueReksadana / _args.totalValue) * 100).toInt();
      if (flexCalc <= 0) {
        flexCalc = 1;
      }

      result.add(
        Expanded(
          flex:  flexCalc,
          child: Container(
            height: 25,
            color: Colors.green,
          ),
        )
      );
    }

    if (_args.totalValueSaham > 0) {
      flexCalc = ((_args.totalValueSaham / _args.totalValue) * 100).toInt();
      if (flexCalc <= 0) {
        flexCalc = 1;
      }

      result.add(
        Expanded(
          flex:  flexCalc,
          child: Container(
            height: 25,
            color: Colors.pink,
          ),
        )
      );
    }

    if (_args.totalValueCrypto > 0) {
      flexCalc = ((_args.totalValueCrypto / _args.totalValue) * 100).toInt();
      if (flexCalc <= 0) {
        flexCalc = 1;
      }

      result.add(
        Expanded(
          flex:  flexCalc,
          child: Container(
            height: 25,
            color: Colors.purple,
          ),
        )
      );
    }

    if (_args.totalValueGold > 0) {
      flexCalc = ((_args.totalValueGold / _args.totalValue) * 100).toInt();
      if (flexCalc <= 0) {
        flexCalc = 1;
      }

      result.add(
        Expanded(
          flex:  flexCalc,
          child: Container(
            height: 25,
            color: Colors.amber,
          ),
        )
      );
    }

    return result;
  }

  Widget _smallText(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
      ),
    );
  }

  Widget _largeText(String text, [double? size]) {
    double textSize = size ?? 20;

    return Text(
      text,
      style: TextStyle(
        fontSize: textSize,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}