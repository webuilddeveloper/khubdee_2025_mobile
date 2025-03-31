import 'package:KhubDeeDLT/component/material/custom_alert_dialog.dart';
import 'package:KhubDeeDLT/component/material/field_item.dart';
import 'package:KhubDeeDLT/home_v2.dart';
import 'package:KhubDeeDLT/pages/profile/drivers_info.dart';
import 'package:KhubDeeDLT/shared/api_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:KhubDeeDLT/component/header.dart';

class RegisterWithLicensePlate extends StatefulWidget {
  @override
  _RegisterWithLicensePlatePageState createState() =>
      _RegisterWithLicensePlatePageState();
}

class _RegisterWithLicensePlatePageState
    extends State<RegisterWithLicensePlate> {
  final storage = FlutterSecureStorage();
  final _formKey = GlobalKey<FormState>();

  DateTime selectedDate = DateTime.now();
  TextEditingController vehicleTypeRef = TextEditingController();
  TextEditingController plate1 = TextEditingController();
  TextEditingController plate2 = TextEditingController();
  TextEditingController offLocCode = TextEditingController();

  late Future<dynamic> futureModel;

  List<dynamic> _itemprovince = [];
  late String _selectedprovince = '';

  List<dynamic> _itemvehicleType = [];
  late String _selectedvehicleType = '';

  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    _read();
    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop:
          () => Navigator.of(context)
              .pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => HomePageV2()),
                (Route<dynamic> route) => false,
              )
              .then((result) {
                return false;
              }),
      child: Scaffold(
        appBar: header(context, () {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => HomePageV2()),
            (Route<dynamic> route) => false,
          );
          // Navigator.pop(context,false);
        }, title: 'ตรวจสอบข้อมูลทะเบียนรถที่ครอบครอง'),
        backgroundColor: Color(0xFFF5F8FB),
        body: InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: screen(),
        ),
      ),
    );
  }

  screen() {
    return SingleChildScrollView(
      child: Column(
        // mainAxisSize: MainAxisSize.max,
        // crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 240,
            color: Color(0xFFDFCDCA),
            child: Column(
              children: [
                SizedBox(height: 34),
                Expanded(
                  child: Container(
                    child: Image.asset(
                      'assets/license_plate.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Container(alignment: Alignment.center, height: 34),
              ],
            ),
          ),
          fieldDropdown(
            title: 'ประเภทรถ',
            hintText: 'เลือกประเภทรถ',
            controller: vehicleTypeRef,
            itemsData: _itemvehicleType,
            selectData: _selectedvehicleType,
            typeDropdown: "vehicleType",
            textInputType: TextInputType.text,
            validator: (value) {},
            onChanged: (value) {},
            inputFormatters: [],
          ),
          fieldItem(
            title: 'หมวดตัวอักษร',
            hintText: 'หมวดตัวอักษร',
            controller: plate1,
          ),
          fieldItem(
            title: 'หมวดตัวเลข',
            hintText: 'หมวดตัวเลข',
            controller: plate2,
          ),
          fieldDropdown(
            title: 'จังหวัด',
            hintText: 'เลือกจังหวัด',
            controller: offLocCode,
            itemsData: _itemprovince,
            selectData: _selectedprovince,
            typeDropdown: "province",
            textInputType: TextInputType.text,
            validator: (value) {},
            onChanged: (value) {},
            inputFormatters: [],
          ),
          SizedBox(height: 100),
          Container(
            child: Material(
              elevation: 5.0,
              borderRadius: BorderRadius.circular(10.0),
              color: Color(0xFF9C0000),
              child: MaterialButton(
                minWidth: 200,
                height: 40,
                onPressed: () {
                  dialogVerification();
                },
                child: Text(
                  'ตกลง',
                  style: TextStyle(
                    fontSize: 18.0,
                    color: Colors.white,
                    fontWeight: FontWeight.normal,
                    fontFamily: 'Sarabun',
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<dynamic> dialogVerification() async {
    if (_selectedvehicleType == null ||
        plate1.text == '' ||
        plate2.text == '' ||
        _selectedprovince == null) {
      // toastFail(context, text: 'กรุณากรอกข้อมูลให้ครบถ้วน');
      return showDialog(
        context: context,
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: () {
              return Future.value(false);
            },
            child: CustomAlertDialog(
              contentPadding: EdgeInsets.all(0),
              content: Container(
                width: 325,
                height: 300,
                // width: MediaQuery.of(context).size.width / 1.3,
                // height: MediaQuery.of(context).size.height / 2.5,
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  color: const Color(0xFFFFFF),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.white,
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: 20),
                      Image.asset('assets/cross_ quadrangle.png', height: 50),
                      // Icon(
                      //   Icons.check_circle_outline_outlined,
                      //   color: Color(0xFF5AAC68),
                      //   size: 60,
                      // ),
                      SizedBox(height: 10),
                      Text(
                        'กรุณากรอกข้อมูลให้ครบถ้วน',
                        style: TextStyle(
                          fontFamily: 'Sarabun',
                          fontSize: 15,
                          // color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'กรุณายืนยันตัวผ่านตัวเลือกดังต่อไปนี้',
                        style: TextStyle(
                          fontFamily: 'Sarabun',
                          fontSize: 15,
                          color: Color(0xFF4D4D4D),
                        ),
                      ),
                      SizedBox(height: 28),
                      Container(height: 0.5, color: Color(0xFFcfcfcf)),
                      InkWell(
                        onTap: () {
                          Navigator.pop(context, false);
                        },
                        child: Container(
                          height: 45,
                          alignment: Alignment.center,
                          child: Text(
                            'ลองใหม่อีกครั้ง',
                            style: TextStyle(
                              fontFamily: 'Sarabun',
                              fontSize: 15,
                              color: Color(0xFF4D4D4D),
                            ),
                          ),
                        ),
                      ),
                      Container(height: 0.5, color: Color(0xFFcfcfcf)),
                      InkWell(
                        onTap: () {
                          Navigator.pop(context, false);
                          Navigator.pop(context, false);
                        },
                        child: Container(
                          height: 45,
                          alignment: Alignment.center,
                          child: Text(
                            'ยกเลิก',
                            style: TextStyle(
                              fontFamily: 'Sarabun',
                              fontSize: 15,
                              color: Color(0xFF9C0000),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // child: //Contents here
              ),
            ),
          );
        },
      );
    } else {
      String? profileCode = await storage.read(key: 'profileCode2');
      String? idcard = await storage.read(key: 'idcard');
         return showDialog(
            context: context,
            builder: (BuildContext context) {
              return WillPopScope(
                onWillPop: () {
                  return Future.value(false);
                },
                child: CustomAlertDialog(
                  contentPadding: EdgeInsets.all(0),
                  content: Container(
                    width: 325,
                    height: 235,
                    // width: MediaQuery.of(context).size.width / 1.3,
                    // height: MediaQuery.of(context).size.height / 2.5,
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      color: const Color(0xFFFFFF),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.white,
                      ),
                      child: Column(
                        children: [
                          SizedBox(height: 10),
                          Image.asset('assets/check_circle.png', height: 50),
                          // Icon(
                          //   Icons.check_circle_outline_outlined,
                          //   color: Color(0xFF5AAC68),
                          //   size: 60,
                          // ),
                          SizedBox(height: 10),
                          Text(
                            'ยืนยันตัวตนสำเร็จ',
                            style: TextStyle(
                              fontFamily: 'Sarabun',
                              fontSize: 15,
                              // color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 30),
                          Container(height: 0.5, color: Color(0xFFcfcfcf)),
                          InkWell(
                            onTap: () {
                              Navigator.pop(context, false);
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DriversInfo(),
                                ),
                              );
                            },
                            child: Container(
                              height: 50,
                              alignment: Alignment.center,
                              child: Text(
                                'ดูใบอนุญาตขับรถของฉัน',
                                style: TextStyle(
                                  fontFamily: 'Sarabun',
                                  fontSize: 15,
                                  color: Color(0xFF4D4D4D),
                                ),
                              ),
                            ),
                          ),
                          Container(height: 0.5, color: Color(0xFFcfcfcf)),
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                Navigator.pop(context, false);
                                Navigator.pop(context, false);
                                // Navigator.pushReplacement(
                                //   context,
                                //   MaterialPageRoute(
                                //     builder: (context) => HomePage(),
                                //   ),
                                // );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Color(0xFF9C0000),
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(10),
                                    bottomRight: Radius.circular(10),
                                  ),
                                ),
                                height: 45,
                                alignment: Alignment.center,
                                child: Text(
                                  'ไปหน้าหลัก',
                                  style: TextStyle(
                                    fontFamily: 'Sarabun',
                                    fontSize: 15,
                                    color: Color(0xFFFFFFFF),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // child: //Contents here
                  ),
                ),
              );
            },
          );
       
      // if (profileCode != '' && profileCode != null) {
      //   final result =
      //       await postObjectDataMW(serverMW + 'DLT/insertVehicleInfoByPlate', {
      //         'code': profileCode,
      //         'createBy': profileCode,
      //         'updateBy': profileCode,
      //         'plate1': plate1.text,
      //         'plate2': plate2.text,
      //         'vehicleTypeRef': _selectedvehicleType,
      //         'offLocCode': _selectedprovince,
      //         'docNo': idcard,
      //         'reqDocNo': idcard,
      //       });
      //   if (result['status'] == 'S') {
      //     return showDialog(
      //       context: context,
      //       builder: (BuildContext context) {
      //         return WillPopScope(
      //           onWillPop: () {
      //             return Future.value(false);
      //           },
      //           child: CustomAlertDialog(
      //             contentPadding: EdgeInsets.all(0),
      //             content: Container(
      //               width: 325,
      //               height: 235,
      //               // width: MediaQuery.of(context).size.width / 1.3,
      //               // height: MediaQuery.of(context).size.height / 2.5,
      //               decoration: BoxDecoration(
      //                 shape: BoxShape.rectangle,
      //                 color: const Color(0xFFFFFF),
      //               ),
      //               child: Container(
      //                 decoration: BoxDecoration(
      //                   borderRadius: BorderRadius.circular(15),
      //                   color: Colors.white,
      //                 ),
      //                 child: Column(
      //                   children: [
      //                     SizedBox(height: 10),
      //                     Image.asset('assets/check_circle.png', height: 50),
      //                     // Icon(
      //                     //   Icons.check_circle_outline_outlined,
      //                     //   color: Color(0xFF5AAC68),
      //                     //   size: 60,
      //                     // ),
      //                     SizedBox(height: 10),
      //                     Text(
      //                       'ยืนยันตัวตนสำเร็จ',
      //                       style: TextStyle(
      //                         fontFamily: 'Sarabun',
      //                         fontSize: 15,
      //                         // color: Colors.black,
      //                       ),
      //                     ),
      //                     SizedBox(height: 30),
      //                     Container(height: 0.5, color: Color(0xFFcfcfcf)),
      //                     InkWell(
      //                       onTap: () {
      //                         Navigator.pop(context, false);
      //                         Navigator.pushReplacement(
      //                           context,
      //                           MaterialPageRoute(
      //                             builder: (context) => DriversInfo(),
      //                           ),
      //                         );
      //                       },
      //                       child: Container(
      //                         height: 50,
      //                         alignment: Alignment.center,
      //                         child: Text(
      //                           'ดูใบอนุญาตขับรถของฉัน',
      //                           style: TextStyle(
      //                             fontFamily: 'Sarabun',
      //                             fontSize: 15,
      //                             color: Color(0xFF4D4D4D),
      //                           ),
      //                         ),
      //                       ),
      //                     ),
      //                     Container(height: 0.5, color: Color(0xFFcfcfcf)),
      //                     Expanded(
      //                       child: InkWell(
      //                         onTap: () {
      //                           Navigator.pop(context, false);
      //                           Navigator.pop(context, false);
      //                           // Navigator.pushReplacement(
      //                           //   context,
      //                           //   MaterialPageRoute(
      //                           //     builder: (context) => HomePage(),
      //                           //   ),
      //                           // );
      //                         },
      //                         child: Container(
      //                           decoration: BoxDecoration(
      //                             color: Color(0xFF9C0000),
      //                             borderRadius: BorderRadius.only(
      //                               bottomLeft: Radius.circular(10),
      //                               bottomRight: Radius.circular(10),
      //                             ),
      //                           ),
      //                           height: 45,
      //                           alignment: Alignment.center,
      //                           child: Text(
      //                             'ไปหน้าหลัก',
      //                             style: TextStyle(
      //                               fontFamily: 'Sarabun',
      //                               fontSize: 15,
      //                               color: Color(0xFFFFFFFF),
      //                             ),
      //                           ),
      //                         ),
      //                       ),
      //                     ),
      //                   ],
      //                 ),
      //               ),
      //               // child: //Contents here
      //             ),
      //           ),
      //         );
      //       },
      //     );
      //   } else {
      //     return showDialog(
      //       context: context,
      //       builder: (BuildContext context) {
      //         return WillPopScope(
      //           onWillPop: () {
      //             return Future.value(false);
      //           },
      //           child: CustomAlertDialog(
      //             contentPadding: EdgeInsets.all(0),
      //             content: Container(
      //               width: 325,
      //               height: 300,
      //               // width: MediaQuery.of(context).size.width / 1.3,
      //               // height: MediaQuery.of(context).size.height / 2.5,
      //               decoration: BoxDecoration(
      //                 shape: BoxShape.rectangle,
      //                 color: const Color(0xFFFFFF),
      //               ),
      //               child: Container(
      //                 decoration: BoxDecoration(
      //                   borderRadius: BorderRadius.circular(15),
      //                   color: Colors.white,
      //                 ),
      //                 child: Column(
      //                   children: [
      //                     SizedBox(height: 20),
      //                     Image.asset(
      //                       'assets/cross_ quadrangle.png',
      //                       height: 50,
      //                     ),
      //                     // Icon(
      //                     //   Icons.check_circle_outline_outlined,
      //                     //   color: Color(0xFF5AAC68),
      //                     //   size: 60,
      //                     // ),
      //                     SizedBox(height: 10),
      //                     Text(
      //                       'ยืนยันตัวตนไม่สำเร็จ',
      //                       style: TextStyle(
      //                         fontFamily: 'Sarabun',
      //                         fontSize: 15,
      //                         // color: Colors.black,
      //                       ),
      //                     ),
      //                     SizedBox(height: 10),
      //                     Text(
      //                       'กรุณายืนยันตัวผ่านตัวเลือกดังต่อไปนี้',
      //                       style: TextStyle(
      //                         fontFamily: 'Sarabun',
      //                         fontSize: 15,
      //                         color: Color(0xFF4D4D4D),
      //                       ),
      //                     ),
      //                     SizedBox(height: 28),
      //                     Container(height: 0.5, color: Color(0xFFcfcfcf)),
      //                     InkWell(
      //                       onTap: () {
      //                         Navigator.pop(context, false);
      //                       },
      //                       child: Container(
      //                         height: 45,
      //                         alignment: Alignment.center,
      //                         child: Text(
      //                           'ลองใหม่อีกครั้ง',
      //                           style: TextStyle(
      //                             fontFamily: 'Sarabun',
      //                             fontSize: 15,
      //                             color: Color(0xFF4D4D4D),
      //                           ),
      //                         ),
      //                       ),
      //                     ),
      //                     Container(height: 0.5, color: Color(0xFFcfcfcf)),
      //                     InkWell(
      //                       onTap: () {
      //                         Navigator.pop(context, false);
      //                         Navigator.pop(context, false);
      //                       },
      //                       child: Container(
      //                         height: 45,
      //                         alignment: Alignment.center,
      //                         child: Text(
      //                           'ยกเลิก',
      //                           style: TextStyle(
      //                             fontFamily: 'Sarabun',
      //                             fontSize: 15,
      //                             color: Color(0xFF9C0000),
      //                           ),
      //                         ),
      //                       ),
      //                     ),
      //                   ],
      //                 ),
      //               ),
      //               // child: //Contents here
      //             ),
      //           ),
      //         );
      //       },
      //     );
      //   }
      // }
    }
  }

  fieldDropdown({
    String title = '',
    String value = '',
    String hintText = '',
    String typeDropdown = '',
    required List<dynamic> itemsData,
    required String selectData,
    required TextInputType textInputType,
    required Function validator,
    required Function onChanged,
    required TextEditingController controller,
    required List<TextInputFormatter> inputFormatters,
  }) {
    return Container(
      color: Colors.white,
      height: typeDropdown == "vehicleType" ? 55 : 35,
      // alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: 10),
      margin: EdgeInsets.only(bottom: 1),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment:
            typeDropdown == "vehicleType"
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.normal,
                  fontFamily: 'Sarabun',
                  fontSize: 13.0,
                ),
              ),
              Text('*', style: TextStyle(color: Colors.red)),
            ],
          ),
          SizedBox(width: 15),
          Expanded(
            child: Container(
              alignment:
                  typeDropdown == "vehicleType"
                      ? Alignment.topRight
                      : Alignment.centerRight,
              child: DropdownButtonFormField(
                items:
                    itemsData.map((item) {
                      return DropdownMenuItem(
                        child: Text(
                          item['title'],
                          style: TextStyle(
                            fontSize: 15.00,
                            fontFamily: 'Kanit',
                            color: Color(0xFF000070),
                          ),
                          overflow: TextOverflow.visible,
                        ),
                        value: item['code'],
                      );
                    }).toList(),
                // value: selectData,
                onChanged: (value) {
                  setState(() {
                    if (typeDropdown == "province")
                      _selectedprovince = value as String;
                    if (typeDropdown == "vehicleType") {
                      _selectedvehicleType = value as String;
                    }
                  });
                },
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(0.0),
                  hintText: 'กรุณาเลือก',
                  hintStyle: TextStyle(fontSize: 11.00, fontFamily: 'Sarabun'),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  isDense: true,
                ),
                isExpanded: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  _read() {
    getprovince();
    getvehicleType();
  }

  Future<dynamic> getprovince() async {
  _itemprovince = [
      {'code': '01', 'title': 'กรุงเทพมหานคร'},
      {'code': '02', 'title': 'สมุทรปราการ'},
      {'code': '03', 'title': 'นครปฐม'},
      {'code': '04', 'title': 'นนทบุรี'},
      {'code': '05', 'title': 'ปทุมธานี'},
      {'code': '06', 'title': 'พระนครศรีอยุธยา'},
      {'code': '07', 'title': 'อ่างทอง'},
      {'code': '08', 'title': 'ลพบุรี'},
      {'code': '09', 'title': 'สิงห์บุรี'},
      {'code': '10', 'title': 'ชัยนาท'},
      {'code': '11', 'title': 'สระบุรี'},
      {'code': '12', 'title': 'ชลบุรี'},
      {'code': '13', 'title': 'ระยอง'},
      {'code': '14', 'title': 'จันทบุรี'},
      {'code': '15', 'title': 'ตราด'},
      {'code': '16', 'title': 'ฉะเชิงเทรา'},
      {'code': '17', 'title': 'ปราจีนบุรี'},
      {'code': '18', 'title': 'นครราชสีมา'},
      {'code': '19', 'title': 'บุรีรัมย์'},
      {'code': '20', 'title': 'สุรินทร์'},
      {'code': '21', 'title': 'ศรีสะเกษ'},
      {'code': '22', 'title': 'อุบลราชธานี'},
      {'code': '23', 'title': 'ยโสธร'},
      {'code': '24', 'title': 'ชัยภูมิ'},
      {'code': '25', 'title': 'ขอนแก่น'},
      {'code': '26', 'title': 'อุดรธานี'},
      {'code': '27', 'title': 'หนองบัวลำภู'},
      {'code': '28', 'title': 'เลย'},
      {'code': '29', 'title': 'นครพนม'},
      {'code': '30', 'title': 'มุกดาหาร'},
      {'code': '31', 'title': 'บึงกาฬ'},
      {'code': '32', 'title': 'สกลนคร'},
      {'code': '33', 'title': 'ร้อยเอ็ด'},
      {'code': '34', 'title': 'กาฬสินธุ์'},
      {'code': '35', 'title': 'นครสวรรค์'},
      {'code': '36', 'title': 'อุทัยธานี'},
      {'code': '37', 'title': 'สุโขทัย'},
      {'code': '38', 'title': 'พิษณุโลก'},
      {'code': '39', 'title': 'พิจิตร'},
      {'code': '40', 'title': 'ตาก'},
      {'code': '41', 'title': 'กำแพงเพชร'},
      {'code': '42', 'title': 'เชียงใหม่'},
      {'code': '43', 'title': 'ลำพูน'},
      {'code': '44', 'title': 'ลำปาง'},
      {'code': '45', 'title': 'แพร่'},
      {'code': '46', 'title': 'น่าน'},
      {'code': '47', 'title': 'พะเยา'},
      {'code': '48', 'title': 'เชียงราย'},
      {'code': '49', 'title': 'แม่ฮ่องสอน'},
      {'code': '50', 'title': 'นครนายก'},
      {'code': '51', 'title': 'สระแก้ว'},
      {'code': '52', 'title': 'จันทบุรี'},
      {'code': '53', 'title': 'ตราด'},
      {'code': '54', 'title': 'สตูล'},
      {'code': '55', 'title': 'สงขลา'},
      {'code': '56', 'title': 'พัทลุง'},
      {'code': '57', 'title': 'ปัตตานี'},
      {'code': '58', 'title': 'ยะลา'},
      {'code': '59', 'title': 'นราธิวาส'},
      {'code': '60', 'title': 'ภูเก็ต'},
      {'code': '61', 'title': 'กระบี่'},
      {'code': '62', 'title': 'ตรัง'},
      {'code': '63', 'title': 'พังงา'},
      {'code': '64', 'title': 'สุราษฎร์ธานี'},
      {'code': '65', 'title': 'ชุมพร'},
      {'code': '66', 'title': 'ระนอง'},
      {'code': '67', 'title': 'สมุทรสงคราม'},
      {'code': '68', 'title': 'สมุทรสาคร'},
      {'code': '69', 'title': 'เพชรบุรี'},
      {'code': '70', 'title': 'ประจวบคีรีขันธ์'},
      {'code': '71', 'title': 'นครศรีธรรมราช'},
      {'code': '72', 'title': 'พัทลุง'},
      {'code': '73', 'title': 'สุราษฎร์ธานี'},
      {'code': '74', 'title': 'จันทบุรี'},
      {'code': '75', 'title': 'นครพนม'},
      {'code': '76', 'title': 'เชียงราย'},
      {'code': '77', 'title': 'ชลบุรี'},
    ];
    // final result = await postObjectDataMW(
    //   "http://122.155.223.63/td-khub-dee-middleware-api/province/read",
    //   {},
    // );
    // if (result['status'] == 'S') {
    //   setState(() {
    //     _itemprovince = result['objectData'];
    //   });
    // }
  }

  Future<dynamic> getvehicleType() async {
      _itemvehicleType = [
     {'code': '01', 'title': 'รถจดทะเบียนนั่งส่วนบุคคลไม่เกิน 7 คน'},
      {'code': '02', 'title': 'รถจดทะเบียนนั่งส่วนบุคคลเกิน 7 คน'},
      {'code': '03', 'title': 'รถบรรทุกส่วนบุคคล'},
      {'code': '04', 'title': 'รถรับจ้างระหว่างจังหวัด'},
      {'code': '05', 'title': 'รถรับจ้างบรรทุกคนโดยสารไม่เกิน 7 คน'},
      {'code': '06', 'title': 'รถสี่ล้อเล็กรับจ้าง'},
      {'code': '07', 'title': 'รถรับจ้างสามล้อ'},
      {'code': '08', 'title': 'รถบริการทัศนาจร'},
      {'code': '09', 'title': 'รถบริการให้เช่า'},
      {'code': '10', 'title': 'รถจักรยานยนต์'},
      {'code': '11', 'title': 'รถแทรกเตอร์'},
    ];
    
    // final result = await postObjectDataMW(
    //     "http://122.155.223.63/td-khub-dee-middleware-api/vehicleType/read",
    //     {});
    // if (result['status'] == 'S') {
    //   setState(() {
    //     _itemvehicleType = result['objectData'];
    //   });
    // }
  }
}
