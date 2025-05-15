import 'dart:convert';
import 'package:my_wealth/_index.g.dart';

enum CompanyLastUpdateType {
  max,
  min,
}
class CompanySharedPreferences {
  static const _sectorNameListKey = "sector_name_list";
  static const _companyListKey = "company_list_";
  static const _companySearchKey = "company_search_";
  static const _companyLastUpdate = "company_last_update_";

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

  static Future<void> setCompanySearch({
    required String type,
    required List<CompanySearchModel> companies
  }) async {
    List<String> companyList = [];
    for (CompanySearchModel company in companies) {
      companyList.add(jsonEncode(company.toJson()));
    }
    await LocalBox.putStringList(
      key: "$_companySearchKey$type",
      value: companyList,
      cache: true,
    );
  }

  static List<CompanySearchModel> getCompanySearch({required String type}) {
    // get the company list from local box
    List<String> companyListString = (
      LocalBox.getStringList(
        key: "$_companySearchKey$type",
        cache: true
      ) ?? []
    );

    // check if the company list is empty or not?
    if (companyListString.isNotEmpty) {
      // process the company list string to CompanyListModel
      List<CompanySearchModel> companyList = [];
      for (String company in companyListString) {
        companyList.add(CompanySearchModel.fromJson(jsonDecode(company)));
      }

      return companyList;
    }
    else {
      return [];
    }
  }

  static Future<void> updateCompanySearch({
    required String type,
    required CompanySearchModel update,
  }) async {
    // get the favourite company list from local box
    List<String> companyStringList = (
      LocalBox.getStringList(
        key: "$_companySearchKey$type",
        cache: true,
      ) ?? []
    );

    // check if it's empty or not?
    if (companyStringList.isNotEmpty) {
      // convert favourite company list string into FavouritesListModel
      List<CompanySearchModel> companyList = [];
      for (String company in companyStringList) {
        companyList.add(CompanySearchModel.fromJson(jsonDecode(company)));
      }

      // loop for favouriteCompanyList to update the data
      for(int i=0; i<companyList.length; i++) {
        // check if same company ID or not?
        // if same, then update the data
        if (companyList[i].companyId == update.companyId) {
          companyList[i] = update;
          break;
        }
      }

      // overwrite current company search list
      await setCompanySearch(type: type, companies: companyList);
    }
  }

  static Future<void> deleteCompanySearch({
    required String type,
    required int watchlistID,
  }) async {
    // get the favourite company list from local box
    List<String> companyStringList = (
      LocalBox.getStringList(
        key: "$_companySearchKey$type",
        cache: true,
      ) ?? []
    );

    // check if it's empty or not?
    if (companyStringList.isNotEmpty) {
      // convert favourite company list string into FavouritesListModel
      List<CompanySearchModel> companyList = [];
      for (String company in companyStringList) {
        companyList.add(CompanySearchModel.fromJson(jsonDecode(company)));
      }

      // loop for favouriteCompanyList to update the data
      for(int i=0; i<companyList.length; i++) {
        // check if same company ID or not?
        // if same, then update the data
        if ((companyList[i].companyWatchlistID ?? -1) == watchlistID) {
          // update this data, set the watchlist ID back into -1, and we can add
          // this company
          companyList[i] = CompanySearchModel(
            companyId: companyList[i].companyId,
            companyName: companyList[i].companyName,
            companyNetAssetValue: companyList[i].companyNetAssetValue,
            companyPrevPrice: companyList[i].companyPrevPrice,
            companyFCA: companyList[i].companyFCA,
            companyWatchlistID: -1,
            companyLastUpdate: companyList[i].companyLastUpdate,
            companyCanAdd: true,
          );
          break;
        }
      }

      // overwrite current company search list
      await setCompanySearch(type: type, companies: companyList);
    }
  }

  static Future<void> clearCompanySearch() async {
    // clear all the company list we stored so we can re-fetch it with the
    // latest information.
    LocalBox.delete(key: _companySearchKey, cache: true);
  }

  static Future<void> setCompanyLastUpdateModel({
    required CompanyLastUpdateType type,
    required CompanyLastUpdateModel lastUpdateModel
  }) async {
    String key = _companyLastUpdate;
    switch(type) {
      case CompanyLastUpdateType.max:
        key += 'max';
        break;
      case CompanyLastUpdateType.min:
        key += 'min';
        break;
    }

    // convert the json to string so we can stored it on the local storage
    String lastUpdateString = jsonEncode(lastUpdateModel.toJson());
    LocalBox.putString(
      key: key,
      value: lastUpdateString
    );
  }

  static CompanyLastUpdateModel getCompanyLastUpdateModel({
    required CompanyLastUpdateType type,
  }) {
    String key = _companyLastUpdate;
    switch(type) {
      case CompanyLastUpdateType.max:
        key += 'max';
        break;
      case CompanyLastUpdateType.min:
        key += 'min';
        break;
    }

    // get the data from local box
    String lastUpdateString = (
      LocalBox.getString(key: key) ?? ''
    );

    // check if the list is empty or not?
    if (lastUpdateString.isNotEmpty) {
      // string is not empty, parse the string to company max update
      CompanyLastUpdateModel ret = CompanyLastUpdateModel.fromJson(jsonDecode(lastUpdateString));

      // return the company max update model
      return ret;
    }
    else {
      // no data
      return CompanyLastUpdateModel(
        reksadana: DateTime.now(),
        crypto: DateTime.now(),
        saham: DateTime.now(),
      );
    }
  }
}