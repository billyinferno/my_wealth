import 'package:flutter/material.dart';
import 'package:my_wealth/themes/colors.dart';
import 'package:my_wealth/utils/function/date_utils.dart';
import 'package:my_wealth/utils/function/format_currency.dart';
import 'package:my_wealth/widgets/chart/heat_graph.dart';

class LineChartPainter extends CustomPainter {
  final List<GraphData> data;
  final Map<DateTime, int>? watchlist;
  final bool? showLegend;
  
  const LineChartPainter({required this.data, this.watchlist, this.showLegend});

  @override
  void paint(Canvas canvas, Size size) {
    // calculate the center
    Offset center = Offset(size.width / 2, size.height / 2);

    // ensure that we at least have more than 1 data, because if only 1 data
    // then the min or max probably will be the same.
    if (data.length > 1) {
      // then let's draw the line
      _drawLine(canvas, size, center);
    }

    // first let's draw the border
    _drawBorder(canvas, size, center);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
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
    double x;
    double y;

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
    Paint avgPricePaint = Paint()
      ..color = Colors.orange.withOpacity(0.7);
    Paint ma5PricePaint = Paint()
      ..color = Colors.green.withOpacity(0.7);
    Paint ma8PricePaint = Paint()
      ..color = Colors.pink.withOpacity(0.7);
    Paint ma13PricePaint = Paint()
      ..color = Colors.blue.withOpacity(0.7);

    // canvas.drawRect(graphRect, graphRectBorder);
    
    // draw the guides
    // draw vertical lines
    double xLeft = graphRect.left;
    double guideW = graphRect.size.width / data.length;
    double avgPrice = 0;
    int count = data.length;
    double ma5 = 0;
    double ma5Count = 0;
    double ma8 = 0;
    double ma8Count = 0;
    double ma13 = 0;
    double ma13Count = 0;

    // check for the date print offset
    int datePrintOffset = 10;
    if (data.length < datePrintOffset) {
      datePrintOffset = data.length - 1;
    }

    for(int i = 0; i < data.length; i++) {
      Offset p1 = Offset(xLeft, graphRect.bottom);
      Offset p2 = Offset(xLeft, graphRect.top);

      avgPrice = avgPrice + data[i].price;

      count = count - 1;
      if (count < 5) {
        ma5 = ma5 + data[i].price;
        ma5Count++;
      }
      if (count < 8) {
        ma8 = ma8 + data[i].price;
        ma8Count++;
      }
      if (count < 13) {
        ma13 = ma13 + data[i].price;
        ma13Count++;
      }

      if(i%datePrintOffset == 0 && i > 0) {
        canvas.drawLine(p1, p2, graphRectBorderWhite);
        _drawText(
          canvas: canvas,
          position: Offset(xLeft, graphRect.bottom),
          width: 60,
          text: formatDate(date: data[i].date, format: "dd/MM"),
          left: -15,
          top: 5,
          minHeight: 0,
          maxHeight: graphRect.height + 20,
          minWidth: 0,
          maxWidth: graphRect.width + 20
        );
      }
      else {
        canvas.drawLine(p1, p2, graphRectBorder);
      }

      // next
      xLeft += guideW;
    }
    avgPrice = avgPrice / data.length;
    ma5 = ma5 / ma5Count;
    ma8 = ma8 / ma8Count;
    ma13 = ma13 / ma13Count;
    // debugPrint("$ma5 - $ma5Count, $ma8 - $ma8Count, $ma13 - $ma13Count");

    // draw horizontal line
    double yD = graphRect.size.height / 4;
    for(int i = 0; i < 4; i++) {
      Offset p1 = Offset(graphRect.left, graphRect.bottom - (yD * i));
      Offset p2 = Offset(graphRect.right, graphRect.bottom - (yD * i));
      canvas.drawLine(p1, p2, graphRectBorder);

      double currVal = min + (((max - min) / 4.0) * i.toDouble());
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
        maxWidth: graphRect.width
      );
    }

    // put the max price
    _drawText(
        canvas: canvas,
        position: Offset(graphRect.left, graphRect.top),
        width: 60,
        text: formatCurrency(max),
        left: 0,
        top: -5,
        minHeight: 10,
        maxHeight: graphRect.height,
        minWidth: 10,
        maxWidth: graphRect.width
      );
    
    // check if we need to show legend or not?
    bool isShowLegend = (showLegend ?? true);

    if (isShowLegend) {
      // draw the average price line
      // ensure that (max-min is not 0)
      if ((max-min) == 0) {
        yD = ((avgPrice - min) / (min)) * graphRect.height;
      }
      else {
        yD = ((avgPrice - min) / (max - min)) * graphRect.height;
      }
      _drawDashedLine(canvas, graphRect, 2, yD, avgPricePaint);
      _drawText(
        canvas: canvas,
        position: Offset(graphRect.right, graphRect.bottom - yD),
        width: 60,
        text: formatCurrency(avgPrice),
        left: 0,
        top: -10,
        minHeight: 10,
        maxHeight: graphRect.height,
        minWidth: 10,
        maxWidth: graphRect.width + 8,
        textColor: Colors.orange[300]!.withOpacity(0.5)
      );

      // draw the ma5 price line
      if ((max-min) == 0) {
        yD = ((ma5 - min) / (min)) * graphRect.height;
      }
      else {
        yD = ((ma5 - min) / (max - min)) * graphRect.height;
      }
      _drawDashedLine(canvas, graphRect, 2, yD, ma5PricePaint);
      _drawText(
        canvas: canvas,
        position: Offset(graphRect.right, graphRect.bottom - yD),
        width: 60,
        text: formatCurrency(ma5),
        left: 0,
        top: -10,
        minHeight: 10,
        maxHeight: graphRect.height,
        minWidth: 10,
        maxWidth: graphRect.width + 8,
        textColor: Colors.green[300]!.withOpacity(0.5)
      );

      // draw the ma8 price line
      if ((max-min) == 0) {
        yD = ((ma8 - min) / (min)) * graphRect.height;
      }
      else {
        yD = ((ma8 - min) / (max - min)) * graphRect.height;
      }
      _drawDashedLine(canvas, graphRect, 2, yD, ma8PricePaint);
      _drawText(
        canvas: canvas,
        position: Offset(graphRect.right, graphRect.bottom - yD),
        width: 60,
        text: formatCurrency(ma8),
        left: 0,
        top: -10,
        minHeight: 10,
        maxHeight: graphRect.height,
        minWidth: 10,
        maxWidth: graphRect.width + 8,
        textColor: Colors.pink[300]!.withOpacity(0.5)
      );

      // draw the ma13 price line
      if ((max-min) == 0) {
        yD = ((ma13 - min) / (min)) * graphRect.height;
      }
      else {
        yD = ((ma13 - min) / (max - min)) * graphRect.height;
      }
      _drawDashedLine(canvas, graphRect, 2, yD, ma13PricePaint);
      _drawText(
        canvas: canvas,
        position: Offset(graphRect.right, graphRect.bottom - yD),
        width: 60,
        text: formatCurrency(ma13),
        left: 0,
        top: -10,
        minHeight: 10,
        maxHeight: graphRect.height,
        minWidth: 10,
        maxWidth: graphRect.width + 8,
        textColor: Colors.blue[300]!.withOpacity(0.5)
      );
    }

    // once guidelines finished, we can draw the actual graph
    double gap = graphRect.width / (data.length.toDouble() - 1);
    double ratio;
    if ((max-min) == 0) {
      ratio = graphRect.height / min;      
    }
    else {
      ratio = graphRect.height / (max - min);
    }
    
    Path pUp = Path();
    Path pDown = Path();
    Path pNoChange = Path();
    bool isFirst = true;
    double prevPrice = double.minPositive;
    double xi = 0;
    double yi = 0;

    x = graphRect.left;
    y = 0;

    // loop thru data
    for (GraphData value in data) {
      y = 10 + graphRect.height - ((value.price - min) * ratio);

      // check if watchlist is not null
      if (watchlist != null) {
        if (watchlist!.isNotEmpty) {
          // check if this date is on the watchlist or not?
          if (watchlist!.containsKey(value.date)) {
            // check whether this is buy, sell, or both
            // we will draw a different triangle for buy, and sell
            if (watchlist![value.date.toLocal()] == 1 || watchlist![value.date.toLocal()] == 3) {
              Path triAnglePath = Path();
              
              xi = x - 3;
              yi = y - 6;
              triAnglePath.moveTo(xi, yi);
              
              xi = x + 3;
              triAnglePath.lineTo(xi, yi);

              yi = y;
              xi = x;
              triAnglePath.lineTo(xi, yi);

              triAnglePath.close();
              canvas.drawPath(triAnglePath, watchlistPaintBuy);
            } else if (watchlist![value.date.toLocal()] == 2 || watchlist![value.date.toLocal()] == 3) {
              Path triAnglePath = Path();
              
              xi = x + 3;
              yi = y + 6;
              triAnglePath.moveTo(xi, yi);
              
              xi = x - 3;
              triAnglePath.lineTo(xi, yi);

              yi = y;
              xi = x;
              triAnglePath.lineTo(xi, yi);

              triAnglePath.close();
              canvas.drawPath(triAnglePath, watchlistPaintSell);
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

  void _drawDashedLine(Canvas canvas, Rect graph, double width, double offset, Paint paint) {
    int j = 0;
    for (double i = graph.left; i <= graph.right; i = (i + width)) {
      if (j % 2 == 0) {
        canvas.drawLine(
          Offset(i, graph.bottom - offset), Offset((i + width), graph.bottom - offset),
          paint
        );
      }
      // odd and even to print the line
      j = j + 1;
    }
  }

  void _drawText({required Canvas canvas, required Offset position, required double width, required String text, required double left, required double top, required double minHeight, required double maxHeight, required double minWidth, required double maxWidth, Color? textColor}) {
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