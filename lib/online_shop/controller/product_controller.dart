import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product_card.dart';
import '../models/product_stock.dart';

class ProductController {
  final String baseUrl = "http://192.168.1.6:3000/api/store";

  Future<List<Product_Cart>> getAllProducts() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/products'));
      if (response.statusCode == 200) {
        return List<Product_Cart>.from(
          json.decode(response.body).map((x) => Product_Cart.fromJson(x)),
        );
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching products: $e');
    }
  }

  Future<List<Product_Cart>> getNewReleaseProducts() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/products/new_releases'));
      if (response.statusCode == 200) {
        return List<Product_Cart>.from(
          json.decode(response.body).map((x) => Product_Cart.fromJson(x)),
        );
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching products: $e');
    }
  }

  Future<Map<String, dynamic>> getProductStock(String productName, String productSize) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products/stock?product_name=$productName&product_size=$productSize'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print("Response Data: $data");

        if (data.isNotEmpty) {
          final productStock = data[0];

          if (productStock is Map<String, dynamic>) {
            final productId = productStock['product_id'] ?? '';
            final stokQty = productStock['stok_qty'] ?? 0;

            print("Stok: $stokQty");
            print("Product ID: $productId");

            return {
              'product_id': productId ?? '',
              'stok_qty': stokQty ?? 0,
            };
          } else {
            throw Exception('Data tidak sesuai format yang diharapkan');
          }
        } else {
          print("Tidak ada data stok ditemukan");
          return {'stok_qty': 0, 'product_id': ''}; // Tidak ada stok
        }
      } else {
        throw Exception('Gagal memuat stok produk, Status Code: ${response.statusCode}');
      }
    } catch (e) {
      print("Error fetching product stock: $e");
      return {'stok_qty': 0, 'product_id': ''};
    }
  }
}
