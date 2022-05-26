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
  final bool isVisible;
  final UserLoginInfoModel userInfo;
  final WatchlistListModel watchlist;
  const ExpandedTileView({ Key? key, this.showedLot, required this.isVisible, required this.userInfo, required this.watchlist }) : super(key: key);

  @override
  ExpandedTileViewState createState() => ExpandedTileViewState();
}

class ExpandedTileViewState extends State<ExpandedTileView> {
  final DateFormat dt = DateFormat("dd/MM/yyyy");
  final DateFormat dtSmall = DateFormat('dd/MM');
  bool _isShowedLots = false;
  double _totalShare = 0;
  double _totalGain = 0;
  double _totalCost = 0;

  @override
  Widget build(BuildContext context) {
    _isShowedLots = (widget.showedLot ?? false);
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
        name: widget.watchlist.watchlistCompanyName,
        lot: _totalLot(),
        share: _totalShare,
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
          shares: widget.watchlist.watchlistDetail[index].watchlistDetailShare,
          price: widget.watchlist.watchlistDetail[index].watchlistDetailPrice,
          currentPrice: widget.watchlist.watchlistCompanyNetAssetValue!,
          risk: widget.userInfo.risk,
        );
      }),
    );
  }

  int _totalLot() {
    // loop thru widget.watchlist.watchlistDetail and ensure that we will only count
    // all the shares that > 0
    int total = 0;
    for (WatchlistDetailListModel data in widget.watchlist.watchlistDetail) {
      if(data.watchlistDetailShare > 0) {
        total++;
      }
    }
    // return the correct total lot
    return total;
  }

  void _computeDetail() {
    // loop thru the watchlist details and calculate the total share and total gain
    _totalShare = 0;
    _totalGain = 0;
    _totalCost = 0;

    double price = (widget.watchlist.watchlistCompanyNetAssetValue ?? 0);
    for (WatchlistDetailListModel detail in widget.watchlist.watchlistDetail) {
      _totalShare += detail.watchlistDetailShare;

      // check whether this is buy or sell
      if (detail.watchlistDetailShare > 0) {
        // this is a buy, so we can just calculate the cost using the price we buy        
        _totalCost += (detail.watchlistDetailShare * detail.watchlistDetailPrice);
      }
      else {
        // this is a sell, so we need to use the current price as the cost calculation
        // because something that we sell 2y ago, shouldn't affect the current day
        // cost for the remaining shares.
        _totalCost += (detail.watchlistDetailShare * price);
      }
    }

    _totalGain = (_totalShare * price) - _totalCost;
    // debugPrint("${widget.watchlist.watchlistCompanyName} cost :$_totalCost - gain:$_totalGain");
  }

}