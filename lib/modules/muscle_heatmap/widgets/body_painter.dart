import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart';

import '../models/body_part.dart';
import '../models/muscle_info.dart';
import '../utils/muscle_color.dart';

class BodyPainter extends CustomPainter {
  final List<BodyPart> muscles;
  final Map<String, MuscleInfo> muscleStates;

  BodyPainter(
      this.muscles,
      this.muscleStates,
      );

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    final paths = <Path>[];

    // تحويل كل الـ SVG إلى Paths
    for (final muscle in muscles) {
      for (final svg in muscle.left) {
        paths.add(parseSvgPathData(svg));
      }

      for (final svg in muscle.right) {
        paths.add(parseSvgPathData(svg));
      }
    }

    // حساب حدود الرسم
    Rect bounds = paths.first.getBounds();

    for (final path in paths.skip(1)) {
      bounds = bounds.expandToInclude(path.getBounds());
    }

    // أفضل Scale
    final scaleX = size.width / bounds.width;
    final scaleY = size.height / bounds.height;

    final scale = (scaleX < scaleY ? scaleX : scaleY) * 0.9;

    canvas.save();

    // توسيط الرسم
    canvas.translate(
      (size.width - bounds.width * scale) / 2,
      (size.height - bounds.height * scale) / 2,
    );

    canvas.scale(scale);

    // نقل الرسم لنقطة الأصل
    canvas.translate(-bounds.left, -bounds.top);

    int index = 0;

    for (final muscle in muscles) {
      final info = muscleStates[muscle.slug];

      paint.color = info == null
          ? Colors.grey.shade400
          : MuscleColor.fromInfo(info);

      for (final svg in muscle.left) {
        canvas.drawPath(paths[index++], paint);
      }

      for (final svg in muscle.right) {
        canvas.drawPath(paths[index++], paint);
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant BodyPainter oldDelegate) {
    return oldDelegate.muscleStates != muscleStates ||
        oldDelegate.muscles != muscles;
  }
}