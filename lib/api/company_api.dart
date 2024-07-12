import 'dart:convert';
import 'package:my_wealth/model/common/common_array_model.dart';
import 'package:my_wealth/model/common/common_single_model.dart';
import 'package:my_wealth/model/company/company_detail_model.dart';
import 'package:my_wealth/model/company/company_list_model.dart';
import 'package:my_wealth/model/company/company_saham_dividend_model.dart';
import 'package:my_wealth/model/company/company_saham_list_model.dart';
import 'package:my_wealth/model/company/company_search_model.dart';
import 'package:my_wealth/model/company/company_top_broker_model.dart';
import 'package:my_wealth/model/company/company_seasonality_model.dart';
import 'package:my_wealth/model/company/company_saham_find_other_model.dart';
import 'package:my_wealth/model/insight/insight_sector_name_list_model.dart';
import 'package:my_wealth/model/insight/insight_sector_per_detail_model.dart';
import 'package:my_wealth/utils/globals.dart';
import 'package:my_wealth/utils/net/netutils.dart';

class CompanyAPI {
  Future<List<CompanyListModel>> findCompany(String type) async {
    // get the company data using netutils
    final String body = await NetUtils.get(
      url: '${Globals.apiCompanies}/type/${type.toLowerCase()}'
    ).onError((error, stackTrace) {
        throw Exception(error);
      }
    );

    // parse the response to get the data and process each one
    CommonArrayModel commonModel = CommonArrayModel.fromJson(jsonDecode(body));
    List<CompanyListModel> ret = [];
    for (dynamic data in commonModel.data) {
      // convert the attributes data to company list model
      CompanyListModel company = CompanyListModel.fromJson(data['attributes']);
      ret.add(company);
    }

    // return the company list
    return ret;
  }

  Future<CompanyDetailModel> getCompanyDetail(int companyId, String type) async {
    // get the company data using netutils
    final String body = await NetUtils.get(
      url: '${Globals.apiCompanies}/${type.toLowerCase()}/detail/$companyId'
    ).onError((error, stackTrace) {
        throw Exception(error);
      }
    );

    // parse the response to get the detail company information
    CommonSingleModel commonModel = CommonSingleModel.fromJson(jsonDecode(body));
    CompanyDetailModel company = CompanyDetailModel.fromJson(commonModel.data[0]['attributes']);
    return company;
  }

  Future<List<CompanySearchModel>> getCompanyByName(String companyName, String type) async {
    // get the company data using netutils
    final String body = await NetUtils.get(
      url: '${Globals.apiCompanies}/$type/name/${companyName.toLowerCase()}'
    ).onError((error, stackTrace) {
        throw Exception(error);
      }
    );

    // parse the response to get the company search result
    CommonArrayModel commonModel = CommonArrayModel.fromJson(jsonDecode(body));
    List<CompanySearchModel> ret = [];
    for (dynamic data in commonModel.data) {
      CompanySearchModel company = CompanySearchModel.fromJson(data['attributes']);
      ret.add(company);
    }
    return ret;
  }

  Future<CompanyDetailModel> getCompanyByID(int companyId, String type) async {
    // get the company data using netutils
    final String body = await NetUtils.get(
      url: '${Globals.apiCompanies}/$type/id/$companyId'
    ).onError((error, stackTrace) {
        throw Exception(error);
      }
    );

    // parse the response to get the company detail information based on the
    // company ID
    CommonSingleModel commonModel = CommonSingleModel.fromJson(jsonDecode(body));
    CompanyDetailModel company = CompanyDetailModel.fromJson(commonModel.data['attributes']);
    return company;
  }

  Future<CompanyDetailModel> getCompanyByCode(String companyCode, String type) async {
    // get the company data using netutils
    final String body = await NetUtils.get(
      url: '${Globals.apiCompanies}/$type/code/${companyCode.toUpperCase()}'
    ).onError((error, stackTrace) {
        throw Exception(error);
      }
    );

    // parse the response to get the company detail information based on the
    // company code (this is usually for stock company)
    CommonSingleModel commonModel = CommonSingleModel.fromJson(jsonDecode(body));
    CompanyDetailModel company = CompanyDetailModel.fromJson(commonModel.data['attributes']);
    return company;
  }

  Future<List<CompanyDetailModel>> getCompanySectorAndSubSector(String type, String sectorName, String subSectorName) async {
    // convert the sector and subsector into Base64
    // as we will use Base24 to send the data to avoid any invalid character
    String sectorNameBase64 = base64.encode(utf8.encode(sectorName));
    String subSectorNameBase64 = base64.encode(utf8.encode(subSectorName));

    // get the company data using netutils
    final String body = await NetUtils.get(
      url: '${Globals.apiCompanies}/sector/$sectorNameBase64/$type/$subSectorNameBase64'
    ).onError((error, stackTrace) {
        throw Exception(error);
      }
    );

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
        throw Exception(error);
      }
    );

    // parse the response to get the sector name list
    CommonArrayModel commonModel = CommonArrayModel.fromJson(jsonDecode(body));
    List<SectorNameModel> sectorNameList = [];
    for (var data in commonModel.data) {
      SectorNameModel company = SectorNameModel.fromJson(data['attributes']);
      sectorNameList.add(company);
    }
    return sectorNameList;
  }

  Future<SectorPerDetailModel> getCompanySectorPER(String sectorName) async {
    // convert the sector name into Base64
    String sectorNameBase64 = base64.encode(utf8.encode(sectorName));

    // get the company data using netutils
    final String body = await NetUtils.get(
      url: '${Globals.apiCompanies}/sector/$sectorNameBase64/per'
    ).onError((error, stackTrace) {
        throw Exception(error);
      }
    );

    // parse the response to get each sector PER
    CommonSingleModel commonModel = CommonSingleModel.fromJson(jsonDecode(body));
    SectorPerDetailModel per = SectorPerDetailModel.fromJson(commonModel.data['attributes']);
    return per;
  }

  Future<CompanyTopBrokerModel> getCompanyTopBroker(String code, DateTime fromDate, DateTime toDate, [int? limit]) async {
    // get the initial query information for the API
    String dateFromString = Globals.dfyyyyMMdd.format(fromDate);
    String dateToString = Globals.dfyyyyMMdd.format(toDate);
    int currLimit = (limit ?? 10);

    // get the company data using netutils
    final String body = await NetUtils.get(
      url: '${Globals.apiCompanies}/broker/$code/from/$dateFromString/to/$dateToString/limit/$currLimit'
    ).onError((error, stackTrace) {
        throw Exception(error);
      }
    );

    // parse the response to get top broker information
    CommonSingleModel commonModel = CommonSingleModel.fromJson(jsonDecode(body));
    CompanyTopBrokerModel topBroker = CompanyTopBrokerModel.fromJson(commonModel.data['attributes']);
    return topBroker;
  }

  Future<CompanySahamFindOtherModel> getOtherCompany(String companyCode) async {
    // get the company data using netutils
    final String body = await NetUtils.get(
      url: '${Globals.apiCompanySaham}/findother/${companyCode.toUpperCase()}'
    ).onError((error, stackTrace) {
        throw Exception(error);
      }
    );

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
        throw Exception(error);
      }
    );

    // parse the response to get company saham list
    CommonArrayModel commonModel = CommonArrayModel.fromJson(jsonDecode(body));
    List<CompanySahamListModel> ret = [];
    for (dynamic data in commonModel.data) {
      CompanySahamListModel company = CompanySahamListModel.fromJson(data['attributes']);
      ret.add(company);
    }
    return ret;
  }

  Future<List<SeasonalityModel>> getSeasonality(String code) async {
    // get the company data using netutils
    final String body = await NetUtils.get(
      url: '${Globals.apiCompanySaham}/seasonality/$code'
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

  Future<CompanySahamDividendModel> getCompanySahamDividend(String code) async {
    // get the company data using netutils
    final String body = await NetUtils.get(
      url: '${Globals.apiCompanySaham}/dividend/$code'
    ).onError((error, stackTrace) {
        throw Exception(error);
      }
    );

    // parse the response to get the company detail information based on the
    // company ID
    CommonSingleModel commonModel = CommonSingleModel.fromJson(jsonDecode(body));
    CompanySahamDividendModel company = CompanySahamDividendModel.fromJson(commonModel.data['attributes']);
    return company;
  }
}