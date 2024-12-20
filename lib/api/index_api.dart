import 'dart:convert';
import 'package:my_wealth/_index.g.dart';

class IndexAPI {  
  Future<List<IndexModel>> getIndex() async {
    // get the index data using netutils
    final String body = await NetUtils.get(
      url: Globals.apiIndices
    ).onError((error, stackTrace) {
      Log.error(
        message: 'Error on getIndex',
        error: error,
        stackTrace: stackTrace,
      );
      throw error as NetException;
    });

    // parse the response to get the list of index
    CommonArrayModel commonModel = CommonArrayModel.fromJson(jsonDecode(body));
    List<IndexModel> listIndex = [];
    for (var data in commonModel.data) {
      IndexModel index = IndexModel.fromJson(data['attributes']);
      listIndex.add(index);
    }
    return listIndex;
  }

  Future<List<IndexPriceModel>> getIndexPrice({required int indexId}) async {
    // get the index data using netutils
    final String body = await NetUtils.get(
      url: '${Globals.apiIndicePrice}/$indexId'
    ).onError((error, stackTrace) {
      Log.error(
        message: 'Error on getIndexPrice',
        error: error,
        stackTrace: stackTrace,
      );
      throw error as NetException;
    });

    // parse the response to get the list of price for specific index data
    CommonArrayModel commonModel = CommonArrayModel.fromJson(jsonDecode(body));
    List<IndexPriceModel> listIndexPrice = [];
    for (var data in commonModel.data) {
      IndexPriceModel indexPrice = IndexPriceModel.fromJson(data['attributes']);
      listIndexPrice.add(indexPrice);
    }
    return listIndexPrice;
  }

  Future<List<IndexPriceModel>> getIndexPriceDate({
    required int indexID,
    required DateTime from,
    required DateTime to
  }) async {
    // get the index data using netutils
    final String body = await NetUtils.get(
      url: '${Globals.apiIndicePrice}/id/$indexID/from/${Globals.dfyyyyMMdd.formatLocal(from)}/to/${Globals.dfyyyyMMdd.formatLocal(to)}'
    ).onError((error, stackTrace) {
      Log.error(
        message: 'Error on getIndexPriceDate',
        error: error,
        stackTrace: stackTrace,
      );
      throw error as NetException;
    });

    // parse the response to get the list of price for specific index data
    CommonArrayModel commonModel = CommonArrayModel.fromJson(jsonDecode(body));
    List<IndexPriceModel> listIndexPrice = [];
    for (var data in commonModel.data) {
      IndexPriceModel indexPrice = IndexPriceModel.fromJson(data['attributes']);
      listIndexPrice.add(indexPrice);
    }
    return listIndexPrice;
  }

  Future<List<SeasonalityModel>> getSeasonality({required int id}) async {
    // get the company data using netutils
    final String body = await NetUtils.get(
      url: '${Globals.apiIndicePrice}/seasonality/$id'
    ).onError((error, stackTrace) {
      Log.error(
        message: 'Error on getSeasonality',
        error: error,
        stackTrace: stackTrace,
      );
      throw error as NetException;
    });

    // parse the response to get seasonality information for this company
    CommonArrayModel commonModel = CommonArrayModel.fromJson(jsonDecode(body));
    List<SeasonalityModel> ret = [];
    for (dynamic data in commonModel.data) {
      SeasonalityModel seasonality = SeasonalityModel.fromJson(data['attributes']);
      ret.add(seasonality);
    }
    return ret;
  }

  Future<CompanyWeekdayPerformanceModel> getIndexWeekdayPerformance({
    required int id,
    required DateTime fromDate,
    required DateTime toDate,
  }) async {
    // get the initial query information for the API
    String dateFromString = Globals.dfyyyyMMdd.formatLocal(fromDate);
    String dateToString = Globals.dfyyyyMMdd.formatLocal(toDate);

    // get the company data using netutils
    final String body = await NetUtils.get(
      url: '${Globals.apiIndices}/weekday/$id/from/$dateFromString/to/$dateToString'
    ).onError((error, stackTrace) {
      Log.error(
        message: 'Error on getIndexWeekdayPerformance',
        error: error,
        stackTrace: stackTrace,
      );
      throw error as NetException;
    });

    // parse the response to get top broker information
    CommonSingleModel commonModel = CommonSingleModel.fromJson(jsonDecode(body));
    CompanyWeekdayPerformanceModel weekdayPerformance = CompanyWeekdayPerformanceModel.fromJson(commonModel.data['attributes']);
    return weekdayPerformance;
  }

  Future<CompanyWeekdayPerformanceModel> getIndexMonthlyPerformance({
    required int id,
    required DateTime fromDate,
    required DateTime toDate,
  }) async {
    // get the initial query information for the API
    String dateFromString = Globals.dfyyyyMMdd.formatLocal(fromDate);
    String dateToString = Globals.dfyyyyMMdd.formatLocal(toDate);

    // get the company data using netutils
    final String body = await NetUtils.get(
      url: '${Globals.apiIndices}/monthly/$id/from/$dateFromString/to/$dateToString'
    ).onError((error, stackTrace) {
      Log.error(
        message: 'Error on getIndexMonthlyPerformance',
        error: error,
        stackTrace: stackTrace,
      );
      throw error as NetException;
    });

    // parse the response to get top broker information
    CommonSingleModel commonModel = CommonSingleModel.fromJson(jsonDecode(body));
    CompanyWeekdayPerformanceModel weekdayPerformance = CompanyWeekdayPerformanceModel.fromJson(commonModel.data['attributes']);
    return weekdayPerformance;
  }

  Future<MinMaxDateModel> getIndexPriceMinMaxDate({
    required int companyId
  }) async {
    // get the API response
    final String body = await NetUtils.get(
      url: '${Globals.apiIndicePrice}/minmax/date/$companyId'
    ).onError((error, stackTrace) {
      Log.error(
        message: 'Error on getIndexPriceMinMaxDate',
        error: error,
        stackTrace: stackTrace,
      );
      throw error as NetException;
    });

    // parse the response to get broker summary data based on the stock code
    CommonSingleModel commonModel = CommonSingleModel.fromJson(jsonDecode(body));
    MinMaxDateModel minMaxDate = MinMaxDateModel.fromJson(commonModel.data['attributes']);
    return minMaxDate;
  }
}