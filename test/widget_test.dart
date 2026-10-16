import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:KhubDeeDLT/pages/news/dlt_news_detail.dart';
import 'package:KhubDeeDLT/component/tab_category.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:KhubDeeDLT/pages/news/news_list.dart';
import 'package:KhubDeeDLT/shared/dlt_news_service.dart';

class FakeNewsService extends DltNewsService {
  final calls = <DltNewsCategory>[];
  bool fail = false;
  final pending = <DltNewsCategory, Completer<List<DltNewsArticle>>>{};

  @override
  Future<DltNewsDetail> fetchDetail(DltNewsArticle article) async =>
      DltNewsDetail(
        article: article,
        contentHtml: '<p>เนื้อหาข่าวฉบับเต็ม</p>',
        images: const [],
      );

  @override
  Future<List<DltNewsArticle>> fetch(DltNewsCategory category) async {
    calls.add(category);
    if (fail) throw const DltNewsException('offline');
    if (pending.containsKey(category)) return pending[category]!.future;
    return [
      DltNewsArticle(
        title:
            category == DltNewsCategory.publicNews
                ? 'ข่าวใบขับขี่'
                : 'กิจกรรมกรมฯ',
        description: 'รายละเอียดจาก DLT',
        url: category.pageUrl.resolve('${category.slug}/1'),
        category: category,
      ),
    ];
  }
}

class BatchNewsService extends FakeNewsService {
  final batches = <List<DltNewsArticle>>[];
  final firstImages = Completer<List<DltNewsArticle>>();

  @override
  Future<List<DltNewsArticle>> fetch(DltNewsCategory category) async =>
      List.generate(
        12,
        (i) => DltNewsArticle(
          title: 'ข่าวชุด $i',
          description: '',
          url: category.pageUrl.resolve('${category.slug}/${i + 1}'),
          category: category,
        ),
      );

  @override
  Future<List<DltNewsArticle>> loadImages(List<DltNewsArticle> articles) {
    batches.add(articles);
    return batches.length == 1 ? firstImages.future : Future.value(articles);
  }
}

void main() {
  testWidgets('shows titles before images and requests five more on demand', (
    tester,
  ) async {
    final service = BatchNewsService();
    addTearDown(service.close);
    await tester.pumpWidget(
      MaterialApp(home: NewsList(title: 'ข่าว', service: service)),
    );
    await tester.pump();
    await tester.pump();
    expect(find.text('ข่าวชุด 0'), findsOneWidget);
    expect(service.batches.single.length, 5);
    expect(find.text('เปิดเว็บไซต์ DLT'), findsNothing);
    service.firstImages.complete(service.batches.first);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('โหลดข่าวเพิ่มเติม'),
      500,
      scrollable:
          find
              .descendant(
                of: find.byType(RefreshIndicator),
                matching: find.byType(Scrollable),
              )
              .first,
    );
    await tester.tap(find.text('โหลดข่าวเพิ่มเติม'));
    await tester.pumpAndSettle();
    expect(service.batches.length, 2);
    expect(service.batches.last.map((a) => a.title), [
      'ข่าวชุด 5',
      'ข่าวชุด 6',
      'ข่าวชุด 7',
      'ข่าวชุด 8',
      'ข่าวชุด 9',
    ]);
  });

  testWidgets(
    'opens a native detail page with full HTML instead of a WebView',
    (tester) async {
      final service = FakeNewsService();
      addTearDown(service.close);
      await tester.pumpWidget(
        MaterialApp(home: NewsList(title: 'ข่าว', service: service)),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('ข่าวใบขับขี่'));
      await tester.pumpAndSettle();
      expect(find.byType(DltNewsDetailPage), findsOneWidget);
      expect(find.text('ดูข่าวต้นฉบับและเอกสารแนบ'), findsNothing);
      expect(
        tester.widget<Html>(find.byType(Html)).data,
        contains('เนื้อหาข่าวฉบับเต็ม'),
      );
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
      expect(find.byType(NewsList), findsOneWidget);
    },
  );

  testWidgets('switches categories and filters without the old news API', (
    tester,
  ) async {
    final service = FakeNewsService();
    addTearDown(service.close);
    await tester.pumpWidget(
      MaterialApp(home: NewsList(title: 'ข่าวประชาสัมพันธ์', service: service)),
    );
    await tester.pumpAndSettle();
    expect(find.text('ข่าวใบขับขี่'), findsOneWidget);
    await tester.pump();
    await tester.tap(
      find.descendant(
        of: find.byType(CategorySelector),
        matching: find.text('กรมการขนส่งทางบก'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('กิจกรรมกรมฯ'), findsOneWidget);
    expect(find.text('ข่าวใบขับขี่'), findsNothing);
    expect(service.calls, [
      DltNewsCategory.publicNews,
      DltNewsCategory.department,
    ]);
    await tester.enterText(find.byType(TextField), 'ไม่มีข่าวนี้');
    await tester.pumpAndSettle();
    expect(find.text('ไม่พบข่าวที่ค้นหา'), findsOneWidget);
    await tester.enterText(find.byType(TextField), '');
    await tester.pumpAndSettle();
    expect(find.text('กิจกรรมกรมฯ'), findsOneWidget);
  });

  testWidgets('offers retry after network failure', (tester) async {
    final service = FakeNewsService()..fail = true;
    addTearDown(service.close);
    await tester.pumpWidget(
      MaterialApp(home: NewsList(title: 'ข่าว', service: service)),
    );
    await tester.pumpAndSettle();
    expect(find.text('โหลดข่าวไม่สำเร็จ'), findsOneWidget);
    service.fail = false;
    await tester.tap(find.text('ลองอีกครั้ง'));
    await tester.pumpAndSettle();
    expect(find.text('ข่าวใบขับขี่'), findsOneWidget);
  });

  testWidgets('an earlier request cannot overwrite the selected category', (
    tester,
  ) async {
    final completer = Completer<List<DltNewsArticle>>();
    final service =
        FakeNewsService()..pending[DltNewsCategory.publicNews] = completer;
    addTearDown(service.close);
    await tester.pumpWidget(
      MaterialApp(home: NewsList(title: 'ข่าว', service: service)),
    );
    await tester.pump();
    await tester.tap(
      find.descendant(
        of: find.byType(CategorySelector),
        matching: find.text('กรมการขนส่งทางบก'),
      ),
    );
    await tester.pumpAndSettle();
    completer.complete([]);
    await tester.pumpAndSettle();
    expect(find.text('กิจกรรมกรมฯ'), findsOneWidget);
    expect(find.text('ยังไม่มีข่าวในหมวดนี้'), findsNothing);
  });
}
