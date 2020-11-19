/*
 * Copyright (C) 2017, David PHAM-VAN <dev.nfet.net@gmail.com>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// ignore_for_file: omit_local_variable_types

part of widget;

class BarDataSet extends Dataset {
  BarDataSet({
    @required this.data,
    String legend,
    this.borderColor,
    this.borderWidth = 1.5,
    PdfColor color = PdfColors.blue,
    bool drawBorder,
    this.drawSurface = true,
    this.surfaceOpacity = 1,
    this.width = 10,
    this.offset = 0,
    this.axis = Axis.horizontal,
  })  : drawBorder = drawBorder ?? borderColor != null && color != borderColor,
        assert((drawBorder ?? borderColor != null && color != borderColor) ||
            drawSurface),
        assert(axis != null),
        super(
          legend: legend,
          color: color,
        );

  final List<LineChartValue> data;

  final bool drawBorder;
  final PdfColor borderColor;
  final double borderWidth;

  final bool drawSurface;

  final double surfaceOpacity;

  final double width;
  final double offset;

  final Axis axis;

  void _drawSurface(Context context, ChartGrid grid, LineChartValue value) {
    switch (axis) {
      case Axis.horizontal:
        final double y = (grid is CartesianGrid) ? grid.xAxisOffset : 0;
        final PdfPoint p = grid.toChart(value.point);
        final double x = p.x + offset - width / 2;
        final double height = p.y - y;

        context.canvas.drawRect(x, y, width, height);
        break;
      case Axis.vertical:
        final double x = (grid is CartesianGrid) ? grid.yAxisOffset : 0;
        final PdfPoint p = grid.toChart(value.point);
        final double y = p.y + offset - width / 2;
        final double height = p.x - x;

        context.canvas.drawRect(x, y, height, width);
        break;
    }
  }

  @override
  void layout(Context context, BoxConstraints constraints,
      {bool parentUsesSize = false}) {
    box = PdfRect.fromPoints(PdfPoint.zero, constraints.biggest);
  }

  @override
  void paint(Context context) {
    super.paint(context);

    if (data.isEmpty) {
      return;
    }

    final ChartGrid grid = Chart.of(context).grid;

    if (drawSurface) {
      for (final LineChartValue value in data) {
        _drawSurface(context, grid, value);
      }

      if (surfaceOpacity != 1) {
        context.canvas
          ..saveContext()
          ..setGraphicState(
            PdfGraphicState(opacity: surfaceOpacity),
          );
      }

      context.canvas
        ..setFillColor(color)
        ..fillPath();

      if (surfaceOpacity != 1) {
        context.canvas.restoreContext();
      }
    }

    if (drawBorder) {
      for (final LineChartValue value in data) {
        _drawSurface(context, grid, value);
      }

      context.canvas
        ..setStrokeColor(borderColor ?? color)
        ..setLineWidth(borderWidth)
        ..strokePath();
    }
  }
}
