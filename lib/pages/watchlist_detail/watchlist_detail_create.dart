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

  late WatchlistListArgs _watchlistArgs;
  late String _type;
  late WatchlistListModel _watchlist;
  
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _watchlistArgs = widget.watchlistArgs as WatchlistListArgs;
    _type = _watchlistArgs.type;
    _watchlist = _watchlistArgs.watchList;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(
              Ionicons.arrow_back
            ),
            onPressed: (() async {
              await _checkForm().then((value) {
                if (context.mounted) {
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
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            WatchlistDetailCreateCalendar(
              onDateChange: ((newDate) {
                _selectedDate = newDate;
              })
            ),
            WatchlistDetailCreateTextFields(
              controller: _sharesController,
              title: "Shares",
              decimal: 6,
            ),
            WatchlistDetailCreateTextFields(
              controller: _priceController,
              title: "Price",
              hintText: formatDecimalWithNull(_watchlistArgs.watchList.watchlistCompanyNetAssetValue, 1, 2),
              decimal: 6,
              defaultPrice: _watchlistArgs.watchList.watchlistCompanyNetAssetValue,
            ),
            const SizedBox(height: 10,),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                const SizedBox(width: 10,),
                TransparentButton(
                  text: "Buy",
                  bgColor: primaryDark,
                  icon: Ionicons.bag_add,
                  callback: (() async {
                    await _addDetail().then((_) {
                      Log.success(message: "💾 Saved the watchlist detail for ${_watchlist.watchlistId}");
                      if (context.mounted) {
                        // return back to the previous page
                        Navigator.pop(context);
                      }
                    }).onError((error, stackTrace) {
                      if (context.mounted) {
                        // show error on snack bar
                        ScaffoldMessenger.of(context).showSnackBar(createSnackBar(message: error.toString()));
                      }
                    });
                  })
                ),
                const SizedBox(width: 10,),
                TransparentButton(
                  text: "Cancel",
                  bgColor: secondaryDark,
                  icon: Ionicons.close,
                  callback: (() async {
                    await _checkForm().then((value) {
                      if(context.mounted && value) {
                        Navigator.pop(context);
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
    double price = (double.tryParse(_priceController.text) ?? 0);

    if(shares > 0 && price >= 0) {
      // show the loading screen
      LoadingScreen.instance().show(context: context);

      // call API to add watchlist detail
      await _watchlistAPI.addDetail(_watchlist.watchlistId, _selectedDate, shares, price).then((watchlistDetail) async {
        // change the watchlist detail for this one
        List<WatchlistListModel> currentWatchList = WatchlistSharedPreferences.getWatchlist(_type);
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
        await WatchlistSharedPreferences.setWatchlist(_type, newWatchList);
        if (mounted) {
          Provider.of<WatchlistProvider>(context, listen: false).setWatchlist(_type, newWatchList);
        }
      }).whenComplete(() {
        // remove loading screen after finished
        LoadingScreen.instance().hide();
      },);
    }
    else {
      throw Exception("Share and Price are zero");
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
}