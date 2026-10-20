import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:KhubDeeDLT/shared/dlt_news_service.dart';

void main() {
  test(
    'RSS renders without loading pages; images load only for the requested batch',
    () async {
      final pages = <Uri>[];
      final service = DltNewsService(
        client: MockClient(
          (_) async => http.Response.bytes(
            File('test/fixtures/dlt-news.xml').readAsBytesSync(),
            200,
          ),
        ),
        pageLoader: (url) async {
          pages.add(url);
          if (url.path.endsWith('public-news')) {
            return '<div id="pills-g"><div class="card"><img class="img-CardH" src="/web-upload/cover.jpg"><a class="btn-readmore" href="/th/public-news/3996">อ่าน</a></div></div>';
          }
          return '<div class="card-content"><div class="detail-content"><p>เนื้อหา</p></div><a data-fancybox="gallery" href="/web-upload/gallery.jpg"></a></div>';
        },
      );
      addTearDown(service.close);
      final articles = await service.fetch(DltNewsCategory.publicNews);
      expect(pages, isEmpty);
      final first = await service.loadImages(articles.take(1).toList());
      expect(first.single.imageUrl?.path, '/web-upload/cover.jpg');
      expect(pages.length, 1);
      final second = await service.loadImages(articles.skip(1).toList());
      expect(second.single.imageUrl?.path, '/web-upload/gallery.jpg');
      expect(pages.length, 2);
      await service.loadImages(articles);
      expect(pages.length, 2);
    },
  );

  final article = DltNewsArticle(
    title: 'ข่าวทดสอบ',
    description: 'คำโปรย',
    url: Uri.parse('https://www.dlt.go.th/th/public-news/3996'),
    category: DltNewsCategory.publicNews,
  );

  test('pairs cover images by article URL, not list order', () {
    final images = DltNewsService.parseCovers('''<div id="pills-g">
      <div class="card"><img class="img-CardH" src="/web-upload/two.jpg"><a class="btn-readmore" href="/th/public-news/2">อ่าน</a></div>
      <div class="card"><img class="img-CardH" src="/web-upload/one.jpg"><a class="btn-readmore" href="/th/public-news/1">อ่าน</a></div>
      <div class="card"><img class="img-CardH" src="https://other.example/image.jpg"><a class="btn-readmore" href="/th/public-news/3">อ่าน</a></div>
    </div>''', DltNewsCategory.publicNews);
    expect(
      images['https://www.dlt.go.th/th/public-news/1'].toString(),
      'https://www.dlt.go.th/web-upload/one.jpg',
    );
    expect(images, hasLength(2));
  });

  test('extracts native content, metadata and deduplicated gallery', () {
    final detail = DltNewsService.parseDetail('''<div class="card-content">
      <ul class="dateVL"><li><div><svg class="ic-clock"></svg></div><span>29 ก.ย. 2569</span></li><li><div><svg class="ic-eye"></svg></div>1,234</li></ul>
      <div class="detail-content"><p style="font-size:99px" onclick="alert(1)">เนื้อหา <b>เต็ม</b></p>
        <script>alert(1)</script><iframe src="https://other.example"></iframe>
        <a href="/web-upload/document.pdf">เอกสาร</a><a href="javascript:alert(1)">bad</a>
      </div>
      <a data-fancybox="gallery" href="/web-upload/one.jpg"></a>
      <a data-fancybox="gallery" href="/web-upload/one.jpg"></a>
      <a data-fancybox="gallery" href="/web-upload/two.jpg"></a>
      <img src="/_nuxt/img/logo.png">
    </div>''', article);
    expect(detail.images, hasLength(2));
    expect(detail.contentHtml, contains('<b>เต็ม</b>'));
    expect(
      detail.contentHtml,
      contains('https://www.dlt.go.th/web-upload/document.pdf'),
    );
    expect(detail.contentHtml, isNot(contains('script')));
    expect(detail.contentHtml, isNot(contains('style=')));
    expect(detail.contentHtml, isNot(contains('onclick')));
    expect(detail.contentHtml, isNot(contains('iframe')));
    expect(detail.dateLabel, '29 ก.ย. 2569');
    expect(detail.views, 1234);
  });

  test('removes website photo carousel while preserving album description', () {
    final detail = DltNewsService.parseDetail(
      '''<div class="card-content"><div class="detail-content">
      <div id="galleryCPN"><button>next</button><a data-fancybox="album" href="/web-upload/photo.jpg"><img src="/web-upload/photo.jpg"></a></div>
      <p>รายละเอียดกิจกรรม</p>
    </div></div>''',
      article,
    );
    expect(
      detail.images.single.toString(),
      'https://www.dlt.go.th/web-upload/photo.jpg',
    );
    expect(detail.contentHtml, contains('รายละเอียดกิจกรรม'));
    expect(detail.contentHtml, isNot(contains('galleryCPN')));
    expect(detail.contentHtml, isNot(contains('next')));
  });

  test('rejects missing article DOM instead of showing a partial summary', () {
    expect(
      () => DltNewsService.parseDetail('<div>loading</div>', article),
      throwsA(isA<DltNewsException>()),
    );
  });

  test('reads the official Thai public news feed and publication date', () {
    final articles = DltNewsService.parse(
      File('test/fixtures/dlt-news.xml').readAsStringSync(),
      DltNewsCategory.publicNews,
    );
    expect(articles, hasLength(2));
    expect(articles.first.title, contains('กรมการขนส่งทางบก'));
    expect(
      articles.first.url.toString(),
      'https://www.dlt.go.th/th/public-news/3996',
    );
    expect(articles.first.publishedAt, DateTime(2026, 9, 30));
  });

  test('uses the photo feed for the department category', () async {
    final service = DltNewsService(
      client: MockClient((request) async {
        expect(
          request.url.toString(),
          'https://www.dlt.go.th/rss/1/th/173/dlt-photo.xml',
        );
        return http.Response.bytes(
          File('test/fixtures/dlt-photo.xml').readAsBytesSync(),
          200,
        );
      }),
    );
    addTearDown(service.close);
    final articles = await service.fetch(DltNewsCategory.department);
    expect(articles, hasLength(2));
    expect(articles.first.category, DltNewsCategory.department);
    expect(articles.first.url.path, '/th/dlt-photo/1027');
  });

  test('decodes UTF-8 when server omits charset', () async {
    final service = DltNewsService(
      client: MockClient((_) async {
        return http.Response.bytes(
          utf8.encode('''<rss><channel><item>
        <title>ข่าวภาษาไทย &amp; DLT</title>
        <description><![CDATA[<p>รายละเอียด <b>ข่าว</b></p>]]></description>
        <link>https://www.dlt.go.th/th/public-news/1</link>
      </item></channel></rss>'''),
          200,
        );
      }),
    );
    addTearDown(service.close);
    final articles = await service.fetch(DltNewsCategory.publicNews);
    expect(articles.single.title, 'ข่าวภาษาไทย & DLT');
    expect(articles.single.description, 'รายละเอียด ข่าว');
    expect(articles.single.publishedAt, isNull);
  });

  test('rejects non-feed responses and server errors', () async {
    expect(
      () => DltNewsService.parse(
        '<html>unavailable</html>',
        DltNewsCategory.publicNews,
      ),
      throwsA(isA<DltNewsException>()),
    );
    expect(
      () => DltNewsService.parse('<rss>', DltNewsCategory.publicNews),
      throwsA(isA<DltNewsException>()),
    );
    final service = DltNewsService(
      client: MockClient((_) async => http.Response('unavailable', 503)),
    );
    addTearDown(service.close);
    await expectLater(
      service.fetch(DltNewsCategory.publicNews),
      throwsA(isA<DltNewsException>()),
    );
  });

  test('ignores duplicate, empty and unrelated article links', () {
    final links = [
      'https://www.dlt.go.th/th/public-news/1',
      'https://www.dlt.go.th/th/public-news/1',
      'https://example.com/th/public-news/2',
      'javascript:alert(1)',
      'https://www.dlt.go.th/th/dlt-photo/2',
      '',
    ];
    final source =
        '<rss><channel>${links.map((link) => '<item><title>ข่าว</title><link>$link</link></item>').join()}</channel></rss>';
    expect(
      DltNewsService.parse(source, DltNewsCategory.publicNews),
      hasLength(1),
    );
    expect(
      DltNewsService.parse('<rss><channel/></rss>', DltNewsCategory.publicNews),
      isEmpty,
    );
  });
}
