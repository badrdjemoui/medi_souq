class AppUser {
  final String id;
  final String name;
  final String email;
  final String password; // تخزين كلمة المرور
  final String role; // تخزين الدور

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.password, // إضافة كلمة المرور في المُنشئ
    required this.role, // إضافة الدور في المُنشئ
  });

  factory AppUser.fromMap(Map<String, dynamic> data, String docId) {
    return AppUser(
      id: docId,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      password: data['password'] ?? '', // تضمين كلمة المرور من البيانات
      role: data['role'] ?? '', // تضمين الدور من البيانات
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'password': password, // تضمين كلمة المرور عند تحويل الكائن إلى خريطة
      'role': role, // تضمين الدور عند تحويل الكائن إلى خريطة
    };
  }
}
