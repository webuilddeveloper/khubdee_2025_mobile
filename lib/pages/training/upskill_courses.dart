import 'package:KhubDeeDLT/pages/training/course_detail.dart';
import 'package:flutter/material.dart';
import 'package:KhubDeeDLT/component/header.dart';

class UpskillCourses extends StatefulWidget {
  @override
  _UpskillCoursesState createState() => _UpskillCoursesState();
}

class _UpskillCoursesState extends State<UpskillCourses> {
  final List<Map<String, dynamic>> _upskillCourses = [
    {
      'id': 'US001',
      'category': 'ภาษาต่างประเทศ',
      'title': 'ภาษาอังกฤษพื้นฐานสำหรับคนขับรถสาธารณะ',
      'description': 'เรียนรู้ประโยคและคำศัพท์ภาษาอังกฤษที่จำเป็นสำหรับการสื่อสารกับนักท่องเที่ยว',
      'imageUrl': 'https://via.placeholder.com/150/FF5733/FFFFFF?text=English', // Mock image URL
      'isEnrolled': true,
      'certificateStatus': 'not_earned',
    },
    {
      'id': 'US002',
      'category': 'เทคโนโลยี EV',
      'title': 'การดูแลรักษารถยนต์ไฟฟ้าเบื้องต้น',
      'description': 'ทำความเข้าใจหลักการทำงานและการบำรุงรักษารถยนต์ไฟฟ้าอย่างถูกวิธี',
      'imageUrl': 'https://via.placeholder.com/150/33FF57/FFFFFF?text=EV+Tech', // Mock image URL
      'isEnrolled': false,
      'certificateStatus': 'not_earned',
    },
    {
      'id': 'US003',
      'category': 'First Aid',
      'title': 'การปฐมพยาบาลเบื้องต้นเมื่อเจออุบัติเหตุ',
      'description': 'เรียนรู้เทคนิคการปฐมพยาบาลที่ถูกต้องเพื่อช่วยเหลือผู้ประสบเหตุบนท้องถนน',
      'imageUrl': 'https://via.placeholder.com/150/3357FF/FFFFFF?text=First+Aid', // Mock image URL
      'isEnrolled': true,
      'certificateStatus': 'earned',
    },
    {
      'id': 'US004',
      'category': 'Service Mind',
      'title': 'จิตวิทยาการให้บริการและการจัดการอารมณ์',
      'description': 'พัฒนาทักษะการบริการลูกค้าและการควบคุมอารมณ์ในสถานการณ์ต่างๆ',
      'imageUrl': 'https://via.placeholder.com/150/FFFF33/000000?text=Service+Mind', // Mock image URL
      'isEnrolled': false,
      'certificateStatus': 'not_earned',
    },
    {
      'id': 'US005',
      'category': 'ภาษาต่างประเทศ',
      'title': 'ภาษาจีนพื้นฐานสำหรับคนขับรถสาธารณะ',
      'description': 'เรียนรู้ประโยคและคำศัพท์ภาษาจีนที่จำเป็นสำหรับการสื่อสารกับนักท่องเที่ยวชาวจีน',
      'imageUrl': 'https://via.placeholder.com/150/FF33FF/FFFFFF?text=Chinese', // Mock image URL
      'isEnrolled': false,
      'certificateStatus': 'not_earned',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(
        context,
        () {
          Navigator.pop(context);
        },
        title: 'คอร์สเพิ่มทักษะพิเศษ',
      ),
      backgroundColor: const Color(0xFFF5F8FB),
      body: ListView.builder(
        padding: const EdgeInsets.all(10.0),
        itemCount: _upskillCourses.length,
        itemBuilder: (context, index) {
          final course = _upskillCourses[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 10.0),
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CourseDetail(course: course),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course['title'],
                      style: const TextStyle(
                        fontFamily: 'Sarabun',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6F267B),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      course['description'],
                      style: const TextStyle(
                        fontFamily: 'Sarabun',
                        fontSize: 13,
                        color: Color(0xFF545454),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildCategoryChip(course['category']),
                        _buildCertificateStatus(course['certificateStatus']),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryChip(String category) {
    return Chip(
      label: Text(
        category,
        style: const TextStyle(
          fontFamily: 'Sarabun',
          fontSize: 12,
          color: Colors.white,
        ),
      ),
      backgroundColor: const Color(0xFFEBC22B),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildCertificateStatus(String status) {
    Color color;
    String text;
    IconData icon;
    switch (status) {
      case 'earned':
        color = Colors.green;
        text = 'ได้รับใบประกาศ';
        icon = Icons.check_circle;
        break;
      default:
        color = Colors.grey;
        text = 'ยังไม่ได้รับใบประกาศ';
        icon = Icons.info_outline;
    }
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 5),
        Text(
          text,
          style: TextStyle(
            fontFamily: 'Sarabun',
            fontSize: 12,
            color: color,
          ),
        ),
      ],
    );
  }
}
