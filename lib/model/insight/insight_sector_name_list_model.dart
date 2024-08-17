// To parse this JSON data, do
//
//     final sectorNameModel = sectorNameModelFromJson(jsonString);

import 'dart:convert';
import 'package:my_wealth/_index.g.dart';

SectorNameModel sectorNameModelFromJson(String str) => SectorNameModel.fromJson(json.decode(str));

String sectorNameModelToJson(SectorNameModel data) => json.encode(data.toJson());

class SectorNameModel {
    SectorNameModel({
        required this.sectorName,
        required this.sectorFriendlyname,
    });

    final String sectorName;
    final String sectorFriendlyname;

    factory SectorNameModel.fromJson(Map<String, dynamic> json) => SectorNameModel(
        sectorName: json["sector_name"],
        sectorFriendlyname: Globals.sectorName[json["sector_name"].toString().replaceAll('&amp;', '&')]!
    );

    Map<String, dynamic> toJson() => {
        "sector_name": sectorName,
        "sector_friendly_name": sectorFriendlyname
    };
}
