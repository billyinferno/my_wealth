class WatchlistSummaryArgs {
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

  WatchlistSummaryArgs({
    required this.totalDayGain, required this.totalValue, required this.totalCost,
    required this.totalDayGainReksadana, required this.totalValueReksadana, required this.totalCostReksadana,
    required this.totalDayGainSaham, required this.totalValueSaham, required this.totalCostSaham,
    required this.totalDayGainCrypto, required this.totalValueCrypto, required this.totalCostCrypto,
    required this.totalDayGainGold, required this.totalValueGold, required this.totalCostGold
  });
}