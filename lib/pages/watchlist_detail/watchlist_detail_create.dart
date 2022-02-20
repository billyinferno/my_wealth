import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:my_wealth/api/watchlist_api.dart';
import 'package:my_wealth/model/watchlist_list_model.dart';
import 'package:my_wealth/provider/watchlist_provider.dart';
import 'package:my_wealth/themes/colors.dart';
import 'package:my_wealth/utils/dialog/create_snack_bar.dart';
import 'package:my_wealth/utils/dialog/show_my_dialog.dart';
import 'package:my_wealth/utils/extensions/string.dart';
import 'package:my_wealth/utils/loader/show_loader_dialog.dart';
import 'package:my_wealth/utils/prefs/shared_watchlist.dart';
import 'package:my_wealth/widgets/transparent_button.dart';
import 'package:my_wealth/widgets/watchlist_detail_create_calendar.dart';
import 'package:my_wealth/widgets/watchlist_detail_create_textfields.dart';
import 'package:provider/provider.dart';

class WatchlistDetailCreatePage
 extends StatefulWidget {
  final Object? watchlist;
  const WatchlistDetailCreatePage({ Key? key, required this.watchlist }) : super(key: key);

  @override
  _WatchlistDetailCreatePageState createState() => _WatchlistDetailCreatePageState();
}

class _WatchlistDetailCreatePageState extends State<WatchlistDetailCreatePage> {
  final TextEditingController _sharesController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final WatchlistAPI _watchlistAPI = WatchlistAPI();

  late WatchlistListModel _watchlist;
  
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _watchlist = widget.watchlist as WatchlistListModel;
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
                  text: "Save",
                  icon: Ionicons.save,
                  callback: (() async {
                    showLoaderDialog(context);
                    await _addDetail().then((_) {
                      debugPrint("💾 Saved the watchlist detail for " + _watchlist.watchlistId.toString());
                      // remove the loader dialog
                      Navigator.pop(context);
                      // return back to the previous page
                      Navigator.pop(context);
                    }).onError((error, stackTrace) {
                      // remove the loader dialog
                      Navigator.pop(context);
                      // show error on snack bar
                      ScaffoldMessenger.of(context).showSnackBar(createSnackBar(message: error.toString()));
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
      ),
    );
  }

  Future<void> _addDetail() async {
    double _shares = (double.tryParse(_sharesController.text) ?? 0);
    double _price = (double.tryParse(_priceController.text) ?? 0);

    if(_shares > 0 && _price > 0) {
      await _watchlistAPI.addDetail(_watchlist.watchlistId, _selectedDate, _shares, _price).then((watchlistDetail) async {
        // change the watchlist detail for this one
        List<WatchlistListModel> _currentWatchList = WatchlistSharedPreferences.getWatchlist();
        List<WatchlistListModel> _newWatchList = [];
        for (WatchlistListModel _data in _currentWatchList) {
          // check if this watchlist is the one that we add
          if(_watchlist.watchlistId == _data.watchlistId) {
            WatchlistListModel _updateWatchList = WatchlistListModel(
              watchlistId: _watchlist.watchlistId,
              watchlistCompanyId: _watchlist.watchlistCompanyId,
              watchlistCompanyName: _watchlist.watchlistCompanyName,
              watchlistDetail: watchlistDetail,
              watchlistCompanyNetAssetValue: _watchlist.watchlistCompanyNetAssetValue,
              watchlistCompanyPrevPrice: _watchlist.watchlistCompanyPrevPrice,
              watchlistCompanyLastUpdate: _watchlist.watchlistCompanyLastUpdate,
              watchlistFavouriteId: _watchlist.watchlistFavouriteId,
            );
            _newWatchList.add(_updateWatchList);
          }
          else {
            _newWatchList.add(_data);
          }
        }

        // once got the new one then we can update the shared preferences and provider
        await WatchlistSharedPreferences.setWatchlist(_newWatchList);
        Provider.of<WatchlistProvider>(context, listen: false).setWatchlist(_newWatchList);
      });
    }
    else {
      throw Exception("Shares or Price cannot be zero");
    }
  }

  Future<bool> _checkForm() async {
    if(_sharesController.text.isNotEmpty && _priceController.text.isNotEmpty) {
      bool _ret = false;

      await ShowMyDialog(
        title: "Data Not Saved",
        text: "Do you want to back?",
      ).show(context).then((value) {
        _ret = value!;
      });

      return _ret;
    }
    else {
      return true;
    }
  }
}