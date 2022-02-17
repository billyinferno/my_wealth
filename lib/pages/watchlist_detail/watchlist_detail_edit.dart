import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:my_wealth/api/watchlist_api.dart';
import 'package:my_wealth/model/watchlist_detail_list_model.dart';
import 'package:my_wealth/model/watchlist_list_model.dart';
import 'package:my_wealth/provider/watchlist_provider.dart';
import 'package:my_wealth/themes/colors.dart';
import 'package:my_wealth/utils/arguments/watchlist_detail_edit_args.dart';
import 'package:my_wealth/utils/dialog/create_snack_bar.dart';
import 'package:my_wealth/utils/dialog/show_my_dialog.dart';
import 'package:my_wealth/utils/extensions/string.dart';
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
  _WatchlistDetailEditPageState createState() => _WatchlistDetailEditPageState();
}

class _WatchlistDetailEditPageState extends State<WatchlistDetailEditPage> {
  final TextEditingController _sharesController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final WatchlistAPI _watchlistApi = WatchlistAPI();
  
  late WatchlistDetailEditArgs _watchlistArgs;
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
    _watchlist = _watchlistArgs.watchlist;
    _watchlistDetailIndex = _watchlistArgs.index;
    
    _selectedDate = _watchlist.watchlistDetail[_watchlistDetailIndex].watchlistDetailDate;

    _prevDate = _watchlist.watchlistDetail[_watchlistDetailIndex].watchlistDetailDate;
    _prevShares = _watchlist.watchlistDetail[_watchlistDetailIndex].watchlistDetailShare;
    _prevPrice = _watchlist.watchlistDetail[_watchlistDetailIndex].watchlistDetailPrice;

    _sharesController.text = formatDecimal(_prevShares);
    _priceController.text = formatDecimal(_prevPrice);
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
              if(value) {
                Navigator.pop(context);
              }
            });
          }),
        ),
        title: Center(
          child: Text(
            _watchlist.watchlistCompanyName.toTitleCase(),
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
            decimal: 6,
          ),
          const SizedBox(height: 10,),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              const SizedBox(width: 10,),
              TransparentButton(
                text: "Update",
                icon: Ionicons.save,
                callback: (() async {
                  showLoaderDialog(context);
                  await _updateDetail().then((resp) {
                    if(resp) {                      
                      debugPrint("💾 Update the watchlist detail ID " +
                        _watchlist.watchlistDetail[_watchlistDetailIndex].watchlistDetailId.toString() +
                        " for " + _watchlist.watchlistId.toString());
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
    );
  }

  Future<bool> _updateDetail() async {
    bool _ret = false;
    double _shares = (double.tryParse(_sharesController.text) ?? 0);
    double _price = (double.tryParse(_priceController.text) ?? 0);

    if(_shares > 0 && _price > 0) {
      await _watchlistApi.updateDetail(_watchlist.watchlistDetail[_watchlistDetailIndex].watchlistDetailId, _selectedDate, _shares, _price).then((resp) async {
        // check if the response is success
        if(resp) {
          // update the current detail with new one
          WatchlistDetailListModel _newWatchlistDetail = WatchlistDetailListModel(
            watchlistDetailId: _watchlist.watchlistDetail[_watchlistDetailIndex].watchlistDetailId,
            watchlistDetailShare: _shares,
            watchlistDetailPrice: _price,
            watchlistDetailDate: _selectedDate);
          
          // create the new watchlist details
          List<WatchlistDetailListModel> _newWatchlistDetailList = [];
          // loop thru the current watchlist detail list
          for (WatchlistDetailListModel _watchDetail in _watchlist.watchlistDetail) {
            if(_watchlist.watchlistDetail[_watchlistDetailIndex].watchlistDetailId == _watchDetail.watchlistDetailId) {
              // put the update wathclist detail
              _newWatchlistDetailList.add(_newWatchlistDetail);
            }
            else {
              // add the other
              _newWatchlistDetailList.add(_watchDetail);
            }
          }

          // loop thru current watchlist
          List<WatchlistListModel> _newWatchlist = [];
          List<WatchlistListModel> _currWatchlist = WatchlistSharedPreferences.getWatchlist();
          for (WatchlistListModel _watch in _currWatchlist) {
            // check if this is the same ID or not, if same then we need to recreate the new watchlist
            if(_watch.watchlistId == _watchlist.watchlistId) {
              WatchlistListModel _updateWatchlist = WatchlistListModel(
                watchlistId: _watchlist.watchlistId,
                watchlistCompanyId: _watchlist.watchlistCompanyId,
                watchlistCompanyName: _watchlist.watchlistCompanyName,
                watchlistDetail: _newWatchlistDetailList,
                watchlistCompanyNetAssetValue: _watchlist.watchlistCompanyNetAssetValue,
                watchlistCompanyPrevPrice: _watchlist.watchlistCompanyPrevPrice,
                watchlistCompanyLastUpdate: _watchlist.watchlistCompanyLastUpdate,
                watchlistFavouriteId: _watchlist.watchlistFavouriteId,
              );
              _newWatchlist.add(_updateWatchlist); 
            }
            else {
              _newWatchlist.add(_watch);
            }
          }

          // got the new list, not time to update the shared preferences and the provider
          await WatchlistSharedPreferences.setWatchlist(_newWatchlist);
          Provider.of<WatchlistProvider>(context, listen: false).setWatchlist(_newWatchlist);
        }

        _ret = resp;
      });
    }
    else {
      throw Exception("Shares or Price cannot be zero");
    }

    return _ret;
  }

  Future<bool> _checkForm() async {
    // check if the current data and previous data is the same or not?
    // if the same then just leave it be, otherwise then ask user if they really
    // want to leave the page or not?
    if(_sharesController.text.isNotEmpty && _priceController.text.isNotEmpty) {
      // check the previous and current data is the same or not
      double _shares = (double.tryParse(_sharesController.text) ?? 0);
      double _price = (double.tryParse(_priceController.text) ?? 0);

      if(_selectedDate == _prevDate && _shares == _prevShares && _price == _prevPrice) {
        return true;
      }
      else {
        bool _ret = false;

        await ShowMyDialog(
          title: "Data Not Saved",
          text: "Do you want to back?",
        ).show(context).then((value) {
          _ret = value!;
        });

        return _ret;
      }
    }
    else {
      return true;
    }
  }
}