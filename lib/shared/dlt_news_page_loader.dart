import 'dart:async';
import 'package:KhubDeeDLT/shared/dlt_news_cache.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:KhubDeeDLT/shared/dlt_news_service.dart';

/// App-wide service so covers and article details survive leaving and
/// re-entering the news pages. Never call `close()` on it.
final sharedDltNewsService = DltNewsService(
  pageLoader: DltNewsPageLoader.instance.load,
  backgroundPageLoader: DltNewsPageLoader.instance.loadInBackground,
);

class _Job {
  _Job(this.url, this.key, this.background);
  final Uri url;
  final String key;
  bool background;
  final completer = Completer<String>();
}

/// DLT renders its public pages with JavaScript. Read the rendered article DOM
/// without copying the website's private API credentials into the application.
///
/// Pages are rendered by a small pool of headless web views. Foreground loads
/// (the user tapped something) always run before background prefetches, and a
/// prefetch that the user then asks for is promoted to the front of the queue.
class DltNewsPageLoader {
  DltNewsPageLoader._();
  static final instance = DltNewsPageLoader._();

  static const _maxActive = 3;
  static const _maxBackground = 2; // keeps one slot free for the user's taps

  /// Only the DOM is read, so images/fonts/media are never downloaded.
  /// Set to false if a page stops rendering with them blocked.
  /// (If dlt-photo detail pages keep timing out, try false.)
  static const _blockMedia = false;
  static final _mediaBlockers = [
    ContentBlocker(
      trigger: ContentBlockerTrigger(
        urlFilter: '.*',
        resourceType: [
          ContentBlockerTriggerResourceType.IMAGE,
          ContentBlockerTriggerResourceType.FONT,
          ContentBlockerTriggerResourceType.MEDIA,
        ],
      ),
      action: ContentBlockerAction(type: ContentBlockerActionType.BLOCK),
    ),
  ];

  final _pending = <String, Future<String>>{};
  final _details = <String, ({DateTime time, String html})>{};
  final _queue = <_Job>[];
  final _jobs = <String, _Job>{}; // queued (not yet running) jobs
  int _active = 0;
  int _activeBackground = 0;

  Future<String> load(Uri url) => _load(url, background: false);

  Future<String> loadInBackground(Uri url) => _load(url, background: true);

  Future<String> _load(Uri url, {required bool background}) {
    if (url.scheme != 'https' ||
        url.host != 'www.dlt.go.th' ||
        !RegExp(
          r'^/th/(announce|public-news|dlt-photo)(/\d+)?$',
        ).hasMatch(url.path)) {
      return Future.error(const DltNewsException('ลิงก์ข่าวไม่ถูกต้อง'));
    }
    final key = url.toString();
    final cached = _details[key];
    if (cached != null &&
        DateTime.now().difference(cached.time) < const Duration(minutes: 5)) {
      return Future.value(cached.html);
    }
    final existing = _pending[key];
    if (existing != null) {
      if (!background) _promote(key);
      return existing;
    }
    final result = DltNewsCache.instance.text(
      url,
      () => _enqueue(url, key, background),
    );
    final future = result.then(
      (source) {
        _pending.remove(key);
        if (_details.length >= 30) _details.remove(_details.keys.first);
        _details[key] = (time: DateTime.now(), html: source);
        return source;
      },
      onError: (Object error, StackTrace stack) {
        _pending.remove(key);
        Error.throwWithStackTrace(error, stack);
      },
    );
    _pending[key] = future;
    return future;
  }

  void _insert(_Job job) {
    // Foreground jobs go before the first background job.
    final index = _queue.indexWhere((j) => j.background);
    if (job.background || index < 0) {
      _queue.add(job);
    } else {
      _queue.insert(index, job);
    }
  }

  Future<String> _enqueue(Uri url, String key, bool background) {
    final job = _Job(url, key, background);
    _jobs[key] = job;
    _insert(job);
    _pump();
    return job.completer.future;
  }

  void _promote(String key) {
    final job = _jobs[key];
    if (job == null || !job.background) return;
    job.background = false;
    _queue.remove(job);
    _insert(job);
    _pump();
  }

  void _pump() {
    while (_active < _maxActive) {
      final index = _queue.indexWhere(
        (j) => !j.background || _activeBackground < _maxBackground,
      );
      if (index < 0) return;
      final job = _queue.removeAt(index);
      _jobs.remove(job.key);
      final background = job.background;
      _active++;
      if (background) _activeBackground++;
      _render(job.url)
          .then(
            job.completer.complete,
            onError:
                (Object error, StackTrace stack) =>
                    job.completer.completeError(error, stack),
          )
          .whenComplete(() {
            _active--;
            if (background) _activeBackground--;
            _pump();
          });
    }
  }

  Future<String> _render(Uri url) async {
    final isListing = url.pathSegments.length == 2;
    Object? failure;
    final webView = HeadlessInAppWebView(
      initialUrlRequest: URLRequest(url: WebUri(url.toString())),
      initialSettings: InAppWebViewSettings(
        javaScriptEnabled: true,
        mediaPlaybackRequiresUserGesture: true,
        blockNetworkImage: _blockMedia,
        contentBlockers: _blockMedia ? _mediaBlockers : null,
      ),
      onReceivedError: (_, request, error) {
        if (request.isForMainFrame == true) {
          failure = const DltNewsException('โหลดข้อมูลข่าวจาก DLT ไม่สำเร็จ');
        }
      },
      onReceivedHttpError: (_, request, response) {
        if (request.isForMainFrame == true) {
          failure = const DltNewsException('เว็บไซต์ DLT ไม่พร้อมใช้งาน');
        }
      },
    );
    try {
      await webView.run().timeout(const Duration(seconds: 15));
      final deadline = DateTime.now().add(const Duration(seconds: 30));
      while (DateTime.now().isBefore(deadline)) {
        if (failure != null) throw failure!;
        final source = await webView.webViewController
            ?.evaluateJavascript(
              source: isListing ? _listingScript : _detailScript,
            )
            .timeout(const Duration(seconds: 5));
        if (source is String && source.isNotEmpty) return source;
        await Future<void>.delayed(const Duration(milliseconds: 200));
      }
      if (kDebugMode) {
        final state = await webView.webViewController?.evaluateJavascript(
          source: '''
JSON.stringify({
  url: location.href,
  cards: document.querySelectorAll('#pills-g .card').length,
  selected: document.querySelector('#filter_show')?.value,
  contentBody: !!document.querySelector('#contentBody'),
  cardContent: !!document.querySelector('.card-content'),
  detail: !!document.querySelector('.detail-content'),
  detailText: (document.querySelector('.detail-content')?.textContent || '').trim().length,
  detailImgs: document.querySelectorAll('.detail-content img').length,
  fancybox: document.querySelectorAll('a[data-fancybox]').length,
  gallery: document.querySelector('#galleryCPN')?.children.length,
  cardHtml: (document.querySelector('#contentBody .card-content')?.outerHTML || '').slice(0, 700),
  outline: Array.from(document.querySelectorAll('.card-content *'))
    .filter(e => ['DIV','SECTION','ARTICLE','P','H1','H2','H3'].includes(e.tagName))
    .slice(0, 30)
    .map(e => e.tagName.toLowerCase() + '.' + e.className + ':' + (e.textContent || '').trim().length),
  pills: (document.querySelector('#pills-g')?.textContent || '').slice(-350),
  bodyStart: (document.body?.innerText || '').slice(0, 200)
})
''',
        );
        debugPrint('DLT page timeout: $state');
      }
      if (!isListing) {
        // The page loaded but its article body never filled in. Hand back what
        // is there so the detail page still shows the title and cover instead
        // of an error.
        try {
          final partial = await webView.webViewController
              ?.evaluateJavascript(source: _partialDetailScript)
              .timeout(const Duration(seconds: 5));
          if (partial is String && partial.isNotEmpty) return partial;
        } catch (_) {}
      }
      throw const DltNewsException('โหลดข้อมูลข่าวนานเกินไป กรุณาลองใหม่');
    } finally {
      await webView.dispose();
    }
  }

  // Use the public page's page-size control so RSS items 13–20 also get images.
  static const _listingScript = r'''
(() => {
  const root = document.querySelector('#pills-g');
  if (!root || !root.querySelector('.card')) return null;
  const select = document.querySelector('#filter_show');
  if (select && select.value !== '24') {
    select.value = '24';
    select.dispatchEvent(new Event('change', {bubbles: true}));
    return null;
  }
  const count = root.querySelectorAll('.card').length;
  const totalMatch = root.textContent.match(/จำนวนหน้าทั้งหมด\s*([\d,]+)\s*รายการ/);
  const total = totalMatch ? Number(totalMatch[1].replace(/,/g, '')) : 24;
  window.__dltTries = (window.__dltTries || 0) + 1;
  if (select && count < Math.min(24, total) && window.__dltTries < 25) return null;
  return root.outerHTML;
})()
''';

  // Finds the article body when `.detail-content` stays empty: the largest
  // block inside the article container that does not contain the date/views
  // row. Wrapped so parseDetail() still finds `.card-content` and
  // `.detail-content`.
  static const _bodyBlockJs = r'''
const dltBodyBlock = (root) => {
  let best = null, bestLen = 0;
  for (const el of root.querySelectorAll('div, section, article')) {
    if (el.closest('.dateVL') || el.querySelector('.dateVL')) continue;
    const len = (el.textContent || '').trim().length;
    if (len > bestLen) { best = el; bestLen = len; }
  }
  return bestLen >= 40 ? best : null;
};
const dltWrap = (root) => {
  const block = dltBodyBlock(root);
  if (!block) return null;
  const meta = root.querySelector('.dateVL');
  return '<div class="card-content">' + (meta ? meta.outerHTML : '') +
    '<div class="detail-content">' + block.innerHTML + '</div></div>';
};
''';

  // Normal pages behave exactly as before (strict check, so the gallery is
  // already populated). If the strict check never passes, after ~30 tries
  // (~6 s) a relaxed check accepts a filled `.detail-content`, an image or a
  // fancybox link, and finally the generic body-block search.
  static const _detailScript = '''
(() => {
  $_bodyBlockJs
  const strictRoot = document.querySelector('#contentBody .card-content');
  const strict = strictRoot && strictRoot.querySelector('.detail-content');
  if (strict && (strict.textContent.trim() || strict.querySelector('img'))) {
    return strictRoot.outerHTML;
  }
  window.__dltDetailTries = (window.__dltDetailTries || 0) + 1;
  if (window.__dltDetailTries < 30) return null;
  const root = document.querySelector('.card-content');
  if (!root) return null;
  const content = root.querySelector('.detail-content');
  if (content && (content.textContent.trim() || content.querySelector('img') ||
      document.querySelector('a[data-fancybox]'))) {
    return root.outerHTML;
  }
  return dltWrap(root);
})()
''';

  // Used only after the normal detail check has timed out: return whatever the
  // page has so the detail page shows the title and cover instead of an error.
  static const _partialDetailScript = '''
(() => {
  $_bodyBlockJs
  const root = document.querySelector('#contentBody .card-content') ||
    document.querySelector('.card-content');
  if (!root) return null;
  return dltWrap(root) ||
    (root.querySelector('.detail-content') ? root.outerHTML : null);
})()
''';
}
