import 'dart:convert';
import 'package:my_wealth/_index.g.dart';

class PriceAPI {
  Future<PriceSahamMovingAverageModel> getPriceMovingAverage({
    required String stockCode
  }) async {
    // get saham price data using netutils
    final String body = await NetUtils.get(
      url: '${Globals.apiPriceSaham}/ma/code/$stockCode'
    ).onError((error, stackTrace) {
      Log.error(
        message: 'Error on getPriceMovingAverage',
        error: error,
        stackTrace: stackTrace,
      );
      throw error as NetException;
    });

    // parse the response to get saham moving average price
    CommonSingleModel commonModel = CommonSingleModel.fromJson(jsonDecode(body));
    PriceSahamMovingAverageModel priceMa = PriceSahamMovingAverageModel.fromJson(commonModel.data['attributes']);
    return priceMa;
  }

  Future<PriceSahamMovementModel> getPriceMovement({
    required String stockCode
  }) async {
    // get saham price data using netutils
    final String body = await NetUtils.get(
      url: '${Globals.apiPriceSaham}/movement/code/$stockCode'
    ).onError((error, stackTrace) {
      Log.error(
        message: 'Error on getPriceMovement',
        error: error,
        stackTrace: stackTrace,
      );
      throw error as NetException;
    });

    // parse the response to get the price movement data
    CommonSingleModel commonModel = CommonSingleModel.fromJson(jsonDecode(body));
    PriceSahamMovementModel priceMovement = PriceSahamMovementModel.fromJson(commonModel.data['attributes']);
    return priceMovement;
  }

  Future<List<PriceGoldModel>> getGoldPrice({
    required DateTime from,
    required DateTime to
  }) async {
    // get reksadana information using netutils
    final String body = await NetUtils.get(
      url: '${Globals.apiPriceGold}/from/${Globals.dfyyyyMMdd.format(from)}/to/${Globals.dfyyyyMMdd.format(to)}'
    ).onError((error, stackTrace) {
      Log.error(
        message: 'Error on getGoldPrice',
        error: error,
        stackTrace: stackTrace,
      );
      throw error as NetException;
    });

    // parse the response to reksdana information
    CommonArrayModel commonModel = CommonArrayModel.fromJson(jsonDecode(body));
    List<PriceGoldModel> listPriceGold = [];
    for (var data in commonModel.data) {
      PriceGoldModel price = PriceGoldModel.fromJson(data['attributes']);
      listPriceGold.add(price);
    }
    return listPriceGold;
  }
}