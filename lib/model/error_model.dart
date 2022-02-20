// To parse this JSON data, do
//
//     final errorModel = errorModelFromJson(jsonString);

import 'dart:convert';

ErrorModel errorModelFromJson(String str) => ErrorModel.fromJson(json.decode(str));

String errorModelToJson(ErrorModel data) => json.encode(data.toJson());

class ErrorModel {
    ErrorModel({
        required this.data,
        required this.error,
    });

    final dynamic data;
    final ErrorInformation error;

    factory ErrorModel.fromJson(Map<String, dynamic> json) => ErrorModel(
        data: json["data"],
        error: ErrorInformation.fromJson(json["error"]),
    );

    Map<String, dynamic> toJson() => {
        "data": data,
        "error": error.toJson(),
    };
}

class ErrorInformation {
    ErrorInformation({
        required this.status,
        required this.name,
        required this.message,
    });

    final int status;
    final String name;
    final String message;

    factory ErrorInformation.fromJson(Map<String, dynamic> json) => ErrorInformation(
        status: json["status"],
        name: json["name"],
        message: json["message"],
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "name": name,
        "message": message,
        "details": {},
    };
}
