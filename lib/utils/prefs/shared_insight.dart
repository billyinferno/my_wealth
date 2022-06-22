import 'dart:convert';
import 'package:my_wealth/model/sector_summary_model.dart';
import 'package:my_wealth/storage/local_box.dart';

class InsightSharedPreferences {
  static const _sectorSummaryKey = "sector_summary";

  static Future<void> setSectorSummaryList(List<SectorSummaryModel> sectorSummaryList) async {
    // stored the user info to box
    if(LocalBox.keyBox == null) {
      LocalBox.init();
    }

    // convert the json to string so we can stored it on the local storage
    List<String> sectorSummaryListResp = [];
    for (SectorSummaryModel sector in sectorSummaryList) {
      sectorSummaryListResp.add(jsonEncode(sector.toJson()));
    }
    LocalBox.putStringList(_sectorSummaryKey, sectorSummaryListResp);
  }

  static List<SectorSummaryModel> getSectorSummaryList() {
    // check if the key box is null or not?
    if(LocalBox.keyBox == null) {
      LocalBox.init();
    }

    // get the data from local box
    List<String> sectorSummaryList = (LocalBox.getStringList(_sectorSummaryKey) ?? []);

    // check if the list is empty or not?
    if (sectorSummaryList.isNotEmpty) {
      // list is not empty, parse the string to FavouriteModel
      List<SectorSummaryModel> ret = [];
      for (String sectorString in sectorSummaryList) {
        SectorSummaryModel sector = SectorSummaryModel.fromJson(jsonDecode(sectorString));
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