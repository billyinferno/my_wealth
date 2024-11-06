import 'dart:convert';
import 'package:my_wealth/_index.g.dart';

class CompanySharedPreferences {
  static const _sectorNameListKey = "sector_name_list";
  static const _companyListKey = "company_list_";

  static Future<void> setSectorNameList({
    required List<SectorNameModel> sectorNameList
  }) async {
    // convert the json to string so we can stored it on the local storage
    List<String> sectorNameListResp = [];
    for (SectorNameModel sectorName in sectorNameList) {
      sectorNameListResp.add(jsonEncode(sectorName.toJson()));
    }
    LocalBox.putStringList(
      key: _sectorNameListKey,
      value: sectorNameListResp
    );
  }

  static List<SectorNameModel> getSectorNameList() {
    // get the data from local box
    List<String> sectorNameListString = (
      LocalBox.getStringList(key: _sectorNameListKey) ?? []
    );

    // check if the list is empty or not?
    if (sectorNameListString.isNotEmpty) {
      // list is not empty, parse the string to FavouriteModel
      List<SectorNameModel> ret = [];
      for (String sectorString in sectorNameListString) {
        SectorNameModel sector = SectorNameModel.fromJson(jsonDecode(sectorString));
        ret.add(sector);
      }

      // return the favourites list
      return ret;
    }
    else {
      // no data
      return [];
    }
  }

  static Future<void> setCompanyList({
    required String type,
    required List<CompanyListModel> list
  }) async {
    List<String> companyList = [];
    for (CompanyListModel company in list) {
      companyList.add(jsonEncode(company.toJson()));
    }
    await LocalBox.putStringList(
      key: "$_companyListKey$type",
      value: companyList,
      cache: true,
    );
  }

  static List<CompanyListModel> getCompanyList({required String type}) {
    // get the company list from local box
    List<String> companyListString = (
      LocalBox.getStringList(
        key: "$_companyListKey$type",
        cache: true
      ) ?? []
    );

    // check if the company list is empty or not?
    if (companyListString.isNotEmpty) {
      // process the company list string to CompanyListModel
      List<CompanyListModel> companyList = [];
      for (String company in companyListString) {
        companyList.add(CompanyListModel.fromJson(jsonDecode(company)));
      }

      return companyList;
    }
    else {
      return [];
    }
  }

  static Future<void> clearCompanyList() async {
    // clear all the company list we stored so we can re-fetch it with the
    // latest information.
    LocalBox.delete(key: _companyListKey, cache: true);
  }
}