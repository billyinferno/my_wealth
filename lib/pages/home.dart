import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:my_wealth/_index.g.dart';
import 'package:my_wealth/utils/icon/my_ionicons.dart';

class HomePage extends StatefulWidget {
  const HomePage({ super.key });

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  int _selectedIndex = 2;

  static const List<String> _titleList = <String>[
    'Index',
    'Broker',
    'Portofolio',
    'Watchlists',
    'Insight',
    'Favourites',
  ];

  final List<Color> _activeColor = <Color>[
    Colors.green[300]!.withValues(alpha: 0.3),
    Colors.purple[300]!.withValues(alpha: 0.3),
    accentColor.withValues(alpha: 0.3),
    secondaryLight.withValues(alpha: 0.3),
    extendedLight.withValues(alpha: 0.3),
    Colors.transparent,
  ];

  static const List<Widget> _widgetList = <Widget>[
    IndexPage(),
    BrokerPage(),
    PortofolioPage(),
    WatchlistsPage(),
    InsightPage(),
    FavouritesPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Row(
          children: [
            IconButton(
              icon: Icon(
                (_selectedIndex == 5 ? MyIonicons(MyIoniconsData.star) : MyIonicons(MyIoniconsData.star_outline)).data,
                color: (_selectedIndex == 5 ? Colors.yellow : textPrimary),
              ),
              onPressed: (() {
                // open the search/favorites page
                _onItemTapped(5);
              }),
            ),
          ],
        ),
        title: Center(
          child: Text(
            _titleList[_selectedIndex],
            style: const TextStyle(
              color: secondaryColor,
            ),
          )
        ),
        actions: <Widget>[
          IconButton(
            onPressed: (() {
              showCupertinoModalPopup<void>(
                context: context,
                builder: ((BuildContext context) {
                  return MySafeArea(
                    child: CupertinoActionSheet(
                      title: const Text(
                        "Search Symbol",
                        style: TextStyle(
                          fontFamily: '--apple-system',
                        ),
                      ),
                      actions: <CupertinoActionSheetAction>[
                        CupertinoActionSheetAction(
                          onPressed: (() {
                            // navigate to reksadana
                            Navigator.popAndPushNamed(context, '/favourites/list/reksadana');
                          }),
                          child: const Text(
                            "Mutual Fund",
                            style: TextStyle(
                              fontFamily: '--apple-system',
                              color: textPrimary,
                            ),
                          ),
                        ),
                        CupertinoActionSheetAction(
                          onPressed: (() {
                            // navigate to reksadana
                            Navigator.popAndPushNamed(context, '/favourites/list/saham');
                          }),
                          child: const Text(
                            "Stock",
                            style: TextStyle(
                              fontFamily: '--apple-system',
                              color: textPrimary,
                            ),
                          ),
                        ),
                        CupertinoActionSheetAction(
                          onPressed: (() {
                            // navigate to reksadana
                            Navigator.popAndPushNamed(context, '/favourites/list/crypto');
                          }),
                          child: const Text(
                            "Crypto",
                            style: TextStyle(
                              fontFamily: '--apple-system',
                              color: textPrimary,
                            ),
                          ),
                        )
                      ],
                    ),
                  );
                }),
              );
            }),
            icon: Icon(MyIonicons(MyIoniconsData.search_outline).data)
          ),
          IconButton(
            onPressed: (() {
              Navigator.pushNamed(context, '/user');
            }),
            icon: Icon(MyIonicons(MyIoniconsData.person_outline).data)
          )
        ],
        automaticallyImplyLeading: false,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetList,
      ),
      bottomNavigationBar: MySafeArea(
        bottomPadding: 15,
        color: primaryDark,
        child: _generateBottomBar()
      ),
    );
  }

  Widget _generateBottomBar() {
    return Container(
      color: primaryDark,
      padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
      child: GNav(
        selectedIndex: _selectedIndex,
        backgroundColor: primaryDark,
        onTabChange: ((index) {
          _onItemTapped(index);
        }),
        tabBackgroundColor: _activeColor[_selectedIndex],
        padding: const EdgeInsets.all(15),
        duration: const Duration(milliseconds: 300),
        color: Colors.white,
        tabs: [
          GButton(
            icon: MyIonicons(MyIoniconsData.analytics_outline).data,
            iconActiveColor: Color.fromRGBO(129, 199, 132, 1),
          ),
          GButton(
            icon: MyIonicons(MyIoniconsData.business_outline).data,
            iconActiveColor: Color.fromRGBO(186, 104, 200, 1),
          ),
          GButton(
            icon: MyIonicons(MyIoniconsData.list_circle_outline).data,
            iconActiveColor: Colors.orange,
          ),
          GButton(
            icon: MyIonicons(MyIoniconsData.eye_outline).data,
            iconActiveColor: secondaryLight,
          ),
          GButton(
            icon: MyIonicons(MyIoniconsData.bulb_outline).data,
            iconActiveColor: extendedLight,
          ),
        ],
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}