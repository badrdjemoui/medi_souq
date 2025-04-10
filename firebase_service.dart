import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Add Product
  Future<void> addProduct(Product product) async {
    try {
      await _db.collection('products').add(product.toMap());
    } catch (e) {
      throw e;
    }
  }

  // Fetch products
  Future<List<Product>> getProducts() async {
    try {
      QuerySnapshot snapshot = await _db.collection('products').get();
      return snapshot.docs
          .map((doc) => Product.fromFirestore(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw e;
    }
  }

  // Delete Product
  Future<void> deleteProduct(String productId) async {
    try {
      await _db.collection('products').doc(productId).delete();
    } catch (e) {
      throw e;
    }
  }
}

class Product {
  final String id;
  final String name;
  final String imageUrl;
  final double price;

  Product({required this.id, required this.name, required this.imageUrl, required this.price});

  factory Product.fromFirestore(Map<String, dynamic> firestoreData) {
    return Product(
      id: firestoreData['id'] ?? '',
      name: firestoreData['name'] ?? '',
      imageUrl: firestoreData['imageUrl'] ?? '',
      price: firestoreData['price'] ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'price': price,
    };
  }
}

class AddProductScreen extends StatefulWidget {
  final Function onProductAdded;

  const AddProductScreen({Key? key, required this.onProductAdded}) : super(key: key);

  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String imageUrl = '';
  double price = 0.0;

  void saveProduct() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Ensure the Product is initialized properly
      if (name.isNotEmpty && imageUrl.isNotEmpty && price > 0.0) {
        Product newProduct = Product(id: DateTime.now().toString(), name: name, imageUrl: imageUrl, price: price);

        // Adding product to Firebase
        FirebaseService().addProduct(newProduct).then((_) {
          widget.onProductAdded();
          Navigator.pop(context);
        }).catchError((e) {
          print("Error adding product: $e");
        });
      } else {
        print("Invalid product data");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add New Product')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Product Name'),
                validator: (value) => value!.isEmpty ? 'Name is required' : null,
                onSaved: (value) => name = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Image URL'),
                validator: (value) => value!.isEmpty ? 'Image URL is required' : null,
                onSaved: (value) => imageUrl = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Price is required' : null,
                onSaved: (value) => price = double.parse(value!),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: saveProduct,
                child: Text('Save Product'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
