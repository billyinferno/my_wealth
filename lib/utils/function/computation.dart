import 'package:flutter/material.dart';
import 'package:my_wealth/_index.g.dart';

class WatchlistComputationResult {
  final int totalBuy;
  final int totalSell;
  final double totalCost;
  final double priceDiff;
  final double totalUnrealisedGain;
  final double totalRealisedGain;
  final double totalValue;
  final double totalCurrentShares;
  final double totalSharesBuy;
  final double totalSharesSell;
  final double totalBuyAmount;
  final double totalSellAmount;
  final Color riskColor;

  WatchlistComputationResult({
    required this.totalBuy,
    required this.totalSell,
    required this.priceDiff,
    required this.totalCost,
    required this.totalUnrealisedGain,
    required this.totalRealisedGain,
    required this.totalValue,
    required this.totalCurrentShares,
    required this.totalSharesBuy,
    required this.totalSharesSell,
    required this.totalBuyAmount,
    required this.totalSellAmount,
    required this.riskColor,
  });
}

WatchlistComputationResult detailWatchlistComputation({required WatchlistListModel watchlist, required int riskFactor}) {
    // compute all necessary data for the summary, such as cost, gain
    int totalBuy = 0;
    int totalSell = 0;
    double priceDiff = 0;
    double totalCost = 0;
    double totalUnrealisedGain = 0;
    double totalRealisedGain = 0;
    double totalValue = 0;
    double totalCurrentShares = 0;
    double totalSharesBuy = 0;
    double totalSharesSell = 0;
    double totalBuyAmount = 0;
    double totalSellAmount = 0;

    // compute the price diff
    priceDiff = (watchlist.watchlistCompanyNetAssetValue! - watchlist.watchlistCompanyPrevPrice!) ;

    double avgPrice = 0;
    for (WatchlistDetailListModel detail in watchlist.watchlistDetail.reversed) {
      // check if this is buy or sell?
      if (detail.watchlistDetailShare > 0) {
        // this is buy, so add totalShare and totalCost
        totalCurrentShares += detail.watchlistDetailShare;
        totalCost += (detail.watchlistDetailShare * detail.watchlistDetailPrice);
        // calculate the average price
        avgPrice = totalCost / totalCurrentShares;
        // add total buy
        totalSharesBuy += detail.watchlistDetailShare;
        totalBuyAmount += (detail.watchlistDetailShare * detail.watchlistDetailPrice);
        totalBuy++;
      }
      else {
        // this is sell
        // compute the realised gain
        totalRealisedGain += (detail.watchlistDetailShare * detail.watchlistDetailPrice * (-1)) - (detail.watchlistDetailShare * avgPrice * (-1));
        // then subtract the totalShare and recompute the totalCost
        totalCurrentShares += detail.watchlistDetailShare;
        totalCost += (detail.watchlistDetailShare * avgPrice);
        // add total sell
        totalSharesSell += (detail.watchlistDetailShare * (-1));
        totalSellAmount += (detail.watchlistDetailShare * detail.watchlistDetailPrice * (-1));
        totalSell++;
      }
    }

    // once finished check whether we have share left or not?
    if (totalCurrentShares > 0) {
      totalValue = totalCurrentShares * watchlist.watchlistCompanyNetAssetValue!;
      totalUnrealisedGain = totalValue - totalCost;
    }
    else {
      // zerorise
      totalCost = 0;
      totalValue = 0;
      totalUnrealisedGain = 0;
    }

    return WatchlistComputationResult(
      totalBuy: totalBuy,
      totalSell: totalSell,
      priceDiff: priceDiff,
      totalCost: totalCost,
      totalUnrealisedGain: totalUnrealisedGain,
      totalRealisedGain: totalRealisedGain,
      totalValue: totalValue,
      totalCurrentShares: totalCurrentShares,
      totalSharesBuy: totalSharesBuy,
      totalSharesSell: totalSharesSell,
      totalBuyAmount: totalBuyAmount,
      totalSellAmount: totalSellAmount,
      riskColor: riskColor(
        value: totalValue,
        cost: totalCost,
        riskFactor: riskFactor
      )
    );
  }