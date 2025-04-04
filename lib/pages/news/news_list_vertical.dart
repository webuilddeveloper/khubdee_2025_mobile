import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:KhubDeeDLT/pages/blank_page/blank_data.dart';
import 'package:KhubDeeDLT/pages/blank_page/blank_loading.dart';
import 'package:KhubDeeDLT/pages/news/news_form.dart';

class NewsListVertical extends StatefulWidget {
  const NewsListVertical({
    Key? key,
    required this.site,
    required this.model,
    required this.title,
    required this.url,
    required this.urlComment,
    required this.urlGallery,
  }) : super(key: key);

  final String site;
  final Future<dynamic> model;
  final String title;
  final String url;
  final String urlComment;
  final String urlGallery;

  @override
  _NewsListVertical createState() => _NewsListVertical();
}

class _NewsListVertical extends State<NewsListVertical> {
  @override
  void initState() {
    super.initState();
  }

  final List<String> items =
      List<String>.generate(10, (index) => "Item: ${++index}");

  checkImageAvatar(String img) {
    return CircleAvatar(
      backgroundColor: Colors.white,
      backgroundImage: img != null
          ? NetworkImage(
              img,
            )
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: widget.model, // function where you call your api
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.length == 0) {
            return Container(
              alignment: Alignment.center,
              height: 200,
              child: Text(
                'ไม่พบข้อมูล',
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'Sarabun',
                  color: Color.fromRGBO(0, 0, 0, 0.6),
                ),
              ),
            );
          } else {
            print('1');
            return Container(
              color: Colors.transparent,
              alignment: Alignment.center,
              padding: EdgeInsets.only(left: 10.0, right: 10.0),
              child: ListView.builder(
                physics: ScrollPhysics(),
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                itemCount: snapshot.data.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NewsForm(
                            url: widget.url,
                            code: snapshot.data[index]['code'],
                            model: snapshot.data[index],
                            urlComment: widget.urlComment,
                            urlGallery: widget.urlGallery,
                          ),
                        ),
                      );
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 0,
                                    blurRadius: 7,
                                    offset: Offset(
                                        0, 3), // changes position of shadow
                                  ),
                                ],
                              ),
                              margin: EdgeInsets.only(bottom: 5.0),
                              // height: 334,
                              width: 600,
                              child: Column(
                                children: [
                                  Container(
                                    height: 55,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor,
                                      borderRadius: new BorderRadius.only(
                                        topLeft: const Radius.circular(5.0),
                                        topRight: const Radius.circular(5.0),
                                      ),
                                    ),
                                    padding: EdgeInsets.all(5),
                                    alignment: Alignment.centerLeft,
                                    child: Row(
                                      children: [
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              margin: EdgeInsets.fromLTRB(
                                                  8, 0, 0, 0),
                                              child: Text(
                                                // '${snapshot.data[index]['userList'][0]['firstName']} ${snapshot.data[index]['userList'][0]['lastName']}',
                                                '${snapshot.data[index]['categoryList'][0]['title']}',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontFamily: 'Sarabun',
                                                ),
                                              ),
                                            ),
                                            // Container(
                                            //   margin: EdgeInsets.fromLTRB(
                                            //       8, 0, 0, 0),
                                            //   child: Text(
                                            //     'วันที่ ' +
                                            //         dateStringToDate(
                                            //             snapshot.data[index]
                                            //                 ['createDate']),
                                            //     style: TextStyle(
                                            //       color: Colors.white,
                                            //       fontFamily: 'Sarabun',
                                            //       fontSize: 8.0,
                                            //       fontWeight: FontWeight.normal,
                                            //     ),
                                            //   ),
                                            // ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    constraints: BoxConstraints(
                                      minHeight: 200,
                                      maxHeight: 200,
                                      minWidth: double.infinity,
                                    ),
                                    child:
                                        snapshot.data[index]['imageUrl'] != null
                                            ? Image.network(
                                                '${snapshot.data[index]['imageUrl']}',
                                                fit: BoxFit.cover,
                                              )
                                            : BlankLoading(
                                                height: 200,
                                              ),
                                  ),
                                  Container(
                                    height: 60,
                                    decoration: BoxDecoration(
                                      borderRadius: new BorderRadius.only(
                                        bottomLeft: const Radius.circular(5.0),
                                        bottomRight: const Radius.circular(5.0),
                                      ),
                                      color: Color(0xFFFFFFFF),
                                    ),
                                    padding: EdgeInsets.all(5.0),
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      '${snapshot.data[index]['title']}',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontFamily: 'Sarabun',
                                        fontSize: 15.0,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          }
        } else {
          print('2');
          print(snapshot.data);
          return blankListData(context, height: 300);
        }
      },
    );
  }

  Future<dynamic> downloadData() async {
    var body = json.encode({
      "permission": "all",
      "skip": 0,
      "limit": 10 // integer value type
    });
    var response = await http.post(Uri.parse(''), body: body, headers: {
      "Accept": "application/json",
      "Content-Type": "application/json"
    });

    var data = json.decode(response.body);

    // int randomNumber = random.nextInt(10);
    // sleep(Duration(seconds: widget.sleep));
    return Future.value(data['objectData']);
    // return Future.value(response); // return your response
  }

  Future<dynamic> postData() async {
    var body = json.encode({
      "permission": "all",
      "skip": 0,
      "limit": 2 // integer value type
    });

    var client = new http.Client();
    client.post(
        Uri.parse("http://hwpolice.we-builds.com/hwpolice-api/privilege/read"),
        body: body,
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json"
        }).then((response) {
      client.close();
      var data = json.decode(response.body);

      if (data.length > 0) {
        sleep(const Duration(seconds: 10));
        setState(() {
          // Update your state here
        });
      } else {}
    }).catchError((onError) {
      client.close();
    });
  }
}
