import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icons.dart';

class Globals {
  static String apiURL = (dotenv.env['API_URL'] ?? 'http://192.168.1.176:1337/');
  static int apiTimeOut = 30;

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
  static String apiPriceGold = '${apiURL}api/price-golds';
  
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

  static String runAs() {
    if (kIsWasm) {
      return " run as WASM";
    }
    if (kIsWeb) {
      return " run as JS";
    }
    return "";
  }

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
    "Barang Baku":LucideIcons.wheat,
    "Barang Konsumen Non-Primer":LucideIcons.shirt,
    "Barang Konsumen Primer":LucideIcons.beef,
    "Energi":LucideIcons.zap,
    "Infrastruktur":LucideIcons.building,
    "Kesehatan":LucideIcons.stethoscope,
    "Keuangan":LucideIcons.landmark,
    "Perindustrian":LucideIcons.factory,
    "Properti & Real Estat":LucideIcons.land_plot,
    "TRADE, SERVICES, & INVESTMENT":LucideIcons.piggy_bank,
    "Teknologi":LucideIcons.cpu,
    "Transportasi & Logistik":LucideIcons.forklift,
  };

  static Map<String, String> sectorName = {
    "Barang Baku":"Barang Baku",
    "Barang Konsumen Non-Primer":"Barang Konsumen Non-Primer",
    "Barang Konsumen Primer":"Barang Konsumen Primer",
    "Energi":"Energi",
    "Infrastruktur":"Infrastruktur",
    "Kesehatan":"Kesehatan",
    "Keuangan":"Keuangan",
    "Perindustrian":"Perindustrian",
    "Properti & Real Estat":"Properti & Real Estat",
    "Teknologi":"Teknologi",
    "Transportasi & Logistik":"Transportasi & Logistik",
  };

  static Map<String, IconData> subSectorIcon = {
    "Asuransi": LineIcons.carCrash,
    "Bank": LineIcons.university,
    "Barang Baku": LineIcons.egg,
    "Barang Perindustrian": LineIcons.industry,
    "Barang Rekreasi": LucideIcons.toy_brick,
    "Barang Rumah Tangga": LucideIcons.lamp_floor,
    "Energi Alternatif": LucideIcons.atom,
    "Farmasi & Riset Kesehatan": LucideIcons.pill,
    "Infrastruktur Transportasi": LucideIcons.truck,
    "Jasa & Peralatan Kesehatan": LucideIcons.stethoscope,
    "Jasa Investasi": LucideIcons.circle_dollar_sign,
    "Jasa Konsumen": LucideIcons.hand_platter,
    "Jasa Pembiayaan": LucideIcons.hand_coins,
    "Jasa Perindustrian": LucideIcons.forklift,
    "Konstruksi Bangunan": LucideIcons.hard_hat,
    "Logistik & Pengantaran": LucideIcons.package,
    "Makanan & Minuman": LucideIcons.cup_soda,
    "Media & Hiburan": LucideIcons.clapperboard,
    "Minyak, Gas & Batu Bara": LucideIcons.fuel,
    "Otomotif & Komponen Otomotif": LucideIcons.car,
    "Pakaian & Barang Mewah": LucideIcons.watch,
    "Perangkat Keras & Peralatan Teknologi": LucideIcons.monitor_smartphone,
    "Perangkat Lunak & Jasa TI": LucideIcons.app_window,
    "Perdagangan Ritel": LucideIcons.shopping_cart,
    "Perdagangan Ritel Barang Primer": LucideIcons.shopping_basket,
    "Perusahaan Holding & Investasi": LucideIcons.landmark,
    "Perusahaan Holding Multi Sektor": LucideIcons.square_stack,
    "Produk Rumah Tangga Tidak Tahan Lama": LucideIcons.beef,
    "Properti & Real Estat": LucideIcons.building,
    "Rokok": LucideIcons.cigarette,
    "Telekomunikasi": LucideIcons.phone,
    "Transportasi": LucideIcons.train_front,
    "Utilitas": LucideIcons.wrench,
    "Wholesale (Durable & Non Durable Goods)": LucideIcons.baggage_claim,
  };

  // icon list for industry
  static Map<String, IconData> industryIcon = {
    "Aplikasi & Jasa Internet":LineIcons.wifi,
    "Asuransi":LineIcons.carCrash,
    "Bahan Bakar Alternatif":LineIcons.solarPanel,
    "Bank":LineIcons.university,
    "Barang Kimia":LineIcons.flask,
    "Barang Rumah Tangga":LineIcons.couch,
    "Batu Bara":LineIcons.fire,
    "Department Store":LineIcons.alternateStore,
    "Distributor Barang Konsumen":LineIcons.truck,
    "Farmasi":LineIcons.flask,
    "Hiburan & Film":LineIcons.film,
    "Jasa & Konsultan TI":LineIcons.server,
    "Jasa Investasi":LineIcons.piggyBank,
    "Jasa Komersial":LineIcons.store,
    "Jasa Profesional":LineIcons.userTie,
    "Jasa Telekomunikasi Nirkabel":LineIcons.wifi,
    "Jasa Telekomunikasi":LineIcons.phone,
    "Kelistrikan":LineIcons.plug,
    "Komponen Otomotif":LineIcons.cog,
    "Konstruksi Bangunan":LineIcons.wrench,
    "Logam & Mineral":LineIcons.eraser,
    "Logistik & Pengantaran":LineIcons.truck,
    "Machinery":LineIcons.wrench,
    "Makanan Olahan":LineIcons.hamburger,
    "Maskapai Penerbangan":LineIcons.planeDeparture,
    "Material Konstruksi":LineIcons.warehouse,
    "Media":LineIcons.photoVideo,
    "Minuman":LineIcons.beer,
    "Minyak & Gas":LineIcons.oilCan,
    "Operator Infrastruktur Transportasi":LineIcons.bus,
    "Pakaian & Barang Mewah":LineIcons.tShirt,
    "Pariwisata & Rekreasi":LineIcons.campground,
    "Pembiayaan Konsumen":LineIcons.users,
    "Pendidikan & Jasa Penunjang":LineIcons.school,
    "Pendukung Minyak, Gas & Batu Bara":LineIcons.fire,
    "Pengangkutan Darat Penumpang":LineIcons.shuttleVan,
    "Pengelola & Pengembang Real Estat":LineIcons.home,
    "Penyedia Jasa Kesehatan":LineIcons.stethoscope,
    "Peralatan & Perlengkapan Kesehatan":LineIcons.stethoscope,
    "Peralatan Energi Alternatif":LineIcons.alternateRadiation,
    "Peralatan Jaringan":LineIcons.ethernet,
    "Peralatan Olah Raga & Barang Hobi":LineIcons.bicycle,
    "Perangkat Komputer":LineIcons.desktop,
    "Perangkat Lunak":LineIcons.laptopCode,
    "Perangkat, Instrumen & Komponen Elektronik":LineIcons.plug,
    "Perdagangan Aneka Barang Perindustrian":LineIcons.alternateStore,
    "Perdagangan Ritel Barang Primer":LineIcons.hamburger,
    "Perhutanan & Kertas":LineIcons.scroll,
    "Perusahaan Holding & Investasi":LineIcons.handHoldingUsDollar,
    "Perusahaan Holding Multi-sektor":LineIcons.city,
    "Produk & Perlengkapan Bangunan":LineIcons.wrench,
    "Produk Keperluan Rumah Tangga":LineIcons.couch,
    "Produk Makanan Pertanian":LineIcons.tractor,
    "Produk Perawatan Tubuh":LineIcons.eyeDropper,
    "Ritel Khusus":LineIcons.store,
    "Rokok":LineIcons.smoking,
    "Utilitas Gas":LineIcons.gasPump,
    "Utilitas Listrik":LineIcons.plug,
    "Wadah & Kemasan":LineIcons.shoppingBag,
  };
}
