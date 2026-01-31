import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/theme/app_colors.dart';
import '../../shared/widgets/loading_indicator.dart';
import 'services/product_service.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  // ===== EDIT FLAGS =====
  bool editProductInfo = false;
  bool editPricing = false;
  bool editColour = false;
  bool editTax = false;
  bool editPayment = false;
  bool editDelivery = false;
  bool editStock = false;

  // ===== CONTROLLERS =====
  final _titleCtrl = TextEditingController();
  final _itemNoCtrl = TextEditingController();
  final _sizeCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  final _basePriceCtrl = TextEditingController();
  final _totalPriceCtrl = TextEditingController();

  final _colourNameCtrl = TextEditingController();

  final _sgstCtrl = TextEditingController();
  final _cgstCtrl = TextEditingController();

  final _advanceCtrl = TextEditingController();
  final _interimCtrl = TextEditingController();
  final _finalCtrl = TextEditingController();

  final _deliveryCtrl = TextEditingController();

  final _stockCtrl = TextEditingController();
  final _discountCtrl = TextEditingController();

  bool editSpecs = false;

  List<TextEditingController> specNameCtrls = [];
  List<TextEditingController> specValueCtrls = [];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _itemNoCtrl.dispose();
    _sizeCtrl.dispose();
    _descCtrl.dispose();
    _basePriceCtrl.dispose();
    _totalPriceCtrl.dispose();
    _colourNameCtrl.dispose();
    _sgstCtrl.dispose();
    _cgstCtrl.dispose();
    _advanceCtrl.dispose();
    _interimCtrl.dispose();
    _finalCtrl.dispose();
    _deliveryCtrl.dispose();
    _stockCtrl.dispose();
    _discountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      appBar: AppBar(
        title: const Text(
          'Product Details',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600, // 👈 add weight here
          ),
        ),
        backgroundColor: AppColors.navy,
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: ProductService().getProductById(widget.productId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const LoadingIndicator(message: 'Loading product...');
          }

          final data = snapshot.data!.data();
          if (data == null) {
            return const Center(child: Text('Product not found'));
          }
          final specs = (data['specifications'] ?? []) as List;
          if (specNameCtrls.isEmpty && specs.isNotEmpty) {
            for (final spec in specs) {
              specNameCtrls.add(TextEditingController(text: spec['name']));
              specValueCtrls.add(TextEditingController(text: spec['value']));
            }
          }

          final pricing = data['pricing'] ?? {};
          final tax = data['tax'] ?? {};
          final payment = data['paymentTerms'] ?? {};
          final colour = data['colour'] ?? {};

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [

                // ================= PRODUCT INFO =================
                _card(
                  'Product Information',
                  actions: _editActions(
                    editProductInfo,
                        () => setState(() => editProductInfo = !editProductInfo),
                        () async {
                      await ProductService().updateProduct(
                        widget.productId,
                        {
                          'title': _titleCtrl.text,
                          'itemNo': _itemNoCtrl.text,
                          'size': _sizeCtrl.text,
                          'description': _descCtrl.text,
                        },
                      );
                      setState(() => editProductInfo = false);
                    },
                  ),
                  children: [
                    _editableRow('Title', _titleCtrl, data['title'], editProductInfo),
                    _editableRow('Item No', _itemNoCtrl, data['itemNo'], editProductInfo),
                    _editableRow('Size', _sizeCtrl, data['size'], editProductInfo),
                    _editableRow('Description', _descCtrl, data['description'], editProductInfo, multiline: true),
                  ],
                ),

                const SizedBox(height: 16),

                // ================= COLOUR =================
                _card(
                  'Colour',
                  actions: _editActions(
                    editColour,
                        () => setState(() => editColour = !editColour),
                        () async {
                      await ProductService().updateProduct(
                        widget.productId,
                        {
                          'colour.colourName': _colourNameCtrl.text,
                        },
                      );
                      setState(() => editColour = false);
                    },
                  ),
                  children: [
                    _editableRow('Colour Name', _colourNameCtrl, colour['colourName'], editColour),
                  ],
                ),

                const SizedBox(height: 16),

                // ================= PRICING =================
                _card(
                  'Pricing',
                  actions: _editActions(
                    editPricing,
                        () => setState(() => editPricing = !editPricing),
                        () async {
                      await ProductService().updateProduct(
                        widget.productId,
                        {
                          'pricing.basePrice': int.tryParse(_basePriceCtrl.text),
                          'pricing.totalPrice': int.tryParse(_totalPriceCtrl.text),
                        },
                      );
                      setState(() => editPricing = false);
                    },
                  ),
                  children: [
                    _editableRow('Base Price', _basePriceCtrl, pricing['basePrice']?.toString(), editPricing),
                    _editableRow('Total Price', _totalPriceCtrl, pricing['totalPrice']?.toString(), editPricing),
                  ],
                ),

                const SizedBox(height: 16),

                // ================= TAX =================
                _card(
                  'Tax',
                  actions: _editActions(
                    editTax,
                        () => setState(() => editTax = !editTax),
                        () async {
                      await ProductService().updateProduct(
                        widget.productId,
                        {
                          'tax.sgst': int.tryParse(_sgstCtrl.text),
                          'tax.cgst': int.tryParse(_cgstCtrl.text),
                        },
                      );
                      setState(() => editTax = false);
                    },
                  ),
                  children: [
                    _editableRow('SGST', _sgstCtrl, tax['sgst']?.toString(), editTax),
                    _editableRow('CGST', _cgstCtrl, tax['cgst']?.toString(), editTax),
                  ],
                ),

                const SizedBox(height: 16),

                // ================= PAYMENT TERMS =================
                _card(
                  'Payment Terms',
                  actions: _editActions(
                    editPayment,
                        () => setState(() => editPayment = !editPayment),
                        () async {
                      await ProductService().updateProduct(
                        widget.productId,
                        {
                          'paymentTerms.advancePaymentPercent': int.tryParse(_advanceCtrl.text),
                          'paymentTerms.interimPaymentPercent': int.tryParse(_interimCtrl.text),
                          'paymentTerms.finalPaymentPercent': int.tryParse(_finalCtrl.text),
                        },
                      );
                      setState(() => editPayment = false);
                    },
                  ),
                  children: [
                    _editableRow('Advance %', _advanceCtrl, payment['advancePaymentPercent']?.toString(), editPayment),
                    _editableRow('Interim %', _interimCtrl, payment['interimPaymentPercent']?.toString(), editPayment),
                    _editableRow('Final %', _finalCtrl, payment['finalPaymentPercent']?.toString(), editPayment),
                  ],
                ),

                const SizedBox(height: 16),

                // ================= DELIVERY =================
                _card(
                  'Delivery',
                  actions: _editActions(
                    editDelivery,
                        () => setState(() => editDelivery = !editDelivery),
                        () async {
                      await ProductService().updateProduct(
                        widget.productId,
                        {
                          'deliveryTerms': int.tryParse(_deliveryCtrl.text),
                        },
                      );
                      setState(() => editDelivery = false);
                    },
                  ),
                  children: [
                    _editableRow('Delivery (days)', _deliveryCtrl, data['deliveryTerms']?.toString(), editDelivery),
                  ],
                ),

                const SizedBox(height: 16),


                _card(
                  'Specifications',
                  actions: _editActions(
                    editSpecs,
                        () => setState(() => editSpecs = !editSpecs),
                        () async {
                      final updatedSpecs = List.generate(specNameCtrls.length, (i) {
                        return {
                          'name': specNameCtrls[i].text,
                          'value': specValueCtrls[i].text,
                        };
                      });

                      await ProductService().updateProduct(
                        widget.productId,
                        {
                          'specifications': updatedSpecs,
                        },
                      );

                      setState(() => editSpecs = false);
                    },
                  ),
                  children: [
                    if (specNameCtrls.isEmpty)
                      const Text(
                        'No specifications added',
                        style: TextStyle(color: Colors.grey),
                      ),

                    ...List.generate(specNameCtrls.length, (index) {
                      return Row(
                        children: [
                          Expanded(
                            child: editSpecs
                                ? TextFormField(
                              controller: specNameCtrls[index],
                              decoration: const InputDecoration(
                                labelText: 'Name',
                                isDense: true,
                              ),
                            )
                                : Text(
                              specNameCtrls[index].text,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                color: AppColors.navy,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: editSpecs
                                ? TextFormField(
                              controller: specValueCtrls[index],
                              decoration: const InputDecoration(
                                labelText: 'Value',
                                isDense: true,
                              ),
                            )
                                : Text(
                              specValueCtrls[index].text,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                color: AppColors.navy,
                              ),
                            ),
                          ),
                          if (editSpecs)
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  specNameCtrls.removeAt(index);
                                  specValueCtrls.removeAt(index);
                                });
                              },
                            ),
                        ],
                      );
                    }),

                    if (editSpecs)
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            specNameCtrls.add(TextEditingController());
                            specValueCtrls.add(TextEditingController());
                          });
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add Specification'),
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                // ================= STOCK =================
                _card(
                  'Stock & Discount',
                  actions: _editActions(
                    editStock,
                        () => setState(() => editStock = !editStock),
                        () async {
                      await ProductService().updateProduct(
                        widget.productId,
                        {
                          'stock': int.tryParse(_stockCtrl.text),
                          'discountPercent': int.tryParse(_discountCtrl.text),
                        },
                      );
                      setState(() => editStock = false);
                    },
                  ),
                  children: [
                    _editableRow('Stock', _stockCtrl, data['stock']?.toString(), editStock),
                    _editableRow('Discount %', _discountCtrl, data['discountPercent']?.toString(), editStock),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ================= HELPERS =================

  List<Widget> _editActions(bool editing, VoidCallback toggle, VoidCallback save) {
    return [
      IconButton(icon: Icon(editing ? Icons.close : Icons.edit), onPressed: toggle),
      if (editing)
        IconButton(icon: const Icon(Icons.save), onPressed: save),
    ];
  }

  Widget _card(String title, {List<Widget>? actions, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.navy.withOpacity(0.25)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.navy)),
          if (actions != null) Row(children: actions),
        ]),
        const SizedBox(height: 14),
        ...children,
      ]),
    );
  }

  Widget _editableRow(String label, TextEditingController ctrl, String? value, bool edit,
      {bool multiline = false}) {
    ctrl.text = ctrl.text.isEmpty ? (value ?? '') : ctrl.text;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(width: 150, child: Text(label, style: const TextStyle(color: Colors.grey))),
          Expanded(
            child: edit
                ? TextFormField(
              controller: ctrl,
              maxLines: multiline ? 3 : 1,
              decoration: const InputDecoration(isDense: true, border: OutlineInputBorder()),
            )
                : Text(value == null || value.isEmpty ? '-' : value,
                style: const TextStyle(fontWeight: FontWeight.w500, color: AppColors.navy)),
          ),
        ],
      ),
    );
  }
}
