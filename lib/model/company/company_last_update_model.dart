// To parse this JSON data, do
//
//     final companyMaxUpdateModel = companyMaxUpdateModelFromJson(jsonString);

import 'dart:convert';

CompanyLastUpdateModel companyLastUpdateModelFromJson(String str) => CompanyLastUpdateModel.fromJson(json.decode(str));

String companyLastUpdateModelToJson(CompanyLastUpdateModel data) => json.encode(data.toJson());

class CompanyLastUpdateModel {
    final DateTime reksadana;
    final DateTime crypto;
    final DateTime saham;

    CompanyLastUpdateModel({
        required this.reksadana,
        required this.crypto,
        required this.saham,
    });

    factory CompanyLastUpdateModel.fromJson(Map<String, dynamic> json) => CompanyLastUpdateModel(
        reksadana: DateTime.parse(json["reksadana"]),
        crypto: DateTime.parse(json["crypto"]),
        saham: DateTime.parse(json["saham"]),
    );

    Map<String, dynamic> toJson() => {
        "reksadana": "${reksadana.year.toString().padLeft(4, '0')}-${reksadana.month.toString().padLeft(2, '0')}-${reksadana.day.toString().padLeft(2, '0')}",
        "crypto": "${crypto.year.toString().padLeft(4, '0')}-${crypto.month.toString().padLeft(2, '0')}-${crypto.day.toString().padLeft(2, '0')}",
        "saham": "${saham.year.toString().padLeft(4, '0')}-${saham.month.toString().padLeft(2, '0')}-${saham.day.toString().padLeft(2, '0')}",
    };
}
