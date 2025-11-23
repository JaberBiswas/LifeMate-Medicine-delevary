import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/medicine_model.dart';
import '../../providers/product_provider.dart';
import '../../services/firestore_data_service.dart';

class AdminProductsScreen extends StatefulWidget {
  static const String routeName = '/admin/products';

  const AdminProductsScreen({super.key});

  @override
  State<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends State<AdminProductsScreen> {
  final FirestoreDataService _data = FirestoreDataService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin • Products'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(),
        icon: const Icon(Icons.add),
        label: const Text('Add Product'),
      ),
      body: Consumer<ProductProvider>(
        builder: (context, provider, _) {
          final List<MedicineModel> list = provider.allMedicines;
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (list.isEmpty) {
            return const _EmptyState();
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            itemCount: list.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (BuildContext context, int index) {
              final MedicineModel product = list[index];
              return ListTile(
                leading: CircleAvatar(
                  child: Text(
                    product.name.isEmpty ? '?' : product.name[0].toUpperCase(),
                  ),
                ),
                title: Text(product.name.isEmpty ? 'Untitled' : product.name),
                subtitle: Text(
                  product.description.isEmpty ? 'No description' : product.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text('\$${product.price.toStringAsFixed(2)}'),
                    const SizedBox(width: 12),
                    IconButton(
                      tooltip: 'Edit',
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () => _openEditor(existing: product),
                    ),
                    IconButton(
                      tooltip: 'Delete',
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => _confirmDelete(product.id),
                    ),
                  ],
                ),
                onTap: () => _openDetails(product),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _openEditor({ MedicineModel? existing }) async {
    final _EditableProduct initial = existing == null
        ? _EditableProduct.empty()
        : _EditableProduct(
            id: existing.id,
            name: existing.name,
            description: existing.description,
            price: existing.price,
            category: existing.category,
          );
    final _EditableProduct? result = await showModalBottomSheet<_EditableProduct>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: _ProductEditor(initial: initial),
        );
      },
    );

    if (!mounted || result == null) return;

    if (existing == null) {
      final MedicineModel m = MedicineModel(
        id: result.id ?? '',
        name: result.name,
        description: result.description,
        price: result.price,
        discountPrice: 0,
        imageUrl: '',
        category: result.category ?? 'General',
        manufacturer: '',
        stock: 0,
        expiryDate: '',
        tags: const <String>[],
        isPrescriptionRequired: false,
        strength: '',
        rating: 0,
        reviewCount: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isActive: true,
      );
      await _data.addMedicine(m);
    } else {
      await _data.updateMedicine(existing.id, {
        'name': result.name,
        'description': result.description,
        'price': result.price,
        'category': result.category ?? existing.category,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    }
  }

  Future<void> _confirmDelete(String productId) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Delete product?'),
        content: const Text('This action cannot be undone.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (!mounted || confirmed != true) return;
    await _data.deleteMedicine(productId);
  }

  void _openDetails(MedicineModel product) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(product.name.isEmpty ? 'Untitled' : product.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Price: \$${product.price.toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            Text(product.description.isEmpty ? 'No description' : product.description),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.inventory_2_outlined, size: 64),
            SizedBox(height: 12),
            Text('No products yet'),
            SizedBox(height: 4),
            Text('Tap "Add Product" to create your first one.'),
          ],
        ),
      ),
    );
  }
}

class _ProductEditor extends StatefulWidget {
  final _EditableProduct initial;

  const _ProductEditor({required this.initial});

  @override
  State<_ProductEditor> createState() => _ProductEditorState();
}

class _ProductEditorState extends State<_ProductEditor> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initial.name);
    _descriptionController = TextEditingController(text: widget.initial.description);
    _priceController = TextEditingController(text: widget.initial.price.toStringAsFixed(2));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Row(
                children: <Widget>[
                  Icon(Icons.edit_outlined),
                  SizedBox(width: 8),
                  Text('Product Details'),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.next,
                validator: (String? value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Price',
                  prefixText: '\$',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (String? value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a price';
                  }
                  final double? parsed = double.tryParse(value.replaceAll(',', ''));
                  if (parsed == null || parsed < 0) {
                    return 'Enter a valid non-negative number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: <Widget>[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop<_EditableProduct>(null),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _onSave,
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;
    final double price = double.parse(_priceController.text.replaceAll(',', ''));
    final _EditableProduct product = _EditableProduct(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      price: price,
    );
    Navigator.of(context).pop<_EditableProduct>(product);
  }
}

class _EditableProduct {
  final String? id;
  final String name;
  final String description;
  final double price;
  final String? category;

  const _EditableProduct({
    this.id,
    required this.name,
    required this.description,
    required this.price,
    this.category,
  });

  factory _EditableProduct.empty() => const _EditableProduct(id: null, name: '', description: '', price: 0, category: null);

  _EditableProduct copy() => _EditableProduct(id: id, name: name, description: description, price: price, category: category);
}


