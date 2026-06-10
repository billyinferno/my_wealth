import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:my_wealth/_index.g.dart';
import 'package:my_wealth/widgets/page/tab_content_view.dart';
import 'package:provider/provider.dart';

class InsightStockSectorSummarySubPage extends StatefulWidget {
  const InsightStockSectorSummarySubPage({
    super.key,
  });

  @override
  State<InsightStockSectorSummarySubPage> createState() => _InsightStockSectorSummarySubPageState();
}

class _InsightStockSectorSummarySubPageState extends State<InsightStockSectorSummarySubPage> with SingleTickerProviderStateMixin {
  // make selectable item list as final, since we will never change the list
  final Map<String,String> _selectableItemList = {
    '1d': '1d',
    '1w': '1w',
    'mtd': 'mtd',
    '1m': '1m',
    '3m': '3m',
    '6m': '6m',
    'ytd': 'ytd',
    '1y': '1y',
    '3y': '3y',
    '5y': '5y',
  };
  final ScrollController _summaryController = ScrollController();
  final ScrollController _flowController = ScrollController();

  late String _sectorSummaryPeriod;
  late List<SectorSummaryModel> _sectorSummaryList;
  late List<BrokerSummarySectorFlowModel> _sectorFlowList;
  late UserLoginInfoModel? _userInfo;

  @override
  void initState() {
    super.initState();
    
    // default to the first key
    _sectorSummaryPeriod = _selectableItemList.keys.first;

    // get the sector summary list from the shared preferences on the init
    _sectorSummaryList = InsightSharedPreferences.getSectorSummaryList();

    // get the broker summary sector flow list from the shared preferences on the init
    _sectorFlowList = BrokerSharedPreferences.getBrokerSummarySectorFlow();

    // get the user information
    _userInfo = UserSharedPreferences.getUserInfo();
  }

  @override
  void dispose() {
    _summaryController.dispose();
    _flowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<InsightProvider, BrokerProvider>(builder: (
      context,
      insightProvider,
      brokerProvider,
      child,
    ) {
      
      // get the sector summary list from the provider, so in case there are
      // any update on the data we will also refresh the page
      _sectorSummaryList = (insightProvider.sectorSummaryList ?? []);
    
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          DefaultTabController(
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
                    Tab(text: 'SUMMARY',),
                    Tab(text: 'FLOW'),
                  ],
                ),
                const SizedBox(height: 10,),
                TabContentView(
                  children: <Widget>[
                    _sectorSummary(),
                    _sectorFlow(),
                  ],
                ),
              ]
            ),
          ),
        ],
      );
    },);
  }

  Widget _sectorSummary() {
    return Column(
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
        SelectableList<String>(
          items: _selectableItemList,
          initialValue: _sectorSummaryPeriod,
          onPress: ((period) {
            setState(() {
              _sectorSummaryPeriod = period;
            });
          })
        ),
        const SizedBox(height: 10,),
        GridView.count(
          controller: _summaryController,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
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
              case 'mtd':
                sectorAverage = _sectorSummaryList[index].sectorAverage.theMTD;
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
            Color bgColor = riskColor(
              value: (1 + sectorAverage),
              cost: 1,
              riskFactor: _userInfo!.risk
            );
            Color textColor = riskColorReverse(
              value: (1 + sectorAverage),
              cost: 1
            );
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
                    Center(
                      child: Text(
                        "${formatDecimal(
                          (sectorAverage * 100),
                          decimal: 2
                        )}%",
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
      ]
    );
  }

  Widget _sectorFlow() {
    double cardAspectRatio = (90 / 120);
    
    // ensure that we have data for the sector flow, if not just return no data
    if (_sectorFlowList.isEmpty) {
      return Center(
        child: Text("No sector flow data available"),
      );
    }

    // get the sector flow date from the first data, since all data should have the same date
    String sectorFlowDate = Globals.dfDDMMMyyyy.format(_sectorFlowList[0].brokerSummaryDate);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Center(
          child: Text(
            "Money Flow as of $sectorFlowDate",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 10,),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  color: Colors.grey,
                  width: 1.0,
                  style: BorderStyle.solid,
                )
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    LucideIcons.globe,
                    size: 12,
                  ),
                  const SizedBox(width: 2,),
                  Text(
                    "Foreign Flow",
                    style: TextStyle(
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10,),
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  color: Colors.grey,
                  width: 1.0,
                  style: BorderStyle.solid,
                )
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    LucideIcons.flag,
                    size: 14,
                  ),
                  const SizedBox(width: 2,),
                  Text(
                    "Domestic Flow",
                    style: TextStyle(
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10,),
        GridView.count(
          childAspectRatio: cardAspectRatio,
          controller: _flowController,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          children: List<Widget>.generate(_sectorFlowList.length, (index) {
            // check the color for the sector flow, if the value is positive then it will be green, if negative then it will be red, if zero then it will be blue
            int totalNetValue = _sectorFlowList[index].totalValueForeignNet + _sectorFlowList[index].totalValueDomesticNet;
            int prevTotalNetValue = _sectorFlowList[index].prevTotalValueDomesticNet + _sectorFlowList[index].prevTotalValueForeignNet;
            double netValueChange = prevTotalNetValue != 0 ? ((totalNetValue - prevTotalNetValue) / prevTotalNetValue).makePositive() : 0;

            Color bgColor = extendedColor;
            if (totalNetValue > 0) {
              bgColor = Colors.green[300]!;
            }
            else if (totalNetValue < 0) {
              bgColor = secondaryLight;
            }

            Color borderColor = extendedDark;
            if (totalNetValue > 0) {
              borderColor = Color.fromARGB(255, 15, 88, 17);
            }
            else if (totalNetValue < 0) {
              borderColor = secondaryDark;
            }

            Color iconColor = Colors.white;
            if (totalNetValue > 0) {
              iconColor = Color.fromARGB(255, 15, 88, 17);
            }
            else if (totalNetValue < 0) {
              iconColor = secondaryDark;
            }

            Color foreignBgColor = extendedDark;
            if (_sectorFlowList[index].totalValueForeignNet > 0) {
              foreignBgColor = Color.fromARGB(255, 15, 88, 17);
            }
            else if (_sectorFlowList[index].totalValueForeignNet < 0) {
              foreignBgColor = secondaryDark;
            }

            Color domesticBgColor = extendedDark;
            if (_sectorFlowList[index].totalValueDomesticNet > 0) {
              domesticBgColor = Color.fromARGB(255, 15, 88, 17);
            }
            else if (_sectorFlowList[index].totalValueDomesticNet < 0) {
              domesticBgColor = secondaryDark;
            }

            //TODO: to add InkWell to go to next page to showed top 10 of foreign and domestic for each sector
            return Container(
              padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
              margin: const EdgeInsets.all(5),
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Globals.sectorIcon[_sectorFlowList[index].sectorName] ?? LucideIcons.circle_question_mark,
                        size: 20,
                        color: iconColor,
                      ),
                      const SizedBox(height: 5,),
                      Text(
                        _sectorFlowList[index].sectorName,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: iconColor,
                        ),
                      ),
                      const SizedBox(height: 5,),
                      Text(
                        formatIntWithNull(
                          totalNetValue,
                          checkThousand: true,
                          decimalNum: 2,
                          shorten: true,
                          showDecimal: true,
                        ),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: iconColor,
                        ),
                      ),
                      Text(
                        "${formatDecimalWithNull(
                          netValueChange * 100,
                          decimal: 2,
                        )}% (${formatIntWithNull(prevTotalNetValue, checkThousand: true)})",
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: iconColor,
                        ),
                      ),
                    ]
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.all(5),
                        margin: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                        decoration: BoxDecoration(
                          color: foreignBgColor,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Icon(
                              LucideIcons.globe,
                              color: textPrimary,
                              size: 15,
                            ),
                            const SizedBox(width: 5,),
                            Expanded(
                              child: Text(
                                formatIntWithNull(
                                  _sectorFlowList[index].totalValueForeignNet,
                                  checkThousand: true,
                                  decimalNum: 2,
                                  shorten: true,
                                  showDecimal: true,
                                ),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(5),
                        margin: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                        decoration: BoxDecoration(
                          color: domesticBgColor,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Icon(
                              LucideIcons.flag,
                              color: textPrimary,
                              size: 15,
                            ),
                            const SizedBox(width: 5,),
                            Expanded(
                              child: Text(
                                formatIntWithNull(
                                  _sectorFlowList[index].totalValueDomesticNet,
                                  checkThousand: true,
                                  decimalNum: 2,
                                  shorten: true,
                                  showDecimal: true,
                                ),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ),
      ]
    );
  }
}