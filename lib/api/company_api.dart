import 'dart:convert';
import 'package:my_wealth/_index.g.dart';

class CompanyAPI {
  Future<List<CompanyListModel>> findCompany({
    required String type
  }) async {
    // first check whether we already have this company on the cache or not?
    List<CompanyListModel> ret = CompanySharedPreferences.getCompanyList(type: type);

    // check if ret is empty or not?
    if (ret.isEmpty) {
      // get the company data using netutils
      final String body = await NetUtils.get(
        url: '${Globals.apiCompanies}/type/${type.toLowerCase()}'
      ).onError((error, stackTrace) {
        Log.error(
          message: 'Error on findCompany',
          error: error,
          stackTrace: stackTrace,
        );
        throw error as NetException;
      });

      // parse the response to get the data and process each one
      CommonArrayModel commonModel = CommonArrayModel.fromJson(jsonDecode(body));
      for (dynamic data in commonModel.data) {
        // convert the attributes data to company list model
        CompanyListModel company = CompanyListModel.fromJson(data['attributes']);
        ret.add(company);
      }

      // stored the company list on the cache
      CompanySharedPreferences.setCompanyList(type: type, list: ret);
    }

    // return the company list
    return ret;
  }

  Future<CompanyDetailModel> getCompanyDetail({
    required int companyId,
    required String type,
  }) async {
    // get the company data using netutils
    final String body = await NetUtils.get(
      url: '${Globals.apiCompanies}/${type.toLowerCase()}/detail/$companyId'
    ).onError((error, stackTrace) {
      Log.error(
        message: 'Error on getCompanyDetail',
        error: error,
        stackTrace: stackTrace,
      );
      throw error as NetException;
    });

    // parse the response to get the detail company information
    CommonArrayModel commonModel = CommonArrayModel.fromJson(jsonDecode(body));
    if (commonModel.data.length == 1) {
      dynamic data = commonModel.data[0];
      CompanyDetailModel company = CompanyDetailModel.fromJson(data['attributes']);
      return company;
    }
    else {
      throw 'Invalid company detail data';
    }
  }

  Future<List<CompanySearchModel>> getCompanyByName({
    required String companyName,
    required String type
  }) async {
    // get the company data using netutils
    final String body = await NetUtils.get(
      url: '${Globals.apiCompanies}/$type/name/${companyName.toLowerCase()}'
    ).onError((error, stackTrace) {
      Log.error(
        message: 'Error on getCompanyByName',
        error: error,
        stackTrace: stackTrace,
      );
      throw error as NetException;
    });

    // parse the response to get the company search result
    CommonArrayModel commonModel = CommonArrayModel.fromJson(jsonDecode(body));
    List<CompanySearchModel> ret = [];
    for (dynamic data in commonModel.data) {
      CompanySearchModel company = CompanySearchModel.fromJson(data['attributes']);
      ret.add(company);
    }
    return ret;
  }

  Future<List<CompanySearchModel>> getCompanyList({
    required String type
  }) async {
    // check if company search resul for this type is already in the cache or not?
    List<CompanySearchModel> ret = CompanySharedPreferences.getCompanySearch(type: type);

    // check whether the cache data is empty or not?
    if (ret.isEmpty) {
      // get the company data using netutils
      final String body = await NetUtils.get(
        url: '${Globals.apiCompanies}/list/$type'
      ).onError((error, stackTrace) {
        Log.error(
          message: 'Error on getCompanyList',
          error: error,
          stackTrace: stackTrace,
        );
        throw error as NetException;
      });

      // parse the response to get the company search result
      CommonArrayModel commonModel = CommonArrayModel.fromJson(jsonDecode(body));
      for (dynamic data in commonModel.data) {
        CompanySearchModel company = CompanySearchModel.fromJson(data['attributes']);
        ret.add(company);
      }

      // stored the company search result data in the cache
      CompanySharedPreferences.setCompanySearch(type: type, companies: ret);
    }

    return ret;
  }

  Future<CompanyDetailModel> getCompanyByID({
    required int companyId,
    required String type
  }) async {
    // get the company data using netutils
    final String body = await NetUtils.get(
      url: '${Globals.apiCompanies}/$type/id/$companyId'
    ).onError((error, stackTrace) {
      Log.error(
        message: 'Error on getCompanyByID',
        error: error,
        stackTrace: stackTrace,
      );
      throw error as NetException;
    });

    // parse the response to get the company detail information based on the
    // company ID
    CommonSingleModel commonModel = CommonSingleModel.fromJson(jsonDecode(body));
    CompanyDetailModel company = CompanyDetailModel.fromJson(commonModel.data['attributes']);
    return company;
  }

  Future<CompanyDetailModel> getCompanyByCode({
    required String companyCode,
    required String type
  }) async {
    // get the company data using netutils
    final String body = await NetUtils.get(
      url: '${Globals.apiCompanies}/$type/code/${companyCode.toUpperCase()}'
    ).onError((error, stackTrace) {
      Log.error(
        message: 'Error on getCompanyByCode',
        error: error,
        stackTrace: stackTrace,
      );
      throw error as NetException;
    });

    // parse the response to get the company detail information based on the
    // company code (this is usually for stock company)
    CommonSingleModel commonModel = CommonSingleModel.fromJson(jsonDecode(body));
    CompanyDetailModel company = CompanyDetailModel.fromJson(commonModel.data['attributes']);
    return company;
  }

  Future<List<CompanyDetailModel>> getCompanySectorAndSubSector({
    required String type,
    required String sectorName,
    required String subSectorName
  }) async {
    // convert the sector and subsector into Base64
    // as we will use Base24 to send the data to avoid any invalid character
    String sectorNameBase64 = base64.encode(utf8.encode(sectorName));
    String subSectorNameBase64 = base64.encode(utf8.encode(subSectorName));

    // get the company data using netutils
    final String body = await NetUtils.get(
      url: '${Globals.apiCompanies}/sector/$sectorNameBase64/$type/$subSectorNameBase64'
    ).onError((error, stackTrace) {
      Log.error(
        message: 'Error on getCompanySectorAndSubSector',
        error: error,
        stackTrace: stackTrace,
      );
      throw error as NetException;
    });

    // parse the response to get the company list
    CommonArrayModel commonModel = CommonArrayModel.fromJson(jsonDecode(body));
    List<CompanyDetailModel> companyList = [];
    for (var data in commonModel.data) {
      CompanyDetailModel company = CompanyDetailModel.fromJson(data['attributes']);
      companyList.add(company);
    }
    return companyList;
  }

  Future<List<SectorNameModel>> getSectorNameList() async {
    // get the company data using netutils
    final String body = await NetUtils.get(
      url: '${Globals.apiCompanies}/sector/list'
    ).onError((error, stackTrace) {
      Log.error(
        message: 'Error on getSectorNameList',
        error: error,
        stackTrace: stackTrace,
      );
      throw error as NetException;
    });

    // parse the response to get the sector name list
    CommonArrayModel commonModel = CommonArrayModel.fromJson(jsonDecode(body));
    List<SectorNameModel> sectorNameList = [];
    for (var data in commonModel.data) {
      SectorNameModel company = SectorNameModel.fromJson(data['attributes']);
      sectorNameList.add(company);
    }
    return sectorNameList;
  }

  Future<SectorPerDetailModel> getCompanySectorPER({
    required String sectorName
  }) async {
    // convert the sector name into Base64
    String sectorNameBase64 = base64.encode(utf8.encode(sectorName));

    // get the company data using netutils
    final String body = await NetUtils.get(
      url: '${Globals.apiCompanies}/sector/$sectorNameBase64/per'
    ).onError((error, stackTrace) {
      Log.error(
        message: 'Error on getCompanySectorPER',
        error: error,
        stackTrace: stackTrace,
      );
      throw error as NetException;
    });

    // parse the response to get each sector PER
    CommonSingleModel commonModel = CommonSingleModel.fromJson(jsonDecode(body));
    SectorPerDetailModel per = SectorPerDetailModel.fromJson(commonModel.data['attributes']);
    return per;
  }

  Future<CompanyTopBrokerModel> getCompanyTopBroker({
    required String code,
    required DateTime fromDate,
    required DateTime toDate,
    int limit = 10,
  }) async {
    // get the initial query information for the API
    String dateFromString = Globals.dfyyyyMMdd.formatLocal(fromDate);
    String dateToString = Globals.dfyyyyMMdd.formatLocal(toDate);

    // get the company data using netutils
    final String body = await NetUtils.get(
      url: '${Globals.apiCompanies}/broker/$code/from/$dateFromString/to/$dateToString/limit/$limit'
    ).onError((error, stackTrace) {
      Log.error(
        message: 'Error on getCompanyTopBroker',
        error: error,
        stackTrace: stackTrace,
      );
      throw error as NetException;
    });

    // parse the response to get top broker information
    CommonSingleModel commonModel = CommonSingleModel.fromJson(jsonDecode(body));
    CompanyTopBrokerModel topBroker = CompanyTopBrokerModel.fromJson(commonModel.data['attributes']);
    return topBroker;
  }

  Future<CompanySahamFindOtherModel> getOtherCompany({
    required String companyCode
  }) async {
    // get the company data using netutils
    final String body = await NetUtils.get(
      url: '${Globals.apiCompanySaham}/findother/${companyCode.toUpperCase()}'
    ).onError((error, stackTrace) {
      Log.error(
        message: 'Error on getOtherCompany',
        error: error,
        stackTrace: stackTrace,
      );
      throw error as NetException;
    });

    // parse the response to find similar company
    CommonSingleModel commonModel = CommonSingleModel.fromJson(jsonDecode(body));
    CompanySahamFindOtherModel company = CompanySahamFindOtherModel.fromJson(commonModel.data['attributes']);
    return company;
  }

  Future<List<CompanySahamListModel>> getCompanySahamList() async {
    // get the company data using netutils
    final String body = await NetUtils.get(
      url: '${Globals.apiCompanySaham}/list'
    ).onError((error, stackTrace) {
      Log.error(
        message: 'Error on getCompanySahamList',
        error: error,
        stackTrace: stackTrace,
      );
      throw error as NetException;
    });

    // parse the response to get company saham list
    CommonArrayModel commonModel = CommonArrayModel.fromJson(jsonDecode(body));
    List<CompanySahamListModel> ret = [];
    for (dynamic data in commonModel.data) {
      CompanySahamListModel company = CompanySahamListModel.fromJson(data['attributes']);
      ret.add(company);
    }
    return ret;
  }

  Future<List<SeasonalityModel>> getSeasonality({
    required String code
  }) async {
    // get the company data using netutils
    final String body = await NetUtils.get(
      url: '${Globals.apiCompanySaham}/seasonality/$code'
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

  Future<CompanySahamDividendModel> getCompanySahamDividend({
    required String code
  }) async {
    // get the company data using netutils
    final String body = await NetUtils.get(
      url: '${Globals.apiCompanySaham}/dividend/$code'
    ).onError((error, stackTrace) {
      Log.error(
        message: 'Error on getCompanySahamDividend',
        error: error,
        stackTrace: stackTrace,
      );
      throw error as NetException;
    });

    // parse the response to get the company detail information based on the
    // company ID
    CommonSingleModel commonModel = CommonSingleModel.fromJson(jsonDecode(body));
    CompanySahamDividendModel company = CompanySahamDividendModel.fromJson(commonModel.data['attributes']);
    return company;
  }

  Future<CompanySahamSplitModel> getCompanySahamSplit({
    required String code
  }) async {
    // get the company data using netutils
    final String body = await NetUtils.get(
      url: '${Globals.apiCompanySaham}/split/$code'
    ).onError((error, stackTrace) {
      Log.error(
        message: 'Error on getCompanySahamSplit',
        error: error,
        stackTrace: stackTrace,
      );
      throw error as NetException;
    });

    // parse the response to get the company detail information based on the
    // company ID
    CommonSingleModel commonModel = CommonSingleModel.fromJson(jsonDecode(body));
    CompanySahamSplitModel company = CompanySahamSplitModel.fromJson(commonModel.data['attributes']);
    return company;
  }

  Future<CompanyWeekdayPerformanceModel> getCompanyWeekdayPerformance({
    String type = 'saham',
    required String code,
    required DateTime fromDate,
    required DateTime toDate,
  }) async {
    assert(type == 'saham' || type == 'reksadana', "Wrong type");

    // get the initial query information for the API
    String dateFromString = Globals.dfyyyyMMdd.formatLocal(fromDate);
    String dateToString = Globals.dfyyyyMMdd.formatLocal(toDate);

    // get the company data using netutils
    final String body = await NetUtils.get(
      url: '${Globals.apiCompanies}/$type/weekday/$code/from/$dateFromString/to/$dateToString'
    ).onError((error, stackTrace) {
      Log.error(
        message: 'Error on getCompanyWeekdayPerformance',
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

  Future<CompanyWeekdayPerformanceModel> getCompanyMonthlyPerformance({
    String type = 'saham',
    required String code,
    required DateTime fromDate,
    required DateTime toDate,
  }) async {
    assert(type == 'saham' || type == 'reksadana', "Wrong type");
    
    // get the initial query information for the API
    String dateFromString = Globals.dfyyyyMMdd.formatLocal(fromDate);
    String dateToString = Globals.dfyyyyMMdd.formatLocal(toDate);

    // get the company data using netutils
    final String body = await NetUtils.get(
      url: '${Globals.apiCompanies}/$type/monthly/$code/from/$dateFromString/to/$dateToString'
    ).onError((error, stackTrace) {
      Log.error(
        message: 'Error on getCompanyMonthlyPerformance',
        error: error,
        stackTrace: stackTrace,
      );
      throw error as NetException;
    });

    // parse the response to get top broker information
    CommonSingleModel commonModel = CommonSingleModel.fromJson(jsonDecode(body));
    CompanyWeekdayPerformanceModel monthlyPerformance = CompanyWeekdayPerformanceModel.fromJson(commonModel.data['attributes']);
    return monthlyPerformance;
  }

  Future<CompanySahamAdditionalModel?> getCompanySahamAdditional({
    required String code,
  }) async {
    // get the company data using netutils
    try {
      final String body = await NetUtils.get(
        url: '${Globals.apiCompanies}/stock/additional/$code'
      );

      // parse the response to get top broker information
      CommonSingleModel commonModel = CommonSingleModel.fromJson(jsonDecode(body));
      CompanySahamAdditionalModel stockAdditional = CompanySahamAdditionalModel.fromJson(commonModel.data['attributes']);
      return stockAdditional;
    }
    on NetException catch (netError, _) {
      if (netError.code == 404) {
        return null;
      }
    }
    catch (error, stackTrace) {
      Log.error(
        message: 'Error on getCompanySahamAdditional',
        error: error,
        stackTrace: stackTrace,
      );
      throw error as NetException;
    }

    // in case reaching here
    return null;
  }

  Future<CompanySahamSectorIndustryAverageModel> getCompanySahamAverageSectorIndustry({
    required String code,
    required String type,
  }) async {
    assert(type.toLowerCase() == 'per' || type.toLowerCase() == 'pbv', "Wrong type");

    // get the company data using netutils
    try {
      final String body = await NetUtils.get(
        url: '${Globals.apiCompanySaham}/avg/$type/$code'
      );

      // parse the response to get top broker information
      CommonSingleModel commonModel = CommonSingleModel.fromJson(jsonDecode(body));
      CompanySahamSectorIndustryAverageModel stockAverage = CompanySahamSectorIndustryAverageModel.fromJson(commonModel.data['attributes']);
      return stockAverage;
    }
    catch (error, stackTrace) {
      Log.error(
        message: 'Error on getCompanySahamAverageSectorIndustry',
        error: error,
        stackTrace: stackTrace,
      );
      throw error as NetException;
    }
  }

  Future<CompanyPortofolioAssetModel> getCompanyPortofolioAsset({
    required int companyId,
  }) async {
    // get the company data using netutils
    final String body = await NetUtils.get(
      url: '${Globals.apiCompanyPortofolioAsset}/id/$companyId'
    ).onError((error, stackTrace) {
      Log.error(
        message: 'Error on getCompanyPortofolioAsset',
        error: error,
        stackTrace: stackTrace,
      );
      throw error as NetException;
    });

    // parse the response to get the detail company information
    late CompanyPortofolioAssetModel portofolioAsset;

    try {
      CommonSingleModel commonModel = CommonSingleModel.fromJson(jsonDecode(body));
      portofolioAsset = CompanyPortofolioAssetModel.fromJson(commonModel.data['attributes']);
      
    }
    catch(e) {
      Log.error(
        message: 'Error converting portofolio asset data',
        error: e,
      );
    }
    
    return portofolioAsset;
  }

  Future<CompanyLastUpdateModel> getCompanyMaxUpdate() async {
    // get the company data using netutils
    final String body = await NetUtils.get(
      url: '${Globals.apiCompanies}/max/update'
    ).onError((error, stackTrace) {
      Log.error(
        message: 'Error on getCompanyMaxUpdate',
        error: error,
        stackTrace: stackTrace,
      );
      throw error as NetException;
    });

    // parse the response to get the detail company information
    CommonSingleModel commonModel = CommonSingleModel.fromJson(jsonDecode(body));
    CompanyLastUpdateModel companyMaxUpdate = CompanyLastUpdateModel.fromJson(commonModel.data['attributes']);

    return companyMaxUpdate;
  }

  Future<CompanyLastUpdateModel> getCompanyMinUpdate() async {
    // get the company data using netutils
    final String body = await NetUtils.get(
      url: '${Globals.apiCompanies}/min/update'
    ).onError((error, stackTrace) {
      Log.error(
        message: 'Error on getCompanyMinUpdate',
        error: error,
        stackTrace: stackTrace,
      );
      throw error as NetException;
    });

    // parse the response to get the detail company information
    CommonSingleModel commonModel = CommonSingleModel.fromJson(jsonDecode(body));
    CompanyLastUpdateModel companyMinUpdate = CompanyLastUpdateModel.fromJson(commonModel.data['attributes']);

    return companyMinUpdate;
  }
}