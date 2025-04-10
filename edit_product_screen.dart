import 'package:flutter/material.dart';


import 'package:cloud_firestore/cloud_firestore.dart';

 // تأكد من استيراد FirebaseService

class EditProductScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  EditProductScreen({required this.product});

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _imageUrlController;
  late TextEditingController _categoryController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product['name']);
    _descriptionController = TextEditingController(text: widget.product['description']);
    _priceController = TextEditingController(text: widget.product['price'].toString());
    _imageUrlController = TextEditingController(text: widget.product['imageUrl']);
    _categoryController = TextEditingController(text: widget.product['category']);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  void _updateProduct() async {
    if (_nameController.text.isEmpty || _priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('يرجى ملء كل الحقول'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseService().updateProduct(widget.product['id'], {
        'name': _nameController.text,
        'description': _descriptionController.text,
        'price': double.parse(_priceController.text),
        'imageUrl': _imageUrlController.text.isEmpty
            ? 'https://via.placeholder.com/150' // صورة افتراضية
            : _imageUrlController.text,
        'category': _categoryController.text,
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('تم تحديث المنتج بنجاح'),
        backgroundColor: Colors.green,
      ));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('حدث خطأ أثناء التحديث'),
        backgroundColor: Colors.red,
      ));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _deleteProduct() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseService().deleteProduct(widget.product['id']);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('تم حذف المنتج بنجاح'),
        backgroundColor: Colors.green,
      ));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('حدث خطأ أثناء الحذف'),
        backgroundColor: Colors.red,
      ));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('تعديل المنتج')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'اسم المنتج'),
              ),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'الوصف'),
              ),
              TextField(
                controller: _priceController,
                decoration: InputDecoration(labelText: 'السعر'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _imageUrlController,
                decoration: InputDecoration(labelText: 'رابط الصورة'),
              ),
              TextField(
                controller: _categoryController,
                decoration: InputDecoration(labelText: 'الفئة'),
              ),
              SizedBox(height: 20),
              _isLoading
                  ? CircularProgressIndicator()
                  : Column(
                      children: [
                        ElevatedButton(
                          onPressed: _updateProduct,
                          child: Text('تحديث'),
                        ),
                        SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: _deleteProduct,
                          child: Text('حذف المنتج'),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red),
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

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // إضافة منتج
  Future<void> addProduct(Map<String, dynamic> product) async {
    try {
      await _db.collection('products').add(product);
    } catch (e) {
      throw Exception('خطأ في إضافة المنتج: $e');
    }
  }

  // تعديل منتج
  Future<void> updateProduct(String id, Map<String, dynamic> product) async {
    try {
      await _db.collection('products').doc(id).update(product);
    } catch (e) {
      throw Exception('خطأ في تعديل المنتج: $e');
    }
  }

  // حذف منتج
  Future<void> deleteProduct(String id) async {
    try {
      await _db.collection('products').doc(id).delete();
    } catch (e) {
      throw Exception('خطأ في حذف المنتج: $e');
    }
  }

  getProducts() {}
}
