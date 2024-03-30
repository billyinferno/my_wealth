import 'dart:convert';
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
import 'package:my_wealth/utils/globals.dart';
import 'package:my_wealth/utils/net/netutils.dart';

class InsightAPI {
  Future<List<SectorSummaryModel>> getSectorSummary() async {
    // get insight data using netutils
    final String body = await NetUtils.get(
      url: '${Globals.apiInsight}/summary/sector'
    ).onError((error, stackTrace) {
        throw Exception(error);
      }
    );

    // parse the response to get sector summart list
    CommonArrayModel commonModel = CommonArrayModel.fromJson(jsonDecode(body));
    List<SectorSummaryModel> sectorSummary = [];
    for (var data in commonModel.data) {
      SectorSummaryModel sector = SectorSummaryModel.fromJson(data['attributes']);
      sectorSummary.add(sector);
    }
    return sectorSummary;
  }

  Future<TopWorseCompanyListModel> getSectorSummaryList(String sectorName, String sortType) async {
    // convert sector name into Base64
    String sectorNameBase64 = base64.encode(utf8.encode(sectorName));

    // get insight data using netutils
    final String body = await NetUtils.get(
      url: '${Globals.apiInsight}/summary/sectorname/$sectorNameBase64/list/$sortType'
    ).onError((error, stackTrace) {
        throw Exception(error);
      }
    );

    // parse the response to get company sector list
    CommonSingleModel commonModel = CommonSingleModel.fromJson(jsonDecode(body));
    TopWorseCompanyListModel companyList = TopWorseCompanyListModel.fromJson(commonModel.data['attributes']);
    return companyList;
  }

  Future<List<SectorSummaryModel>> getIndustrySummary(String sectorName) async {
    // convert sector name into Base64
    String sectorNameBase64 = base64.encode(utf8.encode(sectorName));

    // get insight data using netutils
    final String body = await NetUtils.get(
      url: '${Globals.apiInsight}/summary/industry/sectorname/$sectorNameBase64'
    ).onError((error, stackTrace) {
        throw Exception(error);
      }
    );

    // parse the response to get sector summary based on their industry list
    CommonArrayModel commonModel = CommonArrayModel.fromJson(jsonDecode(body));
    List<SectorSummaryModel> sectorSummary = [];
    for (var data in commonModel.data) {
      SectorSummaryModel sector = SectorSummaryModel.fromJson(data['attributes']);
      sectorSummary.add(sector);
    }
    return sectorSummary;
  }

  Future<List<SectorSummaryModel>> getSubSectorSummary(String sectorName) async {
    // convert sector name to Base64
    String sectorNameBase64 = base64.encode(utf8.encode(sectorName));

    // get insight data using netutils
    final String body = await NetUtils.get(
      url: '${Globals.apiInsight}/summary/subsector/sectorname/$sectorNameBase64'
    ).onError((error, stackTrace) {
        throw Exception(error);
      }
    );

    // parse the response to get sector summary list based on sub sector
    CommonArrayModel commonModel = CommonArrayModel.fromJson(jsonDecode(body));
    List<SectorSummaryModel> sectorSummary = [];
    for (var data in commonModel.data) {
      SectorSummaryModel sector = SectorSummaryModel.fromJson(data['attributes']);
      sectorSummary.add(sector);
    }
    return sectorSummary;
  }

  Future<TopWorseCompanyListModel> getTopWorseCompany(String type) async {
    // get insight data using netutils
    final String body = await NetUtils.get(
      url: '${Globals.apiInsight}/stock/$type'
    ).onError((error, stackTrace) {
        throw Exception(error);
      }
    );

    // parse the response to get top and worse company data
    CommonSingleModel commonModel = CommonSingleModel.fromJson(jsonDecode(body));
    TopWorseCompanyListModel companyList = TopWorseCompanyListModel.fromJson(commonModel.data['attributes']);
    return companyList;
  }

  Future<BrokerTopTransactionModel> getBrokerTopTransaction() async {
    // get insight data using netutils
    final String body = await NetUtils.get(
      url: '${Globals.apiInsight}/broker/top'
    ).onError((error, stackTrace) {
        throw Exception(error);
      }
    );

    // parse the response to broker top transaction list
    CommonSingleModel commonModel = CommonSingleModel.fromJson(jsonDecode(body));
    BrokerTopTransactionModel brokerList = BrokerTopTransactionModel.fromJson(commonModel.data['attributes']);
    return brokerList;
  }

  Future<TopWorseCompanyListModel> getTopWorseReksadana(String type, String topWorse) async {
    // get insight data using netutils
    final String body = await NetUtils.get(
      url: '${Globals.apiInsight}/reksadana/$topWorse/type/$type'
    ).onError((error, stackTrace) {
        throw Exception(error);
      }
    );

    // parse the response to get reksdana top and worse company
    CommonSingleModel commonModel = CommonSingleModel.fromJson(jsonDecode(body));
    TopWorseCompanyListModel companyList = TopWorseCompanyListModel.fromJson(commonModel.data['attributes']);
    return companyList;
  }

  Future<InsightBandarInterestModel> getBandarInteresting() async {
    // get insight data using netutils
    final String body = await NetUtils.get(
      url: '${Globals.apiInsight}/bandar/interesting'
    ).onError((error, stackTrace) {
        throw Exception(error);
      }
    );
    
    // parse the response to get interesting stock from bandar
    CommonSingleModel commonModel = CommonSingleModel.fromJson(jsonDecode(body));
    InsightBandarInterestModel interestList = InsightBandarInterestModel.fromJson(commonModel.data['attributes']);
    return interestList;
  }

  Future<List<InsightAccumulationModel>> getTopAccumulation(int oneDayRate, DateTime fromDate, DateTime toDate) async {
    // convert date
    final String dateFromString = Globals.dfyyyyMMdd.format(fromDate.toLocal());
    final String dateToString = Globals.dfyyyyMMdd.format(toDate.toLocal());

    // get insight data using netutils
    final String body = await NetUtils.get(
      url: '${Globals.apiInsight}/accumulation/oneday/$oneDayRate/from/$dateFromString/to/$dateToString'
    ).onError((error, stackTrace) {
        throw Exception(error);
      }
    );

    // parse the response to get top accumulation for stock
    CommonArrayModel commonModel = CommonArrayModel.fromJson(jsonDecode(body));
    List<InsightAccumulationModel> accumulation = [];
    for (var data in commonModel.data) {
      InsightAccumulationModel acc = InsightAccumulationModel.fromJson(data['attributes']);
      accumulation.add(acc);
    }
    return accumulation;
  }

  Future<List<InsightEpsModel>> getTopEPS(int minDiff, int minDiffRate) async {
    // get insight data using netutils
    final String body = await NetUtils.get(
      url: '${Globals.apiInsight}/eps/top/min/$minDiff/diff/$minDiffRate'
    ).onError((error, stackTrace) {
        throw Exception(error);
      }
    );

    // parse the response to get EPS information list
    CommonArrayModel commonModel = CommonArrayModel.fromJson(jsonDecode(body));
    List<InsightEpsModel> epsList = [];
    for (var data in commonModel.data) {
      InsightEpsModel eps = InsightEpsModel.fromJson(data['attributes']);
      epsList.add(eps);
    }
    return epsList;
  }

  Future<List<InsightSidewayModel>> getSideway(int maxOneDay, int oneDayRange, int oneWeekRange) async {
    // get insight data using netutils
    final String body = await NetUtils.get(
      url: '${Globals.apiInsight}/sideway/oneday/$maxOneDay/onedayrange/$oneDayRange/oneweekrange/$oneWeekRange'
    ).onError((error, stackTrace) {
        throw Exception(error);
      }
    );

    // parse the response to get stock that currently in sideway position
    CommonArrayModel commonModel = CommonArrayModel.fromJson(jsonDecode(body));
    List<InsightSidewayModel> sidewayList = [];
    for (var data in commonModel.data) {
      InsightSidewayModel sideway = InsightSidewayModel.fromJson(data['attributes']);
      sidewayList.add(sideway);
    }
    return sidewayList;
  }

  Future<MarketTodayModel> getMarketToday() async {
    // get insight data using netutils
    final String body = await NetUtils.get(
      url: '${Globals.apiInsight}/markettoday'
    ).onError((error, stackTrace) {
        throw Exception(error);
      }
    );

    // parse the response to get market today information
    CommonSingleModel commonModel = CommonSingleModel.fromJson(jsonDecode(body));
    MarketTodayModel marketToday = MarketTodayModel.fromJson(commonModel.data['attributes']);
    return marketToday;
  }

  Future<List<MarketCapModel>> getMarketCap() async {
    // get insight data using netutils
    final String body = await NetUtils.get(
      url: '${Globals.apiInsight}/marketcap'
    ).onError((error, stackTrace) {
        throw Exception(error);
      }
    );

    // parse the response to get market cap from stock
    CommonArrayModel commonModel = CommonArrayModel.fromJson(jsonDecode(body));
    List<MarketCapModel> marketCapList = [];
    for (var data in commonModel.data) {
      MarketCapModel marketCap = MarketCapModel.fromJson(data['attributes']);
      marketCapList.add(marketCap);
    }
    return marketCapList;
  }

  Future<List<IndexBeaterModel>> getIndexBeater() async {
    // get insight data using netutils
    final String body = await NetUtils.get(
      url: '${Globals.apiInsight}/indexbeater'
    ).onError((error, stackTrace) {
        throw Exception(error);
      }
    );

    // parse the response to get all stock code that get return better than
    // index.
    CommonArrayModel commonModel = CommonArrayModel.fromJson(jsonDecode(body));
    List<IndexBeaterModel> indexBeaterList = [];
    for (var data in commonModel.data) {
      IndexBeaterModel indexBeater = IndexBeaterModel.fromJson(data['attributes']);
      indexBeaterList.add(indexBeater);
    }
    return indexBeaterList;
  }

  Future<List<StockNewListedModel>> getStockNewListed() async {
    // get insight data using netutils
    final String body = await NetUtils.get(
      url: '${Globals.apiInsight}/stock/new'
    ).onError((error, stackTrace) {
        throw Exception(error);
      }
    );

    // parse the response to get all the new stock
    CommonArrayModel commonModel = CommonArrayModel.fromJson(jsonDecode(body));
    List<StockNewListedModel> stockNewList = [];
    for (var data in commonModel.data) {
      StockNewListedModel stock = StockNewListedModel.fromJson(data['attributes']);
      stockNewList.add(stock);
    }
    return stockNewList;
  }

  Future<List<StockDividendListModel>> getStockDividendList() async {
    // get insight data using netutils
    final String body = await NetUtils.get(
      url: '${Globals.apiInsight}/stock/dividend'
    ).onError((error, stackTrace) {
        throw Exception(error);
      }
    );

    // parse the response to get dividend information that currently
    // bein distributed
    CommonArrayModel commonModel = CommonArrayModel.fromJson(jsonDecode(body));
    List<StockDividendListModel> stockDividedList = [];
    for (var data in commonModel.data) {
      StockDividendListModel stock = StockDividendListModel.fromJson(data['attributes']);
      stockDividedList.add(stock);
    }
    return stockDividedList;
  }

  Future<List<StockSplitListModel>> getStockSplitList() async {
    // get insight data using netutils
    final String body = await NetUtils.get(
      url: '${Globals.apiInsight}/stock/split'
    ).onError((error, stackTrace) {
        throw Exception(error);
      }
    );

    // parse the response to get the data and process each one
    CommonArrayModel commonModel = CommonArrayModel.fromJson(jsonDecode(body));
    List<StockSplitListModel> stockSplitList = [];
    for (var data in commonModel.data) {
      StockSplitListModel stock = StockSplitListModel.fromJson(data['attributes']);
      stockSplitList.add(stock);
    }
    return stockSplitList;
  }

  Future<List<InsightStockCollectModel>> getStockCollect([int? accumLimit, DateTime? dateFrom, DateTime? dateTo]) async {
    // prepare all necessary data/information
    final DateTime currentDateFrom = (dateFrom ?? DateTime.now().toLocal());
    final DateTime currentDateTo = (dateTo ?? DateTime.now().toLocal());
    final String dateFromString = Globals.dfyyyyMMdd.format(currentDateFrom);
    final String dateToString = Globals.dfyyyyMMdd.format(currentDateTo);
    final int currAccumLimit = (accumLimit ?? 75);
    
    // get insight data using netutils
    final String body = await NetUtils.get(
      url: '${Globals.apiInsight}/stockcollect/accum/$currAccumLimit/from/$dateFromString/to/$dateToString'
    ).onError((error, stackTrace) {
        throw Exception(error);
      }
    );

    // parse the response to get the stock collection information list
    CommonArrayModel commonModel = CommonArrayModel.fromJson(jsonDecode(body));
    List<InsightStockCollectModel> stockCollectList = [];
    for (var data in commonModel.data) {
      InsightStockCollectModel stock = InsightStockCollectModel.fromJson(data['attributes']);
      stockCollectList.add(stock);
    }
    return stockCollectList;
  }

  Future<InsightBrokerCollectModel> getBrokerCollect(String broker, [int? accumLimit, DateTime? dateFrom, DateTime? dateTo]) async {
    // prepare all necessary data/information
    DateTime currentDateFrom = (dateFrom ?? DateTime.now().toLocal());
    DateTime currentDateTo = (dateTo ?? DateTime.now().toLocal());
    String dateFromString = Globals.dfyyyyMMdd.format(currentDateFrom);
    String dateToString = Globals.dfyyyyMMdd.format(currentDateTo);
    int currAccumLimit = (accumLimit ?? 75);

    // get insight data using netutils
    final String body = await NetUtils.get(
      url: '${Globals.apiInsight}/brokercollect/broker/$broker/accum/$currAccumLimit/from/$dateFromString/to/$dateToString'
    ).onError((error, stackTrace) {
        throw Exception(error);
      }
    );

    // parse the response to get stock that currently being collected by broker
    CommonSingleModel commonModel = CommonSingleModel.fromJson(jsonDecode(body));
    InsightBrokerCollectModel brokerCollect = InsightBrokerCollectModel.fromJson(commonModel.data['attributes']);
    return brokerCollect;
  }
}