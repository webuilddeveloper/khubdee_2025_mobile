import 'package:flutter/material.dart';
import 'package:KhubDeeDLT/component/key_search.dart';
import 'package:KhubDeeDLT/component/header.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:url_launcher/url_launcher.dart';

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
      'image': 'http://gcc.go.th/wp-content/uploads/2025/09/mt220968_5.jpg',
      'url':
          'https://gcc.go.th/2025/09/22/%E0%B8%81%E0%B8%9B%E0%B8%96-%E0%B9%80%E0%B8%9B%E0%B8%B4%E0%B8%94%E0%B8%A3%E0%B8%B1%E0%B8%9A%E0%B8%84%E0%B8%B3%E0%B8%82%E0%B8%AD%E0%B8%A3%E0%B8%B1%E0%B8%9A%E0%B9%80%E0%B8%87%E0%B8%B4%E0%B8%99-2/',
      'views': 2580,
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
              const SizedBox(height: 16),
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
              const SizedBox(height: 16),

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
          final url = item['url'];
          if (url != null && url.isNotEmpty) {
            launchUrl(Uri.parse(url));
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // รูปภาพ
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(8),
              ),
              child:
                  item['image'] != null
                      ? Image.network(
                        item['image'],
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.fitWidth,
                      )
                      : Container(
                        height: 180,
                        width: double.infinity,
                        color: Colors.grey[200],
                        child: Center(
                          child: Image.asset(
                            'assets/icons/icon_fund.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // หมวดหมู่
                  // Container(
                  //   padding: const EdgeInsets.symmetric(
                  //     horizontal: 8,
                  //     vertical: 4,
                  //   ),
                  //   decoration: BoxDecoration(
                  //     color: _getCategoryColor(item['category']),
                  //     borderRadius: BorderRadius.circular(4),
                  //   ),
                  //   child: Text(
                  //     item['category'] ?? '',
                  //     style: const TextStyle(
                  //       color: Colors.white,
                  //       fontSize: 12,
                  //       fontWeight: FontWeight.w500,
                  //     ),
                  //   ),
                  // ),
                  // const SizedBox(height: 12),
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
}
