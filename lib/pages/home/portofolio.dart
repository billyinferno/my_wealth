import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';
import 'package:my_wealth/_index.g.dart';

class PortofolioPage extends StatefulWidget {
  const PortofolioPage({super.key});

  @override
  State<PortofolioPage> createState() => _PortofolioPageState();
}

class _PortofolioPageState extends State<PortofolioPage> {
  final ScrollController _scrollController = ScrollController();

  late UserLoginInfoModel? _userInfo;
  late List<WatchlistListModel> _watchlistReksadana;
  late List<WatchlistListModel> _watchlistSaham;
  late List<WatchlistListModel> _watchlistCrypto;
  late List<WatchlistListModel> _watchlistGold;
  late ComputeWatchlistAllResult _watchlistAll;
  late List<BarChartData> _barChartData;

  bool _isSummaryVisible = true;
  bool _currentIsSummaryVisible = true;

  @override
  void initState() {
    super.initState();

    _barChartData = [];
    _userInfo = UserSharedPreferences.getUserInfo();

    // check user visibility configuration
    _isSummaryVisible = _userInfo!.visibility;
    _currentIsSummaryVisible = _userInfo!.visibility;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // if not invisible then we will just return the normal page
    return Consumer2<UserProvider, WatchlistProvider>(
      builder: ((context, userProvider, watchlistProvider, child) {
        _userInfo = userProvider.userInfo;

        // check if the visibility information is being change on the user page?
        if (_currentIsSummaryVisible != _userInfo!.visibility) {
          _currentIsSummaryVisible = _userInfo!.visibility;
          _isSummaryVisible = _userInfo!.visibility;
        }

        // check summary visibility
        if (!_isSummaryVisible) {
          return _invisiblePage();
        }

        _watchlistReksadana = (watchlistProvider.watchlistReksadana ?? []);
        _watchlistSaham = (watchlistProvider.watchlistSaham ?? []);
        _watchlistCrypto = (watchlistProvider.watchlistCrypto ?? []);
        _watchlistGold = (watchlistProvider.watchlistGold ?? []);

        // compute all the watchlist first
        _watchlistAll = computeWatchlistAll(
          _watchlistReksadana,
          _watchlistSaham,
          _watchlistCrypto,
          _watchlistGold
        );

        _generateBarChartData();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _summaryBox(
              barColor: riskColor(
                value: _watchlistAll.totalValue,
                cost: _watchlistAll.totalCost,
                riskFactor: _userInfo!.risk
              ),
              backgroundColor: primaryDark,
              value: _watchlistAll.totalValue,
              cost: _watchlistAll.totalCost,
              realised: _watchlistAll.totalRealised,
              dayGain: _watchlistAll.totalDayGain,
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
                      value: _watchlistAll.totalValueReksadana,
                      cost: _watchlistAll.totalCostReksadana,
                      total: _watchlistAll.totalValue,
                      realised: _watchlistAll.totalRealisedReksadana,
                      dayGain: _watchlistAll.totalDayGainReksadana,
                      onTap: (() {
                        PortofolioListArgs args = PortofolioListArgs(
                          title: "Reksadana",
                          value: _watchlistAll.totalValueReksadana,
                          cost: _watchlistAll.totalCostReksadana,
                          realised: _watchlistAll.totalRealisedReksadana,
                          unrealised: (_watchlistAll.totalValueReksadana - _watchlistAll.totalCostReksadana),
                          type: "reksadana",
                          showSort: true,
                        );
                        Navigator.pushNamed(context, '/portofolio/list', arguments: args);
                      })
                    ),
                    ProductListItem(
                      bgColor: Colors.pink,
                      title: "Stock",
                      value: _watchlistAll.totalValueSaham,
                      cost: _watchlistAll.totalCostSaham,
                      total: _watchlistAll.totalValue,
                      realised: _watchlistAll.totalRealisedSaham,
                      dayGain: _watchlistAll.totalDayGainSaham,
                      onTap: (() {
                        PortofolioListArgs args = PortofolioListArgs(
                          title: "Stock",
                          value: _watchlistAll.totalValueSaham,
                          cost: _watchlistAll.totalCostSaham,
                          realised: _watchlistAll.totalRealisedSaham,
                          unrealised: (_watchlistAll.totalValueSaham - _watchlistAll.totalCostSaham),
                          type: "saham"
                        );
                        Navigator.pushNamed(context, '/portofolio/list', arguments: args);
                      })
                    ),
                    ProductListItem(
                      bgColor: Colors.purple,
                      title: "Crypto",
                      value: _watchlistAll.totalValueCrypto,
                      cost: _watchlistAll.totalCostCrypto,
                      total: _watchlistAll.totalValue,
                      realised: _watchlistAll.totalRealisedCrypto,
                      dayGain: _watchlistAll.totalDayGainCrypto,
                      onTap: (() {
                        // check whether we can navigate to detail page, or just do nothing
                        if (_watchlistCrypto.isNotEmpty) {
                          // got product means we can display the details here 
                          PortofolioListArgs args = PortofolioListArgs(
                            title: 'Crypto',
                            value: _watchlistAll.totalValueCrypto,
                            cost: _watchlistAll.totalCostCrypto,
                            realised: _watchlistAll.totalRealisedCrypto,
                            unrealised: (_watchlistAll.totalValueCrypto - _watchlistAll.totalCostCrypto),
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
                      value: _watchlistAll.totalValueGold,
                      cost: _watchlistAll.totalCostGold,
                      total: _watchlistAll.totalValue,
                      realised: _watchlistAll.totalRealisedGold,
                      dayGain: _watchlistAll.totalDayGainGold,
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
                Ionicons.eye_outline,
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
    _barChartData.add(BarChartData(
      title: "Reksadana",
      value: _watchlistAll.totalValueReksadana,
      total: _watchlistAll.totalValue,
      color: Colors.green
    ));

    _barChartData.add(BarChartData(
      title: "Stock",
      value: _watchlistAll.totalValueSaham,
      total: _watchlistAll.totalValue,
      color: Colors.pink
    ));

    _barChartData.add(BarChartData(
      title: "Crypto",
      value: _watchlistAll.totalValueCrypto,
      total: _watchlistAll.totalValue,
      color: Colors.purple
    ));
    
    _barChartData.add(BarChartData(
      title: "Gold",
      value: _watchlistAll.totalValueGold,
      total: _watchlistAll.totalValue,
      color: Colors.amber
    ));
  }

  Widget _summaryBox({
    required Color barColor,
    required double value,
    required double cost,
    required double dayGain,
    required double realised,
    Color backgroundColor = primaryColor,
    double fontSize = 20
  }) {
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
      color: backgroundColor,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 10,
              color: barColor,
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.fromLTRB(10, 10, 0, 10),
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              _smallText("Total Value"),
                              _largeText(
                                text: formatCurrency(
                                  value,
                                  showDecimal:  true,
                                  shorten: false,
                                ),
                                size: fontSize,
                                overflow: TextOverflow.ellipsis
                              ),
                            ],
                          )
                        ),
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              _smallText("Total Unrealised"),
                              Row(
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
                                    formatCurrency(
                                      gain,
                                      shorten: true,
                                    ),
                                    style: TextStyle(
                                      color: trendColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ],
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              _smallText("Total Cost"),
                              Text(
                                formatCurrency(
                                  cost,
                                  shorten: false,
                                ),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          )
                        ),
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              _smallText("Total Realised"),
                              Row(
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
                                    formatCurrency(
                                      realised,
                                      shorten: true,
                                    ),
                                    style: TextStyle(
                                      color: realisedColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            ),
            const SizedBox(width: 10,),
            InkWell(
              onTap: (() {
                setState(() {
                  _isSummaryVisible = !_isSummaryVisible;
                });
              }),
              child: Container(
                width: 16,
                height: 16,
                color: Colors.transparent,
                child: Icon(
                  (_isSummaryVisible ? Ionicons.eye_off_outline : Ionicons.eye_outline),
                  color: primaryLight,
                  size: 16,
                ),
              ),
            ),
            const SizedBox(width: 10,),
          ],
        ),
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

  Widget _largeText({
    required String text,
    double size = 20,
    TextOverflow? overflow,
  }) {
    return Text(
      text,
      style: TextStyle(
        fontSize: size,
        fontWeight: FontWeight.bold,
      ),
      overflow: overflow,
    );
  }
}