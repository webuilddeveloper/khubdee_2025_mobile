import 'package:flutter/material.dart';
import 'package:KhubDeeDLT/component/key_search.dart';
import 'package:KhubDeeDLT/component/header.dart';
import 'package:KhubDeeDLT/component/tab_category.dart';
import 'package:KhubDeeDLT/pages/news/news_list_vertical.dart';
import 'package:KhubDeeDLT/shared/api_provider.dart' as service;
import 'package:pull_to_refresh/pull_to_refresh.dart';

class NewsList extends StatefulWidget {
  const NewsList({super.key, required this.title});

  final String title;

  @override
  // ignore: library_private_types_in_public_api
  _NewsList createState() => _NewsList();
}

class _NewsList extends State<NewsList> {
  late NewsListVertical news;
  bool hideSearch = true;
  final txtDescription = TextEditingController();
  String keySearch = '';
  late String category;
  int _limit = 10;

  final RefreshController _refreshController = RefreshController(
    initialRefresh: false,
  );

  @override
  void initState() {
    super.initState();

    news = NewsListVertical(
      site: "DDPM",
      model: service.post('${service.newsApi}read', {
        'skip': 0,
        'limit': _limit,
      }),
      url: '${service.newsApi}read',
      urlComment: '${service.newsCommentApi}read',
      urlGallery: service.newsGalleryApi,
      title: '',
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onLoading() async {
    setState(() {
      _limit = _limit + 10;

      news = NewsListVertical(
        site: 'DDPM',
        model: service.post('${service.newsApi}read', {
          'skip': 0,
          'limit': _limit,
          "keySearch": keySearch,
          'category': category,
        }),
        url: '${service.newsApi}read',
        urlGallery: service.newsGalleryApi,
        title: '',
        urlComment: '',
      );
    });

    await Future.delayed(const Duration(milliseconds: 1000));

    _refreshController.loadComplete();
  }

  void goBack() async {
    Navigator.pop(context, false);
    // Navigator.of(context).push(
    //   MaterialPageRoute(
    //     builder: (context) => Menu(),
    //   ),
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      appBar: header(context, goBack, title: widget.title, isBg: false),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ShaderMask(
              shaderCallback: (rect) {
                return const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white, // เห็นภาพชัด
                    Colors.transparent, // ค่อย ๆ หายไป
                  ],
                ).createShader(rect);
              },
              blendMode: BlendMode.dstIn,
              child: Image.asset(
                'assets/bg_header.png',
                width: double.infinity,
                fit: BoxFit.cover,
                height: 250, // ปรับความยาวของ fade ได้
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: kToolbarHeight + 64),
            child: NotificationListener<OverscrollIndicatorNotification>(
              onNotification: (OverscrollIndicatorNotification overScroll) {
                overScroll.disallowIndicator();
                return false;
              },
              child: Column(
                children: [
                  CategorySelector(
                    model: service.postCategory(
                      '${service.newsCategoryApi}read',
                      {'skip': 0, 'limit': 100},
                    ),
                    onChange: (String val) {
                      setState(() {
                        category = val;
                        news = NewsListVertical(
                          site: 'DDPM',
                          model: service.post('${service.newsApi}read', {
                            'skip': 0,
                            'limit': _limit,
                            "category": category,
                            "keySearch": keySearch,
                          }),
                          url: '${service.newsApi}read',
                          urlGallery: service.newsGalleryApi,
                          title: '',
                          urlComment: '',
                        );
                      });
                    },
                  ),
                  const SizedBox(height: 5),
                  KeySearch(
                    show: hideSearch,
                    onKeySearchChange: (String val) {
                      // newsList(context, service.post('${service.newsApi}read', {'skip': 0, 'limit': 100,"keySearch": val}),'');
                      setState(() {
                        keySearch = val;
                        news = NewsListVertical(
                          site: 'DDPM',
                          model: service.post('${service.newsApi}read', {
                            'skip': 0,
                            'limit': _limit,
                            "keySearch": keySearch,
                            'category': category,
                          }),
                          url: '${service.newsApi}read',
                          urlGallery: service.newsGalleryApi,
                          title: '',
                          urlComment: '',
                        );
                      });
                    },
                  ),
                  // const SizedBox(height: 15),
                  Expanded(
                    child: SmartRefresher(
                      enablePullDown: true,
                      enablePullUp: true,
                      footer: const ClassicFooter(
                        loadingText: ' ',
                        canLoadingText: ' ',
                        idleText: ' ',
                        idleIcon: Icon(
                          Icons.arrow_upward,
                          color: Colors.transparent,
                        ),
                      ),
                      controller: _refreshController,
                      onLoading: _onLoading,
                      child: Container(
                        decoration: BoxDecoration(
      color: Colors.transparent,       // หรือ gradient / image ก็ได้
    ),
                        child: ListView(
                          padding: EdgeInsets.only(top: 15),
                          physics: const ScrollPhysics(),
                          shrinkWrap: false,
                          // controller: _controller,
                          children: [
                            // SubHeader(th: "ข่าวสารประชาสัมพันธ์", en: "News"),
                            
                            news,
                            // newsList(context, service.post('${service.newsApi}read', {'skip': 0, 'limit': 100}),''),
                            // Expanded(
                            //   child: news,
                            // ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
