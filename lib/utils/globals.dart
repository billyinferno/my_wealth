import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:ionicons/ionicons.dart';

class Globals {
  static String apiURL = (dotenv.env['API_URL'] ?? 'http://192.168.1.176:1337/');
  static String appVersion = (dotenv.env['APP_VERSION'] ?? '0.0.1 - dev');
  static Map<String, String> reksadanaCompanyTypeEnum = {"reksadanacampuran":"Campuran", "reksadanasaham":"Saham", "reksadanapasaruang":"Pasar Uang", "reksadanapendapatantetap":"Pendapatan Tetap"};

  // icon list for sector
  static Map<String, IconData> sectorIcon = {
    "MISCELLANEOUS INDUSTRY":Ionicons.color_filter_outline,
    "CONSUMER GOODS INDUSTRY":Ionicons.fast_food_outline,
    "FINANCE":Ionicons.cash_outline,
    "AGRICULTURE":Ionicons.flower_outline,
    "INFRASTRUCTURE, UTILITIES & TRANSPORTATION":Ionicons.business,
    "BASIC INDUSTRY AND CHEMICALS":Ionicons.flask_outline,
    "MINING":Ionicons.construct_outline,
    "TRADE, SERVICES, & INVESTMENT":Ionicons.trail_sign_outline,
    "PROPERTY, REAL ESTATE AND BUILDING CONSTRUCTION":Ionicons.home_outline,
  };

  static Map<String, String> sectorName = {
    "MISCELLANEOUS INDUSTRY":"Misc Industry",
    "CONSUMER GOODS INDUSTRY":"Consumer Goods",
    "FINANCE":"Finance",
    "AGRICULTURE":"Agriculture",
    "INFRASTRUCTURE, UTILITIES & TRANSPORTATION":"Infrastructure",
    "BASIC INDUSTRY AND CHEMICALS":"Chemicals",
    "MINING":"Mining",
    "TRADE, SERVICES, & INVESTMENT":"Investment",
    "PROPERTY, REAL ESTATE AND BUILDING CONSTRUCTION":"Property",
  }; 

  // icon list for industry
  /*
  Peralatan Energi Alternatif
Operator Infrastruktur Transportasi
Farmasi
Produk Perawatan Tubuh
Pengangkutan Darat Penumpang
Jasa Profesional
Pendidikan &amp; Jasa Penunjang
Logam &amp; Mineral
Logistik &amp; Pengantaran
Media
Perangkat Lunak
Jasa &amp; Konsultan TI
Produk &amp; Perlengkapan Bangunan
Jasa Telekomunikasi Nirkabel
Jasa Telekomunikasi
Perdagangan Ritel Barang Primer
Distributor Barang Konsumen
Asuransi
Pengelola &amp; Pengembang Real Estat
Jasa Investasi
Material Konstruksi
Minuman
Konstruksi Bangunan
Department Store
Pembiayaan Konsumen
Perangkat, Instrumen &amp; Komponen Elektronik
Makanan Olahan
Perdagangan Aneka Barang Perindustrian
Wadah &amp; Kemasan
Maskapai Penerbangan
Peralatan &amp; Perlengkapan Kesehatan
Perhutanan &amp; Kertas
Aplikasi &amp; Jasa Internet
Minyak &amp; Gas
Utilitas Gas
Hiburan &amp; Film
Penyedia Jasa Kesehatan
Pariwisata &amp; Rekreasi
Barang Kimia
Peralatan Olah Raga &amp; Barang Hobi
Machinery
Rokok
Bank
Komponen Otomotif
Jasa Komersial
Pendukung Minyak, Gas &amp; Batu Bara
Barang Rumah Tangga
Perusahaan Holding Multi-sektor
Kelistrikan
Perusahaan Holding &amp; Investasi
Peralatan Jaringan
Ritel Khusus
Perangkat Komputer
Utilitas Listrik
Bahan Bakar Alternatif
Pakaian &amp; Barang Mewah
Batu Bara
Produk Makanan Pertanian
  */
}
