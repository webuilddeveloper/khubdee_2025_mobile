import 'package:KhubDeeDLT/pages/score_criteria.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:KhubDeeDLT/component/header.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class BehaviorPoints extends StatefulWidget {
  @override
  _BehaviorPointsPageState createState() => _BehaviorPointsPageState();
}

class _BehaviorPointsPageState extends State<BehaviorPoints> {
  late Future<dynamic> futureModel;
  dynamic tempData;
  int _limit = 3;

  final RefreshController _refreshController = RefreshController(
    initialRefresh: false,
  );

  @override
  void initState() {
    super.initState();

    _read();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(
        context,
        () {
          Navigator.pop(context);
        },
        title: 'ตรวจสอบแต้มความประพฤติการขับขี่',
        isButtonRight: true,
        imageRightButton: 'assets/images/icon_info.png',
        rightButton: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ScoreCriteria()),
          );
        },
      ),
      backgroundColor: const Color(0xFFF5F8FB),
      body: InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: _screen(tempData),
        // child: _futureBuilder(),
      ),
    );
  }

  _screen(dynamic model) {
    int totalDeductedPoints = 0;
    if (model != null) {
      // Calculate the sum of deducted points
      for (var item in model) {
        totalDeductedPoints += (item['points'] as int).abs();
      }
    }
    // Assume starting points are 100
    int remainingPoints = 100 - totalDeductedPoints;
    return Column(
      children: [
        _buildScoreHeader(remainingPoints),
        Expanded(
          child: SmartRefresher(
            enablePullDown: false,
            enablePullUp: true,
            footer: const ClassicFooter(
              loadingText: ' ',
              canLoadingText: ' ',
              idleText: ' ',
              idleIcon: Icon(Icons.arrow_upward, color: Colors.transparent),
            ),
            controller: _refreshController,
            onLoading: _onLoading,
            onRefresh: _onRefresh,
            child: ListView.builder(
              physics: const ScrollPhysics(),
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              itemCount: model?.length ?? 0,
              itemBuilder: (context, index) {
                return _item(model[index]);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScoreHeader(int remainingPoints) {
    double percentage = remainingPoints / 100.0;
    Color progressColor;

    if (percentage > 0.5) {
      progressColor = Colors.green;
    } else if (percentage > 0.2) {
      progressColor = Colors.orange;
    } else {
      progressColor = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'แต้มคงเหลือ',
                style: TextStyle(
                    fontFamily: 'Sarabun',
                    fontSize: 16,
                    color: Colors.black54),
              ),
              Text.rich(
                TextSpan(
                  text: remainingPoints.toString(),
                  style: TextStyle(
                    fontFamily: 'Sarabun',
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: progressColor,
                  ),
                  children: const [
                    TextSpan(
                      text: ' / 100',
                      style: TextStyle(
                        fontFamily: 'Sarabun',
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percentage,
              minHeight: 12,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ),
        ],
      ),
    );
  }

  _item(dynamic model) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      'วันที่: ${model['date']}',
                      style: const TextStyle(
                          fontFamily: 'Sarabun',
                          fontSize: 14,
                          color: Colors.black54),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${model['points']} คะแนน',
                    style: const TextStyle(
                      fontFamily: 'Sarabun',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Text(
              model['offense'],
              style: const TextStyle(
                  fontFamily: 'Sarabun',
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _textRow(
                icon: Icons.location_on_outlined,
                title: 'สถานที่:',
                value: model['place']),
            const SizedBox(height: 8),
            _textRow(
                icon: Icons.receipt_long_outlined,
                title: 'เลขที่ใบสั่ง:',
                value: model['ticketId']),
            const SizedBox(height: 8),
            _textRow(
                icon: Icons.account_balance_outlined,
                title: 'หน่วยงาน:',
                value: model['department']),
          ],
        ),
      ),
    );
  }

  Widget _textRow({required IconData icon, String title = '', String value = ''}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Text(title,
            style: const TextStyle(
                fontFamily: 'Sarabun', fontSize: 14, color: Colors.grey)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
                fontFamily: 'Sarabun', fontSize: 14, color: Colors.black87),
          ),
        ),
      ],
    );
  }

  // function
  _read() async {
    // mock data
    var now = DateTime.now();
    final mockData = [
      {
        'date': DateFormat('dd-MM-yyyy').format(now.subtract(const Duration(days: 15))),
        'place': 'อำเภอเมือง จังหวัดเชียงใหม่',
        'ticketId': '240674',
        'department': 'สถานีตำรวจ ภาค 5',
        'offense': 'ขับรถเร็วเกินกำหนด แต่ไม่เกิน 100 กม.ต่อชม.',
        'points': -10,
      },
      {
        'date': DateFormat('dd-MM-yyyy').format(now.subtract(const Duration(days: 40))),
        'place': 'เขตจตุจักร กรุงเทพมหานคร',
        'ticketId': '350112',
        'department': 'สน.พหลโยธิน',
        'offense': 'ไม่ส่งผู้โดยสารตามที่ตกลง',
        'points': -20,
      },
      {
        'date': DateFormat('dd-MM-yyyy').format(now.subtract(const Duration(days: 75))),
        'place': 'อำเภอบางละมุง จังหวัดชลบุรี',
        'ticketId': '880234',
        'department': 'สภ.เมืองพัทยา',
        'offense': 'ขับรถประมาท หวาดเสียวเป็นอันตราย',
        'points': -30,
      },
      // {
      //   'date': DateFormat('dd-MM-yyyy').format(now.subtract(const Duration(days: 100))),
      //   'place': 'อำเภอหาดใหญ่ จังหวัดสงขลา',
      //   'ticketId': '542189',
      //   'department': 'สภ.หาดใหญ่',
      //   'offense': 'ไม่แสดงบัตรประจำตัวผู้ขับรถ',
      //   'points': -10,
      // },
    ].where((e) => true).toList(); // Ensure it's a growable list

    if (mounted) {
      setState(() {
        if (_limit > mockData.length) {
          tempData = mockData;
        } else {
          tempData = mockData.sublist(0, _limit);
        }
      });
    }
  }

  _onLoading() async {
    setState(() {
      _limit += 2;
    });
    _read();

    await Future.delayed(const Duration(milliseconds: 2000));

    _refreshController.loadComplete();
  }

  void _onRefresh() async {
    setState(() {
      _limit = 4;
    });
    _read();

    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
    // _refreshController.loadComplete();
  }
}
