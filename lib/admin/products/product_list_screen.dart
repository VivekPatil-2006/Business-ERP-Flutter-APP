import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/theme/app_colors.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/loading_indicator.dart';
import '../shared/widgets/admin_drawer.dart';
import 'services/product_service.dart';
import 'product_detail_screen.dart';

class ProductListScreen extends StatelessWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AdminDrawer(currentRoute: '/products'),
      backgroundColor: AppColors.lightGrey,

      appBar: AppBar(
        backgroundColor: AppColors.navy,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Products',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.pushNamed(context, '/createProduct');
        },
      ),

      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: ProductService().getProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingIndicator(message: 'Loading products...');
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const EmptyState(
              title: 'No Products',
              message:
              'You haven’t added any products yet.\nTap + to create one.',
              icon: Icons.inventory_2_outlined,
            );
          }

          final products = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final doc = products[index];
              final data = doc.data();

              final pricing = data['pricing'] ?? {};

              return InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ProductDetailScreen(productId: doc.id),
                    ),
                  );
                },
                child: _ProductCard(
                  productId: doc.id,
                  title: data['title'] ?? '',
                  itemNo: data['itemNo'] ?? '',
                  price: pricing['totalPrice']?.toString() ?? '0',
                  stock: data['stock']?.toString() ?? '0',
                  active: data['active'] ?? false,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ================= PRODUCT CARD =================

class _ProductCard extends StatelessWidget {
  final String productId;
  final String title;
  final String itemNo;
  final String price;
  final String stock;
  final bool active;

  const _ProductCard({
    required this.productId,
    required this.title,
    required this.itemNo,
    required this.price,
    required this.stock,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.neonBlue.withOpacity(0.08),
            blurRadius: 16,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          // 📦 PRODUCT ICON
          CircleAvatar(
            radius: 26,
            backgroundColor: AppColors.primaryBlue.withOpacity(0.15),
            child: const Icon(
              Icons.inventory_2,
              color: AppColors.primaryBlue,
            ),
          ),

          const SizedBox(width: 14),

          // 📄 PRODUCT INFO
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.isEmpty ? 'Untitled Product' : title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.navy,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Item No: ${itemNo.isEmpty ? '-' : itemNo}',
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  '₹ $price  •  Stock: $stock',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          // 🔁 ACTIVE / INACTIVE TOGGLE
          Column(
            children: [
              Switch(
                value: active,
                activeColor: AppColors.primaryBlue,
                onChanged: (value) {
                  ProductService().toggleProductStatus(
                    productId: productId,
                    active: value,
                  );
                },
              ),
              Text(
                active ? 'ACTIVE' : 'INACTIVE',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: active ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
