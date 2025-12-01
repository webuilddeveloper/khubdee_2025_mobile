import 'package:flutter/material.dart';
import 'package:KhubDeeDLT/component/header.dart';
import 'package:KhubDeeDLT/pages/training/e_learning_courses.dart';
import 'package:KhubDeeDLT/pages/training/upskill_courses.dart';
import 'package:KhubDeeDLT/pages/training/e_certificate_list.dart';

class TrainingMain extends StatelessWidget {
  const TrainingMain({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(
        context,
        () {
          Navigator.pop(context);
        },
        title: 'Training & Upskill Academy',
      ),
      backgroundColor: const Color(0xFFF5F8FB),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'หมวดการเรียนรู้และอบรม',
              style: TextStyle(
                fontFamily: 'Sarabun',
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6F267B),
              ),
            ),
            const SizedBox(height: 20),
            _buildTrainingButton(
              title: 'E-Learning สำหรับต่ออายุ',
              icon: Icons.school,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ELearningCourses()),
                );
              },
            ),
            const SizedBox(height: 10),
            _buildTrainingButton(
              title: 'คอร์สเพิ่มทักษะพิเศษ',
              icon: Icons.star,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UpskillCourses()),
                );
              },
            ),
            const SizedBox(height: 10),
            _buildTrainingButton(
              title: 'ใบประกาศนียบัตรของฉัน',
              icon: Icons.card_membership,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ECertificateList()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrainingButton({required String title, required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), spreadRadius: 1, blurRadius: 3)],
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF6F267B), size: 28),
            const SizedBox(width: 15),
            Text(title, style: const TextStyle(fontFamily: 'Sarabun', fontSize: 16, color: Color(0xFF545454))),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, size: 18, color: Color(0xFF9E9E9E)),
          ],
        ),
      ),
    );
  }
}