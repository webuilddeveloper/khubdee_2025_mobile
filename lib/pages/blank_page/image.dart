import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class BlurFitImage extends StatelessWidget {
  const BlurFitImage({
    super.key,
    required this.provider,
    required this.height,
    this.width = double.infinity,
  });

  final ImageProvider provider;
  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ClipRect(
        child: Stack(
          fit: StackFit.expand,
          children: [
            // พื้นหลัง: รูปเดียวกัน เต็มกรอบ + เบลอ
            ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Image(image: provider, fit: BoxFit.cover),
            ),
            // overlay ให้มืดลงเล็กน้อย
            Container(color: Colors.black.withOpacity(0.15)),
            // รูปหลัก: แสดงครบทั้งรูป ไม่ถูกตัด
            Image(
              image: provider,
              fit: BoxFit.contain,
              errorBuilder:
                  (_, __, ___) => const Center(
                    child: Icon(
                      Icons.broken_image,
                      size: 50,
                      color: Colors.grey,
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
