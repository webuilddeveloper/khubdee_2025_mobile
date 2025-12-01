import 'package:KhubDeeDLT/pages/training/course_detail.dart';
import 'package:flutter/material.dart';
import 'package:KhubDeeDLT/component/header.dart';

class ELearningCourses extends StatefulWidget {
  @override
  _ELearningCoursesState createState() => _ELearningCoursesState();
}

class _ELearningCoursesState extends State<ELearningCourses> {
  final List<Map<String, dynamic>> _eLearningCourses = [
    {
      'id': 'EL001',
      'title': 'การอบรมเพื่อต่ออายุใบอนุญาตขับขี่ (ภาคทฤษฎี)',
      'description': 'วิดีโออบรมออนไลน์สำหรับผู้ต้องการต่ออายุใบอนุญาตขับขี่รถยนต์ส่วนบุคคลและรถจักรยานยนต์',
      'videoUrl': 'https://www.youtube.com/watch?v=o1ei72JIdiE', // Mock video URL
      'isCompleted': false,
      'quizStatus': 'not_started', // 'not_started', 'in_progress', 'completed', 'passed', 'failed'
      'duration': '2 ชั่วโมง',
    },
    {
      'id': 'EL002',
      'title': 'กฎหมายจราจรและมารยาทในการขับขี่',
      'description': 'เรียนรู้กฎหมายจราจรที่สำคัญและมารยาทในการขับขี่เพื่อความปลอดภัยบนท้องถนน',
      'videoUrl': 'https://www.youtube.com/watch?v=o1ei72JIdiE', // Mock video URL
      'isCompleted': true,
      'quizStatus': 'passed',
      'duration': '1 ชั่วโมง 30 นาที',
    },
    {
      'id': 'EL003',
      'title': 'การบำรุงรักษารถยนต์เบื้องต้น',
      'description': 'ความรู้เบื้องต้นเกี่ยวกับการดูแลรักษารถยนต์เพื่อยืดอายุการใช้งานและลดอุบัติเหตุ',
      'videoUrl': 'https://www.youtube.com/watch?v=o1ei72JIdiE', // Mock video URL
      'isCompleted': false,
      'quizStatus': 'not_started',
      'duration': '1 ชั่วโมง',
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
        title: 'E-Learning สำหรับต่ออายุ',
      ),
      backgroundColor: const Color(0xFFF5F8FB),
      body: ListView.builder(
        padding: const EdgeInsets.all(10.0),
        itemCount: _eLearningCourses.length,
        itemBuilder: (context, index) {
          final course = _eLearningCourses[index];
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
                        _buildStatusChip(course['quizStatus']),
                        Text(
                          'ระยะเวลา: ${course['duration']}',
                          style: const TextStyle(
                            fontFamily: 'Sarabun',
                            fontSize: 12,
                            color: Color(0xFF9E9E9E),
                          ),
                        ),
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

  Widget _buildStatusChip(String status) {
    Color color;
    String text;
    switch (status) {
      case 'passed':
        color = Colors.green;
        text = 'ผ่านแล้ว';
        break;
      case 'completed':
        color = Colors.blue;
        text = 'ดูจบแล้ว';
        break;
      case 'in_progress':
        color = Colors.orange;
        text = 'กำลังเรียน';
        break;
      case 'failed':
        color = Colors.red;
        text = 'ไม่ผ่าน';
        break;
      default:
        color = Colors.grey;
        text = 'ยังไม่เริ่ม';
    }
    return Chip(
      label: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Sarabun',
          fontSize: 12,
          color: Colors.white,
        ),
      ),
      backgroundColor: color,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
