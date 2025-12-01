import 'package:KhubDeeDLT/component/header.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FundDetailPage extends StatelessWidget {
  final Map<String, dynamic> fund;

  const FundDetailPage({Key? key, required this.fund}) : super(key: key);

  String formatCurrency(double amount, {bool withSymbol = true}) {
    final format = NumberFormat.currency(
      locale: 'th_TH',
      symbol: withSymbol ? '฿' : '',
      decimalDigits: 2,
    );
    return format.format(amount);
  }

  // Mock data for transaction history
  List<Map<String, dynamic>> get a_transactionHistory {
    return [
      {'date': '2025-11-01', 'description': 'เงินสมทบประจำเดือน', 'amount': fund['monthlyContribution'], 'type': 'deposit'},
      {'date': '2025-10-01', 'description': 'เงินสมทบประจำเดือน', 'amount': fund['monthlyContribution'], 'type': 'deposit'},
      {'date': '2025-09-15', 'description': 'เงินปันผลประจำปี', 'amount': fund['amount'] * 0.02, 'type': 'dividend'},
      {'date': '2025-09-01', 'description': 'เงินสมทบประจำเดือน', 'amount': fund['monthlyContribution'], 'type': 'deposit'},
      {'date': '2025-08-01', 'description': 'เงินสมทบประจำเดือน', 'amount': fund['monthlyContribution'], 'type': 'deposit'},
      {'date': '2025-07-20', 'description': 'ถอนเงินกรณีพิเศษ', 'amount': -1500.0, 'type': 'withdraw'},
      {'date': '2025-07-01', 'description': 'เงินสมทบประจำเดือน', 'amount': fund['monthlyContribution'], 'type': 'deposit'},
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: header(context, () {
        Navigator.pop(context);
      }, title: fund['name']),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            _buildFundSummaryCard(),
            const SizedBox(height: 32),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'ประวัติการทำรายการ',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildTransactionList(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildFundSummaryCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: fund['color'],
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: fund['color'].withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ยอดสะสมปัจจุบัน',
              style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.8)),
            ),
            const SizedBox(height: 8),
            Text(
              formatCurrency(fund['amount']),
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            const Divider(color: Colors.white24, height: 1),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSummaryInfo('ผลตอบแทน', '+${fund['returnPercent']}%', Icons.trending_up),
                _buildSummaryInfo('ส่งรายเดือน', formatCurrency(fund['monthlyContribution']), Icons.payments_outlined),
                _buildSummaryInfo('เป็นสมาชิก', 'ตั้งแต่ ${fund['memberSince']}', Icons.card_membership),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryInfo(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.white.withOpacity(0.8), size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.8)),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionList() {
    return ListView.separated(
      itemCount: a_transactionHistory.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      separatorBuilder: (context, index) => const Divider(height: 1, indent: 16, endIndent: 16),
      itemBuilder: (context, index) {
        final transaction = a_transactionHistory[index];
        final isDeposit = transaction['amount'] >= 0;
        final iconData = transaction['type'] == 'deposit'
            ? Icons.add_circle
            : transaction['type'] == 'dividend'
                ? Icons.star
                : Icons.remove_circle;
        final color = transaction['type'] == 'deposit'
            ? Colors.green
            : transaction['type'] == 'dividend'
                ? Colors.orange
                : Colors.red;

        return ListTile(
          leading: CircleAvatar(
            backgroundColor: color.withOpacity(0.1),
            child: Icon(iconData, color: color, size: 24),
          ),
          title: Text(
            transaction['description'],
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
          ),
          subtitle: Text(
            DateFormat('d MMM yyyy', 'th_TH').format(DateTime.parse(transaction['date'])),
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
          trailing: Text(
            '${isDeposit ? '+' : ''}${formatCurrency(transaction['amount'], withSymbol: false)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        );
      },
    );
  }
}