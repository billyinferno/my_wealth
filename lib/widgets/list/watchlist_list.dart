import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:my_wealth/_index.g.dart';

class WatchlistList extends StatelessWidget {
  final String name;
  final String price;
  final String date;
  final Color riskColor;
  final bool canAdd;
  final bool fca;
  final bool warning;
  final IconData warningIcon;
  final Color warningColor;
  final VoidCallback onPress;
  const WatchlistList({
    super.key,
    required this.name,
    required this.price,
    required this.date,
    required this.riskColor,
    required this.canAdd,
    required this.fca,
    this.warning = false,
    this.warningIcon = Ionicons.warning,
    this.warningColor = secondaryColor,
    required this.onPress
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Container(
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: primaryLight,
              width: 1.0,
              style: BorderStyle.solid,
            ),
          )
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              color: riskColor,
              width: 5,
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Visibility(
                                visible: warning,
                                child: Container(
                                  padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                                  child: Icon(
                                    warningIcon,
                                    color: warningColor,
                                    size: 15,
                                  ),
                                )
                              ),
                              Visibility(
                                visible: fca,
                                child: Container(
                                  padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                                  child: const Icon(
                                    Ionicons.warning,
                                    color: secondaryColor,
                                    size: 15,
                                  ),
                                )
                              ),
                              Expanded(
                                child: Text(
                                  name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5,),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              const Icon(
                                Ionicons.logo_usd,
                                size: 12,
                                color: primaryLight,
                              ),
                              const SizedBox(width: 5,),
                              Expanded(
                                child: Text(
                                  price,
                                  style: const TextStyle(
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10,),
                              const Icon(
                                Ionicons.time,
                                size: 12,
                                color: primaryLight,
                              ),
                              const SizedBox(width: 5,),
                              Expanded(
                                child: Text(
                                  date,
                                  style: const TextStyle(
                                    fontSize: 12,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                    (canAdd ? _canPress() : _cannotPress()),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _canPress() {
    return InkWell(
      onTap: (() {
        onPress();
      }),
      child: Container(
        color: primaryColor,
        width: 25,
        child: const Icon(
          Ionicons.add_circle,
          color: accentColor,
        ),
      ),
    );
  }

  Widget _cannotPress() {
    return Container(
      color: primaryColor,
      width: 25,
      child: const Icon(
        Ionicons.checkmark,
        color: Colors.green,
      ),
    );
  }
}