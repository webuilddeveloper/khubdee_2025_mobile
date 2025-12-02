import 'package:KhubDeeDLT/component/header.dart';
import 'package:KhubDeeDLT/pages/profile/drivers_info.dart';
import 'package:flutter/material.dart';

class DriverLicenseConsentPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(
        context,
        () {
          Navigator.pop(context);
        },
        title: 'ความยินยอม',
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Image.asset('assets/icons/icon_depa_transport.png',
                      height: 80),
                  SizedBox(height: 16),
                  Text(
                    'เผยแพร่ข้อมูลใบขับขี่',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Sarabun',
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Text(
              'แอปพลิเคชันมีความจำเป็นต้องเข้าถึงและแสดงข้อมูลใบอนุญาตขับขี่ของท่าน เพื่อการใช้งานฟังก์ชันที่เกี่ยวข้องกับการตรวจสอบสถานะใบอนุญาต, การแสดงข้อมูลใบอนุญาตดิจิทัล, และการแจ้งเตือนต่างๆ',
              style: TextStyle(fontSize: 16, fontFamily: 'Sarabun', height: 1.5),
            ),
            SizedBox(height: 15),
            Text(
              'ข้อมูลที่จะถูกแสดงประกอบด้วย:',
              style: TextStyle(fontSize: 16, fontFamily: 'Sarabun', height: 1.5),
            ),
            SizedBox(height: 10),
            _buildConsentItem('ชื่อ-นามสกุล'),
            _buildConsentItem('เลขที่ใบอนุญาต'),
            _buildConsentItem('ประเภทใบอนุญาต'),
            _buildConsentItem('วันที่ออกและวันหมดอายุ'),
            _buildConsentItem('รูปถ่ายประจำตัว'),
            SizedBox(height: 25),
            Text(
              'การกดปุ่ม "อนุญาต" หมายถึงท่านยินยอมให้แอปพลิเคชันเข้าถึงและแสดงข้อมูลดังกล่าว',
              style: TextStyle(
                  fontSize: 16, fontFamily: 'Sarabun', color: Colors.grey[700]),
            ),
            Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => DriversInfo()),
                  );
                },
                child: Text(
                  'อนุญาต',
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'Sarabun',
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildConsentItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, top: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '> ',
            style: TextStyle(fontSize: 16, fontFamily: 'Sarabun'),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 16, fontFamily: 'Sarabun'),
            ),
          ),
        ],
      ),
    );
  }
}