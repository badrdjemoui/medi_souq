import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  final CollectionReference usersRef =
      FirebaseFirestore.instance.collection('users');

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String? userRole = 'user'; // تحديد الدور الافتراضي كـ 'user'

  String? editingUserId;

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> addOrUpdateUser() async {
    final username = usernameController.text.trim();
    final email = emailController.text.trim().toLowerCase();
    final password = passwordController.text.replaceAll(' ', '');

    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      showError('يرجى ملء جميع الحقول');
      return;
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      showError('صيغة البريد الإلكتروني غير صالحة');
      return;
    }

    if (password.length < 6) {
      showError('كلمة السر يجب أن تكون على الأقل 6 أحرف');
      return;
    }

    try {
      // تحقق من وجود بريد إلكتروني مكرر
      final existingUser = await usersRef
          .where('email', isEqualTo: email)
          .get();

      if (editingUserId == null && existingUser.docs.isNotEmpty) {
        showError('هذا البريد الإلكتروني مستخدم بالفعل');
        return;
      }

      if (editingUserId == null) {
        await usersRef.add({
          'username': username,
          'email': email,
          'password': password,
          'role': userRole, // إضافة الدور
          'createdAt': Timestamp.now(),
        });
      } else {
        await usersRef.doc(editingUserId).update({
          'username': username,
          'email': email,
          'password': password,
          'role': userRole, // تحديث الدور
          'updatedAt': Timestamp.now(),
        });
      }

      usernameController.clear();
      emailController.clear();
      passwordController.clear();
      editingUserId = null;
      userRole = 'user'; // إعادة تعيين الدور الافتراضي بعد الإضافة
      Navigator.of(context).pop();
    } catch (e) {
      showError('حدث خطأ: $e');
    }
  }

  void openUserForm({String? userId, String? username, String? email, String? password, String? role}) {
    usernameController.text = username ?? '';
    emailController.text = email ?? '';
    passwordController.text = password ?? '';
    userRole = role ?? 'user'; // تعيين الدور عند التعديل
    editingUserId = userId;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(userId == null ? 'إضافة مستخدم جديد' : 'تعديل المستخدم'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: usernameController,
                decoration: InputDecoration(
                  labelText: 'الاسم',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'البريد الإلكتروني',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'كلمة السر',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: userRole,
                decoration: InputDecoration(
                  labelText: 'الدور',
                  prefixIcon: Icon(Icons.account_circle),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                items: <String>['admin', 'user']
                    .map((role) => DropdownMenuItem<String>(
                          value: role,
                          child: Text(role),
                        ))
                    .toList(),
                onChanged: (newValue) {
                  setState(() {
                    userRole = newValue!;
                  });
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              usernameController.clear();
              emailController.clear();
              passwordController.clear();
              editingUserId = null;
              userRole = 'user'; // إعادة تعيين الدور الافتراضي
              Navigator.of(context).pop();
            },
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: addOrUpdateUser,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            ),
            child: Text(userId == null ? 'إضافة' : 'تحديث'),
          ),
        ],
      ),
    );
  }

  Future<void> deleteUser(String userId) async {
    await usersRef.doc(userId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة المستخدمين'),
        backgroundColor: Colors.deepPurple,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: usersRef.orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data!.docs;

          if (users.isEmpty) {
            return const Center(child: Text('لا يوجد مستخدمون.'));
          }

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              final userData = user.data() as Map<String, dynamic>;

              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.deepPurple,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  title: Text(userData['username'] ?? 'بدون اسم'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(userData['email'] ?? 'بدون بريد'),
                      Text('الدور: ${userData['role'] ?? 'بدون دور'}'),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => openUserForm(
                          userId: user.id,
                          username: userData['username'],
                          email: userData['email'],
                          password: userData['password'],
                          role: userData['role'],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => deleteUser(user.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        onPressed: () => openUserForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
