import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:ionicons/ionicons.dart';
import 'package:my_wealth/pages/home/broker.dart';
import 'package:my_wealth/pages/home/favourites.dart';
import 'package:my_wealth/pages/home/index.dart';
import 'package:my_wealth/pages/home/inisght.dart';
import 'package:my_wealth/pages/home/portofolio.dart';
import 'package:my_wealth/pages/home/watchlists.dart';
import 'package:my_wealth/themes/colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({ Key? key }) : super(key: key);

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
    return SafeArea(
      bottom: true,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(
              Ionicons.search_outline
            ),
            onPressed: (() {
              // open the search/favorites page
              _onItemTapped(5);
            }),
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
                Navigator.pushNamed(context, '/user');
              }),
              icon: const Icon(Ionicons.person_outline)
            )
          ],
          automaticallyImplyLeading: false,
        ),
        body: IndexedStack(
          index: _selectedIndex,
          children: _widgetList,
        ),
        bottomNavigationBar: _generateBottomBar(),
      ),
    );
  }

  Widget _generateBottomBar() {
    return Container(
      color: primaryDark,
      padding: const EdgeInsets.fromLTRB(15, 10, 15, 25),
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
            icon: Ionicons.analytics_outline,
            iconActiveColor: Colors.green[300],
          ),
          GButton(
            icon: Ionicons.business_outline,
            iconActiveColor: Colors.purple[300],
          ),
          const GButton(
            icon: Ionicons.list_circle_outline,
            iconActiveColor: Colors.orange,
          ),
          const GButton(
            icon: Ionicons.eye_outline,
            iconActiveColor: secondaryLight,
          ),
          const GButton(
            icon: Ionicons.bulb_outline,
            iconActiveColor: extendedLight,
          ),
        ],
      ),
      // child: SalomonBottomBar(
      //   items: <SalomonBottomBarItem>[
      //     SalomonBottomBarItem(
      //       icon: const Icon(Ionicons.analytics_outline),
      //       title: const Text(""),
      //       selectedColor: Colors.green[300],
      //     ),
      //     SalomonBottomBarItem(
      //       icon: const Icon(Ionicons.business_outline),
      //       title: const Text(""),
      //       selectedColor: Colors.purple[300],
      //     ),
      //     SalomonBottomBarItem(
      //       icon: const Icon(Ionicons.eye_outline),
      //       title: const Text(""),
      //       selectedColor: secondaryLight,
      //     ),
      //     SalomonBottomBarItem(
      //       icon: const Icon(Ionicons.list_circle_outline),
      //       title: const Text(""),
      //       selectedColor: accentLight,
      //     ),
      //     SalomonBottomBarItem(
      //       icon: const Icon(Ionicons.bulb_outline),
      //       title: const Text(""),
      //       selectedColor: extendedLight,
      //     ),
      //   ],
      //   currentIndex: _selectedIndex,
      //   onTap: _onItemTapped,
      // ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}