import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:my_wealth/model/broker_summary_date_model.dart';
import 'package:my_wealth/model/broker_summary_broker_txn_list_model.dart';
import 'package:my_wealth/model/broker_summary_model.dart';
import 'package:my_wealth/model/broker_summary_top_model.dart';
import 'package:my_wealth/model/broker_summary_txn_detail_model.dart';
import 'package:my_wealth/model/common_single_model.dart';
import 'package:my_wealth/utils/function/parse_error.dart';
import 'package:my_wealth/utils/globals.dart';
import 'package:my_wealth/utils/prefs/shared_user.dart';

class BrokerSummaryAPI {
  late String _bearerToken;
  final DateFormat _df = DateFormat('yyyy-MM-dd');

  BrokerSummaryAPI() {
    // get the bearer token from user shared secured box
    _getJwt();
  }

  void _getJwt() {
    _bearerToken = UserSharedPreferences.getUserJWT();
  }

  Future<BrokerSummaryModel> getBrokerSummary(String stockCode, [DateTime? dateFrom, DateTime? dateTo]) async {
    // if empty then we try to get again the bearer token from user preferences
    if (_bearerToken.isEmpty) {
      _getJwt();
    }

    // check if we have bearer token or not?
    if (_bearerToken.isNotEmpty) {
      // check if we got date or not?
      DateTime currentDateFrom = (dateFrom ?? DateTime.now().toLocal());
      DateTime currentDateTo = (dateTo ?? DateTime.now().toLocal());
      String dateFromString = _df.format(currentDateFrom);
      String dateToString = _df.format(currentDateTo);

      final response = await http.get(
        Uri.parse('${Globals.apiURL}api/broker-summaries/code/$stockCode/from/$dateFromString/to/$dateToString'),
        headers: {
          HttpHeaders.authorizationHeader: "Bearer $_bearerToken",
          'Content-Type': 'application/json',
        },
      );

      // check if we got 200 response or not?
      if (response.statusCode == 200) {
        // parse the response to get the data and process each one
        CommonSingleModel commonModel = CommonSingleModel.fromJson(jsonDecode(response.body));
        BrokerSummaryModel brokerSummary = BrokerSummaryModel.fromJson(commonModel.data['attributes']);
        return brokerSummary;
      }

      // status code is not 200, means we got error
      throw Exception(parseError(response.body).error.message);
    }
    else {
      throw Exception("No bearer token");
    }
  }

  Future<BrokerSummaryModel> getBrokerSummaryNet(String stockCode, [DateTime? dateFrom, DateTime? dateTo]) async {
    // if empty then we try to get again the bearer token from user preferences
    if (_bearerToken.isEmpty) {
      _getJwt();
    }

    // check if we have bearer token or not?
    if (_bearerToken.isNotEmpty) {
      // check if we got date or not?
      DateTime currentDateFrom = (dateFrom ?? DateTime.now().toLocal());
      DateTime currentDateTo = (dateTo ?? DateTime.now().toLocal());
      String dateFromString = _df.format(currentDateFrom);
      String dateToString = _df.format(currentDateTo);

      final response = await http.get(
        Uri.parse('${Globals.apiURL}api/broker-summaries/net/code/$stockCode/from/$dateFromString/to/$dateToString'),
        headers: {
          HttpHeaders.authorizationHeader: "Bearer $_bearerToken",
          'Content-Type': 'application/json',
        },
      );

      // check if we got 200 response or not?
      if (response.statusCode == 200) {
        // parse the response to get the data and process each one
        CommonSingleModel commonModel = CommonSingleModel.fromJson(jsonDecode(response.body));
        BrokerSummaryModel brokerSummary = BrokerSummaryModel.fromJson(commonModel.data['attributes']);
        return brokerSummary;
      }

      // status code is not 200, means we got error
      throw Exception(parseError(response.body).error.message);
    }
    else {
      throw Exception("No bearer token");
    }
  }

  Future<BrokerSummaryBrokerTxnListModel> getBrokerTransactionList(String brokerCode, int start, int limit, [DateTime? dateFrom, DateTime? dateTo]) async {
    // if empty then we try to get again the bearer token from user preferences
    if (_bearerToken.isEmpty) {
      _getJwt();
    }

    // check if we have bearer token or not?
    if (_bearerToken.isNotEmpty) {
      // check if we got date or not?
      DateTime currentDateFrom = (dateFrom ?? DateTime.now().toLocal());
      DateTime currentDateTo = (dateTo ?? DateTime.now().toLocal());
      String dateFromString = _df.format(currentDateFrom);
      String dateToString = _df.format(currentDateTo);

      final response = await http.get(
        Uri.parse('${Globals.apiURL}api/broker-summaries/broker/$brokerCode/from/$dateFromString/to/$dateToString/start/$start/limit/$limit'),
        headers: {
          HttpHeaders.authorizationHeader: "Bearer $_bearerToken",
          'Content-Type': 'application/json',
        },
      );

      // check if we got 200 response or not?
      if (response.statusCode == 200) {
        // parse the response to get the data and process each one
        CommonSingleModel commonModel = CommonSingleModel.fromJson(jsonDecode(response.body));
        BrokerSummaryBrokerTxnListModel brokerTxnList = BrokerSummaryBrokerTxnListModel.fromJson(commonModel.data['attributes']);
        return brokerTxnList;
      }

      // status code is not 200, means we got error
      throw Exception(parseError(response.body).error.message);
    }
    else {
      throw Exception("No bearer token");
    }
  }

  Future<BrokerSummaryTxnDetailModel> getBrokerTransactionDetail(String brokerCode, String stockCode, [DateTime? dateFrom, DateTime? dateTo]) async {
    // if empty then we try to get again the bearer token from user preferences
    if (_bearerToken.isEmpty) {
      _getJwt();
    }

    // check if we have bearer token or not?
    if (_bearerToken.isNotEmpty) {
      // check if we got date or not?
      DateTime currentDateFrom = (dateFrom ?? DateTime.now().toLocal());
      DateTime currentDateTo = (dateTo ?? DateTime.now().toLocal());
      String dateFromString = _df.format(currentDateFrom);
      String dateToString = _df.format(currentDateTo);

      final response = await http.get(
        Uri.parse('${Globals.apiURL}api/broker-summaries/detail/broker/$brokerCode/code/$stockCode/from/$dateFromString/to/$dateToString'),
        headers: {
          HttpHeaders.authorizationHeader: "Bearer $_bearerToken",
          'Content-Type': 'application/json',
        },
      );

      // check if we got 200 response or not?
      if (response.statusCode == 200) {
        // parse the response to get the data and process each one
        CommonSingleModel commonModel = CommonSingleModel.fromJson(jsonDecode(response.body));
        BrokerSummaryTxnDetailModel brokerTxnDetail = BrokerSummaryTxnDetailModel.fromJson(commonModel.data['attributes']);
        return brokerTxnDetail;
      }

      // status code is not 200, means we got error
      throw Exception(parseError(response.body).error.message);
    }
    else {
      throw Exception("No bearer token");
    }
  }

  Future<BrokerSummaryTopModel> getBrokerSummaryTop([DateTime? searchDate]) async {
    // if empty then we try to get again the bearer token from user preferences
    if (_bearerToken.isEmpty) {
      _getJwt();
    }

    // check if we have bearer token or not?
    if (_bearerToken.isNotEmpty) {
      
      // check if we got date or not?
      String url = '';
      if (searchDate == null) {
        url = '${Globals.apiURL}api/broker-summaries/top/last';
      }
      else {
        String dateSearchText = _df.format(searchDate);
        url = '${Globals.apiURL}api/broker-summaries/top/date/$dateSearchText';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          HttpHeaders.authorizationHeader: "Bearer $_bearerToken",
          'Content-Type': 'application/json',
        },
      );

      // check if we got 200 response or not?
      if (response.statusCode == 200) {
        // parse the response to get the data and process each one
        CommonSingleModel commonModel = CommonSingleModel.fromJson(jsonDecode(response.body));
        BrokerSummaryTopModel brokerTopResult = BrokerSummaryTopModel.fromJson(commonModel.data['attributes']);
        return brokerTopResult;
      }

      // status code is not 200, means we got error
      throw Exception(parseError(response.body).error.message);
    }
    else {
      throw Exception("No bearer token");
    }
  }

  Future<BrokerSummaryDateModel> getBrokerSummaryCodeDate(String stockCode) async {
    // if empty then we try to get again the bearer token from user preferences
    if (_bearerToken.isEmpty) {
      _getJwt();
    }

    // check if we have bearer token or not?
    if (_bearerToken.isNotEmpty) {
      final response = await http.get(
        Uri.parse('${Globals.apiURL}api/broker-summaries/date/code/$stockCode'),
        headers: {
          HttpHeaders.authorizationHeader: "Bearer $_bearerToken",
          'Content-Type': 'application/json',
        },
      );

      // check if we got 200 response or not?
      if (response.statusCode == 200) {
        // parse the response to get the data and process each one
        CommonSingleModel commonModel = CommonSingleModel.fromJson(jsonDecode(response.body));
        BrokerSummaryDateModel brokerSummaryDate = BrokerSummaryDateModel.fromJson(commonModel.data['attributes']);
        return brokerSummaryDate;
      }

      // status code is not 200, means we got error
      throw Exception(parseError(response.body).error.message);
    }
    else {
      throw Exception("No bearer token");
    }
  }

  Future<BrokerSummaryDateModel> getBrokerSummaryBrokerDate(String brokerID) async {
    // if empty then we try to get again the bearer token from user preferences
    if (_bearerToken.isEmpty) {
      _getJwt();
    }

    // check if we have bearer token or not?
    if (_bearerToken.isNotEmpty) {
      final response = await http.get(
        Uri.parse('${Globals.apiURL}api/broker-summaries/date/broker/$brokerID'),
        headers: {
          HttpHeaders.authorizationHeader: "Bearer $_bearerToken",
          'Content-Type': 'application/json',
        },
      );

      // check if we got 200 response or not?
      if (response.statusCode == 200) {
        // parse the response to get the data and process each one
        CommonSingleModel commonModel = CommonSingleModel.fromJson(jsonDecode(response.body));
        BrokerSummaryDateModel brokerSummaryDate = BrokerSummaryDateModel.fromJson(commonModel.data['attributes']);
        return brokerSummaryDate;
      }

      // status code is not 200, means we got error
      throw Exception(parseError(response.body).error.message);
    }
    else {
      throw Exception("No bearer token");
    }
  }

  Future<BrokerSummaryDateModel> getBrokerSummaryDate() async {
    // if empty then we try to get again the bearer token from user preferences
    if (_bearerToken.isEmpty) {
      _getJwt();
    }

    // check if we have bearer token or not?
    if (_bearerToken.isNotEmpty) {
      final response = await http.get(
        Uri.parse('${Globals.apiURL}api/broker-summaries/date/all'),
        headers: {
          HttpHeaders.authorizationHeader: "Bearer $_bearerToken",
          'Content-Type': 'application/json',
        },
      );

      // check if we got 200 response or not?
      if (response.statusCode == 200) {
        // parse the response to get the data and process each one
        CommonSingleModel commonModel = CommonSingleModel.fromJson(jsonDecode(response.body));
        BrokerSummaryDateModel brokerSummaryDate = BrokerSummaryDateModel.fromJson(commonModel.data['attributes']);
        return brokerSummaryDate;
      }

      // status code is not 200, means we got error
      throw Exception(parseError(response.body).error.message);
    }
    else {
      throw Exception("No bearer token");
    }
  }
}