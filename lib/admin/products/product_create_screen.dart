import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_text_field.dart';
import 'services/product_service.dart';

class ProductCreateScreen extends StatefulWidget {
  const ProductCreateScreen({super.key});

  @override
  State<ProductCreateScreen> createState() => _ProductCreateScreenState();
}

class _ProductCreateScreenState extends State<ProductCreateScreen> {
  final titleCtrl = TextEditingController();

  // ───────── CORE DATA ─────────
  String itemNo = '';
  String descriptionText = '';
  String size = '';

  Map<String, dynamic> colour = {};
  Map<String, dynamic> pricing = {};
  Map<String, dynamic> tax = {};
  Map<String, dynamic> paymentTerms = {};

  int deliveryMonths = 0;
  int stock = 0;
  double discountPercent = 0;

  List<Map<String, dynamic>> specifications = [];

  bool isLoading = false;

  // ================= CREATE PRODUCT =================
  Future<void> _createProduct() async {
    if (titleCtrl.text.isEmpty) return;

    setState(() => isLoading = true);

    final totalPrice =
        (pricing['basePrice'] ?? 0) + (tax['sgst'] ?? 0) + (tax['cgst'] ?? 0);

    final totalPayment =
        (paymentTerms['advancePaymentPercent'] ?? 0) +
            (paymentTerms['interimPaymentPercent'] ?? 0) +
            (paymentTerms['finalPaymentPercent'] ?? 0);

    await ProductService().createProduct({
      'title': titleCtrl.text.trim(),
      'itemNo': itemNo,
      'description': descriptionText,
      'size': size,
      'colour': colour,
      'pricing': {
        ...pricing,
        'totalPrice': totalPrice,
      },
      'tax': tax,
      'paymentTerms': {
        ...paymentTerms,
        'totalPayment': totalPayment,
      },
      'deliveryTerms': deliveryMonths,
      'specifications': specifications,
      'discountPercent': discountPercent,
      'stock': stock,
    });

    if (!mounted) return;
    Navigator.pop(context);
  }


  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: AppBar(
        title: const Text(
          'Create Product',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.navy,
        iconTheme: const IconThemeData(
          color: Colors.white, // back button color
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            AppTextField(
              controller: titleCtrl,
              label: 'Product Title',
            ),

            const SizedBox(height: 20),

            _card('Description', _descriptionSheet,
                subtitle: itemNo.isEmpty ? 'Not set' : itemNo),

            _card('Colour', _colourSheet,
                subtitle: colour['colourName'] ?? 'Not set'),

            _card('Pricing & Tax', _pricingSheet,
                subtitle: pricing.isEmpty ? 'Not set' : 'Configured'),

            _card('Payment Terms', _paymentSheet,
                subtitle: paymentTerms.isEmpty ? 'Not set' : 'Configured'),

            _card('Delivery Terms', _deliverySheet,
                subtitle: deliveryMonths == 0
                    ? 'Not set'
                    : '$deliveryMonths months'),

            _card('Specifications', _specificationsSheet,
                subtitle: '${specifications.length} added'),

            _card('Stock & Discount', _stockSheet,
                subtitle: stock == 0 ? 'Not set' : 'Configured'),

            const SizedBox(height: 30),

            AppButton(
              label: 'Create Product',
              isLoading: isLoading,
              onPressed: _createProduct,
            ),
          ],
        ),
      ),
    );
  }

  // ================= CARD =================
  Widget _card(String title, VoidCallback onTap, {String? subtitle}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        title: Text(title,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: AppColors.navy)),
        subtitle:
        subtitle != null ? Text(subtitle) : const SizedBox.shrink(),
        trailing:
        const Icon(Icons.chevron_right, color: AppColors.primaryBlue),
        onTap: onTap,
      ),
    );
  }

  // ================= BOTTOM SHEET =================
  void _sheet(String title, Widget child) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        final height = MediaQuery.of(context).size.height * 0.6; // 👈 3/5th

        return Container(
          height: height,
          padding: EdgeInsets.fromLTRB(
            20,
            12,
            20,
            MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔹 DRAG HANDLE
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),

              // 🔹 TITLE
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.navy,
                ),
              ),

              const SizedBox(height: 16),

              // 🔹 CONTENT (SCROLLABLE)
              Expanded(
                child: SingleChildScrollView(
                  child: child,
                ),
              ),
            ],
          ),
        );
      },
    );
  }


  // ================= SHEETS =================

  void _descriptionSheet() {
    final itemCtrl = TextEditingController(text: itemNo);
    final descCtrl = TextEditingController(text: descriptionText);
    final sizeCtrl = TextEditingController(text: size);

    _sheet(
      'Product Description',
      Column(
        children: [
          AppTextField(controller: itemCtrl, label: 'Item No'),
          const SizedBox(height: 12),
          AppTextField(controller: descCtrl, label: 'Description'),
          const SizedBox(height: 12),
          AppTextField(controller: sizeCtrl, label: 'Size'),
          const SizedBox(height: 20),
          AppButton(
            label: 'Save',
            onPressed: () {
              setState(() {
                itemNo = itemCtrl.text;
                descriptionText = descCtrl.text;
                size = sizeCtrl.text;
              });
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _colourSheet() {
    final nameCtrl =
    TextEditingController(text: colour['colourName']);
    bool selected = colour['selectColour'] ?? false;

    _sheet(
      'Colour',
      Column(
        children: [
          SwitchListTile(
            value: selected,
            title: const Text('Select Colour'),
            onChanged: (v) => setState(() => selected = v),
          ),
          const SizedBox(height: 12),
          AppTextField(controller: nameCtrl, label: 'Colour Name'),
          const SizedBox(height: 20),
          AppButton(
            label: 'Save',
            onPressed: () {
              setState(() {
                colour = {
                  'selectColour': selected,
                  'colourName': nameCtrl.text,
                };
              });
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _pricingSheet() {
    final baseCtrl =
    TextEditingController(text: pricing['basePrice']?.toString());
    final sgstCtrl =
    TextEditingController(text: tax['sgst']?.toString());
    final cgstCtrl =
    TextEditingController(text: tax['cgst']?.toString());

    _sheet(
      'Pricing & Tax',
      Column(
        children: [
          AppTextField(controller: baseCtrl, label: 'Base Price'),
          const SizedBox(height: 12),
          AppTextField(controller: sgstCtrl, label: 'SGST'),
          const SizedBox(height: 12),
          AppTextField(controller: cgstCtrl, label: 'CGST'),
          const SizedBox(height: 20),
          AppButton(
            label: 'Save',
            onPressed: () {
              setState(() {
                pricing = {
                  'basePrice': double.tryParse(baseCtrl.text) ?? 0,
                };
                tax = {
                  'sgst': double.tryParse(sgstCtrl.text) ?? 0,
                  'cgst': double.tryParse(cgstCtrl.text) ?? 0,
                };
              });
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _paymentSheet() {
    final advCtrl = TextEditingController(
        text: paymentTerms['advancePaymentPercent']?.toString());
    final intCtrl = TextEditingController(
        text: paymentTerms['interimPaymentPercent']?.toString());
    final finCtrl = TextEditingController(
        text: paymentTerms['finalPaymentPercent']?.toString());

    _sheet(
      'Payment Terms',
      Column(
        children: [
          AppTextField(controller: advCtrl, label: 'Advance %'),
          const SizedBox(height: 12),
          AppTextField(controller: intCtrl, label: 'Interim %'),
          const SizedBox(height: 12),
          AppTextField(controller: finCtrl, label: 'Final %'),
          const SizedBox(height: 20),
          AppButton(
            label: 'Save',
            onPressed: () {
              setState(() {
                paymentTerms = {
                  'advancePaymentPercent':
                  double.tryParse(advCtrl.text) ?? 0,
                  'interimPaymentPercent':
                  double.tryParse(intCtrl.text) ?? 0,
                  'finalPaymentPercent':
                  double.tryParse(finCtrl.text) ?? 0,
                };
              });
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _deliverySheet() {
    final ctrl = TextEditingController(text: deliveryMonths.toString());

    _sheet(
      'Delivery Terms',
      Column(
        children: [
          AppTextField(controller: ctrl, label: 'Delivery (days)'),
          const SizedBox(height: 20),
          AppButton(
            label: 'Save',
            onPressed: () {
              setState(() {
                deliveryMonths = int.tryParse(ctrl.text) ?? 0;
              });
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _stockSheet() {
    final stockCtrl = TextEditingController(text: stock.toString());
    final discCtrl =
    TextEditingController(text: discountPercent.toString());

    _sheet(
      'Stock & Discount',
      Column(
        children: [
          AppTextField(controller: stockCtrl, label: 'Stock'),
          const SizedBox(height: 12),
          AppTextField(controller: discCtrl, label: 'Discount %'),
          const SizedBox(height: 20),
          AppButton(
            label: 'Save',
            onPressed: () {
              setState(() {
                stock = int.tryParse(stockCtrl.text) ?? 0;
                discountPercent =
                    double.tryParse(discCtrl.text) ?? 0;
              });
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _specificationsSheet() {
    final nameCtrl = TextEditingController();
    final valueCtrl = TextEditingController();

    _sheet(
      'Specifications',
      StatefulBuilder(
        builder: (context, setModal) {
          return Column(
            children: [
              ...specifications.map((spec) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.lightGrey,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                        child:
                        Text('${spec['name']} : ${spec['value']}')),
                    IconButton(
                      icon: const Icon(Icons.remove_circle,
                          color: Colors.red),
                      onPressed: () {
                        setState(() =>
                            specifications.remove(spec));
                        setModal(() {});
                      },
                    ),
                  ],
                ),
              )),
              AppTextField(controller: nameCtrl, label: 'Spec Name'),
              const SizedBox(height: 12),
              AppTextField(controller: valueCtrl, label: 'Spec Value'),
              const SizedBox(height: 14),
              AppButton(
                label: 'Add Specification',
                onPressed: () {
                  if (nameCtrl.text.isEmpty ||
                      valueCtrl.text.isEmpty) return;
                  setState(() {
                    specifications.add({
                      'name': nameCtrl.text,
                      'value': valueCtrl.text,
                    });
                  });
                  nameCtrl.clear();
                  valueCtrl.clear();
                  setModal(() {});
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
