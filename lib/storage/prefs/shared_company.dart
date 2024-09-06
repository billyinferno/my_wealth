import 'dart:convert';
import 'package:my_wealth/_index.g.dart';

class CompanySharedPreferences {
  static const _sectorNameListKey = "sector_name_list";

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
}