import 'package:KhubDeeDLT/component/header.dart';
import 'package:KhubDeeDLT/pages/poi/poi_list.dart';
import 'package:KhubDeeDLT/shared/api_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PoiMain extends StatefulWidget {
  final String title;
  final LatLng latLng;

  const PoiMain({Key? key, required this.title, required this.latLng})
      : super(key: key);

  @override
  _PoiMainState createState() => _PoiMainState();
}

class _PoiMainState extends State<PoiMain> {
  late Future<dynamic> futureCategory;

  @override
  void initState() {
    super.initState();
    futureCategory = postCategory('${poiCategoryApi}read', {
      'skip': 0,
      'limit': 100,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(
        context,
        () => Navigator.pop(context),
        title: widget.title,
      ),
      backgroundColor: Colors.white,
      body: FutureBuilder<dynamic>(
        future: futureCategory,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('เกิดข้อผิดพลาดในการโหลดข้อมูล'));
          } else if (snapshot.hasData && snapshot.data.isNotEmpty) {
            List<dynamic> categories = snapshot.data;
            return ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                var category = categories[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    leading: category['imageUrl'] != null &&
                            category['imageUrl'].isNotEmpty
                        ? Image.network(
                            category['imageUrl'],
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Icon(Icons.location_on, size: 40),
                          )
                        : Icon(Icons.location_on, size: 40),
                    title: Text(
                      category['title'] ?? 'ไม่มีชื่อหมวดหมู่',
                      style: TextStyle(fontFamily: 'Sarabun'),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PoiList(
                            title: category['title'] ?? widget.title,
                            latLng: widget.latLng,
                            categoryCode: category['code'],
                            categoryTitle: category['title'],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          } else {
            return Center(child: Text('ไม่พบหมวดหมู่'));
          }
        },
      ),
    );
  }
}