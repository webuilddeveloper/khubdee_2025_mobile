import 'package:flutter/material.dart';
import 'package:KhubDeeDLT/pages/privilegeSpecial/privilege_special_form.dart';
import 'package:KhubDeeDLT/shared/extension.dart';

class PrivilegeSpecialListVertical extends StatefulWidget {
  PrivilegeSpecialListVertical({
    Key? key,
    this.model,
    this.code,
    this.title,
  }) : super(key: key);

  final Future<dynamic>? model;
  final String? code;
  final String? title;

  @override
  // ignore: library_private_types_in_public_api
  _PrivilegeSpecialListVertical createState() =>
      _PrivilegeSpecialListVertical();
}

class _PrivilegeSpecialListVertical
    extends State<PrivilegeSpecialListVertical> {
  @override
  void initState() {
    super.initState();
  }

  final List<String> items =
      List<String>.generate(10, (index) => "Item: ${++index}");

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: widget.model, // function where you call your api
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        // AsyncSnapshot<Your object type>
        if (snapshot.hasData) {
          if (snapshot.data.length == 0) {
            return Container(
              height: 200,
              alignment: Alignment.center,
              child: const Text(
                'ไม่พบข้อมูล',
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'Kanit',
                  color: Color.fromRGBO(0, 0, 0, 0.6),
                ),
              ),
            );
          } else {
            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.only(left: 10.0),
                      margin: EdgeInsets.only(bottom: 5.0, top: 10.0),
                      child: Text(
                        widget.title!,
                        style: const TextStyle(
                          color: Color(0xFF1B6CA8),
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                          fontFamily: 'Kanit',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1 / 1.5,
                    ),
                    physics: const ClampingScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: snapshot.data.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PrivilegeSpecialForm(
                                code: snapshot.data[index]['code'],
                              ),
                            ),
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              height: 165,
                              width: 165,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(5),
                                child: Image.network(
                                  '${snapshot.data[index]['imageUrl']}',
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10.0),
                            Container(
                              padding: const EdgeInsets.only(left: 10),
                              child: Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  '${snapshot.data[index]['title']}',
                                  style: const TextStyle(
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'Kanit',
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.only(left: 10),
                              child: Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  'จนถึง ${dateStringToDateStringFormat(snapshot.data[index]['updateDate'])}',
                                  style: const TextStyle(
                                    fontSize: 11.0,
                                    fontWeight: FontWeight.normal,
                                    fontFamily: 'Kanit',
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }
        } else {
          return Container(
            height: 800,
            padding: const EdgeInsets.only(left: 5.0, right: 5.0),
            child: GridView.count(
              crossAxisCount: 2,
              children: List.generate(
                10,
                (index) {
                  return Column(
                    children: <Widget>[
                      Expanded(
                        child: GestureDetector(
                          onTap: () {},
                          child: Container(
                            padding: const EdgeInsets.only(left: 30, right: 30),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    spreadRadius: 0,
                                    blurRadius: 7,
                                    offset: const Offset(
                                        0, 3), // changes position of shadow
                                  ),
                                ],
                                borderRadius: BorderRadius.circular(6.0),
                              ),
                            ),
                            // height: 205,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          );
        }
      },
    );
  }
}
