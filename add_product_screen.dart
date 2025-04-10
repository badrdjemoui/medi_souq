import 'package:flutter/material.dart';
import 'edit_product_screen.dart';


class AddProductScreen extends StatefulWidget {
  final VoidCallback onProductAdded;

  const AddProductScreen({super.key, required this.onProductAdded});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}
class _AddProductScreenState extends State<AddProductScreen> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _categoryController = TextEditingController();

  bool _isLoading = false;

  void _addProduct() async {
    if (_nameController.text.isEmpty || _priceController.text.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      await FirebaseService().addProduct({
        'name': _nameController.text,
        'description': _descController.text,
        'price': double.tryParse(_priceController.text) ?? 0.0,
        'imageUrl': _imageUrlController.text.isEmpty
            ? 'https://via.placeholder.com/150'
            : _imageUrlController.text,
        'category': _categoryController.text,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تمت إضافة المنتج بنجاح')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('إضافة منتج')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _nameController, decoration: InputDecoration(labelText: 'الاسم')),
            TextField(controller: _descController, decoration: InputDecoration(labelText: 'الوصف')),
            TextField(controller: _priceController, decoration: InputDecoration(labelText: 'السعر'), keyboardType: TextInputType.number),
            TextField(controller: _imageUrlController, decoration: InputDecoration(labelText: 'رابط الصورة')),
            TextField(controller: _categoryController, decoration: InputDecoration(labelText: 'الفئة')),
            SizedBox(height: 20),
            _isLoading ? CircularProgressIndicator() :
            ElevatedButton(onPressed: _addProduct, child: Text('إضافة'))
          ],
        ),
      ),
    );
  }
}
