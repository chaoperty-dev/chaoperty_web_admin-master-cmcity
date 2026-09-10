////////------------------------->
class PersonFieldModel {
  final String ser;
  final String title;
  String detail;

  PersonFieldModel({
    required this.ser,
    required this.title,
    this.detail = '',
  });
}

////////------------------------->
class ShopSubField {
  final String ser;
  final String titlesub;
  String detail;

  ShopSubField({required this.ser, required this.titlesub, this.detail = ''});
}

class ShopFieldModel {
  final String ser;
  final String title;
  String detail;
  List<ShopSubField> detailsub;

  ShopFieldModel({
    required this.ser,
    required this.title,
    this.detail = '',
    this.detailsub = const [],
  });
}
//////////------------------------------------->

List<PersonFieldModel> data_persons = [
  PersonFieldModel(ser: '1', title: 'ชื่อ-นามสกุล*'),
  PersonFieldModel(ser: '2', title: 'เลขบัตรประจำตัวประชาชน*'),
  PersonFieldModel(ser: '3', title: 'อายุ*'),
  PersonFieldModel(ser: '4', title: 'สัญชาติ*'),
  PersonFieldModel(ser: '5', title: 'บ้านเลขที่*'),
  PersonFieldModel(ser: '6', title: 'หมู่ที่'),
  PersonFieldModel(ser: '7', title: 'ตรอก/ซอย'),
  PersonFieldModel(ser: '8', title: 'ถนน*'),
  PersonFieldModel(ser: '9', title: 'ตำบล/แขวง*'),
  PersonFieldModel(ser: '10', title: 'อำเภอ/เขต*'),
  PersonFieldModel(ser: '11', title: 'จังหวัด*'),
  PersonFieldModel(ser: '12', title: 'เบอร์โทร*'),
  PersonFieldModel(ser: '13', title: 'หมายเหตุ'),
];

List<ShopFieldModel> data_shops = [
  ShopFieldModel(
    ser: '1',
    title: 'พื้นที่เช่า (ตร.ม.)',
    detailsub: [
      ShopSubField(ser: '1', titlesub: 'บริเวณ'),
      ShopSubField(ser: '2', titlesub: 'โซน'),
      ShopSubField(ser: '3', titlesub: 'ล็อกที่'),
    ],
  ),
  ShopFieldModel(ser: '2', title: 'ขนาดพื้นที่เช่า (ตร.ม.)'),
  ShopFieldModel(ser: '3', title: 'ประเภทสินค้า'),
  ShopFieldModel(ser: '4', title: 'ชื่อร้าน'),
];
