import 'package:flutter/material.dart';
import 'package:my_wealth/pages/insight/insight_broker.dart';
import 'package:my_wealth/pages/insight/insight_stock.dart';

class InsightPage extends StatefulWidget {
  const InsightPage({Key? key}) : super(key: key);

  @override
  State<InsightPage> createState() => InsightPageState();
}

class InsightPageState extends State<InsightPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 3, vsync: this);
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
          tabs: const <Widget>[
            Tab(text: 'BROKER',),
            Tab(text: 'STOCK',),
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
              Center(child: Text("Bandar")),
            ],
          ),
        ),
      ],
    );
  }
}