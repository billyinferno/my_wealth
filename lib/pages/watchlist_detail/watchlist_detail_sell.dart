
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:my_wealth/api/watchlist_api.dart';
import 'package:my_wealth/model/watchlist/watchlist_list_model.dart';
import 'package:my_wealth/provider/watchlist_provider.dart';
import 'package:my_wealth/themes/colors.dart';
import 'package:my_wealth/utils/arguments/watchlist_list_args.dart';
import 'package:my_wealth/utils/dialog/create_snack_bar.dart';
import 'package:my_wealth/utils/dialog/show_my_dialog.dart';
import 'package:my_wealth/utils/loader/show_loader_dialog.dart';
import 'package:my_wealth/utils/prefs/shared_watchlist.dart';
import 'package:my_wealth/widgets/components/transparent_button.dart';
import 'package:my_wealth/widgets/components/watchlist_detail_create_calendar.dart';
import 'package:my_wealth/widgets/components/watchlist_detail_create_textfields.dart';
import 'package:provider/provider.dart';

class WatchlistDetailSellPage extends StatefulWidget {
  final Object? watchlistArgs;
  const WatchlistDetailSellPage({Key? key, required this.watchlistArgs}) : super(key: key);

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
                  text: "Sell",
                  bgColor: primaryDark,
                  icon: Ionicons.bag_remove,
                  callback: (() async {
                    showLoaderDialog(context);
                    await _addDetail().then((_) {
                      // ignore: prefer_interpolation_to_compose_strings
                      debugPrint("💾 Sell the watchlist detail for " + _watchlist.watchlistId.toString());
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

  Future<void> _addDetail() async {
    // since it sell we need to make it a negative
    double shares = (double.tryParse(_sharesController.text) ?? 0) * -1;
    double price = (double.tryParse(_priceController.text) ?? 0);
    
    // first check if the total current shares we have is at least the same or lesser
    // than the share we want to sell or not?
    if (_watchlistArgs.currentShare! >= (shares * (-1))) {
      // since sell shares should be lesser than 0, but the price should be still positive
      // as this will be used to calculate the total value we have later on on the summary
      // watchlist page.
      if(shares < 0 && price > 0) {
        await _watchlistAPI.addDetail(_watchlist.watchlistId, _selectedDate, shares, price).then((watchlistDetail) async {
          // change the watchlist deta  il for this one
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
              );
              newWatchList.add(updateWatchList);
            }
            else {
              newWatchList.add(data);
            }
          }

          // once got the new one then we can update the shared preferences and provider
          await WatchlistSharedPreferences.setWatchlist(_type, newWatchList);
          if (!mounted) return;
          Provider.of<WatchlistProvider>(context, listen: false).setWatchlist(_type, newWatchList);
        });
      }
      else {
        throw Exception("Invalid quantity or amount for share or price");
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