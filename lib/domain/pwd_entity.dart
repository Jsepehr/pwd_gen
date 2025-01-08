class PwdEntity {
  final String id;
   String hint;
   String password;
   int usageCount;

  PwdEntity({
    required this.id,
    required this.hint,
    required this.password,
    required this.usageCount
  });
}
