import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:my_wealth/themes/colors.dart';
import 'package:my_wealth/utils/function/format_currency.dart';

class FavouriteCompanyList extends StatelessWidget {
  final int companyId;
  final String name;
  final String type;
  final String date;
  final double value;
  final bool isFavourite;
  final VoidCallback onPress;
  const FavouriteCompanyList({ Key? key, required this.companyId, required this.name, required this.type, required this.date, required this.value, required this.isFavourite, required this.onPress }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: primaryLight,
            width: 1.0,
            style: BorderStyle.solid
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        flex: 2,
                        child: Text(
                          type,
                          style: const TextStyle(
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        )
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          date,
                          style: const TextStyle(
                            fontSize: 12,
                          ),
                        )
                      ),
                      Expanded(
                        flex: 1,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            formatCurrency(value),
                            style: const TextStyle(
                              fontSize: 12,
                            ),
                          ),
                        )
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10,),
          IconButton(
            onPressed: (() {
              onPress();
            }),
            icon: Icon(
              (isFavourite ? Ionicons.star : Ionicons.star_outline),
              color: (isFavourite ? accentColor : accentDark),
            )
          ),
        ],
      ),
    );
  }
}
