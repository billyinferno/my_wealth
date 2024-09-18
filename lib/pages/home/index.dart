import 'package:flutter/material.dart';
import 'package:my_wealth/_index.g.dart';

class IndexPage extends StatefulWidget {
  const IndexPage({ super.key });

  @override
  IndexPageState createState() => IndexPageState();
}

class IndexPageState extends State<IndexPage> {
  final ScrollController _scrollController = ScrollController();
  final IndexAPI _indexApi = IndexAPI();

  late String _filterMode;
  late String _filterSort;
  final Map<String, String> _filterList = {};

  late List<IndexModel> _indexList;
  late UserLoginInfoModel _userInfo;

  @override
  void initState() {
    super.initState();
    
    _indexList = IndexSharedPreferences.getIndexList();
    _userInfo = UserSharedPreferences.getUserInfo()!;

    // list all the filter that we want to put here
    _filterList["AB"] = "Code";
    _filterList["PR"] = "Price";
    _filterList["CP"] = "Change (%)";
    _filterList["CH"] = "Change (\$)";

    // default filter mode to Code and ASC
    _filterMode = "AB";
    _filterSort = "ASC";
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        SearchBox(
          filterMode: _filterMode,
          filterList: _filterList,
          filterSort: _filterSort,
          onFilterSelect: ((value) {
            setState(() {
              _filterMode = value;
              _sortedIndexList();
            });
          }),
          onSortSelect: ((value) {
            setState(() {
              _filterSort = value;
              _sortedIndexList();
            });
          })
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: (() async {
              await _refreshIndex().then((value) {
                Log.success(message: "🔃 Refresh Index");
              }).onError((error, stackTrace) {
                Log.error(
                  message: 'Error when refresh index',
                  error: error,
                  stackTrace: stackTrace,
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(createSnackBar(message: error.toString()));
                }
              });

              // once finished just rebuild the widget
              setState(() {
                // just rebuild
              });
            }),
            color: accentColor,
            child: ListView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              children: List.generate(_indexList.length, (index) {
                String indexName = _indexList[index].indexName;
                if (Globals.indexName.containsKey(_indexList[index].indexName)) {
                  indexName = "(${_indexList[index].indexName}) ${Globals.indexName[_indexList[index].indexName]}";
                }

                return InkWell(
                  onTap: (() {
                    Navigator.pushNamed(context, '/index/detail', arguments: _indexList[index]);
                  }),
                  child: SimpleListItem(
                    name: indexName,
                    date: Globals.dfddMMyyyy.formatLocal(_indexList[index].indexLastUpdate),
                    price: _indexList[index].indexNetAssetValue,
                    percentChange: (_indexList[index].indexDailyReturn * 100),
                    priceChange: (_indexList[index].indexNetAssetValue - _indexList[index].indexPrevPrice),
                    riskFactor: _userInfo.risk,
                  ),
                );
              }),
            ),
          ),
        ),
      ],
    );
  }

  void _refreshIndexList() {
    setState(() {
      _sortedIndexList();
    });
  }

  Future<void> _refreshIndex() async {
    // show loading screen
    LoadingScreen.instance().show(context: context);

    // get the index data
    await _indexApi.getIndex().then((resp) async {
      // set the shared preferences and provider for index
      await IndexSharedPreferences.setIndexList(indexList: resp);
      _refreshIndexList();
    }).onError((error, stackTrace) {
      throw Exception(error.toString());
    }).whenComplete(() {
      // remove loading screen
      LoadingScreen.instance().hide();
    },);
  }

  void _sortedIndexList() {
    // if the filter mode is "AB" which is code, then just copy from the _companyList
    if (_filterMode == "AB") {
      // check the sort methode?
      if (_filterSort == "ASC") {
        _indexList = IndexSharedPreferences.getIndexList();
      }
      else {
        _indexList = List<IndexModel>.from(IndexSharedPreferences.getIndexList().reversed);
      }
    }
    else {
      List<IndexModel> tempFilter = List<IndexModel>.from(IndexSharedPreferences.getIndexList());
    //       _filterList["AB"] = "Code";
    // _filterList["PR"] = "Price";
    // _filterList["CP"] = "Change (%)";
    // _filterList["CH"] = "Change (\$)";
      switch(_filterMode) {
        case "PR":
          tempFilter.sort(((a, b) => (a.indexNetAssetValue).compareTo((b.indexNetAssetValue))));
          break;
        case "CP":
          tempFilter.sort(((a, b) => (a.indexDailyReturn).compareTo((b.indexDailyReturn))));
          break;
        case "CH":
          tempFilter.sort(((a, b) => (a.indexNetAssetValue - a.indexPrevPrice).compareTo((b.indexNetAssetValue - b.indexPrevPrice))));
          break;
        default:
          tempFilter.sort(((a, b) => (a.indexNetAssetValue).compareTo((b.indexNetAssetValue))));
          break;
      }

      // check the filter type
      if (_filterSort == "ASC") {
        _indexList = List<IndexModel>.from(tempFilter);
      }
      else {
        _indexList = List<IndexModel>.from(tempFilter.reversed);
      }
    }
  }
}