# ข่าวจากเว็บไซต์กรมการขนส่งทางบก

หน้า Home คงรูปแบบเดิมโดยไม่มีรายการข่าว เมนูข่าวเปิดหน้า Flutter ที่มี 2 หมวด:

| หมวด | หน้าเว็บไซต์ | RSS ทางการ |
| --- | --- | --- |
| ข่าวประชาสัมพันธ์ | https://www.dlt.go.th/th/public-news | https://www.dlt.go.th/rss/1/th/172/public-news.xml |
| กรมการขนส่งทางบก | https://www.dlt.go.th/th/dlt-photo | https://www.dlt.go.th/rss/1/th/173/dlt-photo.xml |

ใช้ `DltNewsService` ดึง RSS ผ่าน HTTPS โดยตรง ไม่เรียก `newsApi`, `newsCategoryApi`, gallery หรือ comment ของระบบเดิมในหน้าข่าวใหม่นี้ ลิงก์ข่าวเก่าในประวัติการแจ้งเตือนยังใช้หน้ารายละเอียดเดิม เพื่อรองรับ reference เดิม

RSS ให้ข่าวล่าสุด 20 รายการต่อหมวด โดยไม่มีรูปหรือเนื้อหาเต็ม จึงใช้ `DltNewsPageLoader` เปิดหน้า DLT แบบ headless ให้ JavaScript ของเว็บไซต์ทำงาน แล้วอ่านเฉพาะ DOM ของรายการข่าว/บทความ ไม่ดึง credential ของเว็บไซต์มาใส่ในแอป

จับคู่รูปปกกับ URL ของข่าว หากข่าวใน RSS ไม่มีรูปปกในหน้ารวม จะใช้รูปแกลเลอรีจริงของข่าวนั้น การ์ดคงแถบหมวดสีม่วง รูปสูง 200 และหัวข้อ 2 บรรทัด ส่วน header, CategorySelector และ KeySearch ใช้รูปแบบเดิม

เมื่อแตะข่าว จะเปิด `DltNewsDetailPage` ซึ่งเป็นหน้า Flutter: รูปใหญ่สูง 360, รูปย่อย, กดขยาย/เลื่อนดูรูป, หัวข้อ, วันที่และจำนวนเข้าชมจาก DLT, ปุ่มแชร์ลิงก์ต้นฉบับ และเนื้อหาเต็มผ่าน flutter_html ลบ controls และ inline styles ของเว็บไซต์ก่อนแสดงด้วยฟอนต์ Sarabun แบบเดิม ไม่เรียก API ข่าว/แกลเลอรี/คอมเมนต์เดิม

รายการแสดงครั้งละ 5 ข่าว พร้อมปุ่ม “โหลดข่าวเพิ่มเติม” แสดงหัวข้อจาก RSS ทันทีโดยไม่รอรูป โหลดรูปเฉพาะชุดที่แสดงและเก็บผลไว้ระหว่างใช้งานหน้าข่าว การค้นหาครอบคลุมข่าวใน RSS ทั้งหมด (ล่าสุด 20 ข่าวต่อหมวด) ไม่ได้ดึงข่าวย้อนหลังนอก RSS

ไม่มีปุ่มเปิดเว็บไซต์หรือหน้าข่าว WebView และลิงก์ในเนื้อหาไม่เปิด browser ผู้ใช้ดูรายละเอียดและรูปใน Flutter เท่านั้น โดยยังใช้ headless WebView ภายในเพื่ออ่านข้อมูลหน้า DLT ที่ render ด้วย JavaScript

รองรับ loading, error/retry, pull-to-refresh และภาพโหลดไม่สำเร็จ มี timeout และปิด headless WebView หลังอ่านเสร็จทุกครั้ง จำกัดหนึ่งตัวพร้อมกัน รวม request ซ้ำ และ cache เนื้อหาบทความ 5 นาที (สูงสุด 30 ข่าว) หาก DLT เปลี่ยนโครงสร้าง ให้ปรับ selector ใน `dlt_news_page_loader.dart` และ parser ใน `dlt_news_service.dart`

## ตรวจสอบ

```sh
flutter pub get
flutter test
flutter run -d "iPhone 18 Pro"
```

หากเครื่องนี้เกิด `Failed to start Dart Development Service` ให้ใช้ `flutter run --no-dds -d "iPhone 18 Pro"` ซึ่งยังรองรับ hot reload ผ่าน Flutter CLI

ทดสอบ parser ด้วยตัวอย่าง RSS จริง, UTF-8, ลิงก์ซ้ำ/ผิดหมวด, server error, การสลับหมวด, ค้นหา และ retry โดยไม่พึ่งอินเทอร์เน็ตใน unit/widget tests

## iOS

Flutter 3.35.3 ใช้ explicit FlutterEngine ใน AppDelegate พร้อม SceneDelegate ที่ลงทะเบียนใน Info.plist สำหรับ SDK ที่บังคับ UIScene โดยยังส่ง URL callbacks ไปยัง FlutterAppDelegate ให้ plugin เดิมใช้งาน
