import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_wealth/model/user_login.dart';
import 'package:my_wealth/model/watchlist_detail_list_model.dart';
import 'package:my_wealth/model/watchlist_list_model.dart';
import 'package:my_wealth/themes/colors.dart';
import 'package:my_wealth/utils/function/risk_color.dart';
import 'package:my_wealth/widgets/expanded_tile_children.dart';
import 'package:my_wealth/widgets/expanded_tile_title.dart';

class ExpandedTileView extends StatefulWidget {
  final bool? showedLot;
  final bool? isInLot;
  final bool isVisible;
  final UserLoginInfoModel userInfo;
  final WatchlistListModel watchlist;
  final String? shareTitle;
  const ExpandedTileView({ Key? key, this.showedLot, this.isInLot, required this.isVisible, required this.userInfo, required this.watchlist, this.shareTitle }) : super(key: key);

  @override
  ExpandedTileViewState createState() => ExpandedTileViewState();
}

class ExpandedTileViewState extends State<ExpandedTileView> {
  final DateFormat dt = DateFormat("dd/MM/yyyy");
  final DateFormat dtSmall = DateFormat('dd/MM');
  bool _isShowedLots = false;
  bool _isInLot = false;
  double _totalShare = 0;
  double _totalGain = 0;
  double _totalCost = 0;
  double _averagePrice = 0;
  int _totalBuy = 0;
  int _totalSell = 0;

  @override
  Widget build(BuildContext context) {
    _isShowedLots = (widget.showedLot ?? false);
    _isInLot = (widget.isInLot ?? false);
    _computeDetail();

    return ExpansionTile(
      key: Key(widget.key.toString() + _isShowedLots.toString()),
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
      backgroundColor: primaryColor,
      collapsedBackgroundColor: primaryColor,
      iconColor: primaryLight,
      collapsedIconColor: primaryLight,
      title: ExpandedTileTitle(
        name: (widget.watchlist.watchlistCompanySymbol!.isNotEmpty ? "(${widget.watchlist.watchlistCompanySymbol}) ${widget.watchlist.watchlistCompanyName}" : widget.watchlist.watchlistCompanyName),
        buy: _totalBuy,
        sell: _totalSell,
        share: (_isInLot ? _totalShare / 100 : _totalShare),
        shareTitle: (_isInLot ? "Lot" : (widget.shareTitle ?? "Shares")),
        price: (widget.watchlist.watchlistCompanyNetAssetValue ?? 0),
        gain: (widget.isVisible ? _totalGain : null),
        lastUpdate: (widget.watchlist.watchlistCompanyLastUpdate == null ? "-" : dtSmall.format(widget.watchlist.watchlistCompanyLastUpdate!.toLocal())),
        riskColor: (widget.isVisible ? riskColor((_totalShare * widget.watchlist.watchlistCompanyNetAssetValue!), _totalCost, widget.userInfo.risk) : Colors.white),
      ),
      initiallyExpanded: _isShowedLots,
      collapsedTextColor: textPrimary,
      textColor: textPrimary,
      children: List<Widget>.generate(widget.watchlist.watchlistDetail.length, (index) {
        return ExpandedTileChildren(
          date: dt.format(widget.watchlist.watchlistDetail[index].watchlistDetailDate),
          shares: (_isInLot ? (widget.watchlist.watchlistDetail[index].watchlistDetailShare / 100) : widget.watchlist.watchlistDetail[index].watchlistDetailShare),
          price: widget.watchlist.watchlistDetail[index].watchlistDetailPrice,
          currentPrice: widget.watchlist.watchlistCompanyNetAssetValue!,
          averagePrice: _averagePrice,
          risk: widget.userInfo.risk,
        );
      }),
    );
  }

  void _computeDetail() {
    // loop thru the watchlist details and calculate the total share and total gain
    _totalShare = 0;
    _totalGain = 0;
    _totalCost = 0;
    _totalBuy = 0;
    _totalSell = 0;

    // for the calculation of the sell share's to avoid any average cost problem
    // we need to see how much is the average cost for each share that we buy
    double totalShareBuy = 0;
    double totalShareSell = 0;
    double totalCostBuy = 0;
    double totalCostSell = 0;
    double averageBuyPrice = 0;
    for (WatchlistDetailListModel detail in widget.watchlist.watchlistDetail) {
      if (detail.watchlistDetailShare > 0) {
        totalShareBuy += detail.watchlistDetailShare;
        totalCostBuy += (detail.watchlistDetailShare * detail.watchlistDetailPrice);
        _totalBuy++;
      }
      else {
        totalShareSell += detail.watchlistDetailShare;
        _totalSell++;
      }
    }

    // check we still have share left or not?
    if ((totalShareBuy + totalShareSell) > 0) {
      // get what is the average buy price that we have
      if (totalShareBuy > 0 && totalCostBuy > 0) {
        averageBuyPrice = totalCostBuy / totalShareBuy;
      }

      // calculate the total cost sell, this is should be the total shares we sell times the averageBuyPrice
      totalCostSell = totalShareSell * averageBuyPrice;

      // set the result
      // total share should be buy subtract by sell (remember here sell already negative)
      _totalShare = totalShareBuy + totalShareSell;
      _totalGain = (widget.watchlist.watchlistCompanyNetAssetValue! * (totalShareBuy + totalShareSell)) - (averageBuyPrice * (totalShareBuy + totalShareSell));
      _totalCost = totalCostBuy + totalCostSell;
      _averagePrice = averageBuyPrice;
    }
    
    // debugPrint("Name: ${widget.watchlist.watchlistCompanyName}, Total: ${_totalShare * widget.watchlist.watchlistCompanyNetAssetValue!}, Gain:$_totalGain, Total Share Buy:$totalShareBuy, Total Share Sell:$totalShareSell,  Cost Buy:$totalCostBuy, Cost Sell:$totalCostSell,  Cost:$_totalCost, Average Price:$_averagePrice");
  }
}