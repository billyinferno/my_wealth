import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:ionicons/ionicons.dart';
import 'package:line_icons/line_icons.dart';

class Globals {
  static String apiURL = (dotenv.env['API_URL'] ?? 'http://192.168.1.176:1337/');
  static int apiTimeOut = 10;

  // add all the api path here, so in case we change API we can just do it from
  // this single file instead goes to each API
  static String apiBroker = '${apiURL}api/company-brokers';
  static String apiBrokerSummary = '${apiURL}api/broker-summaries';
  static String apiCompanies = '${apiURL}api/companies';
  static String apiCompanySaham = '${apiURL}api/company-saham';
  static String apiFavourites = '${apiURL}api/favourites';
  static String apiIndices = '${apiURL}api/indices';
  static String apiIndicePrice = '${apiURL}api/indices-prices';
  static String apiInfoFundamentals = '${apiURL}api/info-fundamentals';
  static String apiInfoReksadana = '${apiURL}api/info-reksadanas';
  static String apiInfoSaham = '${apiURL}api/info-sahams';
  static String apiPortofolio = '${apiURL}api/portofolio';
  static String apiPriceSaham = '${apiURL}api/price-sahams';
  static String apiAuthLocal = '${apiURL}api/auth/local';
  static String apiUsers = '${apiURL}api/users';
  static String apiRisk = '${apiURL}api/risk';
  static String apiVisibility = '${apiURL}api/visibility';
  static String apiPassword = '${apiURL}api/password';
  static String apiBot = '${apiURL}api/bot';
  static String apiWatchlists = '${apiURL}api/watchlists';
  static String apiWatchlistDetails = '${apiURL}api/watchlists-details';
  static String apiInsight = '${apiURL}api/insight';
  
  static String appVersion = (dotenv.env['APP_VERSION'] ?? '0.0.1 - dev');
  static String flutterVersion = (dotenv.env['FLUTTER_VERSION'] ?? 'beta');
  static Map<String, String> reksadanaCompanyTypeEnum = {"reksadanacampuran":"Campuran", "reksadanasaham":"Saham", "reksadanapasaruang":"Pasar Uang", "reksadanapendapatantetap":"Pendapatan Tetap"};

  static DateFormat dfddMM = DateFormat('dd/MM');
  static DateFormat dfddMMyyyy = DateFormat('dd/MM/yyyy');
  static DateFormat dfddMMyyyy2 = DateFormat('dd-MM-yyyy');
  static DateFormat dfDDMMMyyyy = DateFormat('dd MMM yyyy');
  static DateFormat dfddMMyy = DateFormat('dd/MM/yy');
  
  static DateFormat dfMMMyyyy = DateFormat('MMM yyyy');
  static DateFormat dfMMM = DateFormat('MMM');
  static DateFormat dfMMyy = DateFormat('MM/yy');

  static DateFormat dfyyyyMMdd = DateFormat('yyyy-MM-dd');
  static DateFormat dfyyyyMM = DateFormat('yyyy/MM');

  static List<Color> colorList = [
    // -- 1st shade --
    const Color.fromRGBO(220,20,60,1), // crimson
    const Color.fromRGBO(255,165,0,1), // orange
    const Color.fromRGBO(154,205,50,1), // yellow green
    const Color.fromRGBO(102,205,170,1), // medium aqua marine
    const Color.fromRGBO(221,160,221,1), // plum
    const Color.fromRGBO(245,245,220,1), // beige
    const Color.fromRGBO(210,105,30,1), // chocolate
    // -- 2nd shade --
    const Color.fromRGBO(255,99,71,1), // tomato
    const Color.fromRGBO(255,215,0,1), // gold
    const Color.fromRGBO(127,255,0,1), // chartreuse
    const Color.fromRGBO(0,206,209,1), // dark turquoise
    const Color.fromRGBO(255,105,180,1), // hot pink
    const Color.fromRGBO(255,228,196,1), // bisque
    const Color.fromRGBO(222,184,135,1), // burly brown
    // -- 3rd shade --
    const Color.fromRGBO(240,128,128,1), // light coral
    const Color.fromRGBO(240,230,140,1), // khaki
    const Color.fromRGBO(34,139,34,1), // forest green
    const Color.fromRGBO(176,224,230,1), // powder blue
    const Color.fromRGBO(255,192,203,1), // pink
    const Color.fromRGBO(245,222,179,1), // wheat
    const Color.fromRGBO(255,222,173,1), // navajo white
  ];

  // index name
  static Map<String,String> indexName = {
    'BISNIS-27' : 'Bisnis Indonesia',
    'IDX-30'    : 'IDX 30 Index',
    'IDXG30'    : 'IDX Growth 30',
    'IHSG'      : 'IDX Composite',
    'LQ45'      : 'Indeks LQ45',
    'ISSI'      : 'Indonesia Sharia Stock Index',
    'JII'       : 'Jakarta Islamic Index',
    'JII 70'    : 'Jakarta Islamic Index 70',
    'PCMBI'     : 'Bond Index',
    'PCCMBI'    : 'Conventional Bond Index',
    'PCCBI'     : 'Conventional Corporate Bond Index',
    'PCGBI'     : 'Conventional Government Bond Index',
    'PCBI'      : 'Corporate Bond Index',
    'PGBI'      : 'Government Bond Index',
    'PIRC'      : 'Indeks Reksadana Campuran',
    'PIRC-S'    : 'Indeks Reksadana Campuran - Syariah',
    'PIRFI'     : 'Indeks Reksadana Pendapatan Tetap',
    'PIRFI-S'   : 'Indeks Reksadana Pendapatan Tetap - Syariah',
    'PIRS'      : 'Indeks Reksadana Saham',
    'PIRS-S'    : 'Indeks Reksadana Saham - Syariah',
    'PIUC'      : 'Indeks Unitlink Campuran',
    'PIUPU'     : 'Indeks Unitlink Pasar Uang',
    'PIUFI'     : 'Indeks Unitlink Pendapatan Tetap',
    'PIUS'      : 'Indeks Unitlink Saham',
    'PIRPU'     : 'Index Reksadana Pasar Uang',
    'PIRPU-S'   : 'Index Reksadana Pasar Uang - Syariah',
    'PSCMBI'    : 'Sharia Bond Index',
    'PSCBI'     : 'Sharia Corporate Bond Index',
    'PSGBI'     : 'Sharia Government Bond Index',
    'SRI-KEHATI': 'Sustainable and Responsible Investment',
  };

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
    "MISCELLANEOUS INDUSTRY":"Miscellaneous",
    "CONSUMER GOODS INDUSTRY":"Consumer Goods",
    "FINANCE":"Finance",
    "AGRICULTURE":"Agriculture",
    "INFRASTRUCTURE, UTILITIES & TRANSPORTATION":"Infra, Utility, & Transport",
    "BASIC INDUSTRY AND CHEMICALS":"Basic Industry & Chemicals",
    "MINING":"Mining",
    "TRADE, SERVICES, & INVESTMENT":"Trade, Service, & Investment",
    "PROPERTY, REAL ESTATE AND BUILDING CONSTRUCTION":"Property & Construction",
  };

  static Map<String, IconData> subSectorIcon = {
    "Electronics":LineIcons.plug,
    "Restaurant, Hotel And Tourism":LineIcons.hotel,
    "Food & Beverages":LineIcons.hamburger,
    "Computer And Services":LineIcons.server,
    "Land / Stone Quarrying":LineIcons.mountain,
    "Others":LineIcons.table,
    "Wood Industries":LineIcons.tree,
    "Bank":LineIcons.piggyBank,
    "Houseware":LineIcons.utensils,
    "Footwear":LineIcons.shoePrints,
    "Toll Road, Airport, Harbor and Allied Products":LineIcons.planeDeparture,
    "Insurance":LineIcons.carCrash,
    "Property and Real Estate":LineIcons.home,
    "Chemicals":LineIcons.flask,
    "Coal Mining":LineIcons.tractor,
    "Plantation":LineIcons.tree,
    "Cosmetics & Household":LineIcons.mask,
    "Textile, Garment":LineIcons.tShirt,
    "Animal Husbandary":LineIcons.dog,
    "Retail Trade":LineIcons.alternateStore,
    "Health Care":LineIcons.medkit,
    "Crops":LineIcons.seedling,
    "Financial Institution":LineIcons.coins,
    "Tobacco Manufacturers":LineIcons.smoking,
    "Cement":LineIcons.tractor,
    "Non Building Construction":LineIcons.hardHat,
    "Crude Petroleum & Natural Gas Production":LineIcons.oilCan,
    "Wholesale (Durable & Non Durable Goods)":LineIcons.industry,
    "Automotive & Components":LineIcons.cogs,
    "Plastics & Packaging":LineIcons.shoppingBag,
    "Building Construction":LineIcons.building,
    "Machinery & Heavy Equipment":LineIcons.wrench,
    "Ceramics, Glass, Porcelain":LineIcons.alternateWineGlas,
    "Energy":LineIcons.solarPanel,
    "Metal & Mineral Mining":LineIcons.tractor,
    "Pulp & Paper":LineIcons.scroll,
    "Advertising, Printing, dan Media":LineIcons.ad,
    "Fishery":LineIcons.fish,
    "Cable":LineIcons.ethernet,
    "Animal Feed":LineIcons.paw,
    "Telecommunication":LineIcons.phone,
    "Transportation":LineIcons.bus,
    "Pharmaceuticals":LineIcons.prescriptionBottle,
    "Metal & Allied Products":LineIcons.cog,
    "Securities Company":LineIcons.userSecret,
    "Investment Company":LineIcons.handHoldingUsDollar,
  };

  // icon list for industry
  static Map<String, IconData> industryIcon = {
    "Peralatan Energi Alternatif":LineIcons.alternateRadiation,
    "Operator Infrastruktur Transportasi":LineIcons.bus,
    "Farmasi":LineIcons.flask,
    "Produk Perawatan Tubuh":LineIcons.eyeDropper,
    "Pengangkutan Darat Penumpang":LineIcons.shuttleVan,
    "Jasa Profesional":LineIcons.userTie,
    "Pendidikan & Jasa Penunjang":LineIcons.school,
    "Logam & Mineral":LineIcons.eraser,
    "Logistik & Pengantaran":LineIcons.truck,
    "Media":LineIcons.photoVideo,
    "Perangkat Lunak":LineIcons.laptopCode,
    "Jasa & Konsultan TI":LineIcons.server,
    "Produk & Perlengkapan Bangunan":LineIcons.wrench,
    "Jasa Telekomunikasi Nirkabel":LineIcons.wifi,
    "Jasa Telekomunikasi":LineIcons.phone,
    "Perdagangan Ritel Barang Primer":LineIcons.hamburger,
    "Distributor Barang Konsumen":LineIcons.truck,
    "Asuransi":LineIcons.carCrash,
    "Pengelola & Pengembang Real Estat":LineIcons.home,
    "Jasa Investasi":LineIcons.piggyBank,
    "Material Konstruksi":LineIcons.warehouse,
    "Minuman":LineIcons.beer,
    "Konstruksi Bangunan":LineIcons.wrench,
    "Department Store":LineIcons.alternateStore,
    "Pembiayaan Konsumen":LineIcons.users,
    "Perangkat, Instrumen & Komponen Elektronik":LineIcons.plug,
    "Makanan Olahan":LineIcons.hamburger,
    "Perdagangan Aneka Barang Perindustrian":LineIcons.alternateStore,
    "Wadah & Kemasan":LineIcons.shoppingBag,
    "Maskapai Penerbangan":LineIcons.planeDeparture,
    "Peralatan & Perlengkapan Kesehatan":LineIcons.stethoscope,
    "Perhutanan & Kertas":LineIcons.scroll,
    "Aplikasi & Jasa Internet":LineIcons.wifi,
    "Minyak & Gas":LineIcons.oilCan,
    "Utilitas Gas":LineIcons.gasPump,
    "Hiburan & Film":LineIcons.film,
    "Penyedia Jasa Kesehatan":LineIcons.stethoscope,
    "Pariwisata & Rekreasi":LineIcons.campground,
    "Barang Kimia":LineIcons.flask,
    "Peralatan Olah Raga & Barang Hobi":LineIcons.bicycle,
    "Machinery":LineIcons.wrench,
    "Rokok":LineIcons.smoking,
    "Bank":LineIcons.university,
    "Komponen Otomotif":LineIcons.cog,
    "Jasa Komersial":LineIcons.store,
    "Pendukung Minyak, Gas & Batu Bara":LineIcons.fire,
    "Barang Rumah Tangga":LineIcons.couch,
    "Perusahaan Holding Multi-sektor":LineIcons.city,
    "Kelistrikan":LineIcons.plug,
    "Perusahaan Holding & Investasi":LineIcons.handHoldingUsDollar,
    "Peralatan Jaringan":LineIcons.ethernet,
    "Ritel Khusus":LineIcons.store,
    "Perangkat Komputer":LineIcons.desktop,
    "Utilitas Listrik":LineIcons.plug,
    "Bahan Bakar Alternatif":LineIcons.solarPanel,
    "Pakaian & Barang Mewah":LineIcons.tShirt,
    "Batu Bara":LineIcons.fire,
    "Produk Makanan Pertanian":LineIcons.tractor,
  };
}
