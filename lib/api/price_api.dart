import 'dart:convert';
import 'package:my_wealth/model/common/common_single_model.dart';
import 'package:my_wealth/model/price/price_saham_ma_model.dart';
import 'package:my_wealth/model/price/price_saham_movement_model.dart';
import 'package:my_wealth/utils/globals.dart';
import 'package:my_wealth/utils/net/netutils.dart';

class PriceAPI {
  Future<PriceSahamMovingAverageModel> getPriceMovingAverage(String stockCode) async {
    // get saham price data using netutils
    final String body = await NetUtils.get(
      url: '${Globals.apiPriceSaham}/ma/code/$stockCode'
    ).onError((error, stackTrace) {
        throw Exception(error);
      }
    );

    // parse the response to get saham moving average price
    CommonSingleModel commonModel = CommonSingleModel.fromJson(jsonDecode(body));
    PriceSahamMovingAverageModel priceMa = PriceSahamMovingAverageModel.fromJson(commonModel.data['attributes']);
    return priceMa;
  }

  Future<PriceSahamMovementModel> getPriceMovement(String stockCode) async {
    // get saham price data using netutils
    final String body = await NetUtils.get(
      url: '${Globals.apiPriceSaham}/movement/code/$stockCode'
    ).onError((error, stackTrace) {
        throw Exception(error);
      }
    );

    // parse the response to get the price movement data
    CommonSingleModel commonModel = CommonSingleModel.fromJson(jsonDecode(body));
    PriceSahamMovementModel priceMovement = PriceSahamMovementModel.fromJson(commonModel.data['attributes']);
    return priceMovement;
  }
}