import 'dart:convert';
import 'package:my_wealth/model/company_saham_list_model.dart';
import 'package:my_wealth/model/sector_name_list_model.dart';
import 'package:my_wealth/storage/local_box.dart';

class CompanySharedPreferences {
  static const _sectorNameListKey = "sector_name_list";
  static const _companySahamListKey = "company_saham_list";

  static Future<void> setSectorNameList(List<SectorNameModel> sectorNameList) async {
    // stored the user info to box
    if(LocalBox.keyBox == null) {
      LocalBox.init();
    }

    // convert the json to string so we can stored it on the local storage
    List<String> sectorNameListResp = [];
    for (SectorNameModel sectorName in sectorNameList) {
      sectorNameListResp.add(jsonEncode(sectorName.toJson()));
    }
    LocalBox.putStringList(_sectorNameListKey, sectorNameListResp);
  }

  static List<SectorNameModel> getSectorNameList() {
    // check if the key box is null or not?
    if(LocalBox.keyBox == null) {
      LocalBox.init();
    }

    // get the data from local box
    List<String> sectorNameListString = (LocalBox.getStringList(_sectorNameListKey) ?? []);

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

  static Future<void> setCompanySahamList(List<CompanySahamListModel> companySahamList) async {
    // stored the user info to box
    if(LocalBox.keyBox == null) {
      LocalBox.init();
    }

    // convert the json to string so we can stored it on the local storage
    List<String> companySahamListResp = [];
    for (CompanySahamListModel company in companySahamList) {
      companySahamListResp.add(jsonEncode(company.toJson()));
    }
    LocalBox.putStringList(_companySahamListKey, companySahamListResp);
  }

  static List<CompanySahamListModel> getCompanySahamList() {
    // check if the key box is null or not?
    if(LocalBox.keyBox == null) {
      LocalBox.init();
    }

    // get the data from local box
    List<String> companySahamListString = (LocalBox.getStringList(_companySahamListKey) ?? []);

    // check if the list is empty or not?
    if (companySahamListString.isNotEmpty) {
      // list is not empty, parse the string to FavouriteModel
      List<CompanySahamListModel> ret = [];
      for (String companyString in companySahamListString) {
        CompanySahamListModel company = CompanySahamListModel.fromJson(jsonDecode(companyString));
        ret.add(company);
      }

      // return the favourites list
      return ret;
    }
    else {
      // no data
      return [];
    }
  }
}