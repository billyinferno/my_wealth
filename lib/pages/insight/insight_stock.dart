import 'package:flutter/material.dart';
import 'package:my_wealth/model/sector_summary_model.dart';
import 'package:my_wealth/model/top_worse_company_list_model.dart';
import 'package:my_wealth/model/user_login.dart';
import 'package:my_wealth/provider/inisght_provider.dart';
import 'package:my_wealth/themes/colors.dart';
import 'package:my_wealth/utils/arguments/company_detail_args.dart';
import 'package:my_wealth/utils/arguments/industry_summary_args.dart';
import 'package:my_wealth/utils/function/format_currency.dart';
import 'package:my_wealth/utils/function/risk_color.dart';
import 'package:my_wealth/utils/globals.dart';
import 'package:my_wealth/utils/prefs/shared_insight.dart';
import 'package:my_wealth/utils/prefs/shared_user.dart';
import 'package:my_wealth/widgets/selectable_button.dart';
import 'package:provider/provider.dart';

class InsightStockPage extends StatefulWidget {
  const InsightStockPage({Key? key}) : super(key: key);

  @override
  State<InsightStockPage> createState() => _InsightStockPageState();
}

class _InsightStockPageState extends State<InsightStockPage> {
  final ScrollController _scrollController = ScrollController();
  late List<SectorSummaryModel> _sectorSummaryList;
  late TopWorseCompanyListModel _topCompanyList;
  late TopWorseCompanyListModel _worseCompanyList;
  late UserLoginInfoModel? _userInfo;

  String _sectorSummaryPeriod = "1d";
  String _topCompanyPeriod = "1d";
  String _worseCompanyPeriod = "1d";

  @override
  void initState() {
    _sectorSummaryList = InsightSharedPreferences.getSectorSummaryList();
    _topCompanyList = InsightSharedPreferences.getTopWorseCompanyList('top');
    _topCompanyList = InsightSharedPreferences.getTopWorseCompanyList('worse');

    _userInfo = UserSharedPreferences.getUserInfo();
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
        _sectorSummaryList = (insightProvider.sectorSummaryList ?? []);
        _topCompanyList = insightProvider.topCompanyList!;
        _worseCompanyList = insightProvider.worseCompanyList!;

        return SingleChildScrollView(
          controller: _scrollController,
          child: RefreshIndicator(
            color: accentColor,
            onRefresh: (() async {
              //TODO: refresh all the data in this page
              debugPrint("Refresh");
            }),
            child: Container(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  const Center(
                    child: Text(
                      "Sector Summary",
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
                        selected: (_sectorSummaryPeriod == "1d"),
                        onPress: (() {
                          _setSectorSummaryPeriod('1d');
                        })
                      ),
                      SelectableButton(
                        text: "1w",
                        selected: (_sectorSummaryPeriod == "1w"),
                        onPress: (() {
                          _setSectorSummaryPeriod('1w');
                        })
                      ),
                      SelectableButton(
                        text: "1m",
                        selected: (_sectorSummaryPeriod == "1m"),
                        onPress: (() {
                          _setSectorSummaryPeriod('1m');
                        })
                      ),
                      SelectableButton(
                        text: "3m",
                        selected: (_sectorSummaryPeriod == "3m"),
                        onPress: (() {
                          _setSectorSummaryPeriod('3m');
                        })
                      ),
                      SelectableButton(
                        text: "6m",
                        selected: (_sectorSummaryPeriod == "6m"),
                        onPress: (() {
                          _setSectorSummaryPeriod('6m');
                        })
                      ),
                      SelectableButton(
                        text: "ytd",
                        selected: (_sectorSummaryPeriod == "ytd"),
                        onPress: (() {
                          _setSectorSummaryPeriod('ytd');
                        })
                      ),
                      SelectableButton(
                        text: "1y",
                        selected: (_sectorSummaryPeriod == "1y"),
                        onPress: (() {
                          _setSectorSummaryPeriod('1y');
                        })
                      ),
                      SelectableButton(
                        text: "3y",
                        selected: (_sectorSummaryPeriod == "3y"),
                        onPress: (() {
                          _setSectorSummaryPeriod('3y');
                        })
                      ),
                      SelectableButton(
                        text: "5y",
                        selected: (_sectorSummaryPeriod == "5y"),
                        onPress: (() {
                          _setSectorSummaryPeriod('5y');
                        })
                      ),
                    ],
                  ),
                  const SizedBox(height: 10,),
                  SizedBox(
                    width: double.infinity,
                    height: 370,
                    child: GridView.count(
                      crossAxisCount: 3,
                      children: List<Widget>.generate(_sectorSummaryList.length, (index) {
                        double sectorAverage = 0;
                        IndustrySummaryArgs industryArgs = IndustrySummaryArgs(sectorData: _sectorSummaryList[index]);

                        switch (_sectorSummaryPeriod) {
                          case '1d':
                            sectorAverage = _sectorSummaryList[index].sectorAverage.the1D;
                            break;
                          case '1w':
                            sectorAverage = _sectorSummaryList[index].sectorAverage.the1W;
                            break;
                          case '1m':
                            sectorAverage = _sectorSummaryList[index].sectorAverage.the1M;
                            break;
                          case '3m':
                            sectorAverage = _sectorSummaryList[index].sectorAverage.the3M;
                            break;
                          case '6m':
                            sectorAverage = _sectorSummaryList[index].sectorAverage.the6M;
                            break;
                          case 'ytd':
                            sectorAverage = _sectorSummaryList[index].sectorAverage.theYTD;
                            break;
                          case '1y':
                            sectorAverage = _sectorSummaryList[index].sectorAverage.the1Y;
                            break;
                          case '3y':
                            sectorAverage = _sectorSummaryList[index].sectorAverage.the3Y;
                            break;
                          case '5y':
                            sectorAverage = _sectorSummaryList[index].sectorAverage.the5Y;
                            break;
                          default:
                            sectorAverage = _sectorSummaryList[index].sectorAverage.the1D;
                            break;
                        }

                        // Color bgColor = (sectorAverage >= 0 ? Colors.green : secondaryColor);
                        Color bgColor = riskColor((1 + sectorAverage), 1, _userInfo!.risk);
                        Color textColor = riskColorReverse((1 + sectorAverage), 1);
                        Color borderColor = (sectorAverage >= 0 ? const Color.fromARGB(255, 15, 88, 17) : secondaryDark);
                  
                        return InkWell(
                          onTap: (() {
                            Navigator.pushNamed(context, '/insight/stock/industry', arguments: industryArgs);
                          }),
                          child: Container(
                            margin: const EdgeInsets.all(5),
                            height: 90,
                            width: 90,
                            decoration: BoxDecoration(
                              color: bgColor,
                              border: Border.all(
                                color: borderColor,
                                style: BorderStyle.solid,
                                width: 1.0,
                              )
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(
                                  Globals.sectorIcon[_sectorSummaryList[index].sectorName]!,
                                  size: 25,
                                  color: textColor,
                                ),
                                const SizedBox(height: 5,),
                                Center(
                                  child: Text(
                                    Globals.sectorName[_sectorSummaryList[index].sectorName]!,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 5,),
                                Center(
                                  child: Text(
                                    "${formatDecimal((sectorAverage * 100), 2)}%",
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 20,),
                  const Center(
                    child: Text(
                      "Top Gainer",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ),
                  const SizedBox(height: 10,),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SelectableButton(
                        text: "1d",
                        selected: (_topCompanyPeriod == "1d"),
                        onPress: (() {
                          _setTopCompanyPeriod('1d');
                        })
                      ),
                      SelectableButton(
                        text: "1w",
                        selected: (_topCompanyPeriod == "1w"),
                        onPress: (() {
                          _setTopCompanyPeriod('1w');
                        })
                      ),
                      SelectableButton(
                        text: "1m",
                        selected: (_topCompanyPeriod == "1m"),
                        onPress: (() {
                          _setTopCompanyPeriod('1m');
                        })
                      ),
                      SelectableButton(
                        text: "3m",
                        selected: (_topCompanyPeriod == "3m"),
                        onPress: (() {
                          _setTopCompanyPeriod('3m');
                        })
                      ),
                      SelectableButton(
                        text: "6m",
                        selected: (_topCompanyPeriod == "6m"),
                        onPress: (() {
                          _setTopCompanyPeriod('6m');
                        })
                      ),
                      SelectableButton(
                        text: "ytd",
                        selected: (_topCompanyPeriod == "ytd"),
                        onPress: (() {
                          _setTopCompanyPeriod('ytd');
                        })
                      ),
                      SelectableButton(
                        text: "1y",
                        selected: (_topCompanyPeriod == "1y"),
                        onPress: (() {
                          _setTopCompanyPeriod('1y');
                        })
                      ),
                      SelectableButton(
                        text: "3y",
                        selected: (_topCompanyPeriod == "3y"),
                        onPress: (() {
                          _setTopCompanyPeriod('3y');
                        })
                      ),
                      SelectableButton(
                        text: "5y",
                        selected: (_topCompanyPeriod == "5y"),
                        onPress: (() {
                          _setTopCompanyPeriod('5y');
                        })
                      ),
                    ],
                  ),
                  const SizedBox(height: 10,),
                  _generateTopWorseList(type: 'top', codeColor: accentColor, gainColor: Colors.green),
                  const SizedBox(height: 20,),
                  const Center(
                    child: Text(
                      "Top Loser",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ),
                  const SizedBox(height: 10,),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SelectableButton(
                        text: "1d",
                        selected: (_worseCompanyPeriod == "1d"),
                        onPress: (() {
                          _setWorseCompanyPeriod('1d');
                        })
                      ),
                      SelectableButton(
                        text: "1w",
                        selected: (_worseCompanyPeriod == "1w"),
                        onPress: (() {
                          _setWorseCompanyPeriod('1w');
                        })
                      ),
                      SelectableButton(
                        text: "1m",
                        selected: (_worseCompanyPeriod == "1m"),
                        onPress: (() {
                          _setWorseCompanyPeriod('1m');
                        })
                      ),
                      SelectableButton(
                        text: "3m",
                        selected: (_worseCompanyPeriod == "3m"),
                        onPress: (() {
                          _setWorseCompanyPeriod('3m');
                        })
                      ),
                      SelectableButton(
                        text: "6m",
                        selected: (_worseCompanyPeriod == "6m"),
                        onPress: (() {
                          _setWorseCompanyPeriod('6m');
                        })
                      ),
                      SelectableButton(
                        text: "ytd",
                        selected: (_worseCompanyPeriod == "ytd"),
                        onPress: (() {
                          _setWorseCompanyPeriod('ytd');
                        })
                      ),
                      SelectableButton(
                        text: "1y",
                        selected: (_worseCompanyPeriod == "1y"),
                        onPress: (() {
                          _setWorseCompanyPeriod('1y');
                        })
                      ),
                      SelectableButton(
                        text: "3y",
                        selected: (_worseCompanyPeriod == "3y"),
                        onPress: (() {
                          _setWorseCompanyPeriod('3y');
                        })
                      ),
                      SelectableButton(
                        text: "5y",
                        selected: (_worseCompanyPeriod == "5y"),
                        onPress: (() {
                          _setWorseCompanyPeriod('5y');
                        })
                      ),
                    ],
                  ),
                  const SizedBox(height: 10,),
                  _generateTopWorseList(type: 'worse', codeColor: accentColor, gainColor: secondaryLight),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _generateTopWorseList({required String type, required Color codeColor, required Color gainColor}) {
    List<CompanyInfo> info = [];
    
    if (type == 'top') {
      // select which info we will display based on the _topPeriod
      switch(_topCompanyPeriod) {
        case '1d':
          info = _topCompanyList.companyList.the1D;
          break;
        case '1w':
          info = _topCompanyList.companyList.the1W;
          break;
        case '1m':
          info = _topCompanyList.companyList.the1M;
          break;
        case '3m':
          info = _topCompanyList.companyList.the3M;
          break;
        case '6m':
          info = _topCompanyList.companyList.the6M;
          break;
        case 'ytd':
          info = _topCompanyList.companyList.theYTD;
          break;
        case '1y':
          info = _topCompanyList.companyList.the1Y;
          break;
        case '3y':
          info = _topCompanyList.companyList.the3Y;
          break;
        case '5y':
          info = _topCompanyList.companyList.the5Y;
          break;
        default:
          info = _topCompanyList.companyList.the1D;
          break;
      }
    }
    else if (type == 'worse') {
      // select which info we will display based on the _topPeriod
      switch(_worseCompanyPeriod) {
        case '1d':
          info = _worseCompanyList.companyList.the1D;
          break;
        case '1w':
          info = _worseCompanyList.companyList.the1W;
          break;
        case '1m':
          info = _worseCompanyList.companyList.the1M;
          break;
        case '3m':
          info = _worseCompanyList.companyList.the3M;
          break;
        case '6m':
          info = _worseCompanyList.companyList.the6M;
          break;
        case 'ytd':
          info = _worseCompanyList.companyList.theYTD;
          break;
        case '1y':
          info = _worseCompanyList.companyList.the1Y;
          break;
        case '3y':
          info = _worseCompanyList.companyList.the3Y;
          break;
        case '5y':
          info = _worseCompanyList.companyList.the5Y;
          break;
        default:
          info = _worseCompanyList.companyList.the1D;
          break;
      }
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
          type: 'saham'
        );

        return InkWell(
          onTap: () {
            Navigator.pushNamed(context, '/company/detail/saham', arguments: args);
          },
          child: Container(
            padding: const EdgeInsets.all(10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  width: 20,
                  child: Text(
                    (index + 1).toString(),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold
                    ),
                  )
                ),
                const SizedBox(width: 5,),
                Text(
                  "(${info[index].code})",
                  style: TextStyle(
                    color: codeColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 5,),
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

  void _setSectorSummaryPeriod(String period) {
    setState(() {
      _sectorSummaryPeriod = period;
    });
  }

  void _setTopCompanyPeriod(String period) {
    setState(() {
      _topCompanyPeriod = period;
    });
  }

  void _setWorseCompanyPeriod(String period) {
    setState(() {
      _worseCompanyPeriod = period;
    });
  }
 }