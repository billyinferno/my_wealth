import 'package:flutter/material.dart';
import 'package:my_wealth/model/watchlist_detail_list_model.dart';
import 'package:my_wealth/model/watchlist_list_model.dart';
import 'package:my_wealth/utils/function/risk_color.dart';

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

    // for the calculation of the sell share's to avoid any average cost problem
    // we need to see how much is the average cost for each share that we buy
    double totalCostSell = 0;
    double averageBuyPrice = 0;

    // this variable is being used to calculate the realised gain
    double totalShareBuyRealised = 0;
    double totalBuyAmountRealised = 0;
    double averageRealisedPrice = 0;
    for (WatchlistDetailListModel detail in watchlist.watchlistDetail.reversed) {
      if (detail.watchlistDetailShare > 0) {
        totalSharesBuy += detail.watchlistDetailShare;
        totalBuyAmount += (detail.watchlistDetailShare * detail.watchlistDetailPrice);
        totalBuy++;

        totalShareBuyRealised += totalSharesBuy;
        totalBuyAmountRealised += totalBuyAmount;
      }
      else {
        // get the current gain price that we can use to calculate the actual realised gain we got at that time
        if (totalShareBuyRealised > 0 && totalBuyAmountRealised > 0) {
          averageRealisedPrice = totalBuyAmountRealised / totalShareBuyRealised;
        }

        totalSharesSell += detail.watchlistDetailShare;
        totalSellAmount += (detail.watchlistDetailShare * detail.watchlistDetailPrice);
        totalRealisedGain += ((detail.watchlistDetailShare * detail.watchlistDetailPrice) * -1) - (detail.watchlistDetailShare * averageRealisedPrice * -1);
        totalSell++;

        // recalculate the totalShareBuyRealised and totalBuyAmountRealised
        totalShareBuyRealised += detail.watchlistDetailShare;
        totalBuyAmountRealised += (detail.watchlistDetailShare * averageRealisedPrice);
      }
    }
    
    // get what is the average buy price that we have
    if (totalSharesBuy > 0 && totalBuyAmount > 0) {
      averageBuyPrice = totalBuyAmount / totalSharesBuy;
    }

    // total sell is negative, make it a positive
    if (totalSharesSell < 0) {
      totalSharesSell *= -1;
    }
    if (totalSellAmount < 0) {
      totalSellAmount *= -1;
    }

    // calculate the total cost sell, this is should be the total shares we sell times the averageBuyPrice
    totalCostSell = totalSharesSell * averageBuyPrice;

    // set the result
    // total share should be buy subtract by sell
    totalCurrentShares = totalSharesBuy - totalSharesSell;
    totalCost = totalBuyAmount - totalCostSell;
    totalValue = totalCurrentShares * watchlist.watchlistCompanyNetAssetValue!;
    totalUnrealisedGain = totalValue - (averageBuyPrice * (totalSharesBuy - totalSharesSell));

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
      riskColor: riskColor(totalValue, totalCost, riskFactor)
    );
  }