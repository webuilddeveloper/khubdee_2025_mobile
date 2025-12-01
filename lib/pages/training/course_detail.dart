import 'package:flutter/material.dart';
import 'package:KhubDeeDLT/component/header.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart'; // For video playback (mock)

class CourseDetail extends StatefulWidget {
  final Map<String, dynamic> course;

  const CourseDetail({Key? key, required this.course}) : super(key: key);

  @override
  _CourseDetailState createState() => _CourseDetailState();
}

class _CourseDetailState extends State<CourseDetail> {
  late YoutubePlayerController _controller;
  bool _isQuizStarted = false;
  bool _isQuizCompleted = false;
  bool _quizPassed = false;
  late bool _isEnrolled;
  int _score = 0;

  final List<Map<String, dynamic>> _quizQuestions = [
    {
      'question':
          '1. เมื่อผู้ขับขี่มาถึงทางแยกที่มีสัญญาณไฟแดง แต่มีลูกศรเขียวให้เลี้ยวขวา ควรทำอย่างไร?',
      'options': [
        'หยุดหลังเส้นให้หยุด แต่สามารถเลี้ยวขวาได้ด้วยความระมัดระวัง',
        'ขับผ่านไปได้เลย แต่ต้องเลี้ยวขวาเท่านั้น',
        'ชะลอรถแล้วเลี้ยวขวาได้ทันที',
        'หยุดรอจนกว่าจะได้สัญญาณไฟเขียว',
      ],
      'correctAnswerIndex': 0,
    },
    {
      'question':
          '2. ในขณะขับรถ ผู้ขับขี่ต้องเว้นระยะห่างจากรถคันหน้าเท่าใดจึงจะปลอดภัย?',
      'options': [
        '1 เมตร',
        '2 เมตร',
        'ห่างพอที่จะหยุดรถได้โดยปลอดภัย',
        '5 เมตร',
      ],
      'correctAnswerIndex': 2,
    },
    {
      'question': '3. ป้าย "หยุด" มีความหมายว่าอย่างไร?',
      'options': [
        'ให้ผู้ขับขี่เตรียมพร้อมหยุดรถ',
        'ให้ผู้ขับขี่หยุดรถ และให้รถและคนเดินเท้าในทางขวางหน้าผ่านไปก่อน',
        'ให้ผู้ขับขี่ชะลอความเร็ว',
        'ให้ทางแก่รถที่สวนมา',
      ],
      'correctAnswerIndex': 1,
    },
  ];
  final Map<int, int?> _selectedAnswers = {};

  @override
  void initState() {
    super.initState();
    // E-Learning courses (category == null) are considered pre-enrolled.
    // Upskill courses depend on the 'isEnrolled' flag.
    _isEnrolled =
        (widget.course['isEnrolled'] ?? false) ||
        (widget.course['category'] == null);

    // Initialize quiz state based on the passed course data
    if (widget.course['quizStatus'] == 'passed') {
      _isQuizCompleted = true;
      _quizPassed = true;
    }

    // Assign to the class member _controller, not a new local variable.
    _controller = YoutubePlayerController(
      initialVideoId: YoutubePlayer.convertUrlToId(widget.course['videoUrl'] ?? '') ?? '',
      flags: const YoutubePlayerFlags(autoPlay: false, mute: false),
    );
  }

  @override
  void dispose() {
    // Make sure to dispose of the controller to avoid memory leaks.
    _controller.dispose();
    super.dispose();
  }

  void _submitQuiz() {
    if (_selectedAnswers.length < _quizQuestions.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณาตอบคำถามให้ครบทุกข้อ')),
      );
      return;
    }

    int correctAnswers = 0;
    for (int i = 0; i < _quizQuestions.length; i++) {
      if (_selectedAnswers[i] == _quizQuestions[i]['correctAnswerIndex']) {
        correctAnswers++;
      }
    }

    setState(() {
      _score = correctAnswers;
      _isQuizCompleted = true;
      _quizPassed = correctAnswers >= 2; // ผ่านเมื่อถูก 2 ข้อขึ้นไป
    });
    _showQuizResultDialog();
  }

  void _showQuizResultDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            _quizPassed ? 'ยินดีด้วย คุณสอบผ่าน!' : 'เสียใจด้วย คุณสอบไม่ผ่าน',
          ),
          content: Text(
            _quizPassed
                ? 'คุณทำข้อสอบได้ $_score เต็ม ${_quizQuestions.length} คะแนน'
                : 'คุณยังไม่ผ่านการทำข้อสอบ กรุณาลองใหม่อีกครั้ง',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('ตกลง'),
              onPressed: () {
                Navigator.of(context).pop();
                if (_quizPassed) {
                  // In a real app, this would update the course status in a database
                  // For mock, we can just show a message or navigate
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('สถานะคอร์สอัปเดตแล้ว!')),
                  );
                }
              },
            ),
            if (!_quizPassed)
              TextButton(
                child: const Text('ลองอีกครั้ง'),
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    _isQuizStarted = false;
                    _isQuizCompleted = false;
                    _selectedAnswers.clear();
                  });
                },
              ),
          ],
        );
      },
    );
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ไม่สามารถเปิด URL: $urlString ได้')),
      );
    }
  }

  Widget _buildQuiz() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _quizQuestions.length,
          itemBuilder: (context, index) {
            final question = _quizQuestions[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    question['question'],
                    style: const TextStyle(
                      fontFamily: 'Sarabun',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...List.generate(question['options'].length, (optionIndex) {
                    return RadioListTile<int>(
                      title: Text(
                        question['options'][optionIndex],
                        style: const TextStyle(
                          fontFamily: 'Sarabun',
                          fontSize: 14,
                        ),
                      ),
                      value: optionIndex,
                      groupValue: _selectedAnswers[index],
                      onChanged: (value) {
                        setState(() {
                          _selectedAnswers[index] = value;
                        });
                      },
                    );
                  }),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 20),
        Center(
          child: ElevatedButton(
            onPressed: _submitQuiz,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6F267B),
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
            ),
            child: const Text(
              'ส่งคำตอบ',
              style: TextStyle(
                fontFamily: 'Sarabun',
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, () {
        Navigator.pop(context);
      }, title: widget.course['title']),
      backgroundColor: const Color(0xFFF5F8FB),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.course['title'],
              style: const TextStyle(
                fontFamily: 'Sarabun',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6F267B),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              widget.course['description'],
              style: const TextStyle(
                fontFamily: 'Sarabun',
                fontSize: 15,
                color: Color(0xFF545454),
              ),
            ),
            const SizedBox(height: 15),
            _buildCourseInfoSection(),
            const SizedBox(height: 20),
            if (_isEnrolled) ...[
              if (widget.course['videoUrl'] != null) ...[
                const Text(
                  'วิดีโอการอบรม:',
                  style: TextStyle(
                    fontFamily: 'Sarabun',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: YoutubePlayer(
                      controller: _controller,
                      showVideoProgressIndicator: true,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
              // Show quiz section if:
              // 1. The course has a quiz.
              // 2. The user has NOT already earned the certificate for this course.
              if ((widget.course['hasQuiz'] == true ||
                      widget.course['category'] == null) &&
                  widget.course['certificateStatus'] != 'earned')
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ข้อสอบหลังเรียน:',
                      style: TextStyle(
                        fontFamily: 'Sarabun',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (_isQuizCompleted)
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color:
                              _quizPassed
                                  ? Colors.green.shade100
                                  : Colors.red.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _quizPassed ? Icons.check_circle : Icons.cancel,
                              color: _quizPassed ? Colors.green : Colors.red,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              // เพิ่ม Expanded เผื่อข้อความยาว
                              child: Text(
                                _quizPassed
                                    ? 'คุณผ่านการทำข้อสอบแล้ว!'
                                    : 'คุณยังไม่ผ่านการทำข้อสอบ',
                                style: TextStyle(
                                  fontFamily: 'Sarabun',
                                  color:
                                      _quizPassed
                                          ? Colors.green.shade800
                                          : Colors.red.shade800,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    else if (!_isQuizStarted)
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _isQuizStarted = true;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFEBC22B),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 30,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'เริ่มทำข้อสอบ',
                            style: TextStyle(
                              fontFamily: 'Sarabun',
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      )
                    else
                      _buildQuiz(),
                  ],
                ),
            ] else ...[
              // Show Enrollment Button if not enrolled
              Center(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.person_add, color: Colors.white),
                  label: const Text(
                    'สมัครเรียนคอร์สนี้',
                    style: TextStyle(
                      fontFamily: 'Sarabun',
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      _isEnrolled = true; // Simulate enrollment
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('สมัครเรียนสำเร็จ! เริ่มเรียนได้เลย'),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEBC22B),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 15,
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),
            if (widget.course['certificateStatus'] == 'earned')
              Center(
                child: Column(
                  children: [
                    const Icon(
                      Icons.card_membership,
                      color: Colors.amber,
                      size: 40,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'คุณได้รับใบประกาศนียบัตรอิเล็กทรอนิกส์สำหรับคอร์สนี้แล้ว!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Sarabun',
                        fontSize: 14,
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: () {
                        _launchUrl(
                          'https://today-obs.line-scdn.net/0hZI6UBYMjBWYLLBQc4Rh6MTN6CRc4Sh9vKRkfV3suUlVyAEU4N0NWBS8qWkp1SEo2K00eUygoWQQuSRYzNg/w1200',
                        );
                      },
                      icon: const Icon(Icons.download, color: Colors.white),
                      label: const Text(
                        'ดูใบประกาศนียบัตร',
                        style: TextStyle(
                          fontFamily: 'Sarabun',
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6F267B),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseInfoSection() {
    final hasQuiz =
        widget.course['hasQuiz'] == true || widget.course['category'] == null;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          _buildInfoRow(
            Icons.info_outline,
            'รูปแบบการเรียน:',
            'เรียนออนไลน์ผ่านวิดีโอในแอปพลิเคชัน\nสามารถเรียนได้ทุกที่ ทุกเวลา',
          ),
          const Divider(),
          _buildInfoRow(
            Icons.timer_outlined,
            'ระยะเวลาเรียน:',
            widget.course['accessDuration'] ?? 'เรียนได้ตลอดชีพ',
          ),
          const Divider(),
          _buildInfoRow(
            Icons.assignment_turned_in_outlined,
            'การรับใบประกาศ:',
            hasQuiz
                ? 'ต้องทำข้อสอบท้ายบทเรียนให้ผ่าน'
                : 'เรียนจบคอร์สเพื่อรับใบประกาศ',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF6F267B), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Sarabun',
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontFamily: 'Sarabun',
                    fontSize: 14,
                    color: Color(0xFF545454),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
