import 'package:flutter/cupertino.dart';
import 'package:my_wealth/model/sector_summary_model.dart';

class InsightProvider extends ChangeNotifier {
  List<SectorSummaryModel>? sectorSummaryList;

  setSectorSummaryList(List<SectorSummaryModel> list) {
    sectorSummaryList = list;
    notifyListeners();
  }
}