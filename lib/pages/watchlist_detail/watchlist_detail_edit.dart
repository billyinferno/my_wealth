import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:my_wealth/api/watchlist_api.dart';
import 'package:my_wealth/model/watchlist/watchlist_detail_list_model.dart';
import 'package:my_wealth/model/watchlist/watchlist_list_model.dart';
import 'package:my_wealth/provider/watchlist_provider.dart';
import 'package:my_wealth/themes/colors.dart';
import 'package:my_wealth/utils/arguments/watchlist_detail_edit_args.dart';
import 'package:my_wealth/utils/dialog/create_snack_bar.dart';
import 'package:my_wealth/utils/dialog/show_my_dialog.dart';
import 'package:my_wealth/utils/function/format_currency.dart';
import 'package:my_wealth/utils/loader/show_loader_dialog.dart';
import 'package:my_wealth/utils/prefs/shared_watchlist.dart';
import 'package:my_wealth/widgets/transparent_button.dart';
import 'package:my_wealth/widgets/watchlist_detail_create_calendar.dart';
import 'package:my_wealth/widgets/watchlist_detail_create_textfields.dart';
import 'package:provider/provider.dart';

class WatchlistDetailEditPage extends StatefulWidget {
  final Object? watchlistArgs;
  const WatchlistDetailEditPage({ Key? key, required this.watchlistArgs }) : super(key: key);

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
    
    _selectedDate = _watchlist.watchlistDetail[_watchlistDetailIndex].watchlistDetailDate;

    _prevDate = _watchlist.watchlistDetail[_watchlistDetailIndex].watchlistDetailDate;
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
    return WillPopScope(
      onWillPop: (() async {
        return false;
      }),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(
              Ionicons.arrow_back
            ),
            onPressed: (() async {
              await _checkForm().then((value) {
                if(value) {
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
              decimal: 6,
            ),
            WatchlistDetailCreateTextFields(
              controller: _priceController,
              title: "Price",
              decimal: 6,
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
                    showLoaderDialog(context);
                    await _updateDetail().then((resp) {
                      if(resp) {                      
                        debugPrint("💾 Update the watchlist detail ID ${_watchlist.watchlistDetail[_watchlistDetailIndex].watchlistDetailId} for ${_watchlist.watchlistId}");
                        // return back to the previous page
                        Navigator.pop(context);
                      }
                    }).onError((error, stackTrace) {
                      // remove the loader dialog
                      Navigator.pop(context);
                      // show error on snack bar
                      ScaffoldMessenger.of(context).showSnackBar(createSnackBar(message: error.toString()));
                    }).whenComplete(() {
                      // remove the loader dialog
                      Navigator.pop(context);
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
                      if(value) {
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
              );
              newWatchlist.add(updateWatchlist); 
            }
            else {
              newWatchlist.add(watch);
            }
          }

          // got the new list, not time to update the shared preferences and the provider
          await WatchlistSharedPreferences.setWatchlist(_type, newWatchlist);
          if (!mounted) return;
          Provider.of<WatchlistProvider>(context, listen: false).setWatchlist(_type, newWatchlist);
        }

        ret = resp;
      });
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