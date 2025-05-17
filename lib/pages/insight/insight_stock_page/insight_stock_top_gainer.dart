import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:my_wealth/_index.g.dart';
import 'package:provider/provider.dart';

class InsightStockTopGainerSubPage extends StatefulWidget {
  final Function({required String code}) getCompanyDetailAndGo;

  const InsightStockTopGainerSubPage({
    super.key,
    required this.getCompanyDetailAndGo,
  });

  @override
  State<InsightStockTopGainerSubPage> createState() => _InsightStockTopGainerSubPageState();
}

class _InsightStockTopGainerSubPageState extends State<InsightStockTopGainerSubPage> {
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

  late String _topCompanyPeriod;
  late TopWorseCompanyListModel _topCompanyList;

  @override
  void initState() {
    super.initState();

    // initialize the top company period as the 1st key
    _topCompanyPeriod = _selectableItemList.keys.first;

    // get the top company list
    _topCompanyList = InsightSharedPreferences.getTopWorseCompanyList(type: 'top');
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<InsightProvider>(
      builder: (context, insightProvider, child) {
        _topCompanyList = insightProvider.topCompanyList!;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            const Center(
              child: Text(
                "Top Gainer",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              )
            ),
            const SizedBox(height: 10,),
            SelectableList<String>(
              items: _selectableItemList,
              initialValue: _topCompanyPeriod,
              onPress: ((period) {
                setState(() {
                  _topCompanyPeriod = period;
                });
              })
            ),
            const SizedBox(height: 10,),
            _generateTopWorseList(codeColor: accentColor, gainColor: Colors.green),
          ],
        );
      },
    );
  }

  Widget _generateTopWorseList({required Color codeColor, required Color gainColor}) {
    List<CompanyInfo> info = [];
    
    // select which info we will display based on the _topPeriod
    switch(_topCompanyPeriod) {
      case '1d':
        info = _topCompanyList.companyList.the1D;
        break;
      case '1w':
        info = _topCompanyList.companyList.the1W;
        break;
      case 'mtd':
        info = _topCompanyList.companyList.theMTD;
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
              crossAxisAlignment: CrossAxisAlignment.center,
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
                Visibility(
                  visible: info[index].fca,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                    child: Icon(
                      Ionicons.warning,
                      size: 12,
                      color: secondaryColor,
                    ),
                  ),
                ),
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