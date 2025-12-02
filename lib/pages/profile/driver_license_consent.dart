import 'package:KhubDeeDLT/component/header.dart';
import 'package:KhubDeeDLT/pages/profile/drivers_info.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class DriverLicenseConsentPage extends StatefulWidget {
  @override
  State<DriverLicenseConsentPage> createState() =>
      _DriverLicenseConsentPageState();
}

class _DriverLicenseConsentPageState extends State<DriverLicenseConsentPage> {
  bool _showAnimation = true;

  @override
  void initState() {
    super.initState();

    // แสดง Lottie 3 วินาที แล้วค่อยโชว์เนื้อหาปกติ
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        _showAnimation = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, () {
        Navigator.pop(context);
      }, title: 'ความยินยอม'),
      body:
          _showAnimation
              ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 🔹 ThaiID Icon อยู่ด้านบน
                    Image.asset(
                      'assets/logo/socials/thaiid-icon.png', // <= ใส่ path icon จริงของเพื่อนเลิฟ
                      height: 80,
                    ),
                    SizedBox(height: 16),

                    // 🔹 Lottie Animation Cred Tick
                    Lottie.asset(
                      'assets/lotties/cred_tick_animation.json',
                      width: 200,
                      repeat: true, // ถ้าจะให้หมุนรอบเดียวเปลี่ยนเป็น false
                    ),

                    SizedBox(height: 8),
                    Text(
                      "กำลังตรวจสอบข้อมูล...",
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Sarabun',
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              )
              : Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/icons/icon_depa_transport.png',
                            height: 80,
                          ),
                          const SizedBox(height: 16),
                          const Text(
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
                    const SizedBox(height: 20),
                    const Text(
                      'แอปพลิเคชันมีความจำเป็นต้องเข้าถึงและแสดงข้อมูลใบอนุญาตขับขี่ของท่าน เพื่อการใช้งานฟังก์ชันที่เกี่ยวข้องกับการตรวจสอบสถานะใบอนุญาต, การแสดงข้อมูลใบอนุญาตดิจิทัล, และการแจ้งเตือนต่างๆ',
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Sarabun',
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'ข้อมูลที่จะถูกแสดงประกอบด้วย:',
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Sarabun',
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildConsentItem('ชื่อ-นามสกุล'),
                    _buildConsentItem('เลขที่ใบอนุญาต'),
                    _buildConsentItem('ประเภทใบอนุญาต'),
                    _buildConsentItem('วันที่ออกและวันหมดอายุ'),
                    _buildConsentItem('รูปถ่ายประจำตัว'),
                    const SizedBox(height: 25),
                    Text(
                      'การกดปุ่ม "อนุญาต" หมายถึงท่านยินยอมให้แอปพลิเคชันเข้าถึงและแสดงข้อมูลดังกล่าว',
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Sarabun',
                        color: Colors.grey[700],
                      ),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DriversInfo(),
                            ),
                          );
                        },
                        child: const Text(
                          'อนุญาต',
                          style: TextStyle(
                            fontSize: 18,
                            fontFamily: 'Sarabun',
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
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
          const Text(
            '> ',
            style: TextStyle(fontSize: 16, fontFamily: 'Sarabun'),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16, fontFamily: 'Sarabun'),
            ),
          ),
        ],
      ),
    );
  }
}
