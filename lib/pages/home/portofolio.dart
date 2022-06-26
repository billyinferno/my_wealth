import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:my_wealth/model/user_login.dart';
import 'package:my_wealth/model/watchlist_list_model.dart';
import 'package:my_wealth/provider/user_provider.dart';
import 'package:my_wealth/provider/watchlist_provider.dart';
import 'package:my_wealth/themes/colors.dart';
import 'package:my_wealth/utils/arguments/portofolio_list_args.dart';
import 'package:my_wealth/utils/function/compute_watchlist.dart';
import 'package:my_wealth/utils/function/format_currency.dart';
import 'package:my_wealth/utils/function/risk_color.dart';
import 'package:my_wealth/utils/prefs/shared_user.dart';
import 'package:my_wealth/utils/prefs/shared_watchlist.dart';
import 'package:my_wealth/widgets/bar_chart.dart';
import 'package:my_wealth/widgets/product_list_item.dart';
import 'package:provider/provider.dart';

class PortofolioPage extends StatefulWidget {
  const PortofolioPage({Key? key}) : super(key: key);

  @override
  State<PortofolioPage> createState() => _PortofolioPageState();
}

class _PortofolioPageState extends State<PortofolioPage> {
  final ScrollController _scrollController = ScrollController();

  late UserLoginInfoModel? _userInfo;
  late List<WatchlistListModel>? _watchlistReksadana;
  late List<WatchlistListModel>? _watchlistSaham;
  late List<WatchlistListModel>? _watchlistCrypto;
  late List<WatchlistListModel>? _watchlistGold;
  late ComputeWatchlistResult? _watchlistAll;
  late List<BarChartData> _barChartData;

  bool _isSummaryVisible = true;

  @override
  void initState() {
    _barChartData = [];
    _userInfo = UserSharedPreferences.getUserInfo();
    _watchlistReksadana = WatchlistSharedPreferences.getWatchlist("reksadana");
    _watchlistSaham = WatchlistSharedPreferences.getWatchlist("saham");
    _watchlistCrypto = WatchlistSharedPreferences.getWatchlist("crypto");
    _watchlistGold = WatchlistSharedPreferences.getWatchlist("gold");

    // initialize also in the initial state
    _watchlistAll = computeWatchlist(_watchlistReksadana!, _watchlistSaham!, _watchlistCrypto!, _watchlistGold!);

    // put the value in bar chart data
    _generateBarChartData();

    // check user visibility configuration
    _isSummaryVisible = _userInfo!.visibility;
    
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isSummaryVisible) {
      return _invisiblePage();
    }

    // if not invisible then we will just return the normal page
    return Consumer2<UserProvider, WatchlistProvider>(
      builder: ((context, userProvider, watchlistProvider, child) {
        _userInfo = userProvider.userInfo;
        _watchlistReksadana = watchlistProvider.watchlistReksadana;
        _watchlistSaham = watchlistProvider.watchlistSaham;
        _watchlistCrypto = watchlistProvider.watchlistCrypto;
        _watchlistGold = watchlistProvider.watchlistGold;

        // compute all the watchlist first
        _watchlistAll = computeWatchlist(_watchlistReksadana!, _watchlistSaham!, _watchlistCrypto!, _watchlistGold!);
        _generateBarChartData();

        return SingleChildScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              _summaryBox(
                barColor: riskColor(_watchlistAll!.totalValue, _watchlistAll!.totalCost, _userInfo!.risk),
                backgroundColor: primaryDark,
                value: _watchlistAll!.totalValue,
                cost: _watchlistAll!.totalCost,
                dayGain: _watchlistAll!.totalDayGain,
              ),
              const SizedBox(height: 10,),
              BarChart(
                data: _barChartData
              ),
              const SizedBox(height: 20,),
              ProductListItem(
                bgColor: Colors.green,
                title: "Reksadana",
                value: _watchlistAll!.totalValueReksadana,
                cost: _watchlistAll!.totalCostReksadana,
                total: _watchlistAll!.totalValue,
                onTap: (() {
                  PortofolioListArgs args = PortofolioListArgs(
                    title: "Reksadana",
                    value: _watchlistAll!.totalValueReksadana,
                    cost: _watchlistAll!.totalCostReksadana,
                    type: "reksadana"
                  );
                  Navigator.pushNamed(context, '/portofolio/list', arguments: args);
                })
              ),
              ProductListItem(
                bgColor: Colors.pink,
                title: "Stock",
                value: _watchlistAll!.totalValueSaham,
                cost: _watchlistAll!.totalCostSaham,
                total: _watchlistAll!.totalValue,
                onTap: (() {
                  PortofolioListArgs args = PortofolioListArgs(
                    title: "Stock",
                    value: _watchlistAll!.totalValueSaham,
                    cost: _watchlistAll!.totalCostSaham,
                    type: "saham"
                  );
                  Navigator.pushNamed(context, '/portofolio/list', arguments: args);
                })
              ),
              ProductListItem(
                bgColor: Colors.purple,
                title: "Crypto",
                value: _watchlistAll!.totalValueCrypto,
                cost: _watchlistAll!.totalCostCrypto,
                total: _watchlistAll!.totalValue,
                onTap: (() {
                  // do nothing, we just want to showed the chevron icon here
                })
              ),
              ProductListItem(
                bgColor: Colors.amber,
                title: "Gold",
                value: _watchlistAll!.totalValueGold,
                cost: _watchlistAll!.totalCostGold,
                total: _watchlistAll!.totalValue,
                onTap: (() {
                  // do nothing, we just want to showed the chevron icon here
                })
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _invisiblePage() {
    return Center(
      child: InkWell(
        onTap: (() {
          setState(() {
            _isSummaryVisible = true;
          });
        }),
        child: Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: primaryDark,
            borderRadius: BorderRadius.circular(100),
          ),
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: const <Widget>[
              Icon(
                Ionicons.eye_off,
                color: primaryLight,
                size: 35,
              ),
              Text(
                "Click here to view",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  color: primaryLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _generateBarChartData() {
    _barChartData.clear();
    _barChartData.add(BarChartData(title: "Reksadana", value: _watchlistAll!.totalValueReksadana, total: _watchlistAll!.totalValue, color: Colors.green));
    _barChartData.add(BarChartData(title: "Stock", value: _watchlistAll!.totalValueSaham, total: _watchlistAll!.totalValue, color: Colors.pink));
    _barChartData.add(BarChartData(title: "Crypto", value: _watchlistAll!.totalValueCrypto, total: _watchlistAll!.totalValue, color: Colors.purple));
    _barChartData.add(BarChartData(title: "Gold", value: _watchlistAll!.totalValueGold, total: _watchlistAll!.totalValue, color: Colors.amber));
  }

  Widget _summaryBox({required Color barColor, required double value, required double cost, required double dayGain, Color? backgroundColor, String? title, double? fontSize}) {
    Color bgColor = backgroundColor ?? primaryColor;
    bool gotTitle = title == null ? false : true;
    String titleText = title ?? '';
    double summarySize = fontSize ?? 20;
    double gain = value - cost;
    Color trendColor = Colors.white;
    IconData trendIcon = Ionicons.remove;
    // Color dayGainColor = Colors.white;
    // IconData dayGainIcon = Ionicons.remove;

    if (gain > 0) {
      trendColor = Colors.green;
      trendIcon = Ionicons.trending_up;
    }
    else if(gain < 0) {
      trendColor = secondaryColor;
      trendIcon = Ionicons.trending_down;
    }

    // if (dayGain > 0) {
    //   dayGainColor = Colors.green;
    //   dayGainIcon = Ionicons.add_outline;
    // }
    // else if (dayGain < 0) {
    //   dayGainColor = secondaryColor;
    // }

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
                  _largeText(formatCurrency(value, false, true, false), summarySize),
                  const SizedBox(height: 5,),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _smallText("Total Cost"),
                          const SizedBox(height: 5,),
                          Text(
                            formatCurrency(cost, false, true, false),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 5,),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _smallText("Total Gain"),
                            const SizedBox(height: 5,),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                Icon(
                                  trendIcon,
                                  color: trendColor,
                                  size: 18,
                                ),
                                const SizedBox(width: 5,),
                                Text(
                                  formatCurrency(gain, false, true, false),
                                  style: TextStyle(
                                    color: trendColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
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