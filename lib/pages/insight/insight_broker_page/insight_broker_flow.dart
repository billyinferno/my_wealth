import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_wealth/_index.g.dart';
import 'package:my_wealth/utils/icon/my_ionicons.dart';

class InsightBrokerRowData {
  const InsightBrokerRowData({
    required this.buy,
    required this.sell,
    required this.net,
  });

  final int buy;
  final int sell;
  final int net;
}

class InsightBrokerFlowPage extends StatefulWidget {
  const InsightBrokerFlowPage({super.key});

  @override
  State<InsightBrokerFlowPage> createState() => InsightBrokerFlowPageState();
}

class InsightBrokerFlowPageState extends State<InsightBrokerFlowPage> {
  final ScrollController _scrollController = ScrollController();

  late String _brokerSelection;
  late BrokerSummaryFlowModel? _brokerSummaryFlow;
  late Map<String, List<Map<String, double>>> _brokerSummaryGraphData;
  late Map<String, Map<DateTime, InsightBrokerRowData>> _brokerSummaryRowData;
  late int _totalNetPlus;
  late int _totalNetNegative;
  late int _totalBuy;
  late int _totalSell;
  late int _totalNet;

  @override
  void initState() {
    super.initState();

    // defaulted to all selection
    _brokerSelection = "a";

    // get the broker summary flow from shared preferences
    _brokerSummaryFlow = BrokerSharedPreferences.getBrokerSummaryFlow();

    // default the total net to 0
    _totalNetPlus = 0;
    _totalNetNegative = 0;

    // default the total row to 0
    _totalBuy = 0;
    _totalSell = 0;
    _totalNet = 0;

    // initialize the broker summary data
    // this will hold all the data from domestic, foreign, and all
    // and we will showed the graph based on the selection
    _brokerSummaryGraphData = {};
    _brokerSummaryRowData = {};
    _generateBrokerSummaryData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
        title: const Center(
          child: Text(
            "Broker Transaction Flow",
            style: TextStyle(
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
                    _brokerSelection = value;
                  });
                }),
                groupValue: _brokerSelection,
                selectedColor: secondaryColor,
                borderColor: secondaryDark,
                pressedColor: textPrimary,
              ),
            ),
            const SizedBox(height: 10,),
            MultiLineChart(
              height: 250,
              data: (_brokerSummaryGraphData[_brokerSelection] ?? []),
              color: const [Colors.green, Colors.red, Colors.blue],
              legend: const ["Buy", "Sell", "Net"],
              dateOffset: ((_brokerSummaryGraphData[_brokerSelection] ?? []).length ~/ 10),
            ),
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

  List<Widget> _generateBrokerTable() {
    List<Widget> ret = [];

    Map<DateTime, InsightBrokerRowData> rowData = (_brokerSummaryRowData[_brokerSelection] ?? {});

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
          date: Globals.dfDDMMMyyyy.format(date),
          buy: formatIntWithNull(row.buy),
          sell: formatIntWithNull(row.sell),
          net: formatIntWithNull(row.net),
          netColor: netColor,
        ));
      });
    }

    // return list of widget
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
          width: 120,
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

  void _generateBrokerSummaryData() {
    // we will generate the broker summary graph data here
    // ensure we have broker summary flow data first
    if (_brokerSummaryFlow == null) {
      return;
    }

    // clear the current data
    _brokerSummaryGraphData.clear();
    _brokerSummaryRowData.clear();

    // let's loop for all the broker summary flow data
    // create variables for the table data
    Map<DateTime, InsightBrokerRowData> allRow = {};
    Map<DateTime, InsightBrokerRowData> domesticRow = {};
    Map<DateTime, InsightBrokerRowData> foreignRow = {};

    // all will be combine for both domestic and foreign
    Map<String, double> allBuy = {};
    Map<String, double> allSell = {};
    Map<String, double> allNet = {};

    // first do for domestic
    Map<String, double> domesticBuy = {};
    Map<String, double> domesticSell = {};
    Map<String, double> domesticNet = {};

    for (BrokerSummaryFlowData data in _brokerSummaryFlow!.domestic) {
      domesticBuy[Globals.dfDDMMMyyyy.format(data.date)] = data.buyValue.toDouble();
      domesticSell[Globals.dfDDMMMyyyy.format(data.date)] = data.sellValue.toDouble();
      domesticNet[Globals.dfDDMMMyyyy.format(data.date)] = data.netValue.toDouble();

      // add to table data for domestic
      domesticRow[data.date] = InsightBrokerRowData(
        buy: data.buyValue,
        sell: data.sellValue,
        net: data.netValue,
      );

      // add to all data, as all doesn't have data yet
      allBuy[Globals.dfDDMMMyyyy.format(data.date)] = data.buyValue.toDouble();
      allSell[Globals.dfDDMMMyyyy.format(data.date)] = data.sellValue.toDouble();
      allNet[Globals.dfDDMMMyyyy.format(data.date)] = data.netValue.toDouble();

      // add to table data for all
      allRow[data.date] = InsightBrokerRowData(
        buy: data.buyValue,
        sell: data.sellValue,
        net: data.netValue,
      );
    }

    // now do for foreign
    Map<String, double> foreignBuy = {};
    Map<String, double> foreignSell = {};
    Map<String, double> foreignNet = {};

    for (BrokerSummaryFlowData data in _brokerSummaryFlow!.foreign) {
      foreignBuy[Globals.dfDDMMMyyyy.format(data.date)] = data.buyValue.toDouble();
      foreignSell[Globals.dfDDMMMyyyy.format(data.date)] = data.sellValue.toDouble();
      foreignNet[Globals.dfDDMMMyyyy.format(data.date)] = data.netValue.toDouble();

      // add to table data for foreign
      foreignRow[data.date] = InsightBrokerRowData(
        buy: data.buyValue,
        sell: data.sellValue,
        net: data.netValue,
      );

      // add to all data, if previous data already exists then add previous data
      // if not then default to foreign only
      allBuy[Globals.dfDDMMMyyyy.format(data.date)] = (allBuy[Globals.dfDDMMMyyyy.format(data.date)] ?? 0) + data.buyValue.toDouble();
      allSell[Globals.dfDDMMMyyyy.format(data.date)] = (allSell[Globals.dfDDMMMyyyy.format(data.date)] ?? 0) + data.sellValue.toDouble();
      allNet[Globals.dfDDMMMyyyy.format(data.date)] = (allNet[Globals.dfDDMMMyyyy.format(data.date)] ?? 0) + data.netValue.toDouble();

      // for all data, we need to check if we get previous data from domestic
      // or not?
      // if got then we need to combine the value with previous data
      // otherwise we can just add the data
      if (allRow.containsKey(data.date)) {
        InsightBrokerRowData prevData = allRow[data.date]!;
        allRow[data.date] = InsightBrokerRowData(
          buy: prevData.buy + data.buyValue,
          sell: prevData.sell + data.sellValue,
          net: prevData.net + data.netValue,
        );
      }
      else {
        allRow[data.date] = InsightBrokerRowData(
          buy: data.buyValue,
          sell: data.sellValue,
          net: data.netValue,
        );
      }
    }

    // initialize the data
    _brokerSummaryGraphData["a"] = [];
    _brokerSummaryGraphData["d"] = [];
    _brokerSummaryGraphData["f"] = [];

    // now all the data to the broker summary graph data
    _brokerSummaryGraphData["a"]!.add(allBuy);
    _brokerSummaryGraphData["a"]!.add(allSell);
    _brokerSummaryGraphData["a"]!.add(allNet);

    _brokerSummaryGraphData["d"]!.add(domesticBuy);
    _brokerSummaryGraphData["d"]!.add(domesticSell);
    _brokerSummaryGraphData["d"]!.add(domesticNet);

    _brokerSummaryGraphData["f"]!.add(foreignBuy);
    _brokerSummaryGraphData["f"]!.add(foreignSell);
    _brokerSummaryGraphData["f"]!.add(foreignNet);

    // move the row data
    _brokerSummaryRowData["a"] = allRow;
    _brokerSummaryRowData["d"] = domesticRow;
    _brokerSummaryRowData["f"] = foreignRow;

    //TODO: if somehow foreign and domestic have different date, we will screw up unless we sor the all map
  }
}