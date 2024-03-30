import 'dart:convert';
import 'package:my_wealth/model/broker/broker_summary_accumulation_model.dart';
import 'package:my_wealth/model/broker/broker_summary_daily_stat_model.dart';
import 'package:my_wealth/model/broker/broker_summary_date_model.dart';
import 'package:my_wealth/model/broker/broker_summary_broker_txn_list_model.dart';
import 'package:my_wealth/model/broker/broker_summary_model.dart';
import 'package:my_wealth/model/broker/broker_summary_top_model.dart';
import 'package:my_wealth/model/broker/broker_summary_txn_detail_model.dart';
import 'package:my_wealth/model/common/common_single_model.dart';
import 'package:my_wealth/utils/globals.dart';
import 'package:my_wealth/utils/net/netutils.dart';

class BrokerSummaryAPI {
  Future<BrokerSummaryModel> getBrokerSummary(String stockCode, [DateTime? dateFrom, DateTime? dateTo]) async {
    // get the date we want to check
    DateTime currentDateFrom = (dateFrom ?? DateTime.now().toLocal());
    DateTime currentDateTo = (dateTo ?? DateTime.now().toLocal());
    String dateFromString = Globals.dfyyyyMMdd.format(currentDateFrom);
    String dateToString = Globals.dfyyyyMMdd.format(currentDateTo);

    // get the API response
    final String body = await NetUtils.get(
      url: '${Globals.apiBrokerSummary}/code/$stockCode/from/$dateFromString/to/$dateToString'
    ).onError((error, stackTrace) {
      throw Exception(error);
    });

    // parse the body
    CommonSingleModel commonModel = CommonSingleModel.fromJson(jsonDecode(body));
    BrokerSummaryModel brokerSummary = BrokerSummaryModel.fromJson(commonModel.data['attributes']);
    return brokerSummary;
  }

  Future<BrokerSummaryModel> getBrokerSummaryNet(String stockCode, [DateTime? dateFrom, DateTime? dateTo]) async {
    // get the date we want to check
    // check if we got date or not?
    DateTime currentDateFrom = (dateFrom ?? DateTime.now().toLocal());
    DateTime currentDateTo = (dateTo ?? DateTime.now().toLocal());
    String dateFromString = Globals.dfyyyyMMdd.format(currentDateFrom);
    String dateToString = Globals.dfyyyyMMdd.format(currentDateTo);

    // get the API response
    final String body = await NetUtils.get(
      url: '${Globals.apiBrokerSummary}/net/code/$stockCode/from/$dateFromString/to/$dateToString'
    ).onError((error, stackTrace) {
      throw Exception(error);
    });

    // parse the response to get the data and process each one
    CommonSingleModel commonModel = CommonSingleModel.fromJson(jsonDecode(body));
    BrokerSummaryModel brokerSummary = BrokerSummaryModel.fromJson(commonModel.data['attributes']);
    return brokerSummary;
  }

  Future<BrokerSummaryBrokerTxnListModel> getBrokerTransactionList(String brokerCode, int start, int limit, [DateTime? dateFrom, DateTime? dateTo]) async {
    // check if we got date or not?
    DateTime currentDateFrom = (dateFrom ?? DateTime.now().toLocal());
    DateTime currentDateTo = (dateTo ?? DateTime.now().toLocal());
    String dateFromString = Globals.dfyyyyMMdd.format(currentDateFrom);
    String dateToString = Globals.dfyyyyMMdd.format(currentDateTo);

    // get the API response
    final String body = await NetUtils.get(
      url: '${Globals.apiBrokerSummary}/broker/$brokerCode/from/$dateFromString/to/$dateToString/start/$start/limit/$limit'
    ).onError((error, stackTrace) {
      throw Exception(error);
    });

    // parse the response to get the data and process each one
    CommonSingleModel commonModel = CommonSingleModel.fromJson(jsonDecode(body));
    BrokerSummaryBrokerTxnListModel brokerTxnList = BrokerSummaryBrokerTxnListModel.fromJson(commonModel.data['attributes']);
    return brokerTxnList;
  }

  Future<BrokerSummaryTxnDetailModel> getBrokerTransactionDetail(String brokerCode, String stockCode, [DateTime? dateFrom, DateTime? dateTo]) async {
    // check if we got date or not?
    DateTime currentDateFrom = (dateFrom ?? DateTime.now().toLocal());
    DateTime currentDateTo = (dateTo ?? DateTime.now().toLocal());
    String dateFromString = Globals.dfyyyyMMdd.format(currentDateFrom);
    String dateToString = Globals.dfyyyyMMdd.format(currentDateTo);

    // get the API response
    final String body = await NetUtils.get(
      url: '${Globals.apiBrokerSummary}/detail/broker/$brokerCode/code/$stockCode/from/$dateFromString/to/$dateToString'
    ).onError((error, stackTrace) {
      throw Exception(error);
    });

    // parse the response to get the broker transaction detail data
    CommonSingleModel commonModel = CommonSingleModel.fromJson(jsonDecode(body));
    BrokerSummaryTxnDetailModel brokerTxnDetail = BrokerSummaryTxnDetailModel.fromJson(commonModel.data['attributes']);
    return brokerTxnDetail;
  }

  Future<BrokerSummaryTopModel> getBrokerSummaryTop([DateTime? searchDate]) async {
    // check if we got date or not?
    String url = '';
    if (searchDate == null) {
      url = '${Globals.apiBrokerSummary}/top/last';
    }
    else {
      String dateSearchText = Globals.dfyyyyMMdd.format(searchDate);
      url = '${Globals.apiBrokerSummary}/top/date/$dateSearchText';
    }

    // get the API response
    final String body = await NetUtils.get(
      url: url
    ).onError((error, stackTrace) {
      throw Exception(error);
    });

    // parse the response to get broker summary top result
    CommonSingleModel commonModel = CommonSingleModel.fromJson(jsonDecode(body));
    BrokerSummaryTopModel brokerTopResult = BrokerSummaryTopModel.fromJson(commonModel.data['attributes']);
    return brokerTopResult;
  }

  Future<BrokerSummaryDateModel> getBrokerSummaryCodeDate(String stockCode) async {
    // get the API response
    final String body = await NetUtils.get(
      url: '${Globals.apiBrokerSummary}/date/code/$stockCode'
    ).onError((error, stackTrace) {
      throw Exception(error);
    });

    // parse the response to get broker summary data based on the stock code
    CommonSingleModel commonModel = CommonSingleModel.fromJson(jsonDecode(body));
    BrokerSummaryDateModel brokerSummarryCode = BrokerSummaryDateModel.fromJson(commonModel.data['attributes']);
    return brokerSummarryCode;
  }

  Future<BrokerSummaryDateModel> getBrokerSummaryBrokerDate(String brokerID) async {
    // get the API response
    final String body = await NetUtils.get(
      url: '${Globals.apiBrokerSummary}/date/broker/$brokerID'
    ).onError((error, stackTrace) {
      throw Exception(error);
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
      throw Exception(error);
    });

    // parse the response to get the broker summary date for all
    CommonSingleModel commonModel = CommonSingleModel.fromJson(jsonDecode(body));
    BrokerSummaryDateModel brokerSummaryDate = BrokerSummaryDateModel.fromJson(commonModel.data['attributes']);
    return brokerSummaryDate;
  }

  Future<BrokerSummaryAccumulationModel> getBrokerSummaryAccumulation(String version, String stockCode, DateTime currentDate) async {
    // get the API response
    final String body = await NetUtils.get(
      url: '${Globals.apiBrokerSummary}/accum/$version/code/$stockCode/date/${Globals.dfyyyyMMdd.format(currentDate)}'
    ).onError((error, stackTrace) {
      throw Exception(error);
    });

    // parse the response to get the broker summary accumulation data
    CommonSingleModel commonModel = CommonSingleModel.fromJson(jsonDecode(body));
    BrokerSummaryAccumulationModel brokerSummary = BrokerSummaryAccumulationModel.fromJson(commonModel.data['attributes']);
    return brokerSummary;
  }

  Future<BrokerSummaryDailyStatModel> getBrokerSummaryDailyStat(String code) async {
    // get the API response
    final String body = await NetUtils.get(
      url: '${Globals.apiBrokerSummary}/stat/daily/code/$code'
    ).onError((error, stackTrace) {
      throw Exception(error);
    });

    // parse the response to get the broker summary daily statistic
    CommonSingleModel commonModel = CommonSingleModel.fromJson(jsonDecode(body));
    BrokerSummaryDailyStatModel brokerSummary = BrokerSummaryDailyStatModel.fromJson(commonModel.data['attributes']);
    return brokerSummary;
  }

  Future<BrokerSummaryDailyStatModel> getBrokerSummaryMonthlyStat(String code) async {
    // get the API response
    final String body = await NetUtils.get(
      url: '${Globals.apiBrokerSummary}/stat/monthly/code/$code'
    ).onError((error, stackTrace) {
      throw Exception(error);
    });

    // parse the response to get the broker summary monthly statistic
    CommonSingleModel commonModel = CommonSingleModel.fromJson(jsonDecode(body));
    BrokerSummaryDailyStatModel brokerSummary = BrokerSummaryDailyStatModel.fromJson(commonModel.data['attributes']);
    return brokerSummary;
  }
}