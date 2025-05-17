import 'package:flutter/material.dart';
import 'package:my_wealth/_index.g.dart';
import 'package:provider/provider.dart';

class InsightStockTopLoserSubPage extends StatefulWidget {
  final Function({required String code}) getCompanyDetailAndGo;

  const InsightStockTopLoserSubPage({
    super.key,
    required this.getCompanyDetailAndGo,
  });

  @override
  State<InsightStockTopLoserSubPage> createState() => _InsightStockTopLoserSubPageState();
}

class _InsightStockTopLoserSubPageState extends State<InsightStockTopLoserSubPage> {
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

  late String _worseCompanyPeriod;
  late TopWorseCompanyListModel _worseCompanyList;

  @override
  void initState() {
    super.initState();

    // default the worse company period as the first key
    _worseCompanyPeriod = _selectableItemList.keys.first;

    // get the top worse company from the shared preferences
    _worseCompanyList = InsightSharedPreferences.getTopWorseCompanyList(type: 'worse');
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<InsightProvider>(
      builder: (context, insightProvider, child) {
        // get the worse company list from the provide, so when we have any
        // changes on the provider it will refresh the page
        _worseCompanyList = insightProvider.worseCompanyList!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            const Center(
              child: Text(
                "Top Loser",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              )
            ),
            const SizedBox(height: 10,),
            SelectableList<String>(
              items: _selectableItemList,
              initialValue: _worseCompanyPeriod,
              onPress: ((period) {
                setState(() {
                  _worseCompanyPeriod = period;
                });
              })
            ),
            const SizedBox(height: 10,),
            _generateTopWorseList(codeColor: accentColor, gainColor: secondaryLight),
            const SizedBox(height: 20,),
          ],
        );
      },
    );
  }

  Widget _generateTopWorseList({required Color codeColor, required Color gainColor}) {
    List<CompanyInfo> info = [];
    
    // select which info we will display based on the _topPeriod
    switch(_worseCompanyPeriod) {
      case '1d':
        info = _worseCompanyList.companyList.the1D;
        break;
      case '1w':
        info = _worseCompanyList.companyList.the1W;
        break;
      case 'mtd':
        info = _worseCompanyList.companyList.theMTD;
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: List.generate(info.length, (index) {
        return InkWell(
          onTap: () {
            widget.getCompanyDetailAndGo(code: info[index].code);
          },
          child: Container(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
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
}