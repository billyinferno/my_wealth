import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ionicons/ionicons.dart';
import 'package:my_wealth/api/company_api.dart';
import 'package:my_wealth/api/watchlist_api.dart';
import 'package:my_wealth/model/company_search_model.dart';
import 'package:my_wealth/model/user_login.dart';
import 'package:my_wealth/model/watchlist_list_model.dart';
import 'package:my_wealth/provider/watchlist_provider.dart';
import 'package:my_wealth/themes/colors.dart';
import 'package:my_wealth/utils/dialog/create_snack_bar.dart';
import 'package:my_wealth/utils/function/format_currency.dart';
import 'package:my_wealth/utils/function/risk_color.dart';
import 'package:my_wealth/utils/loader/show_loader_dialog.dart';
import 'package:my_wealth/utils/prefs/shared_user.dart';
import 'package:my_wealth/utils/prefs/shared_watchlist.dart';
import 'package:my_wealth/widgets/watchlist_list.dart';
import 'package:provider/provider.dart';

class WatchlistAddPage extends StatefulWidget {
  const WatchlistAddPage({ Key? key }) : super(key: key);

  @override
  _WatchlistAddPageState createState() => _WatchlistAddPageState();
}

class _WatchlistAddPageState extends State<WatchlistAddPage> {
  final TextEditingController _textController = TextEditingController();
  final DateFormat _df = DateFormat("dd/MM/yyyy");
  final CompanyAPI _companyAPI = CompanyAPI();
  final WatchlistAPI _watchlistAPI = WatchlistAPI();

  late List<CompanySearchModel>? _companySearchResult;
  late List<WatchlistListModel>? _watchlists;
  late UserLoginInfoModel? _userInfo;

  @override
  void initState() {
    super.initState();

    // set the search result as empty
    _companySearchResult = [];
    _userInfo = UserSharedPreferences.getUserInfo();
    _watchlists = WatchlistSharedPreferences.getWatchlist();
  }

  @override
  void dispose() {
    super.dispose();
    _textController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: ((() {
            // return back to the previous page
            Navigator.pop(context);
          })),
          icon: const Icon(
            Ionicons.arrow_back,
          )
        ),
        title: const Center(
          child: Text(
            "Add Watchlist",
            style: TextStyle(
              color: secondaryColor,
            ),
          )
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(10),
            child: CupertinoSearchTextField(
              controller: _textController,
              backgroundColor: primaryDark,
              style: const TextStyle(
                color: textPrimary,
                fontFamily: '--apple-system',
              ),
              onSubmitted: ((searchText) async {
                if(searchText.isNotEmpty) {
                  debugPrint("🔎 Searching for " + searchText);

                  // show loader dialog
                  showLoaderDialog(context);
                  await _searchCompany(searchText).then((resp) {
                    _setSearchResult(resp);
                  }).onError((error, stackTrace) {
                    ScaffoldMessenger.of(context).showSnackBar(createSnackBar(message: error.toString()));
                  }).whenComplete(() {
                    // remove the loader dialog
                    Navigator.pop(context);
                  });
                }
              }),
            ),
          ),
          const SizedBox(height: 10,),
          _generateResult(),
        ],
      ),
    );
  }

  Widget _generateResult() {
    if(_companySearchResult!.isEmpty) {
      return const Expanded(
        child: Center(
          child: Text(
            "No Results",
            style: TextStyle(
              color: primaryLight,
            ),
          ),
        ),
      );
    }
    else {
      return Expanded(
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: List<Widget>.generate(_companySearchResult!.length, (index) {
            return Container(
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: primaryLight,
                    width: 1.0,
                    style: BorderStyle.solid,
                  ),
                )
              ),
              child: WatchlistList(
                name: _companySearchResult![index].companyName,
                price: formatCurrency(_companySearchResult![index].companyNetAssetValue!),
                date: _df.format(_companySearchResult![index].companyLastUpdate.toLocal()),
                riskColor: riskColor(_companySearchResult![index].companyNetAssetValue!, _companySearchResult![index].companyPrevPrice!, _userInfo!.risk),
                canAdd: _companySearchResult![index].companyCanAdd,
                onPress: (() async {
                  await _addCompanyToWatchlist(index).then((resp) async {
                    debugPrint("🏁 Add Company " + _companySearchResult![index].companyName + " to watchlist");

                    // add the response to watchlist
                    _watchlists!.add(resp!);

                    // update the shared preferences
                    await WatchlistSharedPreferences.setWatchlist(_watchlists!);

                    // notify the listener for the watchlist
                    Provider.of<WatchlistProvider>(context, listen: false).setWatchlist(_watchlists!);
                  }).onError((error, stackTrace) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      createSnackBar(message: error.toString())
                    );
                  });
                })
              ),
            );
          }),
        ),
      );
    }
  }

  Future<List<CompanySearchModel>> _searchCompany(String companyName) async {
    List<CompanySearchModel> _ret = [];
    await _companyAPI.getCompanyByName(companyName).then((resp) {
      _ret = resp;
    }).onError((error, stackTrace) {
      throw Exception("Error when search company");
    });

    return _ret;
  }

  void _setSearchResult(List<CompanySearchModel> result) {
    setState(() {
      _companySearchResult = result;
    });
  }

  Future<WatchlistListModel?> _addCompanyToWatchlist(int index) async {
    WatchlistListModel? _watchlist;

    await _watchlistAPI.add(_companySearchResult![index].companyId).then((resp) async {
      _watchlist = resp;

      CompanySearchModel _ret = CompanySearchModel(
        companyId: _companySearchResult![index].companyId,
        companyName: _companySearchResult![index].companyName,
        companyNetAssetValue: _companySearchResult![index].companyNetAssetValue!,
        companyPrevPrice: _companySearchResult![index].companyPrevPrice!,
        companyLastUpdate: _companySearchResult![index].companyLastUpdate,
        companyCanAdd: false
      );

      List<CompanySearchModel> _resp = [];
      for (CompanySearchModel? _company in _companySearchResult!) {
        if(_company!.companyId == _ret.companyId) {
          _resp.add(_ret);
        }
        else {
          _resp.add(_company);
        }
      }

      _setSearchResult(_resp);
    }).onError((error, stackTrace) {
      throw Exception("Error when add to watchlist");
    });

    return _watchlist!;
  }
}