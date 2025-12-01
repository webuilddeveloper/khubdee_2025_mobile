import 'package:flutter/material.dart';
import 'package:KhubDeeDLT/component/header.dart';
import 'package:intl/intl.dart';

class ECertificateList extends StatefulWidget {
  @override
  _ECertificateListState createState() => _ECertificateListState();
}

class _ECertificateListState extends State<ECertificateList> {
  final List<Map<String, dynamic>> _certificates = [
    {
      'id': 'CERT001',
      'courseTitle': 'กฎหมายจราจรและมารยาทในการขับขี่',
      'issueDate': DateTime(2025, 11, 15),
      'certificateUrl': 'https://via.placeholder.com/300x200/0000FF/FFFFFF?text=Certificate+001', // Mock certificate image
    },
    {
      'id': 'CERT002',
      'courseTitle': 'การปฐมพยาบาลเบื้องต้นเมื่อเจออุบัติเหตุ',
      'issueDate': DateTime(2025, 10, 20),
      'certificateUrl': 'https://via.placeholder.com/300x200/FF0000/FFFFFF?text=Certificate+002', // Mock certificate image
    },
    {
      'id': 'CERT003',
      'courseTitle': 'ภาษาอังกฤษพื้นฐานสำหรับคนขับรถสาธารณะ',
      'issueDate': DateTime(2025, 9, 5),
      'certificateUrl': 'https://via.placeholder.com/300x200/00FF00/FFFFFF?text=Certificate+003', // Mock certificate image
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(
        context,
        () {
          Navigator.pop(context);
        },
        title: 'ใบประกาศนียบัตรของฉัน',
      ),
      backgroundColor: const Color(0xFFF5F8FB),
      body: _certificates.isEmpty
          ? const Center(
              child: Text(
                'ยังไม่มีใบประกาศนียบัตร',
                style: TextStyle(
                  fontFamily: 'Sarabun',
                  fontSize: 16,
                  color: Color(0xFF9E9E9E),
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(10.0),
              itemCount: _certificates.length,
              itemBuilder: (context, index) {
                final certificate = _certificates[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10.0),
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  child: InkWell(
                    onTap: () {
                      // In a real app, this would open the certificate PDF/image
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text(certificate['courseTitle']),
                            content: Image.network(certificate['certificateUrl']),
                            actions: <Widget>[
                              TextButton(
                                child: const Text('ปิด'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            certificate['courseTitle'],
                            style: const TextStyle(
                              fontFamily: 'Sarabun',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF6F267B),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'ออกเมื่อ: ${DateFormat('dd MMMM yyyy', 'th').format(certificate['issueDate'])}',
                            style: const TextStyle(
                              fontFamily: 'Sarabun',
                              fontSize: 13,
                              color: Color(0xFF545454),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Icon(Icons.picture_as_pdf, color: Colors.red.shade700),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
