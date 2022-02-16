import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_wealth/api/index_api.dart';
import 'package:my_wealth/model/index_model.dart';
import 'package:my_wealth/model/user_login.dart';
import 'package:my_wealth/provider/index_provider.dart';
import 'package:my_wealth/provider/user_provider.dart';
import 'package:my_wealth/themes/colors.dart';
import 'package:my_wealth/utils/dialog/create_snack_bar.dart';
import 'package:my_wealth/utils/loader/show_loader_dialog.dart';
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
  final IndexAPI _indexApi = IndexAPI();

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
                }),
                color: accentColor,
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
            ),
          ],
        );
      }),
    );
  }

  Future<void> _refreshIndex() async {
    await _indexApi.getIndex().then((resp) async {
      // set the shared preferences and provider for index
      await IndexSharedPreferences.setIndexList(resp);
      Provider.of<IndexProvider>(context, listen: false).setIndexList(resp);
    }).onError((error, stackTrace) {
      throw Exception(error.toString());
    });
  }
}