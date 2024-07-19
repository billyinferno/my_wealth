import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_wealth/model/index/index_model.dart';
import 'package:my_wealth/model/user/user_login.dart';
import 'package:my_wealth/storage/prefs/shared_index.dart';
import 'package:my_wealth/storage/prefs/shared_user.dart';
import 'package:my_wealth/themes/colors.dart';
import 'package:my_wealth/utils/globals.dart';
import 'package:my_wealth/widgets/list/favourite_list.dart';

class IndexFindOtherPage extends StatefulWidget {
  const IndexFindOtherPage({super.key});

  @override
  State<IndexFindOtherPage> createState() => _IndexFindOtherPageState();
}

class _IndexFindOtherPageState extends State<IndexFindOtherPage> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _indexListScrollController = ScrollController();
  late List<IndexModel> _indexList;
  late List<IndexModel> _filterList;
  late UserLoginInfoModel _userInfo;

  @override
  void initState() {
    super.initState();

    // get the index list from shared preferences
    _indexList = IndexSharedPreferences.getIndexList();
    _filterList = _indexList.toList();

    // get the user info risk
    _userInfo = UserSharedPreferences.getUserInfo()!;
  }

  @override
  void dispose() {
    _textController.dispose();
    _indexListScrollController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: const Center(
            child: Text(
              "Find Index",
              style: TextStyle(
                color: secondaryColor,
              ),
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: (() async {
              // back icon press means that no code being selected
              Navigator.pop(context, null);
            }),
          ),
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                child: CupertinoSearchTextField(
                  controller: _textController,
                  onChanged: ((value) {
                    if (value.length >= 2) {
                      _searchList(value);
                    }
                    else {
                      setState(() {
                        _filterList = _indexList.toList();
                      });
                    }
                  }),
                  suffixMode: OverlayVisibilityMode.editing,
                  style: const TextStyle(
                    color: textPrimary,
                    fontFamily: '--apple-system'
                  ),
                  decoration: BoxDecoration(
                    color: primaryLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 10,),
              Expanded(
                child: ListView.builder(
                  controller: _indexListScrollController,
                  itemCount: _filterList.length,
                  itemBuilder: ((context, index) {
                    String indexName = _filterList[index].indexName;
                    if (Globals.indexName.containsKey(_filterList[index].indexName)) {
                      indexName = "(${_filterList[index].indexName}) ${Globals.indexName[_filterList[index].indexName]}";
                    }
          
                    return InkWell(
                      onTap: (() {
                        Navigator.pop(context, _filterList[index]);
                      }),
                      child: SimpleListItem(
                        name: indexName,
                        date: Globals.dfddMMyyyy.format(_filterList[index].indexLastUpdate.toLocal()),
                        price: _filterList[index].indexNetAssetValue,
                        percentChange: (_filterList[index].indexDailyReturn * 100),
                        priceChange: (_filterList[index].indexNetAssetValue - _filterList[index].indexPrevPrice),
                        riskFactor: _userInfo.risk,
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 20,),
            ],
          ),
        ),
      ),
    );
  }

  void _searchList(String find) {
    String indexName;
    
    setState(() {
      // clear the filter list first
      _filterList.clear();
      // then loop thru _faveList and check if the company name or code contain the text we want to find
      for (var i = 0; i < _indexList.length; i++) {
        if (find.length == 2) {
          if (_indexList[i].indexName.toLowerCase().contains(find.toLowerCase())) {
            // add this filter list
            _filterList.add(_indexList[i]);
          }
        }
        else {
          indexName = (Globals.indexName[_indexList[i].indexName] ?? '');
          if (_indexList[i].indexName.toLowerCase().contains(find.toLowerCase()) || indexName.toLowerCase().contains(find.toLowerCase())) {
            // add this filter list
            _filterList.add(_indexList[i]);
          }
        }
      }
    });
  }
}