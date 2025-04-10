import 'package:flutter/material.dart';

class AdminDashboard extends StatelessWidget {
  final String role;

  AdminDashboard({required this.role});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('لوحة تحكم الأدمن'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Center(
              child: Text(
                'مرحبًا في لوحة تحكم الأدمن!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 30),
            // عرض الخيارات فقط إذا كان المستخدم أدمن
            if (role == 'admin') 
              Column(
                children: [
                  Card(
                    elevation: 4,
                    child: ListTile(
                      leading: Icon(Icons.people, color: Colors.blue),
                      title: Text('إدارة المستخدمين'),
                      trailing: Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        // فتح شاشة إدارة المستخدمين
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 4,
                    child: ListTile(
                      leading: Icon(Icons.shopping_bag, color: Colors.green),
                      title: Text('إدارة المنتجات'),
                      trailing: Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        // فتح شاشة إدارة المنتجات
                      },
                    ),
                  ),
                ],
              ),
            // إذا كان المستخدم ليس أدمن، يمكننا إضافة خيارات أخرى هنا
          ],
        ),
      ),
    );
  }
}
