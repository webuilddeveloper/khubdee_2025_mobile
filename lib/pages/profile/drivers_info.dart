import 'package:KhubDeeDLT/component/material/custom_alert_dialog.dart';
import 'package:KhubDeeDLT/pages/blank_page/toast_fail.dart';
import 'package:KhubDeeDLT/pages/notification/notification_list.dart';
import 'package:KhubDeeDLT/shared/api_provider.dart';
import 'package:flutter/material.dart';
import 'package:KhubDeeDLT/component/header.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:qr_flutter/qr_flutter.dart';

class DriversInfo extends StatefulWidget {
  @override
  _DriversInfoPageState createState() => _DriversInfoPageState();
}

class _DriversInfoPageState extends State<DriversInfo> {
  late Future<dynamic> _futureModel;
  final storage = new FlutterSecureStorage();
  dynamic tempData;
  dynamic categoryList = [
    {'title': '1', 'value': 0},
    {'title': '2', 'value': 1},
    {'title': '3', 'value': 2},
    {'title': '4', 'value': 3},
  ];
  String imageTemp =
      'https://instagram.fbkk5-6.fna.fbcdn.net/v/t51.2885-15/sh0.08/e35/c0.180.1440.1440a/s640x640/133851894_231577355006812_2104786467046058604_n.jpg?_nc_ht=instagram.fbkk5-6.fna.fbcdn.net&_nc_cat=1&_nc_ohc=t-y0eYG-FkYAX8VbpYj&tp=1&oh=d5fed0e8846f1056c70836b6fce223eb&oe=601E2B77';
  int _limit = 10;
  int selectedCategory = 0;
  String profileCode = "";
  String idcard = "";
  String profileImage = "";
  RefreshController _refreshController = RefreshController(
    initialRefresh: false,
  );
  String isExpireDate = "2";
  GlobalKey globalKey = new GlobalKey();
  String _dataString = "Hello from this QR";

  List<dynamic> model = [
    {
      'isExpire': '1',
      'code': '3550800068774',
      'idCard': '3550800068774',
      'pltNo': '6600011',
      'pltDesc': 'ใบอนุญาตขับรถยนต์สาธารณะ',
      'pltDescEn': 'Taxi Driving Licence',
      'titleDesc': 'นาย',
      'fname': 'วีบิลด์',
      'lname': 'ทำเอง',
      'titleDescEn': 'Mr.',
      'fnameEn': 'WEBUILD',
      'lnameEn': 'TAMEANG',
      'docNo': '',
      'issDate': '04/02/2020 00:00:00',
      'expDate': '28/03/2025 00:00:00',
      'birthDate': '17 พฤษภาคม 1994',
      'birthDateEn': '17 May 1994',
      'type': '1',
      'province': 'กรุงเทพมหานคร',
      'provinceEn': 'Bangkok',
    },
    {
      'isExpire': '2',
      'code': '3550800068774',
      'idCard': '3550800068774',
      'pltNo': '6600012',
      'pltDesc': 'ใบอนุญาตขับรถจักรยานยนต์สาธารณะ',
      'pltDescEn': 'Motorcycle Driving Licence',
      'titleDesc': 'นาย',
      'fname': 'วีบิลด์',
      'lname': 'ทำเอง',
      'titleDescEn': 'Mr.',
      'fnameEn': 'WEBUILD',
      'lnameEn': 'TAMEANG',
      'docNo': '',
      'issDate': '04/02/2020 00:00:00',
      'expDate': '28/03/2025 00:00:00',
      'birthDate': '17 พฤษภาคม 1994',
      'birthDateEn': '17 May 1994',
      'type': '2',
      'province': 'กรุงเทพมหานคร',
      'provinceEn': 'Bangkok',
    },
    {
      'isExpire': '3',
      'code': '3550800068774',
      'idCard': '3550800068774',
      'pltNo': '6600012',
      'pltDesc': 'ใบอนุญาตขับรถจักรยานยนต์สาธารณะ',
      'pltDescEn': 'Motorcycle Driving Licence',
      'titleDesc': 'นาย',
      'fname': 'วีบิลด์',
      'lname': 'ทำเอง',
      'titleDescEn': 'Mr.',
      'fnameEn': 'WEBUILD',
      'lnameEn': 'TAMEANG',
      'docNo': '',
      'issDate': '04/02/2020 00:00:00',
      'expDate': '28/03/2025 00:00:00',
      'birthDate': '17 พฤษภาคม 1994',
      'birthDateEn': '17 May 1994',
      'type': '2',
      'province': 'กรุงเทพมหานคร',
      'provinceEn': 'Bangkok',
    },
  ];

  @override
  void initState() {
    super.initState();
    _callRead();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(
        context,
        () {
          Navigator.pop(context, false);
        },
        title: 'ใบอนุญาตขับขี่',
        isButtonRight: true,
        imageRightButton: 'assets/icons/bell.png',
        rightButton: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NotificationList(title: 'แจ้งเตือน'),
            ),
          );
        },
      ),
      backgroundColor: Color(0xFFF5F8FB),
      body: InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        // child: _screen(model),
        child: _buildListView(),

        // FutureBuilder<dynamic>(
        //   future: _futureModel, // function where you call your api
        //   builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        //     if (snapshot.hasData) {
        //       return _screen2(snapshot.data);
        //     } else if (snapshot.hasError) {
        //       return Container();
        //     } else {
        //       return Container();
        //     }
        //   },
        // ),
      ),
    );
  }

  _buildListView() {
    return Column(
      children: [
        Container(
          height: 60,
          padding: EdgeInsets.symmetric(horizontal: 15),
          margin: EdgeInsets.only(bottom: 1),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  new Text(
                    'ใบอนุญาตทั้งหมด',
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontFamily: 'Sarabun',
                      fontSize: 14.0,
                      color: Color(0xFF545454),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // SizedBox(height: 10),
        model.length > 0
            ? Expanded(
              child: ListView(
                children: [
                  _buildCard(model[0]),
                  _buildCard(model[1]),
                  _buildCard(model[2]),
                ],
              ),

              // SmartRefresher(
              //   enablePullDown: false,
              //   enablePullUp: true,
              //   footer: ClassicFooter(
              //     loadingText: ' ',
              //     canLoadingText: ' ',
              //     idleText: ' ',
              //     idleIcon: Icon(Icons.arrow_upward, color: Colors.transparent),
              //   ),
              //   controller: _refreshController,
              //   onLoading: _onLoading,
              //   onRefresh: _onRefresh,
              //   child: ListView.builder(
              //     physics: ScrollPhysics(),
              //     shrinkWrap: true,
              //     scrollDirection: Axis.vertical,
              //     itemCount: model.length,
              //     itemBuilder: (context, index) {
              //       return _item(model[index]);
              //     },
              //   ),
              // ),
            )
            : Container(),
      ],
    );
  }

  _buildCard(dynamic model) {
    return Container(
      // height: 200,
      // margin: EdgeInsets.only(right: 5),
      padding: EdgeInsets.symmetric(horizontal: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: [
          //     Expanded(
          //       flex: 3,
          //       child: Container(
          //         // height: 130,
          //         // width: 180,
          //         margin: EdgeInsets.only(
          //           bottom: 5,
          //           left: 10,
          //           right: 10,
          //           top: 5,
          //         ),
          //         padding: EdgeInsets.all(3),
          //         decoration: BoxDecoration(
          //           color: Colors.white,
          //           borderRadius: BorderRadius.circular(5),
          //           boxShadow: [
          //             BoxShadow(
          //               color: Colors.grey.withOpacity(0.4),
          //               spreadRadius: 0,
          //               blurRadius: 4,
          //               offset: Offset(1, 3), // changes position of shadow
          //             ),
          //           ],
          //         ),
          //         child: Column(
          //           mainAxisAlignment: MainAxisAlignment.start,
          //           children: [
          //             Container(
          //               height: 15,
          //               color:
          //                   model['isExpire']
          //                       ? Color(0xFF838383)
          //                       : Color(0xFF214492),
          //               padding: EdgeInsets.all(3),
          //               child: Row(
          //                 children: [
          //                   Image.asset(
          //                     "assets/icons/icon_flag.png",
          //                     fit: BoxFit.cover,
          //                   ),
          //                   Text(
          //                     '   ใบอนุญาตขับรถ',
          //                     style: TextStyle(
          //                       fontFamily: 'Sarabun',
          //                       fontSize: 6,
          //                       color: Colors.white,
          //                     ),
          //                   ),
          //                 ],
          //               ),
          //             ),
          //             SizedBox(height: 5),
          //             Row(
          //               children: [
          //                 Container(
          //                   width: 65,
          //                   height: 84,
          //                   child: Image.network(
          //                     profileImage,
          //                     fit: BoxFit.cover,
          //                   ),
          //                 ),
          //                 SizedBox(width: 4),
          //                 Expanded(
          //                   child: Container(
          //                     alignment: Alignment.topLeft,
          //                     child: Column(
          //                       children: [
          //                         Container(
          //                           height: 30,
          //                           width: double.infinity,
          //                           color:
          //                               model['isExpire']
          //                                   ? Color(0xFF838383)
          //                                   : Color(0xFFFFB13B),
          //                           padding: EdgeInsets.only(left: 3),
          //                           child: Column(
          //                             crossAxisAlignment:
          //                                 CrossAxisAlignment.start,
          //                             children: [
          //                               Text(
          //                                 'No.${model['pltNo']}',
          //                                 style: TextStyle(
          //                                   fontFamily: 'Sarabun',
          //                                   fontSize: 10,
          //                                   color: Colors.white,
          //                                 ),
          //                                 textAlign: TextAlign.start,
          //                               ),
          //                               SizedBox(height: 2),
          //                               Text(
          //                                 model['pltDesc'],
          //                                 style: TextStyle(
          //                                   fontFamily: 'Sarabun',
          //                                   fontSize: 9,
          //                                   color: Colors.white,
          //                                 ),
          //                                 textAlign: TextAlign.start,
          //                               ),
          //                             ],
          //                           ),
          //                         ),
          //                         SizedBox(height: 4),
          //                         Container(
          //                           height: 50,
          //                           width: double.infinity,
          //                           padding: EdgeInsets.only(left: 3, top: 3),
          //                           decoration: BoxDecoration(
          //                             gradient: LinearGradient(
          //                               colors:
          //                                   model['isExpire']
          //                                       ? [
          //                                         Color(0xFFDCDCDC),
          //                                         Color(0xFFF0E0E0),
          //                                         Color(0xFFF0F0F0),
          //                                         Color(0xFFFFFFFF),
          //                                         Color(0xFFF0E0E0),
          //                                       ]
          //                                       : [
          //                                         Color(0xFFF1E8F8),
          //                                         Color(0xFFF9E6BA),
          //                                         Color(0xFFF9E6BA),
          //                                         Color(0xFFFFFFFF),
          //                                         Color(0xFFF1E8F8),
          //                                       ],
          //                               begin: Alignment(0, -1),
          //                               end: Alignment(0, 0.5),
          //                             ),
          //                           ),
          //                           child: Column(
          //                             crossAxisAlignment:
          //                                 CrossAxisAlignment.start,
          //                             children: [
          //                               Text(
          //                                 '${model['titleDesc']} ${model['fname']} ${model['lname']}',
          //                                 style: TextStyle(
          //                                   fontFamily: 'Sarabun',
          //                                   fontSize: 10,
          //                                   fontWeight: FontWeight.w500,
          //                                 ),
          //                                 textAlign: TextAlign.start,
          //                                 overflow: TextOverflow.ellipsis,
          //                                 maxLines: 1,
          //                               ),
          //                               SizedBox(height: 3),
          //                               Row(
          //                                 children: [
          //                                   Text(
          //                                     'เลขประจำตัวประชาชน : ',
          //                                     style: TextStyle(
          //                                       fontFamily: 'Sarabun',
          //                                       fontSize: 6,
          //                                       fontWeight: FontWeight.w500,
          //                                     ),
          //                                     textAlign: TextAlign.start,
          //                                   ),
          //                                   Text(
          //                                     model['docNo'],
          //                                     style: TextStyle(
          //                                       fontFamily: 'Sarabun',
          //                                       fontSize: 7,
          //                                       fontWeight: FontWeight.w500,
          //                                     ),
          //                                     textAlign: TextAlign.start,
          //                                   ),
          //                                 ],
          //                               ),
          //                               SizedBox(height: 2),
          //                               Row(
          //                                 children: [
          //                                   Expanded(
          //                                     child: Text(
          //                                       'วันอนุญาต ${model['issDate'].substring(0, 10)}',
          //                                       style: TextStyle(
          //                                         fontFamily: 'Sarabun',
          //                                         fontSize: 6,
          //                                         fontWeight: FontWeight.w500,
          //                                       ),
          //                                       textAlign: TextAlign.start,
          //                                     ),
          //                                   ),
          //                                   Container(
          //                                     height: 10,
          //                                     width: 1,
          //                                     color: Colors.black,
          //                                     margin: EdgeInsets.symmetric(
          //                                       horizontal: 2,
          //                                     ),
          //                                   ),
          //                                   Expanded(
          //                                     child: Text(
          //                                       'วันหมดอายุ ${model['expDate'].substring(0, 10)}',
          //                                       style: TextStyle(
          //                                         fontFamily: 'Sarabun',
          //                                         fontSize: 6,
          //                                         fontWeight: FontWeight.w500,
          //                                       ),
          //                                       textAlign: TextAlign.start,
          //                                     ),
          //                                   ),
          //                                 ],
          //                               ),
          //                             ],
          //                           ),
          //                         ),
          //                       ],
          //                     ),
          //                   ),
          //                 ),
          //               ],
          //             ),
          //             SizedBox(height: 4),
          //             model['isExpire']
          //                 ? Container(
          //                   height: 16,
          //                   color: Color(0xFF838383),
          //                   padding: EdgeInsets.only(bottom: 5, right: 5),
          //                   child: Row(
          //                     crossAxisAlignment: CrossAxisAlignment.end,
          //                     mainAxisAlignment: MainAxisAlignment.end,
          //                     children: [
          //                       Text(
          //                         'แสดง QR Code',
          //                         style: TextStyle(
          //                           fontFamily: 'Sarabun',
          //                           fontSize: 9,
          //                           decoration: TextDecoration.underline,
          //                           color: Colors.white,
          //                         ),
          //                       ),
          //                     ],
          //                   ),
          //                 )
          //                 : InkWell(
          //                   onTap: () {
          //                     _callDialogQRCode(context, model: model);
          //                   },
          //                   child: Container(
          //                     height: 16,
          //                     color: Color(0xFF214492),
          //                     padding: EdgeInsets.only(bottom: 5, right: 5),
          //                     child: Row(
          //                       crossAxisAlignment: CrossAxisAlignment.end,
          //                       mainAxisAlignment: MainAxisAlignment.end,
          //                       children: [
          //                         Text(
          //                           'แสดง QR Code',
          //                           style: TextStyle(
          //                             fontFamily: 'Sarabun',
          //                             fontSize: 9,
          //                             decoration: TextDecoration.underline,
          //                             color: Colors.white,
          //                           ),
          //                         ),
          //                       ],
          //                     ),
          //                   ),
          //                 ),
          //           ],
          //         ),
          //       ),
          //     ),
          //     Expanded(
          //       flex: 2,
          //       child: Container(
          //         alignment: Alignment.topRight,
          //         height: 150,
          //         padding: EdgeInsets.all(3),
          //         child: Column(
          //           crossAxisAlignment: CrossAxisAlignment.end,
          //           children: [
          //             Text(
          //               'วันหมดอายุ',
          //               style: TextStyle(
          //                 fontFamily: 'Sarabun',
          //                 fontSize: 13,
          //                 fontWeight: FontWeight.w500,
          //               ),
          //             ),
          //             SizedBox(height: 10),
          //             Text(
          //               '${model['expDate'].substring(0, 10)}',
          //               style: TextStyle(
          //                 fontFamily: 'Sarabun',
          //                 fontSize: 15,
          //                 fontWeight: FontWeight.w500,
          //                 color: model['isExpire'] ? Colors.red : Colors.black,
          //               ),
          //             ),
          //             SizedBox(height: 10),
          //             Row(
          //               mainAxisAlignment: MainAxisAlignment.end,
          //               children: [
          //                 model['isExpire']
          //                     ? Container(
          //                       height: 25,
          //                       padding: EdgeInsets.all(5),
          //                       decoration: BoxDecoration(
          //                         color: Color(0xFF838383),
          //                         borderRadius: BorderRadius.circular(5),
          //                       ),
          //                       child: Text(
          //                         'แสดง QR Code',
          //                         style: TextStyle(
          //                           fontFamily: 'Sarabun',
          //                           fontSize: 9,
          //                           color: Colors.white,
          //                         ),
          //                         textAlign: TextAlign.start,
          //                       ),
          //                     )
          //                     : InkWell(
          //                       onTap: () {
          //                         _callDialogQRCode(context, model: model);
          //                       },
          //                       child: Container(
          //                         height: 25,
          //                         padding: EdgeInsets.all(5),
          //                         decoration: BoxDecoration(
          //                           color: Color(0xFFEBC22B),
          //                           borderRadius: BorderRadius.circular(5),
          //                         ),
          //                         child: Text(
          //                           'แสดง QR Code',
          //                           style: TextStyle(
          //                             fontFamily: 'Sarabun',
          //                             fontSize: 9,
          //                             color: Colors.white,
          //                           ),
          //                           textAlign: TextAlign.start,
          //                         ),
          //                       ),
          //                     ),
          //                 SizedBox(width: 5),
          //                 InkWell(
          //                   onTap: () {},
          //                   child: Container(
          //                     height: 25,
          //                     padding: EdgeInsets.all(5),
          //                     decoration: BoxDecoration(
          //                       color: Color(0xFF6F267B),
          //                       borderRadius: BorderRadius.circular(5),
          //                     ),
          //                     child: Text(
          //                       'ข้อมูลเพิ่มเติม',
          //                       style: TextStyle(
          //                         fontFamily: 'Sarabun',
          //                         fontSize: 9,
          //                         color: Colors.white,
          //                       ),
          //                       textAlign: TextAlign.start,
          //                     ),
          //                   ),
          //                 ),
          //               ],
          //             ),
          //           ],
          //         ),
          //       ),
          //     ),
          //   ],
          // ),
          _cardItem(model: model),
          _buildLine(),
        ],
      ),
    );
  }

  _cardItem({String type = '1', dynamic model}) {
    return Column(
      children: [
        Container(
          // height: 130,
          // width: double.infinity,
          margin: EdgeInsets.only(bottom: 5, left: 10, right: 10, top: 5),
          padding: EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.4),
                spreadRadius: 0,
                blurRadius: 4,
                offset: Offset(1, 3), // changes position of shadow
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                height: 30,
                color:
                    model['isExpire'] == '3'
                        ? Color(0xFF838383)
                        : model['isExpire'] == '2'
                        ? Colors.yellow.shade800
                        : Color(0xFF214492),
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: Image.asset(
                              "assets/icons/icon_flag.png",
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(width: 3),
                          Column(
                            children: [
                              Text(
                                'ประเทศไทย',
                                style: TextStyle(
                                  fontFamily: 'Sarabun',
                                  fontSize: 9,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Kingdom of Thailand',
                                style: TextStyle(
                                  fontFamily: 'Sarabun',
                                  fontSize: 8,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // SizedBox(width: 10),
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${model['pltDesc']}',
                            style: TextStyle(
                              fontFamily: 'Sarabun',
                              fontSize: 9,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            '${model['pltDescEn']}',
                            style: TextStyle(
                              fontFamily: 'Sarabun',
                              fontSize: 8,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 3),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.only(bottom: 5),
                    width: 100,
                    height: 55,
                    child: Image.asset(
                      'assets/logo/logo_1.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: Container(
                        height: 50,
                        width: double.infinity,
                        color: Color(0xFFFFB13B),
                        padding: EdgeInsets.all(5),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              flex: 1,
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'ฉบับที่',
                                        style: TextStyle(
                                          fontFamily: 'Sarabun',
                                          fontSize: 9,
                                          color: Colors.white,
                                          height: 1,
                                        ),
                                        textAlign: TextAlign.end,
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        '${model['pltNo']}',
                                        style: TextStyle(
                                          fontFamily: 'Sarabun',
                                          fontSize: 12,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.start,
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        'วันอนุญาต',
                                        style: TextStyle(
                                          fontFamily: 'Sarabun',
                                          fontSize: 9,
                                          color: Colors.white,
                                          height: 1,
                                        ),
                                        textAlign: TextAlign.end,
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        '${model['issDate'].substring(0, 10)}',
                                        style: TextStyle(
                                          fontFamily: 'Sarabun',
                                          fontSize: 9,
                                          color: Colors.white,
                                          fontWeight: FontWeight.normal,
                                        ),
                                        textAlign: TextAlign.start,
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        'Issue Date',
                                        style: TextStyle(
                                          fontFamily: 'Sarabun',
                                          fontSize: 9,
                                          color: Colors.white,
                                          height: 1,
                                        ),
                                        textAlign: TextAlign.end,
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        '${model['issDate'].substring(0, 10)}',
                                        style: TextStyle(
                                          fontFamily: 'Sarabun',
                                          fontSize: 9,
                                          color: Colors.white,
                                          fontWeight: FontWeight.normal,
                                          height: 1,
                                        ),
                                        textAlign: TextAlign.start,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            Expanded(
                              flex: 1,
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'No. ',
                                        style: TextStyle(
                                          fontFamily: 'Sarabun',
                                          fontSize: 9,
                                          color: Colors.white,
                                          height: 1,
                                        ),
                                        textAlign: TextAlign.end,
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        '${model['pltNo']}',
                                        style: TextStyle(
                                          fontFamily: 'Sarabun',
                                          fontSize: 12,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.start,
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        'วันสิ้นอายุ',
                                        style: TextStyle(
                                          fontFamily: 'Sarabun',
                                          fontSize: 9,
                                          color: Colors.white,
                                          height: 1,
                                        ),
                                        textAlign: TextAlign.end,
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        '${model['expDate'].substring(0, 10)}',
                                        style: TextStyle(
                                          fontFamily: 'Sarabun',
                                          fontSize: 9,
                                          color: Colors.white,
                                          fontWeight: FontWeight.normal,
                                        ),
                                        textAlign: TextAlign.start,
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        'Expiry Date',
                                        style: TextStyle(
                                          fontFamily: 'Sarabun',
                                          fontSize: 9,
                                          color: Colors.white,
                                          height: 1,
                                        ),
                                        textAlign: TextAlign.end,
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        '${model['issDate'].substring(0, 10)}',
                                        style: TextStyle(
                                          fontFamily: 'Sarabun',
                                          fontSize: 9,
                                          color: Colors.white,
                                          fontWeight: FontWeight.normal,
                                          height: 1,
                                        ),
                                        textAlign: TextAlign.start,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    width: 100,
                    height: 130,
                    // child: Image.network(profileImage, fit: BoxFit.cover),
                    child: Image.asset('assets/owner.png', fit: BoxFit.cover),
                  ),
                  SizedBox(width: 4),
                  Expanded(
                    child: Container(
                      alignment: Alignment.topLeft,
                      child: Column(
                        children: [
                          Container(
                            height: 130,
                            width: double.infinity,
                            padding: EdgeInsets.only(left: 3, top: 3),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color(0xFFF1E8F8),
                                  Color(0xFFFFFFFF),
                                  Color(0xFFF1E8F8),
                                ],
                                begin: Alignment(0, -1),
                                end: Alignment(0, 0.5),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            'ชื่อ       ',
                                            style: TextStyle(
                                              fontFamily: 'Sarabun',
                                              fontSize: 10,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.red.shade400,
                                            ),
                                            textAlign: TextAlign.start,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                          Text(
                                            '${model['titleDesc']} ${model['fname']} ${model['lname']}',
                                            style: TextStyle(
                                              fontFamily: 'Sarabun',
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            textAlign: TextAlign.start,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ],
                                      ),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Name  ',
                                            style: TextStyle(
                                              fontFamily: 'Sarabun',
                                              fontSize: 10,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.red.shade400,
                                            ),
                                            textAlign: TextAlign.start,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                          Text(
                                            '${model['titleDescEn']} ${model['fnameEn']} ${model['lnameEn']}',
                                            style: TextStyle(
                                              fontFamily: 'Sarabun',
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            textAlign: TextAlign.start,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            'เกิดวันที่      ',
                                            style: TextStyle(
                                              fontFamily: 'Sarabun',
                                              fontSize: 9,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.red.shade400,
                                            ),
                                            textAlign: TextAlign.start,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                          Text(
                                            '${model['birthDate']}',
                                            style: TextStyle(
                                              fontFamily: 'Sarabun',
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            textAlign: TextAlign.start,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ],
                                      ),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Birth Date  ',
                                            style: TextStyle(
                                              fontFamily: 'Sarabun',
                                              fontSize: 9,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.red.shade400,
                                            ),
                                            textAlign: TextAlign.start,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                          Text(
                                            '${model['birthDateEn']}',
                                            style: TextStyle(
                                              fontFamily: 'Sarabun',
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            textAlign: TextAlign.start,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ],
                                      ),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            'เลขประจำตัวประชาชน / ID No. ',
                                            style: TextStyle(
                                              fontFamily: 'Sarabun',
                                              fontSize: 9,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.red.shade400,
                                            ),
                                            textAlign: TextAlign.start,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                          Text(
                                            '${model['idCard']}',
                                            style: TextStyle(
                                              fontFamily: 'Sarabun',
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            textAlign: TextAlign.start,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4),

              Container(
                height: 30,
                color:
                    model['isExpire'] == '3'
                        ? Color(0xFF838383)
                        : model['isExpire'] == '2'
                        ? Colors.yellow.shade800
                        : Color(0xFF214492),
                padding: EdgeInsets.only(bottom: 5, right: 5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'นายทะเบียน ${model['province']} ${model['provinceEn']}',
                      style: TextStyle(
                        fontFamily: 'Sarabun',
                        fontSize: 12,
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 5),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              InkWell(
                onTap: () {
                  model['isExpire'] == '3'
                      ? null
                      : _callDialogQRCode(context, model: model);
                },
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 0,
                        blurRadius: 7,
                        offset: Offset(0, 3), // changes position of shadow
                      ),
                    ],
                    borderRadius: BorderRadius.circular(7),
                    color: Color.fromARGB(255, 117, 70, 154),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'แสดง QR Code',
                        style: TextStyle(
                          fontFamily: 'Sarabun',
                          fontSize: 12,
                          decoration: TextDecoration.underline,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

SizedBox(width: 10,),
              model['isExpire'] == '3'
                  ? Row(
                    children: [
                      Text(
                        'วันหมดอายุ  ',
                        style: TextStyle(
                          fontFamily: 'Sarabun',
                          fontSize: 12,
                          // decoration: TextDecoration.underline,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        '${model['expDate'].substring(0, 10)}',
                        style: TextStyle(
                          fontFamily: 'Sarabun',
                          fontSize: 12,
                          // decoration: TextDecoration.underline,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  )
                  : Container(),
            ],
          ),
        ),
      ],
    );
  }

  _buildLine() {
    return Container(
      height: 1,
      margin: EdgeInsets.symmetric(vertical: 20),
      color: Color(0xFF919191),
    );
  }

  _callRead() async {
    var fname = await storage.read(key: 'profileFirstName');
    var lname = await storage.read(key: 'profileLastName');
    var idcard = await storage.read(key: 'idcard');
    profileImage = (await storage.read(key: 'profileImageUrl')) ?? '';
    profileCode = (await storage.read(key: 'profileCode2')) ?? '';

    // print('----- ${model.toString()}');

    // profileCode = await storage.read(key: 'profileCode2');
    // idcard = await storage.read(key: 'idcard');

    // if (profileCode != '' && profileCode != null)
    //   setState(() {
    //     _futureModel = postDio('${serverMW}DLTLC/getDriverLicenceByDocNo',
    //         {"code": profileCode, "docNo": idcard});
    //   });

    // // mock data
    // setState(() {
    //   tempData = [];
    //   for (var i = 1; i < _limit; i++) {
    //     setState(() {
    //       tempData.add({'title': i.toString()});
    //     });
    //   }
    // });
  }

  _callDialogQRCode(BuildContext context, {dynamic model}) {
    // print('----- card ----- ' + model.toString());

    return showDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () {
            return Future.value(true);
          },
          child: CustomAlertDialog(
            contentPadding: EdgeInsets.all(0),
            content: Container(
              width: 345,
              height: 400,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.white,
              ),
              child: Column(
                children: [
                  Container(
                    height: 60,
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Color(0xFF6F267B),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15),
                      ),
                    ),
                    child: Stack(
                      children: <Widget>[
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Image.asset(
                            "assets/logo/logo_1.png",
                            fit: BoxFit.cover,
                            height: 40,
                          ),
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: Text(
                            'กรมการขนส่งทางบก',
                            style: TextStyle(
                              fontFamily: 'Sarabun',
                              fontSize: 18,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.0),
                  Container(
                    child: Center(
                      child: RepaintBoundary(
                        key: globalKey,
                        child: QrImageView(data: model['code'], size: 240),
                      ),
                    ),
                  ),
                  SizedBox(height: 30.0),
                  Container(
                    // height: 50,
                    child: Text(
                      '${model['titleDesc']} ${model['fname']} ${model['lname']}',
                      style: TextStyle(
                        fontFamily: 'Sarabun',
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  _screen(dynamic model) {
    return SmartRefresher(
      enablePullDown: false,
      enablePullUp: true,
      footer: ClassicFooter(
        loadingText: ' ',
        canLoadingText: ' ',
        idleText: ' ',
        idleIcon: Icon(Icons.arrow_upward, color: Colors.transparent),
      ),
      controller: _refreshController,
      onLoading: _onLoading,
      onRefresh: _onRefresh,
      child: ListView.builder(
        physics: ScrollPhysics(),
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        itemCount: model.length,
        itemBuilder: (context, index) {
          return _buildCard(model[index]);
        },
      ),
    );
  }

  _update() async {
    final result =
        await postObjectDataMW(serverMW + 'DLTLC/updateDriverLicenceByDocNo', {
          'code': profileCode,
          'createBy': profileCode,
          'updateBy': profileCode,
          'docType': '8',
          'docNo': idcard,
          'reqDocNo': idcard,
        });
    if (result['status'] == 'S') {
      _callRead();
      toastFail(context, text: 'อัพเดทข้อมูลสำเร็จ');
    } else {
      toastFail(context, text: 'อัพเดทข้อมูลล้มเหลว');
    }
  }

  _onLoading() async {
    // setState(() {
    //   _limit = _limit + 2;
    // });
    _callRead();

    await Future.delayed(Duration(milliseconds: 2000));

    _refreshController.loadComplete();
  }

  void _onRefresh() async {
    // getCurrentUserData();
    // _getLocation();
    _callRead();

    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
    // _refreshController.loadComplete();
  }
}
