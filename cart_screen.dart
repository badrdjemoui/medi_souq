import 'package:flutter/material.dart';
import '../models/product.dart';

class PaymentScreen extends StatelessWidget {
  final List<Product> items;

  const PaymentScreen({super.key, required this.items});
  
  get cartItems => null;

  @override
  Widget build(BuildContext context) {
    double total = items.fold(0, (sum, item) => sum + item.price);

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
                itemCount: items.length,
                itemBuilder: (ctx, i) => ListTile(
                  title: Text(items[i].name),
                  trailing: Text('${items[i].price.toStringAsFixed(2)} ج.م'),
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
                Navigator.push(
    context,
    MaterialPageRoute(
      builder: (ctx) => PaymentScreen(items: cartItems),
    ),
  );
                // تنفيذ عملية الدفع لاحقاً
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
    Navigator.pop(context); // يرجع للشاشة السابقة
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
