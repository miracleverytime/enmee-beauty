import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/product.dart';

class AddProductScreen extends StatefulWidget {
  final Product? product;
  const AddProductScreen({super.key, this.product});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _stockController = TextEditingController();
  final _buyPriceController = TextEditingController();
  final _sellPriceController = TextEditingController();
  String _selectedCategory = 'Serum';
  bool _isLoading = false;

  final List<String> _categories = [
    'Serum',
    'Moisturizer',
    'Sunscreen',
    'Cleanser',
    'Toner',
    'Essence',
    'Masker',
    'Eye Care',
    'Lip Care',
    'Exfoliator',
    'Primer',
    'Lainnya',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _nameController.text = widget.product!.name;
      _stockController.text = widget.product!.stock.toString();
      _buyPriceController.text = widget.product!.buyPrice.toString();
      _sellPriceController.text = widget.product!.sellPrice.toString();
      _selectedCategory = widget.product!.category;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _stockController.dispose();
    _buyPriceController.dispose();
    _sellPriceController.dispose();
    super.dispose();
  }

  String _calculateMargin() {
    final buyPrice = double.tryParse(_buyPriceController.text) ?? 0;
    final sellPrice = double.tryParse(_sellPriceController.text) ?? 0;
    final margin = sellPrice - buyPrice;
    final marginPercent = buyPrice > 0 ? (margin / buyPrice * 100) : 0;
    return 'Rp ${margin.toStringAsFixed(0)} - ${marginPercent.toStringAsFixed(0)}%';
  }

  void _showCategoryPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Text(
                  'PILIH KATEGORI',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.0,
                    color: Color(0xFF616161),
                  ),
                ),
              ),
              const Divider(height: 1, color: Color(0xFFE0E0E0)),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    final isSelected = category == _selectedCategory;
                    return InkWell(
                      onTap: () {
                        setState(() => _selectedCategory = category);
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              category,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                                color: const Color(0xFF212121),
                              ),
                            ),
                            if (isSelected)
                              const Icon(
                                Icons.check,
                                color: Color(0xFF212121),
                                size: 24,
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
        );
      },
    );
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final db = DatabaseHelper.instance;
      final product = Product(
        id: widget.product?.id,
        name: _nameController.text.trim(),
        category: _selectedCategory,
        stock: int.parse(_stockController.text),
        buyPrice: double.parse(_buyPriceController.text),
        sellPrice: double.parse(_sellPriceController.text),
        createdAt: widget.product?.createdAt ?? DateTime.now().toIso8601String(),
      );

      if (widget.product == null) {
        await db.insertProduct(product);
      } else {
        await db.updateProduct(product);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.product == null ? 'Produk berhasil ditambahkan' : 'Produk berhasil diperbarui'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan: $e'), backgroundColor: Colors.red),
        );
      }
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.product != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF212121)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEditing ? 'Edit Produk' : 'Tambah Produk',
          style: const TextStyle(
            color: Color(0xFF212121),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'INFORMASI PRODUK',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.0,
                        color: Color(0xFF616161),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Nama',
                            style: TextStyle(fontSize: 15, color: Color(0xFF424242)),
                          ),
                          Expanded(
                            child: TextFormField(
                              controller: _nameController,
                              textAlign: TextAlign.right,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Brightening Serum',
                                hintStyle: TextStyle(color: Color(0xFFBDBDBD)),
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                              style: const TextStyle(fontSize: 15, color: Color(0xFF424242)),
                              validator: (value) => value == null || value.trim().isEmpty ? 'Nama produk wajib diisi' : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: _showCategoryPicker,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                          const Text(
                            'Kategori',
                            style: TextStyle(fontSize: 15, color: Color(0xFF424242)),
                          ),
                            Row(
                              children: [
                                Text(
                                  _selectedCategory,
                                  style: const TextStyle(fontSize: 15, color: Color(0xFF212121)),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.keyboard_arrow_down, color: Color(0xFF212121), size: 20),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'STOK & HARGA',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.0,
                        color: Color(0xFF616161),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Stok',
                            style: TextStyle(fontSize: 15, color: Color(0xFF424242)),
                          ),
                          Expanded(
                            child: TextFormField(
                              controller: _stockController,
                              textAlign: TextAlign.right,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: '0',
                                hintStyle: TextStyle(color: Color(0xFFBDBDBD)),
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                              style: const TextStyle(fontSize: 15, color: Color(0xFF424242)),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) return 'Stok wajib diisi';
                                final stock = int.tryParse(value);
                                if (stock == null || stock < 0) return 'Masukkan angka yang valid';
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Harga beli',
                            style: TextStyle(fontSize: 15, color: Color(0xFF424242)),
                          ),
                          Expanded(
                            child: TextFormField(
                              controller: _buyPriceController,
                              textAlign: TextAlign.right,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: '0',
                                hintStyle: TextStyle(color: Color(0xFFBDBDBD)),
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                              style: const TextStyle(fontSize: 15, color: Color(0xFF424242)),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) return 'Harga beli wajib diisi';
                                if (double.tryParse(value) == null) return 'Masukkan angka yang valid';
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Harga jual',
                            style: TextStyle(fontSize: 15, color: Color(0xFF424242)),
                          ),
                          Expanded(
                            child: TextFormField(
                              controller: _sellPriceController,
                              textAlign: TextAlign.right,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: '0',
                                hintStyle: TextStyle(color: Color(0xFFBDBDBD)),
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                              style: const TextStyle(fontSize: 15, color: Color(0xFF424242)),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) return 'Harga jual wajib diisi';
                                if (double.tryParse(value) == null) return 'Masukkan angka yang valid';
                                final buyPrice = double.tryParse(_buyPriceController.text) ?? 0;
                                final sellPrice = double.tryParse(value) ?? 0;
                                if (sellPrice < buyPrice) return 'Harga jual harus >= harga beli';
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Margin per unit',
                            style: TextStyle(fontSize: 14, color: Color(0xFF424242)),
                          ),
                          Text(
                            _calculateMargin(),
                            style: const TextStyle(fontSize: 14, color: Color(0xFF212121), fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _saveProduct,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF9E9E9E),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: Text(
                        isEditing ? 'Simpan Perubahan' : 'Simpan Produk',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}