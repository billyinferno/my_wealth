import 'package:flutter/material.dart';
import 'package:my_wealth/themes/colors.dart';
import 'package:my_wealth/utils/function/date_utils.dart';
import 'package:my_wealth/utils/function/format_currency.dart';
import 'package:my_wealth/widgets/heat_graph.dart';

class LineChartPainter extends CustomPainter {
  final List<GraphData> data;
  final Map<DateTime, double>? watchlist;
  
  const LineChartPainter({required this.data, this.watchlist});

  @override
  void paint(Canvas canvas, Size size) {
    // calculate the center
    Offset center = Offset(size.width / 2, size.height / 2);

    // then let's draw the line
    _drawLine(canvas, size, center);

    // first let's draw the border
    _drawBorder(canvas, size, center);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

  double _maxData() {
    // loop on the data
    double max = double.minPositive;

    for (GraphData value in data) {
      if(max < value.price) {
        max = value.price;
      }
    }

    return max;
  }

  double _minData() {
    // loop on the data
    double min = double.maxFinite;

    for (GraphData value in data) {
      if(min > value.price) {
        min = value.price;
      }
    }

    return min;
  }

  void _drawBorder(Canvas canvas, Size size, Offset center) {
    // set the rectangle position
    Rect rect = Rect.fromCenter(center: center, width: (size.width - 20), height: (size.height - 20));
    Paint border = Paint()
      ..color = primaryLight
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    
    // draw the rectangle
    canvas.drawRect(rect, border);
  }

  void _drawLine(Canvas canvas, Size size, Offset center) {
    // get the max and min data from the graph
    double max = _maxData();
    double min = _minData();

    // create the rect that we will use as a guide for the graph
    Rect graphRect = Rect.fromLTRB(10, 10, size.width - 10, size.height - 30);
    Paint graphRectBorder = Paint()
      ..color = primaryDark.withOpacity(0.5)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    Paint graphRectBorderWhite = Paint()
      ..color = primaryLight.withOpacity(0.5)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    Paint watchlistPaintBuy = Paint()
      ..color = accentColor;
    Paint watchlistPaintSell = Paint()
      ..color = extendedLight;
    Paint watchlistPaintBuySell = Paint()
      ..color = Colors.white;

    // canvas.drawRect(graphRect, graphRectBorder);
    
    // draw the guides
    // draw vertical lines
    double xLeft = graphRect.left;
    double guideW = graphRect.size.width / data.length;
    for(int i = 0; i < data.length; i++) {
      Offset p1 = Offset(xLeft, graphRect.bottom);
      Offset p2 = Offset(xLeft, graphRect.top);

      if(i%10 == 0 && i > 0) {
        canvas.drawLine(p1, p2, graphRectBorderWhite);
        _drawText(canvas, Offset(xLeft, graphRect.bottom), 60, formatDate(date: data[i].date, format: "dd/MM"), -15, 5, graphRect.height, graphRect.width);
      }
      else {
        canvas.drawLine(p1, p2, graphRectBorder);
      }

      // next
      xLeft += guideW;
    }

    // draw horizontal line
    double yD = graphRect.size.height / 4;
    for(int i = 0; i < 4; i++) {
      Offset p1 = Offset(graphRect.left, graphRect.bottom - (yD * i));
      Offset p2 = Offset(graphRect.right, graphRect.bottom - (yD * i));
      canvas.drawLine(p1, p2, graphRectBorder);

      double currVal = min + (((max - min) / 4.0) * i.toDouble());
      _drawText(canvas, Offset(graphRect.left, graphRect.bottom - (yD * i) - 5), 60, formatCurrency(currVal), 0, -5, graphRect.height, graphRect.width);
    }

    // once guidelines finished, we can draw the actual graph
    double gap = graphRect.width / (data.length.toDouble() - 1);
    double ratio = graphRect.height / (max - min);
    Path pUp = Path();
    Path pDown = Path();
    Path pNoChange = Path();
    double x = graphRect.left;
    double y = 0;
    bool isFirst = true;
    double prevPrice = double.minPositive;

    // loop thru data
    for (GraphData value in data) {
      y = 10 + graphRect.height - ((value.price - min) * ratio);

      // check if watchlist is not null
      if (watchlist != null) {
        if (watchlist!.isNotEmpty) {
          // check if this date is on the watchlist or not?
          if (watchlist!.containsKey(value.date)) {
            // got the date, so now we can just draw the circle in this position            
            // if we doing buy and sell all in one day
            if (watchlist![value.date]! == 0) {
              canvas.drawCircle(Offset(x, y), 3.0, watchlistPaintBuySell);  
            }
            else if (watchlist![value.date]! > 0) {
              canvas.drawCircle(Offset(x, y), 3.0, watchlistPaintBuy);  
            }
            else {
              canvas.drawCircle(Offset(x, y), 3.0, watchlistPaintSell);
            }
          }
        }
      }

      // check whether this is the first data?
      if(isFirst) {
        pUp.moveTo(x, y);
        pDown.moveTo(x, y);
        pNoChange.moveTo(x, y);

        isFirst = false;
      }
      else {
        // check whether price go up or go down?
        if(value.price > prevPrice) {
          pUp.lineTo(x, y);
          pDown.moveTo(x, y);
          pNoChange.moveTo(x, y);
        }
        else if(value.price < prevPrice) {
          pUp.moveTo(x, y);
          pDown.lineTo(x, y);
          pNoChange.moveTo(x, y);
        }
        else {
          pUp.moveTo(x, y);
          pDown.moveTo(x, y);
          pNoChange.lineTo(x, y);
        }
      }

      // next column
      prevPrice = value.price;
      x += gap;
    }

    // end of chart

    // draw the path
    Paint dpUp = Paint()
      ..color = Colors.green
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    Paint dpDown = Paint()
      ..color = secondaryColor
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    
    Paint dpNoChange = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    canvas.drawPath(pUp, dpUp);
    canvas.drawPath(pDown, dpDown);
    canvas.drawPath(pNoChange, dpNoChange);
  }

  void _drawText(Canvas canvas, Offset position, double width, String text, double left, double top, double maxHeight, double maxWidth) {
    final TextSpan textSpan = TextSpan(
      text: text,
      style: TextStyle(
        color: Colors.white.withOpacity(0.5),
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
    if (dx > maxWidth) {
      dx = maxWidth - textPainter.width;
    }

    textPainter.paint(canvas, Offset(dx, (position.dy + top)));
  }
}