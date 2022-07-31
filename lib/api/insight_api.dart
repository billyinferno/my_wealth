import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:my_wealth/model/broker_top_transaction_model.dart';
import 'package:my_wealth/model/common_array_model.dart';
import 'package:my_wealth/model/common_single_model.dart';
import 'package:my_wealth/model/inisght_bandar_interest_model.dart';
import 'package:my_wealth/model/insight_accumulation_model.dart';
import 'package:my_wealth/model/sector_summary_model.dart';
import 'package:my_wealth/model/top_worse_company_list_model.dart';
import 'package:my_wealth/utils/function/parse_error.dart';
import 'package:my_wealth/utils/globals.dart';
import 'package:my_wealth/utils/prefs/shared_user.dart';

class InsightAPI {
  late String _bearerToken;
  final DateFormat _df = DateFormat('yyyy-MM-dd');

  InsightAPI() {
    // get the bearer token from user shared secured box
    _getJwt();
  }

  void _getJwt() {
    _bearerToken = UserSharedPreferences.getUserJWT();
  }

  Future<List<SectorSummaryModel>> getSectorSummary() async {
    // if empty then we try to get again the bearer token from user preferences
    if (_bearerToken.isEmpty) {
      _getJwt();
    }

    // check if we have bearer token or not?
    if (_bearerToken.isNotEmpty) {
      final response = await http.get(
        Uri.parse('${Globals.apiURL}api/insight/summary/sector'),
        headers: {
          HttpHeaders.authorizationHeader: "Bearer $_bearerToken",
          'Content-Type': 'application/json',
        },
      );

      // check if we got 200 response or not?
      if (response.statusCode == 200) {
        // parse the response to get the data and process each one
        CommonArrayModel commonModel = CommonArrayModel.fromJson(jsonDecode(response.body));
        List<SectorSummaryModel> sectorSummary = [];
        for (var data in commonModel.data) {
          SectorSummaryModel sector = SectorSummaryModel.fromJson(data['attributes']);
          sectorSummary.add(sector);
        }
        return sectorSummary;
      }

      // status code is not 200, means we got error
      throw Exception(parseError(response.body).error.message);
    }
    else {
      throw Exception("No bearer token");
    }
  }

  Future<List<SectorSummaryModel>> getIndustrySummary(String sectorName) async {
    // if empty then we try to get again the bearer token from user preferences
    if (_bearerToken.isEmpty) {
      _getJwt();
    }

    // check if we have bearer token or not?
    if (_bearerToken.isNotEmpty) {
      // convert sector name to Base64
      String sectorNameBase64 = base64.encode(utf8.encode(sectorName));
      final response = await http.get(
        Uri.parse('${Globals.apiURL}api/insight/summary/industry/sectorname/$sectorNameBase64'),
        headers: {
          HttpHeaders.authorizationHeader: "Bearer $_bearerToken",
          'Content-Type': 'application/json',
        },
      );

      // check if we got 200 response or not?
      if (response.statusCode == 200) {
        // parse the response to get the data and process each one
        CommonArrayModel commonModel = CommonArrayModel.fromJson(jsonDecode(response.body));
        List<SectorSummaryModel> sectorSummary = [];
        for (var data in commonModel.data) {
          SectorSummaryModel sector = SectorSummaryModel.fromJson(data['attributes']);
          sectorSummary.add(sector);
        }
        return sectorSummary;
      }

      // status code is not 200, means we got error
      throw Exception(parseError(response.body).error.message);
    }
    else {
      throw Exception("No bearer token");
    }
  }

  Future<List<SectorSummaryModel>> getSubSectorSummary(String sectorName) async {
    // if empty then we try to get again the bearer token from user preferences
    if (_bearerToken.isEmpty) {
      _getJwt();
    }

    // check if we have bearer token or not?
    if (_bearerToken.isNotEmpty) {
      // convert sector name to Base64
      String sectorNameBase64 = base64.encode(utf8.encode(sectorName));
      final response = await http.get(
        Uri.parse('${Globals.apiURL}api/insight/summary/subsector/sectorname/$sectorNameBase64'),
        headers: {
          HttpHeaders.authorizationHeader: "Bearer $_bearerToken",
          'Content-Type': 'application/json',
        },
      );

      // check if we got 200 response or not?
      if (response.statusCode == 200) {
        // parse the response to get the data and process each one
        CommonArrayModel commonModel = CommonArrayModel.fromJson(jsonDecode(response.body));
        List<SectorSummaryModel> sectorSummary = [];
        for (var data in commonModel.data) {
          SectorSummaryModel sector = SectorSummaryModel.fromJson(data['attributes']);
          sectorSummary.add(sector);
        }
        return sectorSummary;
      }

      // status code is not 200, means we got error
      throw Exception(parseError(response.body).error.message);
    }
    else {
      throw Exception("No bearer token");
    }
  }

  Future<TopWorseCompanyListModel> getTopWorseCompany(String type) async {
    // if empty then we try to get again the bearer token from user preferences
    if (_bearerToken.isEmpty) {
      _getJwt();
    }

    // check if we have bearer token or not?
    if (_bearerToken.isNotEmpty) {
      final response = await http.get(
        Uri.parse('${Globals.apiURL}api/insight/stock/$type'),
        headers: {
          HttpHeaders.authorizationHeader: "Bearer $_bearerToken",
          'Content-Type': 'application/json',
        },
      );

      // check if we got 200 response or not?
      if (response.statusCode == 200) {
        // parse the response to get the data and process each one
        CommonSingleModel commonModel = CommonSingleModel.fromJson(jsonDecode(response.body));
        TopWorseCompanyListModel companyList = TopWorseCompanyListModel.fromJson(commonModel.data['attributes']);
        return companyList;
      }

      // status code is not 200, means we got error
      throw Exception(parseError(response.body).error.message);
    }
    else {
      throw Exception("No bearer token");
    }
  }

  Future<BrokerTopTransactionModel> getBrokerTopTransaction() async {
    // if empty then we try to get again the bearer token from user preferences
    if (_bearerToken.isEmpty) {
      _getJwt();
    }

    // check if we have bearer token or not?
    if (_bearerToken.isNotEmpty) {
      final response = await http.get(
        Uri.parse('${Globals.apiURL}api/insight/broker/top'),
        headers: {
          HttpHeaders.authorizationHeader: "Bearer $_bearerToken",
          'Content-Type': 'application/json',
        },
      );

      // check if we got 200 response or not?
      if (response.statusCode == 200) {
        // parse the response to get the data and process each one
        CommonSingleModel commonModel = CommonSingleModel.fromJson(jsonDecode(response.body));
        BrokerTopTransactionModel brokerList = BrokerTopTransactionModel.fromJson(commonModel.data['attributes']);
        return brokerList;
      }

      // status code is not 200, means we got error
      throw Exception(parseError(response.body).error.message);
    }
    else {
      throw Exception("No bearer token");
    }
  }

  Future<TopWorseCompanyListModel> getTopReksadana(String type) async {
    // if empty then we try to get again the bearer token from user preferences
    if (_bearerToken.isEmpty) {
      _getJwt();
    }

    // check if we have bearer token or not?
    if (_bearerToken.isNotEmpty) {
      final response = await http.get(
        Uri.parse('${Globals.apiURL}api/insight/reksadana/top/type/$type'),
        headers: {
          HttpHeaders.authorizationHeader: "Bearer $_bearerToken",
          'Content-Type': 'application/json',
        },
      );

      // check if we got 200 response or not?
      if (response.statusCode == 200) {
        // parse the response to get the data and process each one
        CommonSingleModel commonModel = CommonSingleModel.fromJson(jsonDecode(response.body));
        TopWorseCompanyListModel companyList = TopWorseCompanyListModel.fromJson(commonModel.data['attributes']);
        return companyList;
      }

      // status code is not 200, means we got error
      throw Exception(parseError(response.body).error.message);
    }
    else {
      throw Exception("No bearer token");
    }
  }

  Future<InsightBandarInterestModel> getBandarInteresting() async {
    // if empty then we try to get again the bearer token from user preferences
    if (_bearerToken.isEmpty) {
      _getJwt();
    }

    // check if we have bearer token or not?
    if (_bearerToken.isNotEmpty) {
      final response = await http.get(
        Uri.parse('${Globals.apiURL}api/insight/bandar/interesting'),
        headers: {
          HttpHeaders.authorizationHeader: "Bearer $_bearerToken",
          'Content-Type': 'application/json',
        },
      );

      // check if we got 200 response or not?
      if (response.statusCode == 200) {
        // parse the response to get the data and process each one
        CommonSingleModel commonModel = CommonSingleModel.fromJson(jsonDecode(response.body));
        InsightBandarInterestModel interestList = InsightBandarInterestModel.fromJson(commonModel.data['attributes']);
        return interestList;
      }

      // status code is not 200, means we got error
      throw Exception(parseError(response.body).error.message);
    }
    else {
      throw Exception("No bearer token");
    }
  }

  Future<List<InsightAccumulationModel>> getTopAccumulation(int oneDayRate, DateTime fromDate, DateTime toDate) async {
    // if empty then we try to get again the bearer token from user preferences
    if (_bearerToken.isEmpty) {
      _getJwt();
    }

    // check if we have bearer token or not?
    if (_bearerToken.isNotEmpty) {
      String dateFromString = _df.format(fromDate.toLocal());
      String dateToString = _df.format(toDate.toLocal());

      final response = await http.get(
        Uri.parse('${Globals.apiURL}api/insight/accumulation/oneday/$oneDayRate/from/$dateFromString/to/$dateToString'),
        headers: {
          HttpHeaders.authorizationHeader: "Bearer $_bearerToken",
          'Content-Type': 'application/json',
        },
      );

      // check if we got 200 response or not?
      if (response.statusCode == 200) {
        // parse the response to get the data and process each one
        CommonArrayModel commonModel = CommonArrayModel.fromJson(jsonDecode(response.body));
        List<InsightAccumulationModel> accumulation = [];
        for (var data in commonModel.data) {
          InsightAccumulationModel acc = InsightAccumulationModel.fromJson(data['attributes']);
          accumulation.add(acc);
        }
        return accumulation;
      }

      // status code is not 200, means we got error
      throw Exception(parseError(response.body).error.message);
    }
    else {
      throw Exception("No bearer token");
    }
  }
}