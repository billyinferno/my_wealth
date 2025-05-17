import 'package:flutter/cupertino.dart';
import 'package:my_wealth/themes/colors.dart';

class SmallBox extends StatelessWidget {
  final String title;
  final String value;
  const SmallBox({
    super.key,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SizedBox(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: extendedLight,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 12
              ),
            ),
          ],
        ),
      ),
    );
  }
}