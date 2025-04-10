import 'package:flutter/material.dart';
import '../screens/cart_data.dart'; // استيراد سلة المشتريات العامة

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double total = cartItems.fold(0, (sum, item) => sum + item.price);

    return Scaffold(
      appBar: AppBar(
        title: Text('💳 الدفع'),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('تفاصيل الشراء', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView.builder(
                itemCount: cartItems.length,
                itemBuilder: (ctx, i) => ListTile(
                  title: Text(cartItems[i].name),
                  trailing: Text('${cartItems[i].price.toStringAsFixed(2)} ج.م'),
                ),
              ),
            ),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('المجموع:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text('${total.toStringAsFixed(2)} ج.م', style: TextStyle(fontSize: 18, color: Colors.teal)),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                // تنفيذ عملية الدفع لاحقًا
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('✅ تم تنفيذ الدفع بنجاح!')),
                );
              },
              icon: Icon(Icons.check_circle_outline),
              label: Text('تأكيد الدفع'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            TextButton.icon(
              onPressed: () {
                Navigator.pop(context); // يرجع للشاشة السابقة لإضافة المزيد
              },
              icon: Icon(Icons.add_shopping_cart, color: Colors.teal),
              label: Text(
                'إضافة مشتريات أخرى',
                style: TextStyle(color: Colors.teal, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
