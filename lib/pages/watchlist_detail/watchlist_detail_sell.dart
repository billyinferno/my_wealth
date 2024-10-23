
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';
import 'package:my_wealth/_index.g.dart';

class WatchlistDetailSellPage extends StatefulWidget {
  final Object? watchlistArgs;
  const WatchlistDetailSellPage({super.key, required this.watchlistArgs});

  @override
  State<WatchlistDetailSellPage> createState() => _WatchlistDetailSellPageState();
}

class _WatchlistDetailSellPageState extends State<WatchlistDetailSellPage> {
  final TextEditingController _sharesController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final WatchlistAPI _watchlistAPI = WatchlistAPI();

  late WatchlistListArgs _watchlistArgs;
  late String _type;
  late WatchlistListModel _watchlist;
  late double _currentShare;
  
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _watchlistArgs = widget.watchlistArgs as WatchlistListArgs;
    _type = _watchlistArgs.type;
    _watchlist = _watchlistArgs.watchList;
    _currentShare = (_watchlistArgs.currentShare ?? 0);
    if (_currentShare > 0) {
      // check whether this is in lot or not?
      if (_watchlistArgs.isLot) {
        _currentShare = _currentShare / 100;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      body: MySafeArea(
        child: Column(
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
              title: _watchlistArgs.shareName.toCapitalized(),
              subTitle: formatDecimalWithNull(
                _currentShare,
                decimal: 5
              ),
              hintText: formatDecimalWithNull(
                _currentShare,
                decimal: 5
              ),
              defaultPrice: _currentShare,
              decimal: 6,
            ),
            WatchlistDetailCreateTextFields(
              controller: _priceController,
              title: "Price",
              hintText: formatDecimalWithNull(
                _watchlistArgs.watchList.watchlistCompanyNetAssetValue,
                decimal: 2
              ),
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
                  text: "Cancel",
                  color: secondaryDark,
                  borderColor: secondaryLight,
                  icon: Ionicons.close,
                  onTap: (() async {
                    await _checkForm().then((value) {
                      if (context.mounted) {
                        if(value) {
                          Navigator.pop(context);
                        }
                      }
                    });
                  })
                ),
                const SizedBox(width: 10,),
                TransparentButton(
                  text: "Sell",
                  color: primaryDark,
                  borderColor: primaryLight,
                  icon: Ionicons.bag_remove,
                  onTap: (() async {
                    await _addDetail().then((_) {
                      Log.success(
                        message: "💾 Sell the watchlist detail for ${_watchlist.watchlistId}"
                      );

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
              ],
            )
          ],
        ),
      ),
    );
  }

  Future<void> _addDetail() async {
    // since it sell we need to make it a negative
    double shares = (double.tryParse(_sharesController.text) ?? 0) * -1;
    // check if shares is in lot or not?
    if (_watchlistArgs.isLot) {
      shares = shares * 100;
    }
    
    double price = (double.tryParse(_priceController.text) ?? 0);
    
    // first check if the total current shares we have is at least the same or lesser
    // than the share we want to sell or not?
    if (_watchlistArgs.currentShare! >= (shares * (-1))) {
      // since sell shares should be lesser than 0, but the price should be still positive
      // as this will be used to calculate the total value we have later on on the summary
      // watchlist page.
      if(shares < 0 && price > 0) {
        // show loading screen
        LoadingScreen.instance().show(context: context);

        // send sell request to API
        await _watchlistAPI.addDetail(
          id: _watchlist.watchlistId,
          date: _selectedDate,
          shares: shares,
          price: price,
        ).then((watchlistDetail) async {
          // change the watchlist deta  il for this one
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
          if (!mounted) return;
          Provider.of<WatchlistProvider>(context, listen: false).setWatchlist(
            type: _type,
            watchlistData: newWatchList
          );
        }).whenComplete(() {
          // remove loading screen
          LoadingScreen.instance().hide();
        },);
      }
      else {
        throw Exception("Invalid share/price value");
      }
    }
    else {
      throw Exception("Max share to sell is ${_watchlistArgs.currentShare ?? 0}");
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