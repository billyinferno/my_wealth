import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:my_wealth/pages/home/favourites.dart';
import 'package:my_wealth/pages/home/index.dart';
import 'package:my_wealth/pages/home/user.dart';
import 'package:my_wealth/pages/home/watchlists.dart';
import 'package:my_wealth/themes/colors.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({ Key? key }) : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  int _selectedIndex = 2;

  static const List<Widget> _widgetList = <Widget>[
    IndexPage(),
    FavouritesPage(),
    WatchlistsPage(),
    UserPage()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            "myWealth",
            style: TextStyle(
              color: secondaryColor,
            ),
          )
        ),
        automaticallyImplyLeading: false,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetList,
      ),
      bottomNavigationBar: _generateBottomBar(),
    );
  }

  Widget _generateBottomBar() {
    return Container(
      color: primaryDark,
      padding: const EdgeInsets.all(10),
      child: SalomonBottomBar(
        items: <SalomonBottomBarItem>[
          SalomonBottomBarItem(
            icon: const Icon(Ionicons.analytics_outline),
            title: const Text("Index"),
            selectedColor: Colors.green[300],
          ),
          SalomonBottomBarItem(
            icon: const Icon(Ionicons.list_circle_outline),
            title: const Text("Favourites"),
            selectedColor: accentLight,
          ),
          SalomonBottomBarItem(
            icon: const Icon(Ionicons.eye_outline),
            title: const Text("Watchlists"),
            selectedColor: secondaryLight,
          ),
          SalomonBottomBarItem(
            icon: const Icon(Ionicons.person_outline),
            title: const Text("User"),
            selectedColor: extendedLight,
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}