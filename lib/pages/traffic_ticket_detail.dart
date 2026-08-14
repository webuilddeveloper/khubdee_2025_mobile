import 'package:KhubDeeDLT/component/gallery_view.dart';
import 'package:KhubDeeDLT/component/material/custom_alert_dialog.dart';
import 'package:KhubDeeDLT/pages/appeal.dart';
import 'package:KhubDeeDLT/pages/blank_page/blank_loading.dart';
import 'package:KhubDeeDLT/pages/blank_page/toast_fail.dart';
import 'package:KhubDeeDLT/pages/qr_payment.dart';
import 'package:KhubDeeDLT/shared/extension.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:KhubDeeDLT/component/header.dart';

class TrafficTicketDetail extends StatefulWidget {
  final dynamic model;

  const TrafficTicketDetail({Key? key, required this.model}) : super(key: key);

  @override
  _TrafficTicketDetailPageState createState() =>
      _TrafficTicketDetailPageState();
}

class _TrafficTicketDetailPageState extends State<TrafficTicketDetail> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, () {
        Navigator.pop(context);
      }, title: 'รายละเอียดใบสั่ง'),
      backgroundColor: const Color(0xFFF5F8FB),      
      body: _screen(widget.model),      
      bottomNavigationBar: _buildBottomButtons(widget.model),
    );
  }

  _screen(dynamic model) {
    if (model == null) {
      return const Center(child: Text('ไม่พบข้อมูลใบสั่ง'));
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(model),
          const SizedBox(height: 16),
          _buildOffenseCard(model),
          const SizedBox(height: 16),          
          _buildFineCard(model),          
          // const SizedBox(height: 16),
          // _buildAppealButton(model),
        ],
      ),
    );
  }

  Widget _buildInfoCard(dynamic model) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'ข้อมูลใบสั่ง',
                  style: TextStyle(
                      fontFamily: 'Sarabun',
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
                if (model['ticket_STATUS'] != null)
                  statusBox(model['ticket_STATUS']),
              ],
            ),
            const Divider(height: 24),
            _textRow(
                title: 'เลขที่ใบสั่ง',
                value: model['ticket_ID'] ?? '-',
                icon: Icons.receipt_long_outlined),
            _textRow(
                title: 'วันที่กระทำผิด',
                value: dateStringToDate(model['occur_DT']),
                icon: Icons.calendar_today_outlined),
            _textRow(
                title: 'สถานที่',
                value: model['place'] ?? '-',
                icon: Icons.location_on_outlined),
            _textRow(
                title: 'หน่วยงาน',
                value: model['org_ABBR'] ?? '-',
                icon: Icons.account_balance_outlined),
          ],
        ),
      ),
    );
  }

  Widget _buildOffenseCard(dynamic model) {
    final offenses = [];
    for (int i = 1; i <= 5; i++) {
      if (model['accuse${i}_CODE'] != null && model['fine$i'] != null) {
        offenses.add({
          'title': model['accuse${i}_CODE'],
          'fine': model['fine$i'],
        });
      }
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'รายการข้อหา',
              style: TextStyle(
                  fontFamily: 'Sarabun',
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
            const Divider(height: 24),
            if (offenses.isEmpty)
              const Center(child: Text('ไม่พบรายการข้อหา'))
            else
              ...offenses.map((offense) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          '• ${offense['title']}',
                          style: const TextStyle(
                              fontFamily: 'Sarabun', fontSize: 14),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '${offense['fine']} บาท',
                        style: const TextStyle(
                            fontFamily: 'Sarabun',
                            fontSize: 14,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildFineCard(dynamic model) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'ค่าปรับทั้งหมด',
              style: TextStyle(
                  fontFamily: 'Sarabun',
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
            Text(
              '${model['fine_AMT'] ?? '0'} บาท',
              style: const TextStyle(
                fontFamily: 'Sarabun',
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFF7B06),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _textRow(
      {required String title, required String value, required IconData icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Theme.of(context).primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontFamily: 'Sarabun', fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                      fontFamily: 'Sarabun',
                      fontSize: 14,
                      color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons(dynamic model) {
    bool isPaid = model['ticket_STATUS'] == '3';

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.image_outlined),
                label: const Text('ดูรูปภาพ'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Theme.of(context).primaryColor,
                  side: BorderSide(color: Theme.of(context).primaryColor),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () {
                  List<ImageProvider> photos = [];
                  if (model['pic1'] != null && model['pic1'] != '') {
                    photos.add(NetworkImage(model['pic1']));
                  }
                  if (model['pic2'] != null && model['pic2'] != '') {
                    photos.add(NetworkImage(model['pic2']));
                  }
                  if (model['pic3'] != null && model['pic3'] != '') {
                    photos.add(NetworkImage(model['pic3']));
                  }

                  if (photos.isNotEmpty) {
                    showCupertinoDialog(
                      context: context,
                      builder: (context) => ImageViewer(
                          imageProviders: photos, initialIndex: 0),
                    );
                  } else {
                    toastFail(context, text: 'ไม่พบรูปภาพ');
                  }
                },
              ),
            ),
            if (!isPaid) ...[
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.qr_code_scanner),
                  label: const Text('ชำระค่าปรับ'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color(0xFFEBC22B),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 2,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            QRPayment(code: model['code'], back: false),
                      ),
                    );
                  },
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildAppealButton(dynamic model) {
    return Center(
      child: TextButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) => dialogVerification(model),
          );
        },
        child: const Text(
          'ยื่นอุทธรณ์',
          style: TextStyle(
            fontFamily: 'Sarabun',
            fontSize: 14,
            color: Color(0xFF9C0000),
            decoration: TextDecoration.underline,
          ),
        ),
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
          padding: EdgeInsets.symmetric(
            horizontal: 10,
          ),
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

  statusBox(String value) {
    var status = '';
    List<Color> colors = [const Color(0xFF07C9A8), const Color(0xFF03996F)];
    if (value == '1') {
      status = 'ค้างชำระ';
      colors = [const Color(0xFFFF2525), const Color(0xFFBC0611)];
    } else if (value == '2') {
      status = 'เกินกำหนดแล้วยังไม่ชำระ';
      colors = [const Color(0xFFFFC200), const Color(0xFFFF7B06)];
    } else if (value == '3') {
      status = 'ชำระแล้ว';
    }
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 7),
      height: 30,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(
        status,
        style: const TextStyle(
          fontFamily: 'Sarabun',
          fontSize: 11,
          color: Colors.white,
        ),
        // textAlign: TextAlign.center,
      ),
    );
  }
}
