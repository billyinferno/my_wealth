import 'package:flutter/material.dart';
import 'package:my_wealth/_index.g.dart';
import 'package:provider/provider.dart';

class InsightReksadanaTopLoserSubPage extends StatefulWidget {
  final String type;
  final String title;
  const InsightReksadanaTopLoserSubPage({
    super.key,
    required this.type,
    required this.title,
  });

  @override
  State<InsightReksadanaTopLoserSubPage> createState() => _InsightReksadanaTopLoserSubPageState();
}

class _InsightReksadanaTopLoserSubPageState extends State<InsightReksadanaTopLoserSubPage> {
  final CompanyAPI _companyAPI = CompanyAPI();

  // list all the selectable item list as final
  final Map<String, String> _selectableItemList = {
    '1d': '1d',
    '1w': '1w',
    '1m': '1m',
    '3m': '3m',
    '6m': '6m',
    'ytd': 'ytd',
    '1y': '1y',
  };

  late TopWorseCompanyListModel _topReksadanaList;
  late TopWorseCompanyListModel _worseReksadanaList;
  late String _topPeriodSelected;
  late String _worsePeriodSelected;

  @override
  void initState() {
    super.initState();

    // get the top and worse reksadana list based on type from shared preferences
    // for initial data
    _topReksadanaList = InsightSharedPreferences.getTopReksadanaList(type: widget.type.toLowerCase());
    _worseReksadanaList = InsightSharedPreferences.getWorseReksadanaList(type: widget.type.toLowerCase());

    // default the period selected as the first key of selectable item list
    _topPeriodSelected = _selectableItemList.keys.first;
    _worsePeriodSelected = _selectableItemList.keys.first;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<InsightProvider>(builder: (context, insightProvider, child) {
      _topReksadanaList = insightProvider.topReksadanaList![widget.type.toLowerCase()] ?? TopWorseCompanyListModel(
        companyList: CompanyList(
          the1D: [],
          the1M: [],
          the1W: [],
          the1Y: [],
          the3M: [],
          the3Y: [],
          the5Y: [],
          the6M: [],
          theYTD: [],
          theMTD: [],
        ),
      );

      _worseReksadanaList = insightProvider.worseReksadanaList!['saham'] ?? TopWorseCompanyListModel(
        companyList: CompanyList(
          the1D: [],
          the1M: [],
          the1W: [],
          the1Y: [], the3M: [], the3Y: [], the5Y: [], the6M: [], theYTD: [], theMTD: []));

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Center(
            child: Text(
              "Top Gain ${widget.title}",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 10,),
          SelectableList<String>(
            items: _selectableItemList,
            initialValue: _topPeriodSelected,
            onPress: ((value) {
              setState(() {
                _topPeriodSelected = value;
              });
            })
          ),
          const SizedBox(height: 10,),
          _generateTopWorseList(
            reksadanaList: _topReksadanaList,
            period: _topPeriodSelected,
            codeColor: accentColor,
            gainColor: Colors.green,
          ),
          const SizedBox(height: 20,),
          Center(
            child: Text(
              "Top Loser ${widget.title}",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 10,),
          SelectableList<String>(
            items: _selectableItemList,
            initialValue: _worsePeriodSelected,
            onPress: ((value) {
              setState(() {
                _worsePeriodSelected = value;
              });
            })
          ),
          const SizedBox(height: 10,),
          _generateTopWorseList(
            reksadanaList: _worseReksadanaList,
            period: _worsePeriodSelected,
            codeColor: accentColor,
            gainColor: Colors.red,
          ),
        ],
      );
    },);
  }

  Widget _generateTopWorseList({required TopWorseCompanyListModel reksadanaList, required String period, required Color codeColor, required Color gainColor}) {
    List<CompanyInfo> info = [];
  
    // select which info we will display based on the _topPeriod
    switch(period) {
      case '1d':
        info = reksadanaList.companyList.the1D;
        break;
      case '1w':
        info = reksadanaList.companyList.the1W;
        break;
      case '1m':
        info = reksadanaList.companyList.the1M;
        break;
      case '3m':
        info = reksadanaList.companyList.the3M;
        break;
      case '6m':
        info = reksadanaList.companyList.the6M;
        break;
      case 'ytd':
        info = reksadanaList.companyList.theYTD;
        break;
      case '1y':
        info = reksadanaList.companyList.the1Y;
        break;
      case '3y':
        info = reksadanaList.companyList.the3Y;
        break;
      case '5y':
        info = reksadanaList.companyList.the5Y;
        break;
      default:
        info = reksadanaList.companyList.the1D;
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
                ScaffoldMessenger.of(context).showSnackBar(
                  createSnackBar(
                    message: 'Error when try to get the company detail from server',
                  ),
                );
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
}