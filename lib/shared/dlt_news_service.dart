import 'dart:convert';

import 'package:html/dom.dart' show Element;
import 'package:html/parser.dart' as html;
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

enum DltNewsCategory {
  // TODO: 171 is a guess and returns an EMPTY feed (0 items). Replace it with
  // the real id from https://www.dlt.go.th/th/announce (look for the RSS link).
  // Until then the listing-page fallback in DltNewsService.fetch() is used.
  announce('ข่าวประกาศจากกรม', 'announce', 171),
  publicNews('ข่าวประชาสัมพันธ์', 'public-news', 172),
  department('ภาพข่าวกรมการขนส่งทางบก', 'dlt-photo', 173);

  const DltNewsCategory(this.title, this.slug, this.feedId);

  final String title;
  final String slug;
  final int feedId;

  Uri get pageUrl => Uri.https('www.dlt.go.th', '/th/$slug');
  Uri get feedUrl => Uri.https('www.dlt.go.th', '/rss/1/th/$feedId/$slug.xml');
}

class DltNewsArticle {
  const DltNewsArticle({
    required this.title,
    required this.description,
    required this.url,
    required this.category,
    this.publishedAt,
    this.imageUrl,
  });

  final String title;
  final String description;
  final Uri url;
  final DltNewsCategory category;
  final DateTime? publishedAt;
  final Uri? imageUrl;

  DltNewsArticle withImage(Uri? image) => DltNewsArticle(
    title: title,
    description: description,
    url: url,
    category: category,
    publishedAt: publishedAt,
    imageUrl: image,
  );
}

/// Reads the public RSS links published on the DLT website. The feeds currently
/// contain the latest 20 items, without images or the full article body.
class DltNewsService {
  DltNewsService({
    http.Client? client,
    this.pageLoader,
    this.backgroundPageLoader,
    this.feedLoader,
  }) : _client = client ?? http.Client();

  final Future<String> Function(Uri url)? pageLoader;

  /// Low-priority loader for prefetching; falls back to [pageLoader].
  final Future<String> Function(Uri url)? backgroundPageLoader;

  final http.Client _client;
  final Future<String> Function(Uri url, Future<String> Function() load)?
  feedLoader;
  final _details = <String, DltNewsDetail>{};
  final _detailPending = <String, Future<DltNewsDetail>>{};
  DltNewsDetail? cachedDetail(DltNewsArticle article) =>
      _details[article.url.toString()];

  Future<List<DltNewsArticle>> fetch(DltNewsCategory category) async {
    Future<String> load() async {
      final response = await _client
          .get(
            category.feedUrl,
            headers: {
              'Accept': 'application/rss+xml, application/xml, text/xml',
            },
          )
          .timeout(const Duration(seconds: 20));
      if (response.statusCode != 200) {
        throw const DltNewsException('ไม่สามารถโหลดข่าวจากกรมการขนส่งทางบกได้');
      }
      return utf8.decode(response.bodyBytes, allowMalformed: true);
    }

    final source = await (feedLoader?.call(category.feedUrl, load) ?? load());
    var articles = parse(source, category);
    assert(() {
      if (articles.isEmpty) {
        final items = '<item'.allMatches(source).length;
        final links =
            RegExp(
              r'<link>\s*([^<\s]+)\s*</link>',
            ).allMatches(source).map((m) => m[1]).take(3).toList();
        // ignore: avoid_print
        print(
          'DLT feed ${category.feedUrl}: ${source.length} chars, '
          '$items items, links=$links',
        );
      }
      return true;
    }());

    // Fallback: the RSS feed is empty (e.g. wrong feed id) -> read the list
    // from the rendered listing page instead. Never throws.
    if (articles.isEmpty && pageLoader != null) {
      try {
        final page = await pageLoader!(category.pageUrl);
        articles = parseListing(page, category);
        assert(() {
          final cards = html.parse(page).querySelectorAll('#pills-g .card');
          // ignore: avoid_print
          print(
            'DLT fallback ${category.slug}: ${articles.length} articles, '
            '${cards.length} cards',
          );
          for (final a in articles.take(3)) {
            // ignore: avoid_print
            print('DLT fallback item: ${a.title} | ${a.url}');
          }
          if (articles.isEmpty && cards.isNotEmpty) {
            final c = cards.first;
            for (final s in c.querySelectorAll('svg').toList()) {
              s.remove();
            }
            // ignore: avoid_print
            print(
              'DLT card hrefs: '
              '${c.querySelectorAll('a[href]').map((a) => a.attributes['href']).toList()}',
            );
            final attrs = <String>[];
            for (final e in [c, ...c.querySelectorAll('*')]) {
              if (e.attributes.isNotEmpty) {
                attrs.add('${e.localName}${e.attributes}');
              }
            }
            final joined = attrs.join(' | ');
            // ignore: avoid_print
            print(
              'DLT card attrs: '
              '${joined.length > 1500 ? joined.substring(0, 1500) : joined}',
            );
            final body =
                c.querySelector('.card-body')?.outerHtml ?? c.outerHtml;
            // ignore: avoid_print
            print(
              'DLT card-body: '
              '${body.length > 900 ? body.substring(0, 900) : body}',
            );
          }
          return true;
        }());
      } catch (e) {
        assert(() {
          // ignore: avoid_print
          print('DLT fallback ${category.slug} failed: $e');
          return true;
        }());
        // Keep the empty list; the UI shows its "no data" state.
      }
    }

    // Show only this year's news when there is any; otherwise show everything
    // the feed has.
    final year = DateTime.now().year;
    final current = articles.where((a) => a.publishedAt?.year == year).toList();
    return current.isNotEmpty ? current : articles;
  }

  static const _coversTtl = Duration(minutes: 10);
  final _covers = <DltNewsCategory, Future<Map<String, Uri>>>{};
  final _coversAt = <DltNewsCategory, DateTime>{};
  final _images = <String, Uri>{};

  void clearImages() {
    _covers.clear();
    _coversAt.clear();
    _images.clear();
  }

  Future<Map<String, Uri>> _coversFor(DltNewsCategory category) {
    final at = _coversAt[category];
    if (at != null && DateTime.now().difference(at) > _coversTtl) {
      _covers.remove(category);
    }
    return _covers.putIfAbsent(category, () async {
      _coversAt[category] = DateTime.now();
      return parseCovers(await pageLoader!(category.pageUrl), category);
    });
  }

  /// Starts reading the listing page now (in parallel with the RSS request) so
  /// covers are usually ready by the time the list is shown.
  void prefetchCovers(DltNewsCategory category) {
    if (pageLoader == null) return;
    final future = _coversFor(category);
    future.then<void>(
      (_) {},
      onError: (Object _) {
        if (identical(_covers[category], future)) _covers.remove(category);
      },
    );
  }

  /// Warms the detail cache in the background so opening an article is instant.
  void prefetchDetails(Iterable<DltNewsArticle> articles) {
    for (final article in articles) {
      fetchDetail(
        article,
        background: true,
      ).then<void>((_) {}, onError: (Object _) {});
    }
  }

  /// Image already known for [article] (from the RSS item or a previous load).
  Uri? cachedImage(DltNewsArticle article) =>
      article.imageUrl ?? _images[article.url.toString()];

  /// Synchronous: returns [article] with its cached image applied, if any.
  DltNewsArticle withCachedImage(DltNewsArticle article) {
    if (article.imageUrl != null) return article;
    final image = _images[article.url.toString()];
    return image == null ? article : article.withImage(image);
  }

  /// Enrich only the requested batch; the RSS list can render immediately.
  /// A failure on one article never discards the images of the others. Only a
  /// failure to read the listing page (covers) is thrown.
  Future<List<DltNewsArticle>> loadImages(List<DltNewsArticle> articles) async {
    if (pageLoader == null || articles.isEmpty) return articles;
    final category = articles.first.category;
    final future = _coversFor(category);
    Map<String, Uri> covers;
    try {
      covers = await future;
    } catch (_) {
      if (identical(_covers[category], future)) _covers.remove(category);
      rethrow;
    }
    return Future.wait(
      articles.map((article) async {
        final key = article.url.toString();
        var image = article.imageUrl ?? _images[key] ?? covers[key];
        if (image == null) {
          try {
            final detail = await fetchDetail(article, background: true);
            if (detail.images.isNotEmpty) image = detail.images.first;
          } catch (_) {
            // This article keeps the placeholder; the others still get images.
          }
        }
        if (image != null) _images[key] = image;
        return article.withImage(image);
      }),
    );
  }

  /// [background] marks speculative loads (prefetch) so a tap by the user is
  /// never queued behind them.
  Future<DltNewsDetail> fetchDetail(
    DltNewsArticle article, {
    bool background = false,
  }) {
    final key = article.url.toString();
    final cached = _details[key];
    if (cached != null) return Future.value(cached);
    final pending = _detailPending[key];
    if (pending != null) {
      // Ask again in the foreground so the loader promotes a queued prefetch.
      if (!background && pageLoader != null) {
        pageLoader!(article.url).then<void>((_) {}, onError: (Object _) {});
      }
      return pending;
    }
    return _detailPending.putIfAbsent(key, () async {
      try {
        final load = (background ? backgroundPageLoader : null) ?? pageLoader;
        if (load == null) {
          throw const DltNewsException('ไม่สามารถโหลดรายละเอียดข่าวได้');
        }
        final detail = parseDetail(
          await load(article.url),
          withCachedImage(article),
        );
        // Do not keep a body-less result, so a later visit tries again.
        if (detail.contentHtml.isNotEmpty) {
          if (_details.length >= 30) _details.remove(_details.keys.first);
          _details[key] = detail;
        }
        return detail;
      } finally {
        _detailPending.remove(key);
      }
    });
  }

  static Map<String, Uri> parseCovers(String source, DltNewsCategory category) {
    final document = html.parse(source);
    final images = <String, Uri>{};
    for (final card in document.querySelectorAll('#pills-g .card')) {
      final link = card.querySelector('a.btn-readmore')?.attributes['href'];
      final src =
          card
              .querySelector('img.img-CardH, .image-box img')
              ?.attributes['src'];
      if (link == null) continue;
      final url = category.pageUrl.resolve(link);
      final image = _imageUri(src, category.pageUrl);
      if (url.host == 'www.dlt.go.th' &&
          url.path.startsWith('/th/${category.slug}/') &&
          image != null) {
        images[url.toString()] = image;
      }
    }
    if (images.isEmpty) {
      throw const DltNewsException('ไม่พบรูปข่าวในหน้าเว็บ กรุณาลองใหม่');
    }
    return images;
  }

  /// Fallback used when the RSS feed has no items: builds the article list
  /// from the rendered listing page (`#pills-g .card`).
  static List<DltNewsArticle> parseListing(
    String source,
    DltNewsCategory category,
  ) {
    final document = html.parse(source);
    final seen = <String>{};
    final articles = <DltNewsArticle>[];
    final bases = [
      category.pageUrl,
      Uri.parse('${category.pageUrl}/'),
      Uri.https('www.dlt.go.th', '/'),
    ];

    final idPath = RegExp('^/th/${RegExp.escape(category.slug)}/(\\d+)/?\$');

    Uri? articleUrl(String? href) {
      if (href == null || href.trim().isEmpty) return null;
      for (final base in bases) {
        final url = base.resolve(href.trim());
        if (url.scheme == 'https' &&
            url.host == 'www.dlt.go.th' &&
            idPath.hasMatch(url.path)) {
          return url.removeFragment();
        }
      }
      return null;
    }

    for (final card in document.querySelectorAll('#pills-g .card')) {
      Uri? url;
      for (final a in card.querySelectorAll('a[href]')) {
        url = articleUrl(a.attributes['href']);
        if (url != null) break;
      }
      if (url == null) {
        final elements = [card, ...card.querySelectorAll('*')];
        final inPath = RegExp('/th/${RegExp.escape(category.slug)}/(\\d+)');
        outer:
        for (final e in elements) {
          for (final entry in e.attributes.entries) {
            final name = entry.key.toString();
            if (const {'src', 'srcset', 'class', 'style', 'd'}.contains(name)) {
              continue;
            }
            final m = inPath.firstMatch(entry.value);
            if (m != null) {
              url = Uri.https('www.dlt.go.th', '/th/${category.slug}/${m[1]}');
              break outer;
            }
          }
        }
        if (url == null) {
          final idName = RegExp('id|code|news', caseSensitive: false);
          outer2:
          for (final e in elements) {
            for (final entry in e.attributes.entries) {
              if (idName.hasMatch(entry.key.toString()) &&
                  RegExp(r'^\d{2,7}$').hasMatch(entry.value.trim())) {
                url = Uri.https(
                  'www.dlt.go.th',
                  '/th/${category.slug}/${entry.value.trim()}',
                );
                break outer2;
              }
            }
          }
        }
      }
      if (url == null || !seen.add(url.toString())) continue;

      final scope = card.querySelector('.card-body') ?? card;
      var title = '';
      // 1) headings / paragraphs / anything with "title" in its class
      for (final e in scope.querySelectorAll(
        'h1,h2,h3,h4,h5,h6,p,[class*="title"]',
      )) {
        title = _plainText(e.text);
        if (title.isNotEmpty) break;
      }
      // 2) a link that is not the "read more" button
      if (title.isEmpty) {
        for (final a in scope.querySelectorAll('a')) {
          if (a.classes.contains('btn-readmore')) continue;
          title = _plainText(a.attributes['title'] ?? a.text);
          if (title.isNotEmpty) break;
        }
      }
      // 3) last resorts
      if (title.isEmpty) title = _plainText(scope.text);
      if (title.isEmpty) {
        title = _plainText(card.querySelector('img')?.attributes['alt'] ?? '');
      }
      if (title.isEmpty) continue;

      articles.add(
        DltNewsArticle(
          title: title,
          description: '',
          url: url,
          category: category,
          imageUrl: _imageUri(
            card
                .querySelector('img.img-CardH, .image-box img')
                ?.attributes['src'],
            category.pageUrl,
          ),
        ),
      );
    }
    return articles;
  }

  static DltNewsDetail parseDetail(String source, DltNewsArticle article) {
    final document = html.parse(source);
    final root = document.querySelector('.card-content');
    final content = root?.querySelector('.detail-content');
    if (root == null || content == null) {
      throw const DltNewsException('ไม่พบเนื้อหาข่าว กรุณาลองใหม่');
    }
    final images = <Uri>{};
    for (final link in root.querySelectorAll('a[data-fancybox]')) {
      final image = _imageUri(link.attributes['href'], article.url);
      if (image != null) images.add(image);
    }
    for (final image in content.querySelectorAll('img')) {
      final url = _imageUri(image.attributes['src'], article.url);
      if (url != null) images.add(url);
    }
    if (images.isEmpty && article.imageUrl != null) {
      images.add(article.imageUrl!);
    }
    final dateLabel =
        root.querySelector('.dateVL .ic-clock')?.parent?.parent?.text.trim();
    final viewText =
        root.querySelector('.dateVL .ic-eye')?.parent?.parent?.text.trim();
    // Strip website controls/gallery (rendered natively) and Word inline styles.
    for (final element in content.querySelectorAll(
      '#galleryCPN, script, style, iframe, object, embed, form, button, input, svg',
    )) {
      element.remove();
    }
    _removeRelatedFiles(content);
    for (final element in content.querySelectorAll('*')) {
      final href = element.attributes['href'];
      final src = element.attributes['src'];
      final alt = element.attributes['alt'];
      element.attributes.clear();
      if (href != null) {
        final url = article.url.resolve(href);
        if (url.scheme == 'https' || url.scheme == 'http') {
          element.attributes['href'] = url.toString();
        }
      }
      if (element.localName == 'img') {
        final url = _imageUri(src, article.url);
        if (url == null) {
          element.remove();
          continue;
        }
        element.attributes['src'] = url.toString();
        if (alt != null) element.attributes['alt'] = alt;
      }
    }
    // An article with an empty body (e.g. a photo news item) is still shown
    // with its title and cover instead of an error.
    final contentHtml = content.innerHtml.trim();
    return DltNewsDetail(
      article: article,
      contentHtml: contentHtml,
      images: images.toList(),
      dateLabel: dateLabel,
      views: int.tryParse((viewText ?? '').replaceAll(',', '')),
    );
  }

  /// Removes the website's "ไฟล์ที่เกี่ยวข้อง" (related files) block: its
  /// heading and everything after it, which only holds download controls.
  static void _removeRelatedFiles(Element content) {
    const title = 'ไฟล์ที่เกี่ยวข้อง';
    for (final element in content.querySelectorAll('*').toList()) {
      final text = element.text.replaceAll(RegExp(r'\s+'), ' ').trim();
      if (!text.startsWith(title) || text.length > title.length + 2) continue;
      // Climb to the outermost wrapper that starts with this heading.
      var node = element;
      while (node.parent != null &&
          !identical(node.parent, content) &&
          node.previousElementSibling == null) {
        node = node.parent!;
      }
      final parent = node.parent;
      if (parent == null) return;
      final index = parent.nodes.indexOf(node);
      for (final n in parent.nodes.sublist(index).toList()) {
        n.remove();
      }
      return;
    }
  }

  static Uri? _imageUri(String? value, Uri base) {
    if (value == null || value.trim().isEmpty) return null;
    final url = base.resolve(value);
    if (url.scheme != 'https' ||
        !(url.host == 'dlt.go.th' || url.host.endsWith('.dlt.go.th')) ||
        !url.path.startsWith('/web-upload/')) {
      return null;
    }
    return url;
  }

  static List<DltNewsArticle> parse(String source, DltNewsCategory category) {
    final XmlDocument document;
    try {
      document = XmlDocument.parse(source);
    } on XmlParserException {
      throw const DltNewsException('รูปแบบข้อมูลข่าวไม่ถูกต้อง');
    } on XmlTagException {
      throw const DltNewsException('รูปแบบข้อมูลข่าวไม่ถูกต้อง');
    }
    final channel = document.getElement('rss')?.getElement('channel');
    if (channel == null) {
      throw const DltNewsException('รูปแบบข้อมูลข่าวไม่ถูกต้อง');
    }
    final seen = <String>{};
    final articles = <DltNewsArticle>[];
    for (final item in channel.findElements('item')) {
      final title = _plainText(item.getElement('title')?.innerText ?? '');
      final link = item.getElement('link')?.innerText.trim() ?? '';
      final url = Uri.tryParse(link);
      // Only article links from the selected official section are accepted.
      if (title.isEmpty ||
          url == null ||
          url.scheme != 'https' ||
          url.host != 'www.dlt.go.th' ||
          url.userInfo.isNotEmpty ||
          !url.path.startsWith('/th/${category.slug}/') ||
          !seen.add(url.toString())) {
        continue;
      }
      articles.add(
        DltNewsArticle(
          title: title,
          description: _plainText(
            item.getElement('description')?.innerText ?? '',
          ),
          url: url,
          category: category,
          publishedAt: _publicationDate(item.getElement('pubDate')?.innerText),
        ),
      );
    }
    return articles;
  }

  static String _plainText(String value) =>
      (html.parseFragment(value).text ?? '')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();

  // Preserve the calendar date supplied by DLT (Thai local time).
  static DateTime? _publicationDate(String? value) {
    if (value == null) return null;
    final match = RegExp(r'(\d{1,2}) ([A-Za-z]{3}) (\d{4})').firstMatch(value);
    if (match == null) return null;
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final month = months.indexOf(match[2]!) + 1;
    final day = int.parse(match[1]!);
    final year = int.parse(match[3]!);
    if (month == 0 || day < 1 || day > 31) return null;
    final date = DateTime(year, month, day);
    return date.month == month ? date : null;
  }

  void close() => _client.close();
}

class DltNewsException implements Exception {
  const DltNewsException(this.message);
  final String message;

  @override
  String toString() => message;
}

class DltNewsDetail {
  const DltNewsDetail({
    required this.article,
    required this.contentHtml,
    required this.images,
    this.dateLabel,
    this.views,
  });

  final DltNewsArticle article;
  final String contentHtml;
  final List<Uri> images;
  final String? dateLabel;
  final int? views;
}
