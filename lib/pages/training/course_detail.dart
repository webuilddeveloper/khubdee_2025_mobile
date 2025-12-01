import 'package:flutter/material.dart';
import 'package:KhubDeeDLT/component/header.dart';
import 'package:webview_flutter/webview_flutter.dart'; // For video playback (mock)

class CourseDetail extends StatefulWidget {
  final Map<String, dynamic> course;

  const CourseDetail({Key? key, required this.course}) : super(key: key);

  @override
  _CourseDetailState createState() => _CourseDetailState();
}

class _CourseDetailState extends State<CourseDetail> {
  late WebViewController _webViewController;
  bool _isQuizStarted = false;
  bool _isQuizCompleted = false;
  bool _quizPassed = false;

  @override
  void initState() {
    super.initState();
    // Initialize WebViewController for mock video playback
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              return NavigationDecision.navigate;
            }
            return NavigationDecision.prevent;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.course['videoUrl'] ?? 'about:blank'));
  }

  void _startQuiz() {
    setState(() {
      _isQuizStarted = true;
    });
    // Simulate quiz completion after a delay
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        _isQuizCompleted = true;
        _quizPassed = true; // Simulate passing the quiz
      });
      _showQuizResultDialog();
    });
  }

  void _showQuizResultDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(_quizPassed ? 'ทำข้อสอบสำเร็จ!' : 'ทำข้อสอบไม่สำเร็จ'),
          content: Text(_quizPassed
              ? 'คุณผ่านการทำข้อสอบสำหรับคอร์สนี้แล้ว'
              : 'คุณยังไม่ผ่านการทำข้อสอบ กรุณาลองใหม่อีกครั้ง'),
          actions: <Widget>[
            TextButton(
              child: const Text('ตกลง'),
              onPressed: () {
                Navigator.of(context).pop();
                if (_quizPassed && widget.course['category'] == null) { // Only for E-Learning courses
                  // In a real app, this would update the course status in a database
                  // For mock, we can just show a message or navigate
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('สถานะคอร์สอัปเดตแล้ว!')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(
        context,
        () {
          Navigator.pop(context);
        },
        title: widget.course['title'],
      ),
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
            const SizedBox(height: 20),
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
                  child: WebViewWidget(controller: _webViewController),
                ),
              ),
              const SizedBox(height: 20),
            ],
            if (widget.course['category'] == null) // Only E-Learning courses have quizzes for renewal
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
                  if (!_isQuizStarted)
                    ElevatedButton(
                      onPressed: _startQuiz,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEBC22B),
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
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
                    )
                  else if (!_isQuizCompleted)
                    const Center(
                      child: Column(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 10),
                          Text(
                            'กำลังประมวลผลข้อสอบ...',
                            style: TextStyle(fontFamily: 'Sarabun'),
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _quizPassed ? Colors.green.shade100 : Colors.red.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _quizPassed ? Icons.check_circle : Icons.cancel,
                            color: _quizPassed ? Colors.green : Colors.red,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            _quizPassed ? 'คุณผ่านการทำข้อสอบแล้ว!' : 'คุณยังไม่ผ่านการทำข้อสอบ',
                            style: TextStyle(
                              fontFamily: 'Sarabun',
                              color: _quizPassed ? Colors.green.shade800 : Colors.red.shade800,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            const SizedBox(height: 20),
            if (widget.course['certificateStatus'] == 'earned')
              Center(
                child: Column(
                  children: [
                    const Icon(Icons.card_membership, color: Colors.amber, size: 40),
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
                        // Simulate viewing certificate
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('กำลังเปิดใบประกาศนียบัตร...')),
                        );
                      },
                      icon: const Icon(Icons.download, color: Colors.white),
                      label: const Text(
                        'ดูใบประกาศนียบัตร',
                        style: TextStyle(fontFamily: 'Sarabun', color: Colors.white),
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
}
