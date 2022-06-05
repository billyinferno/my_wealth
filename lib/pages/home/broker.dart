import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_wealth/api/broker_api.dart';
import 'package:my_wealth/model/broker_model.dart';
import 'package:my_wealth/model/user_login.dart';
import 'package:my_wealth/provider/broker_provider.dart';
import 'package:my_wealth/provider/user_provider.dart';
import 'package:my_wealth/themes/colors.dart';
import 'package:my_wealth/utils/dialog/create_snack_bar.dart';
import 'package:my_wealth/utils/function/format_currency.dart';
import 'package:my_wealth/utils/loader/show_loader_dialog.dart';
import 'package:my_wealth/utils/prefs/shared_broker.dart';
import 'package:my_wealth/utils/prefs/shared_user.dart';
import 'package:provider/provider.dart';

class BrokerPage extends StatefulWidget {
  const BrokerPage({Key? key}) : super(key: key);

  @override
  State<BrokerPage> createState() => _BrokerPageState();
}

class _BrokerPageState extends State<BrokerPage> {
  final DateFormat _df = DateFormat('dd/MM/yyyy');
  final ScrollController _scrollController = ScrollController();
  final BrokerAPI _brokerAPI = BrokerAPI();

  late List<BrokerModel> _brokerList;

  @override
  void initState() {
    super.initState();
    _brokerList = BrokerSharedPreferences.getBrokerList();
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BrokerProvider>(
      builder: ((context, brokerProvider, child) {
        _brokerList = brokerProvider.brokerList!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: RefreshIndicator(
                onRefresh: (() async {
                  showLoaderDialog(context);
                  await _refreshBroker().then((value) {
                    debugPrint("🔃 Refresh Index");
                  }).onError((error, stackTrace) {
                    ScaffoldMessenger.of(context).showSnackBar(createSnackBar(message: error.toString()));
                  }).whenComplete(() {
                    // remove the loader
                    Navigator.pop(context);
                  });
                }),
                color: accentColor,
                child: ListView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: List.generate(_brokerList.length, (index) {
                    return Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        border: Border(bottom: BorderSide(color: primaryLight, style: BorderStyle.solid, width: 1.0))
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                _brokerList[index].brokerFirmId,
                                style: const TextStyle(
                                  color: accentColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 10,),
                              Text(
                                _brokerList[index].brokerFirmName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                          const SizedBox(height: 10,),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              _informationText(flex: 2, text: "Date", value: _df.format(_brokerList[index].brokerDate)),
                              _informationText(text: "Volume", value: formatIntWithNull(_brokerList[index].brokerVolume, true, true)),
                              _informationText(text: "Value", value: formatIntWithNull(_brokerList[index].brokerValue, true, true)),
                              _informationText(text: "Frequency", value: formatIntWithNull(_brokerList[index].brokerFrequency, false, false)),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Future<void> _refreshBroker() async {
    await _brokerAPI.getBroker().then((resp) async {
      // set the shared preferences and provider for index
      await BrokerSharedPreferences.setBrokerList(resp);
      if (!mounted) return;
      Provider.of<BrokerProvider>(context, listen: false).setBrokerList(resp);
    }).onError((error, stackTrace) {
      throw Exception(error.toString());
    });
  }

  Widget _informationText({int? flex, required String text, required String value}) {
    int flexNum = (flex ?? 1);

    return Expanded(
      flex: flexNum,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Text(
            text,
            style: const TextStyle(
              fontSize: 10,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
            ),
          )
        ],
      ),
    );
  }
}