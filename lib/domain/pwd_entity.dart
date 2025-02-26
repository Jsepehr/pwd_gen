import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class PwdEntity {
  final String id;
  String hint;
  String password;
  int usageCount;
  PwdEntity({
    required this.id,
    required this.hint,
    required this.password,
    required this.usageCount,
  });

   

  PwdEntity copyWith({
    String? id,
    String? hint,
    String? password,
    int? usageCount,
  }) {
    return PwdEntity(
      id: id ?? this.id,
      hint: hint ?? this.hint,
      password: password ?? this.password,
      usageCount: usageCount ?? this.usageCount,
    );
  }
  PwdEntity from({
    required  PwdEntity pwd
  }) {
    return PwdEntity(
      id: pwd.id,
      hint: pwd. hint ,
      password: pwd. password ,
      usageCount: pwd. usageCount ,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'hint': hint,
      'password': password,
      'usageCount': usageCount,
    };
  }

  factory PwdEntity.fromMap(Map<String, dynamic> map) {
    return PwdEntity(
      id: map['id'] as String,
      hint: map['hint'] as String,
      password: map['password'] as String,
      usageCount: map['usageCount'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory PwdEntity.fromJson(String source) => PwdEntity.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'PwdEntity(id: $id, hint: $hint, password: $password, usageCount: $usageCount)';
  }

  @override
  bool operator ==(covariant PwdEntity other) {
    if (identical(this, other)) return true;
  
    return 
      other.id == id &&
      other.hint == hint &&
      other.password == password &&
      other.usageCount == usageCount;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      hint.hashCode ^
      password.hashCode ^
      usageCount.hashCode;
  }
}

class PwdEntityEdit {
  String hint;
  String password;

  PwdEntityEdit({
    required this.hint,
    required this.password,
  });

  void update({
    required String hint,
    required String password,
    required int index,
  }) {
    this.hint = hint;
    this.password = password;
  }
}
