import 'package:flutter/material.dart';
import 'package:steppa/offline_shop/ui/factory_stock.dart';
import '../models/product.dart';
import '../controller/product_controller.dart';
import 'history_screen.dart';
import 'request_stock.dart';
import 'cart_screen.dart';

class OfflineShopScreen extends StatefulWidget {
  const OfflineShopScreen({Key? key}) : super(key: key);

  @override
  State<OfflineShopScreen> createState() => _OfflineShopScreenState();
}

class _OfflineShopScreenState extends State<OfflineShopScreen> {
  List<Product> _products = [];
  List<Product> _filteredProducts = []; // List to store filtered products
  Map<int, int> _productQuantities = {};  // Variable to store product quantities based on index
  bool isLoading = true;
  final ProductController productController = ProductController();
  final TextEditingController _searchController = TextEditingController(); // Controller for search input

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      List<Product> products = await productController.getAllProducts();
      setState(() {
        _products = products;
        _filteredProducts = products;  // Initially, show all products
        isLoading = false;
        for (int i = 0; i < _products.length; i++) {
          _productQuantities[i] = 0;  // Default quantity is 0
        }
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error fetching products: $e");
    }
  }

  void _updateQuantity(int index, int change) {
    setState(() {
      int newQuantity = _productQuantities[index]! + change;
      int maxQuantity = _products[index].product_quantity ?? 0; // Fallback to 0 if product_quantity is null
      if (newQuantity >= 0 && newQuantity <= maxQuantity) {
        _productQuantities[index] = newQuantity;
      }
    });
  }

  void _goToCart() {
    // Filter products based on quantity > 0 and exclude null
    final cartItems = _filteredProducts.where((product) {
      final index = _filteredProducts.indexOf(product);
      return _productQuantities[index]! > 0; // Only products with quantity > 0
    }).toList();

    // Convert Map<int, int> to Map<Product, int>
    final productQuantities = Map<Product, int>.fromIterable(cartItems,
        key: (product) => product,
        value: (product) {
          final index = _filteredProducts.indexOf(product);
          return _productQuantities[index]!;  // Get quantity from Map<int, int>
        });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CartScreen(cartItems: cartItems, productQuantities: productQuantities),
      ),
    );
  }

  // Function to filter products by name
  void _filterProducts(String query) {
    final filtered = _products.where((product) {
      final productName = product.product_name?.toLowerCase() ?? '';
      return productName.contains(query.toLowerCase()); // Match the product name
    }).toList();

    setState(() {
      _filteredProducts = filtered; // Update the filtered products list
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline Shop'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer(); // Open the drawer
            },
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: const Text(
                'Offline Shop',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.delivery_dining),
              title: const Text('Shipment'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const StocksScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.money),
              title: const Text('Cashier'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const OfflineShopScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.task),
              title: const Text('History Penjualan'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HistoryScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.factory),
              title: const Text('Factory Stock'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FactoryStockScreen(),
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Back To Menu'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/landing');
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search field above the ListView
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search by name...',
                suffixIcon: Icon(Icons.search),
                contentPadding: EdgeInsets.symmetric(vertical: 10),
              ),
              onChanged: _filterProducts, // Filter products as the text changes
            ),
          ),
          // ListView to display products
          Expanded(
            child: ListView.builder(
              itemCount: _filteredProducts.length,  // Use filtered list
              itemBuilder: (context, index) {
                final product = _filteredProducts[index];
                final productQuantity = _productQuantities[index]!;  // Get quantity from map
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    leading: Image.network(product.product_image!),
                    title: Text(product.product_name!),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('\Rp. ${product.price?.toStringAsFixed(2)}'), // Show price
                        Text('Category: ${product.product_category}'),  // Show category
                        Text('Size: ${product.product_size}'),          // Show size
                        Text('Stock: ${product.product_quantity}'),                 // Show stock
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: productQuantity > 0
                              ? () => _updateQuantity(index, -1)
                              : null, // Disable button if quantity is 0
                        ),
                        Text('$productQuantity'),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: productQuantity < product.product_quantity!
                              ? () => _updateQuantity(index, 1)
                              : null, // Disable button if stock is 0
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _goToCart,
        child: const Icon(Icons.shopping_cart),
      ),
    );
  }
}
