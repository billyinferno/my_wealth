import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_wealth/model/watchlist/watchlist_list_model.dart';
import 'package:my_wealth/themes/colors.dart';
import 'package:my_wealth/utils/function/compute_watchlist.dart';
import 'package:my_wealth/widgets/list/expanded_tile_children.dart';
import 'package:my_wealth/widgets/list/expanded_tile_title.dart';

class ExpandedTileView extends StatelessWidget {
  final bool? showedLot;
  final bool? inLot;
  final int risk;
  final bool isVisible;
  final WatchlistListModel watchlist;
  final ComputeWatchlistResult watchlistResult;
  final String? shareTitle;
  final bool? checkThousandOnPrice;
  final bool showEmptyWatchlist;
  const ExpandedTileView({Key? key, this.showedLot, this.inLot, required this.risk, required this.isVisible, required this.watchlist, required this.watchlistResult, this.shareTitle, this.checkThousandOnPrice, required this.showEmptyWatchlist}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // initialize the value
    bool isShowedLots = (showedLot ?? false);
    bool isInLot = (inLot ?? false);
    final DateFormat dt = DateFormat("dd/MM/yy");
    final DateFormat dtSmall = DateFormat('dd/MM');

    // after that check if the showEmptyWatchlist is set as false?
    // if so ensure that if txn > 0 but totalShare is 0, just return SizedBox instead of expansion tile
    if (!showEmptyWatchlist) {
      // check if we already have transaction here or not?
      if ((watchlistResult.totalBuy + watchlistResult.totalSell) > 0) {
        // already have transaction, ensure we still have share, if not then just hide this
        if (watchlistResult.totalShare <= 0) {
          return const SizedBox.shrink();
        }
      }
    }

    Color headerRiskColor = (isVisible ? watchlistResult.headerRiskColor : Colors.white);
    Color subHeaderRiskColor = (isVisible ? watchlistResult.subHeaderRiskColor : Colors.white);

    return ListTileTheme(
      contentPadding: const EdgeInsets.all(0),
      child: ExpansionTile(
        key: Key(key.toString() + isShowedLots.toString()),
        tilePadding: const EdgeInsets.all(0),
        childrenPadding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
        backgroundColor: primaryColor,
        collapsedBackgroundColor: primaryColor,
        iconColor: primaryLight,
        collapsedIconColor: primaryLight,
        title: ExpandedTileTitle(
          name: (watchlist.watchlistCompanySymbol!.isNotEmpty ? "(${watchlist.watchlistCompanySymbol}) ${watchlist.watchlistCompanyName}" : watchlist.watchlistCompanyName),
          buy: watchlistResult.totalBuy,
          sell: watchlistResult.totalSell,
          share: (isInLot ? watchlistResult.totalShare / 100 : watchlistResult.totalShare),
          shareTitle: (isInLot ? "Lot" : (shareTitle ?? "Shares")),
          price: (watchlist.watchlistCompanyNetAssetValue ?? 0),
          prevPrice: watchlist.watchlistCompanyPrevPrice,
          gain: (isVisible ? watchlistResult.totalGain : null),
          lastUpdate: (watchlist.watchlistCompanyLastUpdate == null ? "-" : dtSmall.format(watchlist.watchlistCompanyLastUpdate!.toLocal())),
          riskColor: headerRiskColor,
          checkThousandOnPrice: (checkThousandOnPrice ?? false),
          subHeaderRiskColor: subHeaderRiskColor,
          totalDayGain: (isVisible ? watchlistResult.totalDayGain : null),
          totalValue: (isVisible ? watchlistResult.totalValue : null),
          totalCost: (isVisible ? watchlistResult.totalCost : null),
          averagePrice: (isVisible ? watchlistResult.averagePrice : null),
        ),
        initiallyExpanded: isShowedLots,
        collapsedTextColor: textPrimary,
        textColor: textPrimary,
        children: List<Widget>.generate(watchlist.watchlistDetail.length, (index) {
          return ExpandedTileChildren(
            date: dt.format(watchlist.watchlistDetail[index].watchlistDetailDate),
            shares: watchlist.watchlistDetail[index].watchlistDetailShare,
            isInLot: isInLot,
            price: watchlist.watchlistDetail[index].watchlistDetailPrice,
            currentPrice: watchlist.watchlistCompanyNetAssetValue!,
            averagePrice: watchlistResult.averagePrice,
            risk: risk,
          );
        }),
      ),
    );
  }
}
