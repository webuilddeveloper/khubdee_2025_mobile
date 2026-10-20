import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:KhubDeeDLT/pages/notification/notification_list.dart';

void main() {
  testWidgets('notification tab builds before stored login is available', (
    tester,
  ) async {
    FlutterSecureStorage.setMockInitialValues({});
    await tester.pumpWidget(
      MaterialApp(home: NotificationList(title: 'แจ้งเตือน')),
    );
    expect(tester.takeException(), isNull);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('ไม่พบข้อมูล'), findsOneWidget);
  });
}
