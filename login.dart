import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/user.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';
  Color _errorTextColor = Colors.red;
  Color _emailBorderColor = Colors.grey;
  Color _passwordBorderColor = Colors.grey;

  // المتغير الذي سيحمل قائمة المستخدمين
  List<AppUser> users = [];

  // دالة لتحميل المستخدمين من Firebase
  Future<void> _loadUsers() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance.collection('users').get();
      final userList = querySnapshot.docs.map((doc) {
        return AppUser.fromMap(doc.data(), doc.id); // تمرير doc.id كمحدد
      }).toList();

      setState(() {
        users = userList;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'فشل في تحميل المستخدمين: ${e.toString()}';
        _errorTextColor = Colors.red;
      });
    }
  }

  // الدالة لتسجيل الدخول
  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _emailBorderColor = Colors.grey;
      _passwordBorderColor = Colors.grey;
    });

    if (_emailController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'الرجاء ملء جميع الحقول';
        _errorTextColor = Colors.orange;
        _emailBorderColor = Colors.red;
        _passwordBorderColor = Colors.red;
        _isLoading = false;
      });
      return;
    }

    try {
      // التأكد من أن users تم تحميلهم
      if (users.isEmpty) {
        await _loadUsers(); // إذا لم يتم تحميل المستخدمين، نقوم بتحميلهم
      }

      // محاولة إيجاد المستخدم
      final user = users.firstWhere(
        (user) => user.email == _emailController.text.trim() && user.password == _passwordController.text.trim(),
        orElse: () => AppUser(id: '', name: '', email: '', password: '', role: ''),
      );

      if (user.email.isNotEmpty) {
        if (user.role == 'admin') {
          Navigator.pushReplacementNamed(context, '/manageUsers');
        }  else {
          Navigator.pushReplacementNamed(context, '/HomeScreen');
        }
      } else {
        setState(() {
          _errorMessage = 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
          _errorTextColor = Colors.red;
          _emailBorderColor = Colors.red;
          _passwordBorderColor = Colors.red;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'حدث خطأ: ${e.toString()}';
        _errorTextColor = Colors.red;
        _isLoading = false;
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.grey[100],
    body: Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, size: 80, color: Colors.teal),
            SizedBox(height: 20),
            Text("أهلاً بك 👋", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text("سجل دخولك للمتابعة", style: TextStyle(color: Colors.grey[600])),

            SizedBox(height: 32),

            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'البريد الإلكتروني',
                hintText: 'example@email.com',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: _emailBorderColor),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 16),

            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'كلمة المرور',
                hintText: '••••••••',
                prefixIcon: Icon(Icons.lock),
                suffixIcon: Icon(Icons.visibility_off),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: _passwordBorderColor),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Text(
                  _errorMessage,
                  style: TextStyle(color: _errorTextColor),
                ),
              ),

            SizedBox(height: 24),

            ElevatedButton.icon(
              onPressed: _isLoading ? null : _login,
              icon: _isLoading
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Icon(Icons.login),
              label: Text('تسجيل الدخول'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
                backgroundColor: Colors.teal,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),

            SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('ليس لديك حساب؟'),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/signUp');
                  },
                  child: Text('سجل الآن'),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
}
