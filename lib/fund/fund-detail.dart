import 'package:flutter/material.dart';
import 'package:KhubDeeDLT/component/key_search.dart';
import 'package:KhubDeeDLT/component/header.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class FundList extends StatefulWidget {
  FundList({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  _FundListState createState() => _FundListState();
}

class _FundListState extends State<FundList> {
  bool hideSearch = true;
  final txtDescription = TextEditingController();
  String? keySearch;
  String? category;
  int _limit = 10;
  List<Map<String, dynamic>> displayedData = [];

  // ข้อมูล Mock สำหรับกองทุนเพื่อความปลอดภัยในการใช้รถใช้ถนน (กปถ.) ปี 2025
  final List<Map<String, dynamic>> mockFundData = [
    {
      'id': '1',
      'title': 'กปถ. เปิดรับคำขอรับเงินค่าอุปกรณ์ช่วยเหลือผู้พิการ ปี 2568',
      'description':
          'เปิดรับคำขอรับจัดสรรเงินเป็นค่าอุปกรณ์ช่วยเหลือผู้พิการอันเนื่องมาจากการประสบภัยจากการใช้รถใช้ถนน ช่วงเดือนมกราคม - กุมภาพันธ์ 2568',
      'category': 'ช่วยเหลือผู้พิการ',
      'date': '2025-01-15',
      'site': 'DDPM',
      'image':
          'https://via.placeholder.com/300x200/4CAF50/ffffff?text=ช่วยเหลือผู้พิการ',
      'views': 2580,
    },
    {
      'id': '2',
      'title': 'กปถ. จัดประมูลทะเบียนรถเลขสวย หมวด 3คฐ ครั้งที่ 1/2568',
      'description':
          'กองทุนเพื่อความปลอดภัยในการใช้รถใช้ถนนเปิดประมูลทะเบียนรถเลขสวยลักษณะพิเศษออนไลน์ เพื่อนำรายได้พัฒนาความปลอดภัยทางถนน',
      'category': 'ประมูลทะเบียน',
      'date': '2025-02-20',
      'site': 'DDPM',
      'image':
          'https://via.placeholder.com/300x200/2196F3/ffffff?text=ประมูลทะเบียน',
      'views': 4250,
    },
    {
      'id': '3',
      'title': 'กปถ. สนับสนุนงบโครงการลดอุบัติเหตุช่วงสงกรานต์ 2568',
      'description':
          'จัดสรรงบประมาณสนับสนุนหน่วยงานท้องถิ่นในการจัดกิจกรรมรณรงค์ลดอุบัติเหตุทางถนนช่วงเทศกาลสงกรานต์',
      'category': 'โครงการ',
      'date': '2025-03-10',
      'site': 'DDPM',
      'image': 'https://via.placeholder.com/300x200/9C27B0/ffffff?text=โครงการ',
      'views': 3120,
    },
    {
      'id': '4',
      'title': 'ผลการดำเนินงาน กปถ. ไตรมาสแรก ปี 2568',
      'description':
          'รายงานผลการดำเนินงานกองทุน กปถ. ในไตรมาสแรกของปี พบว่าสามารถช่วยเหลือผู้ประสบภัยไปแล้ว 1,245 ราย',
      'category': 'ความสำเร็จ',
      'date': '2025-04-05',
      'site': 'DDPM',
      'image': 'https://via.placeholder.com/300x200/F44336/ffffff?text=ผลงาน',
      'views': 1890,
    },
    {
      'id': '5',
      'title': 'กปถ. ร่วม MOT เปิดตัวแคมเปญ "ขับขี่ปลอดภัย ชีวิตมีค่า"',
      'description':
          'ร่วมกับกระทรวงคมนาคมเปิดตัวแคมเปญรณรงค์สร้างจิตสำนึกความปลอดภัยทางถนน มุ่งลดอุบัติเหตุให้เหลือต่ำกว่า 10 คนต่อแสนประชากร',
      'category': 'กิจกรรม',
      'date': '2025-05-18',
      'site': 'DDPM',
      'image': 'https://via.placeholder.com/300x200/00BCD4/ffffff?text=กิจกรรม',
      'views': 2670,
    },
    {
      'id': '6',
      'title': 'ประกาศหลักเกณฑ์ขอรับทุนวิจัย กปถ. ประจำปี 2568',
      'description':
          'เปิดรับข้อเสนอโครงการวิจัยด้านความปลอดภัยทางถนน งบสนับสนุนโครงการละไม่เกิน 2 ล้านบาท',
      'category': 'งานวิจัย',
      'date': '2025-06-25',
      'site': 'DDPM',
      'image':
          'https://via.placeholder.com/300x200/3F51B5/ffffff?text=งานวิจัย',
      'views': 1450,
    },
    {
      'id': '7',
      'title': 'กปถ. จัดอบรมผู้ประสานงานจังหวัด ภาคกลาง',
      'description':
          'จัดการอบรมเชิงปฏิบัติการสำหรับผู้ประสานงาน กปถ. ระดับจังหวัดในเขตภาคกลาง เพื่อเพิ่มประสิทธิภาพการให้บริการ',
      'category': 'กิจกรรม',
      'date': '2025-07-12',
      'site': 'DDPM',
      'image': 'https://via.placeholder.com/300x200/00BCD4/ffffff?text=อบรม',
      'views': 980,
    },
    {
      'id': '8',
      'title': 'รายงานสถานการณ์อุบัติเหตุทางถนนครึ่งปีแรก 2568',
      'description':
          'กปถ. เผยสถิติอุบัติเหตุทางถนนครึ่งปีแรกลดลง 8.5% จากปีก่อน สะท้อนความสำเร็จของมาตรการป้องกัน',
      'category': 'รายงาน',
      'date': '2025-08-08',
      'site': 'DDPM',
      'image': 'https://via.placeholder.com/300x200/607D8B/ffffff?text=รายงาน',
      'views': 3340,
    },
    {
      'id': '9',
      'title': 'กปถ. ร่วม ตร. เปิดจุดตรวจสร้างวินัยจราจรช่วงเทศกาลปีใหม่',
      'description':
          'ร่วมกับตำรวจภูธรภาค 1-9 จัดตั้งจุดตรวจสร้างวินัยจราจรและให้ความรู้ความปลอดภัยช่วงเทศกาลปีใหม่',
      'category': 'โครงการ',
      'date': '2025-09-22',
      'site': 'DDPM',
      'image': 'https://via.placeholder.com/300x200/9C27B0/ffffff?text=โครงการ',
      'views': 2120,
    },
    {
      'id': '10',
      'title': 'แผนปฏิบัติการ กปถ. ปี 2569 เน้นเทคโนโลยีดิจิทัล',
      'description':
          'เตรียมขับเคลื่อนแผนปีหน้าด้วยระบบดิจิทัล AI วิเคราะห์จุดเสี่ยงอุบัติเหตุ และพัฒนาแอปพลิเคชันรายงานสถานการณ์แบบเรียลไทม์',
      'category': 'แผนงาน',
      'date': '2025-10-30',
      'site': 'DDPM',
      'image': 'https://via.placeholder.com/300x200/607D8B/ffffff?text=แผนงาน',
      'views': 1780,
    },
  ];

  final RefreshController _refreshController = RefreshController(
    initialRefresh: false,
  );

  @override
  void dispose() {
    txtDescription.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // โหลดข้อมูล Mock
  void _loadData() {
    setState(() {
      displayedData = _getFilteredData().take(_limit).toList();
    });
  }

  // กรองข้อมูลตาม keySearch และ category
  List<Map<String, dynamic>> _getFilteredData() {
    List<Map<String, dynamic>> filtered = List.from(mockFundData);

    // กรองตาม keySearch
    if (keySearch != null && keySearch!.isNotEmpty) {
      filtered =
          filtered.where((item) {
            return item['title'].toString().toLowerCase().contains(
                  keySearch!.toLowerCase(),
                ) ||
                item['description'].toString().toLowerCase().contains(
                  keySearch!.toLowerCase(),
                );
          }).toList();
    }

    // กรองตาม category
    if (category != null && category!.isNotEmpty && category != 'ทั้งหมด') {
      filtered =
          filtered.where((item) {
            return item['category'] == category;
          }).toList();
    }

    return filtered;
  }

  // โหลดข้อมูลเพิ่มเติม (Load More)
  void _onLoading() async {
    await Future.delayed(Duration(milliseconds: 800));

    setState(() {
      _limit = _limit + 10;
      displayedData = _getFilteredData().take(_limit).toList();
    });

    _refreshController.loadComplete();
  }

  void goBack() {
    Navigator.pop(context, false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: header(context, goBack, title: widget.title ?? 'กองทุน กปถ.'),
      body: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (OverscrollIndicatorNotification overScroll) {
          overScroll.disallowIndicator();
          return false;
        },
        child: SmartRefresher(
          enablePullDown: false,
          enablePullUp: displayedData.length < _getFilteredData().length,
          footer: const ClassicFooter(
            loadingText: 'กำลังโหลด...',
            canLoadingText: 'ปล่อยเพื่อโหลดเพิ่มเติม',
            idleText: 'ดึงขึ้นเพื่อโหลดเพิ่มเติม',
            idleIcon: Icon(Icons.arrow_upward, color: Colors.grey),
          ),
          controller: _refreshController,
          onLoading: _onLoading,
          child: ListView(
            physics: const ScrollPhysics(),
            shrinkWrap: true,
            children: [
              const SizedBox(height: 5),
              KeySearch(
                show: hideSearch,
                onKeySearchChange: (String val) {
                  setState(() {
                    keySearch = val;
                    _limit = 10;
                    displayedData = _getFilteredData().take(_limit).toList();
                  });
                },
              ),
              const SizedBox(height: 10),
              // แสดงรายการข้อมูล
              _buildFundList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFundList() {
    if (displayedData.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            children: [
              Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'ไม่พบข้อมูล',
                style: TextStyle(fontSize: 18, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: displayedData.length,
      itemBuilder: (context, index) {
        final item = displayedData[index];
        return _buildFundCard(item);
      },
    );
  }

  Widget _buildFundCard(Map<String, dynamic> item) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          // Navigate to detail page
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // รูปภาพ
            // ClipRRect(
            //   borderRadius: const BorderRadius.vertical(
            //     top: Radius.circular(8),
            //   ),
            //   child: Container(
            //     height: 180,
            //     width: double.infinity,
            //     color: Colors.grey[200],
            //     child: Center(
            //       child: Image.asset(
            //         'assets/icons/icon_fund.png',
            //         fit: BoxFit.cover,
            //       ),
            //     ),
            //   ),
            // ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // หมวดหมู่
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(item['category']),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      item['category'] ?? '',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // หัวข้อ
                  Text(
                    item['title'] ?? '',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // คำอธิบาย
                  Text(
                    item['description'] ?? '',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  // ข้อมูลเพิ่มเติม
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        item['date'] ?? '',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      const Spacer(),
                      Icon(Icons.visibility, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${item['views']} ครั้ง',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String? category) {
    switch (category) {
      case 'ช่วยเหลือผู้พิการ':
        return Colors.green;
      case 'ประมูลทะเบียน':
        return Colors.blue;
      case 'รางวัล':
        return Colors.orange;
      case 'รายงาน':
        return Colors.blueGrey;
      case 'โครงการ':
        return Colors.purple;
      case 'ความสำเร็จ':
        return Colors.red;
      case 'แผนงาน':
        return Colors.blueGrey;
      case 'ประกาศ':
        return Colors.brown;
      case 'กิจกรรม':
        return Colors.cyan;
      case 'เป้าหมาย':
        return Colors.lightGreen;
      case 'งานวิจัย':
        return Colors.indigo;
      case 'กฎหมาย':
        return Colors.teal;
      case 'โครงสร้าง':
        return Colors.deepPurple;
      default:
        return Colors.grey;
    }
  }
}
