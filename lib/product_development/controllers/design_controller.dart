import 'dart:convert';
import 'package:http/http.dart' as http;

class DesignController {
  final String baseUrl = "http://192.168.1.6:3000/api/rnd"; // Sesuaikan dengan backend Anda.

  Future<void> submitDesign(
      {required String name,
        required String image,
        required String category,
        required String gender,
        required String status,
        required String soleMaterialId,
        required String bodyMaterialId}) async {
    try {
      // Insert ke tabel DESIGN
      final designResponse = await http.post(
        Uri.parse("$baseUrl/design"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": name,
          "image": image,
          "description": "Description placeholder", // Jika ada input deskripsi, sesuaikan
          "category": category,
          "gender": gender,
          "status": status,
        }),
      );

      if (designResponse.statusCode != 201) {
        throw Exception("Failed to insert design");
      }

      // Ambil ID design yang baru dibuat dari response backend
      final resDesign = await http.get(Uri.parse('http://192.168.1.6:3000/api/rnd/design'));
      final List<dynamic> allDesign = jsonDecode(resDesign.body);
      final designId = allDesign.length;
      print(designId);

      // Insert ke tabel DESIGN_MATERIALS
      final materials = [
        {"materialId": "1", "qty": 2}, // Tali Sepatu
        {"materialId": "2", "qty": 1}, // Lem 200 gr
      ];

      // Jika soleMaterialId == bodyMaterialId, tambahkan 1 material dengan qty 4
      if (bodyMaterialId == soleMaterialId) {
        materials.add({"materialId": soleMaterialId, "qty": 4});
      }
      else {
        // Jika beda, tambahkan 2 material masing-masing qty 2
        materials.add({"materialId": soleMaterialId, "qty": 2});
        materials.add({"materialId": bodyMaterialId, "qty": 2});
      }

      for (var material in materials) {
        final materialResponse = await http.post(
          Uri.parse("$baseUrl/design-material"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "designId": designId,
            "materialId": material["materialId"],
            "qty": material["qty"],
          }),
        );

        if (materialResponse.statusCode != 201) {
          throw Exception("Failed to insert design material");
        }
      }
    } catch (e) {
      throw Exception("Error submitting design: $e");
    }
  }
}
