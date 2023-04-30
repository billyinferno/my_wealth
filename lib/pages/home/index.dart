import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ionicons/ionicons.dart';
import 'package:my_wealth/api/index_api.dart';
import 'package:my_wealth/model/index/index_model.dart';
import 'package:my_wealth/model/user/user_login.dart';
import 'package:my_wealth/provider/user_provider.dart';
import 'package:my_wealth/themes/colors.dart';
import 'package:my_wealth/utils/dialog/create_snack_bar.dart';
import 'package:my_wealth/utils/globals.dart';
import 'package:my_wealth/utils/loader/show_loader_dialog.dart';
import 'package:my_wealth/storage/prefs/shared_index.dart';
import 'package:my_wealth/storage/prefs/shared_user.dart';
import 'package:my_wealth/widgets/list/favourite_list.dart';
import 'package:provider/provider.dart';

class IndexPage extends StatefulWidget {
  const IndexPage({ Key? key }) : super(key: key);

  @override
  IndexPageState createState() => IndexPageState();
}

class IndexPageState extends State<IndexPage> {
  final DateFormat _df = DateFormat('dd/MM/yyyy');
  final ScrollController _scrollController = ScrollController();
  final IndexAPI _indexApi = IndexAPI();

  late String _filterMode;
  late String _filterSort;
  final Map<String, String> _filterList = {};
  final TextStyle _filterTypeSelected = const TextStyle(fontSize: 10, color: accentColor, fontWeight: FontWeight.bold);
  final TextStyle _filterTypeUnselected = const TextStyle(fontSize: 10, color: primaryLight, fontWeight: FontWeight.normal);

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
    return Consumer<UserProvider>(
      builder: ((context, userProvider, child) {
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(5),
              color: primaryDark,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    "SORT",
                    style: TextStyle(
                      color: primaryLight,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(width: 5,),
                  Expanded(
                    child: GestureDetector(
                      onTap: (() {
                        showModalBottomSheet<void>(
                          context: context,
                          backgroundColor: Colors.transparent,
                          isDismissible: true,
                          builder:(context) {
                            return Container(
                              height: 210,
                              margin: const EdgeInsets.fromLTRB(10, 10, 10, 25),
                              padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  const Center(
                                    child: Text("Select Filter"),
                                  ),
                                  ..._filterList.entries.map((e) => GestureDetector(
                                    onTap: (() {
                                      setState(() {
                                        _filterMode = e.key;
                                        _sortedIndexList();
                                      });
                                      // remove the modal sheet
                                      Navigator.pop(context);
                                    }),
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(10),
                                      decoration: const BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                            color: primaryLight,
                                            width: 1.0,
                                            style: BorderStyle.solid,
                                          )
                                        )
                                      ),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: 20,
                                            height: 20,
                                            decoration: BoxDecoration(
                                              color: (_filterMode == e.key ? accentDark : Colors.transparent),
                                              borderRadius: BorderRadius.circular(2),
                                              border: Border.all(
                                                color: accentDark,
                                                width: 1.0,
                                                style: BorderStyle.solid,
                                              )
                                            ),
                                            child: Center(
                                              child: Text(
                                                e.key,
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: (_filterMode == e.key ? textPrimary : accentColor),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10,),
                                          Text(
                                            e.value,
                                            style: TextStyle(
                                              color: (_filterMode == e.key ? accentColor : textPrimary),
                                              fontWeight: (_filterMode == e.key ? FontWeight.bold : FontWeight.normal),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )).toList(),
                                ],
                              )
                            );
                          },
                        );
                      }),
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: primaryLight,
                            width: 1.0,
                            style: BorderStyle.solid,
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                              child: Text(_filterList[_filterMode] ?? 'Code'),
                            ),
                            const SizedBox(width: 5,),
                            const Icon(
                              Ionicons.caret_down,
                              color: accentColor,
                              size: 15,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 5,),
                  GestureDetector(
                    onTap: (() {
                      if (_filterSort != "ASC") {
                        // set state
                        setState(() {
                          _filterSort = "ASC";
                          _sortedIndexList();
                        });
                      }
                    }),
                    child: SizedBox(
                      width: 35,
                      child: Center(
                        child: Text(
                          "ASC",
                          style: (_filterSort == "ASC" ? _filterTypeSelected : _filterTypeUnselected),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 2,),
                  GestureDetector(
                    onTap: (() {
                      if (_filterSort != "DESC") {
                        // set state
                        setState(() {
                          _filterSort = "DESC";
                          _sortedIndexList();
                        });
                      }
                    }),
                    child: SizedBox(
                      width: 35,
                      child: Center(
                        child: Text(
                          "DESC",
                          style: (_filterSort == "DESC" ? _filterTypeSelected : _filterTypeUnselected),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: (() async {
                  showLoaderDialog(context);
                  await _refreshIndex().then((value) {
                    debugPrint("🔃 Refresh Index");
                  }).onError((error, stackTrace) {
                    ScaffoldMessenger.of(context).showSnackBar(createSnackBar(message: error.toString()));
                  }).whenComplete(() {
                    // remove the loader
                    Navigator.pop(context);
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
                      child: FavouriteList(
                        name: indexName,
                        date: _df.format(_indexList[index].indexLastUpdate.toLocal()),
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
      }),
    );
  }

  void _refreshIndexList() {
    setState(() {
      _sortedIndexList();
    });
  }

  Future<void> _refreshIndex() async {
    await _indexApi.getIndex().then((resp) async {
      // set the shared preferences and provider for index
      await IndexSharedPreferences.setIndexList(resp);
      _refreshIndexList();
    }).onError((error, stackTrace) {
      throw Exception(error.toString());
    });
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