import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:my_wealth/model/broker/broker_top_transaction_model.dart';
import 'package:my_wealth/model/common/common_array_model.dart';
import 'package:my_wealth/model/common/common_single_model.dart';
import 'package:my_wealth/model/index/index_beater_model.dart';
import 'package:my_wealth/model/insight/insight_bandar_interest_model.dart';
import 'package:my_wealth/model/insight/insight_accumulation_model.dart';
import 'package:my_wealth/model/insight/insight_broker_collect_model.dart';
import 'package:my_wealth/model/insight/insight_eps_model.dart';
import 'package:my_wealth/model/insight/insight_sideway_model.dart';
import 'package:my_wealth/model/insight/insight_market_cap_model.dart';
import 'package:my_wealth/model/insight/insight_market_today_model.dart';
import 'package:my_wealth/model/insight/insight_sector_summary_model.dart';
import 'package:my_wealth/model/insight/insight_stock_collect_model.dart';
import 'package:my_wealth/model/insight/insight_stock_dividend_list_model.dart';
import 'package:my_wealth/model/insight/insight_stock_new_listed_model.dart';
import 'package:my_wealth/model/insight/insight_stock_split_list_model.dart';
import 'package:my_wealth/model/insight/insight_top_worse_company_list_model.dart';
import 'package:my_wealth/utils/function/parse_error.dart';
import 'package:my_wealth/utils/globals.dart';
import 'package:my_wealth/storage/prefs/shared_user.dart';

class InsightAPI {
  late String _bearerToken;
  final DateFormat _df = DateFormat('yyyy-MM-dd');

  InsightAPI() {
    // get the bearer token from user shared secured box
    getJwt();
  }

  void getJwt() {
    _bearerToken = UserSharedPreferences.getUserJWT();
  }

  Future<List<SectorSummaryModel>> getSectorSummary() async {
    // if empty then we try to get again the bearer token from user preferences
    if (_bearerToken.isEmpty) {
      getJwt();
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

  Future<TopWorseCompanyListModel> getSectorSummaryList(String sectorName, String sortType) async {
    // if empty then we try to get again the bearer token from user preferences
    if (_bearerToken.isEmpty) {
      getJwt();
    }

    // check if we have bearer token or not?
    if (_bearerToken.isNotEmpty) {
      String sectorNameBase64 = base64.encode(utf8.encode(sectorName));
      final response = await http.get(
        Uri.parse('${Globals.apiURL}api/insight/summary/sectorname/$sectorNameBase64/list/$sortType'),
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

  Future<List<SectorSummaryModel>> getIndustrySummary(String sectorName) async {
    // if empty then we try to get again the bearer token from user preferences
    if (_bearerToken.isEmpty) {
      getJwt();
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
      getJwt();
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
      getJwt();
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
      getJwt();
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

  Future<TopWorseCompanyListModel> getTopWorseReksadana(String type, String topWorse) async {
    // if empty then we try to get again the bearer token from user preferences
    if (_bearerToken.isEmpty) {
      getJwt();
    }

    // check if we have bearer token or not?
    if (_bearerToken.isNotEmpty) {
      final response = await http.get(
        Uri.parse('${Globals.apiURL}api/insight/reksadana/$topWorse/type/$type'),
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
      getJwt();
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
      getJwt();
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

  Future<List<InsightEpsModel>> getTopEPS(int minDiff, int minDiffRate) async {
    // if empty then we try to get again the bearer token from user preferences
    if (_bearerToken.isEmpty) {
      getJwt();
    }

    // check if we have bearer token or not?
    if (_bearerToken.isNotEmpty) {
      final response = await http.get(
        Uri.parse('${Globals.apiURL}api/insight/eps/top/min/$minDiff/diff/$minDiffRate'),
        headers: {
          HttpHeaders.authorizationHeader: "Bearer $_bearerToken",
          'Content-Type': 'application/json',
        },
      );

      // check if we got 200 response or not?
      if (response.statusCode == 200) {
        // parse the response to get the data and process each one
        CommonArrayModel commonModel = CommonArrayModel.fromJson(jsonDecode(response.body));
        List<InsightEpsModel> epsList = [];
        for (var data in commonModel.data) {
          InsightEpsModel eps = InsightEpsModel.fromJson(data['attributes']);
          epsList.add(eps);
        }
        return epsList;
      }

      // status code is not 200, means we got error
      throw Exception(parseError(response.body).error.message);
    }
    else {
      throw Exception("No bearer token");
    }
  }

  Future<List<InsightSidewayModel>> getSideway(int maxOneDay, int oneDayRange, int oneWeekRange) async {
    // if empty then we try to get again the bearer token from user preferences
    if (_bearerToken.isEmpty) {
      getJwt();
    }

    // check if we have bearer token or not?
    if (_bearerToken.isNotEmpty) {
      final response = await http.get(
        Uri.parse('${Globals.apiURL}api/insight/sideway/oneday/$maxOneDay/onedayrange/$oneDayRange/oneweekrange/$oneWeekRange'),
        headers: {
          HttpHeaders.authorizationHeader: "Bearer $_bearerToken",
          'Content-Type': 'application/json',
        },
      );

      // check if we got 200 response or not?
      if (response.statusCode == 200) {
        // parse the response to get the data and process each one
        CommonArrayModel commonModel = CommonArrayModel.fromJson(jsonDecode(response.body));
        List<InsightSidewayModel> sidewayList = [];
        for (var data in commonModel.data) {
          InsightSidewayModel sideway = InsightSidewayModel.fromJson(data['attributes']);
          sidewayList.add(sideway);
        }
        return sidewayList;
      }

      // status code is not 200, means we got error
      throw Exception(parseError(response.body).error.message);
    }
    else {
      throw Exception("No bearer token");
    }
  }

  Future<MarketTodayModel> getMarketToday() async {
    // if empty then we try to get again the bearer token from user preferences
    if (_bearerToken.isEmpty) {
      getJwt();
    }

    // check if we have bearer token or not?
    if (_bearerToken.isNotEmpty) {
      final response = await http.get(
        Uri.parse('${Globals.apiURL}api/insight/markettoday'),
        headers: {
          HttpHeaders.authorizationHeader: "Bearer $_bearerToken",
          'Content-Type': 'application/json',
        },
      );

      // check if we got 200 response or not?
      if (response.statusCode == 200) {
        // parse the response to get the data and process each one
        CommonSingleModel commonModel = CommonSingleModel.fromJson(jsonDecode(response.body));
        MarketTodayModel marketToday = MarketTodayModel.fromJson(commonModel.data['attributes']);
        return marketToday;
      }

      // status code is not 200, means we got error
      throw Exception(parseError(response.body).error.message);
    }
    else {
      throw Exception("No bearer token");
    }
  }

  Future<List<MarketCapModel>> getMarketCap() async {
    // if empty then we try to get again the bearer token from user preferences
    if (_bearerToken.isEmpty) {
      getJwt();
    }

    // check if we have bearer token or not?
    if (_bearerToken.isNotEmpty) {
      final response = await http.get(
        Uri.parse('${Globals.apiURL}api/insight/marketcap'),
        headers: {
          HttpHeaders.authorizationHeader: "Bearer $_bearerToken",
          'Content-Type': 'application/json',
        },
      );

      // check if we got 200 response or not?
      if (response.statusCode == 200) {
        // parse the response to get the data and process each one
        CommonArrayModel commonModel = CommonArrayModel.fromJson(jsonDecode(response.body));
        List<MarketCapModel> marketCapList = [];
        for (var data in commonModel.data) {
          MarketCapModel marketCap = MarketCapModel.fromJson(data['attributes']);
          marketCapList.add(marketCap);
        }
        return marketCapList;
      }

      // status code is not 200, means we got error
      throw Exception(parseError(response.body).error.message);
    }
    else {
      throw Exception("No bearer token");
    }
  }

  Future<List<IndexBeaterModel>> getIndexBeater() async {
    // if empty then we try to get again the bearer token from user preferences
    if (_bearerToken.isEmpty) {
      getJwt();
    }

    // check if we have bearer token or not?
    if (_bearerToken.isNotEmpty) {
      final response = await http.get(
        Uri.parse('${Globals.apiURL}api/insight/indexbeater'),
        headers: {
          HttpHeaders.authorizationHeader: "Bearer $_bearerToken",
          'Content-Type': 'application/json',
        },
      );

      // check if we got 200 response or not?
      if (response.statusCode == 200) {
        // parse the response to get the data and process each one
        CommonArrayModel commonModel = CommonArrayModel.fromJson(jsonDecode(response.body));
        List<IndexBeaterModel> indexBeaterList = [];
        for (var data in commonModel.data) {
          IndexBeaterModel indexBeater = IndexBeaterModel.fromJson(data['attributes']);
          indexBeaterList.add(indexBeater);
        }
        return indexBeaterList;
      }

      // status code is not 200, means we got error
      throw Exception(parseError(response.body).error.message);
    }
    else {
      throw Exception("No bearer token");
    }
  }

  Future<List<StockNewListedModel>> getStockNewListed() async {
    // if empty then we try to get again the bearer token from user preferences
    if (_bearerToken.isEmpty) {
      getJwt();
    }

    // check if we have bearer token or not?
    if (_bearerToken.isNotEmpty) {
      final response = await http.get(
        Uri.parse('${Globals.apiURL}api/insight/stock/new'),
        headers: {
          HttpHeaders.authorizationHeader: "Bearer $_bearerToken",
          'Content-Type': 'application/json',
        },
      );

      // check if we got 200 response or not?
      if (response.statusCode == 200) {
        // parse the response to get the data and process each one
        CommonArrayModel commonModel = CommonArrayModel.fromJson(jsonDecode(response.body));
        List<StockNewListedModel> stockNewList = [];
        for (var data in commonModel.data) {
          StockNewListedModel stock = StockNewListedModel.fromJson(data['attributes']);
          stockNewList.add(stock);
        }
        return stockNewList;
      }

      // status code is not 200, means we got error
      throw Exception(parseError(response.body).error.message);
    }
    else {
      throw Exception("No bearer token");
    }
  }

  Future<List<StockDividendListModel>> getStockDividendList() async {
    // if empty then we try to get again the bearer token from user preferences
    if (_bearerToken.isEmpty) {
      getJwt();
    }

    // check if we have bearer token or not?
    if (_bearerToken.isNotEmpty) {
      final response = await http.get(
        Uri.parse('${Globals.apiURL}api/insight/stock/dividend'),
        headers: {
          HttpHeaders.authorizationHeader: "Bearer $_bearerToken",
          'Content-Type': 'application/json',
        },
      );

      // check if we got 200 response or not?
      if (response.statusCode == 200) {
        // parse the response to get the data and process each one
        CommonArrayModel commonModel = CommonArrayModel.fromJson(jsonDecode(response.body));
        List<StockDividendListModel> stockNewList = [];
        for (var data in commonModel.data) {
          StockDividendListModel stock = StockDividendListModel.fromJson(data['attributes']);
          stockNewList.add(stock);
        }
        return stockNewList;
      }

      // status code is not 200, means we got error
      throw Exception(parseError(response.body).error.message);
    }
    else {
      throw Exception("No bearer token");
    }
  }

  Future<List<StockSplitListModel>> getStockSplitList() async {
    // if empty then we try to get again the bearer token from user preferences
    if (_bearerToken.isEmpty) {
      getJwt();
    }

    // check if we have bearer token or not?
    if (_bearerToken.isNotEmpty) {
      final response = await http.get(
        Uri.parse('${Globals.apiURL}api/insight/stock/split'),
        headers: {
          HttpHeaders.authorizationHeader: "Bearer $_bearerToken",
          'Content-Type': 'application/json',
        },
      );

      // check if we got 200 response or not?
      if (response.statusCode == 200) {
        // parse the response to get the data and process each one
        CommonArrayModel commonModel = CommonArrayModel.fromJson(jsonDecode(response.body));
        List<StockSplitListModel> stockNewList = [];
        for (var data in commonModel.data) {
          StockSplitListModel stock = StockSplitListModel.fromJson(data['attributes']);
          stockNewList.add(stock);
        }
        return stockNewList;
      }

      // status code is not 200, means we got error
      throw Exception(parseError(response.body).error.message);
    }
    else {
      throw Exception("No bearer token");
    }
  }

  Future<List<InsightStockCollectModel>> getStockCollect([int? accumLimit, DateTime? dateFrom, DateTime? dateTo]) async {
    // if empty then we try to get again the bearer token from user preferences
    if (_bearerToken.isEmpty) {
      getJwt();
    }

    // check if we have bearer token or not?
    if (_bearerToken.isNotEmpty) {
      DateTime currentDateFrom = (dateFrom ?? DateTime.now().toLocal());
      DateTime currentDateTo = (dateTo ?? DateTime.now().toLocal());
      String dateFromString = _df.format(currentDateFrom);
      String dateToString = _df.format(currentDateTo);
      int currAccumLimit = (accumLimit ?? 75);

      final response = await http.get(
        Uri.parse('${Globals.apiURL}api/insight/stockcollect/accum/$currAccumLimit/from/$dateFromString/to/$dateToString'),
        headers: {
          HttpHeaders.authorizationHeader: "Bearer $_bearerToken",
          'Content-Type': 'application/json',
        },
      );

      // check if we got 200 response or not?
      if (response.statusCode == 200) {
        // parse the response to get the data and process each one
        CommonArrayModel commonModel = CommonArrayModel.fromJson(jsonDecode(response.body));
        List<InsightStockCollectModel> stockCollectList = [];
        for (var data in commonModel.data) {
          InsightStockCollectModel stock = InsightStockCollectModel.fromJson(data['attributes']);
          stockCollectList.add(stock);
        }
        return stockCollectList;
      }

      // status code is not 200, means we got error
      throw Exception(parseError(response.body).error.message);
    }
    else {
      throw Exception("No bearer token");
    }
  }

  Future<InsightBrokerCollectModel> getBrokerCollect(String broker, [int? accumLimit, DateTime? dateFrom, DateTime? dateTo]) async {
    // if empty then we try to get again the bearer token from user preferences
    if (_bearerToken.isEmpty) {
      getJwt();
    }

    // check if we have bearer token or not?
    if (_bearerToken.isNotEmpty) {
      DateTime currentDateFrom = (dateFrom ?? DateTime.now().toLocal());
      DateTime currentDateTo = (dateTo ?? DateTime.now().toLocal());
      String dateFromString = _df.format(currentDateFrom);
      String dateToString = _df.format(currentDateTo);
      int currAccumLimit = (accumLimit ?? 75);

      final response = await http.get(
        Uri.parse('${Globals.apiURL}api/insight/brokercollect/broker/$broker/accum/$currAccumLimit/from/$dateFromString/to/$dateToString'),
        headers: {
          HttpHeaders.authorizationHeader: "Bearer $_bearerToken",
          'Content-Type': 'application/json',
        },
      );

      // check if we got 200 response or not?
      if (response.statusCode == 200) {
        // parse the response to get the data and process each one
        CommonSingleModel commonModel = CommonSingleModel.fromJson(jsonDecode(response.body));
        InsightBrokerCollectModel brokerCollect = InsightBrokerCollectModel.fromJson(commonModel.data['attributes']);
        return brokerCollect;
      }

      // status code is not 200, means we got error
      throw Exception(parseError(response.body).error.message);
    }
    else {
      throw Exception("No bearer token");
    }
  }
}