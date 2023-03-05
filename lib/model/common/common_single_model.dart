// To parse this JSON data, do
//
//     final commonSingleModel = commonSingleModelFromJson(jsonString);

import 'dart:convert';

CommonSingleModel commonSingleModelFromJson(String str) => CommonSingleModel.fromJson(json.decode(str));

class CommonSingleModel {
    CommonSingleModel({
        this.data,
        this.meta,
    });

    final dynamic data;
    final dynamic meta;

    factory CommonSingleModel.fromJson(Map<String, dynamic> json) => CommonSingleModel(
        data: json["data"],
        meta: json["meta"],
    );
}