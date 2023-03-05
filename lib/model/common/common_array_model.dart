// To parse this JSON data, do
//
//     final commonModel = commonModelFromJson(jsonString);

import 'dart:convert';

CommonArrayModel commonModelFromJson(String str) => CommonArrayModel.fromJson(json.decode(str));

String commonModelToJson(CommonArrayModel data) => json.encode(data.toJson());

class CommonArrayModel {
    CommonArrayModel({
        required this.data,
        required this.meta,
    });

    final List<dynamic> data;
    final dynamic meta;

    factory CommonArrayModel.fromJson(Map<String, dynamic> json) => CommonArrayModel(
        data: List<dynamic>.from(json["data"].map((x) => x)),
        meta: json["meta"],
    );

    Map<String, dynamic> toJson() => {
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
        "meta": meta.toJson(),
    };
}
