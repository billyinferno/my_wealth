import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';
import 'package:my_wealth/_index.g.dart';

class WatchlistAddPage extends StatefulWidget {
  final Object? watchlistArgs;
  const WatchlistAddPage({ super.key, required this.watchlistArgs });

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
        title: Center(
          child: Text(
            _getTitle(),
            style: const TextStyle(
              color: secondaryColor,
            ),
          )
        ),
      ),
      body: MySafeArea(
        child: Column(
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
                    Log.info(message: "🔎 Searching for $searchText");
          
                    await _searchCompany(searchText).then((resp) {
                      _setSearchResult(resp);
                    }).onError((error, stackTrace) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(createSnackBar(message: error.toString()));
                      }
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
                fca: (_companySearchResult![index].companyFCA ?? false),
                onPress: (() async {
                  await _addCompanyToWatchlist(index).then((_) async {
                    Log.success(message: "🏁 Add Company ${_companySearchResult![index].companyName} to watchlist");
                  }).onError((error, stackTrace) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        createSnackBar(message: error.toString())
                      );
                    }
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

    // show loading screen
    LoadingScreen.instance().show(context: context);

    // find the company by name
    await _companyAPI.getCompanyByName(companyName, _args.type).then((resp) {
      ret = resp;
    }).onError((error, stackTrace) {
      throw Exception("Error when search company");
    }).whenComplete(() {
      // remove loading screen once finished
      LoadingScreen.instance().hide();
    },);

    return ret;
  }

  void _setSearchResult(List<CompanySearchModel> result) {
    setState(() {
      _companySearchResult = result;
    });
  }

  Future<void> _addCompanyToWatchlist(int index) async {
    // show loading screen
    LoadingScreen.instance().show(context: context);

    // perform task
    Future.microtask(() async {
      // add the company to watchlist
      await _watchlistAPI.add(_args.type, _companySearchResult![index].companyId).then((_) async {
        CompanySearchModel ret = CompanySearchModel(
          companyId: _companySearchResult![index].companyId,
          companyName: _companySearchResult![index].companyName,
          companyNetAssetValue: _companySearchResult![index].companyNetAssetValue!,
          companyPrevPrice: _companySearchResult![index].companyPrevPrice!,
          companyFCA: _companySearchResult![index].companyFCA,
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
        Log.success(message: "🔃 Refresh watchlist ${_args.type} after add");
      }).onError((error, stackTrace) {
        throw Exception("Error when refresh watchlist ${_args.type} after add");
      });
    }).whenComplete(() {
      // remove the loading screen once finisged
      LoadingScreen.instance().hide();
    });
  }
}