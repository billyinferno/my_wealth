import 'dart:convert';
import 'package:my_wealth/_index.g.dart';

class BrokerSummaryAPI {
  Future<BrokerSummaryModel> getBrokerSummary({
    required String stockCode,
    DateTime? dateFrom,
    DateTime? dateTo
  }) async {
    // get the date we want to check
    DateTime currentDateFrom = (dateFrom ?? DateTime.now().toLocal());
    DateTime currentDateTo = (dateTo ?? DateTime.now().toLocal());
    String dateFromString = Globals.dfyyyyMMdd.formatLocal(currentDateFrom);
    String dateToString = Globals.dfyyyyMMdd.formatLocal(currentDateTo);

    // get the API response
    final String body = await NetUtils.get(
      url: '${Globals.apiBrokerSummary}/code/$stockCode/from/$dateFromString/to/$dateToString'
    ).onError((error, stackTrace) {
      Log.error(
        message: 'Error on getBrokerSummary',
        error: error,
        stackTrace: stackTrace,
      );
      throw error as NetException;
    });

    // parse the body
    CommonSingleModel commonModel = CommonSingleModel.fromJson(jsonDecode(body));
    BrokerSummaryModel brokerSummary = BrokerSummaryModel.fromJson(commonModel.data['attributes']);
    return brokerSummary;
  }

  Future<BrokerSummaryModel> getBrokerSummaryNet({
    required String stockCode,
    DateTime? dateFrom,
    DateTime? dateTo
  }) async {
    // get the date we want to check
    // check if we got date or not?
    DateTime currentDateFrom = (dateFrom ?? DateTime.now().toLocal());
    DateTime currentDateTo = (dateTo ?? DateTime.now().toLocal());
    String dateFromString = Globals.dfyyyyMMdd.formatLocal(currentDateFrom);
    String dateToString = Globals.dfyyyyMMdd.formatLocal(currentDateTo);

    // get the API response
    final String body = await NetUtils.get(
      url: '${Globals.apiBrokerSummary}/net/code/$stockCode/from/$dateFromString/to/$dateToString'
    ).onError((error, stackTrace) {
      Log.error(
        message: 'Error on getBrokerSummaryNet',
        error: error,
        stackTrace: stackTrace,
      );
      throw error as NetException;
    });

    // parse the response to get the data and process each one
    CommonSingleModel commonModel = CommonSingleModel.fromJson(jsonDecode(body));
    BrokerSummaryModel brokerSummary = BrokerSummaryModel.fromJson(commonModel.data['attributes']);
    return brokerSummary;
  }

  Future<BrokerSummaryBrokerTxnListModel> getBrokerTransactionList({
    required String brokerCode,
    required int start,
    required int limit,
    DateTime? dateFrom,
    DateTime? dateTo
  }) async {
    // check if we got date or not?
    DateTime currentDateFrom = (dateFrom ?? DateTime.now().toLocal());
    DateTime currentDateTo = (dateTo ?? DateTime.now().toLocal());
    String dateFromString = Globals.dfyyyyMMdd.formatLocal(currentDateFrom);
    String dateToString = Globals.dfyyyyMMdd.formatLocal(currentDateTo);

    // get the API response
    final String body = await NetUtils.get(
      url: '${Globals.apiBrokerSummary}/broker/$brokerCode/from/$dateFromString/to/$dateToString/start/$start/limit/$limit'
    ).onError((error, stackTrace) {
      Log.error(
        message: 'Error on getBrokerTransactionList',
        error: error,
        stackTrace: stackTrace,
      );
      throw error as NetException;
    });

    // parse the response to get the data and process each one
    CommonSingleModel commonModel = CommonSingleModel.fromJson(jsonDecode(body));
    BrokerSummaryBrokerTxnListModel brokerTxnList = BrokerSummaryBrokerTxnListModel.fromJson(commonModel.data['attributes']);
    return brokerTxnList;
  }

  Future<BrokerSummaryTxnDetailModel> getBrokerTransactionDetail({
    required String brokerCode,
    required String stockCode,
    DateTime? dateFrom,
    DateTime? dateTo
  }) async {
    // check if we got date or not?
    DateTime currentDateFrom = (dateFrom ?? DateTime.now().toLocal());
    DateTime currentDateTo = (dateTo ?? DateTime.now().toLocal());
    String dateFromString = Globals.dfyyyyMMdd.formatLocal(currentDateFrom);
    String dateToString = Globals.dfyyyyMMdd.formatLocal(currentDateTo);

    // get the API response
    final String body = await NetUtils.get(
      url: '${Globals.apiBrokerSummary}/detail/broker/$brokerCode/code/$stockCode/from/$dateFromString/to/$dateToString'
    ).onError((error, stackTrace) {
      Log.error(
        message: 'Error on getBrokerTransactionDetail',
        error: error,
        stackTrace: stackTrace,
      );
      throw error as NetException;
    });

    // parse the response to get the broker transaction detail data
    CommonSingleModel commonModel = CommonSingleModel.fromJson(jsonDecode(body));
    BrokerSummaryTxnDetailModel brokerTxnDetail = BrokerSummaryTxnDetailModel.fromJson(commonModel.data['attributes']);
    return brokerTxnDetail;
  }

  Future<BrokerSummaryTopModel> getBrokerSummaryTop({
    DateTime? searchDate
  }) async {
    // check if we got date or not?
    String url = '';
    if (searchDate == null) {
      url = '${Globals.apiBrokerSummary}/top/last';
    }
    else {
      String dateSearchText = Globals.dfyyyyMMdd.formatLocal(searchDate);
      url = '${Globals.apiBrokerSummary}/top/date/$dateSearchText';
    }

    // get the API response
    final String body = await NetUtils.get(
      url: url
    ).onError((error, stackTrace) {
      Log.error(
        message: 'Error on getBrokerSummaryTop',
        error: error,
        stackTrace: stackTrace,
      );
      throw error as NetException;
    });

    // parse the response to get broker summary top result
    CommonSingleModel commonModel = CommonSingleModel.fromJson(jsonDecode(body));
    BrokerSummaryTopModel brokerTopResult = BrokerSummaryTopModel.fromJson(commonModel.data['attributes']);
    return brokerTopResult;
  }

  Future<BrokerSummaryDateModel> getBrokerSummaryCodeDate({
    required String stockCode
  }) async {
    // get the API response
    final String body = await NetUtils.get(
      url: '${Globals.apiBrokerSummary}/date/code/$stockCode'
    ).onError((error, stackTrace) {
      Log.error(
        message: 'Error on getBrokerSummaryCodeDate',
        error: error,
        stackTrace: stackTrace,
      );
      throw error as NetException;
    });

    // parse the response to get broker summary data based on the stock code
    CommonSingleModel commonModel = CommonSingleModel.fromJson(jsonDecode(body));
    BrokerSummaryDateModel brokerSummarryCode = BrokerSummaryDateModel.fromJson(commonModel.data['attributes']);
    return brokerSummarryCode;
  }

  Future<BrokerSummaryDateModel> getBrokerSummaryBrokerDate({
    required String brokerID
  }) async {
    // get the API response
    final String body = await NetUtils.get(
      url: '${Globals.apiBrokerSummary}/date/broker/$brokerID'
    ).onError((error, stackTrace) {
      Log.error(
        message: 'Error on getBrokerSummaryBrokerDate',
        error: error,
        stackTrace: stackTrace,
      );
      throw error as NetException;
    });

    // parse the response to get broker summary date
    CommonSingleModel commonModel = CommonSingleModel.fromJson(jsonDecode(body));
    BrokerSummaryDateModel brokerSummaryDate = BrokerSummaryDateModel.fromJson(commonModel.data['attributes']);
    return brokerSummaryDate;
  }

  Future<BrokerSummaryDateModel> getBrokerSummaryDate() async {
    // get the API response
    final String body = await NetUtils.get(
      url: '${Globals.apiBrokerSummary}/date/all'
    ).onError((error, stackTrace) {
      Log.error(
        message: 'Error on getBrokerSummaryDate',
        error: error,
        stackTrace: stackTrace,
      );
      throw error as NetException;
    });

    // parse the response to get the broker summary date for all
    CommonSingleModel commonModel = CommonSingleModel.fromJson(jsonDecode(body));
    BrokerSummaryDateModel brokerSummaryDate = BrokerSummaryDateModel.fromJson(commonModel.data['attributes']);
    return brokerSummaryDate;
  }

  Future<BrokerSummaryAccumulationModel> getBrokerSummaryAccumulation({
    required String version,
    required String stockCode,
    required DateTime date
  }) async {
    // get the API response
    final String body = await NetUtils.get(
      url: '${Globals.apiBrokerSummary}/accum/$version/code/$stockCode/date/${Globals.dfyyyyMMdd.formatLocal(date)}'
    ).onError((error, stackTrace) {
      Log.error(
        message: 'Error on getBrokerSummaryAccumulation',
        error: error,
        stackTrace: stackTrace,
      );
      throw error as NetException;
    });

    // parse the response to get the broker summary accumulation data
    CommonSingleModel commonModel = CommonSingleModel.fromJson(jsonDecode(body));
    BrokerSummaryAccumulationModel brokerSummary = BrokerSummaryAccumulationModel.fromJson(commonModel.data['attributes']);
    return brokerSummary;
  }

  Future<BrokerSummaryDailyStatModel> getBrokerSummaryDailyStat({
    required String code
  }) async {
    // get the API response
    final String body = await NetUtils.get(
      url: '${Globals.apiBrokerSummary}/stat/daily/code/$code'
    ).onError((error, stackTrace) {
      Log.error(
        message: 'Error on getBrokerSummaryDailyStat',
        error: error,
        stackTrace: stackTrace,
      );
      throw error as NetException;
    });

    // parse the response to get the broker summary daily statistic
    CommonSingleModel commonModel = CommonSingleModel.fromJson(jsonDecode(body));
    BrokerSummaryDailyStatModel brokerSummary = BrokerSummaryDailyStatModel.fromJson(commonModel.data['attributes']);
    return brokerSummary;
  }

  Future<BrokerSummaryDailyStatModel> getBrokerSummaryMonthlyStat({
    required String code
  }) async {
    // get the API response
    final String body = await NetUtils.get(
      url: '${Globals.apiBrokerSummary}/stat/monthly/code/$code'
    ).onError((error, stackTrace) {
      Log.error(
        message: 'Error on getBrokerSummaryMonthlyStat',
        error: error,
        stackTrace: stackTrace,
      );
      throw error as NetException;
    });

    // parse the response to get the broker summary monthly statistic
    CommonSingleModel commonModel = CommonSingleModel.fromJson(jsonDecode(body));
    BrokerSummaryDailyStatModel brokerSummary = BrokerSummaryDailyStatModel.fromJson(commonModel.data['attributes']);
    return brokerSummary;
  }
}