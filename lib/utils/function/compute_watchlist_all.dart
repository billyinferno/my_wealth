import 'package:my_wealth/model/watchlist_detail_list_model.dart';
import 'package:my_wealth/model/watchlist_list_model.dart';

class ComputeWatchlistAllResult {
  final double totalDayGain;
  final double totalValue;
  final double totalCost;
  final double totalRealised;

  final double totalDayGainReksadana;
  final double totalValueReksadana;
  final double totalCostReksadana;
  final double totalRealisedReksadana;

  final double totalDayGainSaham;
  final double totalValueSaham;
  final double totalCostSaham;
  final double totalRealisedSaham;

  final double totalDayGainCrypto;
  final double totalValueCrypto;
  final double totalCostCrypto;
  final double totalRealisedCrypto;

  final double totalDayGainGold;
  final double totalValueGold;
  final double totalCostGold;
  final double totalRealisedGold;

  ComputeWatchlistAllResult({
    required this.totalDayGain, required this.totalValue, required this.totalCost, required this.totalRealised,
    required this.totalDayGainReksadana, required this.totalValueReksadana, required this.totalCostReksadana, required this.totalRealisedReksadana,
    required this.totalDayGainSaham, required this.totalValueSaham, required this.totalCostSaham, required this.totalRealisedSaham,
    required this.totalDayGainCrypto, required this.totalValueCrypto, required this.totalCostCrypto, required this.totalRealisedCrypto,
    required this.totalDayGainGold, required this.totalValueGold, required this.totalCostGold, required this.totalRealisedGold,
  });
}

ComputeWatchlistAllResult computeWatchlistAll(List<WatchlistListModel> watchlistsMutualfund, List<WatchlistListModel> watchlistsStock, List<WatchlistListModel> watchlistsCrypto, List<WatchlistListModel> watchlistsGold) {
    // reset the value before we actually compute the data
    double totalDayGain = 0;
    double totalValue = 0;
    double totalCost = 0;
    double totalRealised = 0;
    
    double totalDayGainReksadana = 0;
    double totalValueReksadana = 0;
    double totalCostReksadana = 0;
    double totalRealisedReksadana = 0;

    double totalDayGainSaham = 0;
    double totalValueSaham = 0;
    double totalCostSaham = 0;
    double totalRealisedSaham = 0;

    double totalDayGainCrypto = 0;
    double totalValueCrypto = 0;
    double totalCostCrypto = 0;
    double totalRealisedCrypto = 0;

    double totalDayGainGold = 0;
    double totalValueGold = 0;
    double totalCostGold = 0;
    double totalRealisedGold = 0;

    double tShare = 0;
    double tCost = 0;
    double tValue = 0;
    double tAvgPrice = 0;
    double tRealised = 0;
    double tDayGain = 0;

    // loop for reksadana
    for (WatchlistListModel watchlist in watchlistsMutualfund) {
      // initialize the computation variable
      tShare = 0;
      tCost = 0;
      tValue = 0;
      tAvgPrice = 0;
      tRealised = 0;
      tDayGain = 0;
      for (WatchlistDetailListModel detail in watchlist.watchlistDetail.reversed) {
        // check whether this is buy or sell?
        if (detail.watchlistDetailShare > 0) {
          // this is buy
          tShare += detail.watchlistDetailShare;
          tCost += detail.watchlistDetailShare * detail.watchlistDetailPrice;
          tAvgPrice = tCost / tShare;
        }
        else {
          // this is sell, calculate the realised pl
          tRealised += (detail.watchlistDetailShare * detail.watchlistDetailPrice * (-1)) + (detail.watchlistDetailShare * tAvgPrice);
          // recalculate the share and cost
          tShare += detail.watchlistDetailShare;
          tCost += detail.watchlistDetailShare * tAvgPrice;
        }
    
      }
      // check if we still have share at the end?
      if (tShare > 0) {
        tValue = tShare * watchlist.watchlistCompanyNetAssetValue!;
        tDayGain = (watchlist.watchlistCompanyNetAssetValue! - watchlist.watchlistCompanyPrevPrice!) * tShare;
      }
      else {
        tCost = 0;
        tValue = 0;
        tDayGain = 0;
      }

      // once all finished then we can add this to the main variable container
      totalDayGainReksadana += tDayGain;
      totalValueReksadana += tValue;
      totalCostReksadana += tCost;
      totalRealisedReksadana += tRealised;
    }

    // loop for stock
    for (WatchlistListModel watchlist in watchlistsStock) {
      // initialize the computation variable
      tShare = 0;
      tCost = 0;
      tValue = 0;
      tAvgPrice = 0;
      tRealised = 0;
      tDayGain = 0;
      for (WatchlistDetailListModel detail in watchlist.watchlistDetail.reversed) {
        // check whether this is buy or sell?
        if (detail.watchlistDetailShare > 0) {
          // this is buy
          tShare += detail.watchlistDetailShare;
          tCost += detail.watchlistDetailShare * detail.watchlistDetailPrice;
          tAvgPrice = tCost / tShare;
        }
        else {
          // this is sell, calculate the realised pl
          tRealised += (detail.watchlistDetailShare * detail.watchlistDetailPrice * (-1)) + (detail.watchlistDetailShare * tAvgPrice);
          // recalculate the share and cost
          tShare += detail.watchlistDetailShare;
          tCost += detail.watchlistDetailShare * tAvgPrice;
        }
    
      }
      // check if we still have share at the end?
      if (tShare > 0) {
        tValue = tShare * watchlist.watchlistCompanyNetAssetValue!;
        tDayGain = (watchlist.watchlistCompanyNetAssetValue! - watchlist.watchlistCompanyPrevPrice!) * tShare;
      }
      else {
        tCost = 0;
        tValue = 0;
        tDayGain = 0;
      }

      // once all finished then we can add this to the main variable container
      totalDayGainSaham += tDayGain;
      totalValueSaham += tValue;
      totalCostSaham += tCost;
      totalRealisedSaham += tRealised;
    }

    // loop for crypto
    for (WatchlistListModel watchlist in watchlistsCrypto) {
      // initialize the computation variable
      tShare = 0;
      tCost = 0;
      tValue = 0;
      tAvgPrice = 0;
      tRealised = 0;
      tDayGain = 0;
      for (WatchlistDetailListModel detail in watchlist.watchlistDetail.reversed) {
        // check whether this is buy or sell?
        if (detail.watchlistDetailShare > 0) {
          // this is buy
          tShare += detail.watchlistDetailShare;
          tCost += detail.watchlistDetailShare * detail.watchlistDetailPrice;
          tAvgPrice = tCost / tShare;
        }
        else {
          // this is sell, calculate the realised pl
          tRealised += (detail.watchlistDetailShare * detail.watchlistDetailPrice * (-1)) + (detail.watchlistDetailShare * tAvgPrice);
          // recalculate the share and cost
          tShare += detail.watchlistDetailShare;
          tCost += detail.watchlistDetailShare * tAvgPrice;
        }
    
      }
      // check if we still have share at the end?
      if (tShare > 0) {
        tValue = tShare * watchlist.watchlistCompanyNetAssetValue!;
        tDayGain = (watchlist.watchlistCompanyNetAssetValue! - watchlist.watchlistCompanyPrevPrice!) * tShare;
      }
      else {
        tCost = 0;
        tValue = 0;
        tDayGain = 0;
      }

      // once all finished then we can add this to the main variable container
      totalDayGainCrypto += tDayGain;
      totalValueCrypto += tValue;
      totalCostCrypto += tCost;
      totalRealisedCrypto += tRealised;
    }

    // loop for gold
    for (WatchlistListModel watchlist in watchlistsGold) {
      // initialize the computation variable
      tShare = 0;
      tCost = 0;
      tValue = 0;
      tAvgPrice = 0;
      tRealised = 0;
      tDayGain = 0;
      for (WatchlistDetailListModel detail in watchlist.watchlistDetail.reversed) {
        // check whether this is buy or sell?
        if (detail.watchlistDetailShare > 0) {
          // this is buy
          tShare += detail.watchlistDetailShare;
          tCost += detail.watchlistDetailShare * detail.watchlistDetailPrice;
          tAvgPrice = tCost / tShare;
        }
        else {
          // this is sell, calculate the realised pl
          tRealised += (detail.watchlistDetailShare * detail.watchlistDetailPrice * (-1)) + (detail.watchlistDetailShare * tAvgPrice);
          // recalculate the share and cost
          tShare += detail.watchlistDetailShare;
          tCost += detail.watchlistDetailShare * tAvgPrice;
        }
    
      }
      // check if we still have share at the end?
      if (tShare > 0) {
        tValue = tShare * watchlist.watchlistCompanyNetAssetValue!;
        tDayGain = (watchlist.watchlistCompanyNetAssetValue! - watchlist.watchlistCompanyPrevPrice!) * tShare;
      }
      else {
        tCost = 0;
        tValue = 0;
        tDayGain = 0;
      }

      // once all finished then we can add this to the main variable container
      totalDayGainGold += tDayGain;
      totalValueGold += tValue;
      totalCostGold += tCost;
      totalRealisedGold += tRealised;
    }

    totalDayGain = totalDayGainReksadana + totalDayGainSaham + totalDayGainCrypto + totalDayGainGold;
    totalValue = totalValueReksadana + totalValueSaham + totalValueCrypto + totalValueGold;
    totalCost = totalCostReksadana + totalCostSaham + totalCostCrypto + totalCostGold;
    totalRealised = totalRealisedReksadana + totalRealisedSaham + totalRealisedCrypto + totalRealisedGold;

    return ComputeWatchlistAllResult(
      totalDayGain: totalDayGain, totalValue: totalValue, totalCost: totalCost, totalRealised: totalRealised,
      totalDayGainReksadana: totalDayGainReksadana, totalValueReksadana: totalValueReksadana, totalCostReksadana: totalCostReksadana, totalRealisedReksadana: totalRealisedReksadana,
      totalDayGainSaham: totalDayGainSaham, totalValueSaham: totalValueSaham, totalCostSaham: totalCostSaham, totalRealisedSaham: totalRealisedSaham,
      totalDayGainCrypto: totalDayGainCrypto, totalValueCrypto: totalValueCrypto, totalCostCrypto: totalCostCrypto, totalRealisedCrypto: totalRealisedCrypto,
      totalDayGainGold: totalDayGainGold, totalValueGold: totalValueGold, totalCostGold: totalCostGold, totalRealisedGold: totalRealisedGold
    );
  }