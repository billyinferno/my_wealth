import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:ionicons/ionicons.dart';
import 'package:my_wealth/api/favourites_api.dart';
import 'package:my_wealth/model/favourites/favourites_model.dart';
import 'package:my_wealth/model/user/user_login.dart';
import 'package:my_wealth/provider/favourites_provider.dart';
import 'package:my_wealth/provider/user_provider.dart';
import 'package:my_wealth/themes/colors.dart';
import 'package:my_wealth/utils/arguments/company_detail_args.dart';
import 'package:my_wealth/utils/dialog/create_snack_bar.dart';
import 'package:my_wealth/utils/dialog/show_my_dialog.dart';
import 'package:my_wealth/storage/prefs/shared_favourites.dart';
import 'package:my_wealth/storage/prefs/shared_user.dart';
import 'package:my_wealth/widgets/list/favourite_list.dart';
import 'package:my_wealth/widgets/modal/overlay_loading_modal.dart';
import 'package:provider/provider.dart';

class FavouritesPage extends StatefulWidget {
  const FavouritesPage({ super.key });

  @override
  FavouritesPageState createState() => FavouritesPageState();
}

class FavouritesPageState extends State<FavouritesPage> with SingleTickerProviderStateMixin  {
  final DateFormat df = DateFormat("dd/MM/yyyy");
  final ScrollController _scrollControllerMutual = ScrollController();
  final ScrollController _scrollControllerStock = ScrollController();
  final ScrollController _scrollControllerCrypto = ScrollController(); 
  final FavouritesAPI _faveAPI = FavouritesAPI();
  late TabController _tabController;

  late UserLoginInfoModel? _userInfo;
  late List<FavouritesModel> _favouriteListReksadana;
  late List<FavouritesModel> _favouriteListSaham;
  late List<FavouritesModel> _favouriteListCrypto;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _userInfo = UserSharedPreferences.getUserInfo();
    _favouriteListReksadana = FavouritesSharedPreferences.getFavouritesList("reksadana");
    _favouriteListSaham = FavouritesSharedPreferences.getFavouritesList("saham");
    _favouriteListCrypto = FavouritesSharedPreferences.getFavouritesList("crypto");
  }

  @override
  void dispose() {
    super.dispose();
    _scrollControllerMutual.dispose();
    _scrollControllerStock.dispose();
    _scrollControllerCrypto.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<UserProvider, FavouritesProvider>(
      builder: ((context, userProvider, favouritesProvider, child) {
        _userInfo = userProvider.userInfo;
        _favouriteListReksadana = (favouritesProvider.favouriteListReksadana ?? []);
        _favouriteListSaham = (favouritesProvider.favouriteListSaham ?? []);
        _favouriteListCrypto = (favouritesProvider.favouriteListCrypto ?? []);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    indicatorColor: accentColor,
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: textPrimary,
                    unselectedLabelColor: textPrimary,
                    dividerHeight: 0,
                    tabs: const <Widget>[
                      Tab(text: 'MUTUAL',),
                      Tab(text: 'STOCK',),
                      Tab(text: 'CRYPTO',),
                    ],
                  ),
                  const SizedBox(height: 10,),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: <Widget>[
                        (_favouriteListReksadana.isNotEmpty ? _createList(_scrollControllerMutual, "reksadana", _favouriteListReksadana) : const Center(child: Text("No favourites data"))),
                        (_favouriteListSaham.isNotEmpty ? _createList(_scrollControllerStock, "saham", _favouriteListSaham) : const Center(child: Text("No favourites data"))),
                        (_favouriteListCrypto.isNotEmpty ? _createList(_scrollControllerCrypto, "crypto", _favouriteListCrypto) : const Center(child: Text("No favourites data"))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _createList(ScrollController controller, String type, List<FavouritesModel> data) {
    return RefreshIndicator(
      onRefresh: (() async {
        debugPrint("🔃 Refresh favourites");

        // use future wait so we can sent it all together to save the time when
        // we need to wait for the response.
        await Future.wait([
          _getFavourites("reksadana").then((resp) async {
            if(resp.isNotEmpty) {
              if (mounted) {
                Provider.of<FavouritesProvider>(context, listen: false).setFavouriteList("reksadana", resp);
              }
              await FavouritesSharedPreferences.setFavouritesList("reksadana", resp);
            }
          }),

          _getFavourites("saham").then((resp) async {
            if(resp.isNotEmpty) {
              if (mounted) {
                Provider.of<FavouritesProvider>(context, listen: false).setFavouriteList("saham", resp);
              }
              await FavouritesSharedPreferences.setFavouritesList("saham", resp);
            }
          }),

          _getFavourites("crypto").then((resp) async {
            if(resp.isNotEmpty) {
              if (mounted) {
                Provider.of<FavouritesProvider>(context, listen: false).setFavouriteList("crypto", resp);
              }
              await FavouritesSharedPreferences.setFavouritesList("crypto", resp);
            }
          }),
        ]).onError((error, stackTrace) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(createSnackBar(message: error.toString()));
          }

          // remove the loading screen if error
          LoadingScreen.instance().hide();
          
          debugPrint("⛔ Error when refresh favourites");
          throw Exception('⛔ Error when refresh favourites');
        });

        // remove the loading screen
        LoadingScreen.instance().hide();

        // once finished just rebuild the widget
        setState(() {
          // just rebuild
        });
      }),
      color: accentColor,
      child: ListView.builder(
        controller: controller,
        itemCount: data.length,
        itemBuilder: ((context, index) {
          FavouritesModel fave = data[index];
          return InkWell(
            onTap: (() {
              CompanyDetailArgs args = CompanyDetailArgs(
                companyId: fave.favouritesCompanyId,
                companyName: fave.favouritesCompanyName,
                companyCode: fave.favouritesSymbol,
                companyFavourite: true,
                favouritesId: fave.favouritesId,
                type: type,
              );
              Navigator.pushNamed(context, '/company/detail/$type', arguments: args);
            }),
            child: Slidable(
              endActionPane: ActionPane(
                motion: const ScrollMotion(),
                extentRatio: 0.2,
                children: <Widget>[
                  SlidableAction(
                    onPressed: ((BuildContext context) {
                      Future<bool?> result = ShowMyDialog(
                        title: "Delete Favourites",
                        text: "Do you want to delete ${fave.favouritesCompanyName}?",
                        confirmLabel: "Delete",
                        confirmColor: secondaryColor,
                      ).show(context);
    
                      result.then((value) async {
                        if(value == true) {
                          await _deleteFavourites(index, type);
                        }
                      });
                    }),
                    icon: Ionicons.trash_outline,
                    backgroundColor: secondaryDark,
                  ),
                ],
              ),
              child: SimpleListItem(
                fca: fave.favouritesFCA,
                name: _generateName(type, fave.favouritesCompanyName, fave.favouritesSymbol),
                date: df.format(fave.favouritesLastUpdate.toLocal()),
                price: fave.favouritesNetAssetValue,
                percentChange: fave.favouritesCompanyDailyReturn,
                priceChange: (fave.favouritesNetAssetValue - fave.favouritesPrevAssetValue),
                riskFactor: _userInfo!.risk
              ),
            ),
          );
        }),
      ),
    );
  }

  String _generateName(String type, String name, String symbol) {
    if (type == "reksadana") {
      return name;
    }
    else {
      return "($symbol) $name";
    }
  }

  Future<void> _deleteFavourites(int index, String type) async {
    // check if this is already favourite or not?
    late int faveId;
    if(type == "reksadana") {
      faveId = _favouriteListReksadana[index].favouritesId;
    }
    else if(type == "saham") {
      faveId = _favouriteListSaham[index].favouritesId;
    }
    else if(type == "crypto") {
      faveId = _favouriteListCrypto[index].favouritesId;
    }
    
    // show loading screen
    LoadingScreen.instance().show(context: context);

    await _faveAPI.delete(faveId).then((_) {
      if(type=="reksadana") {
        debugPrint("🧹 Delete Favourite ID $faveId for company ${_favouriteListReksadana[index].favouritesCompanyName}");
      }
      else if(type == "saham") {
        debugPrint("🧹 Delete Favourite ID $faveId for company ${_favouriteListSaham[index].favouritesCompanyName}");
      }
      else if(type == "crypto") {
        debugPrint("🧹 Delete Favourite ID $faveId for company ${_favouriteListCrypto[index].favouritesCompanyName}");
      }
      
      // remove the _favouriteList and re-render the page
      setState(() {
        if(type=="reksadana") {
          _favouriteListReksadana.removeAt(index);
        }
        else if(type=="saham") {
          _favouriteListSaham.removeAt(index);
        }
        else if(type=="crypto") {
          _favouriteListCrypto.removeAt(index);
        }
      });
    }).onError((error, stackTrace) {
      debugPrint(error.toString());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(createSnackBar(message: "Unable to delete favourites"));
      }
    });
    
    // remove the loading screen
    LoadingScreen.instance().hide();
  }

  Future<List<FavouritesModel>> _getFavourites(String type) async {
    List<FavouritesModel> ret = [];

    await _faveAPI.getFavourites(type).then((resp) async {
      ret = resp;
    }).onError((error, stackTrace) {
      throw Exception("Error when refresh favourites");
    });

    // in any case it will return null
    return ret;
  }
}