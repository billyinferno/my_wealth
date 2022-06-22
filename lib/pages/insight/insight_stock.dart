import 'package:flutter/material.dart';
import 'package:my_wealth/model/sector_summary_model.dart';
import 'package:my_wealth/provider/inisght_provider.dart';
import 'package:my_wealth/themes/colors.dart';
import 'package:my_wealth/utils/arguments/industry_summary_args.dart';
import 'package:my_wealth/utils/function/format_currency.dart';
import 'package:my_wealth/utils/globals.dart';
import 'package:my_wealth/utils/prefs/shared_insight.dart';
import 'package:provider/provider.dart';

class InsightStockPage extends StatefulWidget {
  const InsightStockPage({Key? key}) : super(key: key);

  @override
  State<InsightStockPage> createState() => _InsightStockPageState();
}

class _InsightStockPageState extends State<InsightStockPage> {
  final ScrollController _scrollController = ScrollController();
  late List<SectorSummaryModel> _sectorSummaryList;
  String _sectorSummaryPeriod = "1d";

  @override
  void initState() {
    _sectorSummaryList = InsightSharedPreferences.getSectorSummaryList();

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

        return SingleChildScrollView(
          controller: _scrollController,
          child: RefreshIndicator(
            color: accentColor,
            onRefresh: (() async {
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
                      _selectableButton(
                        text: "1d",
                        selected: (_sectorSummaryPeriod == "1d"),
                        onPress: (() {
                          _setSectorSummaryPeriod('1d');
                        })
                      ),
                      _selectableButton(
                        text: "1w",
                        selected: (_sectorSummaryPeriod == "1w"),
                        onPress: (() {
                          _setSectorSummaryPeriod('1w');
                        })
                      ),
                      _selectableButton(
                        text: "1m",
                        selected: (_sectorSummaryPeriod == "1m"),
                        onPress: (() {
                          _setSectorSummaryPeriod('1m');
                        })
                      ),
                      _selectableButton(
                        text: "3m",
                        selected: (_sectorSummaryPeriod == "3m"),
                        onPress: (() {
                          _setSectorSummaryPeriod('3m');
                        })
                      ),
                      _selectableButton(
                        text: "6m",
                        selected: (_sectorSummaryPeriod == "6m"),
                        onPress: (() {
                          _setSectorSummaryPeriod('6m');
                        })
                      ),
                      _selectableButton(
                        text: "1y",
                        selected: (_sectorSummaryPeriod == "1y"),
                        onPress: (() {
                          _setSectorSummaryPeriod('1y');
                        })
                      ),
                      _selectableButton(
                        text: "3y",
                        selected: (_sectorSummaryPeriod == "3y"),
                        onPress: (() {
                          _setSectorSummaryPeriod('3y');
                        })
                      ),
                      _selectableButton(
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
                        Color bgColor = (sectorAverage >= 0 ? Colors.green : secondaryColor);
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
                                  color: textPrimary,
                                ),
                                const SizedBox(height: 5,),
                                Center(
                                  child: Text(
                                    Globals.sectorName[_sectorSummaryList[index].sectorName]!,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: textPrimary,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 5,),
                                Center(
                                  child: Text(
                                    "${formatDecimal((sectorAverage * 100), 2)}%",
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: textPrimary,
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
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _selectableButton({required String text, VoidCallback? onPress, required bool selected}) {
    return InkWell(
      onTap: (() {
        // check if not null
        if (onPress != null) {
          onPress();
        }
      }),
      child: Container(
        height: 20,
        width: 20,
        margin: const EdgeInsets.fromLTRB(5, 0, 5, 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: (selected ? secondaryColor : Colors.transparent),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: (selected ? textPrimary : secondaryColor),
              fontSize: 10,
            ),
          ),
        ),
      ),
    );
  }

  void _setSectorSummaryPeriod(String period) {
    setState(() {
      _sectorSummaryPeriod = period;
    });
  }
}