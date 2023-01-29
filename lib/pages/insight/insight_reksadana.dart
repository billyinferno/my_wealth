import 'package:flutter/material.dart';
import 'package:my_wealth/api/company_api.dart';
import 'package:my_wealth/api/insight_api.dart';
import 'package:my_wealth/model/top_worse_company_list_model.dart';
import 'package:my_wealth/provider/inisght_provider.dart';
import 'package:my_wealth/themes/colors.dart';
import 'package:my_wealth/utils/arguments/company_detail_args.dart';
import 'package:my_wealth/utils/dialog/create_snack_bar.dart';
import 'package:my_wealth/utils/function/format_currency.dart';
import 'package:my_wealth/utils/loader/show_loader_dialog.dart';
import 'package:my_wealth/utils/prefs/shared_insight.dart';
import 'package:my_wealth/widgets/selectable_button.dart';
import 'package:provider/provider.dart';

class InsightReksadanaPage extends StatefulWidget {
  const InsightReksadanaPage({Key? key}) : super(key: key);

  @override
  State<InsightReksadanaPage> createState() => _InsightReksadanaPageState();
}

class _InsightReksadanaPageState extends State<InsightReksadanaPage> {
  final ScrollController _scrollController = ScrollController();
  final InsightAPI _insightAPI = InsightAPI();
  final CompanyAPI _companyAPI = CompanyAPI();

  late Map<String, TopWorseCompanyListModel> _topReksadanaList;
  late Map<String, TopWorseCompanyListModel> _worseReksadanaList;

  String _topSahamPeriodSelected = '1d';
  String _topCampuranPeriodSelected = '1d';
  String _topPasaruangPeriodSelected = '1d';
  String _topPendapatantetapPeriodSelected = '1d';

  String _worseSahamPeriodSelected = '1d';
  String _worseCampuranPeriodSelected = '1d';
  String _worsePasaruangPeriodSelected = '1d';
  String _worsePendapatantetapPeriodSelected = '1d';

  @override
  void initState() {
    // initialize top reksadana list with empty map
    _topReksadanaList = {};
    _worseReksadanaList = {};

    // now get all the information from the shared preferences and put it on the topReksadanaList
    _topReksadanaList['saham'] = InsightSharedPreferences.getTopReksadanaList('saham');
    _topReksadanaList['campuran'] = InsightSharedPreferences.getTopReksadanaList('campuran');
    _topReksadanaList['pasaruang'] = InsightSharedPreferences.getTopReksadanaList('pasaruang');
    _topReksadanaList['pendapatantetap'] = InsightSharedPreferences.getTopReksadanaList('pendapatantetap');

    // then get the worse lit and put it on the worseReksadanaList
    _worseReksadanaList['saham'] = InsightSharedPreferences.getWorseReksadanaList('saham');
    _worseReksadanaList['campuran'] = InsightSharedPreferences.getWorseReksadanaList('campuran');
    _worseReksadanaList['pasaruang'] = InsightSharedPreferences.getWorseReksadanaList('pasaruang');
    _worseReksadanaList['pendapatantetap'] = InsightSharedPreferences.getWorseReksadanaList('pendapatantetap');

    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<InsightProvider>(
      builder: ((context, insightProvider, child) {
        // get the data from provider and put on map
        _topReksadanaList['saham'] = insightProvider.topReksadanaList!['saham'] ?? TopWorseCompanyListModel(companyList: CompanyList(the1D: [], the1M: [], the1W: [], the1Y: [], the3M: [], the3Y: [], the5Y: [], the6M: [], theYTD: [], theMTD: []));
        _topReksadanaList['campuran'] = insightProvider.topReksadanaList!['campuran'] ?? TopWorseCompanyListModel(companyList: CompanyList(the1D: [], the1M: [], the1W: [], the1Y: [], the3M: [], the3Y: [], the5Y: [], the6M: [], theYTD: [], theMTD: []));
        _topReksadanaList['pasaruang'] = insightProvider.topReksadanaList!['pasaruang'] ?? TopWorseCompanyListModel(companyList: CompanyList(the1D: [], the1M: [], the1W: [], the1Y: [], the3M: [], the3Y: [], the5Y: [], the6M: [], theYTD: [], theMTD: []));
        _topReksadanaList['pendapatantetap'] = insightProvider.topReksadanaList!['pendapatantetap'] ?? TopWorseCompanyListModel(companyList: CompanyList(the1D: [], the1M: [], the1W: [], the1Y: [], the3M: [], the3Y: [], the5Y: [], the6M: [], theYTD: [], theMTD: []));

        _worseReksadanaList['saham'] = insightProvider.worseReksadanaList!['saham'] ?? TopWorseCompanyListModel(companyList: CompanyList(the1D: [], the1M: [], the1W: [], the1Y: [], the3M: [], the3Y: [], the5Y: [], the6M: [], theYTD: [], theMTD: []));
        _worseReksadanaList['campuran'] = insightProvider.worseReksadanaList!['campuran'] ?? TopWorseCompanyListModel(companyList: CompanyList(the1D: [], the1M: [], the1W: [], the1Y: [], the3M: [], the3Y: [], the5Y: [], the6M: [], theYTD: [], theMTD: []));
        _worseReksadanaList['pasaruang'] = insightProvider.worseReksadanaList!['pasaruang'] ?? TopWorseCompanyListModel(companyList: CompanyList(the1D: [], the1M: [], the1W: [], the1Y: [], the3M: [], the3Y: [], the5Y: [], the6M: [], theYTD: [], theMTD: []));
        _worseReksadanaList['pendapatantetap'] = insightProvider.worseReksadanaList!['pendapatantetap'] ?? TopWorseCompanyListModel(companyList: CompanyList(the1D: [], the1M: [], the1W: [], the1Y: [], the3M: [], the3Y: [], the5Y: [], the6M: [], theYTD: [], theMTD: []));

        return RefreshIndicator(
          color: accentColor,
          onRefresh: (() async {
            await Future.microtask(() async {
              showLoaderDialog(context);
              // get top list
              await _insightAPI.getTopWorseReksadana('saham', 'top').then((resp) async {
                debugPrint("🔃 Refresh Reksdana Saham");
                await InsightSharedPreferences.setTopReksadanaList('saham', resp);
                if (!mounted) return;
                Provider.of<InsightProvider>(context, listen: false).setTopReksadanaList('saham', resp);
              });
              await _insightAPI.getTopWorseReksadana('campuran', 'top').then((resp) async {
                debugPrint("🔃 Refresh Reksadana Campuran");
                await InsightSharedPreferences.setTopReksadanaList('campuran', resp);
                if (!mounted) return;
                Provider.of<InsightProvider>(context, listen: false).setTopReksadanaList('campuran', resp);
              });
              await _insightAPI.getTopWorseReksadana('pasaruang', 'top').then((resp) async {
                debugPrint("🔃 Refresh Reksadana Pasar Uang");
                await InsightSharedPreferences.setTopReksadanaList('pasaruang', resp);
                if (!mounted) return;
                Provider.of<InsightProvider>(context, listen: false).setTopReksadanaList('pasaruang', resp);
              });
              await _insightAPI.getTopWorseReksadana('pendapatantetap', 'top').then((resp) async {
                debugPrint("🔃 Refresh Reksadana Pendapatan Tetap");
                await InsightSharedPreferences.setTopReksadanaList('pendapatantetap', resp);
                if (!mounted) return;
                Provider.of<InsightProvider>(context, listen: false).setTopReksadanaList('pendapatantetap', resp);
              });
              // get worse list
              await _insightAPI.getTopWorseReksadana('saham', 'loser').then((resp) async {
                debugPrint("🔃 Refresh Reksdana Saham");
                await InsightSharedPreferences.setWorseReksadanaList('saham', resp);
                if (!mounted) return;
                Provider.of<InsightProvider>(context, listen: false).setWorseReksadanaList('saham', resp);
              });
              await _insightAPI.getTopWorseReksadana('campuran', 'loser').then((resp) async {
                debugPrint("🔃 Refresh Reksadana Campuran");
                await InsightSharedPreferences.setWorseReksadanaList('campuran', resp);
                if (!mounted) return;
                Provider.of<InsightProvider>(context, listen: false).setWorseReksadanaList('campuran', resp);
              });
              await _insightAPI.getTopWorseReksadana('pasaruang', 'loser').then((resp) async {
                debugPrint("🔃 Refresh Reksadana Pasar Uang");
                await InsightSharedPreferences.setWorseReksadanaList('pasaruang', resp);
                if (!mounted) return;
                Provider.of<InsightProvider>(context, listen: false).setWorseReksadanaList('pasaruang', resp);
              });
              await _insightAPI.getTopWorseReksadana('pendapatantetap', 'loser').then((resp) async {
                debugPrint("🔃 Refresh Reksadana Pendapatan Tetap");
                await InsightSharedPreferences.setWorseReksadanaList('pendapatantetap', resp);
                if (!mounted) return;
                Provider.of<InsightProvider>(context, listen: false).setWorseReksadanaList('pendapatantetap', resp);
              });
            }).onError((error, stackTrace) {
              debugPrintStack(stackTrace: stackTrace);
              ScaffoldMessenger.of(context).showSnackBar(createSnackBar(message: "Error when refresh reksadana insight"));
            }).whenComplete(() {
              // remove the loader
              Navigator.pop(context);
            });
            
            // once finished just do rebuild so we can get all the latest data from provide since we didn't
            // set the provide as listen on above async call
            setState(() {
              // just rebuild
            });
          }),
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 10,),
                const Center(
                  child: Text(
                    "Top Gain Saham",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 10,),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SelectableButton(
                      text: "1d",
                      selected: (_topSahamPeriodSelected == "1d"),
                      onPress: (() {
                        _setTopSahamPeriodSelected('1d');
                      })
                    ),
                    SelectableButton(
                      text: "1w",
                      selected: (_topSahamPeriodSelected == "1w"),
                      onPress: (() {
                        _setTopSahamPeriodSelected('1w');
                      })
                    ),
                    SelectableButton(
                      text: "1m",
                      selected: (_topSahamPeriodSelected == "1m"),
                      onPress: (() {
                        _setTopSahamPeriodSelected('1m');
                      })
                    ),
                    SelectableButton(
                      text: "3m",
                      selected: (_topSahamPeriodSelected == "3m"),
                      onPress: (() {
                        _setTopSahamPeriodSelected('3m');
                      })
                    ),
                    SelectableButton(
                      text: "6m",
                      selected: (_topSahamPeriodSelected == "6m"),
                      onPress: (() {
                        _setTopSahamPeriodSelected('6m');
                      })
                    ),
                    SelectableButton(
                      text: "ytd",
                      selected: (_topSahamPeriodSelected == "ytd"),
                      onPress: (() {
                        _setTopSahamPeriodSelected('ytd');
                      })
                    ),
                    SelectableButton(
                      text: "1y",
                      selected: (_topSahamPeriodSelected == "1y"),
                      onPress: (() {
                        _setTopSahamPeriodSelected('1y');
                      })
                    ),
                  ],
                ),
                const SizedBox(height: 10,),
                _generateTopWorseList(reksadanaList: _topReksadanaList, type: 'saham', period: _topSahamPeriodSelected, codeColor: accentColor, gainColor: Colors.green),
                const SizedBox(height: 20,),
                ///
                const Center(
                  child: Text(
                    "Top Loser Saham",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 10,),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SelectableButton(
                      text: "1d",
                      selected: (_worseSahamPeriodSelected == "1d"),
                      onPress: (() {
                        _setWorseSahamPeriodSelected('1d');
                      })
                    ),
                    SelectableButton(
                      text: "1w",
                      selected: (_worseSahamPeriodSelected == "1w"),
                      onPress: (() {
                        _setWorseSahamPeriodSelected('1w');
                      })
                    ),
                    SelectableButton(
                      text: "1m",
                      selected: (_worseSahamPeriodSelected == "1m"),
                      onPress: (() {
                        _setWorseSahamPeriodSelected('1m');
                      })
                    ),
                    SelectableButton(
                      text: "3m",
                      selected: (_worseSahamPeriodSelected == "3m"),
                      onPress: (() {
                        _setWorseSahamPeriodSelected('3m');
                      })
                    ),
                    SelectableButton(
                      text: "6m",
                      selected: (_worseSahamPeriodSelected == "6m"),
                      onPress: (() {
                        _setWorseSahamPeriodSelected('6m');
                      })
                    ),
                    SelectableButton(
                      text: "ytd",
                      selected: (_worseSahamPeriodSelected == "ytd"),
                      onPress: (() {
                        _setWorseSahamPeriodSelected('ytd');
                      })
                    ),
                    SelectableButton(
                      text: "1y",
                      selected: (_worseSahamPeriodSelected == "1y"),
                      onPress: (() {
                        _setWorseSahamPeriodSelected('1y');
                      })
                    ),
                  ],
                ),
                const SizedBox(height: 10,),
                _generateTopWorseList(reksadanaList: _worseReksadanaList, type: 'saham', period: _worseSahamPeriodSelected, codeColor: accentColor, gainColor: Colors.red),
                const SizedBox(height: 20,),
                ///
                const Center(
                  child: Text(
                    "Top Gain Campuran",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 10,),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SelectableButton(
                      text: "1d",
                      selected: (_topCampuranPeriodSelected == "1d"),
                      onPress: (() {
                        _setTopCampuranPeriodSelected('1d');
                      })
                    ),
                    SelectableButton(
                      text: "1w",
                      selected: (_topCampuranPeriodSelected == "1w"),
                      onPress: (() {
                        _setTopCampuranPeriodSelected('1w');
                      })
                    ),
                    SelectableButton(
                      text: "1m",
                      selected: (_topCampuranPeriodSelected == "1m"),
                      onPress: (() {
                        _setTopCampuranPeriodSelected('1m');
                      })
                    ),
                    SelectableButton(
                      text: "3m",
                      selected: (_topCampuranPeriodSelected == "3m"),
                      onPress: (() {
                        _setTopCampuranPeriodSelected('3m');
                      })
                    ),
                    SelectableButton(
                      text: "6m",
                      selected: (_topCampuranPeriodSelected == "6m"),
                      onPress: (() {
                        _setTopCampuranPeriodSelected('6m');
                      })
                    ),
                    SelectableButton(
                      text: "ytd",
                      selected: (_topCampuranPeriodSelected == "ytd"),
                      onPress: (() {
                        _setTopCampuranPeriodSelected('ytd');
                      })
                    ),
                    SelectableButton(
                      text: "1y",
                      selected: (_topCampuranPeriodSelected == "1y"),
                      onPress: (() {
                        _setTopCampuranPeriodSelected('1y');
                      })
                    ),
                  ],
                ),
                const SizedBox(height: 10,),
                _generateTopWorseList(reksadanaList: _topReksadanaList, type: 'campuran', period: _topCampuranPeriodSelected, codeColor: accentColor, gainColor: Colors.green),
                const SizedBox(height: 20,),
                ///
                const Center(
                  child: Text(
                    "Top Loser Campuran",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 10,),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SelectableButton(
                      text: "1d",
                      selected: (_worseCampuranPeriodSelected == "1d"),
                      onPress: (() {
                        _setWorseCampuranPeriodSelected('1d');
                      })
                    ),
                    SelectableButton(
                      text: "1w",
                      selected: (_worseCampuranPeriodSelected == "1w"),
                      onPress: (() {
                        _setWorseCampuranPeriodSelected('1w');
                      })
                    ),
                    SelectableButton(
                      text: "1m",
                      selected: (_worseCampuranPeriodSelected == "1m"),
                      onPress: (() {
                        _setWorseCampuranPeriodSelected('1m');
                      })
                    ),
                    SelectableButton(
                      text: "3m",
                      selected: (_worseCampuranPeriodSelected == "3m"),
                      onPress: (() {
                        _setWorseCampuranPeriodSelected('3m');
                      })
                    ),
                    SelectableButton(
                      text: "6m",
                      selected: (_worseCampuranPeriodSelected == "6m"),
                      onPress: (() {
                        _setWorseCampuranPeriodSelected('6m');
                      })
                    ),
                    SelectableButton(
                      text: "ytd",
                      selected: (_worseCampuranPeriodSelected == "ytd"),
                      onPress: (() {
                        _setWorseCampuranPeriodSelected('ytd');
                      })
                    ),
                    SelectableButton(
                      text: "1y",
                      selected: (_worseCampuranPeriodSelected == "1y"),
                      onPress: (() {
                        _setWorseCampuranPeriodSelected('1y');
                      })
                    ),
                  ],
                ),
                const SizedBox(height: 10,),
                _generateTopWorseList(reksadanaList: _worseReksadanaList, type: 'campuran', period: _worseCampuranPeriodSelected, codeColor: accentColor, gainColor: Colors.red),
                const SizedBox(height: 20,),
                ///
                const Center(
                  child: Text(
                    "Top Gain Pasar Uang",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 10,),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SelectableButton(
                      text: "1d",
                      selected: (_topPasaruangPeriodSelected == "1d"),
                      onPress: (() {
                        _setTopPasaruangPeriodSelected('1d');
                      })
                    ),
                    SelectableButton(
                      text: "1w",
                      selected: (_topPasaruangPeriodSelected == "1w"),
                      onPress: (() {
                        _setTopPasaruangPeriodSelected('1w');
                      })
                    ),
                    SelectableButton(
                      text: "1m",
                      selected: (_topPasaruangPeriodSelected == "1m"),
                      onPress: (() {
                        _setTopPasaruangPeriodSelected('1m');
                      })
                    ),
                    SelectableButton(
                      text: "3m",
                      selected: (_topPasaruangPeriodSelected == "3m"),
                      onPress: (() {
                        _setTopPasaruangPeriodSelected('3m');
                      })
                    ),
                    SelectableButton(
                      text: "6m",
                      selected: (_topPasaruangPeriodSelected == "6m"),
                      onPress: (() {
                        _setTopPasaruangPeriodSelected('6m');
                      })
                    ),
                    SelectableButton(
                      text: "ytd",
                      selected: (_topPasaruangPeriodSelected == "ytd"),
                      onPress: (() {
                        _setTopPasaruangPeriodSelected('ytd');
                      })
                    ),
                    SelectableButton(
                      text: "1y",
                      selected: (_topPasaruangPeriodSelected == "1y"),
                      onPress: (() {
                        _setTopPasaruangPeriodSelected('1y');
                      })
                    ),
                  ],
                ),
                const SizedBox(height: 10,),
                _generateTopWorseList(reksadanaList: _topReksadanaList, type: 'pasaruang', period: _topPasaruangPeriodSelected, codeColor: accentColor, gainColor: Colors.green),
                const SizedBox(height: 20,),
                ///
                const Center(
                  child: Text(
                    "Top Loser Pasar Uang",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 10,),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SelectableButton(
                      text: "1d",
                      selected: (_worsePasaruangPeriodSelected == "1d"),
                      onPress: (() {
                        _setWorsePasaruangPeriodSelected('1d');
                      })
                    ),
                    SelectableButton(
                      text: "1w",
                      selected: (_worsePasaruangPeriodSelected == "1w"),
                      onPress: (() {
                        _setWorsePasaruangPeriodSelected('1w');
                      })
                    ),
                    SelectableButton(
                      text: "1m",
                      selected: (_worsePasaruangPeriodSelected == "1m"),
                      onPress: (() {
                        _setWorsePasaruangPeriodSelected('1m');
                      })
                    ),
                    SelectableButton(
                      text: "3m",
                      selected: (_worsePasaruangPeriodSelected == "3m"),
                      onPress: (() {
                        _setWorsePasaruangPeriodSelected('3m');
                      })
                    ),
                    SelectableButton(
                      text: "6m",
                      selected: (_worsePasaruangPeriodSelected == "6m"),
                      onPress: (() {
                        _setWorsePasaruangPeriodSelected('6m');
                      })
                    ),
                    SelectableButton(
                      text: "ytd",
                      selected: (_worsePasaruangPeriodSelected == "ytd"),
                      onPress: (() {
                        _setWorsePasaruangPeriodSelected('ytd');
                      })
                    ),
                    SelectableButton(
                      text: "1y",
                      selected: (_worsePasaruangPeriodSelected == "1y"),
                      onPress: (() {
                        _setWorsePasaruangPeriodSelected('1y');
                      })
                    ),
                  ],
                ),
                const SizedBox(height: 10,),
                _generateTopWorseList(reksadanaList: _worseReksadanaList, type: 'pasaruang', period: _worsePasaruangPeriodSelected, codeColor: accentColor, gainColor: Colors.red),
                const SizedBox(height: 20,),
                ///
                const Center(
                  child: Text(
                    "Top Gain Pendapatan Tetap",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 10,),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SelectableButton(
                      text: "1d",
                      selected: (_topPendapatantetapPeriodSelected == "1d"),
                      onPress: (() {
                        _setTopPendapatanTetapPeriodSelected('1d');
                      })
                    ),
                    SelectableButton(
                      text: "1w",
                      selected: (_topPendapatantetapPeriodSelected == "1w"),
                      onPress: (() {
                        _setTopPendapatanTetapPeriodSelected('1w');
                      })
                    ),
                    SelectableButton(
                      text: "1m",
                      selected: (_topPendapatantetapPeriodSelected == "1m"),
                      onPress: (() {
                        _setTopPendapatanTetapPeriodSelected('1m');
                      })
                    ),
                    SelectableButton(
                      text: "3m",
                      selected: (_topPendapatantetapPeriodSelected == "3m"),
                      onPress: (() {
                        _setTopPendapatanTetapPeriodSelected('3m');
                      })
                    ),
                    SelectableButton(
                      text: "6m",
                      selected: (_topPendapatantetapPeriodSelected == "6m"),
                      onPress: (() {
                        _setTopPendapatanTetapPeriodSelected('6m');
                      })
                    ),
                    SelectableButton(
                      text: "ytd",
                      selected: (_topPendapatantetapPeriodSelected == "ytd"),
                      onPress: (() {
                        _setTopPendapatanTetapPeriodSelected('ytd');
                      })
                    ),
                    SelectableButton(
                      text: "1y",
                      selected: (_topPendapatantetapPeriodSelected == "1y"),
                      onPress: (() {
                        _setTopPendapatanTetapPeriodSelected('1y');
                      })
                    ),
                  ],
                ),
                const SizedBox(height: 10,),
                _generateTopWorseList(reksadanaList: _topReksadanaList, type: 'pendapatantetap', period: _topPendapatantetapPeriodSelected, codeColor: accentColor, gainColor: Colors.green),
                const SizedBox(height: 20,),
                ///
                const Center(
                  child: Text(
                    "Top Loser Pendapatan Tetap",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 10,),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SelectableButton(
                      text: "1d",
                      selected: (_worsePendapatantetapPeriodSelected == "1d"),
                      onPress: (() {
                        _setWorsePendapatanTetapPeriodSelected('1d');
                      })
                    ),
                    SelectableButton(
                      text: "1w",
                      selected: (_worsePendapatantetapPeriodSelected == "1w"),
                      onPress: (() {
                        _setWorsePendapatanTetapPeriodSelected('1w');
                      })
                    ),
                    SelectableButton(
                      text: "1m",
                      selected: (_worsePendapatantetapPeriodSelected == "1m"),
                      onPress: (() {
                        _setWorsePendapatanTetapPeriodSelected('1m');
                      })
                    ),
                    SelectableButton(
                      text: "3m",
                      selected: (_worsePendapatantetapPeriodSelected == "3m"),
                      onPress: (() {
                        _setWorsePendapatanTetapPeriodSelected('3m');
                      })
                    ),
                    SelectableButton(
                      text: "6m",
                      selected: (_worsePendapatantetapPeriodSelected == "6m"),
                      onPress: (() {
                        _setWorsePendapatanTetapPeriodSelected('6m');
                      })
                    ),
                    SelectableButton(
                      text: "ytd",
                      selected: (_worsePendapatantetapPeriodSelected == "ytd"),
                      onPress: (() {
                        _setWorsePendapatanTetapPeriodSelected('ytd');
                      })
                    ),
                    SelectableButton(
                      text: "1y",
                      selected: (_worsePendapatantetapPeriodSelected == "1y"),
                      onPress: (() {
                        _setWorsePendapatanTetapPeriodSelected('1y');
                      })
                    ),
                  ],
                ),
                const SizedBox(height: 10,),
                _generateTopWorseList(reksadanaList: _worseReksadanaList, type: 'pendapatantetap', period: _worsePendapatantetapPeriodSelected, codeColor: accentColor, gainColor: Colors.red),
                ///
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _generateTopWorseList({required Map<String, TopWorseCompanyListModel> reksadanaList, required String type, required String period, required Color codeColor, required Color gainColor}) {
    List<CompanyInfo> info = [];
  
    // select which info we will display based on the _topPeriod
    switch(period) {
      case '1d':
        info = reksadanaList[type]!.companyList.the1D;
        break;
      case '1w':
        info = reksadanaList[type]!.companyList.the1W;
        break;
      case '1m':
        info = reksadanaList[type]!.companyList.the1M;
        break;
      case '3m':
        info = reksadanaList[type]!.companyList.the3M;
        break;
      case '6m':
        info = reksadanaList[type]!.companyList.the6M;
        break;
      case 'ytd':
        info = reksadanaList[type]!.companyList.theYTD;
        break;
      case '1y':
        info = reksadanaList[type]!.companyList.the1Y;
        break;
      case '3y':
        info = reksadanaList[type]!.companyList.the3Y;
        break;
      case '5y':
        info = reksadanaList[type]!.companyList.the5Y;
        break;
      default:
        info = reksadanaList[type]!.companyList.the1D;
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: List.generate(info.length, (index) {

        return InkWell(
          onTap: () async {
            showLoaderDialog(context);
            await _companyAPI.getCompanyByID(info[index].companySahamId, 'reksadana').then((resp) {
              CompanyDetailArgs args = CompanyDetailArgs(
                companyId: info[index].companySahamId,
                companyName: resp.companyName,
                companyCode: (resp.companySymbol ?? ''),
                companyFavourite: (resp.companyFavourites ?? false),
                favouritesId: (resp.companyFavouritesId ?? -1),
                type: "reksadana",
              );
              
              // remove the loader dialog
              Navigator.pop(context);

              // go to the company page
              Navigator.pushNamed(context, '/company/detail/reksadana', arguments: args);
            }).onError((error, stackTrace) {
              // remove the loader dialog
              Navigator.pop(context);

              // show the error message
              ScaffoldMessenger.of(context).showSnackBar(createSnackBar(message: 'Error when try to get the company detail from server'));
            });
          },
          child: Container(
            padding: const EdgeInsets.all(10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  width: 25,
                  child: Text(
                    (index + 1).toString(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: codeColor
                    ),
                  )
                ),
                Expanded(
                  child: Text(
                    info[index].name,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 5,),
                Text(
                  '${formatDecimal(info[index].gain * 100, 2)}%',
                  style: TextStyle(
                    color: gainColor,
                    fontSize: 12,
                  ),
                )
              ],
            ),
          ),
        );
      }),
    );
  }

  void _setTopSahamPeriodSelected(String value) {
    setState(() {
      _topSahamPeriodSelected = value;
    });
  }

  void _setTopCampuranPeriodSelected(String value) {
    setState(() {
      _topCampuranPeriodSelected = value;
    });
  }
  
  void _setTopPasaruangPeriodSelected(String value) {
    setState(() {
      _topPasaruangPeriodSelected = value;
    });
  }
  
  void _setTopPendapatanTetapPeriodSelected(String value) {
    setState(() {
      _topPendapatantetapPeriodSelected = value;
    });
  }

  void _setWorseSahamPeriodSelected(String value) {
    setState(() {
      _worseSahamPeriodSelected = value;
    });
  }

  void _setWorseCampuranPeriodSelected(String value) {
    setState(() {
      _worseCampuranPeriodSelected = value;
    });
  }
  
  void _setWorsePasaruangPeriodSelected(String value) {
    setState(() {
      _worsePasaruangPeriodSelected = value;
    });
  }
  
  void _setWorsePendapatanTetapPeriodSelected(String value) {
    setState(() {
      _worsePendapatantetapPeriodSelected = value;
    });
  }
}