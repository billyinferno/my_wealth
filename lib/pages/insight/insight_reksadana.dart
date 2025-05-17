import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_wealth/_index.g.dart';

enum InsightReksadanaPageEnum {
  saham,
  campuran,
  pasarUang,
  pendapatanTetap,
}

class InsightReksadanaPage extends StatefulWidget {
  const InsightReksadanaPage({super.key});

  @override
  State<InsightReksadanaPage> createState() => _InsightReksadanaPageState();
}

class _InsightReksadanaPageState extends State<InsightReksadanaPage> {
  final ScrollController _scrollController = ScrollController();
  final InsightAPI _insightAPI = InsightAPI();

  late InsightReksadanaPageEnum _selectedReksadanaPage;

  @override
  void initState() {
    super.initState();

    // initialize the reksadana page
    _selectedReksadanaPage = InsightReksadanaPageEnum.saham;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: accentColor,
      onRefresh: (() async {
        await _getInsightReksadanaInformation().onError((error, stackTrace) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(createSnackBar(message: error.toString()));
          }
        },).then((_) {
          // once finished just do rebuild so we can get all the latest data from provide since we didn't
          // set the provide as listen on above async call
          setState(() {
            // just rebuild
          });
        });
      }),
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            ScrollSegmentedControl<InsightReksadanaPageEnum>(
              data: const {
                InsightReksadanaPageEnum.saham: "Saham",
                InsightReksadanaPageEnum.campuran: "Campuran",
                InsightReksadanaPageEnum.pasarUang: "Pasar Uang",
                InsightReksadanaPageEnum.pendapatanTetap: "Pendapatan Tetap",
              },
              onPress: ((value) {
                setState(() {
                  _selectedReksadanaPage = value;
                });
              }),
            ),
            const SizedBox(height: 10,),
            _showPage(),
          ],
        ),
      ),
    );
  }

  Widget _showPage() {
    switch(_selectedReksadanaPage) {
      case InsightReksadanaPageEnum.saham:
        return InsightReksadanaTopLoserSubPage(
          type: 'saham',
          title: 'Saham',
        );
      case InsightReksadanaPageEnum.campuran:
        return InsightReksadanaTopLoserSubPage(
          type: 'campuran',
          title: 'Campuran',
        );
      case InsightReksadanaPageEnum.pasarUang:
        return InsightReksadanaTopLoserSubPage(
          type: 'pasaruang',
          title: 'Pasar Uang',
        );
      case InsightReksadanaPageEnum.pendapatanTetap:
        return InsightReksadanaTopLoserSubPage(
          type: 'pendapatantetap',
          title: 'Pendapatan Tetap',
        );
    }
  }

  Future<void> _getInsightReksadanaInformation() async {
    TopWorseCompanyListModel? topSaham;
    TopWorseCompanyListModel? topCampuran;
    TopWorseCompanyListModel? topPasarUang;
    TopWorseCompanyListModel? topPendapatanTetap;
    TopWorseCompanyListModel? worseSaham;
    TopWorseCompanyListModel? worseCampuran;
    TopWorseCompanyListModel? worsePasarUang;
    TopWorseCompanyListModel? worsePendapatanTetap;

    // show loading screen
    LoadingScreen.instance().show(context: context);

    // get the insight reksadana information
    await Future.wait([
      _insightAPI.getTopWorseReksadana(
        type: 'saham',
        topWorse: 'top',
      ).then((resp) async {
        Log.success(message: "🔃 Refresh Reksdana Saham Top");
        await InsightSharedPreferences.setTopReksadanaList(
          type: 'saham',
          topReksadanaList: resp
        );
        topSaham = resp;
      }),

      _insightAPI.getTopWorseReksadana(
        type: 'campuran',
        topWorse: 'top',
      ).then((resp) async {
        Log.success(message: "🔃 Refresh Reksadana Campuran Top");
        await InsightSharedPreferences.setTopReksadanaList(
          type: 'campuran',
          topReksadanaList: resp
        );
        topCampuran = resp;
      }),

      _insightAPI.getTopWorseReksadana(
        type: 'pasaruang',
        topWorse: 'top',
      ).then((resp) async {
        Log.success(message: "🔃 Refresh Reksadana Pasar Uang Top");
        await InsightSharedPreferences.setTopReksadanaList(
          type: 'pasaruang',
          topReksadanaList: resp
        );
        topPasarUang = resp;
      }),

      _insightAPI.getTopWorseReksadana(
        type: 'pendapatantetap',
        topWorse: 'top',
      ).then((resp) async {
        Log.success(message: "🔃 Refresh Reksadana Pendapatan Tetap Top");
        await InsightSharedPreferences.setTopReksadanaList(
          type: 'pendapatantetap',
          topReksadanaList: resp
        );
        topPendapatanTetap = resp;
      }),

      _insightAPI.getTopWorseReksadana(
        type: 'saham',
        topWorse: 'loser',
      ).then((resp) async {
        Log.success(message: "🔃 Refresh Reksdana Saham Loser");
        await InsightSharedPreferences.setWorseReksadanaList(
          type: 'saham',
          worseReksadanaList: resp
        );
        worseSaham = resp;
      }),

      _insightAPI.getTopWorseReksadana(
        type: 'campuran',
        topWorse: 'loser',
      ).then((resp) async {
        Log.success(message: "🔃 Refresh Reksadana Campuran");
        await InsightSharedPreferences.setWorseReksadanaList(
          type: 'campuran',
          worseReksadanaList: resp
        );
        worseCampuran = resp;
      }),

      _insightAPI.getTopWorseReksadana(
        type: 'pasaruang',
        topWorse: 'loser',
      ).then((resp) async {
        Log.success(message: "🔃 Refresh Reksadana Pasar Uang");
        await InsightSharedPreferences.setWorseReksadanaList(
          type: 'pasaruang',
          worseReksadanaList: resp
        );
        worsePasarUang = resp;
      }),

      _insightAPI.getTopWorseReksadana(
        type: 'pendapatantetap',
        topWorse: 'loser',
      ).then((resp) async {
        Log.success(message: "🔃 Refresh Reksadana Pendapatan Tetap");
        await InsightSharedPreferences.setWorseReksadanaList(
          type: 'pendapatantetap',
          worseReksadanaList: resp
        );
        worsePendapatanTetap = resp;
      }),
    ]).then((_) {
      // if all good then we can set the provider
      if (mounted && (
        topSaham != null && topCampuran != null && topPasarUang != null && topPendapatanTetap != null &&
        worseSaham != null && worseCampuran != null && worsePasarUang != null && worsePendapatanTetap != null
      )) {
        Provider.of<InsightProvider>(context, listen: false).setTopReksadanaList(
          type: 'saham', data: topSaham!
        );
        Provider.of<InsightProvider>(context, listen: false).setTopReksadanaList(
          type: 'campuran', data: topCampuran!
        );
        Provider.of<InsightProvider>(context, listen: false).setTopReksadanaList(
          type: 'pasaruang', data: topPasarUang!
        );
        Provider.of<InsightProvider>(context, listen: false).setTopReksadanaList(
          type: 'pendapatantetap', data: topPendapatanTetap!
        );
        Provider.of<InsightProvider>(context, listen: false).setWorseReksadanaList(
          type: 'saham', data: worseSaham!
        );
        Provider.of<InsightProvider>(context, listen: false).setWorseReksadanaList(
          type: 'campuran', data: worseCampuran!
        );
        Provider.of<InsightProvider>(context, listen: false).setWorseReksadanaList(
          type: 'pasaruang', data: worsePasarUang!
        );
        Provider.of<InsightProvider>(context, listen: false).setWorseReksadanaList(
          type: 'pendapatantetap', data: worsePendapatanTetap!
        );
      }
    }).onError((error, stackTrace) {
      Log.error(
        message: 'Error getting reksadana top and worse information',
        error: error,
        stackTrace: stackTrace,
      );

      throw Exception('Error when get reksdanda top and worse information');
    },).whenComplete(() {
      // remove loading screen
      LoadingScreen.instance().hide();
    },);
  }
}