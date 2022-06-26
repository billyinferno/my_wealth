import 'package:my_wealth/model/watchlist_detail_list_model.dart';
import 'package:my_wealth/model/watchlist_list_model.dart';

class ComputeWatchlistResult {
  final double totalDayGain;
  final double totalValue;
  final double totalCost;

  final double totalDayGainReksadana;
  final double totalValueReksadana;
  final double totalCostReksadana;

  final double totalDayGainSaham;
  final double totalValueSaham;
  final double totalCostSaham;

  final double totalDayGainCrypto;
  final double totalValueCrypto;
  final double totalCostCrypto;

  final double totalDayGainGold;
  final double totalValueGold;
  final double totalCostGold;

  ComputeWatchlistResult({
    required this.totalDayGain, required this.totalValue, required this.totalCost,
    required this.totalDayGainReksadana, required this.totalValueReksadana, required this.totalCostReksadana,
    required this.totalDayGainSaham, required this.totalValueSaham, required this.totalCostSaham,
    required this.totalDayGainCrypto, required this.totalValueCrypto, required this.totalCostCrypto,
    required this.totalDayGainGold, required this.totalValueGold, required this.totalCostGold,
  });
}

ComputeWatchlistResult computeWatchlist(List<WatchlistListModel> watchlistsMutualfund, List<WatchlistListModel> watchlistsStock, List<WatchlistListModel> watchlistsCrypto, List<WatchlistListModel> watchlistsGold) {
    // reset the value before we actually compute the data
    double totalDayGain = 0;
    double totalValue = 0;
    double totalCost = 0;   
    
    double totalDayGainReksadana = 0;
    double totalValueReksadana = 0;
    double totalCostReksadana = 0;

    double totalDayGainSaham = 0;
    double totalValueSaham = 0;
    double totalCostSaham = 0;

    double totalDayGainCrypto = 0;
    double totalValueCrypto = 0;
    double totalCostCrypto = 0;

    double totalDayGainGold = 0;
    double totalValueGold = 0;
    double totalCostGold = 0;

    double dayGain = 0;

    // loop thru all the mutual fund to get the total computation
    double totalShareBuy = 0;
    double totalShareSell = 0;
    double totalShareCurrent = 0;
    double totalCostBuy = 0;
    double totalCostCurrent = 0;
    double totalValueCurrent = 0;
    double averageBuyPrice = 0;
    
    for (WatchlistListModel watchlist in watchlistsMutualfund) {
      // initialize the variable needed for the calculation for each mutual fund
      totalShareBuy = 0;
      totalShareSell = 0;
      totalShareCurrent = 0;
      totalCostBuy = 0;
      totalCostCurrent = 0;
      totalValueCurrent = 0;
      averageBuyPrice = 0;

      for (WatchlistDetailListModel detail in watchlist.watchlistDetail) {
        if (detail.watchlistDetailShare > 0) {
          totalShareBuy += detail.watchlistDetailShare;
          totalCostBuy += (detail.watchlistDetailShare * detail.watchlistDetailPrice);
        }
        else {
          totalShareSell += detail.watchlistDetailShare;
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

      for (WatchlistDetailListModel detail in watchlist.watchlistDetail) {
        if (detail.watchlistDetailShare > 0) {
          totalShareBuy += detail.watchlistDetailShare;
          totalCostBuy += (detail.watchlistDetailShare * detail.watchlistDetailPrice);
        }
        else {
          totalShareSell += detail.watchlistDetailShare;
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
      totalDayGainSaham += dayGain;

      // get the cost of the share
      totalCostCurrent = totalShareCurrent * averageBuyPrice;
      totalCostSaham += totalCostCurrent;

      // get the value of the share now
      totalValueCurrent = totalShareCurrent * watchlist.watchlistCompanyNetAssetValue!;
      totalValueSaham += totalValueCurrent;
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

      for (WatchlistDetailListModel detail in watchlist.watchlistDetail) {
        if (detail.watchlistDetailShare > 0) {
          totalShareBuy += detail.watchlistDetailShare;
          totalCostBuy += (detail.watchlistDetailShare * detail.watchlistDetailPrice);
        }
        else {
          totalShareSell += detail.watchlistDetailShare;
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
      totalDayGainCrypto += dayGain;

      // get the cost of the share
      totalCostCurrent = totalShareCurrent * averageBuyPrice;
      totalCostCrypto += totalCostCurrent;

      // get the value of the share now
      totalValueCurrent = totalShareCurrent * watchlist.watchlistCompanyNetAssetValue!;
      totalValueCrypto += totalValueCurrent;
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

      for (WatchlistDetailListModel detail in watchlist.watchlistDetail) {
        if (detail.watchlistDetailShare > 0) {
          totalShareBuy += detail.watchlistDetailShare;
          totalCostBuy += (detail.watchlistDetailShare * detail.watchlistDetailPrice);
        }
        else {
          totalShareSell += detail.watchlistDetailShare;
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
      totalDayGainGold += dayGain;

      // get the cost of the share
      totalCostCurrent = totalShareCurrent * averageBuyPrice;
      totalCostGold += totalCostCurrent;

      // get the value of the share now
      totalValueCurrent = totalShareCurrent * watchlist.watchlistCompanyNetAssetValue!;
      totalValueGold += totalValueCurrent;
    }

    totalDayGain = totalDayGainReksadana + totalDayGainSaham + totalDayGainCrypto + totalDayGainGold;
    totalValue = totalValueReksadana + totalValueSaham + totalValueCrypto + totalValueGold;
    totalCost = totalCostReksadana + totalCostSaham + totalCostCrypto + totalCostGold;

    return ComputeWatchlistResult(
      totalDayGain: totalDayGain, totalValue: totalValue, totalCost: totalCost,
      totalDayGainReksadana: totalDayGainReksadana, totalValueReksadana: totalValueReksadana, totalCostReksadana: totalCostReksadana,
      totalDayGainSaham: totalDayGainSaham, totalValueSaham: totalValueSaham, totalCostSaham: totalCostSaham,
      totalDayGainCrypto: totalDayGainCrypto, totalValueCrypto: totalValueCrypto, totalCostCrypto: totalCostCrypto,
      totalDayGainGold: totalDayGainGold, totalValueGold: totalValueGold, totalCostGold: totalCostGold
    );
  }