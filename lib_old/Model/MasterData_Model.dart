import 'GetRenTal_Model.dart';
import 'GetUser_Model.dart';

class MasterDataModel {
  final List<RenTalModel> rentalSetring;
  final dynamic incPasscode;
  final List<UserModel> gcUser;
  final List<UserModel> connectedUser;

  MasterDataModel({
    required this.rentalSetring,
    required this.incPasscode,
    required this.gcUser,
    required this.connectedUser,
  });

  factory MasterDataModel.fromJson(Map<String, dynamic> json) {
    return MasterDataModel(
      rentalSetring: (json['rental_setring'] as List? ?? [])
          .map((item) => RenTalModel.fromJson(item))
          .toList(),
      incPasscode: json['Inc_passcode'] ?? [],
      gcUser: (json['GC_user'] as List? ?? [])
          .map((item) => UserModel.fromJson(item))
          .toList(),
      connectedUser: (json['Connected_User'] as List? ?? [])
          .map((item) => UserModel.fromJson(item))
          .toList(),
    );
  }
}
