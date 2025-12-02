import 'dart:convert';
import 'dart:async';
import 'package:KhubDeeDLT/home_v2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:KhubDeeDLT/component/header.dart';
import 'package:KhubDeeDLT/component/key_search.dart';
import 'package:KhubDeeDLT/pages/main_popup/dialog_main_popup.dart';
import 'package:KhubDeeDLT/pages/privilege/list_content_horizontal_privilege.dart';

import 'package:KhubDeeDLT/pages/privilege/list_content_horizontal_privlege_suggested.dart';
import 'package:KhubDeeDLT/pages/privilege/privilege_form.dart';
import 'package:KhubDeeDLT/pages/privilege/privilege_list.dart';
import 'package:KhubDeeDLT/pages/privilege/privilege_list_vertical.dart';
import 'package:KhubDeeDLT/shared/api_provider.dart';
import 'package:http/http.dart' as http;
import 'package:pull_to_refresh/pull_to_refresh.dart';

class PrivilegeMain extends StatefulWidget {
  const PrivilegeMain({
    super.key,
    required this.title,
    required this.fromPolicy,
  });
  final String title;
  final bool fromPolicy;

  @override
  // ignore: library_private_types_in_public_api
  _PrivilegeMain createState() => _PrivilegeMain();
}

class _PrivilegeMain extends State<PrivilegeMain> {
  final storage = const FlutterSecureStorage();

  late PrivilegeList privilegeList;
  late PrivilegeListVertical gridView;
  bool hideSearch = true;
  late Future<dynamic> _futurePromotion;
  // Future<dynamic> _futurePrivilegeCategory;
  late Future<dynamic> _futureForceAds;

  List<dynamic> listData = [];
  List<dynamic> category = [];
  bool isMain = true;
  String categorySelected = '';
  String keySearch = '';
  bool isHighlight = false;
  int _limit = 10;

  final RefreshController _refreshController = RefreshController(
    initialRefresh: false,
  );

  @override
  void initState() {
    _futurePromotion = post('${privilegeApi}read', {
      'skip': 0,
      'limit': 10,
      'isHighlight': true,
    });
    // _futurePrivilegeCategory =
    //     post('${privilegeCategoryApi}read', {'skip': 0, 'limit': 100});
    _futureForceAds = post('${forceAdsApi}read', {'skip': 0, 'limit': 10});
    categoryRead();
    getForceAds();
    super.initState();
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
              child: GestureDetector(
                onTap: () {
                  FocusScope.of(context).requestFocus(FocusNode());
                },
                child: Column(
                  children: [
                    const SizedBox(height: 5.0),
                    tabCategory(),
                    const SizedBox(height: 10.0),
                    KeySearch(
                      show: hideSearch,
                      onKeySearchChange: (String val) {
                        setState(() {
                          keySearch = val;
                        });
                      },
                    ),
                    Expanded(
                      child: SmartRefresher(
                        enablePullDown: false,
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
                        child: ListView(
                          padding: EdgeInsets.only(top: 15),
                          children: [
                            const SizedBox(height: 10.0),
                            keySearch == ''
                                ? isMain
                                    ? ListView(
                                      padding: EdgeInsets.zero,
                                      shrinkWrap: true,
                                      physics:
                                          const ClampingScrollPhysics(), // 2nd
                                      children: [
                                        ListContentHorizontalPrivilegeSuggested(
                                          title: 'แนะนำ',
                                          url: knowledgeApi,
                                          model: _futurePromotion,
                                          urlComment: '',
                                          navigationList: () {
                                            setState(() {
                                              keySearch = '';
                                              isMain = false;
                                              categorySelected = '';
                                            });
                                          },
                                          navigationForm: (
                                            String code,
                                            dynamic model,
                                          ) {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder:
                                                    (context) => PrivilegeForm(
                                                      code: code,
                                                      model: model,
                                                    ),
                                              ),
                                            );
                                          },
                                        ),
                                        for (
                                          int i = 0;
                                          i < listData.length;
                                          i++
                                        )
                                          ListContentHorizontalPrivilege(
                                            code: category[i]['code'],
                                            title: category[i]['title'],
                                            model: listData[i],
                                            navigationList: () {
                                              setState(() {
                                                keySearch = '';
                                                isMain = false;
                                                categorySelected =
                                                    category[i]['code'];
                                              });
                                            },
                                            navigationForm: (
                                              String code,
                                              dynamic model,
                                            ) {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder:
                                                      (context) =>
                                                          PrivilegeForm(
                                                            code: code,
                                                            model: model,
                                                          ),
                                                ),
                                              );
                                            },
                                          ),
                                      ],
                                    )
                                    : reloadList()
                                : reloadList(),
                            const SizedBox(height: 30.0),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<dynamic> showForceAds() async {
    var value = await storage.read(key: 'dataUserLoginDDPM');
    var user = json.decode(value!);

    var valueStorage = await storage.read(key: 'privilegeDDPM');
    // ignore: prefer_typing_uninitialized_variables
    var dataValue;
    if (valueStorage != null) {
      dataValue = json.decode(valueStorage);
    } else {
      dataValue = null;
    }

    var now = DateTime.now();
    DateTime date = DateTime(now.year, now.month, now.day);

    if (dataValue != null) {
      var index = dataValue.indexWhere(
        (c) =>
            c['username'] == user['username'] &&
            c['date'] == DateFormat("ddMMyyyy").format(date).toString() &&
            c['boolean'] == "true",
      );

      if (index == -1) {
        return showDialog(
          barrierDismissible: false, // close outside
          // ignore: use_build_context_synchronously
          context: context,
          builder: (_) {
            return MainPopupDialog(
              model: _futureForceAds,
              type: 'privilege',
              username: user['username'],
              url: '',
              urlGallery: '',
            );
          },
        );
      }
    } else {
      return showDialog(
        barrierDismissible: false, // close outside
        // ignore: use_build_context_synchronously
        context: context,
        builder: (_) {
          return MainPopupDialog(
            model: _futureForceAds,
            type: 'privilege',
            username: user['username'],
            url: '',
            urlGallery: '',
          );
        },
      );
    }
  }

  getForceAds() async {
    var result = await post('${forceAdsApi}read', {'skip': 0, 'limit': 100});
    if (result.length > 0) {
      showForceAds();
    }
  }

  Future<dynamic> categoryRead() async {
    var body = json.encode({
      "permission": "all",
      "skip": 0,
      "limit": 999, // integer value type
    });
    var response = await http.post(
      Uri.parse('${privilegeCategoryApi}read'),
      body: body,
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
    );

    var data = json.decode(response.body);
    setState(() {
      category = data['objectData'];
    });

    if (category.isNotEmpty) {
      for (int i = 0; i <= category.length - 1; i++) {
        var res = post('${privilegeApi}read', {
          'skip': 0,
          'limit': 10,
          'category': category[i]['code'],
        });
        listData.add(res);
      }
    }
  }

  void _onLoading() async {
    setState(() {
      _limit = _limit + 10;

      gridView = PrivilegeListVertical(
        site: 'CIO',
        model: post('${privilegeApi}read', {'skip': 0, 'limit': _limit}),
      );
    });

    await Future.delayed(const Duration(milliseconds: 1000));

    _refreshController.loadComplete();
  }

  reloadList() {
    return gridView = PrivilegeListVertical(
      site: 'DDPM',
      model: post('${privilegeApi}read', {
        'skip': 0,
        'limit': _limit,
        'keySearch': keySearch,
        'isHighlight': isHighlight,
        'category': categorySelected,
      }),
    );
  }

  void goBack() async {
    if (widget.fromPolicy) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => HomePageV2()),
        (Route<dynamic> route) => false,
      );
    } else {
      Navigator.pop(context, false);
    }
    // Navigator.of(context).push(
    //   MaterialPageRoute(
    //     builder: (context) => Menu(),
    //   ),
    // );
  }

  tabCategory() {
    return FutureBuilder<dynamic>(
      future: postCategory('${privilegeCategoryApi}read', {
        'skip': 0,
        'limit': 100,
      }), // function where you call your api
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        // AsyncSnapshot<Your object type>

        if (snapshot.hasData) {
          return Container(
            height: 45.0,
            padding: EdgeInsets.symmetric(horizontal: 3, vertical: 5),
            margin: const EdgeInsets.symmetric(horizontal: 10.0),
            decoration: BoxDecoration(
              // boxShadow: [
              //   BoxShadow(
              //     color: Colors.grey.withOpacity(0.5),
              //     spreadRadius: 0,
              //     blurRadius: 7,
              //     offset: const Offset(0, 3), // changes position of shadow
              //   ),
              // ],
              // borderRadius: BorderRadius.circular(6.0),
              color: Colors.transparent,
            ),
            child: ListView.separated(
              separatorBuilder: (context, index) => SizedBox(width: 5),
              scrollDirection: Axis.horizontal,
              itemCount: snapshot.data.length,
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () {
                    if (snapshot.data[index]['code'] != '') {
                      setState(() {
                        keySearch = '';
                        isMain = false;
                        isHighlight = false;
                        categorySelected = snapshot.data[index]['code'];
                      });
                    } else {
                      setState(() {
                        isHighlight = true;
                        categorySelected = '';
                        isMain = true;
                      });
                    }
                    setState(() {
                      categorySelected = snapshot.data[index]['code'];
                      // selectedIndex = index;
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 6.0,
                    ),
                    decoration: BoxDecoration(
                      color: categorySelected == snapshot.data[index]['code'] ? Theme.of(context).primaryColor : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),

                      boxShadow: [
                        BoxShadow(
                          color: categorySelected == snapshot.data[index]['code'] ? Theme.of(context).primaryColor.withOpacity(0.5) : Colors.transparent,
                          spreadRadius: 0,
                          blurRadius: 4,
                          offset: Offset(0, 2), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Text(
                      snapshot.data[index]['title'],
                      style: TextStyle(
                        color:
                            categorySelected == snapshot.data[index]['code']
                                ? Colors.white
                                : Theme.of(context).primaryColor,
                        // decoration:
                        //     categorySelected == snapshot.data[index]['code']
                        //         ? TextDecoration.underline
                        //         : null,
                        fontSize: 16.0,
                        fontWeight: categorySelected == snapshot.data[index]['code'] ? FontWeight.bold : FontWeight.normal,
                        // letterSpacing: 1.2,
                        fontFamily: 'Sarabun',
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        } else {
          return Container(
            height: 45.0,
            padding: const EdgeInsets.only(left: 5.0, right: 5.0),
            margin: const EdgeInsets.symmetric(horizontal: 30.0),
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 0,
                  blurRadius: 7,
                  offset: const Offset(0, 3), // changes position of shadow
                ),
              ],
              borderRadius: BorderRadius.circular(6.0),
              color: Colors.white,
            ),
          );
        }
      },
    );
  }
}
