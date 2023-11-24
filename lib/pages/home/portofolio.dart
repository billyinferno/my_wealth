import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:my_wealth/model/user/user_login.dart';
import 'package:my_wealth/model/watchlist/watchlist_list_model.dart';
import 'package:my_wealth/provider/user_provider.dart';
import 'package:my_wealth/provider/watchlist_provider.dart';
import 'package:my_wealth/themes/colors.dart';
import 'package:my_wealth/utils/arguments/portofolio_list_args.dart';
import 'package:my_wealth/utils/function/compute_watchlist_all.dart';
import 'package:my_wealth/utils/function/format_currency.dart';
import 'package:my_wealth/utils/function/risk_color.dart';
import 'package:my_wealth/storage/prefs/shared_user.dart';
import 'package:my_wealth/storage/prefs/shared_watchlist.dart';
import 'package:my_wealth/widgets/chart/bar_chart.dart';
import 'package:my_wealth/widgets/list/product_list_item.dart';
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
  late ComputeWatchlistAllResult? _watchlistAll;
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
    _watchlistAll = computeWatchlistAll(_watchlistReksadana!, _watchlistSaham!, _watchlistCrypto!, _watchlistGold!);

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
        _watchlistAll = computeWatchlistAll(_watchlistReksadana!, _watchlistSaham!, _watchlistCrypto!, _watchlistGold!);
        _generateBarChartData();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _summaryBox(
              barColor: riskColor(_watchlistAll!.totalValue, _watchlistAll!.totalCost, _userInfo!.risk),
              backgroundColor: primaryDark,
              value: _watchlistAll!.totalValue,
              cost: _watchlistAll!.totalCost,
              realised: _watchlistAll!.totalRealised,
              dayGain: _watchlistAll!.totalDayGain,
            ),
            const SizedBox(height: 10,),
            BarChart(
              data: _barChartData
            ),
            const SizedBox(height: 20,),
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    ProductListItem(
                      bgColor: Colors.green,
                      title: "Reksadana",
                      value: _watchlistAll!.totalValueReksadana,
                      cost: _watchlistAll!.totalCostReksadana,
                      total: _watchlistAll!.totalValue,
                      realised: _watchlistAll!.totalRealisedReksadana,
                      dayGain: _watchlistAll!.totalDayGainReksadana,
                      onTap: (() {
                        PortofolioListArgs args = PortofolioListArgs(
                          title: "Reksadana",
                          value: _watchlistAll!.totalValueReksadana,
                          cost: _watchlistAll!.totalCostReksadana,
                          realised: _watchlistAll!.totalRealisedReksadana,
                          unrealised: (_watchlistAll!.totalValueReksadana - _watchlistAll!.totalCostReksadana),
                          type: "reksadana",
                          showSort: false,
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
                      realised: _watchlistAll!.totalRealisedSaham,
                      dayGain: _watchlistAll!.totalDayGainSaham,
                      onTap: (() {
                        PortofolioListArgs args = PortofolioListArgs(
                          title: "Stock",
                          value: _watchlistAll!.totalValueSaham,
                          cost: _watchlistAll!.totalCostSaham,
                          realised: _watchlistAll!.totalRealisedSaham,
                          unrealised: (_watchlistAll!.totalValueSaham - _watchlistAll!.totalCostSaham),
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
                      realised: _watchlistAll!.totalRealisedCrypto,
                      dayGain: _watchlistAll!.totalDayGainCrypto,
                      onTap: (() {
                        // check whether we can navigate to detail page, or just do nothing
                        if (_watchlistCrypto!.isNotEmpty) {
                          // got product means we can display the details here 
                          PortofolioListArgs args = PortofolioListArgs(
                            title: 'Crypto',
                            value: _watchlistAll!.totalValueCrypto,
                            cost: _watchlistAll!.totalCostCrypto,
                            realised: _watchlistAll!.totalRealisedCrypto,
                            unrealised: (_watchlistAll!.totalValueCrypto - _watchlistAll!.totalCostCrypto),
                            type: 'crypto',
                            subType: '-1'
                          );
        
                          Navigator.pushNamed(context, '/portofolio/list/detail', arguments: args);
                        }
                      })
                    ),
                    ProductListItem(
                      bgColor: Colors.amber,
                      title: "Gold",
                      value: _watchlistAll!.totalValueGold,
                      cost: _watchlistAll!.totalCostGold,
                      total: _watchlistAll!.totalValue,
                      realised: _watchlistAll!.totalRealisedGold,
                      dayGain: _watchlistAll!.totalDayGainGold,
                      onTap: (() {
                        // do nothing, we just want to showed the chevron icon here
                      })
                    ),
                  ],
                ),
              ),
            ),
          ],
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
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
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

  Widget _summaryBox({required Color barColor, required double value, required double cost, required double dayGain, required double realised, Color? backgroundColor, double? fontSize}) {
    Color bgColor = backgroundColor ?? primaryColor;
    double summarySize = fontSize ?? 20;
    double gain = value - cost;
    Color trendColor = Colors.white;
    Color realisedColor = Colors.white;
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

    if (realised > 0) {
      realisedColor = Colors.green;
      trendIcon = Ionicons.trending_up;
    }
    else if(realised < 0) {
      realisedColor = secondaryColor;
      trendIcon = Ionicons.trending_down;
    }

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
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        flex: 3,
                        child: _smallText("Total Value"),
                      ),
                      Expanded(
                        flex: 2,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: _smallText("Total Unrealised")
                        ),
                      ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        flex: 3,
                        child: _largeText(formatCurrency(value, false, true, false), summarySize),
                      ),
                      Expanded(
                        flex: 2,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              Icon(
                                trendIcon,
                                color: trendColor,
                                size: 16,
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
                        ),
                      ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        flex: 3,
                        child: _smallText("Total Cost"),
                      ),
                      Expanded(
                        flex: 2,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: _smallText("Total Realised")
                        ),
                      ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        flex: 3,
                        child: Text(
                          formatCurrency(cost, false, true, false),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              Icon(
                                Ionicons.wallet_outline,
                                color: realisedColor,
                                size: 16,
                              ),
                              const SizedBox(width: 5,),
                              Text(
                                formatCurrency(realised, false, true, false),
                                style: TextStyle(
                                  color: realisedColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
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