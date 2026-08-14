import 'package:KhubDeeDLT/component/header.dart';
import 'package:KhubDeeDLT/fund/fund-recommend-List-detail.dart';
import 'package:KhubDeeDLT/fund/fund-data.dart';
import 'package:flutter/material.dart';

class FundRecommendList extends StatefulWidget {
  const FundRecommendList({super.key});

  @override
  State<FundRecommendList> createState() => _AllFundsPageState();
}

class _AllFundsPageState extends State<FundRecommendList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: header(context, () {
        Navigator.pop(context);
      }, title: 'กองทุนทั้งหมด'),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            // หัวข้อ
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Text(
                    'รายการกองทุน',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '(เลือกกองทุนเพื่อดูรายละเอียด)',
                    style: TextStyle(fontSize: 13.5, color: Color(0xFF6D727A)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // รายการกองทุน - ใช้ข้อมูลจาก FundData
            ...FundData.allFundsList.map((fund) => _buildFundCard(fund)),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildFundCard(Map<String, dynamic> fund) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FundRecommendListDetail(fund: fund),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Icon Box
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    fund['icon'],
                    color: Theme.of(context).primaryColor,
                    size: 24,
                  ),
                ),

                const SizedBox(width: 14),

                // Texts
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fund['name'],
                        style: const TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),

                      if (fund['isEnrolled'])
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF48BB78).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'เข้าร่วมแล้ว',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: Color(0xFF2F855A),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                Icon(
                  Icons.arrow_forward_ios,
                  size: 22,
                  color: Theme.of(context).primaryColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
