import 'dart:async';
import 'package:KhubDeeDLT/shared/dlt_news_cache.dart';
import 'package:KhubDeeDLT/shared/dlt_news_page_loader.dart';
import 'package:KhubDeeDLT/shared/dlt_news_service.dart';

/// One news session shared by Home, the list and detail routes.
class DltNewsRuntime {
  static final instance = DltNewsRuntime();
  final service = DltNewsService(
    pageLoader: DltNewsPageLoader.instance.load,
    feedLoader: (url, load) => DltNewsCache.instance.text(url, load),
  );
  final _lists = <DltNewsCategory, Future<List<DltNewsArticle>>>{};
  final _warming = <String>{};
  DateTime? _started;

  Future<List<DltNewsArticle>> fetch(
    DltNewsCategory category, {
    bool refresh = false,
  }) {
    if (refresh ||
        (_started != null &&
            DateTime.now().difference(_started!) >
                const Duration(minutes: 15))) {
      _lists.clear();
      service.clearImages();
      _started = null;
    }
    _started ??= DateTime.now();
    return _lists.putIfAbsent(category, () async {
      try {
        final articles = await service.fetch(category);
        unawaited(prepare(articles.take(5).toList()));
        return articles;
      } catch (_) {
        _lists.remove(category);
        rethrow;
      }
    });
  }

  Future<void> warmHome() async {
    try {
      await fetch(DltNewsCategory.publicNews);
    } catch (_) {}
  }

  Future<void> prepare(List<DltNewsArticle> articles) async {
    try {
      final enriched = await service.loadImages(articles);
      await Future.wait(
        enriched.where((a) => a.imageUrl != null).map((a) async {
          try {
            await DltNewsCache.instance.image(a.imageUrl!);
          } catch (_) {}
        }),
      );
      await Future.wait(
        enriched.map((article) async {
          final key = article.url.toString();
          if (!_warming.add(key)) return;
          try {
            final detail = await service.fetchDetail(article);
            // Prepare the hero and thumbnails, leaving full gallery downloads on demand.
            await Future.wait(
              detail.images.take(4).map((url) async {
                try {
                  await DltNewsCache.instance.image(url);
                } catch (_) {}
              }),
            );
          } catch (_) {
            // A failed prefetch remains retryable when the article is opened.
          } finally {
            _warming.remove(key);
          }
        }),
      );
    } catch (_) {}
  }
}
