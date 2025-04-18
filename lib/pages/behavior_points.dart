import 'package:KhubDeeDLT/pages/score_criteria.dart';
import 'package:flutter/material.dart';
import 'package:KhubDeeDLT/component/header.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class BehaviorPoints extends StatefulWidget {
  @override
  _BehaviorPointsPageState createState() => _BehaviorPointsPageState();
}

class _BehaviorPointsPageState extends State<BehaviorPoints> {
  late Future<dynamic> futureModel;
  dynamic tempData;

  final int _limit = 2;

  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();

    _onLoading();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(
        context,
        () {
          Navigator.pop(context);
        },
        title: 'ตรวจสอบแต้มความประพฤติการขับขี่',
        isButtonRight: true,
        imageRightButton: 'assets/images/icon_info.png',
        rightButton: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ScoreCriteria(),
            ),
          );
        },
      ),
      backgroundColor: const Color(0xFFF5F8FB),
      body: InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: _screen(tempData),
        // child: _futureBuilder(),
      ),
    );
  }

  _futureBuilder() {
    return FutureBuilder<dynamic>(
      future: futureModel, // function where you call your api
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          return _screen(snapshot.data);
        } else if (snapshot.hasError) {
          return Container();
        } else {
          return Container();
        }
      },
    );
  }

  _screen(dynamic model) {
    var totalPoint = '80';
    return Column(
      children: [
        Container(
          color: Colors.white,
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 15),
          margin: const EdgeInsets.only(bottom: 1),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Text(
                    'แต้มคงเหลือ',
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontFamily: 'Sarabun',
                      fontSize: 14.0,
                      color: Color(0xFF545454),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Container(
                  alignment: Alignment.centerRight,
                  child: Text(
                    totalPoint,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Sarabun',
                      fontSize: 30.0,
                      color: Color(0xFFEBC22B),
                    ),
                  ),
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
    var toDate = DateFormat("dd-MM-yyyy").format(DateTime.now());
    return Container(
      // height: 310,
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
          const Text(
            'วันที่กระทำความผิด',
            style: TextStyle(
              fontFamily: 'Sarabun',
              fontSize: 13,
              color: Color(0xFF9E9E9E),
            ),
          ),
          Text(
            '$toDate',
            style: const TextStyle(
              fontFamily: 'Sarabun',
              fontSize: 13,
            ),
          ),
          _line(),
          _textRow(
            title: 'สถานที่เกิดเหตุ',
            value: 'อำเภอเมือง จังหวัดเชียงใหม่',
          ),
          const SizedBox(height: 8),
          _textRow(
            title: 'เลขที่ใบสั่ง',
            value: 'xxxxxxxxxxxxxxx',
          ),
          const SizedBox(height: 8),
          _textRow(
            title: 'หน่วยงานที่ออกใบสั่ง',
            value: 'สถานีตำรวจ ภาค 5',
          ),
          const SizedBox(height: 8),
          _line(),
          const Text(
            'ข้อหา',
            style: TextStyle(
              fontFamily: 'Sarabun',
              fontSize: 13,
              color: Color(0xFF9E9E9E),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'ขับรถไม่สุภาพ ขับปาดหน้า ขับรถเร็ว ไม่ปฏิบัติตามกฏจราจร',
            style: TextStyle(
              fontFamily: 'Sarabun',
              fontSize: 13,
            ),
          ),
          _line(),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'คะแนนที่ถูกหัก',
                style: TextStyle(
                  fontFamily: 'Sarabun',
                  fontSize: 13,
                  color: Color(0xFF9E9E9E),
                ),
              ),
              Text(
                '-10 คะแนน',
                style: TextStyle(
                  fontFamily: 'Sarabun',
                  fontSize: 20,
                  color: Color(0xFFFF7B06),
                ),
              ),
            ],
          )
        ],
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

  _textRow({String title = '', String value = ''}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Sarabun',
            fontSize: 13,
            color: Color(0xFF9E9E9E),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Sarabun',
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  // function
  _read() async {
    // mock data
    setState(() {
      tempData = [];
      for (var i = 0; i < _limit; i++) {
        setState(() {
          tempData.add({'title': i.toString()});
        });
      }
    });
  }

  _onLoading() async {
    // setState(() {
    //   _limit = _limit + 2;
    // });
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
