import 'package:KhubDeeDLT/pages/blank_page/blank_loading.dart';
import 'package:KhubDeeDLT/pages/traffic_ticket_detail.dart';
import 'package:KhubDeeDLT/shared/api_provider.dart';
import 'package:KhubDeeDLT/shared/extension.dart';
import 'package:flutter/material.dart';
import 'package:KhubDeeDLT/component/header.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class TrafficTicket extends StatefulWidget {
  @override
  _TrafficTicketPageState createState() => _TrafficTicketPageState();
}

class _TrafficTicketPageState extends State<TrafficTicket> {
  final storage = new FlutterSecureStorage();
  late Future<dynamic> futureModel = Future.value([]);
  dynamic tempData = [];
  dynamic categoryList;
  String url = getAllTicketListApi;

  int _limit = 10;
  int selectedCategory = 0;

  late RefreshController _refreshController;

  @override
  void initState() {
    _refreshController = RefreshController(initialRefresh: false);
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
      }, title: 'ใบสั่ง'),
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
    return Column(
      children: [_buildCategoryTabs(), Expanded(child: _futureBuilder())],
    );
  }

  _futureBuilder() {
    return FutureBuilder<dynamic>(
      future: futureModel, // function where you call your api
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.isNotEmpty) {
            return _listitem(snapshot.data, snapshot.data.length);
          } else {
            return Container(
              alignment: Alignment.center,
              child: const Text(
                'ไม่พบข้อมูล',
                style: TextStyle(fontFamily: 'Sarabun', fontSize: 15),
              ),
            );
          }
        } else if (snapshot.hasError) {
          return Container(
            alignment: Alignment.center,
            child: const Text(
              'เกิดข้อผิดพลาด กรุณากดลองใหม่อีกครั้ง',
              style: TextStyle(fontFamily: 'Sarabun', fontSize: 15),
            ),
          );
        } else {
          return _loading();
        }
      },
    );
  }

  _listitem(dynamic model, int totalData) {
    return Column(
      children: [
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
              padding: const EdgeInsets.only(top: 8),
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

  _loading() {
    return ListView.builder(
      physics: const ScrollPhysics(),
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      itemCount: 10,
      itemBuilder: (context, index) {
        return Container(
          width: double.infinity,
          height: 300,
          margin: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
          child: BlankLoading(),
        );
      },
    );
  }

  Widget _buildCategoryTabs() {
    return Container(
      height: 45.0,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE0E0E0))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _itemCategory('ทั้งหมด', 0),
          _itemCategory('ค้างชำระ', 1),
          _itemCategory('ชำระแล้ว', 2),
          _itemCategory('เกินกำหนด', 3),
        ],
      ),
    );
  }

  _itemCategory(String title, int index) {
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            if (index == 1) {
              url = getNotpaidTicketListApi;
            } else if (index == 2) {
              url = getPaidTicketListApi;
            } else if (index == 3) {
              url = getTimeoutTicketListApi;
            } else {
              url = getAllTicketListApi;
            }
            selectedCategory = index;
            _limit = 0;
          });
          _onRefresh();
        },
        child: Container(
          decoration: BoxDecoration(
            border:
                index == selectedCategory
                    ? Border(
                      bottom: BorderSide(
                        width: 2,
                        color: Theme.of(context).primaryColor,
                      ),
                    )
                    : null,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 10.0),
          child: Text(
            title,
            style: TextStyle(
              color: index == selectedCategory ? Colors.black : Colors.grey,
              fontSize: index == selectedCategory ? 14.0 : 13.0,
              fontWeight: FontWeight.normal,
              // letterSpacing: 1,
              fontFamily: 'Sarabun',
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  _item(dynamic model) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TrafficTicketDetail(model: model),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'เลขที่ใบสั่ง: ${model['ticket_ID']}',
                        style: const TextStyle(
                          fontFamily: 'Sarabun',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'วันที่: ${dateStringToDate(model['occur_DT'])}',
                        style: const TextStyle(
                          fontFamily: 'Sarabun',
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                  if (model['ticket_STATUS'] != null)
                    statusBox(model['ticket_STATUS']),
                ],
              ),
              const Divider(height: 24),
              _textRow(
                icon: Icons.location_on_outlined,
                title: 'สถานที่:',
                value: model['place'],
              ),
              const SizedBox(height: 8),
              _textRow(
                icon: Icons.account_balance_outlined,
                title: 'หน่วยงาน:',
                value: model['org_ABBR'],
              ),
              const Divider(height: 24),
              _buildOffenseList(model),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'ค่าปรับทั้งหมด',
                    style: TextStyle(
                      fontFamily: 'Sarabun',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${model['fine_AMT']} บาท',
                    style: const TextStyle(
                      fontFamily: 'Sarabun',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF7B06),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOffenseList(dynamic model) {
    final offenses = [];
    for (int i = 1; i <= 5; i++) {
      if (model['accuse${i}_CODE'] != null && model['fine$i'] != null) {
        offenses.add({
          'title': model['accuse${i}_CODE'],
          'fine': model['fine$i'],
        });
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'รายการข้อหา',
          style: TextStyle(
            fontFamily: 'Sarabun',
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        ...offenses.map((offense) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    '• ${offense['title']}',
                    style: const TextStyle(fontFamily: 'Sarabun', fontSize: 14),
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  '${offense['fine']} บาท',
                  style: const TextStyle(
                    fontFamily: 'Sarabun',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _textRow({
    required IconData icon,
    String title = '',
    String value = '',
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Sarabun',
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontFamily: 'Sarabun',
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  _line() {
    return Container(
      height: 2,
      margin: EdgeInsets.symmetric(vertical: 10),
      color: Color(0xFFEDF0F3),
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
          margin: EdgeInsets.only(bottom: 8),
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

  statusBox(String value) {
    var status = '';
    List<Color> colors = [const Color(0xFF07C9A8), const Color(0xFF03996F)];
    if (value == '1') {
      status = 'ค้างชำระ';
      colors = [const Color(0xFFFF2525), const Color(0xFFBC0611)];
    } else if (value == '2') {
      status = 'เกินกำหนดแล้วยังไม่ชำระ';
      colors = [const Color(0xFFFFC200), const Color(0xFFFF7B06)];
    } else if (value == '3') {
      status = 'ชำระแล้ว';
    }
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 7),
      height: 30,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(
        status,
        style: const TextStyle(
          fontFamily: 'Sarabun',
          fontSize: 11,
          color: Colors.white,
        ),
        // textAlign: TextAlign.center,
      ),
    );
  }

  // function
  _read() async {
    // futureModel = postDio(url, {
    //   "createBy": "createBy",
    //   "updateBy": "updateBy",
    //   "card_id": "",
    //   "plate1": "3กร",
    //   "plate2": "4853",
    //   "plate3": "00100",
    //   "ticket_id": "",
    // });
    futureModel = Future.value(
      [
            {
              'card_ID': '123456',
              'ticket_ID': 'TICKET001',
              'occur_DT': '25680901',
              'ticket_STATUS': '1',
              'place': 'บางแค',
              'org_CODE': '640872',
              'org_ABBR': 'POLICE',
              'accuse1_CODE': 'ฝ่าสัญญาณไฟจราจร',
              'fine1': "500",
              'accuse2_CODE': 'ขับรถเร็วเกินกำหนด',
              'fine2': "1,000",
              'accuse3_CODE': null,
              'fine3': null,
              'accuse4_CODE': null,
              'fine4': null,
              'accuse5_CODE': null,
              'fine5': null,
              'fine_AMT': "1,500",
              'pic1':
                  'https://scontent.fbkk7-3.fna.fbcdn.net/v/t39.30808-6/497515571_10213427606081207_3266310505784917595_n.jpg?stp=dst-jpg_s1080x2048_tt6&_nc_cat=100&ccb=1-7&_nc_sid=aa7b47&_nc_eui2=AeFjZ32F13s2aVkBR4ihQTJA05mih8pGRGLTmaKHykZEYryFE9AGfuGMyW7aRdLYXGlAb_CEpP2N-LlxoJhfWkkB&_nc_ohc=8mHnMN6VTEgQ7kNvwFQdY33&_nc_oc=Adk0aXMECFN1JQ8jCUvkk9JL86eQrK3opITIngB7wuxphVXmnY7W_i0dTSLo_Z31jVM&_nc_zt=23&_nc_ht=scontent.fbkk7-3.fna&_nc_gid=TrChZUOkrHSlIZa720W2Vw&oh=00_AfgEm4jDqBb_Y5gLHoTlWpznoKjyNnWig1Zq1n-0vxEMRA&oe=69333DBF',
              'pic2':
                  'https://f.ptcdn.info/489/058/000/pbh3dw6p5VNKy6ucM9e-o.jpg',
                  'code': 'QR001',
            },
            {
              'card_ID': '654321',
              'ticket_ID': 'TICKET002',
              'occur_DT': '25680705',
              'ticket_STATUS': '2',
              'place': 'ลาดพร้าว',
              'org_CODE': '853490',
              'org_ABBR': 'TRAFFIC',
              'accuse1_CODE': 'ขับรถผ่านทางม้าลายโดยไม่หยุดให้คนข้าม',
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
              'pic1':
                  'https://scontent.fbkk7-3.fna.fbcdn.net/v/t39.30808-6/497515571_10213427606081207_3266310505784917595_n.jpg?stp=dst-jpg_s1080x2048_tt6&_nc_cat=100&ccb=1-7&_nc_sid=aa7b47&_nc_eui2=AeFjZ32F13s2aVkBR4ihQTJA05mih8pGRGLTmaKHykZEYryFE9AGfuGMyW7aRdLYXGlAb_CEpP2N-LlxoJhfWkkB&_nc_ohc=8mHnMN6VTEgQ7kNvwFQdY33&_nc_oc=Adk0aXMECFN1JQ8jCUvkk9JL86eQrK3opITIngB7wuxphVXmnY7W_i0dTSLo_Z31jVM&_nc_zt=23&_nc_ht=scontent.fbkk7-3.fna&_nc_gid=TrChZUOkrHSlIZa720W2Vw&oh=00_AfgEm4jDqBb_Y5gLHoTlWpznoKjyNnWig1Zq1n-0vxEMRA&oe=69333DBF',
              'pic2':
                  'https://f.ptcdn.info/489/058/000/pbh3dw6p5VNKy6ucM9e-o.jpg',
              'code': 'QR002',
            },
            {
              'card_ID': '789012',
              'ticket_ID': 'TICKET003',
              'occur_DT': '25680607',
              'ticket_STATUS': '3',
              'place': 'พระราม 9',
              'org_CODE': '967321',
              'org_ABBR': 'POLICE',
              'accuse1_CODE': 'ขับรถย้อนศร',
              'fine1': "700",
              'accuse2_CODE': 'กลับรถที่ทางร่วมทางแยก',
              'fine2': "1,300",
              'accuse3_CODE': null,
              'fine3': null,
              'accuse4_CODE': null,
              'fine4': null,
              'accuse5_CODE': null,
              'fine5': null,
              'fine_AMT': "2,000",
              'pic1':
                  'https://scontent.fbkk7-3.fna.fbcdn.net/v/t39.30808-6/497515571_10213427606081207_3266310505784917595_n.jpg?stp=dst-jpg_s1080x2048_tt6&_nc_cat=100&ccb=1-7&_nc_sid=aa7b47&_nc_eui2=AeFjZ32F13s2aVkBR4ihQTJA05mih8pGRGLTmaKHykZEYryFE9AGfuGMyW7aRdLYXGlAb_CEpP2N-LlxoJhfWkkB&_nc_ohc=8mHnMN6VTEgQ7kNvwFQdY33&_nc_oc=Adk0aXMECFN1JQ8jCUvkk9JL86eQrK3opITIngB7wuxphVXmnY7W_i0dTSLo_Z31jVM&_nc_zt=23&_nc_ht=scontent.fbkk7-3.fna&_nc_gid=TrChZUOkrHSlIZa720W2Vw&oh=00_AfgEm4jDqBb_Y5gLHoTlWpznoKjyNnWig1Zq1n-0vxEMRA&oe=69333DBF',
              'pic2':
                  'https://f.ptcdn.info/489/058/000/pbh3dw6p5VNKy6ucM9e-o.jpg',
              'code': 'QR003',
            },
            {
              'card_ID': '987654',
              'ticket_ID': 'TICKET004',
              'occur_DT': '25680310',
              'ticket_STATUS': '3',
              'place': 'เยาวราช',
              'org_CODE': '488210',
              'org_ABBR': 'TRAFFIC',
              'accuse1_CODE': 'แข่งรถบนถนนทางสาธารณะ',
              'fine1': "1,000",
              'accuse2_CODE': null,
              'fine2': null,
              'accuse3_CODE': null,
              'fine3': null,
              'accuse4_CODE': null,
              'fine4': null,
              'accuse5_CODE': null,
              'fine5': null,
              'fine_AMT': "1,000",
              'pic1':
                  'https://scontent.fbkk7-3.fna.fbcdn.net/v/t39.30808-6/497515571_10213427606081207_3266310505784917595_n.jpg?stp=dst-jpg_s1080x2048_tt6&_nc_cat=100&ccb=1-7&_nc_sid=aa7b47&_nc_eui2=AeFjZ32F13s2aVkBR4ihQTJA05mih8pGRGLTmaKHykZEYryFE9AGfuGMyW7aRdLYXGlAb_CEpP2N-LlxoJhfWkkB&_nc_ohc=8mHnMN6VTEgQ7kNvwFQdY33&_nc_oc=Adk0aXMECFN1JQ8jCUvkk9JL86eQrK3opITIngB7wuxphVXmnY7W_i0dTSLo_Z31jVM&_nc_zt=23&_nc_ht=scontent.fbkk7-3.fna&_nc_gid=TrChZUOkrHSlIZa720W2Vw&oh=00_AfgEm4jDqBb_Y5gLHoTlWpznoKjyNnWig1Zq1n-0vxEMRA&oe=69333DBF',
              'pic2':
                  'https://f.ptcdn.info/489/058/000/pbh3dw6p5VNKy6ucM9e-o.jpg',
              'code': 'QR004',
            },
          ]
          .where(
            (a) =>
                selectedCategory == 0 ||
                a['ticket_STATUS'] == selectedCategory.toString(),
          )
          .toList(),
    );
  }

  _onLoading() async {
    setState(() {
      _limit = _limit + 10;
    });
    _read();

    await Future.delayed(const Duration(milliseconds: 1000));

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
