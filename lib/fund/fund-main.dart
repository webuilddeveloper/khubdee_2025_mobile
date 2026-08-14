import 'package:KhubDeeDLT/fund/fund-my.dart';
import 'package:KhubDeeDLT/fund/fund-new.dart';
import 'package:KhubDeeDLT/fund/fund-recommend-List.dart';
import 'package:flutter/material.dart';
import 'package:KhubDeeDLT/component/header.dart';
import 'package:url_launcher/url_launcher.dart';

class FundMain extends StatelessWidget {
  final String title;

  const FundMain({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, () {
        Navigator.pop(context);
      }, title: title),
      backgroundColor: const Color(0xFFF5F8FB),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            _buildFundButton(
              title: 'ข่าวสารกองทุน',
              icon: Icons.list_alt,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FundList(title: 'ข่าวสารกองทุน'),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            _buildFundButton(
              title: 'ประมูลเลขสวย',
              icon: Icons.gavel_outlined,
              onTap: () {
                final url = 'http://extra.tabienrod.com/REG_ZONE2/login.php';
                if (url.isNotEmpty) {
                  launchUrl(Uri.parse(url));
                }
              },
            ),
            const SizedBox(height: 10),
            _buildFundButton(
              title: 'กองทุนแนะนำ',
              icon: Icons.recommend_outlined,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FundRecommendList(),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            _buildFundButton(
              title: 'กองทุนของฉัน',
              icon: Icons.account_balance_wallet_outlined,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FundMyPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFundButton({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 3,
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF6F267B), size: 28),
            const SizedBox(width: 15),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Sarabun',
                fontSize: 16,
                color: Color(0xFF545454),
              ),
            ),
            const Spacer(),
            const Icon(
              Icons.arrow_forward_ios,
              size: 18,
              color: Color(0xFF9E9E9E),
            ),
          ],
        ),
      ),
    );
  }
}
