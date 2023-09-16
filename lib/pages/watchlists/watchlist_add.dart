import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ionicons/ionicons.dart';
import 'package:my_wealth/api/company_api.dart';
import 'package:my_wealth/api/watchlist_api.dart';
import 'package:my_wealth/model/company/company_search_model.dart';
import 'package:my_wealth/model/user/user_login.dart';
import 'package:my_wealth/provider/watchlist_provider.dart';
import 'package:my_wealth/themes/colors.dart';
import 'package:my_wealth/utils/arguments/watchlist_add_args.dart';
import 'package:my_wealth/utils/dialog/create_snack_bar.dart';
import 'package:my_wealth/utils/function/format_currency.dart';
import 'package:my_wealth/utils/function/risk_color.dart';
import 'package:my_wealth/utils/loader/show_loader_dialog.dart';
import 'package:my_wealth/storage/prefs/shared_user.dart';
import 'package:my_wealth/storage/prefs/shared_watchlist.dart';
import 'package:my_wealth/widgets/list/watchlist_list.dart';
import 'package:provider/provider.dart';

class WatchlistAddPage extends StatefulWidget {
  final Object? watchlistArgs;
  const WatchlistAddPage({ Key? key, required this.watchlistArgs }) : super(key: key);

  @override
  WatchlistAddPageState createState() => WatchlistAddPageState();
}

class WatchlistAddPageState extends State<WatchlistAddPage> {
  final TextEditingController _textController = TextEditingController();
  final DateFormat _df = DateFormat("dd/MM/yyyy");
  final CompanyAPI _companyAPI = CompanyAPI();
  final WatchlistAPI _watchlistAPI = WatchlistAPI();

  late WatchlistAddArgs _args;
  late List<CompanySearchModel>? _companySearchResult;
  late UserLoginInfoModel? _userInfo;

  @override
  void initState() {
    super.initState();

    // convert the arguments being passed down to knew what we want to add
    _args = widget.watchlistArgs as WatchlistAddArgs;

    // set the search result as empty
    _companySearchResult = [];
    _userInfo = UserSharedPreferences.getUserInfo();
  }

  @override
  void dispose() {
    super.dispose();
    _textController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
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
          title: Center(
            child: Text(
              _getTitle(),
              style: const TextStyle(
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
                    debugPrint("🔎 Searching for $searchText");
    
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
      ),
    );
  }

  String _getTitle() {
    if (_args.type == "reksadana") {
      return "Add Mutual Fund Watchlist";
    }
    else if (_args.type == "saham") {
      return "Add Stock Watchlist";
    }
    else if (_args.type == "crypto") {
      return "Add Crypto Watchlist";
    }
    return "";
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
                  await _addCompanyToWatchlist(index).then((_) async {
                    debugPrint("🏁 Add Company ${_companySearchResult![index].companyName} to watchlist");
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
    List<CompanySearchModel> ret = [];
    await _companyAPI.getCompanyByName(companyName, _args.type).then((resp) {
      ret = resp;
    }).onError((error, stackTrace) {
      throw Exception("Error when search company");
    });

    return ret;
  }

  void _setSearchResult(List<CompanySearchModel> result) {
    setState(() {
      _companySearchResult = result;
    });
  }

  Future<void> _addCompanyToWatchlist(int index) async {
    showLoaderDialog(context);
    Future.microtask(() async {
      // add the company to watchlist
      await _watchlistAPI.add(_args.type, _companySearchResult![index].companyId).then((_) async {
        CompanySearchModel ret = CompanySearchModel(
          companyId: _companySearchResult![index].companyId,
          companyName: _companySearchResult![index].companyName,
          companyNetAssetValue: _companySearchResult![index].companyNetAssetValue!,
          companyPrevPrice: _companySearchResult![index].companyPrevPrice!,
          companyLastUpdate: _companySearchResult![index].companyLastUpdate,
          companyCanAdd: false
        );

        List<CompanySearchModel> response = [];
        for (CompanySearchModel? company in _companySearchResult!) {
          if(company!.companyId == ret.companyId) {
            response.add(ret);
          }
          else {
            response.add(company);
          }
        }

        _setSearchResult(response);
      }).onError((error, stackTrace) {
        throw Exception("Error when add ${_companySearchResult![index].companyName}");
      });

      // now refresh the watchlist
      await _watchlistAPI.getWatchlist(_args.type).then((resp) async {
        // update the provider and shared preferences
        await WatchlistSharedPreferences.setWatchlist(_args.type, resp);
        if (!mounted) return;
        Provider.of<WatchlistProvider>(context, listen: false).setWatchlist(_args.type, resp);
        debugPrint("🔃 Refresh watchlist ${_args.type} after add");
      }).onError((error, stackTrace) {
        throw Exception("Error when refresh watchlist ${_args.type} after add");
      });
    }).whenComplete(() {
      // once finished then remove the loader dialog
      Navigator.pop(context);
    });
  }
}