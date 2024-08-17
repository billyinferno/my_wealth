import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';
import 'package:my_wealth/_index.g.dart';

class WatchlistDetailEditPage extends StatefulWidget {
  final Object? watchlistArgs;
  const WatchlistDetailEditPage({ super.key, required this.watchlistArgs });

  @override
  WatchlistDetailEditPageState createState() => WatchlistDetailEditPageState();
}

class WatchlistDetailEditPageState extends State<WatchlistDetailEditPage> {
  final TextEditingController _sharesController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final WatchlistAPI _watchlistApi = WatchlistAPI();
  
  late WatchlistDetailEditArgs _watchlistArgs;
  late String _type;
  late String _txn;
  late WatchlistListModel _watchlist;
  late int _watchlistDetailIndex;

  DateTime _selectedDate = DateTime.now();
  DateTime _prevDate = DateTime.now();
  double _prevShares = 0;
  double _prevPrice = 0;

  @override
  void initState() {
    super.initState();

    _watchlistArgs = widget.watchlistArgs as WatchlistDetailEditArgs;
    _type = _watchlistArgs.type;
    _watchlist = _watchlistArgs.watchlist;
    _watchlistDetailIndex = _watchlistArgs.index;

    // check what is the current transaction being performed?
    // if this is a buy, then the shares should be positive, and vice versa
    if (_watchlist.watchlistDetail[_watchlistDetailIndex].watchlistDetailShare > 0) {
      _txn = "b";
    }
    else {
      _txn = "s";
    }
    
    _selectedDate = _watchlist.watchlistDetail[_watchlistDetailIndex].watchlistDetailDate.toLocal();

    _prevDate = _watchlist.watchlistDetail[_watchlistDetailIndex].watchlistDetailDate.toLocal();
    _prevShares = _watchlist.watchlistDetail[_watchlistDetailIndex].watchlistDetailShare;
    // check if previous shares is less than zero, if so then we will make it positive
    if (_prevShares < 0) {
      _prevShares *= -1;
    }
    _prevPrice = _watchlist.watchlistDetail[_watchlistDetailIndex].watchlistDetailPrice;

    _sharesController.text = formatDecimal(_prevShares);
    _priceController.text = formatDecimal(_prevPrice);
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
                if(context.mounted && value) {
                  Navigator.pop(context);
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
              initialDate: _selectedDate,
              onDateChange: ((newDate) {
                _selectedDate = newDate;
              })
            ),
            WatchlistDetailCreateTextFields(
              controller: _sharesController,
              title: "Shares",
              hintText: formatDecimalWithNull(_prevShares, 1, 2),
              decimal: 6,
            ),
            WatchlistDetailCreateTextFields(
              controller: _priceController,
              title: "Price",
              hintText: formatDecimalWithNull(_prevPrice, 1, 2),
              decimal: 6,
              defaultPrice: _prevPrice,
            ),
            const SizedBox(height: 10,),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                const SizedBox(width: 10,),
                TransparentButton(
                  text: "Update ${_txn == "b" ? "Buy" : "Sell"}",
                  bgColor: primaryDark,
                  icon: Ionicons.save,
                  callback: (() async {
                    await _updateDetail().then((resp) {
                      if(resp) {                      
                        Log.success(message: "💾 Update the watchlist detail ID ${_watchlist.watchlistDetail[_watchlistDetailIndex].watchlistDetailId} for ${_watchlist.watchlistId}");
                        if (context.mounted) {
                          // return back to the previous page
                          Navigator.pop(context);
                        }
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

  Future<bool> _updateDetail() async {
    bool ret = false;
    double shares = (double.tryParse(_sharesController.text) ?? 0);
    double price = (double.tryParse(_priceController.text) ?? 0);

    // ensure that shares should be more than 0 when update
    if(shares > 0 && price >= 0) {
      // once we reach here, we need to check whether the transaction is "b"(uy) or "s"(ell), so we can send the correct
      // share amount to the API
      if (_txn == "s") {
        // return back update of sales to minus again
        shares *= -1;
      }

      // show the loadin gscreen
      LoadingScreen.instance().show(context: context);

      // call the update detail API
      await _watchlistApi.updateDetail(_watchlist.watchlistDetail[_watchlistDetailIndex].watchlistDetailId, _selectedDate, shares, price).then((resp) async {
        // check if the response is success
        if(resp) {
          // update the current detail with new one
          WatchlistDetailListModel newWatchlistDetail = WatchlistDetailListModel(
            watchlistDetailId: _watchlist.watchlistDetail[_watchlistDetailIndex].watchlistDetailId,
            watchlistDetailShare: shares,
            watchlistDetailPrice: price,
            watchlistDetailDate: _selectedDate);
          
          // create the new watchlist details
          List<WatchlistDetailListModel> newWatchlistDetailList = [];
          // loop thru the current watchlist detail list
          for (WatchlistDetailListModel watchDetail in _watchlist.watchlistDetail) {
            if(_watchlist.watchlistDetail[_watchlistDetailIndex].watchlistDetailId == watchDetail.watchlistDetailId) {
              // put the update wathclist detail
              newWatchlistDetailList.add(newWatchlistDetail);
            }
            else {
              // add the other
              newWatchlistDetailList.add(watchDetail);
            }
          }

          // loop thru current watchlist
          List<WatchlistListModel> newWatchlist = [];
          List<WatchlistListModel> currWatchlist = WatchlistSharedPreferences.getWatchlist(_type);
          for (WatchlistListModel watch in currWatchlist) {
            // check if this is the same ID or not, if same then we need to recreate the new watchlist
            if(watch.watchlistId == _watchlist.watchlistId) {
              WatchlistListModel updateWatchlist = WatchlistListModel(
                watchlistId: _watchlist.watchlistId,
                watchlistCompanyId: _watchlist.watchlistCompanyId,
                watchlistCompanyName: _watchlist.watchlistCompanyName,
                watchlistCompanySymbol: _watchlist.watchlistCompanySymbol,
                watchlistDetail: newWatchlistDetailList,
                watchlistCompanyNetAssetValue: _watchlist.watchlistCompanyNetAssetValue,
                watchlistCompanyPrevPrice: _watchlist.watchlistCompanyPrevPrice,
                watchlistCompanyLastUpdate: _watchlist.watchlistCompanyLastUpdate,
                watchlistFavouriteId: _watchlist.watchlistFavouriteId,
                watchlistCompanyFCA: _watchlist.watchlistCompanyFCA,
              );
              newWatchlist.add(updateWatchlist); 
            }
            else {
              newWatchlist.add(watch);
            }
          }

          // got the new list, not time to update the shared preferences and the provider
          await WatchlistSharedPreferences.setWatchlist(_type, newWatchlist);
          if (mounted) {
            Provider.of<WatchlistProvider>(context, listen: false).setWatchlist(_type, newWatchlist);
          }
        }

        ret = resp;
      }).whenComplete(() {
        // remove loading screen
        LoadingScreen.instance().hide();
      },);
    }
    else {
      throw Exception("Shares cannot be zero, and price minimum is zero");
    }

    return ret;
  }

  Future<bool> _checkForm() async {
    // check if the current data and previous data is the same or not?
    // if the same then just leave it be, otherwise then ask user if they really
    // want to leave the page or not?
    if(_sharesController.text.isNotEmpty && _priceController.text.isNotEmpty) {
      // check the previous and current data is the same or not
      double shares = (double.tryParse(_sharesController.text) ?? 0);
      double price = (double.tryParse(_priceController.text) ?? 0);

      if(_selectedDate == _prevDate && shares == _prevShares && price == _prevPrice) {
        return true;
      }
      else {
        bool ret = false;

        await ShowMyDialog(
          title: "Data Not Saved",
          text: "Do you want to back?",
        ).show(context).then((value) {
          ret = value!;
        });

        return ret;
      }
    }
    else {
      return true;
    }
  }
}