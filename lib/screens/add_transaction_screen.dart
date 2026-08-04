import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/product.dart';
import '../models/transaction.dart' as model;

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final DatabaseHelper _db = DatabaseHelper.instance;
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController(text: '1');
  
  List<Product> _products = [];
  Product? _selectedProduct;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    try {
      final products = await _db.getAllProducts();
      setState(() => _products = products);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat produk: $e'), backgroundColor: Colors.red),
        );
      }
    }
    setState(() => _isLoading = false);
  }

  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedProduct == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih produk terlebih dahulu'), backgroundColor: Colors.orange),
      );
      return;
    }

    final quantity = int.parse(_quantityController.text);
    if (quantity > _selectedProduct!.stock) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Stok tidak cukup! Stok tersedia: ${_selectedProduct!.stock}'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final transaction = model.Transaction(
        productId: _selectedProduct!.id!,
        quantity: quantity,
        totalPrice: _selectedProduct!.sellPrice * quantity,
        date: DateTime.now().toIso8601String(),
      );

      await _db.insertTransaction(transaction);
      await _db.updateProductStock(_selectedProduct!.id!, _selectedProduct!.stock - quantity);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaksi berhasil disimpan'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan transaksi: $e'), backgroundColor: Colors.red),
        );
      }
    }
    setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    final totalPrice = _selectedProduct != null && _quantityController.text.isNotEmpty
        ? _selectedProduct!.sellPrice * (int.tryParse(_quantityController.text) ?? 0)
        : 0.0;
    
    final profit = _selectedProduct != null && _quantityController.text.isNotEmpty
        ? (_selectedProduct!.sellPrice - _selectedProduct!.buyPrice) * (int.tryParse(_quantityController.text) ?? 0)
        : 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '< Kembali',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF757575),
            fontWeight: FontWeight.normal,
          ),
        ),
        titleSpacing: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _isSaving
              ? const Center(child: CircularProgressIndicator())
              : SafeArea(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                          color: Colors.white,
                          child: const Text(
                            'Tambah Transaksi',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'DETAIL PENJUALAN',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF757575),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _buildDetailRow('Produk', _selectedProduct?.name ?? '', true),
                                const SizedBox(height: 12),
                                _buildDetailRow('Harga satuan', _selectedProduct != null ? 'Rp ${_formatCurrency(_selectedProduct!.sellPrice)}' : '', false),
                                const SizedBox(height: 12),
                                _buildDetailRow('Jumlah', _quantityController.text, false, isQuantity: true),
                                if (_selectedProduct != null) ...[
                                  const SizedBox(height: 8),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      'Sisa stok ${_selectedProduct!.stock} unit',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF757575),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'TOTAL HARGA',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF757575),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  Text(
                                    'Rp ${_formatCurrency(totalPrice)}',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Estimasi profit',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF757575),
                                    ),
                                  ),
                                  Text(
                                    'Rp ${_formatCurrency(profit)}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: _saveTransaction,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                'Simpan Transaksi',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildDetailRow(String label, String value, bool isDropdown, {bool isQuantity = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF757575),
            ),
          ),
          if (isDropdown)
            Expanded(
              child: DropdownButtonFormField<Product>(
                value: _selectedProduct,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                ),
                hint: const Text(
                  'Pilih produk',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                ),
                isExpanded: true,
                alignment: Alignment.centerRight,
                items: _products.map((product) {
                  return DropdownMenuItem(
                    value: product,
                    alignment: Alignment.centerRight,
                    child: Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedProduct = value),
                validator: (value) => value == null ? 'Pilih produk' : null,
                selectedItemBuilder: (BuildContext context) {
                  return _products.map<Widget>((Product product) {
                    return Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.right,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList();
                },
              ),
            )
          else if (isQuantity)
            SizedBox(
              width: 60,
              child: TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                ),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
                textAlign: TextAlign.right,
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Wajib diisi';
                  final qty = int.tryParse(value);
                  if (qty == null || qty <= 0) return 'Tidak valid';
                  if (_selectedProduct != null && qty > _selectedProduct!.stock) {
                    return 'Stok max: ${_selectedProduct!.stock}';
                  }
                  return null;
                },
              ),
            )
          else
            Flexible(
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }

  String _formatCurrency(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }
}