import 'package:flutter/material.dart';

class Navbar extends StatelessWidget implements PreferredSizeWidget {
  final bool isSearching;
  final Function(String) onSearchChanged;
  final Function(String) onSearchSubmitted;
  final Function() onToggleSearch;
  final Function() onCartPressed;
  final Function() onHistoryPressed;

  const Navbar({
    Key? key,
    required this.isSearching,
    required this.onSearchChanged,
    required this.onSearchSubmitted, // Ditambahkan untuk menangani logika pencarian saat Enter ditekan
    required this.onToggleSearch,
    required this.onCartPressed,
    required this.onHistoryPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      toolbarHeight: 60, // Tinggi AppBar
      title: Row(
        children: [
          // Logo di kiri
          Image.asset(
            'assets/logoSteppa.png',
            height: 60, // Ukuran logo
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 10),
          const Spacer(), // Spacer untuk memberikan jarak dinamis
          // Kotak Pencarian
          Container(
            width: MediaQuery.of(context).size.width * 0.4, // Lebar lebih pendek
            height: 40, // Tinggi kotak pencarian
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20), // Border melengkung
              border: Border.all(color: Colors.grey),
            ),
            child: Row(
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 8, right: 5),
                  child: Icon(Icons.search, color: Colors.blue, size: 18),
                ),
                Expanded(
                  child: TextField(
                    onChanged: onSearchChanged, // Tetap dipertahankan untuk interaksi langsung
                    onSubmitted: (value) {
                      if (value.trim().isNotEmpty) {
                        onSearchSubmitted(value); // Menjalankan pencarian saat Enter ditekan
                      }
                    },
                    decoration: const InputDecoration(
                      hintText: 'Cari produk...',
                      border: InputBorder.none,
                      hintStyle: TextStyle(fontSize: 15, color: Colors.grey),
                      contentPadding: EdgeInsets.symmetric(vertical: 14), // Vertikal teks di tengah
                    ),
                    style: const TextStyle(fontSize: 15, color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(), // Spacer untuk memastikan elemen tetap di tengah
        ],
      ),
      actions: [
        // Ikon profil
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.person_outline, color: Colors.blue),
          iconSize: 25,
        ),
        // Ikon keranjang
        IconButton(
          onPressed: onCartPressed,
          icon: const Icon(Icons.shopping_cart_outlined, color: Colors.blue),
          iconSize: 25,
        ),
        IconButton(
          onPressed: onHistoryPressed,
          icon: const Icon(Icons.history, color: Colors.blue),
          iconSize: 25,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60); // Tinggi AppBar
}
