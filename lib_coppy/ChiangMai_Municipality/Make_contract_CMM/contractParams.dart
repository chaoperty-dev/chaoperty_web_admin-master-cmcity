class ContractStore {
  static final ContractStore _i = ContractStore._();
  factory ContractStore() => _i;
  ContractStore._();

  // กำหนดชนิดให้ชัดเจน
  String areaIndex = '';
  String areaLn = '';
  String areaSum = '';
  String rentSum = '';
  String page = '';
  String uuid = '';
  String step = '';
  String paymentUuid = '';
  String paymentAmount = '';
  List<Map<String, dynamic>> paymentJson = const [];
}


// class ContractStore {
//   static final ContractStore _instance = ContractStore._internal();
//   factory ContractStore() => _instance;
//   ContractStore._internal();

//   late dynamic areaIndex;
//   late dynamic areaLn;
//   late dynamic areaSum;
//   late dynamic rentSum;
//   late dynamic page;
//   late dynamic uuid;
//   late dynamic step;
//   late dynamic paymentUuid;
//   late dynamic paymentAmount;
//   dynamic paymentJson;
// }



// class ContractParams {
//   final String areaIndex;
//   final String areaLn;
//   final String areaSum;
//   final String rentSum;
//   final String page;
//   final String uuid;
//   final String step;
//   final String paymentUuid;
//   final String paymentAmount;
//   final dynamic paymentJson;

//   ContractParams({
//     required this.areaIndex,
//     required this.areaLn,
//     required this.areaSum,
//     required this.rentSum,
//     required this.page,
//     required this.uuid,
//     required this.step,
//     required this.paymentUuid,
//     required this.paymentAmount,
//     required this.paymentJson,
//   });
// }
