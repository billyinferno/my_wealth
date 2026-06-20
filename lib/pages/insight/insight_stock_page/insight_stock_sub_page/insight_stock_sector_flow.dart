import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:my_wealth/_index.g.dart';
import 'package:my_wealth/utils/icon/my_ionicons.dart';
import 'package:my_wealth/widgets/page/tab_content_view.dart';

class InsightSectorFlowDetailPage extends StatefulWidget {
  final Object? args;
  const InsightSectorFlowDetailPage({
    super.key,
    required this.args,
  });

  @override
  State<InsightSectorFlowDetailPage> createState() => _InsightSectorFlowDetailPageState();
}

class _InsightSectorFlowDetailPageState extends State<InsightSectorFlowDetailPage> with SingleTickerProviderStateMixin {
  final BrokerSummaryAPI _brokerSummaryAPI = BrokerSummaryAPI();
  final ScrollController _scrollController = ScrollController();
  late TabController _tabController;

  late BrokerSummarySectorFlowDetailModel _sectorFlowList;
  late IndustrySectorFlowArgs _args;
  late Future<bool> _getData;
  late String _graphSelection;
  late String _daySelection;
  late Map<String, Map<String, List<Map<String, double>>>> _graphData;
  late Map<String, Map<String, Map<String, InsightBrokerRowData>>> _rowData;
  late int _totalNetPlus;
  late int _totalNetNegative;
  late int _totalBuy;
  late int _totalSell;
  late int _totalNet;

  @override
  void initState() {
    // convert current object to the sector flow args
    _args = widget.args as IndustrySectorFlowArgs;

    // initialize tab controller
    _tabController =  TabController(length: 2, vsync: this);

    // default the graph selection to "all"
    _graphSelection = "a";
    _daySelection = "30D";

    // default the total net to 0
    _totalNetPlus = 0;
    _totalNetNegative = 0;

    // default the total row to 0
    _totalBuy = 0;
    _totalSell = 0;
    _totalNet = 0;

    // initialize graph and row data with empty value
    _graphData = {};
    _rowData = {};

    // get the sector flow detail
    _getData = _getSectorFlowDetail();
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getData,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return CommonErrorPage(
            errorText: 'Error getting sector flow detail for ${_args.data.sectorName}',
            isNeedScaffold: false,
          );
        }
        else if (snapshot.hasData) {
          return _body();
        }
        else {
          return const CommonLoadingPage(
            isNeedScaffold: true,
          );
        }
      },
    );
  }

  Widget _body() {
    int totalNet = (_args.data.totalValueDomesticNet + _args.data.totalValueForeignNet);
    Color totalNetColor = textPrimary;
    if (totalNet < 0) {
      totalNetColor = secondaryColor;
    }
    else if (totalNet > 0) {
      totalNetColor = Colors.green;
    }

    int totalPrevNet = (_args.data.prevTotalValueDomesticNet + _args.data.prevTotalValueForeignNet);
    Color totalPrevNetColor = textPrimary;
    if (totalPrevNet < 0) {
      totalPrevNetColor = secondaryColor;
    }
    else if (totalPrevNet > 0) {
      totalPrevNetColor = Colors.green;
    }

    int totalNetIncrDecr = totalNet - totalPrevNet;
    double totalNetIncrDecrPercentage = (totalNetIncrDecr / totalPrevNet.abs()) * 100;
    Color totalNetIncrDecrColor = textPrimary;
    if (totalNetIncrDecrPercentage < 0) {
      totalNetIncrDecrColor = secondaryColor;
    }
    else if (totalNetIncrDecrPercentage > 0) {
      totalNetIncrDecrColor = Colors.green;
    }

    int totalValueDomesticIncrDecr = _args.data.totalValueDomesticNet - _args.data.prevTotalValueDomesticNet;
    double totalValueDomesticIncrDecrPercentage = totalValueDomesticIncrDecr / _args.data.totalValueDomesticNet.abs();

    int totalLotDomesticIncrDecr = _args.data.totalLotDomesticNet - _args.data.prevTotalLotDomesticNet;
    double totalLotDomesticIncrDecrPercentage = totalLotDomesticIncrDecr / _args.data.totalLotDomesticNet.abs();

    int totalValueForeignIncrDecr = _args.data.totalValueForeignNet - _args.data.prevTotalLotForeignNet;
    double totalValueForeignIncrDecrPercentage = totalValueForeignIncrDecr / _args.data.totalValueForeignNet.abs();

    int totalLotForeignIncrDecr = _args.data.totalLotForeignNet - _args.data.prevTotalLotForeignNet;
    double totalLotForeignIncrDecrPercentage = totalLotForeignIncrDecr / _args.data.totalLotForeignNet.abs();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            MyIonicons(MyIoniconsData.arrow_back).data,
          ),
          onPressed: (() {
            Navigator.pop(context);
          }),
        ),
        title: Center(
          child: Text(
            "Sector Flow",
            style: const TextStyle(
              color: secondaryColor,
            ),
          ),
        ),
      ),
      body: MySafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              color: primaryDark,
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text(
                    _args.data.sectorName.toUpperCase(),
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10,),
                  Text(
                    "Total Net Flow",
                    style: TextStyle(
                      fontSize: 10,
                    ),
                  ),
                  Text(
                    formatIntWithNull(totalNet),
                    style: TextStyle(
                      fontSize: 28,
                      color: totalNetColor,
                    ),
                  ),
                  const SizedBox(height: 5,),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      _rowInformation(
                        title: "Prev Net",
                        value: formatIntWithNull(totalPrevNet),
                        color: totalPrevNetColor,
                      ),
                      const SizedBox(width: 10,),
                      _rowInformation(
                        title: (totalNetIncrDecr < 0 ? "Decrease" : "Increase"),
                        value: formatIntWithNull(totalNetIncrDecr),
                        color: totalNetIncrDecrColor,
                      ),
                      const SizedBox(width: 10,),
                      _rowInformation(
                        title: "${totalNetIncrDecr < 0 ? "Decrease": "Increase"}%",
                        value: formatDecimal(totalNetIncrDecrPercentage, decimal: 2),
                        color: totalNetIncrDecrColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  _subInformation(
                    icon: LucideIcons.globe,
                    title: "FOREIGN",
                    totalLot: _args.data.totalLotForeignNet,
                    totalLotPercentage: totalLotForeignIncrDecrPercentage,
                    totalValue: _args.data.totalValueForeignNet,
                    totalValuePercentage: totalValueForeignIncrDecrPercentage,
                  ),
                  const SizedBox(width: 10,),
                  _subInformation(
                    icon: LucideIcons.flag,
                    title: "DOMESTIC",
                    totalLot: _args.data.totalLotDomesticNet,
                    totalLotPercentage: totalLotDomesticIncrDecrPercentage,
                    totalValue: _args.data.totalValueDomesticNet,
                    totalValuePercentage: totalValueDomesticIncrDecrPercentage,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10,),
            SizedBox(
              width: double.infinity,
              child: CupertinoSegmentedControl<String>(
                children: const {
                  "a": Text("All"),
                  "d": Text("Domestic"),
                  "f": Text("Foreign"),
                },
                onValueChanged: ((value) {
                  setState(() {
                    _graphSelection = value;
                  });
                }),
                groupValue: _graphSelection,
                selectedColor: secondaryColor,
                borderColor: secondaryDark,
                pressedColor: textPrimary,
              ),
            ),
            const SizedBox(height: 10,),
            SizedBox(
              width: double.infinity,
              child: CupertinoSegmentedControl<String>(
                children: const {
                  "30D": Text("30D"),
                  "90D": Text("90D"),
                  "6M": Text("6M"),
                  "9M": Text("9M"),
                  "1Y": Text("1Y"),
                },
                onValueChanged: ((value) {
                  setState(() {
                    _daySelection = value;
                  });
                }),
                groupValue: _daySelection,
                selectedColor: extendedColor,
                borderColor: Colors.transparent,
                pressedColor: textPrimary,
              ),
            ),
            Expanded(
              child: DefaultTabController(
                length: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    TabBar(
                      isScrollable: true,
                      tabAlignment: TabAlignment.start,
                      indicatorColor: accentColor,
                      indicatorSize: TabBarIndicatorSize.tab,
                      labelColor: textPrimary,
                      unselectedLabelColor: textPrimary,
                      dividerHeight: 0,
                      tabs: const <Widget>[
                        Tab(text: 'GRAPH',),
                        Tab(text: 'TABLE'),
                        //TODO: to add the TOP 10 buy, TOP  10 sell in 1Y (need to create the API first)
                      ],
                    ),
                    const SizedBox(height: 10,),
                    Expanded(
                      child: TabContentView(
                        children: <Widget>[
                          _chart(),
                          _table(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          width: 15,
                          height: 15,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: Colors.lightGreenAccent,
                          ),
                        ),
                        const SizedBox(width: 5,),
                        Text("$_totalNetPlus")
                      ],
                    ),
                  ),
                  const SizedBox(width: 10,),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          width: 15,
                          height: 15,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: secondaryColor,
                          ),
                        ),
                        const SizedBox(width: 5,),
                        Text("$_totalNetNegative")
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chart() {
    return MultiLineChart(
      height: 250,
      data: (_graphData[_graphSelection]![_daySelection] ?? []),
      color: const [Colors.green, Colors.red, Colors.blue],
      legend: const ["Buy", "Sell", "Net"],
      dateOffset: ((_graphData[_graphSelection]![_daySelection] ?? []).length ~/ 10),
    );
  }

  Widget _table() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
          child: _createTableRow(
            date: "DATE",
            buy: "BUY",
            sell: "SELL",
            net: "NET",
            bgColor: secondaryColor,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            child: Container(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  ..._generateBrokerTable(),
                ],
              ),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
          child: _createTableRow(
            date: "TOTAL",
            buy: formatIntWithNull(_totalBuy),
            sell: formatIntWithNull(_totalSell),
            net: formatIntWithNull(_totalNet),
            bgColor: accentDark,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _generateBrokerTable() {
    List<Widget> ret = [];

    if (_rowData[_graphSelection] != null) {
      if (_rowData[_graphSelection] != null) {
        Map<String, InsightBrokerRowData> rowData = (_rowData[_graphSelection]![_daySelection] ?? {});

        // initialize the total net
        _totalNetNegative = 0;
        _totalNetPlus = 0;

        // initialize the total
        _totalBuy = 0;
        _totalSell = 0;
        _totalNet = 0;

        // ensure we have data
        if (rowData.isNotEmpty) {
          // loop thru the row data
          rowData.forEach((date, row) {
            Color netColor = textPrimary;
            if (row.net < 0) {
              netColor = secondaryLight;
              _totalNetNegative++;
            }
            else {
              netColor = Colors.lightGreenAccent;
              _totalNetPlus++;
            }

            _totalBuy += row.buy;
            _totalSell += row.sell;
            _totalNet += row.net;

            ret.add(_createTableRow(
              date: date,
              buy: formatIntWithNull(row.buy),
              sell: formatIntWithNull(row.sell),
              net: formatIntWithNull(row.net),
              netColor: netColor,
              style: TextStyle(
                fontSize: 12,
              ),
            ));
          });
        }
        else {
          ret.add(Center(child: Text("No row data found"),));
        }

        // return list of widget
        return ret;
      }
    }

    // wrong/null data
    ret.add(Center(child: Text("No/wrong row data"),));
    return ret;
  }

  Widget _createTableRow({
    required String date,
    required String buy,
    required String sell,
    required String net,
    Color netColor = textPrimary,
    Color bgColor = primaryDark,
    TextStyle? style,
    TextAlign? align,
  }) {
    TextStyle netStyle;
    if (style != null) {
      netStyle = style.copyWith(
        color: netColor,
      );
    }
    else {
      netStyle = TextStyle(
        color: netColor,
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(5),
          color: bgColor,
          width: 90,
          child: Text(
            date,
            style: style,
            textAlign: align,
          ),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(5),
            color: bgColor,
            child: Text(
              buy,
              style: style,
              textAlign: align,
            ),
          ),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(5),
            color: bgColor,
            child: Text(
              sell,
              style: style,
              textAlign: align,
            ),
          ),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(5),
            color: bgColor,
            child: Text(
              net,
              style: netStyle,
              textAlign: align,
            ),
          ),
        ),
      ],
    );
  }

  Widget _subInformation({
    required IconData icon,
    required String title,
    required int totalLot,
    required double totalLotPercentage,
    required int totalValue,
    required double totalValuePercentage,
  }) {
    Color bgColor = primaryLight;
    Color borderColor = primaryDark;

    if (totalValue < 0) {
      bgColor = secondaryColor;
      borderColor = secondaryDark;
    }
    else if (totalValue > 0) {
      bgColor = Colors.green;
      borderColor = Colors.green[900]!;
    }

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(
            color: borderColor,
            width: 1.0,
            style: BorderStyle.solid,
          )
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Icon(
                  icon,
                  size: 14,
                  color: textPrimary,
                ),
                const SizedBox(width: 5,),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5,),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                _rowInformation(
                  title: "LOT",
                  value: formatIntWithNull(
                    totalLot,
                    checkThousand: true,
                    decimalNum: 2,
                  ),
                  additionalInfo: "(${formatDecimal(
                    totalLotPercentage,
                    times: 100,
                    decimal: 2,
                  )}%)",
                  fontSize: 12,
                  additionalFontSize: 10,
                ),
                const SizedBox(width: 5,),
                _rowInformation(
                  title: "VALUE",
                  value: formatIntWithNull(
                    totalValue,
                    checkThousand: true,
                    decimalNum: 2,
                  ),
                  additionalInfo: "(${formatDecimal(
                    totalValuePercentage,
                    times: 100,
                    decimal: 2,
                  )}%)",
                  fontSize: 12,
                  additionalFontSize: 10,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _rowInformation({
    required String title,
    required String value,
    String additionalInfo = '',
    double fontSize = 18,
    Color color = textPrimary,
    double additionalFontSize = 18,
    Color additionalColor = textPrimary,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              width: 1.0,
              color: primaryLight,
              style: BorderStyle.solid,
            )
          )
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: TextStyle(
                fontSize: 10,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: fontSize,
                color: color,
              ),
            ),
            Visibility(
              visible: (additionalInfo.isNotEmpty),
              child: Text(
                additionalInfo,
                style: TextStyle(
                  fontSize: additionalFontSize,
                  color: additionalColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _getSectorFlowDetail() async {
    await Future.wait([
      _brokerSummaryAPI.getBrokerSummarySectorFlowDetail(
        sectorName: _args.data.sectorName,
      ).then((resp) {
        _sectorFlowList = resp;

        // generate the graph and row data
        _generateGraphAndRowData();
      }),
    ]).onError((error, stackTrace) {
      Log.error(
        message: 'Error getting broker sector flow detail data',
        error: error,
        stackTrace: stackTrace,
      );

      throw Exception('Error when get broker sector flow');
    },).whenComplete(() {
      // remove loading screen when finished
      LoadingScreen.instance().hide();
    },);
    // all good return true
    return true;
  }

  void _generateGraphAndRowData() {
    // when reach here we should already have all the data from the sector
    // we will have 2 structure for domestic and foreign.

    // first let's clear the graph and row data
    _graphData.clear();
    _rowData.clear();

    // now let's arrange all the date both domestic and foreign
    Map<DateTime, bool> dateMap = {};
    // loop thru domestic and foreign subsequently
    for(SectorDetail data in _sectorFlowList.domestic) {
      dateMap[data.date] = true;
    }
    for(SectorDetail data in _sectorFlowList.foreign) {
      dateMap[data.date] = true;
    }

    // get the key from date list, and put it on the list
    List<DateTime> dateList = dateMap.keys.toList();
    dateList.sort();

    // ensure we have at least 1 date list
    if (dateList.isEmpty) {
      return;
    }

    // get the max date
    DateTime maxDate = dateList[dateList.length - 1];
    String dateKey;

    // now generate the all the graph and map data
    Map<String, double> domesticSell30D = {};
    Map<String, double> domesticSell90D = {};
    Map<String, double> domesticSell6M = {};
    Map<String, double> domesticSell9M = {};
    Map<String, double> domesticSell1Y = {};

    Map<String, double> domesticBuy30D = {};
    Map<String, double> domesticBuy90D = {};
    Map<String, double> domesticBuy6M = {};
    Map<String, double> domesticBuy9M = {};
    Map<String, double> domesticBuy1Y = {};

    Map<String, double> domesticNet30D = {};
    Map<String, double> domesticNet90D = {};
    Map<String, double> domesticNet6M = {};
    Map<String, double> domesticNet9M = {};
    Map<String, double> domesticNet1Y = {};

    Map<String, double> foreignSell30D = {};
    Map<String, double> foreignSell90D = {};
    Map<String, double> foreignSell6M = {};
    Map<String, double> foreignSell9M = {};
    Map<String, double> foreignSell1Y = {};

    Map<String, double> foreignBuy30D = {};
    Map<String, double> foreignBuy90D = {};
    Map<String, double> foreignBuy6M = {};
    Map<String, double> foreignBuy9M = {};
    Map<String, double> foreignBuy1Y = {};

    Map<String, double> foreignNet30D = {};
    Map<String, double> foreignNet90D = {};
    Map<String, double> foreignNet6M = {};
    Map<String, double> foreignNet9M = {};
    Map<String, double> foreignNet1Y = {};
    
    Map<String, double> allSell30D = {};
    Map<String, double> allSell90D = {};
    Map<String, double> allSell6M = {};
    Map<String, double> allSell9M = {};
    Map<String, double> allSell1Y = {};

    Map<String, double> allBuy30D = {};
    Map<String, double> allBuy90D = {};
    Map<String, double> allBuy6M = {};
    Map<String, double> allBuy9M = {};
    Map<String, double> allBuy1Y = {};

    Map<String, double> allNet30D = {};
    Map<String, double> allNet90D = {};
    Map<String, double> allNet6M = {};
    Map<String, double> allNet9M = {};
    Map<String, double> allNet1Y = {};

    // table data
    Map<String, InsightBrokerRowData> domestic30D = {};
    Map<String, InsightBrokerRowData> domestic90D = {};
    Map<String, InsightBrokerRowData> domestic6M = {};
    Map<String, InsightBrokerRowData> domestic9M = {};
    Map<String, InsightBrokerRowData> domestic1Y = {};

    Map<String, InsightBrokerRowData> foreign30D = {};
    Map<String, InsightBrokerRowData> foreign90D = {};
    Map<String, InsightBrokerRowData> foreign6M = {};
    Map<String, InsightBrokerRowData> foreign9M = {};
    Map<String, InsightBrokerRowData> foreign1Y = {};

    Map<String, InsightBrokerRowData> all30D = {};
    Map<String, InsightBrokerRowData> all90D = {};
    Map<String, InsightBrokerRowData> all6M = {};
    Map<String, InsightBrokerRowData> all9M = {};
    Map<String, InsightBrokerRowData> all1Y = {};

    // initialize all the data
    for(DateTime date in dateList) {
      dateKey = Globals.dfddMMyy.format(date);

      // check if this is 30D
      if (maxDate.difference(date).inDays <= 30) {
        domesticSell30D[dateKey] = 0;
        domesticBuy30D[dateKey] = 0;
        domesticNet30D[dateKey] = 0;

        foreignSell30D[dateKey] = 0;
        foreignBuy30D[dateKey] = 0;
        foreignNet30D[dateKey] = 0;

        allSell30D[dateKey] = 0;
        allBuy30D[dateKey] = 0;
        allNet30D[dateKey] = 0;
      }

      if (maxDate.difference(date).inDays <= 90) {
        domesticSell90D[dateKey] = 0;
        domesticBuy90D[dateKey] = 0;
        domesticNet90D[dateKey] = 0;

        foreignSell90D[dateKey] = 0;
        foreignBuy90D[dateKey] = 0;
        foreignNet90D[dateKey] = 0;

        allSell90D[dateKey] = 0;
        allBuy90D[dateKey] = 0;
        allNet90D[dateKey] = 0;
      }

      if (maxDate.difference(date).inDays <= 180) {
        domesticSell6M[dateKey] = 0;
        domesticBuy6M[dateKey] = 0;
        domesticNet6M[dateKey] = 0;

        foreignSell6M[dateKey] = 0;
        foreignBuy6M[dateKey] = 0;
        foreignNet6M[dateKey] = 0;

        allSell6M[dateKey] = 0;
        allBuy6M[dateKey] = 0;
        allNet6M[dateKey] = 0;
      }

      if (maxDate.difference(date).inDays <= 270) {
        domesticSell9M[dateKey] = 0;
        domesticBuy9M[dateKey] = 0;
        domesticNet9M[dateKey] = 0;

        foreignSell9M[dateKey] = 0;
        foreignBuy9M[dateKey] = 0;
        foreignNet9M[dateKey] = 0;

        allSell9M[dateKey] = 0;
        allBuy9M[dateKey] = 0;
        allNet9M[dateKey] = 0;
      }

      domesticSell1Y[dateKey] = 0;
      domesticBuy1Y[dateKey] = 0;
      domesticNet1Y[dateKey] = 0;

      foreignSell1Y[dateKey] = 0;
      foreignBuy1Y[dateKey] = 0;
      foreignNet1Y[dateKey] = 0;

      allSell1Y[Globals.dfddMMyy.format(date)] = 0;
      allBuy1Y[Globals.dfddMMyy.format(date)] = 0;
      allNet1Y[Globals.dfddMMyy.format(date)] = 0;
    }

    // now we will fill the domestic, foreign, and all data based on the info
    // on the _sectorList

    for(SectorDetail data in _sectorFlowList.domestic) {
      dateKey = Globals.dfddMMyy.format(data.date);

      // check if this is 30D
      if (maxDate.difference(data.date).inDays <= 30) {
        // add the graph data
        domesticSell30D[dateKey] = data.totalSellValue.toDouble();
        domesticBuy30D[dateKey] = data.totalBuyValue.toDouble();
        domesticNet30D[dateKey] = data.totalBuyValue.toDouble() - data.totalSellValue.toDouble();

        allSell30D[dateKey] = (allSell30D[dateKey] ?? 0) + data.totalSellValue.toDouble();
        allBuy30D[dateKey] = (allBuy30D[dateKey] ?? 0) + data.totalBuyValue.toDouble();
        allNet30D[dateKey] = (allNet30D[dateKey] ?? 0) + (data.totalBuyValue.toDouble() - data.totalSellValue.toDouble());

        // add the row data
        domestic30D[dateKey] = InsightBrokerRowData(buy: data.totalBuyValue, sell: data.totalSellValue, net: data.totalNetValue);
        if (all30D.containsKey(dateKey)) {
          all30D[dateKey] = InsightBrokerRowData(buy: all30D[dateKey]!.buy + data.totalBuyValue, sell: all30D[dateKey]!.sell + data.totalSellValue, net: all30D[dateKey]!.net + data.totalNetValue);
        }
        else {
          all30D[dateKey] = InsightBrokerRowData(buy: data.totalBuyValue, sell: data.totalSellValue, net: data.totalNetValue);
        }
      }

      if (maxDate.difference(data.date).inDays <= 90) {
        // add the graph data
        domesticSell90D[dateKey] = data.totalSellValue.toDouble();
        domesticBuy90D[dateKey] = data.totalBuyValue.toDouble();
        domesticNet90D[dateKey] = data.totalBuyValue.toDouble() - data.totalSellValue.toDouble();

        allSell90D[dateKey] = (allSell90D[dateKey] ?? 0) + data.totalSellValue.toDouble();
        allBuy90D[dateKey] = (allBuy90D[dateKey] ?? 0) + data.totalBuyValue.toDouble();
        allNet90D[dateKey] = (allNet90D[dateKey] ?? 0) + (data.totalBuyValue.toDouble() - data.totalSellValue.toDouble());

        // add the row data
        domestic90D[dateKey] = InsightBrokerRowData(buy: data.totalBuyValue, sell: data.totalSellValue, net: data.totalNetValue);
        if (all90D.containsKey(dateKey)) {
          all90D[dateKey] = InsightBrokerRowData(buy: all90D[dateKey]!.buy + data.totalBuyValue, sell: all90D[dateKey]!.sell + data.totalSellValue, net: all90D[dateKey]!.net + data.totalNetValue);
        }
        else {
          all90D[dateKey] = InsightBrokerRowData(buy: data.totalBuyValue, sell: data.totalSellValue, net: data.totalNetValue);
        }
      }

      if (maxDate.difference(data.date).inDays <= 180) {
        // add graph data
        domesticSell6M[dateKey] = data.totalSellValue.toDouble();
        domesticBuy6M[dateKey] = data.totalBuyValue.toDouble();
        domesticNet6M[dateKey] = data.totalBuyValue.toDouble() - data.totalSellValue.toDouble();

        allSell6M[dateKey] = (allSell6M[dateKey] ?? 0) + data.totalSellValue.toDouble();
        allBuy6M[dateKey] = (allSell6M[dateKey] ?? 0) + data.totalBuyValue.toDouble();
        allNet6M[dateKey] = (allSell6M[dateKey] ?? 0) + (data.totalBuyValue.toDouble() - data.totalSellValue.toDouble());

        // add the row data
        domestic6M[dateKey] = InsightBrokerRowData(buy: data.totalBuyValue, sell: data.totalSellValue, net: data.totalNetValue);
        if (all6M.containsKey(dateKey)) {
          all6M[dateKey] = InsightBrokerRowData(buy: all6M[dateKey]!.buy + data.totalBuyValue, sell: all6M[dateKey]!.sell + data.totalSellValue, net: all6M[dateKey]!.net + data.totalNetValue);
        }
        else {
          all6M[dateKey] = InsightBrokerRowData(buy: data.totalBuyValue, sell: data.totalSellValue, net: data.totalNetValue);
        }
      }

      if (maxDate.difference(data.date).inDays <= 270) {
        // add graph data
        domesticSell9M[dateKey] = data.totalSellValue.toDouble();
        domesticBuy9M[dateKey] = data.totalBuyValue.toDouble();
        domesticNet9M[dateKey] = data.totalBuyValue.toDouble() - data.totalSellValue.toDouble();

        allSell9M[dateKey] = (allSell9M[dateKey] ?? 0) + data.totalSellValue.toDouble();
        allBuy9M[dateKey] = (allSell9M[dateKey] ?? 0) + data.totalBuyValue.toDouble();
        allNet9M[dateKey] = (allSell9M[dateKey] ?? 0) + (data.totalBuyValue.toDouble() - data.totalSellValue.toDouble());

        // add the row data
        domestic9M[dateKey] = InsightBrokerRowData(buy: data.totalBuyValue, sell: data.totalSellValue, net: data.totalNetValue);
        if (all9M.containsKey(dateKey)) {
          all9M[dateKey] = InsightBrokerRowData(buy: all9M[dateKey]!.buy + data.totalBuyValue, sell: all9M[dateKey]!.sell + data.totalSellValue, net: all9M[dateKey]!.net + data.totalNetValue);
        }
        else {
          all9M[dateKey] = InsightBrokerRowData(buy: data.totalBuyValue, sell: data.totalSellValue, net: data.totalNetValue);
        }
      }

      // add graph data
      domesticSell1Y[dateKey] = data.totalSellValue.toDouble();
      domesticBuy1Y[dateKey] = data.totalBuyValue.toDouble();
      domesticNet1Y[dateKey] = data.totalBuyValue.toDouble() - data.totalSellValue.toDouble();

      allSell1Y[dateKey] = (allSell1Y[dateKey] ?? 0) + data.totalSellValue.toDouble();
      allBuy1Y[dateKey] = (allSell1Y[dateKey] ?? 0) + data.totalBuyValue.toDouble();
      allNet1Y[dateKey] = (allSell1Y[dateKey] ?? 0) + (data.totalBuyValue.toDouble() - data.totalSellValue.toDouble());

      // add the row data
      domestic1Y[dateKey] = InsightBrokerRowData(buy: data.totalBuyValue, sell: data.totalSellValue, net: data.totalNetValue);
      if (all1Y.containsKey(dateKey)) {
        all1Y[dateKey] = InsightBrokerRowData(buy: all1Y[dateKey]!.buy + data.totalBuyValue, sell: all1Y[dateKey]!.sell + data.totalSellValue, net: all1Y[dateKey]!.net + data.totalNetValue);
      }
      else {
        all1Y[dateKey] = InsightBrokerRowData(buy: data.totalBuyValue, sell: data.totalSellValue, net: data.totalNetValue);
      }
    }

    for(SectorDetail data in _sectorFlowList.foreign) {
      dateKey = Globals.dfddMMyy.format(data.date);

      // check if this is 30D
      if (maxDate.difference(data.date).inDays <= 30) {
        // add graph data
        foreignSell30D[dateKey] = data.totalSellValue.toDouble();
        foreignBuy30D[dateKey] = data.totalBuyValue.toDouble();
        foreignNet30D[dateKey] = data.totalBuyValue.toDouble() - data.totalSellValue.toDouble();

        allSell30D[dateKey] = (allSell30D[dateKey] ?? 0) + data.totalSellValue.toDouble();
        allBuy30D[dateKey] = (allBuy30D[dateKey] ?? 0) + data.totalBuyValue.toDouble();
        allNet30D[dateKey] = (allNet30D[dateKey] ?? 0) + (data.totalBuyValue.toDouble() - data.totalSellValue.toDouble());

        // add the row data
        foreign30D[dateKey] = InsightBrokerRowData(buy: data.totalBuyValue, sell: data.totalSellValue, net: data.totalNetValue);
        if (all30D.containsKey(dateKey)) {
          all30D[dateKey] = InsightBrokerRowData(buy: all30D[dateKey]!.buy + data.totalBuyValue, sell: all30D[dateKey]!.sell + data.totalSellValue, net: all30D[dateKey]!.net + data.totalNetValue);
        }
        else {
          all30D[dateKey] = InsightBrokerRowData(buy: data.totalBuyValue, sell: data.totalSellValue, net: data.totalNetValue);
        }
      }

      if (maxDate.difference(data.date).inDays <= 90) {
        // add graph data
        foreignSell90D[dateKey] = data.totalSellValue.toDouble();
        foreignBuy90D[dateKey] = data.totalBuyValue.toDouble();
        foreignNet90D[dateKey] = data.totalBuyValue.toDouble() - data.totalSellValue.toDouble();

        allSell90D[dateKey] = (allSell90D[dateKey] ?? 0) + data.totalSellValue.toDouble();
        allBuy90D[dateKey] = (allBuy90D[dateKey] ?? 0) + data.totalBuyValue.toDouble();
        allNet90D[dateKey] = (allNet90D[dateKey] ?? 0) + (data.totalBuyValue.toDouble() - data.totalSellValue.toDouble());

        // add the row data
        foreign90D[dateKey] = InsightBrokerRowData(buy: data.totalBuyValue, sell: data.totalSellValue, net: data.totalNetValue);
        if (all90D.containsKey(dateKey)) {
          all90D[dateKey] = InsightBrokerRowData(buy: all90D[dateKey]!.buy + data.totalBuyValue, sell: all90D[dateKey]!.sell + data.totalSellValue, net: all90D[dateKey]!.net + data.totalNetValue);
        }
        else {
          all90D[dateKey] = InsightBrokerRowData(buy: data.totalBuyValue, sell: data.totalSellValue, net: data.totalNetValue);
        }
      }

      if (maxDate.difference(data.date).inDays <= 180) {
        // add graph data
        foreignSell6M[dateKey] = data.totalSellValue.toDouble();
        foreignBuy6M[dateKey] = data.totalBuyValue.toDouble();
        foreignNet6M[dateKey] = data.totalBuyValue.toDouble() - data.totalSellValue.toDouble();

        allSell6M[dateKey] = (allSell6M[dateKey] ?? 0) + data.totalSellValue.toDouble();
        allBuy6M[dateKey] = (allSell6M[dateKey] ?? 0) + data.totalBuyValue.toDouble();
        allNet6M[dateKey] = (allSell6M[dateKey] ?? 0) + (data.totalBuyValue.toDouble() - data.totalSellValue.toDouble());

        // add the row data
        foreign6M[dateKey] = InsightBrokerRowData(buy: data.totalBuyValue, sell: data.totalSellValue, net: data.totalNetValue);
        if (all6M.containsKey(dateKey)) {
          all6M[dateKey] = InsightBrokerRowData(buy: all6M[dateKey]!.buy + data.totalBuyValue, sell: all6M[dateKey]!.sell + data.totalSellValue, net: all6M[dateKey]!.net + data.totalNetValue);
        }
        else {
          all6M[dateKey] = InsightBrokerRowData(buy: data.totalBuyValue, sell: data.totalSellValue, net: data.totalNetValue);
        }
      }

      if (maxDate.difference(data.date).inDays <= 270) {
        // add graph data
        foreignSell9M[dateKey] = data.totalSellValue.toDouble();
        foreignBuy9M[dateKey] = data.totalBuyValue.toDouble();
        foreignNet9M[dateKey] = data.totalBuyValue.toDouble() - data.totalSellValue.toDouble();

        allSell9M[dateKey] = (allSell9M[dateKey] ?? 0) + data.totalSellValue.toDouble();
        allBuy9M[dateKey] = (allSell9M[dateKey] ?? 0) + data.totalBuyValue.toDouble();
        allNet9M[dateKey] = (allSell9M[dateKey] ?? 0) + (data.totalBuyValue.toDouble() - data.totalSellValue.toDouble());

        // add the row data
        foreign9M[dateKey] = InsightBrokerRowData(buy: data.totalBuyValue, sell: data.totalSellValue, net: data.totalNetValue);
        if (all9M.containsKey(dateKey)) {
          all9M[dateKey] = InsightBrokerRowData(buy: all9M[dateKey]!.buy + data.totalBuyValue, sell: all9M[dateKey]!.sell + data.totalSellValue, net: all9M[dateKey]!.net + data.totalNetValue);
        }
        else {
          all9M[dateKey] = InsightBrokerRowData(buy: data.totalBuyValue, sell: data.totalSellValue, net: data.totalNetValue);
        }
      }

      // add graph data
      foreignSell1Y[dateKey] = data.totalSellValue.toDouble();
      foreignBuy1Y[dateKey] = data.totalBuyValue.toDouble();
      foreignNet1Y[dateKey] = data.totalBuyValue.toDouble() - data.totalSellValue.toDouble();

      allSell1Y[dateKey] = (allSell1Y[dateKey] ?? 0) + data.totalSellValue.toDouble();
      allBuy1Y[dateKey] = (allSell1Y[dateKey] ?? 0) + data.totalBuyValue.toDouble();
      allNet1Y[dateKey] = (allSell1Y[dateKey] ?? 0) + (data.totalBuyValue.toDouble() - data.totalSellValue.toDouble());

      // add the row data
      foreign1Y[dateKey] = InsightBrokerRowData(buy: data.totalBuyValue, sell: data.totalSellValue, net: data.totalNetValue);
      if (all1Y.containsKey(dateKey)) {
        all1Y[dateKey] = InsightBrokerRowData(buy: all1Y[dateKey]!.buy + data.totalBuyValue, sell: all1Y[dateKey]!.sell + data.totalSellValue, net: all1Y[dateKey]!.net + data.totalNetValue);
      }
      else {
        all1Y[dateKey] = InsightBrokerRowData(buy: data.totalBuyValue, sell: data.totalSellValue, net: data.totalNetValue);
      }
    }

    // initialize the main data
    // graph data
    _graphData["a"] = {};
    _graphData["a"]!["30D"] = [];
    _graphData["a"]!["90D"] = [];
    _graphData["a"]!["6M"] = [];
    _graphData["a"]!["9M"] = [];
    _graphData["a"]!["1Y"] = [];

    _graphData["d"] = {};
    _graphData["d"]!["30D"] = [];
    _graphData["d"]!["90D"] = [];
    _graphData["d"]!["6M"] = [];
    _graphData["d"]!["9M"] = [];
    _graphData["d"]!["1Y"] = [];

    _graphData["f"] = {};
    _graphData["f"]!["30D"] = [];
    _graphData["f"]!["90D"] = [];
    _graphData["f"]!["6M"] = [];
    _graphData["f"]!["9M"] = [];
    _graphData["f"]!["1Y"] = [];
    
    // row data
    _rowData["a"] = {};
    _rowData["a"]!["30D"] = all30D;
    _rowData["a"]!["90D"] = all90D;
    _rowData["a"]!["6M"] = all6M;
    _rowData["a"]!["9M"] = all9M;
    _rowData["a"]!["1Y"] = all1Y;

    _rowData["d"] = {};
    _rowData["d"]!["30D"] = domestic30D;
    _rowData["d"]!["90D"] = domestic90D;
    _rowData["d"]!["6M"] = domestic6M;
    _rowData["d"]!["9M"] = domestic9M;
    _rowData["d"]!["1Y"] = domestic1Y;

    _rowData["f"] = {};
    _rowData["f"]!["30D"] = foreign30D;
    _rowData["f"]!["90D"] = foreign90D;
    _rowData["f"]!["6M"] = foreign6M;
    _rowData["f"]!["9M"] = foreign9M;
    _rowData["f"]!["1Y"] = foreign1Y;

    // now add all the data on the actual graph
    _graphData["a"]!["30D"]!.add(allBuy30D);
    _graphData["a"]!["30D"]!.add(allSell30D);
    _graphData["a"]!["30D"]!.add(allNet30D);

    _graphData["a"]!["90D"]!.add(allBuy90D);
    _graphData["a"]!["90D"]!.add(allSell90D);
    _graphData["a"]!["90D"]!.add(allNet90D);

    _graphData["a"]!["6M"]!.add(allBuy6M);
    _graphData["a"]!["6M"]!.add(allSell6M);
    _graphData["a"]!["6M"]!.add(allNet6M);

    _graphData["a"]!["9M"]!.add(allBuy9M);
    _graphData["a"]!["9M"]!.add(allSell9M);
    _graphData["a"]!["9M"]!.add(allNet9M);

    _graphData["a"]!["1Y"]!.add(allBuy1Y);
    _graphData["a"]!["1Y"]!.add(allSell1Y);
    _graphData["a"]!["1Y"]!.add(allNet1Y);

    _graphData["d"]!["30D"]!.add(domesticBuy30D);
    _graphData["d"]!["30D"]!.add(domesticSell30D);
    _graphData["d"]!["30D"]!.add(domesticNet30D);

    _graphData["d"]!["90D"]!.add(domesticBuy90D);
    _graphData["d"]!["90D"]!.add(domesticSell90D);
    _graphData["d"]!["90D"]!.add(domesticNet90D);

    _graphData["d"]!["6M"]!.add(domesticBuy6M);
    _graphData["d"]!["6M"]!.add(domesticSell6M);
    _graphData["d"]!["6M"]!.add(domesticNet6M);

    _graphData["d"]!["9M"]!.add(domesticBuy9M);
    _graphData["d"]!["9M"]!.add(domesticSell9M);
    _graphData["d"]!["9M"]!.add(domesticNet9M);

    _graphData["d"]!["1Y"]!.add(domesticBuy1Y);
    _graphData["d"]!["1Y"]!.add(domesticSell1Y);
    _graphData["d"]!["1Y"]!.add(domesticNet1Y);

    _graphData["f"]!["30D"]!.add(foreignBuy30D);
    _graphData["f"]!["30D"]!.add(foreignSell30D);
    _graphData["f"]!["30D"]!.add(foreignNet30D);

    _graphData["f"]!["90D"]!.add(foreignBuy90D);
    _graphData["f"]!["90D"]!.add(foreignSell90D);
    _graphData["f"]!["90D"]!.add(foreignNet90D);

    _graphData["f"]!["6M"]!.add(foreignBuy6M);
    _graphData["f"]!["6M"]!.add(foreignSell6M);
    _graphData["f"]!["6M"]!.add(foreignNet6M);

    _graphData["f"]!["9M"]!.add(foreignBuy9M);
    _graphData["f"]!["9M"]!.add(foreignSell9M);
    _graphData["f"]!["9M"]!.add(foreignNet9M);

    _graphData["f"]!["1Y"]!.add(foreignBuy1Y);
    _graphData["f"]!["1Y"]!.add(foreignSell1Y);
    _graphData["f"]!["1Y"]!.add(foreignNet1Y);
  }
}