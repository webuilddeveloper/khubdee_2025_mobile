import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

/// Bounded disk cache for public DLT content, shared across app launches.
class DltNewsCache {
  DltNewsCache({Future<Directory> Function()? directory})
    : _directory = directory ?? getTemporaryDirectory;
  static final instance = DltNewsCache();
  final Future<Directory> Function() _directory;
  final _pending = <String, Future<File>>{};
  final _files = <String, File>{};
  Future<Directory>? _root;

  Future<Directory> _folder() =>
      _root ??=
          (() async {
            final base = await _directory();
            final dir = await Directory(
              '${base.path}/dlt-news-v1',
            ).create(recursive: true);
            final files =
                await dir.list().where((e) => e is File).cast<File>().toList();
            final entries = await Future.wait(
              files.map((f) async => (file: f, stat: await f.stat())),
            );
            entries.sort((a, b) => b.stat.modified.compareTo(a.stat.modified));
            var size = 0;
            for (var i = 0; i < entries.length; i++) {
              size += entries[i].stat.size;
              if (i >= 150 || size > 100 * 1024 * 1024) {
                try {
                  await entries[i].file.delete();
                } catch (_) {}
              }
            }
            return dir;
          })();

  Future<File> _file(String key) async {
    final dir = await _folder();
    return File('${dir.path}/${sha256.convert(utf8.encode(key))}');
  }

  Future<String> text(
    Uri url,
    Future<String> Function() load, {
    bool refresh = false,
    Duration maxAge = const Duration(minutes: 15),
  }) async {
    File? file;
    try {
      file = await _file('text:$url');
      if (!refresh &&
          await file.exists() &&
          DateTime.now().difference(await file.lastModified()) < maxAge) {
        return await file.readAsString();
      }
    } catch (_) {
      /* Cache failures must not prevent network loading. */
    }
    final source = await load();
    try {
      await file?.writeAsString(source, flush: true);
    } catch (_) {}
    return source;
  }

  File? cachedImage(Uri url) => _files[url.toString()];

  Future<File> image(Uri url) {
    final key = url.toString();
    return _pending.putIfAbsent(key, () async {
      try {
        final file = await _file('image:$url');
        if (!await file.exists() ||
            await file.length() == 0 ||
            DateTime.now().difference(await file.lastModified()) >
                const Duration(days: 7)) {
          final response = await http
              .get(url)
              .timeout(const Duration(seconds: 20));
          if (response.statusCode != 200)
            throw const HttpException('Image unavailable');
          final temp = File('${file.path}.tmp');
          await temp.writeAsBytes(response.bodyBytes, flush: true);
          await temp.rename(file.path);
        }
        _files[key] = file;
        return file;
      } finally {
        _pending.remove(key);
      }
    });
  }
}
