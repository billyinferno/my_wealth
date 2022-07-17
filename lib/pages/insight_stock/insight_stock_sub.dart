import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:my_wealth/api/insight_api.dart';
import 'package:my_wealth/model/sector_summary_model.dart';
import 'package:my_wealth/model/user_login.dart';
import 'package:my_wealth/themes/colors.dart';
import 'package:my_wealth/utils/arguments/industry_summary_args.dart';
import 'package:my_wealth/utils/arguments/insight_stock_sub_list_args.dart';
import 'package:my_wealth/utils/function/format_currency.dart';
import 'package:my_wealth/utils/function/risk_color.dart';
import 'package:my_wealth/utils/globals.dart';
import 'package:my_wealth/utils/loader/show_loader_dialog.dart';
import 'package:my_wealth/utils/prefs/shared_user.dart';

class InsightStockSubPage extends StatefulWidget {
  final Object? args;
  const InsightStockSubPage({Key? key, required this.args}) : super(key: key);

  @override
  State<InsightStockSubPage> createState() => _InsightStockSubPageState();
}

class _InsightStockSubPageState extends State<InsightStockSubPage> with SingleTickerProviderStateMixin {
  final InsightAPI _insightAPI = InsightAPI();
  final ScrollController _scrollControllerSub = ScrollController();
  final ScrollController _scrollControllerIndustry = ScrollController();

  late UserLoginInfoModel? _userInfo;
  late IndustrySummaryArgs _args;
  late TabController _tabController;

  bool _isLoading = true;
  List<SectorSummaryModel> _subSectorList = [];
  List<SectorSummaryModel> _industryList = [];
  String _currentPeriod = '1d';

  @override
  void initState() {
    _args = widget.args! as IndustrySummaryArgs;
    _isLoading = true;
    _tabController = TabController(length: 2, vsync: this);

    // get user info from shared preferences
    _userInfo = UserSharedPreferences.getUserInfo();
    
    // get the result
    Future.microtask(() async {
      await _getIndustrySummary();
    });

    super.initState();
  }

  @override
  void dispose() {
    _scrollControllerSub.dispose();
    _scrollControllerIndustry.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        color: primaryColor,
      );
    }
    else {
      return _generatePage();
    }
  }

  Widget _generatePage() {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Ionicons.arrow_back,
          ),
          onPressed: (() {
            Navigator.pop(context);
          }),
        ),
        title: Center(
          child: Text(
            Globals.sectorName[_args.sectorData.sectorName]!,
            style: const TextStyle(
              color: secondaryColor,
            ),
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          const SizedBox(height: 10,),
          SizedBox(
            width: double.infinity,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _periodButton(title: "1d", value: _args.sectorData.sectorAverage.the1D),
                _periodButton(title: "1w", value: _args.sectorData.sectorAverage.the1W),
                _periodButton(title: "1m", value: _args.sectorData.sectorAverage.the1M),
                _periodButton(title: "3m", value: _args.sectorData.sectorAverage.the3M),
                _periodButton(title: "6m", value: _args.sectorData.sectorAverage.the6M),
                _periodButton(title: "1y", value: _args.sectorData.sectorAverage.the1Y),
                _periodButton(title: "3y", value: _args.sectorData.sectorAverage.the3Y),
                _periodButton(title: "5y", value: _args.sectorData.sectorAverage.the5Y),
              ],
            ),
          ),
          const SizedBox(height: 10,),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabs: const <Widget>[
                    Tab(text: 'SUB SECTOR',),
                    Tab(text: 'INDUSTRY',),
                  ],
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 30),
                    child: TabBarView(
                      controller: _tabController,
                      children: <Widget>[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            const SizedBox(height: 10,),
                            Expanded(
                              child: GridView.count(
                                controller: _scrollControllerSub,
                                crossAxisCount: 3,
                                children: _listItems(type: "subsector", sectorList: _subSectorList),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            const SizedBox(height: 10,),
                            Expanded(
                              child: GridView.count(
                                controller: _scrollControllerIndustry,
                                crossAxisCount: 3,
                                children: _listItems(type: "industry", sectorList: _industryList),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _periodButton({required double value, required String title}) {
    Color bgColor = riskColor((1 + value), 1, _userInfo!.risk);
    Color textColor = riskColorReverse((1 + value), 1);
    Color borderColor = (value >= 0 ? const Color.fromARGB(255, 15, 88, 17) : secondaryDark);

    if (value < 0) {
      borderColor = Colors.red[900]!;
    }
    if (value > 0) {
      borderColor = Colors.green[900]!;
    }

    return GestureDetector(
      onTap: (() {
        setState(() {
          _currentPeriod = title;
        });
      }),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(5),
            height: 35,
            width: 35,
            decoration: BoxDecoration(
              border: Border.all(
                color: (_currentPeriod == title ? borderColor : primaryDark),
                style: BorderStyle.solid,
                width: 1.0
              ),
              borderRadius: BorderRadius.circular(12),
              color: (_currentPeriod == title ? bgColor : primaryLight),
            ),
            child: Center(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: (_currentPeriod == title ? textColor : primaryDark),
                ),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(5, 0, 5, 5),
            width: 35,
            height: 10,
            decoration: BoxDecoration(
              border: Border.all(
                color: borderColor,
                style: BorderStyle.solid,
                width: 1.0
              ),
              borderRadius: BorderRadius.circular(10),
              color: bgColor,
            ),
          )
        ],
      ),
    );
  }

  List<Widget> _listItems({required String type, required List<SectorSummaryModel> sectorList}) {
    return List<Widget>.generate(sectorList.length, (index) {
      double sectorAverage = 0;
      
      switch (_currentPeriod) {
        case '1d':
          sectorAverage = sectorList[index].sectorAverage.the1D;
          break;
        case '1w':
          sectorAverage = sectorList[index].sectorAverage.the1W;
          break;
        case '1m':
          sectorAverage = sectorList[index].sectorAverage.the1M;
          break;
        case '3m':
          sectorAverage = sectorList[index].sectorAverage.the3M;
          break;
        case '6m':
          sectorAverage = sectorList[index].sectorAverage.the6M;
          break;
        case '1y':
          sectorAverage = sectorList[index].sectorAverage.the1Y;
          break;
        case '3y':
          sectorAverage = sectorList[index].sectorAverage.the3Y;
          break;
        case '5y':
          sectorAverage = sectorList[index].sectorAverage.the5Y;
          break;
        default:
          sectorAverage = sectorList[index].sectorAverage.the1D;
          break;
      }

      Color bgColor = riskColor((1 + sectorAverage), 1, _userInfo!.risk);
      Color textColor = riskColorReverse((1 + sectorAverage), 1);
      Color borderColor = (sectorAverage >= 0 ? const Color.fromARGB(255, 15, 88, 17) : secondaryDark);
      IconData? icon = (type == 'subsector' ? Globals.subSectorIcon[sectorList[index].sectorName] : Globals.industryIcon[sectorList[index].sectorName]);
      icon ??= Ionicons.help;

      return InkWell(
        onTap: (() {
          InsightStockSubListArgs args = InsightStockSubListArgs(type: type, sectorName: _args.sectorData.sectorName, subName: sectorList[index].sectorName);
          Navigator.pushNamed(context, '/insight/stock/sector/sub/list', arguments: args);
        }),
        child: Container(
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                icon,
                size: 25,
                color: textColor,
              ),
              const SizedBox(height: 5,),
              Center(
                child: Text(
                  sectorList[index].sectorName,
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
    });
  }

  Future<void> _getIndustrySummary() async {
    // get the industry summary from backend
    showLoaderDialog(context);
    Future.microtask(() async {
      await _insightAPI.getSubSectorSummary(_args.sectorData.sectorName).then((resp) {
        // set the sub sector list with the response
        _subSectorList = resp;
      });

      await _insightAPI.getIndustrySummary(_args.sectorData.sectorName).then((resp) {
        // set the industry list with the response
        _industryList = resp;
      });
    }).whenComplete(() {
      // remove the loader dialog
      Navigator.pop(context);

      // set loading into false
      setState(() {
        _isLoading = false;
      });
    });
  }
}