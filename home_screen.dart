
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/product.dart';
import '../models/user.dart';
import 'product_detail_screen.dart';

// FirebaseService class for fetching products and users
class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Fetch products
  Future<List<Product>> getProducts() async {
    try {
      QuerySnapshot snapshot = await _db.collection('products').get();
      return snapshot.docs
          .map((doc) => Product.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw e;
    }
  }

  // Add product
  Future<void> addProduct(Product product) async {
    try {
      await _db.collection('products').doc(product.id).set(product.toMap());
    } catch (e) {
      throw e;
    }
  }

  // Delete product
  Future<void> deleteProduct(String productId) async {
    try {
      await _db.collection('products').doc(productId).delete();
    } catch (e) {
      throw e;
    }
  }

  // Fetch users
Future<List<AppUser>> getUsers() async {
  try {
    QuerySnapshot snapshot = await _db.collection('users').get();
    return snapshot.docs
        .map((doc) => AppUser.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  } catch (e) {
    throw e;
  }
}


  // Delete user
  Future<void> deleteUser(String userId) async {
    try {
      await _db.collection('users').doc(userId).delete();
    } catch (e) {
      throw e;
    }
  }
}

// HomeScreen where products and users are displayed
class HomeScreen extends StatefulWidget {
  final Function(Locale) setLocale;

  const HomeScreen({Key? key, required this.setLocale}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Product> products = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  void fetchProducts() async {
    try {
      products = await FirebaseService().getProducts();
    } catch (e) {
      print("❌ Error fetching products: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void deleteProduct(String productId) async {
    try {
      await FirebaseService().deleteProduct(productId);
      setState(() {
        products.removeWhere((product) => product.id == productId);
      });
    } catch (e) {
      print("❌ Error deleting product: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? 'المنتجات الطبية' : 'Medical Products'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            tooltip: isArabic ? 'إضافة منتج' : 'Add Product',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddProductScreen(onProductAdded: fetchProducts),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.language),
            tooltip: isArabic ? 'تغيير اللغة' : 'Change Language',
            onPressed: () {
              widget.setLocale(Locale(isArabic ? 'en' : 'ar'));
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.teal))
          : products.isEmpty
              ? Center(child: Text(isArabic ? 'لا توجد منتجات حالياً' : 'No products available'))
              : ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (ctx, i) => Card(
                    elevation: 3,
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(12),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          products[i].imageUrl,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Icon(Icons.image_not_supported, size: 40),
                        ),
                      ),
                      title: Text(products[i].name),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${products[i].price.toStringAsFixed(2)} دج'),
                          Text(products[i].category, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                        ],
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(isArabic ? 'تأكيد الحذف' : 'Confirm Deletion'),
                            content: Text(isArabic ? 'هل أنت متأكد من حذف هذا المنتج؟' : 'Are you sure you want to delete this product?'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  deleteProduct(products[i].id);
                                  Navigator.pop(context);
                                },
                                child: Text(isArabic ? 'نعم' : 'Yes'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text(isArabic ? 'لا' : 'No'),
                              ),
                            ],
                          ),
                        ),
                      ),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProductDetailScreen(product: products[i]),
                        ),
                      ),
                    ),
                  ),
                ),
    );
  }
}

// AddProductScreen for adding new products
class AddProductScreen extends StatefulWidget {
  final Function onProductAdded;

  const AddProductScreen({Key? key, required this.onProductAdded}) : super(key: key);

  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String description = '';
  String imageUrl = '';
  double price = 0.0;
  String category = '';

  void saveProduct() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      Product newProduct = Product(
        id: id,
        name: name,
        description: description,
        imageUrl: imageUrl,
        price: price,
        category: category,
      );
      FirebaseService().addProduct(newProduct);
      widget.onProductAdded();
      Navigator.pop(context);
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
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(labelText: 'Product Name'),
                  validator: (value) => value!.isEmpty ? 'Name is required' : null,
                  onSaved: (value) => name = value!,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Description'),
                  validator: (value) => value!.isEmpty ? 'Description is required' : null,
                  onSaved: (value) => description = value!,
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
                TextFormField(
                  decoration: InputDecoration(labelText: 'Category'),
                  validator: (value) => value!.isEmpty ? 'Category is required' : null,
                  onSaved: (value) => category = value!,
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
      ),
    );
  }
}
