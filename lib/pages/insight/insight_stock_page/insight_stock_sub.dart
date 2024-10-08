import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:my_wealth/_index.g.dart';

class InsightStockSubPage extends StatefulWidget {
  final Object? args;
  const InsightStockSubPage({super.key, required this.args});

  @override
  State<InsightStockSubPage> createState() => _InsightStockSubPageState();
}

class _InsightStockSubPageState extends State<InsightStockSubPage> with SingleTickerProviderStateMixin {
  final InsightAPI _insightAPI = InsightAPI();
  final CompanyAPI _companyAPI = CompanyAPI();
  final ScrollController _scrollControllerSub = ScrollController();
  final ScrollController _scrollControllerIndustry = ScrollController();
  final ScrollController _scrollControllerBody = ScrollController();

  late UserLoginInfoModel? _userInfo;
  late IndustrySummaryArgs _args;

  late Future<bool> _getData;

  late TopWorseCompanyListModel _sectorListTop;
  late TopWorseCompanyListModel _sectorListWorse;
  List<SectorSummaryModel> _subSectorList = [];
  List<SectorSummaryModel> _industryList = [];
  String _currentPeriod = '1d';
  String _currentSegment = "summary";

  @override
  void initState() {
    super.initState();

    _args = widget.args! as IndustrySummaryArgs;

    // get user info from shared preferences
    _userInfo = UserSharedPreferences.getUserInfo();
    
    // get initial data for stock sub sector
    _getData = _getIndustrySummary();
  }

  @override
  void dispose() {
    _scrollControllerSub.dispose();
    _scrollControllerIndustry.dispose();
    _scrollControllerBody.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getData,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const CommonErrorPage(
            errorText: 'Error loading Sub Sector Information',
          );
        }
        else if (snapshot.hasData) {
          return _generatePage();
        }
        else {
          return const CommonLoadingPage();
        }
      },
    );
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
          Container(
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
            width: double.infinity,
            color: primaryDark,
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
          SizedBox(
            width: double.infinity,
            child: CupertinoSegmentedControl( 
              selectedColor: secondaryColor,
              groupValue: _currentSegment,
              children: <String, Widget>{
                "summary": Container(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: const Text("Summary")
                ),
                "subsector": Container(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: const Text("Sub Sector")
                ),
                "industry": Container(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: const Text("Industry")
                ),
              },
              onValueChanged: ((String val) {
                setState(() {
                  _currentSegment = val;
                });
              })
            ),
          ),
          const SizedBox(height: 10,),
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollControllerBody,
              physics: const AlwaysScrollableScrollPhysics(),
              child: Container(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          _showBodyPage(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _showBodyPage() {
    switch(_currentSegment) {
      case "subsector":
        return SizedBox(
          width: double.infinity,
          child: GridView.count(
            shrinkWrap: true,
            controller: _scrollControllerSub,
            crossAxisCount: 3,
            children: _listItems(type: "subsector", sectorList: _subSectorList),
          ),
        );
      case "industry":
        return SizedBox(
          width: double.infinity,
          child: GridView.count(
            shrinkWrap: true,
            controller: _scrollControllerIndustry,
            crossAxisCount: 3,
            children: _listItems(type: "industry", sectorList: _industryList),
          ),
        );
      default:
        return SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              const Center(
                child: Text(
                  "Top Performer",
                  style: TextStyle(
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
              const SizedBox(height: 5,),
              _generateTopWorseList(type: 'top', codeColor: accentColor, gainColor: Colors.green),
              const SizedBox(height: 20,),
              const Center(
                child: Text(
                  "Worse Performer",
                  style: TextStyle(
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
              const SizedBox(height: 5,),
              _generateTopWorseList(type: 'worse', codeColor: accentColor, gainColor: secondaryColor),
            ],
          ),
        );
    }
  }

  Widget _periodButton({required double value, required String title}) {
    Color bgColor = riskColor(
      value: (1 + value),
      cost: 1,
      riskFactor: _userInfo!.risk
    );

    Color textColor = riskColorReverse(
      value: (1 + value),
      cost: 1
    );

    return GestureDetector(
      onTap: (() {
        setState(() {
          _currentPeriod = title;
        });
      }),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(5, 5, 5, 0),
            height: 35,
            width: 35,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(5), topRight: Radius.circular(5)),
              color: (_currentPeriod == title ? bgColor : Colors.transparent),
            ),
            child: Center(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: (_currentPeriod == title ? textColor : accentColor),
                ),
              ),
            ),
          ),
          Container(
            width: 35,
            height: 10,
            decoration: BoxDecoration(
              borderRadius: (_currentPeriod == title ? const BorderRadius.only(bottomLeft: Radius.circular(5), bottomRight: Radius.circular(5)) : BorderRadius.circular(5)),
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
              Center(
                child: Text(
                  "${formatDecimal(
                    (sectorAverage * 100),
                    decimal: 2,
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
    });
  }

  Widget _generateTopWorseList({required String type, required Color codeColor, required Color gainColor}) {
    List<CompanyInfo> info = [];
    
    if (type == 'top') {
      // select which info we will display based on the _topPeriod
      switch(_currentPeriod) {
        case '1d':
          info = _sectorListTop.companyList.the1D;
          break;
        case '1w':
          info = _sectorListTop.companyList.the1W;
          break;
        case '1m':
          info = _sectorListTop.companyList.the1M;
          break;
        case '3m':
          info = _sectorListTop.companyList.the3M;
          break;
        case '6m':
          info = _sectorListTop.companyList.the6M;
          break;
        case '1y':
          info = _sectorListTop.companyList.the1Y;
          break;
        case '3y':
          info = _sectorListTop.companyList.the3Y;
          break;
        case '5y':
          info = _sectorListTop.companyList.the5Y;
          break;
        default:
          info = _sectorListTop.companyList.the1D;
          break;
      }
    }
    else if (type == 'worse') {
      // select which info we will display based on the _topPeriod
      switch(_currentPeriod) {
        case '1d':
          info = _sectorListWorse.companyList.the1D;
          break;
        case '1w':
          info = _sectorListWorse.companyList.the1W;
          break;
        case '1m':
          info = _sectorListWorse.companyList.the1M;
          break;
        case '3m':
          info = _sectorListWorse.companyList.the3M;
          break;
        case '6m':
          info = _sectorListWorse.companyList.the6M;
          break;
        case '1y':
          info = _sectorListWorse.companyList.the1Y;
          break;
        case '3y':
          info = _sectorListWorse.companyList.the3Y;
          break;
        case '5y':
          info = _sectorListWorse.companyList.the5Y;
          break;
        default:
          info = _sectorListWorse.companyList.the1D;
          break;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: List.generate(info.length, (index) {
        return InkWell(
          onTap: () async {
            _getCompanyAndGo(code: info[index].code);
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

  Future<bool> _getIndustrySummary() async {
    await Future.wait([
      _insightAPI.getSectorSummaryList(
        sectorName: _args.sectorData.sectorName,
        sortType: 'top',
      ).then((resp) {
        // set the sub sector list with the response
        _sectorListTop = resp;
      }),

      _insightAPI.getSectorSummaryList(
        sectorName: _args.sectorData.sectorName,
        sortType: 'worse',
      ).then((resp) {
        // set the sub sector list with the response
        _sectorListWorse = resp;
      }),

      _insightAPI.getSubSectorSummary(
        sectorName: _args.sectorData.sectorName
      ).then((resp) {
        // set the sub sector list with the response
        _subSectorList = resp;
      }),

      _insightAPI.getIndustrySummary(
        sectorName: _args.sectorData.sectorName
      ).then((resp) {
        // set the industry list with the response
        _industryList = resp;
      }),
    ]).onError((error, stackTrace) {
      Log.error(
        message: 'Error getting stock PER sector information',
        error: error,
        stackTrace: stackTrace,
      );
      throw Exception('Error when get stock per sector information');
    },);

    return true;
  }

  Future<void> _getCompanyAndGo({required String code}) async {
    // show loading screen
    LoadingScreen.instance().show(context: context);

    // get company information and navigate to company page
    await _companyAPI.getCompanyByCode(
      companyCode: code,
      type: 'saham',
    ).then((resp) {
      CompanyDetailArgs args = CompanyDetailArgs(
        companyId: resp.companyId,
        companyName: resp.companyName,
        companyCode: code,
        companyFavourite: (resp.companyFavourites ?? false),
        favouritesId: (resp.companyFavouritesId ?? -1),
        type: "saham",
      );
      
      if (mounted) {
        // go to the company page
        Navigator.pushNamed(context, '/company/detail/saham', arguments: args);
      }
    }).onError((error, stackTrace) {
      if (mounted) {
        // show the error message
        ScaffoldMessenger.of(context).showSnackBar(createSnackBar(message: 'Error when try to get the company detail from server'));
      }
    }).whenComplete(() {
      // remove the loading screen once complete
      LoadingScreen.instance().hide();
    },);
  }
}