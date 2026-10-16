// import 'package:flutter/material.dart';
// import 'package:KhubDeeDLT/shared/dlt_news_service.dart';
// import 'package:KhubDeeDLT/pages/news/dlt_news_detail.dart';
// import 'package:KhubDeeDLT/pages/news/dlt_news_image.dart';

// /// Keeps the original news card's category bar, cover area and two-line title.
// class DltNewsCard extends StatelessWidget {
//   const DltNewsCard({super.key, required this.article, this.service});

//   final DltNewsService? service;

//   final DltNewsArticle article;

//   @override
//   Widget build(BuildContext context) {
//     return Align(
//       alignment: Alignment.center,
//       child: Container(
//         width: 600,
//         margin: const EdgeInsets.only(bottom: 5),
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(5),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.grey.withValues(alpha: 0.5),
//               blurRadius: 7,
//               offset: const Offset(0, 3),
//             ),
//           ],
//         ),
//         child: Material(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(5),
//           clipBehavior: Clip.antiAlias,
//           child: InkWell(
//             onTap:
//                 () => Navigator.of(context).push(
//                   MaterialPageRoute<void>(
//                     builder:
//                         (_) => DltNewsDetailPage(
//                           article: article,
//                           service: service,
//                         ),
//                   ),
//                 ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 Container(
//                   height: 55,
//                   color: Theme.of(context).primaryColor,
//                   padding: const EdgeInsets.fromLTRB(13, 5, 5, 5),
//                   alignment: Alignment.centerLeft,
//                   child: Text(
//                     article.category.title,
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontFamily: 'Sarabun',
//                     ),
//                   ),
//                 ),
//                 DltNewsImage(url: article.imageUrl, height: 200),
//                 Container(
//                   height: 60,
//                   padding: const EdgeInsets.all(5),
//                   alignment: Alignment.centerLeft,
//                   child: Text(
//                     article.title,
//                     maxLines: 2,
//                     overflow: TextOverflow.ellipsis,
//                     style: const TextStyle(
//                       fontFamily: 'Sarabun',
//                       fontSize: 15,
//                       fontWeight: FontWeight.normal,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:KhubDeeDLT/shared/dlt_news_service.dart';
import 'package:KhubDeeDLT/pages/news/dlt_news_detail.dart';
import 'package:KhubDeeDLT/pages/news/dlt_news_image.dart';

/// Keeps the original news card's category bar, cover area and two-line title.
class DltNewsCard extends StatelessWidget {
  const DltNewsCard({
    super.key,
    required this.article,
    this.service,
    this.imageLoading = false,
  });

  final DltNewsService? service;

  /// Show a spinner instead of the "no image" placeholder while the cover loads.
  final bool imageLoading;

  final DltNewsArticle article;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        width: 600,
        margin: const EdgeInsets.only(bottom: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.5),
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap:
                () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder:
                        (_) => DltNewsDetailPage(
                          article: article,
                          service: service,
                        ),
                  ),
                ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  height: 55,
                  color: Theme.of(context).primaryColor,
                  padding: const EdgeInsets.fromLTRB(13, 5, 5, 5),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    article.category.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'Sarabun',
                    ),
                  ),
                ),
                DltNewsImage(
                  url: article.imageUrl,
                  height: 200,
                  loading: imageLoading,
                ),
                Container(
                  constraints: const BoxConstraints(minHeight: 60),
                  padding: const EdgeInsets.all(5),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    article.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Sarabun',
                      fontSize: 15,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
