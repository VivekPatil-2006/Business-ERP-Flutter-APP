import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/theme/app_colors.dart';
import '../../shared/widgets/loading_indicator.dart';
import 'services/product_service.dart';

class ProductDetailScreen extends StatelessWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      appBar: AppBar(
        title: const Text(
          'Product Details',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.navy,
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: ProductService().getProductById(productId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const LoadingIndicator(message: 'Loading product...');
          }

          final data = snapshot.data!.data();
          if (data == null) {
            return const Center(child: Text('Product not found'));
          }

          final pricing = data['pricing'] ?? {};
          final tax = data['tax'] ?? {};
          final payment = data['paymentTerms'] ?? {};
          final colour = data['colour'] ?? {};
          final specs = (data['specifications'] ?? []) as List;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [

                // 📦 PRODUCT INFO
                _card('Product Information', [
                  _row('Title', data['title']),
                  _row('Item No', data['itemNo']),
                  _row('Size', data['size']),
                  _row('Description', data['description'], multiline: true),
                  _row(
                    'Status',
                    data['active'] == true ? 'Active' : 'Inactive',
                  ),
                ]),

                const SizedBox(height: 16),

                // 🎨 COLOUR
                _card('Colour', [
                  _row(
                    'Colour Enabled',
                    colour['selectColour'] == true ? 'Yes' : 'No',
                  ),
                  _row('Colour Name', colour['colourName']),
                ]),

                const SizedBox(height: 16),

                // 💰 PRICING
                _card('Pricing', [
                  _row('Base Price', pricing['basePrice']?.toString()),
                  _row('Total Price', pricing['totalPrice']?.toString()),
                ]),

                const SizedBox(height: 16),

                // 🧾 TAX
                _card('Tax', [
                  _row('SGST', tax['sgst']?.toString()),
                  _row('CGST', tax['cgst']?.toString()),
                ]),

                const SizedBox(height: 16),

                // 💳 PAYMENT TERMS
                _card('Payment Terms', [
                  _row(
                    'Advance %',
                    payment['advancePaymentPercent']?.toString(),
                  ),
                  _row(
                    'Interim %',
                    payment['interimPaymentPercent']?.toString(),
                  ),
                  _row(
                    'Final %',
                    payment['finalPaymentPercent']?.toString(),
                  ),
                  _row(
                    'Total Payment',
                    payment['totalPayment']?.toString(),
                  ),
                ]),

                const SizedBox(height: 16),

                // 🚚 DELIVERY
                _card('Delivery', [
                  _row(
                    'Delivery Time',
                    '${data['deliveryTerms']} months',
                  ),
                ]),

                const SizedBox(height: 16),

                // 📋 SPECIFICATIONS
                _card(
                  'Specifications',
                  specs.isEmpty
                      ? [
                    const Text(
                      'No specifications added',
                      style: TextStyle(color: Colors.grey),
                    )
                  ]
                      : specs.map<Widget>((spec) {
                    return _row(
                      spec['name'],
                      spec['value'],
                    );
                  }).toList(),
                ),

                const SizedBox(height: 16),

                // 📦 STOCK
                _card('Stock & Discount', [
                  _row('Stock', data['stock']?.toString()),
                  _row(
                    'Discount %',
                    data['discountPercent']?.toString(),
                  ),
                ]),
              ],
            ),
          );
        },
      ),
    );
  }

  // ================= UI HELPERS =================

  Widget _card(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.navy.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.navy,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _row(
      String label,
      String? value, {
        bool multiline = false,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment:
        multiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          Expanded(
            child: Text(
              value == null || value.isEmpty ? '-' : value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: AppColors.navy,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
