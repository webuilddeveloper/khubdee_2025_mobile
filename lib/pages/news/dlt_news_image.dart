// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:KhubDeeDLT/shared/dlt_news_cache.dart';

// class DltNewsImage extends StatelessWidget {
//   const DltNewsImage({
//     super.key,
//     required this.url,
//     required this.height,
//     this.width,
//   });
//   final Uri? url;
//   final double height;
//   final double? width;

//   @override
//   Widget build(BuildContext context) {
//     Widget placeholder(String label) => ColoredBox(
//       color: const Color(0xFFF5F5F5),
//       child: Center(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Icon(Icons.image_outlined, size: 36, color: Colors.black26),
//             const SizedBox(height: 8),
//             Text(
//               label,
//               style: const TextStyle(
//                 fontFamily: 'Sarabun',
//                 fontSize: 12,
//                 color: Colors.black45,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//     return SizedBox(
//       width: width ?? double.infinity,
//       height: height,
//       child:
//           url == null
//               ? placeholder('ไม่มีภาพประกอบ')
//               : FutureBuilder<File>(
//                 future: DltNewsCache.instance.image(url!),
//                 initialData: DltNewsCache.instance.cachedImage(url!),
//                 builder: (context, snapshot) {
//                   if (snapshot.hasData) {
//                     return Image.file(
//                       snapshot.data!,
//                       fit: BoxFit.cover,
//                       errorBuilder:
//                           (_, __, ___) => placeholder('โหลดรูปไม่สำเร็จ'),
//                     );
//                   }
//                   if (snapshot.hasError) return placeholder('โหลดรูปไม่สำเร็จ');
//                   return const ColoredBox(
//                     color: Color(0xFFF5F5F5),
//                     child: Center(
//                       child: CircularProgressIndicator(strokeWidth: 2),
//                     ),
//                   );
//                 },
//               ),
//     );
//   }
// }

import 'dart:math' as math;

import 'package:flutter/material.dart';

class DltNewsImage extends StatelessWidget {
  const DltNewsImage({
    super.key,
    required this.url,
    required this.height,
    this.width,
    this.loading = false,
  });
  final Uri? url;
  final double height;
  final double? width;

  /// While true and [url] is null, show a spinner instead of "no image".
  final bool loading;

  @override
  Widget build(BuildContext context) {
    Widget placeholder(String label) => ColoredBox(
      color: const Color(0xFFF5F5F5),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.image_outlined, size: 36, color: Colors.black26),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Sarabun',
                fontSize: 12,
                color: Colors.black45,
              ),
            ),
          ],
        ),
      ),
    );
    // Decode at the displayed size (cards are capped at 600 logical px wide).
    final media = MediaQuery.of(context);
    final cacheWidth =
        (math.min(width ?? media.size.width, 600) * media.devicePixelRatio)
            .round();
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child:
          url == null
              ? (loading
                  ? const ColoredBox(
                    color: Color(0xFFF5F5F5),
                    child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                  : placeholder('ไม่มีภาพประกอบ'))
              : Image.network(
                url.toString(),
                fit: BoxFit.cover,
                cacheWidth: cacheWidth,
                gaplessPlayback: true,
                errorBuilder: (_, __, ___) => placeholder('โหลดรูปไม่สำเร็จ'),
                loadingBuilder:
                    (_, child, progress) =>
                        progress == null
                            ? child
                            : const ColoredBox(
                              color: Color(0xFFF5F5F5),
                              child: Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
              ),
    );
  }
}
