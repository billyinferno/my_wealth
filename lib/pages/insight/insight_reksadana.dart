import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_wealth/_index.g.dart';

class InsightReksadanaPage extends StatefulWidget {
  const InsightReksadanaPage({super.key});

  @override
  State<InsightReksadanaPage> createState() => _InsightReksadanaPageState();
}

class _InsightReksadanaPageState extends State<InsightReksadanaPage> {
  final ScrollController _scrollController = ScrollController();
  final InsightAPI _insightAPI = InsightAPI();
  final CompanyAPI _companyAPI = CompanyAPI();

  // list all the selectable item list as final
  final List<SelectableItem> _selectableItemList = [
    const SelectableItem(name: '1d', value: '1d'),
    const SelectableItem(name: '1w', value: '1w'),
    const SelectableItem(name: '1m', value: '1m'),
    const SelectableItem(name: '3m', value: '3m'),
    const SelectableItem(name: '6m', value: '6m'),
    const SelectableItem(name: 'ytd', value: 'ytd'),
    const SelectableItem(name: '1y', value: '1y'),
  ];

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
    super.initState();

    // initialize top reksadana list with empty map
    _topReksadanaList = {};
    _worseReksadanaList = {};

    // now get all the information from the shared preferences and put it on the topReksadanaList
    _topReksadanaList['saham'] = InsightSharedPreferences.getTopReksadanaList(type: 'saham');
    _topReksadanaList['campuran'] = InsightSharedPreferences.getTopReksadanaList(type: 'campuran');
    _topReksadanaList['pasaruang'] = InsightSharedPreferences.getTopReksadanaList(type: 'pasaruang');
    _topReksadanaList['pendapatantetap'] = InsightSharedPreferences.getTopReksadanaList(type: 'pendapatantetap');

    // then get the worse lit and put it on the worseReksadanaList
    _worseReksadanaList['saham'] = InsightSharedPreferences.getWorseReksadanaList(type: 'saham');
    _worseReksadanaList['campuran'] = InsightSharedPreferences.getWorseReksadanaList(type: 'campuran');
    _worseReksadanaList['pasaruang'] = InsightSharedPreferences.getWorseReksadanaList(type: 'pasaruang');
    _worseReksadanaList['pendapatantetap'] = InsightSharedPreferences.getWorseReksadanaList(type: 'pendapatantetap');
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
                SelectableList(
                  items: _selectableItemList,
                  initialValue: _topSahamPeriodSelected,
                  onPress: ((value) {
                    _setTopSahamPeriodSelected(value);
                  })
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
                SelectableList(
                  items: _selectableItemList,
                  initialValue: _worseSahamPeriodSelected,
                  onPress: ((value) {
                    _setWorseSahamPeriodSelected(value);
                  })
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
                SelectableList(
                  items: _selectableItemList,
                  initialValue: _topCampuranPeriodSelected,
                  onPress: ((value) {
                    _setTopCampuranPeriodSelected(value);
                  })
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
                SelectableList(
                  items: _selectableItemList,
                  initialValue: _worseCampuranPeriodSelected,
                  onPress: ((value) {
                    _setWorseCampuranPeriodSelected(value);
                  })
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
                SelectableList(
                  items: _selectableItemList,
                  initialValue: _topPasaruangPeriodSelected,
                  onPress: ((value) {
                    _setTopPasaruangPeriodSelected(value);
                  })
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
                SelectableList(
                  items: _selectableItemList,
                  initialValue: _worsePasaruangPeriodSelected,
                  onPress: ((value) {
                    _setWorsePasaruangPeriodSelected(value);
                  })
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
                SelectableList(
                  items: _selectableItemList,
                  initialValue: _topPendapatantetapPeriodSelected,
                  onPress: ((value) {
                    _setTopPendapatanTetapPeriodSelected(value);
                  })
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
                SelectableList(
                  items: _selectableItemList,
                  initialValue: _worsePendapatantetapPeriodSelected,
                  onPress: ((value) {
                    _setWorsePendapatanTetapPeriodSelected(value);
                  })
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
            // show loading screen
            LoadingScreen.instance().show(context: context);

            // get the company detail information based on the company id
            await _companyAPI.getCompanyByID(
              companyId: info[index].companySahamId,
              type: 'reksadana',
            ).then((resp) {
              CompanyDetailArgs args = CompanyDetailArgs(
                companyId: info[index].companySahamId,
                companyName: resp.companyName,
                companyCode: (resp.companySymbol ?? ''),
                companyFavourite: (resp.companyFavourites ?? false),
                favouritesId: (resp.companyFavouritesId ?? -1),
                type: "reksadana",
              );
              
              if (mounted) {
                // go to the company page
                Navigator.pushNamed(context, '/company/detail/reksadana', arguments: args);
              }
            }).onError((error, stackTrace) {
              if (mounted) {
                // show the error message
                ScaffoldMessenger.of(context).showSnackBar(createSnackBar(message: 'Error when try to get the company detail from server'));
              }
            }).whenComplete(() {
              // remove the loading screen
              LoadingScreen.instance().hide();
            },);
          },
          child: Container(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
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
                  '${formatDecimal(
                    info[index].gain * 100,
                    decimal: 2,
                  )}%',
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