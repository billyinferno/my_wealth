import 'package:flutter/material.dart';
import 'package:my_wealth/pages/insight/insight_bandar.dart';
import 'package:my_wealth/pages/insight/insight_broker.dart';
import 'package:my_wealth/pages/insight/insight_reksadana.dart';
import 'package:my_wealth/pages/insight/insight_stock.dart';
import 'package:my_wealth/themes/colors.dart';

class InsightPage extends StatefulWidget {
  const InsightPage({super.key});

  @override
  State<InsightPage> createState() => InsightPageState();
}

class InsightPageState extends State<InsightPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
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
            Tab(text: 'BROKER',),
            Tab(text: 'STOCK',),
            Tab(text: 'MUTUAL',),
            Tab(text: 'BANDAR',),
          ],
        ),
        const SizedBox(height: 10,),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const <Widget>[
              InsightBrokerPage(),
              InsightStockPage(),
              InsightReksadanaPage(),
              InsightBandarPage(),
            ],
          ),
        ),
      ],
    );
  }
}