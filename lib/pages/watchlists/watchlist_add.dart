import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
  final CompanyAPI _companyAPI = CompanyAPI();
  final WatchlistAPI _watchlistAPI = WatchlistAPI();

  late WatchlistAddArgs _args;
  late List<CompanySearchModel> _companyList;
  late List<CompanySearchModel> _companyFilterResult;
  late UserLoginInfoModel? _userInfo;
  late Future<bool> _getData;
  late bool _isAdd;

  @override
  void initState() {
    super.initState();

    // get user information
    _userInfo = UserSharedPreferences.getUserInfo();
    
    // convert the arguments being passed down to knew what we want to add
    _args = widget.watchlistArgs as WatchlistAddArgs;

    // set the search result as empty, then get the company list from API
    _companyList = [];
    _getData = _getCompanyList();

    // default _isAdd into false
    _isAdd = false;
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getData,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return CommonErrorPage(errorText: 'Unable to load company list of ${_args.type}');
        }
        else if (snapshot.hasData) {
          return _body();
        }
        else {
          return const CommonLoadingPage();
        }
      },
    );
  }

  Widget _body() {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: ((() async {
            // check if we add something before
            if (_isAdd) {
              // show loading
              LoadingScreen.instance().show(context: context);

              // now refresh the watchlist
              await _watchlistAPI.getWatchlist(type: _args.type).then((resp) async {
                // update the provider and shared preferences
                await WatchlistSharedPreferences.setWatchlist(
                  type: _args.type,
                  watchlistData: resp
                );
                
                if (!mounted) return;
                Provider.of<WatchlistProvider>(context, listen: false).setWatchlist(
                  type: _args.type,
                  watchlistData: resp
                );
                
                Log.success(message: "🔃 Refresh watchlist ${_args.type} after add");
              }).onError((error, stackTrace) {
                throw Exception("Error when refresh watchlist ${_args.type} after add");
              }).whenComplete(() {
                LoadingScreen.instance().hide();
              },);
            }

            // ensure mount so we can return back to the previous page
            if (mounted) {
              // return back to the previous page
              Navigator.pop(context);
            }
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
                onChanged: ((searchText) {
                  if(searchText.isNotEmpty && searchText.length >= 3) {
                    // perform filter on the result
                    _searchCompany(searchText);
                  }
                  else {
                    // set back to list all company
                    _setSearchResult(_companyList);
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
    return Expanded(
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: List<Widget>.generate(_companyFilterResult.length, (index) {
          return WatchlistList(
            name: _companyFilterResult[index].companyName,
            price: formatCurrency(
              _companyFilterResult[index].companyNetAssetValue!
            ),
            date: Globals.dfddMMyyyy.formatLocal(
              _companyFilterResult[index].companyLastUpdate
            ),
            riskColor: riskColor(
              value: _companyFilterResult[index].companyNetAssetValue!,
              cost: _companyFilterResult[index].companyPrevPrice!,
              riskFactor: _userInfo!.risk
            ),
            canAdd: _companyFilterResult[index].companyCanAdd,
            fca: (_companyFilterResult[index].companyFCA ?? false),
            onPress: (() async {
              await _addCompanyToWatchlist(index).then((_) async {
                Log.success(
                  message: "🏁 Add Company ${_companyFilterResult[index].companyName} to watchlist"
                );
              }).onError((error, stackTrace) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    createSnackBar(message: error.toString())
                  );
                }
              });
            })
          );
        }),
      ),
    );
  }

  void _searchCompany(String companyName) {
    List<CompanySearchModel> ret = [];

    String textSearch = companyName.toLowerCase();

    // loop thru company list and check
    for(CompanySearchModel company in _companyList) {
      if (company.companyName.toLowerCase().contains(textSearch)) {
        ret.add(company);
      }
    }

    // set the ret as search result
    _setSearchResult(ret);
  }

  void _setSearchResult(List<CompanySearchModel> result) {
    setState(() {
      _companyFilterResult.clear();
      _companyFilterResult = result.toList();
    });
  }

  Future<void> _addCompanyToWatchlist(int index) async {
    // show loading screen
    LoadingScreen.instance().show(context: context);

    // perform task
    Future.microtask(() async {
      // add the company to watchlist
      await _watchlistAPI.add(
        type: _args.type,
        companyId: _companyFilterResult[index].companyId
      ).then((resp) async {
        CompanySearchModel ret = CompanySearchModel(
          companyId: _companyFilterResult[index].companyId,
          companyName: _companyFilterResult[index].companyName,
          companyNetAssetValue: _companyFilterResult[index].companyNetAssetValue!,
          companyPrevPrice: _companyFilterResult[index].companyPrevPrice!,
          companyFCA: _companyFilterResult[index].companyFCA,
          companyWatchlistID: resp.watchlistId,
          companyLastUpdate: _companyFilterResult[index].companyLastUpdate,
          companyCanAdd: false
        );

        // refresh the cache data
        await CompanySharedPreferences.updateCompanySearch(
          type: _args.type,
          update: ret
        );

        // change the current company filter result to the one that we just add
        _companyFilterResult[index] = ret;

        // set _isAdd into true
        _isAdd = true;

        // just rebuild the widget once finished
        setState(() {
        });
      }).onError((error, stackTrace) {
        throw Exception("Error when add ${_companyList[index].companyName}");
      });
    }).whenComplete(() {
      // remove the loading screen once finisged
      LoadingScreen.instance().hide();
    });
  }

  Future<bool> _getCompanyList() async {
    Log.info(message: 'Get company list for ${_args.type}');

    await _companyAPI.getCompanyList(type: _args.type).then((resp) {
      _companyList = resp;
      _companyFilterResult = _companyList.toList();
    }).onError((error, stackTrace) {
      throw Exception("Error when get company list for ${_args.type}");
    },);

    return true;
  }
}