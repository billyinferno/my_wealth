import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_wealth/model/index_model.dart';
import 'package:my_wealth/model/user_login.dart';
import 'package:my_wealth/provider/index_provider.dart';
import 'package:my_wealth/provider/user_provider.dart';
import 'package:my_wealth/utils/prefs/shared_index.dart';
import 'package:my_wealth/utils/prefs/shared_user.dart';
import 'package:my_wealth/widgets/favourite_list.dart';
import 'package:provider/provider.dart';

class IndexPage extends StatefulWidget {
  const IndexPage({ Key? key }) : super(key: key);

  @override
  _IndexPageState createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  final DateFormat _df = DateFormat('dd/MM/yyyy');
  final ScrollController _scrollController = ScrollController();

  late List<IndexModel> _indexList;
  late UserLoginInfoModel _userInfo;

  @override
  void initState() {
    super.initState();
    _indexList = IndexSharedPreferences.getIndexList();
    _userInfo = UserSharedPreferences.getUserInfo()!;
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<IndexProvider, UserProvider>(
      builder: ((context, indexProvider, userProvider, child) {
        _indexList = indexProvider.indexList!;
        _userInfo = userProvider.userInfo!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: ListView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                children: List.generate(_indexList.length, (index) {
                  return InkWell(
                    onTap: (() {
                      Navigator.pushNamed(context, '/index/detail', arguments: _indexList[index]);
                    }),
                    child: FavouriteList(
                      name: _indexList[index].indexName,
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
          ],
        );
      }),
    );
  }
}