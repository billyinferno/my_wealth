import 'package:flutter/material.dart';
import 'package:my_wealth/_index.g.dart';

class PerformanceData {
  final DateTime date;
  final double gain;
  final double total;

  PerformanceData({required this.date, required this.gain, required this.total});
}
class ChartProperties {
  final double min;
  final double max;
  final double gap;
  final double norm;

  ChartProperties({required this.min, required this.max, required this.gap, required this.norm});
}

class PerformanceChartPainter extends CustomPainter {
  final List<PerformanceData> data;
  final ChartProperties dataProperties;
  final List<PerformanceData>? compare;
  final ChartProperties? compareProperties;
  final bool? showInvestment;
  final ChartProperties? investmentProperties;
  final Map<DateTime, int>? watchlist;
  final int? datePrintOffset;
  final String? dateFormat;


  PerformanceChartPainter({
    required this.data,
    required this.dataProperties,
    this.compare,
    this.compareProperties,
    required this.showInvestment,
    required this.investmentProperties,
    this.datePrintOffset,
    this.dateFormat,
    this.watchlist,
  });

  // draw the path
  final Paint dpUp = Paint()
    ..color = Colors.green
    ..strokeWidth = 1.0
    ..style = PaintingStyle.stroke;

  final Paint dpInvestment = Paint()
    ..color = extendedDark
    ..strokeWidth = 1.0
    ..style = PaintingStyle.stroke;

  final Paint dpCompare = Paint()
    ..color = accentDark.withOpacity(0.7)
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

  final Paint watchlistPaintBuy = Paint()..color = accentColor;

  final Paint watchlistPaintSell = Paint()..color = extendedLight;

  final Paint watchlistPaintBuySell = Paint()..color = Colors.white;

  @override
  void paint(Canvas canvas, Size size) {
    // at least investment or data shouldn't be empty
    if (data.isNotEmpty) {
      _drawBorder(canvas: canvas, size: size);
    }
    
    // if we have investment data, draw the investment data
    if ((showInvestment ?? false) && (investmentProperties != null)) {
      _drawInvestmentLine(canvas: canvas, size: size);
    }

    // check if we have compare or not?
    if ((compare ?? []).isNotEmpty) {
      // draw the line for compare
      _drawCompare(canvas: canvas, size: size);
    }

    // draw the line if we have data
    if (data.isNotEmpty) {
      _drawLine(canvas: canvas, size: size);
    }

    // draw the box
    _drawBox(canvas: canvas, size: size);
  }

  @override
  bool shouldRepaint(PerformanceChartPainter oldDelegate) {
    // check if the data is the same or not?
    return listEquals<PerformanceData>(oldDelegate.data, data);
  }

  void _drawBorder({
    required Canvas canvas,
    required Size size
  }) {
    // create the rect that we will use as a guide for the graph
    Rect graphRect = Rect.fromLTRB(10, 10, size.width - 10, size.height - 30);

    // calculate the xLeft and the width guide that will be used to move between
    // one point to another point in the graph.
    int count = data.length;
    double xLeft = graphRect.left;
    double guideW = graphRect.size.width / (count - 1);

    // check for the date print offset
    int currentDatePrintOffset = (datePrintOffset ?? 10);
    // check if data length is less or equal to 10, if so then just make the
    // curent date print offset into 1, which means we will print all the
    // date offset, since the graph will allow at least to have 10 data to be
    // presented on the graph.
    if (count <= 10) {
      currentDatePrintOffset = 1;
    }

    for (int i = 0; i < data.length; i++) {
      Offset p1 = Offset(xLeft, graphRect.bottom);
      Offset p2 = Offset(xLeft, graphRect.top);

      if (i % currentDatePrintOffset == 0 && i > 0) {
        canvas.drawLine(p1, p2, graphRectBorderWhite);
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
    }
  }

  void _drawLine({
    required Canvas canvas,
    required Size size
  }) {
    double x;
    double y;
    double left;

    // create the rect that we will use as a guide for the graph
    Rect graphRect = Rect.fromLTRB(10, 10, size.width - 10, size.height - 30);

    // calculate the xLeft and the width guide that will be used to move between
    // one point to another point in the graph.
    int count = data.length;
    double xLeft = graphRect.left;
    double guideW = graphRect.size.width / (count - 1);

    // check for the date print offset
    int currentDatePrintOffset = (datePrintOffset ?? 10);
    // check if data length is less or equal to 10, if so then just make the
    // curent date print offset into 1, which means we will print all the
    // date offset, since the graph will allow at least to have 10 data to be
    // presented on the graph.
    if (count <= 10) {
      currentDatePrintOffset = 1;
    }

    for (int i = 0; i < data.length; i++) {
      if (i % currentDatePrintOffset == 0 && i > 0) {
        
        // calculate the left here
        // defaulted to -15, this is middle of the line
        left = -15;
        if (i == (data.length - 1)) {
          // if this is in the end, then instead of -15, put it as -30
          left = -30;
        }

        // now check if the data length is > 10, and i is equal to end of data
        // then no need to print the text
        if (i == (data.length - 1) && i > 10) {
          // skip
        }
        else {
          // canvas.drawLine(p1, p2, graphRectBorderWhite);
          _drawText(
            canvas: canvas,
            position: Offset(xLeft, graphRect.bottom),
            width: 60,
            text: formatDate(date: data[i].date, format: (dateFormat ?? "dd/MM")),
            left: left,
            top: 5,
            minHeight: 0,
            maxHeight: graphRect.height + 20,
            minWidth: 0,
            maxWidth: graphRect.width + 20
          );
        }
      }

      // next
      xLeft += guideW;
    }

    // draw horizontal line
    double yD = graphRect.size.height / 4;
    for (int i = 0; i < 4; i++) {
      double currVal = dataProperties.min + (((dataProperties.max - dataProperties.min) / 4.0) * i.toDouble());
      _drawText(
        canvas: canvas,
        position: Offset(graphRect.left, graphRect.bottom - (yD * i) - 5),
        width: 60,
        text: formatCurrency(amount: currVal),
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
      text: formatCurrency(amount: dataProperties.max),
      left: 0,
      top: -5,
      minHeight: 10,
      maxHeight: graphRect.height,
      minWidth: 10,
      maxWidth: graphRect.width
    );

    Path pUp = Path();
    Path pDown = Path();
    Path pNoChange = Path();
    bool isFirst = true;
    double ratio = 0;
    double w = graphRect.width / (data.length.toDouble() - 1);
    double xi = 0;
    double yi = 0;

    if (dataProperties.gap > 0) {
      ratio = graphRect.height / dataProperties.gap;
    }

    x = graphRect.left;
    y = 0;

    // loop thru data
    for (PerformanceData value in data) {
      y = 10 + graphRect.height - ((value.gain + dataProperties.norm) * ratio);

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
      if (watchlist!.isNotEmpty) {
        // check if this date is on the watchlist or not?
        if (watchlist!.containsKey(value.date.toLocal())) {
          // got the date, so now we can just draw the circle in this position
          // if we doing buy and sell all in one day
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

      // next column
      x += w;
    }

    // draw the line chart
    canvas.drawPath(pUp, dpUp);
    canvas.drawPath(pDown, dpDown);
    canvas.drawPath(pNoChange, dpNoChange);
  }

  void _drawInvestmentLine({
    required Canvas canvas,
    required Size size
  }) {
    // create the rect that we will use as a guide for the graph
    Rect graphRect = Rect.fromLTRB(10, 10, size.width - 10, size.height - 30);

    // check if min and max is the same?
    // if the same then we can just draw the line on the bottom
    // and just draw the text on the right side
    if (investmentProperties!.min == investmentProperties!.max) {
      _drawText(
        canvas: canvas,
        position: Offset(graphRect.left, graphRect.bottom),
        width: 60,
        text: formatCurrency(amount: investmentProperties!.max),
        left: graphRect.right,
        top: -5,
        minHeight: 10,
        maxHeight: graphRect.height,
        minWidth: 10,
        maxWidth: graphRect.width
      );
    }
    else {
      double yD = graphRect.size.height / 4;
      for (int i = 0; i < 4; i++) {    
        double currVal = investmentProperties!.min + (((investmentProperties!.max - investmentProperties!.min) / 4.0) * i.toDouble());
        _drawText(
          canvas: canvas,
          position: Offset(graphRect.left, graphRect.bottom - (yD * i) - 5),
          width: 60,
          text: formatCurrency(amount: currVal),
          left: graphRect.right,
          top: -5,
          minHeight: 10,
          maxHeight: graphRect.height,
          minWidth: 10,
          maxWidth: graphRect.width,
          textColor: extendedLight.withOpacity(0.3)
        );
      }

      // put the max price
      _drawText(
        canvas: canvas,
        position: Offset(graphRect.left, graphRect.top),
        width: 60,
        text: formatCurrency(amount: investmentProperties!.max),
        left: graphRect.right,
        top: -5,
        minHeight: 10,
        maxHeight: graphRect.height,
        minWidth: 10,
        maxWidth: graphRect.width,
        textColor: extendedLight.withOpacity(0.3)
      );
    }

    double x;
    double y;

    Path pInvestment = Path();
    bool isFirst = true;
    double ratio = 0;
    double w = graphRect.width / (data.length.toDouble() - 1);

    if (investmentProperties!.gap > 0) {
      ratio = graphRect.height / investmentProperties!.gap;
    }

    x = graphRect.left;
    y = 0;

    // loop thru data
    for (PerformanceData value in data) {
      y = 10 + graphRect.height - ((value.total + investmentProperties!.norm) * ratio);

      // check whether this is the first data?
      if (isFirst) {
        pInvestment.moveTo(x, y);
        isFirst = false;
      } else {
        pInvestment.lineTo(x, y);
      }

      // next column
      x += w;
    }

    // draw the line chart
    canvas.drawPath(pInvestment, dpInvestment);
  }

  void _drawCompare({
    required Canvas canvas,
    required Size size
  }) {
    // create the rect that we will use as a guide for the graph
    Rect graphRect = Rect.fromLTRB(10, 10, size.width - 10, size.height - 30);

    double x;
    double y;

    Path pCompare = Path();
    bool isFirst = true;
    double ratio = 0;
    double w = graphRect.width / (compare!.length.toDouble() - 1);

    if (compareProperties!.gap > 0) {
      ratio = graphRect.height / compareProperties!.gap;
    }

    x = graphRect.left;
    y = 0;

    // loop thru data
    for (PerformanceData value in compare!) {
      y = 10 + graphRect.height - ((value.total + compareProperties!.norm) * ratio);
      // print("Total: ${value.total}, Norm: ${compareProperties!.norm}");
      // print("Calc: ${((value.total + compareProperties!.norm) * ratio)}");

      // check whether this is the first data?
      if (isFirst) {
        pCompare.moveTo(x, y);
        isFirst = false;
      } else {
        pCompare.lineTo(x, y);
      }

      // next column
      x += w;
    }

    // draw the line chart
    canvas.drawPath(pCompare, dpCompare); 
  }

  void _drawBox({
    required Canvas canvas,
    required Size size
  }) {
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

  void _drawText({
    required Canvas canvas,
    required Offset position,
    required double width,
    required String text,
    required double left,
    required double top,
    required double minHeight,
    required double maxHeight,
    required double minWidth,
    required double maxWidth,
    Color? textColor
  }) {
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
      textAlign: TextAlign.center,
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
