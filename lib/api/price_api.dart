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
      url: '${Globals.apiPriceGold}/from/${Globals.dfyyyyMMdd.formatLocal(from)}/to/${Globals.dfyyyyMMdd.formatLocal(to)}'
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

  Future<List<PriceModel>> getCompanyPriceByID({
    required int id,
    required String type,
    int limit = 90,
  }) async {
    // get reksadana information using netutils
    final String body = await NetUtils.get(
      url: '${Globals.apiPrices}/type/$type/id/$id/limit/$limit'
    ).onError((error, stackTrace) {
      Log.error(
        message: 'Error on getCompanyPriceByID',
        error: error,
        stackTrace: stackTrace,
      );
      throw error as NetException;
    });

    // parse the response to reksdana information
    CommonArrayModel commonModel = CommonArrayModel.fromJson(jsonDecode(body));
    List<PriceModel> listPrice = [];
    for (var data in commonModel.data) {
      PriceModel price = PriceModel.fromJson(data['attributes']);
      listPrice.add(price);
    }
    return listPrice;
  }
}