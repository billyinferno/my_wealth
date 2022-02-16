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
  final UserLoginInfoModel userInfo;
  final WatchlistListModel watchlist;
  const ExpandedTileView({ Key? key, this.showedLot, required this.userInfo, required this.watchlist }) : super(key: key);

  @override
  _ExpandedTileViewState createState() => _ExpandedTileViewState();
}

class _ExpandedTileViewState extends State<ExpandedTileView> {
  final DateFormat dt = DateFormat("dd/MM/yyyy");
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
        lot: widget.watchlist.watchlistDetail.length,
        share: _totalShare,
        price: (widget.watchlist.watchlistCompanyNetAssetValue ?? 0),
        gain: _totalGain,
        riskColor: riskColor((_totalShare * widget.watchlist.watchlistCompanyNetAssetValue!), _totalCost, widget.userInfo.risk),
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

  void _computeDetail() {
    // loop thru the watchlist details and calculate the total share and total gain
    _totalShare = 0;
    _totalGain = 0;
    _totalCost = 0;

    double _gain = 0;
    double _price = (widget.watchlist.watchlistCompanyNetAssetValue ?? 0);
    for (WatchlistDetailListModel _detail in widget.watchlist.watchlistDetail) {
      _totalShare += _detail.watchlistDetailShare;
      
      if(_price > 0) {
        _totalCost += (_detail.watchlistDetailShare * _detail.watchlistDetailPrice);

        _gain = (_price - _detail.watchlistDetailPrice) * _detail.watchlistDetailShare;
        _totalGain += _gain;
      }
    }
  }

}