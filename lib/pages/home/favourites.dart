import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ionicons/ionicons.dart';
import 'package:my_wealth/api/favourites_api.dart';
import 'package:my_wealth/model/favourites_model.dart';
import 'package:my_wealth/model/user_login.dart';
import 'package:my_wealth/provider/favourites_provider.dart';
import 'package:my_wealth/provider/user_provider.dart';
import 'package:my_wealth/themes/colors.dart';
import 'package:my_wealth/utils/arguments/company_detail_args.dart';
import 'package:my_wealth/utils/dialog/create_snack_bar.dart';
import 'package:my_wealth/utils/prefs/shared_favourites.dart';
import 'package:my_wealth/utils/prefs/shared_user.dart';
import 'package:my_wealth/widgets/favourite_list.dart';
import 'package:provider/provider.dart';

class FavouritesPage extends StatefulWidget {
  const FavouritesPage({ Key? key }) : super(key: key);

  @override
  _FavouritesPageState createState() => _FavouritesPageState();
}

class _FavouritesPageState extends State<FavouritesPage> {
  final DateFormat df = DateFormat("dd/MM/yyyy");
  final ScrollController _scrollController = ScrollController();
  final FavouritesAPI _faveAPI = FavouritesAPI();

  late UserLoginInfoModel? _userInfo;
  late List<FavouritesModel> _favouriteList;

  @override
  void initState() {
    super.initState();
    _userInfo = UserSharedPreferences.getUserInfo();
    _favouriteList = FavouritesSharedPreferences.getFavouritesList();
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<UserProvider, FavouritesProvider>(
      builder: ((context, userProvider, favouritesProvider, child) {
        _userInfo = userProvider.userInfo;
        _favouriteList = (favouritesProvider.favouriteList ?? []);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(10),
              color: primaryDark,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  const Icon(
                    Ionicons.star,
                    color: accentColor,
                    size: 15,
                  ),
                  const SizedBox(width: 5,),
                  const Expanded(
                    child: Text(
                      "Favourites",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: (() {
                      Navigator.pushNamed(context, '/favourites/list');
                    }),
                    icon: const Icon(
                      Ionicons.add_circle_outline,
                      color: accentColor,
                    ),
                    splashRadius: 30,
                    splashColor: primaryColor,
                  )
                ],
              ),
              width: double.infinity,
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: (() async {
                  debugPrint("🔃 Refresh favourites");
                  await _getFavourites().then((resp) async {
                    if(resp.isNotEmpty) {
                      Provider.of<FavouritesProvider>(context, listen: false).setFavouriteList(resp);
                      await FavouritesSharedPreferences.setFavouritesList(resp);
                    }
                  }).onError((error, stackTrace) {
                    debugPrint("⛔ Error when refresh favourites");
                    ScaffoldMessenger.of(context).showSnackBar(createSnackBar(message: error.toString()));
                  });
                }),
                color: accentColor,
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  controller: _scrollController,
                  itemCount: _favouriteList.length,
                  itemBuilder: ((context, index) {
                    // get the user favourites
                    FavouritesModel _fave = _favouriteList[index];
                    return InkWell(
                      onTap: (() {
                        CompanyDetailArgs _args = CompanyDetailArgs(
                          companyId: _fave.favouritesCompanyId,
                          companyName: _fave.favouritesCompanyName,
                          companyFavourite: true,
                          favouritesId: _fave.favouritesId
                        );
                        Navigator.pushNamed(context, '/company/detail', arguments: _args);
                      }),
                      child: FavouriteList(
                        name: _fave.favouritesCompanyName,
                        date: df.format(_fave.favouritesLastUpdate.toLocal()),
                        price: _fave.favouritesNetAssetValue,
                        percentChange: _fave.favouritesCompanyDailyReturn,
                        priceChange: (_fave.favouritesNetAssetValue - _fave.favouritesPrevAssetValue),
                        riskFactor: _userInfo!.risk
                      ),
                    );
                  }),
                ),
              )
            ),
          ],
        );
      }),
    );
  }

  Future<List<FavouritesModel>> _getFavourites() async {
    List<FavouritesModel> _ret = [];

    await _faveAPI.getFavourites().then((resp) async {
      _ret = resp;
    }).onError((error, stackTrace) {
      throw Exception("Error when refresh favourites");
    });

    // in any case it will return null
    return _ret;
  }
}