import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:my_wealth/_index.g.dart';

class InsightBandarIndexBeaterPage extends StatefulWidget {
  const InsightBandarIndexBeaterPage({super.key});

  @override
  State<InsightBandarIndexBeaterPage> createState() => InsightBandarIndexBeaterPageState();
}

class InsightBandarIndexBeaterPageState extends State<InsightBandarIndexBeaterPage> {
  final InsightAPI _insightAPI = InsightAPI();
  final CompanyAPI _companyAPI = CompanyAPI();

  // sort helper
  late String _filterMode;
  late String _filterSort;
  final Map<String, String> _filterList = {};

  late List<IndexBeaterModel> _indexBeaterList;
  late List<IndexBeaterModel> _sortedBeaterList;
  late Future<bool> _getData;
  
  @override
  void initState() {
    super.initState();
    _indexBeaterList = InsightSharedPreferences.getIndexBeater();

    // list all the filter that we want to put here
    _filterList["nm"] = "Name";
    _filterList["pr"] = "Price";
    _filterList["1d"] = "One Day";
    _filterList["1w"] = "One Week";
    _filterList["mt"] = "Month To Date";
    _filterList["1m"] = "One Month";
    _filterList["3m"] = "Three Month";
    _filterList["6m"] = "Six Month";
    _filterList["yt"] = "Year To Date";
    _filterList["1y"] = "One Year";

    // default filter mode to Code and ASC
    _filterMode = "nm";
    _filterSort = "ASC";

    // get the data from the API or shared storage
    _getData = _fetchData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // use future builder to get the data
    return FutureBuilder(
      future: _getData,
      builder: ((context, snapshot) {
        if (snapshot.hasError) {
          return const CommonErrorPage(errorText: 'Error when get index beater data');
        }
        else if (snapshot.hasData) {
          return _generateBody();
        }
        else {
          return const CommonLoadingPage(isNeedScaffold: false,);
        }
      })
    );
  }

  Widget _generateBody() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          GestureDetector(
            onTap: (() async {
              await ShowInfoDialog(
                title: "Index Beater",
                text: "List of stocks that beat the average daily, weekly, mtd, and ytd of Index on this lists: Sri Kehati, Bisnis 27, IDX 30, IDX Growth 30, IHSG, ISSI, JII, JII 70, and LQ45",
                okayColor: secondaryLight,
              ).show(context);
            }),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  "Index Beater",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: accentColor
                  ),
                ),
                SizedBox(width: 5,),
                Icon(
                  Ionicons.information_circle,
                  size: 15,
                  color: accentColor,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10,),
          SearchBox(
            filterMode: _filterMode,
            filterList: _filterList,
            filterSort: _filterSort,
            bgColor: Colors.transparent,
            onFilterSelect: ((value) {
              setState(() {
                _sortedIndexBeater(newFilterMode: value, newSortMode: _filterSort);
              });
            }),
            onSortSelect: ((value) {
              setState(() {
                _sortedIndexBeater(newFilterMode: _filterMode, newSortMode: value);
              });
            })
          ),
          const SizedBox(height: 10,),
          Expanded(
            child: ListView.builder(
              itemCount: _sortedBeaterList.length,
              itemBuilder: ((context, index) {
                int priceDiff = (_sortedBeaterList[index].lastPrice - _sortedBeaterList[index].prevClosingPrice!);
    
                return InkWell(
                  onTap: (() {
                    _getCompanyDetailAndGo(code: _sortedBeaterList[index].code);
                  }),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: primaryLight,
                          width: 1.0,
                          style: BorderStyle.solid,
                        )
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "(${_sortedBeaterList[index].code})",
                              style: const TextStyle(
                                color: accentColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 5,),
                            Expanded(
                              child: Text(
                                _sortedBeaterList[index].name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 10,),
                            Text(
                              formatIntWithNull(_sortedBeaterList[index].lastPrice, false, false),
                              style: const TextStyle(
                              ),
                            ),
                            const SizedBox(width: 2,),
                            Text(
                              "(${(priceDiff > 0 ? "+" : (priceDiff == 0 ? "" : "-"))}${formatIntWithNull(priceDiff, false, false)})",
                              style: TextStyle(
                                fontSize: 10,
                                color: (priceDiff < 0 ? secondaryColor : (priceDiff > 0 ? Colors.green : textPrimary)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5,),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            _columnText(header: "1 Day", value: _sortedBeaterList[index].oneDay),
                            const SizedBox(width: 10,),
                            _columnText(header: "1 Week", value: _sortedBeaterList[index].oneWeek),
                            const SizedBox(width: 10,),
                            _columnText(header: "MTD", value: _sortedBeaterList[index].mtd),
                            const SizedBox(width: 10,),
                            _columnText(header: "1 Month", value: _sortedBeaterList[index].oneMonth),
                          ],
                        ),
                        const SizedBox(height: 5,),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            _columnText(header: "3 Month", value: _sortedBeaterList[index].threeMonth),
                            const SizedBox(width: 10,),
                            _columnText(header: "6 Month", value: _sortedBeaterList[index].sixMonth),
                            const SizedBox(width: 10,),
                            _columnText(header: "YTD", value: _sortedBeaterList[index].ytd),
                            const SizedBox(width: 10,),
                            _columnText(header: "1 Year", value: _sortedBeaterList[index].oneYear),
                          ],
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
    );
  }

  Widget _columnText({required String header, required double value}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Text(
            header,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            "${formatDecimalWithNull(value, 100, 2)}%",
            style: TextStyle(
              color: (value == 0 ? Colors.white : (value > 0 ? Colors.green : secondaryColor)),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _fetchData() async {
    // check if we got data from the shared preferences or not?
    if (_indexBeaterList.isEmpty) {
      // if not then get the data from API
      await _insightAPI.getIndexBeater().then((resp) {
        _indexBeaterList = resp;

        // set the shared preferences for the index beater
        InsightSharedPreferences.setIndexBeater(indexBeaterList: resp);
      }).onError((error, stackTrace) {
        throw Exception('Error when get index beater');
      });
    }

    // return true regardless
    _sortedBeaterList = List<IndexBeaterModel>.from(_indexBeaterList);
    return true;
  }

  void _sortedIndexBeater({required String newFilterMode, required String newSortMode}) {
    // check if the new filter is same as previous or not?
    if ((newFilterMode != _filterMode)) {
      _filterMode = newFilterMode;

      // clear the current code list as we will rebuild t his
      _sortedBeaterList.clear();

      // if the filter mode is "nm" which is name, then just copy from the _filterFaveList
      if (_filterMode == "nm") {
        // check the sort methode?
        if (_filterSort == "ASC") {
          _sortedBeaterList = List<IndexBeaterModel>.from(_indexBeaterList);
        }
        else {
          _sortedBeaterList = List<IndexBeaterModel>.from(_indexBeaterList.reversed);
        }
      }
      else {
        List<IndexBeaterModel> tempFilter = List<IndexBeaterModel>.from(_indexBeaterList);
        switch(_filterMode) {
          case "pr":
            tempFilter.sort(((a, b) => (a.lastPrice).compareTo((b.lastPrice))));
            break;
          case "1d":
            tempFilter.sort(((a, b) => (a.oneDay).compareTo((b.oneDay))));
            break;
          case "1w":
            tempFilter.sort(((a, b) => (a.oneWeek).compareTo((b.oneWeek))));
            break;
          case "1m":
            tempFilter.sort(((a, b) => (a.oneMonth).compareTo((b.oneMonth))));
            break;
          case "mt":
            tempFilter.sort(((a, b) => (a.mtd).compareTo((b.mtd))));
            break;
          case "3m":
            tempFilter.sort(((a, b) => (a.threeMonth).compareTo((b.threeMonth))));
            break;
          case "6m":
            tempFilter.sort(((a, b) => (a.sixMonth).compareTo((b.sixMonth))));
            break;
          case "yt":
            tempFilter.sort(((a, b) => (a.ytd).compareTo((b.ytd))));
            break;
          case "1y":
            tempFilter.sort(((a, b) => (a.oneYear).compareTo((b.oneYear))));
            break;
          default:
            tempFilter.sort(((a, b) => (a.oneDay).compareTo((b.oneDay))));
            break;
        }

        // check the filter type
        if (_filterSort == "ASC") {
          _sortedBeaterList = List<IndexBeaterModel>.from(tempFilter);
        }
        else {
          _sortedBeaterList = List<IndexBeaterModel>.from(tempFilter.reversed);
        }
      }
    }

    // check if this is new sort mode or not?
    if ((newSortMode != _filterSort)) {
      _filterSort = newSortMode;

      // just reversed the current sorted list
      _sortedBeaterList = List<IndexBeaterModel>.from(_sortedBeaterList.reversed);
    }
  }

  Future<void> _getCompanyDetailAndGo({required String code}) async {
    // show loading screen
    LoadingScreen.instance().show(context: context);

    // get company detail and go
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
      // remove loading screen
      LoadingScreen.instance().hide();
    },);
  }
}