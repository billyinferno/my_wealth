import 'package:flutter_dotenv/flutter_dotenv.dart';

class Globals {
  static String apiURL = (dotenv.env['API_URL'] ?? 'http://192.168.1.176:1337/');
  static String appVersion = (dotenv.env['APP_VERSION'] ?? '0.0.1 - dev');
  static Map<String, String> companyTypeEnum = {"campuran":"Campuran", "saham":"Saham", "pasaruang":"Pasar Uang", "pendapatantetap":"Pendapatan  Tetap"};
}
