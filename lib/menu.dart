import 'dart:convert';
import 'dart:ui';

import 'package:KhubDeeDLT/component/material/check_avatar.dart';
import 'package:KhubDeeDLT/home_v2.dart';
import 'package:KhubDeeDLT/pages/event_calendar/event_calendar_main.dart';
import 'package:KhubDeeDLT/pages/notification/notification_list.dart';
import 'package:KhubDeeDLT/pages/profile/user_information.dart';
import 'package:KhubDeeDLT/profile.dart';
import 'package:KhubDeeDLT/shared/api_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';

class MenuMain extends StatefulWidget {
  MenuMain({Key? key, this.pageIndex, this.modelprofile}) : super(key: key);

  final int? pageIndex;
  final modelprofile;

  @override
  State<MenuMain> createState() => _MenuMainState();
}

class _MenuMainState extends State<MenuMain> {
  final storage = new FlutterSecureStorage();
  late Future<dynamic> _futureProfile = Future.value(null);
  int _currentPage = 0;
  var profileCode;
  dynamic modelProfile;
  String imageUrl = '';
  List<Widget> pages = <Widget>[];
  DateTime? currentBackPressTime;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    pages = <Widget>[
      HomePageV2(),
      EventCalendarMain(title: 'ปฏิทินกิจกรรม'),
      NotificationList(title: 'แจ้งเตือน'),
      UserInformationPage()
      // Profile(model: modelProfile),
      // Profile(model: modelProfile)
    ];
    setState(() {
      _currentPage = widget.pageIndex ?? 0;
    });
  }

  Future<void> _loadUserProfile() async {
    final storage = FlutterSecureStorage();
    String? model = await storage.read(key: 'dataUserLoginDDPM');

    if (model != null) {
      final data = jsonDecode(model);

      setState(() {
        modelProfile = data;
        imageUrl = data['imageUrl'];
        print('>>>>>>>>>>>>>>>> ${data['code']}');
        // _futureProfile = postDio(profileReadApi, {"code": data['code']});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      drawerScrimColor: Colors.transparent,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: WillPopScope(
          onWillPop: confirmExit,
          child: IndexedStack(index: _currentPage, children: pages),
        ),
      ),
      
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(45), topRight: Radius.circular(45)),
                boxShadow: [
              BoxShadow(
                color: Color(0xFF00000026),
                blurRadius: 15,
                offset: Offset(-10, -10),
              ),
            ],
              ),
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 20), // ระยะลอยจากขอบ
        child: 
        // ClipRRect(
        //   // borderRadius: BorderRadius.circular(45),
        //   child: BackdropFilter(
        //     filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        //     child: 
            Container(
              height: 70,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(45),
                // border: Border.all(
                //   color: Theme.of(context).primaryColor.withOpacity(0.2),
                //   width: 1.2,
                // ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _bottomItem(Icons.home, 0, title: 'หน้าแรก'),
                  _bottomItem(Icons.card_giftcard, 1, title: 'ปฏิทินกิจกรรม'),
                  _bottomItem(Icons.notifications, 2, title: 'แจ้งเตือน'),
                  _bottomItem(
                    Icons.person,
                    3,
                    isImageUrl: true,
                    title: 'โปรไฟล์',
                  ),
                ],
              ),
            ),
        //   ),
        // ),
      ),
    );
  }

  Future<bool> confirmExit() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime!) > const Duration(seconds: 2)) {
      currentBackPressTime = now;
      Fluttertoast.showToast(
        msg: 'กดอีกครั้งเพื่อออก',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      return Future.value(false);
    }
    return Future.value(true);
  }

  Widget _bottomItem(
    IconData icon,
    int index, {
    bool isImageUrl = false,
    required String title,
  }) {
    final isSelected = _currentPage == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentPage = index;
        });
        _loadUserProfile();
      },
      // borderRadius: BorderRadius.circular(50),
      child:
      // AnimatedContainer(
      //   duration: Duration(milliseconds: 500),
      //   curve: Curves.linearToEaseOut,
      //   // padding: EdgeInsets.all(12),
      Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          // color:
          //     isSelected ? Theme.of(context).primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(45),
          // boxShadow: [
          //   BoxShadow(
          //     color:
          //         isSelected
          //             ? Colors.black.withOpacity(0.2)
          //             : Colors.transparent,
          //     blurRadius: 20,
          //     offset: Offset(0, 10),
          //   ),
          // ],
          // shape: BoxShape.circle,
        ),
        child: Column(
          children: [
            isImageUrl
                ? Container(
                  padding: EdgeInsets.all('${imageUrl}' != '' ? 0.0 : 5.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    // color: const Color(0xFFFF7900),
                  ),
                  height: 30,
                  width: 30,
                  child:
                      imageUrl != ''
                          ? checkAvatar(context, '${imageUrl}')
                          : Icon(
                            icon,
                            size: 30,
                            color:
                                isSelected
                                    ? Color(0xFF4A0768)
                                    : Color(0xFF877573),
                          ),
                )
                : Icon(
                  icon,
                  size: 30,
                  color: isSelected ? Color(0xFF4A0768) : Color(0xFF877573),
                ),
            Text(title, style: TextStyle(fontSize: 12, color: isSelected ? Color(0xFF4A0768) : Color(0xFF877573))),
          ],
        ),
      ),
    );
    //   ),
    // );
  }
}
