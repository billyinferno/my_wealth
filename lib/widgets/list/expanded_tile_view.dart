import 'package:flutter/material.dart';
import 'package:my_wealth/_index.g.dart';

class ExpandedTileView extends StatelessWidget {
  final bool? showedLot;
  final bool? inLot;
  final int risk;
  final bool isVisible;
  final WatchlistListModel watchlist;
  final ComputeWatchlistResult watchlistResult;
  final String shareTitle;
  final bool checkThousandOnPrice;
  final bool showEmptyWatchlist;
  final bool showPriceDecimal;
  const ExpandedTileView({
    super.key,
    this.showedLot,
    this.inLot,
    required this.risk,
    required this.isVisible,
    required this.watchlist,
    required this.watchlistResult,
    this.shareTitle = "Shares",
    this.checkThousandOnPrice = false,
    required this.showEmptyWatchlist,
    required this.showPriceDecimal,
  });

  @override
  Widget build(BuildContext context) {
    // initialize the value
    bool isShowedLots = (showedLot ?? false);
    bool isInLot = (inLot ?? false);
    final DateTime checkDate = (watchlist.watchlistCompanyLastUpdate ?? DateTime.now());

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

    // get the header and sub header  color
    Color headerRiskColor = watchlistResult.headerRiskColor;
    Color subHeaderRiskColor = watchlistResult.subHeaderRiskColor;

    // check if the total share is 0
    if (watchlistResult.totalShare <= 0) {
      // override header risk color and sub header into primaryDark
      headerRiskColor = primaryLight;
      subHeaderRiskColor = primaryLight;
    }

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
          shareTitle: (isInLot ? "Lot" : shareTitle),
          price: (watchlist.watchlistCompanyNetAssetValue ?? 0),
          prevPrice: watchlist.watchlistCompanyPrevPrice,
          gain: (isVisible ? watchlistResult.totalGain : null),
          lastUpdate: Globals.dfddMM.formatDateWithNull(watchlist.watchlistCompanyLastUpdate),
          riskColor: headerRiskColor,
          checkThousandOnPrice: checkThousandOnPrice,
          subHeaderRiskColor: subHeaderRiskColor,
          totalDayGain: (isVisible ? watchlistResult.totalDayGain : null),
          totalValue: (isVisible ? watchlistResult.totalValue : null),
          totalCost: (isVisible ? watchlistResult.totalCost : null),
          averagePrice: (isVisible ? watchlistResult.averagePrice : null),
          fca: (watchlist.watchlistCompanyFCA ?? false),
          showDecimal: showPriceDecimal,
          visibility: isVisible,
          isLot: isInLot,
        ),
        initiallyExpanded: isShowedLots,
        collapsedTextColor: textPrimary,
        textColor: textPrimary,
        children: List<Widget>.generate(watchlist.watchlistDetail.length, (index) {
          return ExpandedTileChildren(
            date: Globals.dfddMMyy.formatLocal(watchlist.watchlistDetail[index].watchlistDetailDate),
            shares: watchlist.watchlistDetail[index].watchlistDetailShare,
            isInLot: isInLot,
            price: watchlist.watchlistDetail[index].watchlistDetailPrice,
            currentPrice: watchlist.watchlistCompanyNetAssetValue!,
            averagePrice: watchlistResult.averagePrice,
            risk: risk,
            calculateLoss: watchlist.watchlistDetail[index].watchlistDetailDate.isSameOrBefore(
              date: checkDate,
            ),
            visibility: isVisible,
          );
        }),
      ),
    );
  }
}
