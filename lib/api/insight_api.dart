import 'dart:convert';
import 'package:my_wealth/_index.g.dart';

class InsightAPI {
  Future<List<SectorSummaryModel>> getSectorSummary() async {
    // get insight data using netutils
    final String body = await NetUtils.get(
      url: '${Globals.apiInsight}/summary/sector'
    ).onError((error, stackTrace) {
      Log.error(
        message: 'Error on getSectorSummary',
        error: error,
        stackTrace: stackTrace,
      );
      throw error as NetException;
    });

    // parse the response to get sector summart list
    CommonArrayModel commonModel = CommonArrayModel.fromJson(jsonDecode(body));
    List<SectorSummaryModel> sectorSummary = [];
    for (var data in commonModel.data) {
      SectorSummaryModel sector = SectorSummaryModel.fromJson(data['attributes']);
      sectorSummary.add(sector);
    }
    return sectorSummary;
  }

  Future<TopWorseCompanyListModel> getSectorSummaryList({
    required String sectorName,
    required String sortType
  }) async {
    // convert sector name into Base64
    String sectorNameBase64 = base64.encode(utf8.encode(sectorName));

    // get insight data using netutils
    final String body = await NetUtils.get(
      url: '${Globals.apiInsight}/summary/sectorname/$sectorNameBase64/list/$sortType'
    ).onError((error, stackTrace) {
      Log.error(
        message: 'Error on getSectorSummaryList',
        error: error,
        stackTrace: stackTrace,
      );
      throw error as NetException;
    });

    // parse the response to get company sector list
    CommonSingleModel commonModel = CommonSingleModel.fromJson(jsonDecode(body));
    TopWorseCompanyListModel companyList = TopWorseCompanyListModel.fromJson(commonModel.data['attributes']);
    return companyList;
  }

  Future<List<SectorSummaryModel>> getIndustrySummary({
    required String sectorName
  }) async {
    // convert sector name into Base64
    String sectorNameBase64 = base64.encode(utf8.encode(sectorName));

    // get insight data using netutils
    final String body = await NetUtils.get(
      url: '${Globals.apiInsight}/summary/industry/sectorname/$sectorNameBase64'
    ).onError((error, stackTrace) {
      Log.error(
        message: 'Error on getIndustrySummary',
        error: error,
        stackTrace: stackTrace,
      );
      throw error as NetException;
    });

    // parse the response to get sector summary based on their industry list
    CommonArrayModel commonModel = CommonArrayModel.fromJson(jsonDecode(body));
    List<SectorSummaryModel> sectorSummary = [];
    for (var data in commonModel.data) {
      SectorSummaryModel sector = SectorSummaryModel.fromJson(data['attributes']);
      sectorSummary.add(sector);
    }
    return sectorSummary;
  }

  Future<List<SectorSummaryModel>> getSubSectorSummary({
    required String sectorName
  }) async {
    // convert sector name to Base64
    String sectorNameBase64 = base64.encode(utf8.encode(sectorName));

    // get insight data using netutils
    final String body = await NetUtils.get(
      url: '${Globals.apiInsight}/summary/subsector/sectorname/$sectorNameBase64'
    ).onError((error, stackTrace) {
      Log.error(
        message: 'Error on getSubSectorSummary',
        error: error,
        stackTrace: stackTrace,
      );
      throw error as NetException;
    });

    // parse the response to get sector summary list based on sub sector
    CommonArrayModel commonModel = CommonArrayModel.fromJson(jsonDecode(body));
    List<SectorSummaryModel> sectorSummary = [];
    for (var data in commonModel.data) {
      SectorSummaryModel sector = SectorSummaryModel.fromJson(data['attributes']);
      sectorSummary.add(sector);
    }
    return sectorSummary;
  }

  Future<TopWorseCompanyListModel> getTopWorseCompany({
    required String type
  }) async {
    // get insight data using netutils
    final String body = await NetUtils.get(
      url: '${Globals.apiInsight}/stock/$type'
    ).onError((error, stackTrace) {
      Log.error(
        message: 'Error on getTopWorseCompany',
        error: error,
        stackTrace: stackTrace,
      );
      throw error as NetException;
    });

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
      Log.error(
        message: 'Error on getBrokerTopTransaction',
        error: error,
        stackTrace: stackTrace,
      );
      throw error as NetException;
    });

    // parse the response to broker top transaction list
    CommonSingleModel commonModel = CommonSingleModel.fromJson(jsonDecode(body));
    BrokerTopTransactionModel brokerList = BrokerTopTransactionModel.fromJson(commonModel.data['attributes']);
    return brokerList;
  }

  Future<TopWorseCompanyListModel> getTopWorseReksadana({
    required String type,
    required String topWorse
  }) async {
    // get insight data using netutils
    final String body = await NetUtils.get(
      url: '${Globals.apiInsight}/reksadana/$topWorse/type/$type'
    ).onError((error, stackTrace) {
      Log.error(
        message: 'Error on getTopWorseReksadana',
        error: error,
        stackTrace: stackTrace,
      );
      throw error as NetException;
    });

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
      Log.error(
        message: 'Error on getBandarInteresting',
        error: error,
        stackTrace: stackTrace,
      );
      throw error as NetException;
    });
    
    // parse the response to get interesting stock from bandar
    CommonSingleModel commonModel = CommonSingleModel.fromJson(jsonDecode(body));
    InsightBandarInterestModel interestList = InsightBandarInterestModel.fromJson(commonModel.data['attributes']);
    return interestList;
  }

  Future<List<InsightAccumulationModel>> getTopAccumulation({
    required int oneDayRate,
    required DateTime fromDate,
    required DateTime toDate
  }) async {
    // convert date
    final String dateFromString = Globals.dfyyyyMMdd.formatLocal(fromDate);
    final String dateToString = Globals.dfyyyyMMdd.formatLocal(toDate);

    // get insight data using netutils
    final String body = await NetUtils.get(
      url: '${Globals.apiInsight}/accumulation/oneday/$oneDayRate/from/$dateFromString/to/$dateToString'
    ).onError((error, stackTrace) {
      Log.error(
        message: 'Error on getTopAccumulation',
        error: error,
        stackTrace: stackTrace,
      );
      throw error as NetException;
    });

    // parse the response to get top accumulation for stock
    CommonArrayModel commonModel = CommonArrayModel.fromJson(jsonDecode(body));
    List<InsightAccumulationModel> accumulation = [];
    for (var data in commonModel.data) {
      InsightAccumulationModel acc = InsightAccumulationModel.fromJson(data['attributes']);
      accumulation.add(acc);
    }
    return accumulation;
  }

  Future<List<InsightEpsModel>> getTopEPS({
    required int minDiff,
    required int minDiffRate
  }) async {
    // get insight data using netutils
    final String body = await NetUtils.get(
      url: '${Globals.apiInsight}/eps/top/min/$minDiff/diff/$minDiffRate'
    ).onError((error, stackTrace) {
      Log.error(
        message: 'Error on getTopEPS',
        error: error,
        stackTrace: stackTrace,
      );
      throw error as NetException;
    });

    // parse the response to get EPS information list
    CommonArrayModel commonModel = CommonArrayModel.fromJson(jsonDecode(body));
    List<InsightEpsModel> epsList = [];
    for (var data in commonModel.data) {
      InsightEpsModel eps = InsightEpsModel.fromJson(data['attributes']);
      epsList.add(eps);
    }
    return epsList;
  }

  Future<List<InsightSidewayModel>> getSideway({
    required int maxOneDay,
    required int oneDayRange,
    required int oneWeekRange
  }) async {
    // get insight data using netutils
    final String body = await NetUtils.get(
      url: '${Globals.apiInsight}/sideway/oneday/$maxOneDay/onedayrange/$oneDayRange/oneweekrange/$oneWeekRange'
    ).onError((error, stackTrace) {
      Log.error(
        message: 'Error on getSideway',
        error: error,
        stackTrace: stackTrace,
      );
      throw error as NetException;
    });

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
      Log.error(
        message: 'Error on getMarketToday',
        error: error,
        stackTrace: stackTrace,
      );
      throw error as NetException;
    });

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
      Log.error(
        message: 'Error on getMarketCap',
        error: error,
        stackTrace: stackTrace,
      );
      throw error as NetException;
    });

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
      Log.error(
        message: 'Error on getIndexBeater',
        error: error,
        stackTrace: stackTrace,
      );
      throw error as NetException;
    });

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
      Log.error(
        message: 'Error on getStockNewListed',
        error: error,
        stackTrace: stackTrace,
      );
      throw error as NetException;
    });

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
      Log.error(
        message: 'Error on getStockDividendList',
        error: error,
        stackTrace: stackTrace,
      );
      throw error as NetException;
    });

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
      Log.error(
        message: 'Error on getStockSplitList',
        error: error,
        stackTrace: stackTrace,
      );
      throw error as NetException;
    });

    // parse the response to get the data and process each one
    CommonArrayModel commonModel = CommonArrayModel.fromJson(jsonDecode(body));
    List<StockSplitListModel> stockSplitList = [];
    for (var data in commonModel.data) {
      StockSplitListModel stock = StockSplitListModel.fromJson(data['attributes']);
      stockSplitList.add(stock);
    }
    return stockSplitList;
  }

  Future<List<InsightStockCollectModel>> getStockCollect({
    int accumLimit = 75,
    DateTime? dateFrom,
    DateTime? dateTo
  }) async {
    // prepare all necessary data/information
    final DateTime currentDateFrom = (dateFrom ?? DateTime.now());
    final DateTime currentDateTo = (dateTo ?? DateTime.now());
    final String dateFromString = Globals.dfyyyyMMdd.formatLocal(currentDateFrom);
    final String dateToString = Globals.dfyyyyMMdd.formatLocal(currentDateTo);
    
    // get insight data using netutils
    final String body = await NetUtils.get(
      url: '${Globals.apiInsight}/stockcollect/accum/$accumLimit/from/$dateFromString/to/$dateToString'
    ).onError((error, stackTrace) {
      Log.error(
        message: 'Error on getStockCollect',
        error: error,
        stackTrace: stackTrace,
      );
      throw error as NetException;
    });

    // parse the response to get the stock collection information list
    CommonArrayModel commonModel = CommonArrayModel.fromJson(jsonDecode(body));
    List<InsightStockCollectModel> stockCollectList = [];
    for (var data in commonModel.data) {
      InsightStockCollectModel stock = InsightStockCollectModel.fromJson(data['attributes']);
      stockCollectList.add(stock);
    }
    return stockCollectList;
  }

  Future<InsightBrokerCollectModel> getBrokerCollect({
    required String broker,
    int accumLimit = 75,
    DateTime? dateFrom,
    DateTime? dateTo
  }) async {
    // prepare all necessary data/information
    DateTime currentDateFrom = (dateFrom ?? DateTime.now());
    DateTime currentDateTo = (dateTo ?? DateTime.now());
    String dateFromString = Globals.dfyyyyMMdd.formatLocal(currentDateFrom);
    String dateToString = Globals.dfyyyyMMdd.formatLocal(currentDateTo);

    // get insight data using netutils
    final String body = await NetUtils.get(
      url: '${Globals.apiInsight}/brokercollect/broker/$broker/accum/$accumLimit/from/$dateFromString/to/$dateToString'
    ).onError((error, stackTrace) {
      Log.error(
        message: 'Error on getBrokerCollect',
        error: error,
        stackTrace: stackTrace,
      );
      throw error as NetException;
    });

    // parse the response to get stock that currently being collected by broker
    CommonSingleModel commonModel = CommonSingleModel.fromJson(jsonDecode(body));
    InsightBrokerCollectModel brokerCollect = InsightBrokerCollectModel.fromJson(commonModel.data['attributes']);
    return brokerCollect;
  }
}