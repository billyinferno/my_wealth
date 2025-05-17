import 'package:flutter/material.dart';
import 'package:my_wealth/_index.g.dart';
import 'package:provider/provider.dart';

class InsightStockSectorSummarySubPage extends StatefulWidget {
  const InsightStockSectorSummarySubPage({
    super.key,
  });

  @override
  State<InsightStockSectorSummarySubPage> createState() => _InsightStockSectorSummarySubPageState();
}

class _InsightStockSectorSummarySubPageState extends State<InsightStockSectorSummarySubPage> {
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

  late String _sectorSummaryPeriod;
  late List<SectorSummaryModel> _sectorSummaryList;
  late UserLoginInfoModel? _userInfo;

  @override
  void initState() {
    super.initState();

    // default to the first key
    _sectorSummaryPeriod = _selectableItemList.keys.first;

    // get the sector summary list from the shared preferences on the init
    _sectorSummaryList = InsightSharedPreferences.getSectorSummaryList();

    // get the user information
    _userInfo = UserSharedPreferences.getUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<InsightProvider>(builder: (
      context,
      insightProvider,
      child,
    ) {
      
      // get the sector summary list from the provider, so in case there are
      // any update on the data we will also refresh the page
      _sectorSummaryList = (insightProvider.sectorSummaryList ?? []);

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
            SizedBox(
              width: double.infinity,
              child: GridView.count(
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
            ),
        ],
      );
    },);
  }
}