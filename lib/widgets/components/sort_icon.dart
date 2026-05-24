import 'package:flutter/material.dart';
import 'package:my_wealth/themes/colors.dart';
import 'package:my_wealth/utils/enum/colum_sort_enum.dart';
import 'package:my_wealth/utils/icon/my_ionicons.dart';

class SortIcon extends StatelessWidget {
  const SortIcon({
    super.key,
    required this.sortType,
  });

  final SortType sortType;

  @override
  Widget build(BuildContext context) {
    return Icon(
      (
        sortType == SortType.ascending ?
        MyIonicons(MyIoniconsData.arrow_up).data :
        MyIonicons(MyIoniconsData.arrow_down).data
      ),
      size: 10,
      color: textPrimary,
    );
  }
}