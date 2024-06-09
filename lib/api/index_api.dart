import 'dart:convert';
import 'package:my_wealth/model/common/common_array_model.dart';
import 'package:my_wealth/model/company/company_seasonality_model.dart';
import 'package:my_wealth/model/index/index_model.dart';
import 'package:my_wealth/model/index/index_price_model.dart';
import 'package:my_wealth/utils/globals.dart';
import 'package:my_wealth/utils/net/netutils.dart';

class IndexAPI {  
  Future<List<IndexModel>> getIndex() async {
    // get the index data using netutils
    final String body = await NetUtils.get(
      url: Globals.apiIndices
    ).onError((error, stackTrace) {
        throw Exception(error);
      }
    );

    // parse the response to get the list of index
    CommonArrayModel commonModel = CommonArrayModel.fromJson(jsonDecode(body));
    List<IndexModel> listIndex = [];
    for (var data in commonModel.data) {
      IndexModel index = IndexModel.fromJson(data['attributes']);
      listIndex.add(index);
    }
    return listIndex;
  }

  Future<List<IndexPriceModel>> getIndexPrice(int indexId) async {
    // get the index data using netutils
    final String body = await NetUtils.get(
      url: '${Globals.apiIndicePrice}/$indexId'
    ).onError((error, stackTrace) {
        throw Exception(error);
      }
    );

    // parse the response to get the list of price for specific index data
    CommonArrayModel commonModel = CommonArrayModel.fromJson(jsonDecode(body));
    List<IndexPriceModel> listIndexPrice = [];
    for (var data in commonModel.data) {
      IndexPriceModel indexPrice = IndexPriceModel.fromJson(data['attributes']);
      listIndexPrice.add(indexPrice);
    }
    return listIndexPrice;
  }

  Future<List<IndexPriceModel>> getIndexPriceDate(int indexID, DateTime from, DateTime to) async {
    // get the index data using netutils
    final String body = await NetUtils.get(
      url: '${Globals.apiIndicePrice}/id/$indexID/from/${Globals.dfyyyyMMdd.format(from)}/to/${Globals.dfyyyyMMdd.format(to)}'
    ).onError((error, stackTrace) {
        throw Exception(error);
      }
    );

    // parse the response to get the list of price for specific index data
    CommonArrayModel commonModel = CommonArrayModel.fromJson(jsonDecode(body));
    List<IndexPriceModel> listIndexPrice = [];
    for (var data in commonModel.data) {
      IndexPriceModel indexPrice = IndexPriceModel.fromJson(data['attributes']);
      listIndexPrice.add(indexPrice);
    }
    return listIndexPrice;
  }

  Future<List<SeasonalityModel>> getSeasonality(int id) async {
    // get the company data using netutils
    final String body = await NetUtils.get(
      url: '${Globals.apiIndicePrice}/seasonality/$id'
    ).onError((error, stackTrace) {
        throw Exception(error);
      }
    );

    // parse the response to get seasonality information for this company
    CommonArrayModel commonModel = CommonArrayModel.fromJson(jsonDecode(body));
    List<SeasonalityModel> ret = [];
    for (dynamic data in commonModel.data) {
      SeasonalityModel seasonality = SeasonalityModel.fromJson(data['attributes']);
      ret.add(seasonality);
    }
    return ret;
  }
}