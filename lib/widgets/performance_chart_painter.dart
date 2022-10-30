import 'package:flutter/material.dart';
import 'package:my_wealth/model/watchlist_detail_list_model.dart';
import 'package:my_wealth/model/watchlist_performance_model.dart';
import 'package:my_wealth/themes/colors.dart';
import 'package:my_wealth/utils/function/binary_computation.dart';
import 'package:my_wealth/utils/function/date_utils.dart';
import 'package:my_wealth/utils/function/format_currency.dart';

class PerformanceData {
  final DateTime date;
  final double gain;

  PerformanceData({required this.date, required this.gain});
}

class PerformanceChartPainter extends CustomPainter {
  final List<WatchlistPerformanceModel> data;
  final List<WatchlistDetailListModel>? watchlist;

  PerformanceChartPainter({required this.data, this.watchlist});

  // draw the path
  final Paint dpUp = Paint()
    ..color = Colors.green
    ..strokeWidth = 1.0
    ..style = PaintingStyle.stroke;

  final Paint dpDown = Paint()
    ..color = secondaryColor
    ..strokeWidth = 1.0
    ..style = PaintingStyle.stroke;

  final Paint dpNoChange = Paint()
    ..color = Colors.white
    ..strokeWidth = 1.0
    ..style = PaintingStyle.stroke;

  final Paint graphRectBorder = Paint()
    ..color = primaryDark.withOpacity(0.5)
    ..strokeWidth = 1.0
    ..style = PaintingStyle.stroke;

  final Paint graphRectBorderWhite = Paint()
    ..color = primaryLight.withOpacity(0.5)
    ..strokeWidth = 1.0
    ..style = PaintingStyle.stroke;
  
  final Paint watchlistPaintBuy = Paint()
    ..color = accentColor;

  final Paint watchlistPaintSell = Paint()
    ..color = extendedLight;

  final Paint watchlistPaintBuySell = Paint()
    ..color = Colors.white;

  late List<PerformanceData> _data;
  late Map<DateTime, int> _watchlist;

  double _min = double.infinity;
  double _max = 0;
  double _gap = 0;
  double _norm = 0;

  @override
  void paint(Canvas canvas, Size size) {
    // normalize the watchlist performance data, and calculate the gain
    _data = [];
    _watchlist = {};
    _compute();

    // draw the line if we have data
    if (_data.isNotEmpty) {
      _drawLine(canvas, size);
    }

    // draw the box
    _drawBox(canvas, size);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

  void _drawLine(Canvas canvas, Size size) {
    double x;
    double y;

    // create the rect that we will use as a guide for the graph
    Rect graphRect = Rect.fromLTRB(10, 10, size.width - 10, size.height - 30);

    // calculate the xLeft and the width guide that will be used to move between
    // one point to another point in the graph.
    int count = _data.length;
    double xLeft = graphRect.left;
    double guideW = graphRect.size.width / count;

    // check for the date print offset
    int datePrintOffset = 10;
    if (count < datePrintOffset) {
      datePrintOffset = count - 1;
    }

    for (int i = 0; i < data.length; i++) {
      Offset p1 = Offset(xLeft, graphRect.bottom);
      Offset p2 = Offset(xLeft, graphRect.top);

      if (i % datePrintOffset == 0 && i > 0) {
        canvas.drawLine(p1, p2, graphRectBorderWhite);
        _drawText(
            canvas: canvas,
            position: Offset(xLeft, graphRect.bottom),
            width: 60,
            text: formatDate(date: _data[i].date, format: "dd/MM"),
            left: -15,
            top: 5,
            minHeight: 0,
            maxHeight: graphRect.height + 20,
            minWidth: 0,
            maxWidth: graphRect.width + 20);
      } else {
        canvas.drawLine(p1, p2, graphRectBorder);
      }

      // next
      xLeft += guideW;
    }

    // draw horizontal line
    double yD = graphRect.size.height / 4;
    for (int i = 0; i < 4; i++) {
      Offset p1 = Offset(graphRect.left, graphRect.bottom - (yD * i));
      Offset p2 = Offset(graphRect.right, graphRect.bottom - (yD * i));
      canvas.drawLine(p1, p2, graphRectBorder);

      double currVal = _min + (((_max - _min) / 4.0) * i.toDouble());
      _drawText(
          canvas: canvas,
          position: Offset(graphRect.left, graphRect.bottom - (yD * i) - 5),
          width: 60,
          text: formatCurrency(currVal),
          left: 0,
          top: -5,
          minHeight: 10,
          maxHeight: graphRect.height,
          minWidth: 10,
          maxWidth: graphRect.width);
    }

    // put the max price
    _drawText(
        canvas: canvas,
        position: Offset(graphRect.left, graphRect.top),
        width: 60,
        text: formatCurrency(_max),
        left: 0,
        top: -5,
        minHeight: 10,
        maxHeight: graphRect.height,
        minWidth: 10,
        maxWidth: graphRect.width);

    Path pUp = Path();
    Path pDown = Path();
    Path pNoChange = Path();
    bool isFirst = true;
    double ratio = 0;
    double w = graphRect.width / (data.length.toDouble() - 1);

    if (_gap > 0) {
      ratio = graphRect.height / _gap;
    }

    x = graphRect.left;
    y = 0;

    // loop thru data
    for (PerformanceData value in _data) {
      y = 10 + graphRect.height - ((value.gain + _norm) * ratio);

      // check whether this is the first data?
      if (isFirst) {
        pUp.moveTo(x, y);
        pDown.moveTo(x, y);
        pNoChange.moveTo(x, y);
        isFirst = false;
      } else {
        // check whether price go up or go down?
        if (value.gain > 0) {
          pUp.lineTo(x, y);
          pDown.moveTo(x, y);
          pNoChange.moveTo(x, y);
        } else if (value.gain < 0) {
          pUp.moveTo(x, y);
          pDown.lineTo(x, y);
          pNoChange.moveTo(x, y);
        } else {
          pUp.moveTo(x, y);
          pDown.moveTo(x, y);
          pNoChange.lineTo(x, y);
        }
      }

      // check if watchlist is not null
      if (_watchlist.isNotEmpty) {
        // check if this date is on the watchlist or not?
        if (_watchlist.containsKey(value.date.toLocal())) {
          // got the date, so now we can just draw the circle in this position            
          // if we doing buy and sell all in one day
          if (_watchlist[value.date.toLocal()] == 3) {
            canvas.drawCircle(Offset(x, y), 3.0, watchlistPaintBuySell);  
          }
          else if (_watchlist[value.date.toLocal()] == 1) {
            canvas.drawCircle(Offset(x, y), 3.0, watchlistPaintBuy);  
          }
          else if (_watchlist[value.date.toLocal()] == 2) {
            canvas.drawCircle(Offset(x, y), 3.0, watchlistPaintSell);
          }
        }
      }

      // next column
      x += w;
    }

    // draw the line chart
    canvas.drawPath(pUp, dpUp);
    canvas.drawPath(pDown, dpDown);
    canvas.drawPath(pNoChange, dpNoChange);
  }

  void _drawBox(Canvas canvas, Size size) {
    // calculate the center
    Offset center = Offset(size.width / 2, size.height / 2);

    // set the rectangle position
    Rect rect = Rect.fromCenter(
      center: center,
      width: (size.width - 20),
      height: (size.height - 20),
    );

    Paint border = Paint()
      ..color = primaryLight
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // draw the rectangle
    canvas.drawRect(rect, border);
  }

  void _compute() {
    double gain;

    // loop thru all the performance model data
    for (WatchlistPerformanceModel perf in data) {
      // calculate the gain
      gain =
          (perf.buyTotal * perf.currentPrice) - (perf.buyTotal * perf.buyAvg);

      // check the gain with _min and _max
      if (gain < _min) {
        _min = gain;
      }

      if (gain > _max) {
        _max = gain;
      }

      // create the performance data
      PerformanceData dt = PerformanceData(date: perf.buyDate, gain: gain);

      // add the perfoemance data to the list
      _data.add(dt);
    }

    // check the gap between _min and _max
    // print("$_max - $_min");
    _gap = _max - _min;

    // check if _gap is less than 0, if less than 0 it means that this watchlist
    // never even go to the green even once. thus we will need to make the gap
    // value into positive.
    if (_gap < 0) {
      _gap = _gap * (-1);
    }

    // calculate the normalize value
    _norm = _gap - _max;

    // loop thru the watchlist if available
    if (watchlist != null) {
      DateTime tempDate;
      for(WatchlistDetailListModel dt in watchlist!) {
        tempDate = dt.watchlistDetailDate.toLocal();
        if (_watchlist.containsKey(DateTime(tempDate.year, tempDate.month, tempDate.day))) {
          if (dt.watchlistDetailShare > 0) {
            // this is buy
            _watchlist[DateTime(tempDate.year, tempDate.month, tempDate.day)] = bit(data: _watchlist[DateTime(tempDate.year, tempDate.month, tempDate.day)]!, pos: 15, value: 1);
          }
          if (dt.watchlistDetailShare < 0) {
            // this is sell
            _watchlist[DateTime(tempDate.year, tempDate.month, tempDate.day)] = bit(data: _watchlist[DateTime(tempDate.year, tempDate.month, tempDate.day)]!, pos: 14, value: 1);
          }
        }
        else {
          if (dt.watchlistDetailShare > 0) {
            // this is buy
            _watchlist[DateTime(tempDate.year, tempDate.month, tempDate.day)] = 1;
          }
          if (dt.watchlistDetailShare < 0) {
            _watchlist[DateTime(tempDate.year, tempDate.month, tempDate.day)] = 2;
          }
        }
      }
      
    }
  }

  void _drawText(
      {required Canvas canvas,
      required Offset position,
      required double width,
      required String text,
      required double left,
      required double top,
      required double minHeight,
      required double maxHeight,
      required double minWidth,
      required double maxWidth,
      Color? textColor}) {
    final TextSpan textSpan = TextSpan(
      text: text,
      style: TextStyle(
        color: (textColor ?? Colors.white.withOpacity(0.5)),
        fontSize: 10,
      ),
    );

    final TextPainter textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.left,
    );

    textPainter.layout(minWidth: 0, maxWidth: width);
    double dx = position.dx + left;
    if (dx < minWidth) {
      dx = minWidth;
    }
    if (dx > maxWidth) {
      dx = maxWidth - textPainter.width;
    }

    double dy = position.dy + top;
    if (dy < minHeight) {
      dy = minHeight;
    }
    if (dy > maxHeight) {
      dy = maxHeight - textPainter.height;
    }

    textPainter.paint(canvas, Offset(dx, dy));
  }
}
