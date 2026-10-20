// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_html/flutter_html.dart';
// import 'package:share_plus/share_plus.dart';
// import 'package:KhubDeeDLT/component/button_close_back.dart';
// import 'package:KhubDeeDLT/component/gallery_view.dart';
// import 'package:KhubDeeDLT/pages/news/dlt_news_image.dart';
// import 'package:KhubDeeDLT/shared/dlt_news_runtime.dart';
// import 'package:KhubDeeDLT/shared/dlt_news_cache.dart';
// import 'package:KhubDeeDLT/shared/dlt_news_service.dart';

// class DltNewsDetailPage extends StatefulWidget {
//   const DltNewsDetailPage({super.key, required this.article, this.service});
//   final DltNewsArticle article;
//   final DltNewsService? service;

//   @override
//   State<DltNewsDetailPage> createState() => _DltNewsDetailPageState();
// }

// class _DltNewsDetailPageState extends State<DltNewsDetailPage> {
//   late final DltNewsService _service;
//   late Future<DltNewsDetail> _detail;

//   @override
//   void initState() {
//     super.initState();
//     _service = widget.service ?? DltNewsRuntime.instance.service;
//     _detail = _service.fetchDetail(widget.article);
//   }

//   void _retry() {
//     setState(() {
//       _detail = _service.fetchDetail(widget.article);
//     });
//   }

//   void _share() {
//     final box = context.findRenderObject() as RenderBox?;
//     Share.share(
//       '${widget.article.title}\n${widget.article.url}',
//       subject: widget.article.title,
//       sharePositionOrigin:
//           box == null ? null : box.localToGlobal(Offset.zero) & box.size,
//     );
//   }

//   void _viewImage(List<Uri> images, int index) {
//     showCupertinoDialog<void>(
//       context: context,
//       builder:
//           (_) => ImageViewer(
//             initialIndex: index,
//             imageProviders:
//                 images.map<ImageProvider>((url) {
//                   final file = DltNewsCache.instance.cachedImage(url);
//                   return file == null
//                       ? NetworkImage(url.toString())
//                       : FileImage(file);
//                 }).toList(),
//           ),
//     );
//   }

//   Widget _gallery(List<Uri> images) {
//     if (images.isEmpty) return const DltNewsImage(url: null, height: 360);
//     return Column(
//       children: [
//         InkWell(
//           onTap: () => _viewImage(images, 0),
//           child: DltNewsImage(url: images.first, height: 360),
//         ),
//         if (images.length > 1) ...[
//           const SizedBox(height: 5),
//           Row(
//             children: List.generate(images.length > 4 ? 3 : images.length - 1, (
//               i,
//             ) {
//               final index = i + 1;
//               return Expanded(
//                 child: Padding(
//                   padding: EdgeInsets.only(left: i == 0 ? 0 : 2),
//                   child: InkWell(
//                     onTap: () => _viewImage(images, index),
//                     child: Stack(
//                       alignment: Alignment.center,
//                       children: [
//                         DltNewsImage(
//                           url: images[index],
//                           height: MediaQuery.sizeOf(context).width / 3.035,
//                         ),
//                         if (index == 3 && images.length > 4)
//                           Positioned.fill(
//                             child: ColoredBox(
//                               color: Colors.black54,
//                               child: Center(
//                                 child: Text(
//                                   '+ ${images.length - 4}\nรูปภาพ',
//                                   textAlign: TextAlign.center,
//                                   style: const TextStyle(
//                                     color: Colors.white,
//                                     fontFamily: 'Sarabun',
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                       ],
//                     ),
//                   ),
//                 ),
//               );
//             }),
//           ),
//         ],
//       ],
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Stack(
//           children: [
//             FutureBuilder<DltNewsDetail>(
//               future: _detail,
//               initialData: _service.cachedDetail(widget.article),
//               builder: (context, snapshot) {
//                 final detail = snapshot.data;
//                 final article = widget.article;
//                 final date = article.publishedAt;
//                 final dateLabel =
//                     detail?.dateLabel ??
//                     (date == null
//                         ? ''
//                         : '${date.day}/${date.month}/${date.year + 543}');
//                 return ListView(
//                   padding: EdgeInsets.zero,
//                   children: [
//                     _gallery(
//                       detail?.images ??
//                           [if (article.imageUrl != null) article.imageUrl!],
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.fromLTRB(10, 10, 50, 0),
//                       child: Text(
//                         article.title,
//                         style: const TextStyle(
//                           fontSize: 18,
//                           fontFamily: 'Sarabun',
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 10,
//                         vertical: 10,
//                       ),
//                       child: Row(
//                         children: [
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 const Text(
//                                   'กรมการขนส่งทางบก',
//                                   style: TextStyle(
//                                     fontSize: 15,
//                                     fontFamily: 'Sarabun',
//                                     fontWeight: FontWeight.w300,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 4),
//                                 Text(
//                                   [
//                                         dateLabel,
//                                         if (detail?.views != null)
//                                           'เข้าชม ${detail!.views} ครั้ง',
//                                       ]
//                                       .where((value) => value.isNotEmpty)
//                                       .join(' | '),
//                                   style: const TextStyle(
//                                     fontSize: 10,
//                                     fontFamily: 'Sarabun',
//                                     fontWeight: FontWeight.w300,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           IconButton(
//                             tooltip: 'แชร์ข่าว',
//                             onPressed: _share,
//                             icon: Image.asset(
//                               'assets/images/share.png',
//                               width: 55,
//                               height: 35,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     if (snapshot.connectionState != ConnectionState.done &&
//                         detail == null)
//                       const Padding(
//                         padding: EdgeInsets.all(24),
//                         child: Center(child: CircularProgressIndicator()),
//                       )
//                     else if (snapshot.hasError)
//                       Padding(
//                         padding: const EdgeInsets.all(20),
//                         child: Column(
//                           children: [
//                             const Text('โหลดรายละเอียดข่าวไม่สำเร็จ'),
//                             TextButton.icon(
//                               onPressed: _retry,
//                               icon: const Icon(Icons.refresh),
//                               label: const Text('ลองอีกครั้ง'),
//                             ),
//                           ],
//                         ),
//                       )
//                     else if (detail != null)
//                       Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 10),
//                         child: Html(
//                           data: detail.contentHtml,
//                           style: {
//                             'body': Style(
//                               fontFamily: 'Sarabun',
//                               fontSize: FontSize(16),
//                               margin: Margins.zero,
//                             ),
//                           },
//                         ),
//                       ),
//                     const SizedBox(height: 20),
//                   ],
//                 );
//               },
//             ),
//             Positioned(right: 0, top: 5, child: buttonCloseBack(context)),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'dart:math' as math;

import 'package:KhubDeeDLT/pages/blank_page/image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:KhubDeeDLT/component/button_close_back.dart';
import 'package:KhubDeeDLT/component/gallery_view.dart';
import 'package:KhubDeeDLT/pages/news/dlt_news_image.dart';
import 'package:KhubDeeDLT/shared/dlt_news_page_loader.dart';
import 'package:KhubDeeDLT/shared/dlt_news_service.dart';

class DltNewsDetailPage extends StatefulWidget {
  const DltNewsDetailPage({super.key, required this.article, this.service});
  final DltNewsArticle article;
  final DltNewsService? service;

  @override
  State<DltNewsDetailPage> createState() => _DltNewsDetailPageState();
}

class _DltNewsDetailPageState extends State<DltNewsDetailPage> {
  late final DltNewsService _service;
  late Future<DltNewsDetail> _detail;

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? sharedDltNewsService;
    _detail = _service.fetchDetail(widget.article);
  }

  void _retry() {
    setState(() {
      _detail = _service.fetchDetail(widget.article);
    });
  }

  /// [buttonContext] is the share button's own context so the iPad popover
  /// anchors to the button instead of the whole page.
  void _share(BuildContext buttonContext) {
    final box = buttonContext.findRenderObject() as RenderBox?;
    Share.share(
      '${widget.article.title}\n${widget.article.url}',
      subject: widget.article.title,
      sharePositionOrigin:
          box != null && box.hasSize
              ? box.localToGlobal(Offset.zero) & box.size
              : null,
    );
  }

  Future<void> _openLink(String? href) async {
    final uri = href == null ? null : Uri.tryParse(href);
    if (uri == null || (uri.scheme != 'https' && uri.scheme != 'http')) return;
    var opened = false;
    try {
      opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      opened = false;
    }
    if (!opened && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('เปิดลิงก์ไม่ได้')));
    }
  }

  void _viewImage(List<Uri> images, int index) {
    showCupertinoDialog<void>(
      context: context,
      builder:
          (_) => ImageViewer(
            initialIndex: index,
            imageProviders:
                images.map((url) => NetworkImage(url.toString())).toList(),
          ),
    );
  }

  // Widget _gallery(List<Uri> images) {
  //   if (images.isEmpty) return const DltNewsImage(url: null, height: 360);
  //   final thumbCount = images.length > 4 ? 3 : images.length - 1;
  //   final thumbHeight = math.min(
  //     140.0,
  //     MediaQuery.sizeOf(context).width / math.max(thumbCount, 1),
  //   );
  //   return Column(
  //     children: [
  //       InkWell(
  //         onTap: () => _viewImage(images, 0),
  //         child: DltNewsImage(url: images.first, height: 360),
  //       ),
  //       if (images.length > 1) ...[
  //         const SizedBox(height: 5),
  //         Row(
  //           children: List.generate(thumbCount, (i) {
  //             final index = i + 1;
  //             return Expanded(
  //               child: Padding(
  //                 padding: EdgeInsets.only(left: i == 0 ? 0 : 2),
  //                 child: InkWell(
  //                   onTap: () => _viewImage(images, index),
  //                   child: Stack(
  //                     alignment: Alignment.center,
  //                     children: [
  //                       DltNewsImage(url: images[index], height: thumbHeight),
  //                       if (index == 3 && images.length > 4)
  //                         Positioned.fill(
  //                           child: ColoredBox(
  //                             color: Colors.black54,
  //                             child: Center(
  //                               child: Text(
  //                                 '+ ${images.length - 4}\nรูปภาพ',
  //                                 textAlign: TextAlign.center,
  //                                 style: const TextStyle(
  //                                   color: Colors.white,
  //                                   fontFamily: 'Sarabun',
  //                                 ),
  //                               ),
  //                             ),
  //                           ),
  //                         ),
  //                     ],
  //                   ),
  //                 ),
  //               ),
  //             );
  //           }),
  //         ),
  //       ],
  //     ],
  //   );
  // }

  Widget _gallery(List<Uri> images) {
    if (images.isEmpty) return const DltNewsImage(url: null, height: 360);
    final thumbCount = images.length > 4 ? 3 : images.length - 1;
    final thumbHeight = math.min(
      140.0,
      MediaQuery.sizeOf(context).width / math.max(thumbCount, 1),
    );
    return Column(
      children: [
        InkWell(
          onTap: () => _viewImage(images, 0),
          child: BlurFitImage(
            provider: NetworkImage(images.first.toString()),
            height: 360,
          ),
        ),
        if (images.length > 1) ...[
          const SizedBox(height: 5),
          Row(
            children: List.generate(thumbCount, (i) {
              final index = i + 1;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: i == 0 ? 0 : 2),
                  child: InkWell(
                    onTap: () => _viewImage(images, index),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        BlurFitImage(
                          provider: NetworkImage(images[index].toString()),
                          height: thumbHeight,
                        ),
                        if (index == 3 && images.length > 4)
                          Positioned.fill(
                            child: ColoredBox(
                              color: Colors.black54,
                              child: Center(
                                child: Text(
                                  '+ ${images.length - 4}\nรูปภาพ',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Sarabun',
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            FutureBuilder<DltNewsDetail>(
              future: _detail,
              initialData: _service.cachedDetail(widget.article),
              builder: (context, snapshot) {
                final detail = snapshot.data;
                final loading =
                    snapshot.connectionState != ConnectionState.done;
                final failed = detail == null && !loading && snapshot.hasError;
                final article = widget.article;
                final cover = _service.cachedImage(article);
                final date = article.publishedAt;
                final dateLabel =
                    detail?.dateLabel ??
                    (date == null
                        ? ''
                        : '${date.day}/${date.month}/${date.year + 543}');
                final images =
                    detail != null && detail.images.isNotEmpty
                        ? detail.images
                        : <Uri>[if (cover != null) cover];
                return ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _gallery(images),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 10, 50, 0),
                      child: Text(
                        article.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontFamily: 'Sarabun',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'กรมการขนส่งทางบก',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontFamily: 'Sarabun',
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  [
                                        dateLabel,
                                        if (detail?.views != null)
                                          'เข้าชม ${detail!.views} ครั้ง',
                                      ]
                                      .where((value) => value.isNotEmpty)
                                      .join(' | '),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontFamily: 'Sarabun',
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Builder(
                            builder:
                                (buttonContext) => IconButton(
                                  tooltip: 'แชร์ข่าว',
                                  onPressed: () => _share(buttonContext),
                                  icon: Image.asset(
                                    'assets/images/share.png',
                                    width: 55,
                                    height: 35,
                                  ),
                                ),
                          ),
                        ],
                      ),
                    ),
                    if (detail != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Html(
                          data: detail.contentHtml,
                          onLinkTap: (url, _, __) => _openLink(url),
                          style: {
                            'body': Style(
                              fontFamily: 'Sarabun',
                              fontSize: FontSize(16),
                              margin: Margins.zero,
                            ),
                          },
                        ),
                      )
                    else if (failed)
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            const Text('โหลดรายละเอียดข่าวไม่สำเร็จ'),
                            TextButton.icon(
                              onPressed: _retry,
                              icon: const Icon(Icons.refresh),
                              label: const Text('ลองอีกครั้ง'),
                            ),
                          ],
                        ),
                      )
                    else
                      const Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    const SizedBox(height: 20),
                  ],
                );
              },
            ),
            Positioned(right: 0, top: 5, child: buttonCloseBack(context)),
          ],
        ),
      ),
    );
  }
}
