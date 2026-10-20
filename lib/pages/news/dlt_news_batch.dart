import 'package:flutter/material.dart';
import 'package:KhubDeeDLT/shared/dlt_news_runtime.dart';
import 'package:KhubDeeDLT/pages/news/dlt_news_card.dart';
import 'package:KhubDeeDLT/shared/dlt_news_service.dart';

/// Titles stay available while this batch's images are fetched independently.
class DltNewsBatch extends StatefulWidget {
  const DltNewsBatch({
    super.key,
    required this.articles,
    required this.service,
  });
  final List<DltNewsArticle> articles;
  final DltNewsService service;

  @override
  State<DltNewsBatch> createState() => _DltNewsBatchState();
}

class _DltNewsBatchState extends State<DltNewsBatch> {
  late Future<List<DltNewsArticle>> _images;

  @override
  void initState() {
    super.initState();
    _images = widget.service.loadImages(widget.articles);
    if (identical(widget.service, DltNewsRuntime.instance.service)) {
      DltNewsRuntime.instance.prepare(widget.articles);
    }
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<List<DltNewsArticle>>(
    future: _images,
    initialData: widget.articles,
    builder:
        (context, snapshot) => Column(
          children: [
            if (snapshot.connectionState != ConnectionState.done)
              const LinearProgressIndicator(),
            if (snapshot.hasError)
              TextButton(
                onPressed:
                    () => setState(() {
                      _images = widget.service.loadImages(widget.articles);
                    }),
                child: const Text('โหลดรูปไม่สำเร็จ แตะเพื่อลองอีกครั้ง'),
              ),
            for (final article in snapshot.data ?? widget.articles)
              DltNewsCard(article: article, service: widget.service),
          ],
        ),
  );
}
