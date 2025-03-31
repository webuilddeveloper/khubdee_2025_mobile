import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../shared/api_provider.dart';
import '../shared/extension.dart';
import 'package:KhubDeeDLT/component/header.dart';
import 'traffic_ticket_detail.dart';

class TrafficTicketTMP extends StatefulWidget {
  @override
  _TrafficTicketTMPPageState createState() => _TrafficTicketTMPPageState();
}

class _TrafficTicketTMPPageState extends State<TrafficTicketTMP> {
  Future<dynamic>? futureModel;
  dynamic tempData;
  var categoryList = dynamic;

  int _limit = 10;
  int selectedCategory = 0;

  // ignore: prefer_final_fields
  RefreshController _refreshController = RefreshController(
    initialRefresh: false,
  );

  @override
  void initState() {
    super.initState();

    _read();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, () {
        Navigator.pop(context);
      }, title: 'ใบสั่งค้างชำระ (PTM)'),
      backgroundColor: const Color(0xFFF5F8FB),
      body: InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        // child: _screen(tempData),
        child: _futureBuilder(),
      ),
    );
  }

  _futureBuilder() {
    return FutureBuilder<dynamic>(
      future: futureModel, // function where you call your api
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          return _screen(snapshot.data, snapshot.data.length);
        } else if (snapshot.hasError) {
          return Container();
        } else {
          return Container();
        }
      },
    );
  }

  _screen(dynamic model, int totalData) {
    return Column(
      children: [
        Container(
          color: const Color(0xFFEDF0F3),
          padding: const EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'ทั้งหมด',
                style: TextStyle(fontFamily: 'Sarabun', fontSize: 15),
              ),
              Text(
                totalData.toString() + ' รายการ',
                style: const TextStyle(
                  fontFamily: 'Sarabun',
                  fontSize: 15,
                  color: Color(0xFFB1B1B1),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: SmartRefresher(
            enablePullDown: false,
            enablePullUp: true,
            footer: const ClassicFooter(
              loadingText: ' ',
              canLoadingText: ' ',
              idleText: ' ',
              idleIcon: Icon(Icons.arrow_upward, color: Colors.transparent),
            ),
            controller: _refreshController,
            onLoading: _onLoading,
            onRefresh: _onRefresh,
            child: ListView.builder(
              physics: const ScrollPhysics(),
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              itemCount: model.length,
              itemBuilder: (context, index) {
                return _item(model[index]);
              },
            ),
          ),
        ),
      ],
    );
  }

  _item(dynamic model) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => TrafficTicketDetail(
                  cardID: model['card_ID'],
                  ticketID: model['ticket_ID'],
                ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.4),
              spreadRadius: 0,
              blurRadius: 4,
              offset: const Offset(1, 3), // changes position of shadow
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'วันที่กระทำความผิด',
                      style: TextStyle(
                        fontFamily: 'Sarabun',
                        fontSize: 13,
                        color: Color(0xFF9E9E9E),
                      ),
                    ),
                    Text(
                      dateStringToDate(model['occur_DT']),
                      style: const TextStyle(
                        fontFamily: 'Sarabun',
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            _line(),
            _textRowExpanded(
              title: 'สถานที่เกิดเหตุ',
              value: model['place'],
              titleColor: const Color(0xFF9E9E9E),
              spaceBetween: 60,
            ),
            _textRowExpanded(
              title: 'เลขที่ใบสั่ง',
              value: model['org_CODE'],
              titleColor: const Color(0xFF9E9E9E),
              spaceBetween: 60,
            ),
            _textRowExpanded(
              title: 'หน่วยงานที่ออกใบสั่ง',
              value: model['org_ABBR'],
              titleColor: const Color(0xFF9E9E9E),
              spaceBetween: 60,
            ),
            _line(),
            _textRowExpanded(
              title: 'ข้อหา',
              value: 'ค่าปรับ(บาท)',
              titleColor: const Color(0xFF9E9E9E),
              valueColor: const Color(0xFF9E9E9E),
            ),
            if (model['accuse1_CODE'] != null)
              _textRowExpanded(
                title: model['accuse1_CODE'],
                value: model['fine1'],
                valueColor: const Color(0xFFFF7B06),
                expandedRight: false,
                spaceBetween: 60,
              ),
            if (model['accuse2_CODE'] != null)
              _textRowExpanded(
                title: model['accuse2_CODE'],
                value: model['fine2'],
                valueColor: const Color(0xFFFF7B06),
                expandedRight: false,
                spaceBetween: 60,
              ),
            if (model['accuse3_CODE'] != null)
              _textRowExpanded(
                title: model['accuse3_CODE'],
                value: model['fine3'],
                valueColor: const Color(0xFFFF7B06),
                expandedRight: false,
                spaceBetween: 60,
              ),
            if (model['accuse4_CODE'] != null)
              _textRowExpanded(
                title: model['accuse4_CODE'],
                value: model['fine4'],
                valueColor: const Color(0xFFFF7B06),
                expandedRight: false,
                spaceBetween: 60,
              ),
            if (model['accuse5_CODE'] != null)
              _textRowExpanded(
                title: model['accuse5_CODE'],
                value: model['fine5'],
                valueColor: const Color(0xFFFF7B06),
                expandedRight: false,
                spaceBetween: 60,
              ),
            _line(),
            _textRowExpanded(
              title: 'ค่าปรับทั้งหมด',
              value: model['fine_AMT'],
              valueColor: const Color(0xFFFF7B06),
              valueSize: 20,
            ),
          ],
        ),
      ),
    );
  }

  _line() {
    return Container(
      height: 2,
      margin: const EdgeInsets.symmetric(vertical: 10),
      color: const Color(0xFFEDF0F3),
    );
  }

  _textRowExpanded({
    String title = '',
    String value = '',
    Color titleColor = Colors.black,
    Color valueColor = Colors.black,
    double valueSize = 13,
    bool expandedRight = true,
    double spaceBetween = 15,
  }) {
    return title != ''
        ? Container(
          margin: const EdgeInsets.only(bottom: 8),
          child:
              expandedRight
                  ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontFamily: 'Sarabun',
                          fontSize: 13,
                          color: titleColor,
                        ),
                      ),
                      SizedBox(width: spaceBetween),
                      Expanded(
                        child: Text(
                          value,
                          style: TextStyle(
                            fontFamily: 'Sarabun',
                            fontSize: valueSize,
                            color: valueColor,
                          ),
                          textAlign: TextAlign.right,
                          maxLines: 2,
                        ),
                      ),
                    ],
                  )
                  : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontFamily: 'Sarabun',
                            fontSize: 13,
                            color: titleColor,
                          ),
                          maxLines: 2,
                        ),
                      ),
                      SizedBox(width: spaceBetween),
                      Text(
                        value,
                        style: TextStyle(
                          fontFamily: 'Sarabun',
                          fontSize: valueSize,
                          color: valueColor,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ],
                  ),
        )
        : Container();
  }

  // function
  _read() async {
    // getNotpaidTicketListApi
    // futureModel = postDio(getNotpaidTicketListApi, {
    //   "createBy": "createBy",
    //   "updateBy": "updateBy",
    //   "card_id": "",
    //   "plate1": "3กท",
    //   "plate2": "9771",
    //   "plate3": "00100",
    //   "ticket_id": ""
    // });
    futureModel = Future.value(
      [
            {
              'card_ID': '123456',
              'ticket_ID': 'TICKET001',
              'occur_DT': '20250301',
              'ticket_STATUS': '1',
              'place': 'บางแค',
              'org_CODE': 'ORG123',
              'org_ABBR': 'POLICE',
              'accuse1_CODE': 'Violation Code 1',
              'fine1': "500",
              'accuse2_CODE': 'Violation Code 2',
              'fine2': "1000",
              'accuse3_CODE': null,
              'fine3': null,
              'accuse4_CODE': null,
              'fine4': null,
              'accuse5_CODE': null,
              'fine5': null,
              'fine_AMT': "1500",
            },
            {
              'card_ID': '654321',
              'ticket_ID': 'TICKET002',
              'occur_DT': '20250305',
              'ticket_STATUS': '2',
              'place': 'ลาดพร้าว',
              'org_CODE': 'ORG124',
              'org_ABBR': 'TRAFFIC',
              'accuse1_CODE': 'Violation Code 3',
              'fine1': "200",
              'accuse2_CODE': null,
              'fine2': null,
              'accuse3_CODE': null,
              'fine3': null,
              'accuse4_CODE': null,
              'fine4': null,
              'accuse5_CODE': null,
              'fine5': null,
              'fine_AMT': "200",
            },
            {
              'card_ID': '789012',
              'ticket_ID': 'TICKET003',
              'occur_DT': '20250307',
              'ticket_STATUS': '3',
              'place': 'พระราม 9',
              'org_CODE': 'ORG125',
              'org_ABBR': 'POLICE',
              'accuse1_CODE': 'Violation Code 4',
              'fine1': "700",
              'accuse2_CODE': 'Violation Code 5',
              'fine2': "1300",
              'accuse3_CODE': null,
              'fine3': null,
              'accuse4_CODE': null,
              'fine4': null,
              'accuse5_CODE': null,
              'fine5': null,
              'fine_AMT': "2000",
            },
            {
              'card_ID': '987654',
              'ticket_ID': 'TICKET004',
              'occur_DT': '20250310',
              'ticket_STATUS': '3',
              'place': 'เยาวราช',
              'org_CODE': 'ORG126',
              'org_ABBR': 'TRAFFIC',
              'accuse1_CODE': 'Violation Code 6',
              'fine1': "1000",
              'accuse2_CODE': null,
              'fine2': null,
              'accuse3_CODE': null,
              'fine3': null,
              'accuse4_CODE': null,
              'fine4': null,
              'accuse5_CODE': null,
              'fine5': null,
              'fine_AMT': "1000",
            },
          ]
          .where(
            (a) =>
                selectedCategory == 0
                    ? a['ticket_STATUS'] != selectedCategory.toString()
                    : a['ticket_STATUS'] == selectedCategory.toString(),
          )
          .toList(),
    );
  }

  _onLoading() async {
    setState(() {
      _limit = _limit + 10;
    });
    _read();

    await Future.delayed(const Duration(milliseconds: 2000));

    _refreshController.loadComplete();
  }

  void _onRefresh() async {
    // getCurrentUserData();
    // _getLocation();
    _read();

    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
    // _refreshController.loadComplete();
  }
}
