import 'package:pwd_gen/domain/pwd_entity.dart';

class PwdModel extends PwdEntity {
  PwdModel({
    required super.id,
    required super.hint,
    required super.password,
    required super.usageCount,
  });

  factory PwdModel.fromMap(Map<String, dynamic> map) {
    return PwdModel(
        hint: map['hint'],
        id: map['id'],
        password: map['password'],
        usageCount: int.parse(map['usageCount']));
  }
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'hint': hint,
      'password': password,
      'usageCount': usageCount
    };
  }
}
