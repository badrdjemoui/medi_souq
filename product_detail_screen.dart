import 'package:flutter/material.dart';
import '../models/carte_item.dart';
import '../models/product.dart';



class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  List<CartItem> cartItems = [];

  // إضافة المنتج إلى السلة
  void _addToCart(Product product) {
    setState(() {
      final existingItem = cartItems.firstWhere(
        (item) => item.product.name == product.name,
        orElse: () => CartItem(product: product, quantity: 0),
      );

      if (existingItem.quantity > 0) {
        existingItem.quantity++;
      } else {
        cartItems.add(CartItem(product: product));
      }
    });

    // إشعار بعد الإضافة
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✔ تمت الإضافة إلى السلة'),
        backgroundColor: Colors.green[600],
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
    );

    _showCartBottomSheet();
  }

  // عرض السلة عند إضافة منتج
  void _showCartBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        double total = cartItems.fold(0, (sum, item) => sum + item.totalPrice);

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("🛒 سلة المشتريات", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              Divider(thickness: 1),
              ...cartItems.map((item) => ListTile(
                    title: Text(item.product.name),
                    subtitle: Text('السعر: ${item.product.price} × ${item.quantity}'),
                    trailing: Text('${item.totalPrice.toStringAsFixed(2)} ج.م'),
                  )),
              Divider(thickness: 1),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('المجموع الكلي:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('${total.toStringAsFixed(2)} ج.م', style: TextStyle(fontSize: 18, color: Colors.teal[700])),
                ],
              ),
              SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.check),
                label: Text("تم"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                product.imageUrl,
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Icon(Icons.broken_image, size: 100),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return SizedBox(height: 250, child: Center(child: CircularProgressIndicator()));
                },
              ),
            ),
            SizedBox(height: 20),
            Text(
              product.description,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 30),
            Text(
              '${product.price.toStringAsFixed(2)} ج.م',
              style: TextStyle(fontSize: 26, color: Colors.teal[700], fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _addToCart(product),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: Icon(Icons.add_shopping_cart),
              label: Text('أضف إلى السلة', style: TextStyle(fontSize: 18)),
            ),
            SizedBox(height: 20),
            Divider(thickness: 1),
            SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تم الضغط على الدفع')));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: Icon(Icons.payment),
              label: Text('الدفع الآن', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
