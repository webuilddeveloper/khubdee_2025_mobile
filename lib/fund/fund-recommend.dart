import 'package:KhubDeeDLT/fund/fund-main.dart';
import 'package:flutter/material.dart';
import 'package:KhubDeeDLT/component/header.dart';

class FundRecommend extends StatefulWidget {
  const FundRecommend({super.key});

  @override
  State<FundRecommend> createState() => _FunndMyMainState();
}

class _FunndMyMainState extends State<FundRecommend> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: header(context, () => Navigator.pop(context), title: 'กปถ.'),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// LOGO
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/images/DLT.jpg',
                    height: MediaQuery.of(context).size.height * 0.2,
                    width: MediaQuery.of(context).size.width * 0.4,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Center(
                child: Text(
                  'กองทุนเพื่อความปลอดภัยในการใช้รถใช้ถนน (กปถ.)',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              /// INFO CARD
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'เกี่ยวกับกองทุน',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'กองทุนเพื่อความปลอดภัยในการใช้รถใช้ถนน (กปถ.) '
                      'มีวัตถุประสงค์เพื่อสนับสนุนและส่งเสริมความปลอดภัยทางถนน '
                      'รวมถึงช่วยเหลือผู้ประสบภัยจากอุบัติเหตุ และสนับสนุนหน่วยงานด้านความปลอดภัยทางถนน',
                      style: TextStyle(fontSize: 15),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// BENEFITS SECTION
              const Text(
                'สิทธิประโยชน์ของกองทุน',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),

              const SizedBox(height: 12),

              _buildBenefitItem(
                Icons.shield_outlined,
                'สนับสนุนค่าใช้จ่ายผู้ประสบภัยจากรถ',
              ),
              _buildBenefitItem(
                Icons.school_outlined,
                'อบรมและให้ความรู้ด้านความปลอดภัยทางถนน',
              ),
              _buildBenefitItem(
                Icons.health_and_safety_outlined,
                'สนับสนุนอุปกรณ์และโครงการลดอุบัติเหตุ',
              ),
              _buildBenefitItem(
                Icons.group_outlined,
                'ส่งเสริมชุมชนและหน่วยงานในการป้องกันอุบัติเหตุ',
              ),

              const SizedBox(height: 30),

              /// BUTTON
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FundMain(title: 'กองทุน'),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Text(
                    'เข้าสู่บริการกองทุน',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 22, color: Theme.of(context).primaryColor),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 15))),
        ],
      ),
    );
  }
}
