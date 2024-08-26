import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:ionicons/ionicons.dart';
import 'package:my_wealth/_index.g.dart';

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
    Colors.green[300]!.withOpacity(0.3),
    Colors.purple[300]!.withOpacity(0.3),
    accentColor.withOpacity(0.3),
    secondaryLight.withOpacity(0.3),
    extendedLight.withOpacity(0.3),
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
                (_selectedIndex == 5 ? Ionicons.star : Ionicons.star_outline),
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
            icon: const Icon(Ionicons.search_outline)
          ),
          IconButton(
            onPressed: (() {
              Navigator.pushNamed(context, '/user');
            }),
            icon: const Icon(Ionicons.person_outline)
          )
        ],
        automaticallyImplyLeading: false,
      ),
      body: MySafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: _widgetList,
        ),
      ),
      bottomNavigationBar: _generateBottomBar(),
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
        tabs: const [
          GButton(
            icon: Ionicons.analytics_outline,
            iconActiveColor: Color.fromRGBO(129, 199, 132, 1),
          ),
          GButton(
            icon: Ionicons.business_outline,
            iconActiveColor: Color.fromRGBO(186, 104, 200, 1),
          ),
          GButton(
            icon: Ionicons.list_circle_outline,
            iconActiveColor: Colors.orange,
          ),
          GButton(
            icon: Ionicons.eye_outline,
            iconActiveColor: secondaryLight,
          ),
          GButton(
            icon: Ionicons.bulb_outline,
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