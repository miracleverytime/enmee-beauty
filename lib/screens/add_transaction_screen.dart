import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/product.dart';
import '../models/transaction.dart' as model;
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../utils/app_toast.dart';

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
        AppToast.error(
          context,
          title: 'Gagal Memuat Produk',
          description: '$e',
        );
      }
    }
    setState(() => _isLoading = false);
  }

  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedProduct == null) {
      AppToast.warning(
        context,
        title: 'Pilih Produk',
        description: 'Silakan pilih produk terlebih dahulu',
      );
      return;
    }

    final quantity = int.parse(_quantityController.text);
    if (quantity > _selectedProduct!.stock) {
      AppToast.error(
        context,
        title: 'Stok Tidak Cukup',
        description: 'Stok tersedia saat ini: ${_selectedProduct!.stock} pcs',
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
        AppToast.success(
          context,
          title: 'Transaksi Berhasil Disimpan',
          description: '${_selectedProduct!.name} ($quantity pcs)',
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        AppToast.error(
          context,
          title: 'Gagal Menyimpan Transaksi',
          description: '$e',
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
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        backgroundColor: context.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Tambah Transaksi',
          style: TextStyle(
            color: context.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _isSaving
              ? const Center(child: CircularProgressIndicator())
              : SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: context.secondaryColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'DETAIL PENJUALAN',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: context.textSecondary,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _buildDetailRow('Produk', _selectedProduct?.name ?? '', true),
                                const SizedBox(height: 12),
                                _buildDetailRow('Harga satuan', _selectedProduct != null ? Formatters.currencyRp(_selectedProduct!.sellPrice) : '', false),
                                const SizedBox(height: 12),
                                _buildDetailRow('Jumlah', _quantityController.text, false, isQuantity: true),
                                if (_selectedProduct != null) ...[
                                  const SizedBox(height: 8),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      'Sisa stok ${_selectedProduct!.stock} unit',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: context.textSecondary,
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
                            color: context.secondaryColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'TOTAL HARGA',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: context.textSecondary,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  Text(
                                    Formatters.currencyRp(totalPrice),
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: context.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Estimasi profit',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: context.textSecondary,
                                    ),
                                  ),
                                  Text(
                                    '+${Formatters.currencyRp(profit)}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: context.successColor,
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
                                backgroundColor: context.primaryColor,
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
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: context.textSecondary,
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
                hint: Text(
                  'Pilih produk',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: context.textMuted,
                  ),
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                ),
                isExpanded: true,
                alignment: Alignment.centerRight,
                dropdownColor: context.surfaceColor,
                icon: Icon(Icons.keyboard_arrow_down, color: context.textPrimary),
                items: _products.map((product) {
                  return DropdownMenuItem(
                    value: product,
                    alignment: Alignment.centerRight,
                    child: Text(
                      product.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: context.textPrimary,
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
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: context.textPrimary,
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
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: context.textPrimary,
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
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: context.textPrimary,
                ),
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }
}