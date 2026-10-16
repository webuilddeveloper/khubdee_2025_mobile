// import 'package:flutter/material.dart';
// import 'package:KhubDeeDLT/shared/dlt_news_runtime.dart';
// import 'package:KhubDeeDLT/component/header.dart';
// import 'package:KhubDeeDLT/component/key_search.dart';
// import 'package:KhubDeeDLT/component/tab_category.dart';
// import 'package:KhubDeeDLT/pages/news/dlt_news_batch.dart';
// import 'package:KhubDeeDLT/shared/dlt_news_service.dart';

// class NewsList extends StatefulWidget {
//   const NewsList({super.key, required this.title, this.service});

//   final String title;
//   final DltNewsService? service;

//   @override
//   State<NewsList> createState() => _NewsListState();
// }

// class _NewsListState extends State<NewsList> {
//   late final DltNewsService _service;
//   late Future<List<DltNewsArticle>> _news;
//   DltNewsCategory _category = DltNewsCategory.publicNews;
//   String _query = '';
//   int _visibleCount = 5;
//   int _version = 0;
//   final Future<List<Map<String, String>>> _categories = Future.value(
//     DltNewsCategory.values
//         .map((category) => {'code': category.name, 'title': category.title})
//         .toList(),
//   );

//   @override
//   void initState() {
//     super.initState();
//     _service = widget.service ?? DltNewsRuntime.instance.service;
//     _news = _fetch(_category);
//   }

//   Future<List<DltNewsArticle>> _fetch(
//     DltNewsCategory category, {
//     bool refresh = false,
//   }) =>
//       widget.service != null
//           ? _service.fetch(category)
//           : DltNewsRuntime.instance.fetch(category, refresh: refresh);

//   Future<void> _refresh() async {
//     _service.clearImages();
//     final news = _fetch(_category, refresh: true);
//     setState(() {
//       _news = news;
//       _visibleCount = 5;
//       _version++;
//     });
//     try {
//       await news;
//     } catch (_) {
//       // FutureBuilder renders an error and retry action.
//     }
//   }

//   void _selectCategory(DltNewsCategory category) {
//     if (category == _category) return;
//     setState(() {
//       _category = category;
//       _visibleCount = 5;
//       _version++;
//       _news = _fetch(category);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       extendBodyBehindAppBar: true,
//       backgroundColor: Colors.white,
//       appBar: header(
//         context,
//         () => Navigator.of(context).pop(),
//         title: widget.title,
//         isBg: false,
//       ),
//       body: Stack(
//         children: [
//           Positioned(
//             top: 0,
//             left: 0,
//             right: 0,
//             child: ShaderMask(
//               shaderCallback:
//                   (rect) => const LinearGradient(
//                     begin: Alignment.topCenter,
//                     end: Alignment.bottomCenter,
//                     colors: [Colors.white, Colors.transparent],
//                   ).createShader(rect),
//               blendMode: BlendMode.dstIn,
//               child: Image.asset(
//                 'assets/bg_header.png',
//                 width: double.infinity,
//                 fit: BoxFit.cover,
//                 height: 250,
//               ),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.only(top: kToolbarHeight + 64),
//             child: Column(
//               children: [
//                 CategorySelector(
//                   model: _categories,
//                   code: _category.name,
//                   onChange:
//                       (code) =>
//                           _selectCategory(DltNewsCategory.values.byName(code)),
//                 ),
//                 const SizedBox(height: 5),
//                 KeySearch(
//                   show: true,
//                   onKeySearchChange: (value) {
//                     setState(() {
//                       _query = value.trim();
//                       _visibleCount = 5;
//                     });
//                   },
//                 ),
//                 Expanded(
//                   child: RefreshIndicator(
//                     onRefresh: _refresh,
//                     child: FutureBuilder<List<DltNewsArticle>>(
//                       future: _news,
//                       builder: (context, snapshot) {
//                         if (snapshot.connectionState != ConnectionState.done) {
//                           return ListView(
//                             physics: const AlwaysScrollableScrollPhysics(),
//                             children: const [
//                               SizedBox(height: 100),
//                               Center(child: CircularProgressIndicator()),
//                             ],
//                           );
//                         }
//                         if (snapshot.hasError) {
//                           return ListView(
//                             physics: const AlwaysScrollableScrollPhysics(),
//                             padding: const EdgeInsets.all(24),
//                             children: [
//                               const SizedBox(height: 48),
//                               const Icon(Icons.wifi_off, size: 40),
//                               const SizedBox(height: 16),
//                               const Text(
//                                 'โหลดข่าวไม่สำเร็จ',
//                                 textAlign: TextAlign.center,
//                               ),
//                               TextButton(
//                                 onPressed: _refresh,
//                                 child: const Text('ลองอีกครั้ง'),
//                               ),
//                             ],
//                           );
//                         }
//                         final query = _query.toLowerCase();
//                         final articles =
//                             (snapshot.data ?? <DltNewsArticle>[]).where((
//                               article,
//                             ) {
//                               return article.title.toLowerCase().contains(
//                                     query,
//                                   ) ||
//                                   article.description.toLowerCase().contains(
//                                     query,
//                                   );
//                             }).toList();
//                         return ListView(
//                           physics: const AlwaysScrollableScrollPhysics(),
//                           padding: const EdgeInsets.fromLTRB(10, 25, 10, 16),
//                           children: [
//                             if (articles.isEmpty)
//                               Padding(
//                                 padding: const EdgeInsets.symmetric(
//                                   vertical: 48,
//                                 ),
//                                 child: Text(
//                                   _query.isEmpty
//                                       ? 'ยังไม่มีข่าวในหมวดนี้'
//                                       : 'ไม่พบข่าวที่ค้นหา',
//                                   textAlign: TextAlign.center,
//                                 ),
//                               ),
//                             for (
//                               var offset = 0;
//                               offset < articles.length &&
//                                   offset < _visibleCount;
//                               offset += 5
//                             )
//                               DltNewsBatch(
//                                 key: ValueKey('$_version:$_query:$offset'),
//                                 articles:
//                                     articles.skip(offset).take(5).toList(),
//                                 service: _service,
//                               ),
//                             if (_visibleCount < articles.length)
//                               OutlinedButton(
//                                 onPressed:
//                                     () => setState(() => _visibleCount += 5),
//                                 child: const Text('โหลดข่าวเพิ่มเติม'),
//                               ),
//                           ],
//                         );
//                       },
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:KhubDeeDLT/shared/dlt_news_page_loader.dart';
import 'package:KhubDeeDLT/component/header.dart';
import 'package:KhubDeeDLT/component/key_search.dart';
import 'package:KhubDeeDLT/component/tab_category.dart';
import 'package:KhubDeeDLT/pages/news/dlt_news_card.dart';
import 'package:KhubDeeDLT/shared/dlt_news_service.dart';

class NewsList extends StatefulWidget {
  const NewsList({super.key, required this.title, this.service});

  final String title;
  final DltNewsService? service;

  @override
  State<NewsList> createState() => _NewsListState();
}

class _NewsListState extends State<NewsList> {
  static const _pageSize = 5;

  late final DltNewsService _service;
  late Future<List<DltNewsArticle>> _news;
  DltNewsCategory _category = DltNewsCategory.publicNews;
  String _query = '';
  Timer? _debounce;
  int _visibleCount = _pageSize;

  /// Article urls whose cover has been requested (or is being requested).
  final _requested = <String>{};

  /// Article urls whose cover request has finished (success or failure).
  final _settled = <String>{};

  /// Article urls already queued for background detail prefetch.
  final _prefetched = <String>{};
  bool _imageError = false;

  final Future<List<Map<String, String>>> _categories = Future.value(
    DltNewsCategory.values
        .map((category) => {'code': category.name, 'title': category.title})
        .toList(),
  );

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? sharedDltNewsService;
    // Read the listing page (covers) in parallel with the RSS request.
    _service.prefetchCovers(_category);
    _news = _service.fetch(_category);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _refresh() async {
    _service.clearImages();
    _requested.clear();
    _settled.clear();
    _prefetched.clear();
    _service.prefetchCovers(_category);
    final news = _service.fetch(_category);
    setState(() {
      _news = news;
      _visibleCount = _pageSize;
      _imageError = false;
    });
    try {
      await news;
    } catch (_) {
      // FutureBuilder renders an error and retry action.
    }
  }

  void _selectCategory(DltNewsCategory category) {
    if (category == _category) return;
    _service.prefetchCovers(category);
    setState(() {
      _category = category;
      _visibleCount = _pageSize;
      _imageError = false;
      _news = _service.fetch(category);
    });
  }

  void _onSearch(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      setState(() {
        _query = value.trim();
        _visibleCount = _pageSize;
      });
    });
  }

  /// Loads covers for the visible articles, [_pageSize] at a time. Results
  /// land in the service cache, so cards simply read them on rebuild and
  /// searching/filtering never triggers a reload.
  void _loadImages(List<DltNewsArticle> visible) {
    final pending =
        visible
            .where(
              (a) =>
                  _service.cachedImage(a) == null &&
                  _requested.add(a.url.toString()),
            )
            .toList();
    final prefetch =
        visible.where((a) => _prefetched.add(a.url.toString())).toList();
    // Covers first; article details are warmed afterwards in the background
    // so tapping a card does not have to wait for the page to render.
    _loadChunks(pending).whenComplete(() {
      if (mounted) _service.prefetchDetails(prefetch);
    });
  }

  Future<void> _loadChunks(List<DltNewsArticle> pending) async {
    for (var i = 0; i < pending.length; i += _pageSize) {
      final chunk = pending.skip(i).take(_pageSize).toList();
      try {
        await _service.loadImages(chunk);
        if (!mounted) return;
        setState(() {
          _settled.addAll(chunk.map((a) => a.url.toString()));
        });
      } catch (_) {
        if (!mounted) return;
        setState(() {
          _imageError = true;
          for (final article in pending.skip(i)) {
            final key = article.url.toString();
            _requested.remove(key);
            _settled.add(key);
          }
        });
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      appBar: header(
        context,
        () => Navigator.of(context).pop(),
        title: widget.title,
        isBg: false,
      ),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ShaderMask(
              shaderCallback:
                  (rect) => const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.white, Colors.transparent],
                  ).createShader(rect),
              blendMode: BlendMode.dstIn,
              child: Image.asset(
                'assets/bg_header.png',
                width: double.infinity,
                fit: BoxFit.cover,
                height: 250,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: kToolbarHeight + 64),
            child: Column(
              children: [
                CategorySelector(
                  model: _categories,
                  code: _category.name,
                  onChange:
                      (code) =>
                          _selectCategory(DltNewsCategory.values.byName(code)),
                ),
                const SizedBox(height: 5),
                KeySearch(show: true, onKeySearchChange: _onSearch),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _refresh,
                    child: FutureBuilder<List<DltNewsArticle>>(
                      future: _news,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState != ConnectionState.done) {
                          return ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: const [
                              SizedBox(height: 100),
                              Center(child: CircularProgressIndicator()),
                            ],
                          );
                        }
                        if (snapshot.hasError) {
                          return ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(24),
                            children: [
                              const SizedBox(height: 48),
                              const Icon(Icons.wifi_off, size: 40),
                              const SizedBox(height: 16),
                              const Text(
                                'โหลดข่าวไม่สำเร็จ',
                                textAlign: TextAlign.center,
                              ),
                              TextButton(
                                onPressed: _refresh,
                                child: const Text('ลองอีกครั้ง'),
                              ),
                            ],
                          );
                        }
                        final query = _query.toLowerCase();
                        final articles =
                            (snapshot.data ?? <DltNewsArticle>[]).where((
                              article,
                            ) {
                              return article.title.toLowerCase().contains(
                                    query,
                                  ) ||
                                  article.description.toLowerCase().contains(
                                    query,
                                  );
                            }).toList();
                        final shown = articles.take(_visibleCount).toList();
                        final hasMore = articles.length > shown.length;

                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted) _loadImages(shown);
                        });

                        return CustomScrollView(
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          physics: const AlwaysScrollableScrollPhysics(),
                          slivers: [
                            const SliverToBoxAdapter(
                              child: SizedBox(height: 25),
                            ),
                            if (_imageError)
                              SliverToBoxAdapter(
                                child: TextButton(
                                  onPressed:
                                      () => setState(() => _imageError = false),
                                  child: const Text(
                                    'โหลดรูปไม่สำเร็จ แตะเพื่อลองอีกครั้ง',
                                  ),
                                ),
                              ),
                            if (articles.isEmpty)
                              SliverToBoxAdapter(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 48,
                                  ),
                                  child: Text(
                                    _query.isEmpty
                                        ? 'ยังไม่มีข่าวในหมวดนี้'
                                        : 'ไม่พบข่าวที่ค้นหา',
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            SliverPadding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              sliver: SliverList(
                                delegate: SliverChildBuilderDelegate((
                                  context,
                                  index,
                                ) {
                                  final article = shown[index];
                                  return DltNewsCard(
                                    key: ValueKey(article.url.toString()),
                                    article: _service.withCachedImage(article),
                                    service: _service,
                                    imageLoading:
                                        _service.cachedImage(article) == null &&
                                        !_settled.contains(
                                          article.url.toString(),
                                        ),
                                  );
                                }, childCount: shown.length),
                              ),
                            ),
                            if (hasMore)
                              SliverToBoxAdapter(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    10,
                                    8,
                                    10,
                                    0,
                                  ),
                                  child: OutlinedButton(
                                    onPressed:
                                        () => setState(
                                          () => _visibleCount += _pageSize,
                                        ),
                                    child: const Text('โหลดข่าวเพิ่มเติม'),
                                  ),
                                ),
                              ),
                            const SliverToBoxAdapter(
                              child: SizedBox(height: 16),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
