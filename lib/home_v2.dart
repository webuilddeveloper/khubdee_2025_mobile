import 'dart:convert';

import 'package:KhubDeeDLT/component/material/custom_alert_dialog.dart';
import 'package:KhubDeeDLT/fund/fund-main.dart';
import 'package:KhubDeeDLT/fund/fund-recommend.dart';
import 'package:KhubDeeDLT/pages/behavior_points.dart';
import 'package:KhubDeeDLT/pages/profile/driver_license_consent.dart';
import 'package:KhubDeeDLT/pages/profile/drivers_info.dart';
import 'package:KhubDeeDLT/pages/profile/register_with_diver_license.dart';
import 'package:KhubDeeDLT/pages/profile/register_with_license_plate.dart';
import 'package:KhubDeeDLT/pages/traffic_ticket.dart';
import 'package:KhubDeeDLT/pages/training/training_main.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:KhubDeeDLT/component/carousel_rotation.dart';
import 'package:KhubDeeDLT/component/material/check_avatar.dart';
import 'package:KhubDeeDLT/component/menu/build_verify_ticket.dart';
import 'package:KhubDeeDLT/component/menu/color_item.dart';
import 'package:KhubDeeDLT/component/menu/image_item.dart';
import 'package:KhubDeeDLT/component/v2/button_menu_full.dart';
import 'package:KhubDeeDLT/login.dart';
import 'package:KhubDeeDLT/pages/blank_page/blank_loading.dart';
import 'package:KhubDeeDLT/pages/blank_page/toast_fail.dart';
import 'package:KhubDeeDLT/pages/dispute_an_allegation.dart';
import 'package:KhubDeeDLT/pages/reporter/reporte r_main.dart';
import 'package:KhubDeeDLT/pages/warning/warning_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:KhubDeeDLT/component/carousel_banner.dart';
import 'package:KhubDeeDLT/pages/about_us/about_us_form.dart';
import 'package:KhubDeeDLT/pages/menu_grid_item.dart';
import 'package:KhubDeeDLT/pages/notification/notification_list.dart';
import 'package:KhubDeeDLT/pages/poi/poi_list.dart';
import 'package:KhubDeeDLT/pages/poi/poi_main.dart';
import 'package:KhubDeeDLT/pages/poll/poll_list.dart';
import 'package:KhubDeeDLT/pages/welfare/welfare_list.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:KhubDeeDLT/pages/contact /contact_list_category.dart';
import 'package:KhubDeeDLT/pages/news/news_list.dart';
import 'package:KhubDeeDLT/pages/privilege/privilege_main.dart';
import 'package:KhubDeeDLT/pages/profile/user_information.dart';
import 'package:KhubDeeDLT/profile.dart';
import 'package:KhubDeeDLT/shared/api_provider.dart';
import 'package:KhubDeeDLT/component/carousel_form.dart';
import 'pages/event_calendar/event_calendar_main.dart';
import 'pages/knowledge/knowledge_list.dart';
import 'pages/main_popup/dialog_main_popup.dart';

class HomePageV2 extends StatefulWidget {
  const HomePageV2({super.key});

  @override
  _HomePageV2State createState() => _HomePageV2State();
}

class _HomePageV2State extends State<HomePageV2> {
  final storage = new FlutterSecureStorage();
  late DateTime currentBackPressTime;

  late Future<dynamic> _futureBanner = Future.value(null);
  late Future<dynamic> _futureProfile = Future.value(null);
  late Future<dynamic> _futureMenu = Future.value(null);
  late Future<dynamic> _futureRotation = Future.value(null);
  late Future<dynamic> _futureAboutUs = Future.value(null);
  late Future<dynamic> _futureMainPopUp = Future.value(null);
  late Future<dynamic> _futureVerifyTicket = Future.value(null);
  static bool isFirstFund = true;

  String profileCode = '';
  String currentLocation = '-';
  final seen = Set<String>();
  List unique = [];
  List imageLv0 = [];
  String test11 = '2';
  bool chkisCard = false;
  bool notShowOnDay = false;
  bool hiddenMainPopUp = false;

  final RefreshController _refreshController = RefreshController(
    initialRefresh: false,
  );

  LatLng latLng = LatLng(13.743989326935178, 100.53754006134743);

  @override
  void initState() {
    _read();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      // backgroundColor: Colors.white,
      // appBar: _buildHeader(),
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
                'assets/background/bg_purple.png',
                width: double.infinity,
                fit: BoxFit.cover,
                // height: 200, // ปรับความยาวของ fade ได้
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 50),
            child: WillPopScope(
              onWillPop: confirmExit,
              child: Column(
                children: [
                  _buildProfile(),
                  Expanded(child: _buildBackground()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> confirmExit() {
    DateTime now = DateTime.now();
    if (now.difference(currentBackPressTime) > Duration(seconds: 2)) {
      currentBackPressTime = now;
      toastFail(
        context,
        text: 'กดอีกครั้งเพื่อออก',
        color: Colors.black,
        fontColor: Colors.white,
      );
      return Future.value(false);
    }
    return Future.value(true);
  }

  _buildBackground() {
    return Container(
      // decoration: BoxDecoration(
      //   gradient: LinearGradient(
      //     colors: [
      //       Color(0xFFFF7900),
      //       Color(0xFFFF7900),
      //       Color(0xFFFFFFFF),
      //     ],
      //     begin: Alignment.topCenter,
      //     // end: new Alignment(1, 0.0),
      //     end: Alignment.bottomCenter,
      //   ),
      // ),
      padding: EdgeInsets.fromLTRB(15, 15, 15, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: _buildNotificationListener(),
    );
  }

  _buildNotificationListener() {
    return NotificationListener<OverscrollIndicatorNotification>(
      onNotification: (OverscrollIndicatorNotification overScroll) {
        overScroll.disallowIndicator();
        return false;
      },
      child: _buildSmartRefresher(),
    );
  }

  _buildSmartRefresher() {
    return SmartRefresher(
      enablePullDown: true,
      enablePullUp: false,
      header: WaterDropHeader(
        complete: Container(child: Text('')),
        completeDuration: Duration(milliseconds: 0),
      ),
      footer: CustomFooter(
        builder: (BuildContext context, LoadStatus? mode) {
          Widget body;
          if (mode == LoadStatus.idle) {
            body = const Text("pull up load");
          } else if (mode == LoadStatus.loading) {
            body = Text("loading");
          } else if (mode == LoadStatus.failed) {
            body = Text("Load Failed!Click retry!");
          } else if (mode == LoadStatus.canLoading) {
            body = Text("release to load more");
          } else {
            body = Text("No more Data");
          }
          return Container(height: 55.0, child: Center(child: body));
        },
      ),
      controller: _refreshController,
      onRefresh: _onRefresh,
      onLoading: _onLoading,
      child: _buildMenu(),

      // Column(
      //   children: [
      //     // Container(
      //     //   height: (height * 25) / 100,
      //     //   child:

      //     SizedBox(
      //       height: 1.0,
      //     ),

      //     SizedBox(
      //       height: 1.0,
      //     ),

      // Container(
      //   height: 70.0,
      //   child: CardHorizontal(
      //     title: model[11]['title'] != '' ? model[11]['title'] : '',
      //     imageUrl: model[11]['imageUrl'],
      //     model: _futureMenu,
      //     userData: userData,
      //     subTitle: 'สำหรับสมาชิก',
      //     nav: () {
      //       // Navigator.push(
      //       //   context,
      //       //   MaterialPageRoute(
      //       //     builder: (context) => PrivilegeMain(
      //       //       title: model[11]['title'],
      //       //     ),
      //       //   ),
      //       // );
      //     },
      //   ),
      // ),
      //   ],
      // ),
      // ),
    );
  }

  _buildMenu() {
    return ListView(
      // shrinkWrap: true,
      children: [
        // _buildProfile(),
        SizedBox(height: 160, child: _buildBanner()),

        const SizedBox(height: 15),
        _buildService(),
        const SizedBox(height: 15),
        _buildMenuGroup(),
        const SizedBox(height: 15),
        cardMenu2(
          imageMenuUrl: 'assets/icons/menu_bottom_3.png',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TrainingMain()),
            );
          },
        ),
        // const SizedBox(height: 15),
        cardMenu(
          imageMenuUrl: 'assets/icons/menu_bottom_2.png',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => KnowledgeList(title: 'ความรู้คู่การขับขี่'),
              ),
            );
          },
        ),
        const SizedBox(height: 15),
        _buildcardFund(),
        const SizedBox(height: 15),
        _buildRotation(),
        const SizedBox(height: 15),
        _buildFooter(),
        const SizedBox(height: 100),
      ],
    );
  }

  _buildBanner() {
    return CarouselBanner(
      model: _futureBanner,
      nav: (
        String path,
        String action,
        dynamic model,
        String code,
        String urlGallery,
      ) {
        if (action == 'out') {
          // launchInWebViewWithJavaScript(path);
          // launchURL(path);
          launch(path);
        } else if (action == 'in') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => CarouselForm(
                    code: code,
                    model: model,
                    url: mainBannerApi,
                    urlGallery: bannerGalleryApi,
                  ),
            ),
          );
        }
      },
    );
  }

  _buildService() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          // color: Color(0xFF000070),
          // padding: EdgeInsets.symmetric(horizontal: 5),
          alignment: Alignment.center,
          padding: const EdgeInsets.only(right: 10),
          height: 40,
          child: Row(
            children: [
              // Icon(Icons.pin_drop, color: Colors.orange[400]),
              Text(
                // ' ' + currentLocation,
                'บริการ',
                style: TextStyle(
                  fontFamily: 'Kanit',
                  color: Colors.black,
                  fontSize: 16,
                  // color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        Container(
          // color: Color(0xFF000070),
          // padding: EdgeInsets.symmetric(horizontal: 5),
          alignment: Alignment.center,
          padding: const EdgeInsets.only(left: 10),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'ดูทั้งหมด',
                style: TextStyle(
                  fontFamily: 'Kanit',
                  color: Color(0xFF808080),
                  // fontSize: 10,
                  // color: Colors.white,
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 13, color: Color(0xFF808080)),
            ],
          ),
        ),
      ],
    );
  }

  cardMenu({required VoidCallback onTap, required String imageMenuUrl}) {
    return GestureDetector(onTap: onTap, child: Image.asset(imageMenuUrl));
  }

  cardMenu2({required VoidCallback onTap, required String imageMenuUrl}) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          

          Image.asset(imageMenuUrl),
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Color(0xFF4A0768),
                borderRadius: BorderRadius.only(topRight: Radius.circular(16), bottomLeft: Radius.circular(16))
              ),
              child: Text(
                'เรียนรู้และอบรม \n(Training & Upskill Academy)',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500
                ),
                textAlign: TextAlign.center,
              ))),
        ],
      ),
    );
  }

  Widget _buildMenuGroup() {
    return GridView(
      padding: EdgeInsets.zero,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1,
        crossAxisSpacing: 7,
        mainAxisSpacing: 7,
      ),
      physics: ClampingScrollPhysics(),
      shrinkWrap: true,
      children: [
        cardMenu(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => const NewsList(title: 'ข่าวประชาสัมพันธ์'),
              ),
            );
          },
          imageMenuUrl: 'assets/icons/menu1.png',
        ),
        cardMenu(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DriversInfo()),
            );
          },
          imageMenuUrl: 'assets/icons/menu2.png',
        ),
        cardMenu(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => BehaviorPoints()),
            );
          },
          imageMenuUrl: 'assets/icons/menu3.png',
        ),
        cardMenu(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TrafficTicket()),
            );
          },
          imageMenuUrl: 'assets/icons/menu4.png',
        ),
        cardMenu(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ContactListCategory(title: 'เบอร์ติดต่อ'),
              ),
            );
          },
          imageMenuUrl: 'assets/icons/menu5.png',
        ),
        cardMenu(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) =>
                    // PrivilegeSpecialList(title: 'สิทธิพิเศษ'),
                    PrivilegeMain(title: 'สิทธิประโยชน์', fromPolicy: false),
              ),
            );
          },
          imageMenuUrl: 'assets/icons/menu6.png',
        ),
      ],
    );
  }

  _buildProfile() {
    // return Profile(model: _futureProfile);
    return FutureBuilder<dynamic>(
      future: _futureProfile,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          return _buildCardProfile(snapshot.data);
        } else if (snapshot.hasError) {
          return const BlankLoading();
        } else {
          return const BlankLoading();
        }
      },
    );
  }

  _buildCardProfile(dynamic model) {
    return Container(
      height: 118,
      // color: Colors.white,
      child: GestureDetector(
        onTap: () {
          // ? Navigator.push(
          //     context,
          //     MaterialPageRoute(
          //         builder: (context) => DriverLicenseConsentPage()),
          //   )
          model['isDF'] == false
              ? showDialog(
                context: context,
                builder: (BuildContext context) {
                  return _buildDialogdriverLicence();
                },
              )
              : Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DriversInfo()),
              );

          // Navigator.push(
          //         context,
          //         MaterialPageRoute(
          //           builder: (context) => DriversInfo(),
          //         ),
          //       );
        },
        onLongPress: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DriversInfo()),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            // margin: const EdgeInsets.only(top: 5, right: 5, bottom: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.transparent,

              // gradient: LinearGradient(
              //   colors: [Color(0xFFAF86B5), Color(0xFF7948AD)],
              //   begin: Alignment.centerLeft,
              //   // end: new Alignment(1, 0.0),
              //   end: Alignment.centerRight,
              // ),
            ),
            child: Row(
              children: [
                Container(
                  // padding: EdgeInsets.all(
                  //   '${model['imageUrl']}' != '' ? 0.0 : 5.0,
                  // ),
                  height: 120,
                  width: 90,
                  child: checkAvatar(context, '${model['imageUrl']}'),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 5,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        model['isDF'] == false
                            ? Container(
                              padding: const EdgeInsets.only(
                                left: 10,
                                right: 10,
                                bottom: 5.0,
                                top: 5.0,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Text(
                                    '${model['firstName']} ${model['lastName']}',
                                    style: const TextStyle(
                                      fontSize: 16.0,
                                      color: Colors.white,
                                      fontFamily: 'Kanit',
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 5),
                                  Container(
                                    padding: const EdgeInsets.only(
                                      left: 10,
                                      right: 10,
                                      bottom: 5,
                                      top: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(48),
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.15),
                                          spreadRadius: 1,
                                          blurRadius: 4,
                                          offset: Offset(
                                            0,
                                            2,
                                          ), // changes position of shadow
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      'รอยืนยันตัวตน',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),

                                  // const SizedBox(height: 10),
                                  // Row(
                                  //   children: [
                                  //     const Text(
                                  //       'ID Card : ',
                                  //       style: TextStyle(
                                  //         fontSize: 11.0,
                                  //         color: Colors.white,
                                  //         fontFamily: 'Kanit',
                                  //       ),
                                  //     ),
                                  //     Expanded(
                                  //       child: Text(
                                  //         model['idcard'] ??
                                  //             'กรุณาอัพเดทข้อมูล',
                                  //         style: const TextStyle(
                                  //           fontSize: 11.0,
                                  //           color: Colors.white,
                                  //           fontFamily: 'Kanit',
                                  //         ),
                                  //         maxLines: 2,
                                  //       ),
                                  //     ),
                                  //   ],
                                  // ),
                                ],
                              ),
                            )
                            : Container(
                              padding: const EdgeInsets.only(
                                left: 10,
                                right: 10,
                                bottom: 5.0,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Row(
                                    children: [
                                      const Text(
                                        'ID Card : ',
                                        style: TextStyle(
                                          fontSize: 13.0,
                                          color: Colors.white,
                                          fontFamily: 'Kanit',
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          model['idcard'] ??
                                              'กรุณาอัพเดทข้อมูล',
                                          style: const TextStyle(
                                            fontSize: 13.0,
                                            color: Colors.white,
                                            fontFamily: 'Kanit',
                                          ),
                                          maxLines: 2,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '${model['firstName']} ${model['lastName']}',
                                    style: const TextStyle(
                                      fontSize: 13.0,
                                      color: Colors.white,
                                      fontFamily: 'Kanit',
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                        // if(model['isDF'] != false)
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _buildDialogdriverLicence() {
    return WillPopScope(
      onWillPop: () {
        return Future.value(false);
      },
      child: CustomAlertDialog(
        contentPadding: const EdgeInsets.all(0),
        content: Container(
          width: 325,
          height: 351,
          // width: MediaQuery.of(context).size.width / 1.3,
          // height: MediaQuery.of(context).size.height / 2.5,
          decoration: new BoxDecoration(
            shape: BoxShape.rectangle,
            color: const Color(0xFFFFFF),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.white,
            ),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Image.asset('assets/check_register.png', height: 50),
                // Icon(
                //   Icons.check_circle_outline_outlined,
                //   color: Color(0xFF5AAC68),
                //   size: 60,
                // ),
                const SizedBox(height: 10),
                const Text(
                  'ยืนยันตัวตน',
                  style: TextStyle(
                    fontFamily: 'Kanit',
                    fontSize: 15,
                    // color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'กรุณายืนยันตัวผ่านตัวเลือกดังต่อไปนี้',
                  style: TextStyle(
                    fontFamily: 'Kanit',
                    fontSize: 15,
                    color: Color(0xFF4D4D4D),
                  ),
                ),
                const SizedBox(height: 28),
                Container(height: 0.5, color: const Color(0xFFcfcfcf)),
                InkWell(
                  onTap: () {
                    // Navigator.pop(context,false);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DriverLicenseConsentPage(),
                      ),
                    );
                  },
                  child: Container(
                    height: 45,
                    alignment: Alignment.center,
                    child: const Text(
                      'ยืนยันตัวตนผ่านแอพ ThaID',
                      style: TextStyle(
                        fontFamily: 'Kanit',
                        fontSize: 15,
                        color: Color(0xFF4D4D4D),
                      ),
                    ),
                  ),
                ),
                Container(height: 0.5, color: const Color(0xFFcfcfcf)),
                InkWell(
                  onTap: () {
                    // Navigator.pop(context,false);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RegisterWithDriverLicense(),
                      ),
                    );
                  },
                  child: Container(
                    height: 45,
                    alignment: Alignment.center,
                    child: const Text(
                      'ยืนยันตัวตนผ่านใบขับขี่',
                      style: TextStyle(
                        fontFamily: 'Kanit',
                        fontSize: 15,
                        color: Color(0xFF4D4D4D),
                      ),
                    ),
                  ),
                ),
                Container(height: 0.5, color: const Color(0xFFcfcfcf)),
                InkWell(
                  onTap: () {
                    // Navigator.pop(context,false);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RegisterWithLicensePlate(),
                      ),
                    );
                  },
                  child: Container(
                    height: 45,
                    alignment: Alignment.center,
                    child: const Text(
                      'ยืนยันตัวตนผ่านทะเบียนรถที่ครอบครอง',
                      style: TextStyle(
                        fontFamily: 'Kanit',
                        fontSize: 15,
                        color: Color(0xFF4D4D4D),
                      ),
                    ),
                  ),
                ),
                Container(height: 0.5, color: const Color(0xFFcfcfcf)),
                InkWell(
                  onTap: () {
                    Navigator.pop(context, false);
                  },
                  child: Container(
                    height: 45,
                    alignment: Alignment.center,
                    child: const Text(
                      'ยกเลิก',
                      style: TextStyle(
                        fontFamily: 'Kanit',
                        fontSize: 15,
                        color: Color(0xFF9C0000),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _buildRotation() {
    return CarouselRotation(
      model: _futureRotation,
      nav: (String path, String action, dynamic model, String code) {
        if (action == 'out') {
          // launchInWebViewWithJavaScript(path);
          // launchURL(path);
          launch(path);
        } else if (action == 'in') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => CarouselForm(
                    code: code,
                    model: model,
                    url: mainBannerApi,
                    urlGallery: bannerGalleryApi,
                  ),
            ),
          );
        }
      },
    );
  }

  _buildFooter() {
    return Container(
      // height: 70,
      padding: EdgeInsets.symmetric(horizontal: 80, vertical: 15),
      child: Image.asset(
        'assets/background/background_mics_webuilds.png',
        fit: BoxFit.cover,
      ),
    );
  }

  _read() async {
    // print('-------------start response------------');

    _getLocation();

    //read profile
    profileCode = (await storage.read(key: 'profileCode2'))!;
    if (profileCode != '') {
      setState(() {
        _futureProfile = postDio(profileReadApi, {"code": profileCode});
      });
      _futureMenu = postDio('${menuApi}read', {'limit': 10});
      _futureBanner = postDio('${mainBannerApi}read', {'limit': 10});
      _futureRotation = postDio('${mainRotationApi}read', {'limit': 10});
      _futureMainPopUp = postDio('${mainPopupHomeApi}read', {'limit': 10});
      _futureAboutUs = postDio('${aboutUsApi}read', {});

      _futureVerifyTicket = postDio(getNotpaidTicketListApi, {
        "createBy": "createBy",
        "updateBy": "updateBy",
        "card_id": "",
        "plate1": "3กท",
        "plate2": "9771",
        "plate3": "00100",
        "ticket_id": "",
      });

      var _profile = await _futureProfile;
      setState(() {
        chkisCard =
            _profile["idcard"] != '' && _profile['idcard'] != null
                ? true
                : false;
      });
      getMainPopUp();
      // _getLocation();
      // print('-------------end response------------');
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginPage(title: '')),
        (Route<dynamic> route) => false,
      );
    }
  }

  getMainPopUp() async {
    var result = await post('${mainPopupHomeApi}read', {
      'skip': 0,
      'limit': 100,
    });

    if (result.length > 0) {
      var valueStorage = await storage.read(key: 'mainPopupDDPM');
      var dataValue;
      if (valueStorage != null) {
        dataValue = json.decode(valueStorage);
      } else {
        dataValue = null;
      }

      var now = new DateTime.now();
      DateTime date = new DateTime(now.year, now.month, now.day);

      if (dataValue != null) {
        var index = dataValue.indexWhere(
          (c) =>
              // c['username'] == userData.username &&
              c['date'].toString() ==
                  DateFormat("ddMMyyyy").format(date).toString() &&
              c['boolean'] == "true",
        );

        if (index == -1) {
          this.setState(() {
            hiddenMainPopUp = false;
          });
          return showDialog(
            barrierDismissible: false, // close outside
            context: context,
            builder: (_) {
              return WillPopScope(
                onWillPop: () {
                  return Future.value(false);
                },
                child: MainPopupDialog(
                  model: _futureMainPopUp,
                  type: 'mainPopup',
                  url: '',
                  urlGallery: '',
                  username: '',
                ),
              );
            },
          );
        } else {
          this.setState(() {
            hiddenMainPopUp = true;
          });
        }
      } else {
        this.setState(() {
          hiddenMainPopUp = false;
        });
        return showDialog(
          barrierDismissible: false, // close outside
          context: context,
          builder: (_) {
            return WillPopScope(
              onWillPop: () {
                return Future.value(false);
              },
              child: MainPopupDialog(
                model: _futureMainPopUp,
                type: 'mainPopup',
                url: '',
                urlGallery: '',
                username: '',
              ),
            );
          },
        );
      }
    }
  }

  void _onRefresh() async {
    // getCurrentUserData();
    _read();

    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
    // _refreshController.loadComplete();
  }

  void _onLoading() async {
    await Future.delayed(Duration(milliseconds: 1000));
    _refreshController.loadComplete();
  }

  _getLocation() async {
    // print('currentLocation');
    // Position position = await Geolocator.getCurrentPosition(
    //     desiredAccuracy: LocationAccuracy.best);

    // // print('------ Position -----' + position.toString());

    // List<Placemark> placemarks = await placemarkFromCoordinates(
    //     position.latitude, position.longitude,
    //     localeIdentifier: 'th');
    // // print('----------' + placemarks.toString());

    // setState(() {
    //   latLng = LatLng(position.latitude, position.longitude);
    //   currentLocation = placemarks.first.administrativeArea;
    // });
  }

  Widget _buildTrainingButton({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF6F267B)),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Kanit',
                fontSize: 15,
                color: Color(0xFF545454),
              ),
            ),
            const Spacer(),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Color(0xFF9E9E9E),
            ),
          ],
        ),
      ),
    );
  }
  // mainFooter() {
  //   double width = MediaQuery.of(context).size.width;
  //   double height = MediaQuery.of(context).size.height;
  //   return Container(
  //     height: height * 15 / 100,
  //     decoration: BoxDecoration(
  //       gradient: LinearGradient(
  //         colors: [
  //           Color(0xFFFF7514),
  //           Color(0xFFF7E834),
  //         ],
  //         begin: Alignment.topLeft,
  //         end: new Alignment(1, 0.0),
  //       ),
  //     ),
  //     child: Column(
  //       mainAxisSize: MainAxisSize.max,
  //       crossAxisAlignment: CrossAxisAlignment.stretch,
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       children: [
  //         Container(
  //           alignment: Alignment.center,
  //           child: Text(
  //             userData.status == 'N'
  //                 ? 'ท่านยังไม่ได้ยืนยันตัวตน กรุณายืนยันตัวตน'
  //                 : 'ยืนยันตัวตนแล้ว รอเจ้าหน้าที่ตรวจสอบข้อมูล',
  //             style: TextStyle(
  //               // color: Colors.white,
  //               fontFamily: 'Kanit',
  //               fontSize: 13,
  //             ),
  //           ),
  //         ),
  //         SizedBox(
  //           height: height * 1.5 / 100,
  //         ),
  //         userData.status == 'N'
  //             ? Container(
  //                 margin: EdgeInsets.symmetric(horizontal: width * 34 / 100),
  //                 height: height * 6 / 100,
  //                 child: Material(
  //                   elevation: 5.0,
  //                   borderRadius: BorderRadius.circular(10.0),
  //                   child: Container(
  //                     alignment: Alignment.center,
  //                     decoration: BoxDecoration(
  //                       borderRadius: BorderRadius.circular(5.0),
  //                       color: Theme.of(context).primaryColorDark,
  //                     ),
  //                     child: MaterialButton(
  //                       minWidth: MediaQuery.of(context).size.width,
  //                       onPressed: () {
  //                         Navigator.push(
  //                           context,
  //                           MaterialPageRoute(
  //                             builder: (context) => IdentityVerificationPage(),
  //                           ),
  //                         );
  //                       },
  //                       child: Text(
  //                         'ยืนยันตัวตน',
  //                         style: TextStyle(
  //                           color: Colors.white,
  //                           fontFamily: 'Kanit',
  //                           fontSize: 13,
  //                         ),
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //               )
  //             : Container(),
  //       ],
  //     ),
  //   );
  // }

  _buildTraining() {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => TrainingMain()),
        );
      },
      child: Container(
        height: 120,
        padding: const EdgeInsets.symmetric(horizontal: 25),
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.grey,
          image: DecorationImage(
            // image: NetworkImage('${model['imageUrl']}'),
            image: AssetImage('assets/background/background_dispute.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 5),
                  Text(
                    'เรียนรู้และอบรม \n(Training & Upskill Academy)',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.0,
                      fontFamily: 'Kanit',
                      // fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    // overflow: TextOverflow.fade,
                  ),
                  SizedBox(height: 5),
                  Text(
                    'กรมการขนส่งทางบกอำนวยความสะดวกให้ท่าน',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13.0,
                      fontFamily: 'Kanit',
                    ),
                    maxLines: 2,
                    // textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _buildcardFund() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: InkWell(
        onTap: () async {
          if (isFirstFund) {
            // ครั้งแรกหลังเปิดแอพ
            isFirstFund = false;

            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => FundRecommend()),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FundMain(title: 'กองทุน'),
              ),
            );
          }
        },
        child: Container(
          height: 100,
          margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Colors.white,
            image: DecorationImage(
              image: AssetImage('assets/background/backgrounf_fund.png'),
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
