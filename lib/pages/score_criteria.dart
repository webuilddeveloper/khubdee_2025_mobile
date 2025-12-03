import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:KhubDeeDLT/component/header.dart';
import 'package:flutter/widgets.dart';

class ScoreCriteria extends StatefulWidget {
  const ScoreCriteria({super.key});

  @override
  _ScoreCriteriaPageState createState() => _ScoreCriteriaPageState();
}

class _ScoreCriteriaPageState extends State<ScoreCriteria> {
  // Data for point deductions
  final List<Map<String, dynamic>> group1 = [
    {'law': 'พ.ร.บ. รถยนต์', 'offenses': ['ไม่แสดงบัตรประจำตัวผู้ขับรถ', 'ใช้รถที่ยังมิได้จดทะเบียน', 'ใช้รถไม่ตรงตามที่จดทะเบียน', 'ใช้รถจักรยานยนต์ส่วนบุคคลมารับจ้าง', 'กระทำก่อความรำคาญแก่ผู้โดยสาร']},
    {'law': 'พ.ร.บ. การขนส่งทางบก', 'offenses': ['แสดงกิริยาไม่สุภาพขณะปฏิบัติหน้าที่', 'ไม่ดูแลให้ผู้โดยสารปลอดภัยขณะโดยสาร', 'ไม่หยุดรับหรือส่งผู้โดยสาร ณ ที่ให้หยุด', 'ใช้ความเร็วเกินกำหนด แต่ไม่เกิน 100 กม.ต่อชม.']}
  ];
  final List<Map<String, dynamic>> group2 = [
    {'law': 'พ.ร.บ. การขนส่งทางบก', 'offenses': ['ไม่ใช้มาตรค่าโดยสาร', 'ปฏิเสธผู้โดยสาร', 'ไม่ส่งผู้โดยสารตามที่ตกลง ทิ้งผู้โดยสาร', 'แสดงกิริยาไม่สุภาพ', 'เสพของมึนเมาขณะขับรถ', 'ใช้รถสิ้นอายุ']},
    {'law': 'พ.ร.บ. รถยนต์', 'offenses': ['ไม่ใช้เครื่อง GPS', 'ไม่ใช้เครื่องอุปกรณ์และส่วนควบของรถ', 'ไม่ใช้อุปกรณ์ล็อกตู้บรรทุกสินค้า', 'ละทิ้งหน้าที่ผู้ขับรถ', 'บรรทุกผู้โดยสารเกินจำนวนที่นั่ง', 'ใช้ความเร็วเกินตั้งแต่ 101-110 กม.ต่อชม.']}
  ];
  final List<Map<String, dynamic>> group3 = [
    {'law': 'พ.ร.บ. รถยนต์', 'offenses': ['กระทำการลามก', 'ขับรถประมาท หวาดเสียวเป็นอันตราย', 'แก้ไขดัดแปลงมาตรค่าโดยสาร', 'เมาสุราหรือของมึนเมา ขณะขับรถ', 'ขับรถระหว่างที่ใบอนุญาตสิ้นอายุพักใช้/ถูกยึด', 'เก็บค่าโดยสารเกินกฎหมายกำหนด']},
    {'law': 'พ.ร.บ. การขนส่งทางบก', 'offenses': ['กระทำการลามก', 'ใช้อุปกรณ์ตัดสัญญาณ GPS', 'ใช้โทรศัพท์เคลื่อนที่ในขณะขับรถ', 'บรรทุกน้ำมันเชื้อเพลิง ระเบิด หรือวัตถุอันตรายโดยฝ่าฝืนข้อห้าม', 'ให้ผู้โดยสารลงก่อนถึงจุดหมายปลายทาง', 'ขับรถประมาทหวาดเสียวเกิดอันตราย', 'ใช้ความเร็วเกิน 110 กม.ต่อชม.']}
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, () {
        Navigator.pop(context);
      }, title: 'หลักเกณฑ์คะแนนความประพฤติ'),
      backgroundColor: const Color(0xFFF5F8FB),
      body: InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: _screen(),
      ),
    );
  }

  _screen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(),
          const SizedBox(height: 20),
          const Text(
            'เกณฑ์การตัดแต้มใบขับขี่',
            style: TextStyle(
                fontFamily: 'Sarabun',
                fontSize: 18,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _buildExpansionTile('กลุ่มที่ 1: ตัดครั้งละ 10 คะแนน', group1, Colors.orange),
          const SizedBox(height: 10),
          _buildExpansionTile('กลุ่มที่ 2: ตัดครั้งละ 20 คะแนน', group2, Colors.deepOrange),
          const SizedBox(height: 10),
          _buildExpansionTile('กลุ่มที่ 3: ตัดครั้งละ 30 คะแนน', group3, Colors.red),
          const SizedBox(height: 20),
          _buildSectionCard('บทลงโทษที่จะได้รับ', [
            'เหลือ 0 คะแนน: ถูกสั่งพักใช้ใบอนุญาตเป็นเวลา 90 วัน',
            'ถูกพักใช้ใบอนุญาตเกิน 2 ครั้งใน 3 ปี: ถูกสั่งพักใช้ใบอนุญาตเป็นเวลา 180 วัน',
            'กระทำผิดร้ายแรง (เช่น เสพยา, ขับรถขณะถูกพักใช้): ถูกพักใช้ใบอนุญาตทันที และถูกตัดคะแนนเหลือ 0 คะแนนในครั้งเดียว',
          ]),
          const SizedBox(height: 20),
          _buildSectionCard('การคืนคะแนน', [
            'อบรม 2 ชั่วโมง: ได้รับคืน 50 คะแนน',
            'อบรม 4 ชั่วโมง: ได้รับคืน 100 คะแนน',
            'ขอเข้ารับการอบรมคืนคะแนนได้ปีละ 1 ครั้ง',
            'ผู้ถูกพักใช้ใบอนุญาต: ต้องอบรม 4 ชั่วโมงเท่านั้น และจะได้รับ 100 คะแนนคืนเมื่อพ้นกำหนด',
          ]),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'มาตรการตัดแต้มใบขับขี่รถสาธารณะ',
              style: TextStyle(
                  fontFamily: 'Sarabun',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor),
            ),
            const SizedBox(height: 8),
            const Text(
              'บังคับใช้กับผู้ขับรถบรรทุก, รถโดยสาร, แท็กซี่, ตุ๊กตุ๊ก, และ จยย. รับจ้าง เพื่อควบคุมพฤติกรรมการขับรถให้ปลอดภัย โดยผู้ขับขี่ทุกคนมีคะแนนเริ่มต้น 100 คะแนน',
              style: TextStyle(fontFamily: 'Sarabun', fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 8),
            const Text(
              'หมายเหตุ: ไม่เกี่ยวข้องกับมาตรการตัดแต้มรถยนต์ส่วนบุคคลของสำนักงานตำรวจแห่งชาติ',
              style: TextStyle(
                  fontFamily: 'Sarabun', fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpansionTile(
      String title, List<Map<String, dynamic>> content, Color indicatorColor) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      child: ExpansionTile(
        title: Text(
          title,
          style: const TextStyle(
              fontFamily: 'Sarabun',
              fontSize: 16,
              fontWeight: FontWeight.bold),
        ),
        leading: Container(
          width: 12,
          height: 12,
          decoration:
              BoxDecoration(color: indicatorColor, shape: BoxShape.circle),
        ),
        childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: content.map((group) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  group['law'],
                  style: const TextStyle(
                      fontFamily: 'Sarabun',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54),
                ),
                const SizedBox(height: 4),
                ...List<Widget>.from(
                  (group['offenses'] as List<String>).map(
                    (offense) => _buildOffenseItem(offense),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildOffenseItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, top: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 7, right: 8),
            child: Icon(Icons.circle, size: 5, color: Colors.grey),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontFamily: 'Sarabun', fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(String title, List<String> items) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                  fontFamily: 'Sarabun',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor),
            ),
            const SizedBox(height: 10),
            ...items.map((item) => _buildOffenseItem(item)).toList(),
          ],
        ),
      ),
    );
  }
}

class _ListRules extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> data;

  const _ListRules({required this.title, required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ...data.map((group) {
            return Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(group['law'],
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  ...(group['offenses'] as List<String>).map((offense) {
                    return Text(' • $offense');
                  }).toList(),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
