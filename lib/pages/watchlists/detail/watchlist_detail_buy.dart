import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';
import 'package:my_wealth/_index.g.dart';

class WatchlistDetailBuyPage
 extends StatefulWidget {
  final Object? watchlistArgs;
  const WatchlistDetailBuyPage({ super.key, required this.watchlistArgs });

  @override
  WatchlistDetailBuyPageState createState() => WatchlistDetailBuyPageState();
}

class WatchlistDetailBuyPageState extends State<WatchlistDetailBuyPage> {
  final TextEditingController _sharesController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final WatchlistAPI _watchlistAPI = WatchlistAPI();
  final PriceAPI _priceApi = PriceAPI();

  late WatchlistListArgs _watchlistArgs;
  late String _type;
  late WatchlistListModel _watchlist;

  late double _hintPrice;

  late Map<DateTime, double> _priceData;
  late Future<bool> _getPriceData;
  
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _watchlistArgs = widget.watchlistArgs as WatchlistListArgs;
    _type = _watchlistArgs.type;
    _watchlist = _watchlistArgs.watchlist;
    _hintPrice = (_watchlistArgs.watchlist.watchlistCompanyNetAssetValue ?? 0);

    // initialize price data
    _priceData = {};

    // get the price data from API
    _getPriceData = _getCompanyPriceFromID();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getPriceData,
      builder: ((context, snapshot) {
        if (snapshot.hasError) {
          return const CommonErrorPage(errorText: 'Error occured on watchlist detail');
        } else if (snapshot.hasData) {
          return _generatePage();
        } else {
          return const CommonLoadingPage();
        }
      }),
    );
  }

  Widget _generatePage() {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Ionicons.arrow_back
          ),
          onPressed: (() async {
            await _checkForm().then((value) {
              if (mounted) {
                if(value) {
                  Navigator.pop(context);
                }
              }
            });
          }),
        ),
        title: Center(
          child: Text(
            _watchlist.watchlistCompanyName,
            style: const TextStyle(
              fontSize: 18,
              color: secondaryColor
            ),
          ),
        ),
      ),
      body: MySafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            WatchlistDetailCreateCalendar(
              onDateChange: ((newDate) {
                setState(() {                
                  _selectedDate = newDate;

                  // check if we have price data for this date
                  if (_priceData.containsKey(_selectedDate)) {
                    _hintPrice = _priceData[_selectedDate]!;
                  } else {
                    // if not, then use the default price
                    _hintPrice = (_watchlist.watchlistCompanyNetAssetValue ?? 0);
                  }
                });
              })
            ),
            WatchlistDetailCreateTextFields(
              controller: _sharesController,
              title: _watchlistArgs.shareName.toCapitalized(),
              decimal: 6,
            ),
            WatchlistDetailCreateTextFields(
              controller: _priceController,
              title: "Price",
              hintText: formatDecimalWithNull(
                _hintPrice,
                decimal: 2
              ),
              decimal: 6,
              defaultPrice: _hintPrice,
            ),
            const SizedBox(height: 10,),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                const SizedBox(width: 10,),
                TransparentButton(
                  text: "Cancel",
                  color: primaryDark,
                  borderColor: primaryLight,
                  icon: Ionicons.close,
                  onTap: (() async {
                    await _checkForm().then((value) {
                      if(mounted && value) {
                        Navigator.pop(context);
                      }
                    });
                  })
                ),
                const SizedBox(width: 10,),
                TransparentButton(
                  text: "Buy",
                  color: secondaryDark,
                  borderColor: secondaryLight,
                  icon: Ionicons.bag_add,
                  onTap: (() async {
                    await _addDetail().then((_) {
                      Log.success(message: "💾 Saved the watchlist detail for ${_watchlist.watchlistId}");
                      if (mounted) {
                        // return back to the previous page
                        Navigator.pop(context);
                      }
                    }).onError((error, stackTrace) {
                      if (mounted) {
                        // show error on snack bar
                        ScaffoldMessenger.of(context).showSnackBar(createSnackBar(message: error.toString()));
                      }
                    });
                  })
                ),
                const SizedBox(width: 10,),
              ],
            )
          ],
        ),
      ),
    );
  }

  Future<void> _addDetail() async {
    double shares = (double.tryParse(_sharesController.text) ?? 0);
    // check if shares is in lot or not?
    if (_watchlistArgs.isLot) {
      shares = shares * 100;
    }
    
    double price = (double.tryParse(_priceController.text) ?? 0);

    if(shares > 0 && price >= 0) {
      // show the loading screen
      LoadingScreen.instance().show(context: context);

      // call API to add watchlist detail
      await _watchlistAPI.addDetail(
        id: _watchlist.watchlistId,
        date: _selectedDate.toLocal(),
        shares: shares,
        price: price,
      ).then((watchlistDetail) async {
        // change the watchlist detail for this one
        List<WatchlistListModel> currentWatchList = WatchlistSharedPreferences.getWatchlist(type: _type);
        List<WatchlistListModel> newWatchList = [];
        for (WatchlistListModel data in currentWatchList) {
          // check if this watchlist is the one that we add
          if(_watchlist.watchlistId == data.watchlistId) {
            WatchlistListModel updateWatchList = WatchlistListModel(
              watchlistId: _watchlist.watchlistId,
              watchlistCompanyId: _watchlist.watchlistCompanyId,
              watchlistCompanyName: _watchlist.watchlistCompanyName,
              watchlistCompanySymbol: _watchlist.watchlistCompanySymbol,
              watchlistDetail: watchlistDetail,
              watchlistCompanyNetAssetValue: _watchlist.watchlistCompanyNetAssetValue,
              watchlistCompanyPrevPrice: _watchlist.watchlistCompanyPrevPrice,
              watchlistCompanyLastUpdate: _watchlist.watchlistCompanyLastUpdate,
              watchlistFavouriteId: _watchlist.watchlistFavouriteId,
              watchlistCompanyFCA: _watchlist.watchlistCompanyFCA,
            );
            newWatchList.add(updateWatchList);
          }
          else {
            newWatchList.add(data);
          }
        }

        // once got the new one then we can update the shared preferences and provider
        await WatchlistSharedPreferences.setWatchlist(
          type: _type,
          watchlistData: newWatchList
        );
        if (mounted) {
          Provider.of<WatchlistProvider>(context, listen: false).setWatchlist(
            type: _type,
            watchlistData: newWatchList
          );
        }
      }).whenComplete(() {
        // remove loading screen after finished
        LoadingScreen.instance().hide();
      },);
    }
    else {
      throw Exception("Invalid share/price value");
    }
  }

  Future<bool> _checkForm() async {
    if(_sharesController.text.isNotEmpty && _priceController.text.isNotEmpty) {
      bool ret = false;

      await ShowMyDialog(
        title: "Data Not Saved",
        text: "Do you want to back?",
      ).show(context).then((value) {
        ret = value!;
      });

      return ret;
    }
    else {
      return true;
    }
  }

  Future<bool> _getCompanyPriceFromID() async {
    await _priceApi.getCompanyPriceByID(
      id: _watchlistArgs.watchlist.watchlistCompanyId,
      type: _type,
    ).then((price) {
      // generate the price data from the resp
      for(int i=0; i < price.length; i++) {
        _priceData[price[i].priceDate.toLocal()] = price[i].priceValue;
      }
    }).onError((error, stackTrace) {
      Log.error(
        message: 'Error on getCompanyPriceFromID',
        error: error,
        stackTrace: stackTrace,
      );
    },);
    // always return true, even when API is down
    return true;
  }
}