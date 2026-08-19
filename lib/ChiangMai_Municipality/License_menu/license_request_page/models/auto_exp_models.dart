// ============================================================================
// auto_exp_models.dart
// ============================================================================
// Models สำหรับ AddBillingTable (license_request_page)
// - copy มาจาก license_contract_page/models/billing_models.dart
// - ใช้ภายใน license_request_page เท่านั้น (ไม่ต้องพึ่ง contract)
// ============================================================================

class LcExpTransModel {
  String? uuid;
  String? ser;
  String? expname;
  String? exptser;
  String? unitser;
  String? unit;
  String? day;
  String? term;
  String? sdate;
  String? ldate;
  String? qty;
  String? amt;
  String? vser;
  String? vtype;
  String? nvat;
  String? vat;
  String? pvat;
  String? wser;
  String? wtype;
  String? nwht;
  String? wht;
  String? total;

  LcExpTransModel({
    this.uuid,
    this.ser,
    this.expname,
    this.exptser,
    this.unitser,
    this.unit,
    this.day,
    this.term,
    this.sdate,
    this.ldate,
    this.qty,
    this.amt,
    this.vser,
    this.vtype,
    this.nvat,
    this.vat,
    this.pvat = '0.00',
    this.wser,
    this.wtype,
    this.nwht,
    this.wht = '0.00',
    this.total = '0.00',
  });

  /// แปลง model → Map เพื่อส่งใน `debt_details` ของ POST /admin/requests
  Map<String, dynamic> toJson() => {
        'uuid': uuid,
        'ser': ser,
        'expname': expname,
        'exptser': exptser,
        'unitser': unitser,
        'unit': unit,
        'day': day,
        'term': term,
        'sdate': sdate,
        'ldate': ldate,
        'qty': qty,
        'amt': amt,
        'vser': vser,
        'vtype': vtype,
        'nvat': nvat,
        'vat': vat,
        'pvat': pvat,
        'wser': wser,
        'wtype': wtype,
        'nwht': nwht,
        'wht': wht,
        'total': total,
      };
}

class LcAutoExpModel {
  String? ser;
  String? expname;
  String? exptser;
  String? unitser;
  String? unit;
  String? term;
  String? qty;
  String? amt;
  String? vat;
  String? wht;
  String? priAuto;
  String? etype;
  String? auto;

  LcAutoExpModel({
    this.ser,
    this.expname,
    this.exptser,
    this.unitser,
    this.unit,
    this.term,
    this.qty,
    this.amt,
    this.vat,
    this.wht,
    this.priAuto,
    this.etype,
    this.auto,
  });

  factory LcAutoExpModel.fromJson(Map<String, dynamic> json) {
    return LcAutoExpModel(
      ser: json['ser']?.toString(),
      expname: json['expname']?.toString(),
      exptser: json['exptser']?.toString(),
      unitser: json['unitser']?.toString(),
      unit: json['unit']?.toString(),
      term: json['term']?.toString(),
      qty: json['qty']?.toString(),
      amt: json['amt']?.toString(),
      vat: json['vat']?.toString(),
      wht: json['wht']?.toString(),
      priAuto: json['pri_auto']?.toString() ?? json['amt']?.toString(),
      etype: json['etype']?.toString(),
      auto: json['auto']?.toString(),
    );
  }
}

class LcExpTypeModel {
  String? ser;
  String? bills;
  String? etype;
  String? dtype;

  LcExpTypeModel({this.ser, this.bills, this.etype, this.dtype});

  factory LcExpTypeModel.fromJson(Map<String, dynamic> json) {
    return LcExpTypeModel(
      ser: json['ser']?.toString(),
      bills: json['bills']?.toString(),
      etype: json['etype']?.toString(),
      dtype: json['dtype']?.toString(),
    );
  }
}

class LcUnitModel {
  String? ser;
  String? unit;
  String? day;

  LcUnitModel({this.ser, this.unit, this.day});

  factory LcUnitModel.fromJson(Map<String, dynamic> json) {
    return LcUnitModel(
      ser: json['ser']?.toString(),
      unit: json['unit']?.toString(),
      day: json['day']?.toString(),
    );
  }
}

class LcVatModel {
  String? ser;
  String? vat;
  String? pct;

  LcVatModel({this.ser, this.vat, this.pct});

  factory LcVatModel.fromJson(Map<String, dynamic> json) {
    return LcVatModel(
      ser: json['ser']?.toString(),
      vat: json['vat']?.toString(),
      pct: json['pct']?.toString(),
    );
  }
}

class LcWhtModel {
  String? ser;
  String? wht;
  String? pct;

  LcWhtModel({this.ser, this.wht, this.pct});

  factory LcWhtModel.fromJson(Map<String, dynamic> json) {
    return LcWhtModel(
      ser: json['ser']?.toString(),
      wht: json['wht']?.toString(),
      pct: json['pct']?.toString(),
    );
  }
}
