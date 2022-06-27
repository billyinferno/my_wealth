import 'package:flutter/material.dart';
import 'package:my_wealth/model/top_worse_company_list_model.dart';
import 'package:my_wealth/provider/inisght_provider.dart';
import 'package:my_wealth/themes/colors.dart';
import 'package:my_wealth/utils/arguments/company_detail_args.dart';
import 'package:my_wealth/utils/function/format_currency.dart';
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

  late Map<String, TopWorseCompanyListModel> _topReksadanaList;

  String _sahamPeriodSelected = '1d';
  String _campuranPeriodSelected = '1d';
  String _pasaruangPeriodSelected = '1d';
  String _pendapatantetapPeriodSelected = '1d';

  @override
  void initState() {
    // initialize top reksadana list with empty map
    _topReksadanaList = {};

    // now get all the information from the shared preferences and put it on the topReksadanaList
    _topReksadanaList['saham'] = InsightSharedPreferences.getTopReksadanaList('saham');
    _topReksadanaList['campuran'] = InsightSharedPreferences.getTopReksadanaList('campuran');
    _topReksadanaList['pasaruang'] = InsightSharedPreferences.getTopReksadanaList('pasaruang');
    _topReksadanaList['pendapatantetap'] = InsightSharedPreferences.getTopReksadanaList('pendapatantetap');

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
        _topReksadanaList['saham'] = insightProvider.topReksadanaList!['saham'] ?? TopWorseCompanyListModel(companyList: CompanyList(the1D: [], the1M: [], the1W: [], the1Y: [], the3M: [], the3Y: [], the5Y: [], the6M: [], theYTD: []));
        _topReksadanaList['campuran'] = insightProvider.topReksadanaList!['campuran'] ?? TopWorseCompanyListModel(companyList: CompanyList(the1D: [], the1M: [], the1W: [], the1Y: [], the3M: [], the3Y: [], the5Y: [], the6M: [], theYTD: []));
        _topReksadanaList['pasaruang'] = insightProvider.topReksadanaList!['pasaruang'] ?? TopWorseCompanyListModel(companyList: CompanyList(the1D: [], the1M: [], the1W: [], the1Y: [], the3M: [], the3Y: [], the5Y: [], the6M: [], theYTD: []));
        _topReksadanaList['pendapatantetap'] = insightProvider.topReksadanaList!['pendapatantetap'] ?? TopWorseCompanyListModel(companyList: CompanyList(the1D: [], the1M: [], the1W: [], the1Y: [], the3M: [], the3Y: [], the5Y: [], the6M: [], theYTD: []));

        return SingleChildScrollView(
          controller: _scrollController,
          child: RefreshIndicator(
            onRefresh: (() async {
              //TODO: to call api and refresh the data
              debugPrint("Refresh top reksadana");
            }),
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
                      selected: (_sahamPeriodSelected == "1d"),
                      onPress: (() {
                        _setSahamPeriodSelected('1d');
                      })
                    ),
                    SelectableButton(
                      text: "1w",
                      selected: (_sahamPeriodSelected == "1w"),
                      onPress: (() {
                        _setSahamPeriodSelected('1w');
                      })
                    ),
                    SelectableButton(
                      text: "1m",
                      selected: (_sahamPeriodSelected == "1m"),
                      onPress: (() {
                        _setSahamPeriodSelected('1m');
                      })
                    ),
                    SelectableButton(
                      text: "3m",
                      selected: (_sahamPeriodSelected == "3m"),
                      onPress: (() {
                        _setSahamPeriodSelected('3m');
                      })
                    ),
                    SelectableButton(
                      text: "6m",
                      selected: (_sahamPeriodSelected == "6m"),
                      onPress: (() {
                        _setSahamPeriodSelected('6m');
                      })
                    ),
                    SelectableButton(
                      text: "ytd",
                      selected: (_sahamPeriodSelected == "ytd"),
                      onPress: (() {
                        _setSahamPeriodSelected('ytd');
                      })
                    ),
                    SelectableButton(
                      text: "1y",
                      selected: (_sahamPeriodSelected == "1y"),
                      onPress: (() {
                        _setSahamPeriodSelected('1y');
                      })
                    ),
                  ],
                ),
                const SizedBox(height: 10,),
                _generateTopWorseList(type: 'saham', period: _sahamPeriodSelected, codeColor: accentColor, gainColor: Colors.green),
                const SizedBox(height: 20,),
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
                      selected: (_campuranPeriodSelected == "1d"),
                      onPress: (() {
                        _setCampuranPeriodSelected('1d');
                      })
                    ),
                    SelectableButton(
                      text: "1w",
                      selected: (_campuranPeriodSelected == "1w"),
                      onPress: (() {
                        _setCampuranPeriodSelected('1w');
                      })
                    ),
                    SelectableButton(
                      text: "1m",
                      selected: (_campuranPeriodSelected == "1m"),
                      onPress: (() {
                        _setCampuranPeriodSelected('1m');
                      })
                    ),
                    SelectableButton(
                      text: "3m",
                      selected: (_campuranPeriodSelected == "3m"),
                      onPress: (() {
                        _setCampuranPeriodSelected('3m');
                      })
                    ),
                    SelectableButton(
                      text: "6m",
                      selected: (_campuranPeriodSelected == "6m"),
                      onPress: (() {
                        _setCampuranPeriodSelected('6m');
                      })
                    ),
                    SelectableButton(
                      text: "ytd",
                      selected: (_campuranPeriodSelected == "ytd"),
                      onPress: (() {
                        _setCampuranPeriodSelected('ytd');
                      })
                    ),
                    SelectableButton(
                      text: "1y",
                      selected: (_campuranPeriodSelected == "1y"),
                      onPress: (() {
                        _setCampuranPeriodSelected('1y');
                      })
                    ),
                  ],
                ),
                const SizedBox(height: 10,),
                _generateTopWorseList(type: 'campuran', period: _campuranPeriodSelected, codeColor: accentColor, gainColor: Colors.green),
                const SizedBox(height: 20,),
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
                      selected: (_pasaruangPeriodSelected == "1d"),
                      onPress: (() {
                        _setPasaruangPeriodSelected('1d');
                      })
                    ),
                    SelectableButton(
                      text: "1w",
                      selected: (_pasaruangPeriodSelected == "1w"),
                      onPress: (() {
                        _setPasaruangPeriodSelected('1w');
                      })
                    ),
                    SelectableButton(
                      text: "1m",
                      selected: (_pasaruangPeriodSelected == "1m"),
                      onPress: (() {
                        _setPasaruangPeriodSelected('1m');
                      })
                    ),
                    SelectableButton(
                      text: "3m",
                      selected: (_pasaruangPeriodSelected == "3m"),
                      onPress: (() {
                        _setPasaruangPeriodSelected('3m');
                      })
                    ),
                    SelectableButton(
                      text: "6m",
                      selected: (_pasaruangPeriodSelected == "6m"),
                      onPress: (() {
                        _setPasaruangPeriodSelected('6m');
                      })
                    ),
                    SelectableButton(
                      text: "ytd",
                      selected: (_pasaruangPeriodSelected == "ytd"),
                      onPress: (() {
                        _setPasaruangPeriodSelected('ytd');
                      })
                    ),
                    SelectableButton(
                      text: "1y",
                      selected: (_pasaruangPeriodSelected == "1y"),
                      onPress: (() {
                        _setPasaruangPeriodSelected('1y');
                      })
                    ),
                  ],
                ),
                const SizedBox(height: 10,),
                _generateTopWorseList(type: 'pasaruang', period: _pasaruangPeriodSelected, codeColor: accentColor, gainColor: Colors.green),
                const SizedBox(height: 20,),
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
                      selected: (_pendapatantetapPeriodSelected == "1d"),
                      onPress: (() {
                        _setPendapatanTetapPeriodSelected('1d');
                      })
                    ),
                    SelectableButton(
                      text: "1w",
                      selected: (_pendapatantetapPeriodSelected == "1w"),
                      onPress: (() {
                        _setPendapatanTetapPeriodSelected('1w');
                      })
                    ),
                    SelectableButton(
                      text: "1m",
                      selected: (_pendapatantetapPeriodSelected == "1m"),
                      onPress: (() {
                        _setPendapatanTetapPeriodSelected('1m');
                      })
                    ),
                    SelectableButton(
                      text: "3m",
                      selected: (_pendapatantetapPeriodSelected == "3m"),
                      onPress: (() {
                        _setPendapatanTetapPeriodSelected('3m');
                      })
                    ),
                    SelectableButton(
                      text: "6m",
                      selected: (_pendapatantetapPeriodSelected == "6m"),
                      onPress: (() {
                        _setPendapatanTetapPeriodSelected('6m');
                      })
                    ),
                    SelectableButton(
                      text: "ytd",
                      selected: (_pendapatantetapPeriodSelected == "ytd"),
                      onPress: (() {
                        _setPendapatanTetapPeriodSelected('ytd');
                      })
                    ),
                    SelectableButton(
                      text: "1y",
                      selected: (_pendapatantetapPeriodSelected == "1y"),
                      onPress: (() {
                        _setPendapatanTetapPeriodSelected('1y');
                      })
                    ),
                  ],
                ),
                const SizedBox(height: 10,),
                _generateTopWorseList(type: 'pendapatantetap', period: _pendapatantetapPeriodSelected, codeColor: accentColor, gainColor: Colors.green),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _generateTopWorseList({required String type, required String period, required Color codeColor, required Color gainColor}) {
    List<CompanyInfo> info = [];
  
    // select which info we will display based on the _topPeriod
    switch(period) {
      case '1d':
        info = _topReksadanaList[type]!.companyList.the1D;
        break;
      case '1w':
        info = _topReksadanaList[type]!.companyList.the1W;
        break;
      case '1m':
        info = _topReksadanaList[type]!.companyList.the1M;
        break;
      case '3m':
        info = _topReksadanaList[type]!.companyList.the3M;
        break;
      case '6m':
        info = _topReksadanaList[type]!.companyList.the6M;
        break;
      case 'ytd':
        info = _topReksadanaList[type]!.companyList.theYTD;
        break;
      case '1y':
        info = _topReksadanaList[type]!.companyList.the1Y;
        break;
      case '3y':
        info = _topReksadanaList[type]!.companyList.the3Y;
        break;
      case '5y':
        info = _topReksadanaList[type]!.companyList.the5Y;
        break;
      default:
        info = _topReksadanaList[type]!.companyList.the1D;
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: List.generate(info.length, (index) {
        CompanyDetailArgs args = CompanyDetailArgs(
          companyId: info[index].companySahamId,
          companyCode: info[index].code,
          companyName: info[index].name,
          companyFavourite: false,
          favouritesId: -1,
          type: 'reksadana'
        );

        return InkWell(
          onTap: () {
            Navigator.pushNamed(context, '/company/detail/reksadana', arguments: args);
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

  void _setSahamPeriodSelected(String value) {
    setState(() {
      _sahamPeriodSelected = value;
    });
  }

  void _setCampuranPeriodSelected(String value) {
    setState(() {
      _campuranPeriodSelected = value;
    });
  }
  
  void _setPasaruangPeriodSelected(String value) {
    setState(() {
      _pasaruangPeriodSelected = value;
    });
  }
  
  void _setPendapatanTetapPeriodSelected(String value) {
    setState(() {
      _pendapatantetapPeriodSelected = value;
    });
  }
}