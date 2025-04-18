import 'package:KhubDeeDLT/component/gallery_view.dart';
import 'package:KhubDeeDLT/component/material/custom_alert_dialog.dart';
import 'package:KhubDeeDLT/pages/appeal.dart';
import 'package:KhubDeeDLT/pages/blank_page/toast_fail.dart';
import 'package:KhubDeeDLT/pages/qr_payment.dart';
import 'package:KhubDeeDLT/shared/api_provider.dart';
import 'package:KhubDeeDLT/shared/extension.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:KhubDeeDLT/component/header.dart';

class TrafficTicketDetail extends StatefulWidget {
  TrafficTicketDetail({Key? key, required this.cardID, required this.ticketID})
    : super(key: key);

  final String cardID;
  final String ticketID;

  @override
  _TrafficTicketDetailPageState createState() =>
      _TrafficTicketDetailPageState();
}

class _TrafficTicketDetailPageState extends State<TrafficTicketDetail> {
  late Future<dynamic> futureModel;
  String imageTemp =
      'https://instagram.fbkk5-6.fna.fbcdn.net/v/t51.2885-15/sh0.08/e35/c0.180.1440.1440a/s640x640/133851894_231577355006812_2104786467046058604_n.jpg?_nc_ht=instagram.fbkk5-6.fna.fbcdn.net&_nc_cat=1&_nc_ohc=t-y0eYG-FkYAX8VbpYj&tp=1&oh=d5fed0e8846f1056c70836b6fce223eb&oe=601E2B77';

  @override
  void initState() {
    super.initState();

    read();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, () {
        Navigator.pop(context);
      }, title: 'รายละเอียดใบสั่ง'),
      backgroundColor: Color(0xFFF5F8FB),
      body: _futureBuilder(),
    );
  }

  _futureBuilder() {
    return FutureBuilder<dynamic>(
      future: futureModel, // function where you call your api
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.length > 0)
            return _screen(snapshot.data[0]);
          else
            return Container();
        } else if (snapshot.hasError) {
          return Container();
        } else {
          return Container();
        }
      },
    );
  }

  _screen(dynamic model) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            height: 40,
            width: double.infinity,
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.symmetric(horizontal: 10),
            color: Color(0xFFEDF0F3),
            child: const Text(
              'รายละเอียดใบสั่ง',
              style: TextStyle(fontFamily: 'Sarabun', fontSize: 15),
            ),
          ),
          _textRow(
            title: 'วันที่กระทำความผิด',
            value: dateStringToDate(model['ticket_DATE']),
          ),
          _textRow(title: 'เลขที่ใบสั่ง', value: model['org_CODE']),
          _textRow(title: 'หมายเลขหนังสือ', value: 'xxxxxxxxxxxxxxx'),
          _textRow(title: 'ชนิดยานภาหนะ', value: 'รถยนต์ส่วนบุคคล'),
          _textRow(title: 'หมายเลขทะเบียน', value: model['plate']),
          Container(height: 5, color: Colors.white),
          _textRow(
            title: 'ข้อหา',
            value: ' - ' + model['accuse1_CODE'],
            maxLine: 10,
            spaceBetween: 30,
          ),
          if (model['accuse2_CODE'] != null)
            _textRow(
              title: '',
              value: ' - ' + model['accuse2_CODE'],
              maxLine: 10,
              spaceBetween: 30,
            ),
          if (model['accuse3_CODE'] != null)
            _textRow(
              title: '',
              value: ' - ' + model['accuse3_CODE'],
              maxLine: 10,
              spaceBetween: 30,
            ),
          if (model['accuse4_CODE'] != null)
            _textRow(
              title: '',
              value: ' - ' + model['accuse4_CODE'],
              maxLine: 10,
              spaceBetween: 30,
            ),
          if (model['accuse5_CODE'] != null)
            _textRow(
              title: '',
              value: ' - ' + model['accuse5_CODE'],
              maxLine: 10,
              spaceBetween: 30,
            ),
          Container(height: 5, color: Colors.white),
          _textRow(title: 'หน่วยงานที่ออกใบสั่ง', value: model['org_ABBR']),
          _textRow(title: 'ชื่อผู้ขับขี่', value: model['fullname']),
          _textRow(title: 'เลขที่ใบอนุญาตขับขี่', value: model['card_ID']),
          const SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: () {
                  List<ImageProvider> photos = [];
                  if (model['pic1'] != null && model['pic1'] != '')
                    photos.add(NetworkImage(model['pic1']));
                  if (model['pic2'] != null && model['pic2'] != '')
                    photos.add(NetworkImage(model['pic2']));
                  if (model['pic3'] != null && model['pic3'] != '')
                    photos.add(NetworkImage(model['pic3']));
                  if (photos.length > 0) {
                    showCupertinoDialog(
                      context: context,
                      builder: (context) {
                        return ImageViewer(
                          initialIndex: 0,
                          imageProviders: photos,
                        );
                      },
                    );
                  } else {
                    toastFail(context, text: 'ไม่พบรูปภาพ');
                  }
                },
                child: Container(
                  width: 168,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 0,
                        blurRadius: 2,
                        offset: Offset(0, 3), // changes position of shadow
                      ),
                    ],
                  ),
                  child: const Text(
                    'ดูรูปการกระทำความผิด',
                    style: TextStyle(
                      fontFamily: 'Sarabun',
                      fontSize: 13,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 20),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) =>
                              QRPayment(code: model['code'], back: false),
                    ),
                  );
                },
                child: Container(
                  width: 168,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Color(0xFFEBC22B),
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 0,
                        blurRadius: 2,
                        offset: Offset(0, 3), // changes position of shadow
                      ),
                    ],
                  ),
                  child: const Text(
                    'ชำระค่าปรับ',
                    style: TextStyle(
                      fontFamily: 'Sarabun',
                      fontSize: 13,
                      color: Color(0xFF4E2B68),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 80),
          InkWell(
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return dialogVerification(model);
                },
              );
            },
            child: const Text(
              'ยื่นอุทธรณ์',
              style: TextStyle(
                fontFamily: 'Sarabun',
                fontSize: 13,
                color: Color(0xFF9C0000),
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          SizedBox(height: 40),
        ],
      ),
    );
  }

  _textRow({
    String title = '',
    String value = '',
    Color titleColor = const Color(0xFF9E9E9E),
    Color valueColor = const Color(0xFF000000),
    double valueSize = 13,
    int maxLine = 1,
    double spaceBetween = 15,
  }) {
    return Container(
      constraints: BoxConstraints(minHeight: 35),
      width: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.only(left: 15, right: 15, bottom: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Sarabun',
              fontSize: 13,
              color: titleColor,
            ),
            textAlign: TextAlign.left,
          ),
          SizedBox(width: spaceBetween),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontFamily: 'Sarabun',
                fontSize: valueSize,
                color: valueColor,
              ),
              maxLines: maxLine,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  dialogVerification(dynamic model) {
    return CustomAlertDialog(
      contentPadding: EdgeInsets.all(0),
      content: Container(
        width: 345,
        height: 280,
        decoration: const BoxDecoration(
          shape: BoxShape.rectangle,
          color: const Color(0xFFFFFF),
        ),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10,),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Colors.white,
          ),
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Text(
                'การยื่นเรื่องยื่นอุทธรณ์',
                style: TextStyle(
                  fontFamily: 'Sarabun',
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6F267B),
                ),
              ),
              const Text(
                '(กรุณาเลือกเรื่องยื่นอุทธรณ์)',
                style: TextStyle(
                  fontFamily: 'Sarabun',
                  fontSize: 11,
                  color: Color(0xFF414141),
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => Appeal(
                                  title: 'ทะเบียนรถในใบสั่งไม่ตรงกับรถของท่าน',
                                  ticket_ID: model['ticket_ID'],
                                ),
                          ),
                        );
                      },
                      child: Container(
                        height: 169,
                        width: 150,
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Color(0xFF6F267B),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.asset(
                              'assets/card_id.png',
                              width: 40,
                              color: Colors.white,
                            ),
                            const Text(
                              'ทะเบียนรถในใบสั่งไม่ตรงกับรถของท่าน',
                              style: TextStyle(
                                fontFamily: 'Sarabun',
                                fontSize: 13,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => Appeal(
                                  title: 'รถที่ปรากฏตามใบสั่งไม่ใช่รถของท่าน',
                                  ticket_ID: model['ticket_ID'],
                                ),
                          ),
                        );
                      },
                      child: Container(
                        height: 169,
                        width: 150,
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Color(0xFF707070),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.asset(
                              'assets/car_front.png',
                              width: 40,
                              color: Colors.white,
                            ),
                            const Text(
                              'รถที่ปรากฏตามใบสั่งไม่ใช่รถของท่าน',
                              style: TextStyle(
                                fontFamily: 'Sarabun',
                                fontSize: 13,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // function
  read() async {
    // futureModel = postDio(getTicketDetailApi, {
    //   "createBy": "createBy",
    //   "updateBy": "updateBy",
    //   "card_id": widget.cardID,
    //   "ticket_id": widget.ticketID,
    // });
    futureModel = Future.value([
      {
        'ticket_DATE': '20250301',
        'org_CODE': 'TICKET001',
        'plate': 'กข1234',
        'accuse1_CODE': 'Speeding',
        'accuse2_CODE': 'Red light violation',
        'accuse3_CODE': null,
        'accuse4_CODE': null,
        'accuse5_CODE': null,
        'org_ABBR': 'Traffic Police',
        'fullname': 'John Doe',
        'card_ID': 'AB1234567890',
        'pic1': 'https://example.com/image1.jpg',
        'pic2': 'https://example.com/image2.jpg',
        'pic3': 'https://example.com/image3.jpg',
        'code': 'QR001',
      },
      {
        'ticket_DATE': '20250303',
        'org_CODE': 'TICKET002',
        'plate': 'ขค5678',
        'accuse1_CODE': 'Illegal parking',
        'accuse2_CODE': null,
        'accuse3_CODE': null,
        'accuse4_CODE': null,
        'accuse5_CODE': null,
        'org_ABBR': 'City Police',
        'fullname': 'Jane Smith',
        'card_ID': 'CD9876543210',
        'pic1': 'https://example.com/image4.jpg',
        'pic2': 'https://example.com/image5.jpg',
        'pic3': 'https://example.com/image6.jpg',
        'code': 'QR002',
      },
      {
        'ticket_DATE': '20250305',
        'org_CODE': 'TICKET003',
        'plate': 'คข2345',
        'accuse1_CODE': 'Parking in a no-parking zone',
        'accuse2_CODE': 'Not wearing a seatbelt',
        'accuse3_CODE': null,
        'accuse4_CODE': null,
        'accuse5_CODE': null,
        'org_ABBR': 'National Police',
        'fullname': 'Robert Johnson',
        'card_ID': 'EF1122334455',
        'pic1': 'https://example.com/image7.jpg',
        'pic2': 'https://example.com/image8.jpg',
        'pic3': null,
        'code': 'QR003',
      },
    ]);
  }
}
