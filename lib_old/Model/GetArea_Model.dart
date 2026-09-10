import '../ChiangMai_Municipality/Model/Properties_Model.dart';

class AreaModel {
  String? ser,
      rser,
      zser,
      lncode,
      ln,
      area,
      rent,
      rent_maket,
      st,
      img,
      data_update,
      quantity,
      ldate,
      cid,
      cid2,
      total,
      ln_c,
      area_c,
      docno,
      ln_q,
      stype_q,
      sdate_q,
      ldate_q,
      area_q,
      total_q,
      sname,
      sname_q,
      cname,
      cname_q,
      custno,
      zn,
      datex,
      timex,
      cser,
      aser,
      aserQout,
      type,
      sdate,
      dataUpdate,
      id,
      path,
      color,
      name,
      fid,
      ser_ren,
      set_date,
      docno_book,
      con_book,
      con_st_cid,
      cc_date,
      cfid,
      scfid,
      dx,
      dy,
      width,
      height,
      stype,
      exp_array,
      areatype,
      rent_d1,
      rent_d2,
      rent_d3,
      rent_d4,
      rent_d5,
      rent_d6,
      rent_d7,
      mainten,
      mainten_note1,
      mainten_note2,
      date_note1,
      date_note2;

  List<PropertiesModel> properties;

  AreaModel({
    this.ser,
    this.rser,
    this.zser,
    this.lncode,
    this.ln,
    this.area,
    this.rent,
    this.rent_maket,
    this.st,
    this.img,
    this.data_update,
    this.quantity,
    this.ldate,
    this.cid,
    this.cid2,
    this.total,
    this.ln_c,
    this.area_c,
    this.docno,
    this.ln_q,
    this.stype_q,
    this.sdate_q,
    this.ldate_q,
    this.area_q,
    this.total_q,
    this.sname,
    this.sname_q,
    this.cname,
    this.cname_q,
    this.custno,
    this.zn,
    this.datex,
    this.timex,
    this.cser,
    this.aser,
    this.aserQout,
    this.type,
    this.sdate,
    this.dataUpdate,
    this.id,
    this.path,
    this.color,
    this.name,
    this.fid,
    this.ser_ren,
    this.set_date,
    this.docno_book,
    this.con_book,
    this.con_st_cid,
    this.cc_date,
    this.cfid,
    this.scfid,
    this.dx,
    this.dy,
    this.width,
    this.height,
    this.stype,
    this.exp_array,
    this.areatype,
    this.rent_d1,
    this.rent_d2,
    this.rent_d3,
    this.rent_d4,
    this.rent_d5,
    this.rent_d6,
    this.rent_d7,
    this.mainten,
    this.mainten_note1,
    this.mainten_note2,
    this.date_note1,
    this.date_note2,
    List<PropertiesModel>? properties,
  }) : properties = properties ?? [];

  AreaModel.fromJson(Map<String, dynamic> json)
      : properties = json['properties'] != null
            ? List<PropertiesModel>.from(
                json['properties'].map((x) => PropertiesModel.fromJson(x)))
            : [] {
    ser = json['ser'];
    rser = json['rser'];
    zser = json['zser'];
    lncode = json['lncode'];
    ln = json['ln'];
    area = json['area'];
    rent = json['rent'];
    rent_maket = json['rent_maket'];
    st = json['st'];
    img = json['img'];
    data_update = json['data_update'];
    quantity = json['quantity'];
    ldate = json['ldate'];
    cid = json['cid'];
    cid2 = json['cid2'];
    total = json['total'];
    ln_c = json['ln_c'];
    area_c = json['area_c'];
    docno = json['docno'];
    ln_q = json['ln_q'];
    stype_q = json['stype_q'];
    sdate_q = json['sdate_q'];
    ldate_q = json['ldate_q'];
    area_q = json['area_q'];
    total_q = json['total_q'];
    sname = json['sname'];
    sname_q = json['sname_q'];
    cname = json['cname'];
    cname_q = json['cname_q'];
    custno = json['custno'];
    zn = json['zn'];
    datex = json['datex'];
    timex = json['timex'];
    cser = json['cser'];
    aser = json['aser'];
    aserQout = json['aser_qout'];
    type = json['type'];
    sdate = json['sdate'];
    dataUpdate = json['data_update'];
    id = json['id'];
    path = json['path'];
    color = json['color'];
    name = json['name'];
    fid = json['fid'];
    ser_ren = json['ser_ren'];
    set_date = json['set_date'];
    docno_book = json['docno_book'];
    con_book = json['con_book'];
    con_st_cid = json['con_st_cid'];
    cc_date = json['cc_date'];
    cfid = json['cfid'];
    scfid = json['scfid'];
    dx = json['dx'];
    dy = json['dy'];
    width = json['width'];
    height = json['height'];
    stype = json['stype'];
    exp_array = json['exp_array'];
    areatype = json['areatype'];
    rent_d1 = json['rent_d1'];
    rent_d2 = json['rent_d2'];
    rent_d3 = json['rent_d3'];
    rent_d4 = json['rent_d4'];
    rent_d5 = json['rent_d5'];
    rent_d6 = json['rent_d6'];
    rent_d7 = json['rent_d7'];
    mainten = json['mainten'];
    mainten_note1 = json['mainten_note1'];
    mainten_note2 = json['mainten_note2'];
    date_note1 = json['date_note1'];
    date_note2 = json['date_note2'];
  }

  Map<String, dynamic> toJson() {
    return {
      'ser': ser,
      'rser': rser,
      'zser': zser,
      'lncode': lncode,
      'ln': ln,
      'area': area,
      'rent': rent,
      'rent_maket': rent_maket,
      'st': st,
      'img': img,
      'data_update': data_update,
      'quantity': quantity,
      'ldate': ldate,
      'cid': cid,
      'cid2': cid2,
      'total': total,
      'ln_c': ln_c,
      'area_c': area_c,
      'docno': docno,
      'ln_q': ln_q,
      'stype_q': stype_q,
      'sdate_q': sdate_q,
      'ldate_q': ldate_q,
      'area_q': area_q,
      'total_q': total_q,
      'sname': sname,
      'sname_q': sname_q,
      'cname': cname,
      'cname_q': cname_q,
      'custno': custno,
      'zn': zn,
      'datex': datex,
      'timex': timex,
      'cser': cser,
      'aser': aser,
      'aser_qout': aserQout,
      'type': type,
      'sdate': sdate,
      'data_update': dataUpdate,
      'id': id,
      'path': path,
      'color': color,
      'name': name,
      'fid': fid,
      'ser_ren': ser_ren,
      'set_date': set_date,
      'docno_book': docno_book,
      'con_book': con_book,
      'con_st_cid': con_st_cid,
      'cc_date': cc_date,
      'cfid': cfid,
      'scfid': scfid,
      'dx': dx,
      'dy': dy,
      'width': width,
      'height': height,
      'stype': stype,
      'exp_array': exp_array,
      'areatype': areatype,
      'rent_d1': rent_d1,
      'rent_d2': rent_d2,
      'rent_d3': rent_d3,
      'rent_d4': rent_d4,
      'rent_d5': rent_d5,
      'rent_d6': rent_d6,
      'rent_d7': rent_d7,
      'mainten': mainten,
      'mainten_note1': mainten_note1,
      'mainten_note2': mainten_note2,
      'date_note1': date_note1,
      'date_note2': date_note2,
      'properties': properties.map((x) => x.toJson()).toList(),
    };
  }
}
