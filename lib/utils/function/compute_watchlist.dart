import 'package:my_wealth/model/watchlist_detail_list_model.dart';
import 'package:my_wealth/model/watchlist_list_model.dart';

class ComputeWatchlistResult {
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

  ComputeWatchlistResult({
    required this.totalDayGain, required this.totalValue, required this.totalCost, required this.totalRealised,
    required this.totalDayGainReksadana, required this.totalValueReksadana, required this.totalCostReksadana, required this.totalRealisedReksadana,
    required this.totalDayGainSaham, required this.totalValueSaham, required this.totalCostSaham, required this.totalRealisedSaham,
    required this.totalDayGainCrypto, required this.totalValueCrypto, required this.totalCostCrypto, required this.totalRealisedCrypto,
    required this.totalDayGainGold, required this.totalValueGold, required this.totalCostGold, required this.totalRealisedGold,
  });
}

ComputeWatchlistResult computeWatchlist(List<WatchlistListModel> watchlistsMutualfund, List<WatchlistListModel> watchlistsStock, List<WatchlistListModel> watchlistsCrypto, List<WatchlistListModel> watchlistsGold) {
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

    double dayGain = 0;

    // loop thru all the mutual fund to get the total computation
    double totalShareBuy = 0;
    double totalShareSell = 0;
    double totalShareCurrent = 0;
    double totalCostBuy = 0;
    double totalCostCurrent = 0;
    double totalValueCurrent = 0;
    double averageBuyPrice = 0;
    double averageGainPrice = 0;
    double totalCostGain = 0;
    double totalShareGain = 0;
    
    for (WatchlistListModel watchlist in watchlistsMutualfund) {
      // initialize the variable needed for the calculation for each mutual fund
      totalShareBuy = 0;
      totalShareSell = 0;
      totalShareCurrent = 0;
      totalCostBuy = 0;
      totalCostCurrent = 0;
      totalValueCurrent = 0;
      averageBuyPrice = 0;
      averageGainPrice = 0;
      totalCostGain = 0;
      totalShareGain = 0;

      for (WatchlistDetailListModel detail in watchlist.watchlistDetail.reversed) {
        if (detail.watchlistDetailShare > 0) {
          totalShareBuy += detail.watchlistDetailShare;
          totalCostBuy += (detail.watchlistDetailShare * detail.watchlistDetailPrice);

          totalShareGain += totalShareBuy;
          totalCostGain += totalCostBuy;
        }
        else {
          // if you sell by right you should already have the current totalShareBuy and totalCostBuy
          // but since we don't have that kind of protection when we insert data, we still need to perform
          // the check here as we perform divide and it can cause error
          if (totalShareGain > 0 && totalCostGain > 0) {
            averageGainPrice = totalCostGain / totalShareGain;
          }

          // calculate the total sell and gain for this sell
          totalShareSell += detail.watchlistDetailShare;
          totalRealisedReksadana += (detail.watchlistDetailShare * detail.watchlistDetailPrice * -1) - (detail.watchlistDetailShare * averageGainPrice * -1);

          // recalculate the totalShareGain and totalCostGain, as we already sell few of our stock
          totalShareGain -= (detail.watchlistDetailShare);
          totalCostGain -= (detail.watchlistDetailShare * detail.watchlistDetailPrice * -1);
        }
      }

      // get what is the average buy price that we have
      if (totalShareBuy > 0 && totalCostBuy > 0) {
        averageBuyPrice = totalCostBuy / totalShareBuy;
      }


      // total sell is negative, make it a positive
      totalShareSell *= -1;

      // get the total of current share we have
      totalShareCurrent = totalShareBuy - totalShareSell;

      // get the day gain
      dayGain = (watchlist.watchlistCompanyNetAssetValue! - watchlist.watchlistCompanyPrevPrice!) * totalShareCurrent;
      totalDayGainReksadana += dayGain;

      // get the cost of the share
      totalCostCurrent = totalShareCurrent * averageBuyPrice;
      totalCostReksadana += totalCostCurrent;

      // get the value of the share now
      totalValueCurrent = totalShareCurrent * watchlist.watchlistCompanyNetAssetValue!;
      totalValueReksadana += totalValueCurrent;
    }

    // loop thru all the stock to get the total computation
    for (WatchlistListModel watchlist in watchlistsStock) {
      // initialize the variable needed for the calculation for each mutual fund
      totalShareBuy = 0;
      totalShareSell = 0;
      totalShareCurrent = 0;
      totalCostBuy = 0;
      totalCostCurrent = 0;
      totalValueCurrent = 0;
      averageBuyPrice = 0;
      averageGainPrice = 0;
      totalCostGain = 0;
      totalShareGain = 0;

      for (WatchlistDetailListModel detail in watchlist.watchlistDetail.reversed) {
        if (detail.watchlistDetailShare > 0) {
          totalShareBuy += detail.watchlistDetailShare;
          totalCostBuy += (detail.watchlistDetailShare * detail.watchlistDetailPrice);
          
          totalShareGain += totalShareBuy;
          totalCostGain += totalCostBuy;
        }
        else {
          // if you sell by right you should already have the current totalShareBuy and totalCostBuy
          // but since we don't have that kind of protection when we insert data, we still need to perform
          // the check here as we perform divide and it can cause error
          if (totalShareGain > 0 && totalCostGain > 0) {
            averageGainPrice = totalCostGain / totalShareGain;
          }

          // calculate the total sell and gain for this sell
          totalShareSell += detail.watchlistDetailShare;
          totalRealisedSaham += (detail.watchlistDetailShare * detail.watchlistDetailPrice * -1) - (detail.watchlistDetailShare * averageGainPrice * -1);

          // recalculate the totalShareGain and totalCostGain, as we already sell few of our stock
          totalShareGain -= (detail.watchlistDetailShare);
          totalCostGain -= (detail.watchlistDetailShare * detail.watchlistDetailPrice * -1);
        }
      }

      // check if we still have share left
      if ((totalShareBuy + totalShareSell) > 0) {
        // get what is the average buy price that we have
        if (totalShareBuy > 0 && totalCostBuy > 0) {
          averageBuyPrice = totalCostBuy / totalShareBuy;
        }

        // total sell is negative, make it a positive
        totalShareSell *= -1;

        // get the total of current share we have
        totalShareCurrent = totalShareBuy - totalShareSell;

        // get the day gain
        dayGain = (watchlist.watchlistCompanyNetAssetValue! - watchlist.watchlistCompanyPrevPrice!) * totalShareCurrent;
        totalDayGainSaham += dayGain;

        // get the cost of the share
        totalCostCurrent = totalShareCurrent * averageBuyPrice;
        totalCostSaham += totalCostCurrent;

        // get the value of the share now
        totalValueCurrent = totalShareCurrent * watchlist.watchlistCompanyNetAssetValue!;
        totalValueSaham += totalValueCurrent;
      }
    }

    // loop thru all the crypto to get the total computation
    for (WatchlistListModel watchlist in watchlistsCrypto) {
      // initialize the variable needed for the calculation for each mutual fund
      totalShareBuy = 0;
      totalShareSell = 0;
      totalShareCurrent = 0;
      totalCostBuy = 0;
      totalCostCurrent = 0;
      totalValueCurrent = 0;
      averageBuyPrice = 0;
      averageGainPrice = 0;
      totalCostGain = 0;
      totalShareGain = 0;

      for (WatchlistDetailListModel detail in watchlist.watchlistDetail.reversed) {
        if (detail.watchlistDetailShare > 0) {
          totalShareBuy += detail.watchlistDetailShare;
          totalCostBuy += (detail.watchlistDetailShare * detail.watchlistDetailPrice);

          totalShareGain += totalShareBuy;
          totalCostGain += totalCostBuy;
        }
        else {
          // if you sell by right you should already have the current totalShareBuy and totalCostBuy
          // but since we don't have that kind of protection when we insert data, we still need to perform
          // the check here as we perform divide and it can cause error
          if (totalShareGain > 0 && totalCostGain > 0) {
            averageGainPrice = totalCostGain / totalShareGain;
          }

          // calculate the total sell and gain for this sell
          totalShareSell += detail.watchlistDetailShare;
          totalRealisedCrypto += (detail.watchlistDetailShare * detail.watchlistDetailPrice * -1) - (detail.watchlistDetailShare * averageGainPrice * -1);

          // recalculate the totalShareGain and totalCostGain, as we already sell few of our stock
          totalShareGain -= (detail.watchlistDetailShare);
          totalCostGain -= (detail.watchlistDetailShare * detail.watchlistDetailPrice * -1);
        }
      }

      // check if we still have share left or not?
      if ((totalShareBuy + totalShareSell) > 0) {
        // get what is the average buy price that we have
        if (totalShareBuy > 0 && totalCostBuy > 0) {
          averageBuyPrice = totalCostBuy / totalShareBuy;
        }

        // total sell is negative, make it a positive
        totalShareSell *= -1;

        // get the total of current share we have
        totalShareCurrent = totalShareBuy - totalShareSell;
        
        // get the day gain
        dayGain = (watchlist.watchlistCompanyNetAssetValue! - watchlist.watchlistCompanyPrevPrice!) * totalShareCurrent;
        totalDayGainCrypto += dayGain;

        // get the cost of the share
        totalCostCurrent = totalShareCurrent * averageBuyPrice;
        totalCostCrypto += totalCostCurrent;

        // get the value of the share now
        totalValueCurrent = totalShareCurrent * watchlist.watchlistCompanyNetAssetValue!;
        totalValueCrypto += totalValueCurrent;
      }
    }

    // loop thru all the gold to get the total computation
    for (WatchlistListModel watchlist in watchlistsGold) {
      // initialize the variable needed for the calculation for each mutual fund
      totalShareBuy = 0;
      totalShareSell = 0;
      totalShareCurrent = 0;
      totalCostBuy = 0;
      totalCostCurrent = 0;
      totalValueCurrent = 0;
      averageBuyPrice = 0;
      averageGainPrice = 0;
      totalCostGain = 0;
      totalShareGain = 0;

      for (WatchlistDetailListModel detail in watchlist.watchlistDetail.reversed) {
        if (detail.watchlistDetailShare > 0) {
          totalShareBuy += detail.watchlistDetailShare;
          totalCostBuy += (detail.watchlistDetailShare * detail.watchlistDetailPrice);

          totalShareGain += totalShareBuy;
          totalCostGain += totalCostBuy;
        }
        else {
          // if you sell by right you should already have the current totalShareBuy and totalCostBuy
          // but since we don't have that kind of protection when we insert data, we still need to perform
          // the check here as we perform divide and it can cause error
          if (totalShareGain > 0 && totalCostGain > 0) {
            averageGainPrice = totalCostGain / totalShareGain;
          }

          // calculate the total sell and gain for this sell
          totalShareSell += detail.watchlistDetailShare;
          totalRealisedGold += (detail.watchlistDetailShare * detail.watchlistDetailPrice * -1) - (detail.watchlistDetailShare * averageGainPrice * -1);

          // recalculate the totalShareGain and totalCostGain, as we already sell few of our stock
          totalShareGain -= (detail.watchlistDetailShare);
          totalCostGain -= (detail.watchlistDetailShare * detail.watchlistDetailPrice * -1);
        }
      }

      if ((totalShareBuy + totalShareSell) > 0) {
        // get what is the average buy price that we have
        if (totalShareBuy > 0 && totalCostBuy > 0) {
          averageBuyPrice = totalCostBuy / totalShareBuy;
        }

        // total sell is negative, make it a positive
        totalShareSell *= -1;

        // get the total of current share we have
        totalShareCurrent = totalShareBuy - totalShareSell;
        
        // get the day gain
        dayGain = (watchlist.watchlistCompanyNetAssetValue! - watchlist.watchlistCompanyPrevPrice!) * totalShareCurrent;
        totalDayGainGold += dayGain;

        // get the cost of the share
        totalCostCurrent = totalShareCurrent * averageBuyPrice;
        totalCostGold += totalCostCurrent;

        // get the value of the share now
        totalValueCurrent = totalShareCurrent * watchlist.watchlistCompanyNetAssetValue!;
        totalValueGold += totalValueCurrent;
      }
    }

    totalDayGain = totalDayGainReksadana + totalDayGainSaham + totalDayGainCrypto + totalDayGainGold;
    totalValue = totalValueReksadana + totalValueSaham + totalValueCrypto + totalValueGold;
    totalCost = totalCostReksadana + totalCostSaham + totalCostCrypto + totalCostGold;
    totalRealised = totalRealisedReksadana + totalRealisedSaham + totalRealisedCrypto + totalRealisedGold;

    return ComputeWatchlistResult(
      totalDayGain: totalDayGain, totalValue: totalValue, totalCost: totalCost, totalRealised: totalRealised,
      totalDayGainReksadana: totalDayGainReksadana, totalValueReksadana: totalValueReksadana, totalCostReksadana: totalCostReksadana, totalRealisedReksadana: totalRealisedReksadana,
      totalDayGainSaham: totalDayGainSaham, totalValueSaham: totalValueSaham, totalCostSaham: totalCostSaham, totalRealisedSaham: totalRealisedSaham,
      totalDayGainCrypto: totalDayGainCrypto, totalValueCrypto: totalValueCrypto, totalCostCrypto: totalCostCrypto, totalRealisedCrypto: totalRealisedCrypto,
      totalDayGainGold: totalDayGainGold, totalValueGold: totalValueGold, totalCostGold: totalCostGold, totalRealisedGold: totalRealisedGold
    );
  }