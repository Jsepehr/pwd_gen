import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class PwdEntity {
  final String id;
  String hint;
  String password;
  String usageDate;
  PwdEntity({
    required this.id,
    required this.hint,
    required this.password,
    required this.usageDate,
  });

  PwdEntity copyWith({
    String? id,
    String? hint,
    String? password,
    String? usageDate,
  }) {
    return PwdEntity(
      id: id ?? this.id,
      hint: hint ?? this.hint,
      password: password ?? this.password,
      usageDate: usageDate ?? this.usageDate,
    );
  }

  PwdEntity from({required PwdEntity pwd}) {
    return PwdEntity(
      id: pwd.id,
      hint: pwd.hint,
      password: pwd.password,
      usageDate: pwd.usageDate,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'hint': hint,
      'password': password,
      'usageDate': usageDate,
    };
  }

  factory PwdEntity.fromMap(Map<String, dynamic> map) {
    return PwdEntity(
      id: map['id'] as String,
      hint: map['hint'] as String,
      password: map['password'] as String,
      usageDate: map['usageDate'].toString(),
    );
  }

  String toJson() => json.encode(toMap());

  factory PwdEntity.fromJson(String source) =>
      PwdEntity.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'PwdEntity(id: $id, hint: $hint, password: $password, usageDate: $usageDate)';
  }

  @override
  bool operator ==(covariant PwdEntity other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.hint == hint &&
        other.password == password &&
        other.usageDate == usageDate;
  }

  @override
  int get hashCode {
    return id.hashCode ^ hint.hashCode ^ password.hashCode ^ usageDate.hashCode;
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
