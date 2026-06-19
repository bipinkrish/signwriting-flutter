import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:signwriting/signwriting.dart';

// Re-export the pure-Dart utilities (formats, metrics, mirror, joins,
// fingerspelling, mouthing, canonicalize) so a single import is enough.
export 'package:signwriting/signwriting.dart';

// Styles for the SignWriting fonts
const signWritingLinelFamily = TextStyle(fontFamily: 'SuttonSignWritingLine');

const signWritingFillFamily = TextStyle(fontFamily: 'SuttonSignWritingFill');

bool _isAscii(String s) => s.codeUnits.every((c) => c < 128);

/// Renders a single FSW (or SWU) sign to a [ui.Image].
///
/// Returns a 1x1 transparent image for a sign with no symbols (matching the
/// Python visualizer).
Future<ui.Image> _renderSignImage(
  String fsw, {
  bool trustBox = true,
  double size = 30.0,
  Color lineColor = Colors.black,
  Color fillColor = Colors.transparent,
}) async {
  // Accept SWU input (swu2fsw is a no-op for ASCII FSW).
  if (!_isAscii(fsw)) fsw = swu2fsw(fsw);

  final sign = fswToSign(fsw);

  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);

  if (sign.symbols.isEmpty) {
    return recorder.endRecording().toImage(1, 1);
  }

  // Minimum x/y across the sign's symbols.
  final minX = sign.symbols.map((s) => s.position.item1).reduce(min);
  final minY = sign.symbols.map((s) => s.position.item2).reduce(min);

  // Bottom-right corner: the FSW box if trusted, else the tight box computed
  // from the symbols' rendered sizes (matches Python's signwriting_box).
  int maxX, maxY;
  if (trustBox) {
    maxX = sign.box.position.item1;
    maxY = sign.box.position.item2;
  } else {
    final box = signwritingBox(sign);
    maxX = box.item1;
    maxY = box.item2;
  }

  final fillPainter = TextPainter(
    textDirection: TextDirection.ltr,
    textWidthBasis: TextWidthBasis.longestLine,
  );
  final linePainter = TextPainter(
    textDirection: TextDirection.ltr,
    textWidthBasis: TextWidthBasis.longestLine,
  );

  for (final symbol in sign.symbols) {
    final x = (symbol.position.item1 - minX).toDouble();
    final y = (symbol.position.item2 - minY).toDouble();
    final symbolId = key2id(symbol.symbol);

    fillPainter.text = TextSpan(
      text: symbolFill(symbolId),
      style: signWritingFillFamily.copyWith(fontSize: size, color: fillColor),
    );
    linePainter.text = TextSpan(
      text: symbolLine(symbolId),
      style: signWritingLinelFamily.copyWith(fontSize: size, color: lineColor),
    );

    fillPainter.layout();
    linePainter.layout();

    // Fill first, line on top (matches Python's draw order).
    fillPainter.paint(canvas, Offset(x, y));
    linePainter.paint(canvas, Offset(x, y));
  }

  final picture = recorder.endRecording();
  return picture.toImage(max(1, maxX - minX), max(1, maxY - minY));
}

Future<Uint8List> _encodePng(ui.Image image) async {
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  return data!.buffer.asUint8List();
}

/// Converts a SignWriting FSW or SWU string into a PNG image.
///
/// Parameters:
///   - fsw: the FSW string, or an SWU string (auto-detected and converted).
///   - trustBox: if true, use the bounding box from the FSW data; if false,
///     compute a tight box from the symbols' rendered sizes.
///   - size: symbol font size (defaults to 30, the reference size).
///   - lineColor / fillColor: line and fill colors.
///
/// Returns the PNG bytes, or an empty list for a sign with no symbols.
Future<Uint8List> signwritingToImage(
  String fsw, {
  bool trustBox = true,
  double size = 30.0,
  Color lineColor = Colors.black,
  Color fillColor = Colors.transparent,
}) async {
  final source = _isAscii(fsw) ? fsw : swu2fsw(fsw);
  if (fswToSign(source).symbols.isEmpty) {
    return Uint8List(0);
  }
  final image = await _renderSignImage(
    source,
    trustBox: trustBox,
    size: size,
    lineColor: lineColor,
    fillColor: fillColor,
  );
  return _encodePng(image);
}

/// Lays out direction for [signwritingsToImage].
enum SignWritingLayout { horizontal, vertical }

/// Renders multiple FSW/SWU signs and combines them into a single PNG, laid
/// out [direction]ally with a 20px gap and cross-axis centering (matches the
/// Python `layout_signwriting`).
Future<Uint8List> signwritingsToImage(
  List<String> fsws, {
  SignWritingLayout direction = SignWritingLayout.horizontal,
  bool trustBox = true,
  double size = 30.0,
  Color lineColor = Colors.black,
  Color fillColor = Colors.transparent,
}) async {
  if (fsws.isEmpty) return Uint8List(0);

  final images = <ui.Image>[];
  for (final fsw in fsws) {
    images.add(
      await _renderSignImage(
        fsw,
        trustBox: trustBox,
        size: size,
        lineColor: lineColor,
        fillColor: fillColor,
      ),
    );
  }

  const gap = 20;
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final paint = Paint();
  int totalWidth;
  int totalHeight;

  if (direction == SignWritingLayout.vertical) {
    final maxWidth = images.map((i) => i.width).reduce(max);
    totalWidth = maxWidth;
    totalHeight =
        images.fold<int>(0, (s, i) => s + i.height) + gap * (images.length - 1);
    int offset = 0;
    for (final img in images) {
      canvas.drawImage(
        img,
        Offset(((maxWidth - img.width) ~/ 2).toDouble(), offset.toDouble()),
        paint,
      );
      offset += img.height + gap;
    }
  } else {
    final maxHeight = images.map((i) => i.height).reduce(max);
    totalHeight = maxHeight;
    totalWidth =
        images.fold<int>(0, (s, i) => s + i.width) + gap * (images.length - 1);
    int offset = 0;
    for (final img in images) {
      canvas.drawImage(
        img,
        Offset(offset.toDouble(), ((maxHeight - img.height) ~/ 2).toDouble()),
        paint,
      );
      offset += img.width + gap;
    }
  }

  final combined = await recorder.endRecording().toImage(
        max(1, totalWidth),
        max(1, totalHeight),
      );
  return _encodePng(combined);
}
