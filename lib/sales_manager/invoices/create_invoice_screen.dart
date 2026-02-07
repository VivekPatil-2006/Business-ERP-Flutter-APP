// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:intl/intl.dart';
//
// import '../../core/theme/app_colors.dart';
// import '../../core/models/invoice_model.dart';
//
// class CreateInvoiceScreen extends StatefulWidget {
//   const CreateInvoiceScreen({super.key});
//
//   @override
//   State<CreateInvoiceScreen> createState() => _CreateInvoiceScreenState();
// }
//
// class _CreateInvoiceScreenState extends State<CreateInvoiceScreen> {
//
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//
//   String? companyId;
//   String? selectedClientId;
//   String clientAddress = "";
//
//   final descriptionCtrl = TextEditingController();
//   final notesCtrl = TextEditingController();
//
//   DateTime selectedDate = DateTime.now();
//   List<InvoiceItem> invoiceItems = [];
//
//   double grandTotal = 0;
//   bool saving = false;
//
//   // =====================================================
//   // INIT
//   // =====================================================
//
//   @override
//   void initState() {
//     super.initState();
//     loadSalesManagerCompany();
//   }
//
//   // =====================================================
//   // LOAD COMPANY
//   // =====================================================
//
//   Future<void> loadSalesManagerCompany() async {
//
//     final uid = _auth.currentUser!.uid;
//
//     final doc =
//     await _firestore.collection("sales_managers").doc(uid).get();
//
//     if (doc.exists) {
//       companyId = doc['companyId'];
//       if (mounted) setState(() {});
//     }
//   }
//
//   // =====================================================
//   // FETCH CLIENTS
//   // =====================================================
//
//   Future<List<QueryDocumentSnapshot>> fetchClients() async {
//
//     if (companyId == null) return [];
//
//     final snap = await _firestore
//         .collection('clients')
//         .where("companyId", isEqualTo: companyId)
//         .get();
//
//     return snap.docs;
//   }
//
//   // =====================================================
//   // FETCH PRODUCTS
//   // =====================================================
//
//   Future<List<QueryDocumentSnapshot>> fetchProducts() async {
//
//     if (companyId == null) return [];
//
//     final snap = await _firestore
//         .collection('products')
//         .where("companyId", isEqualTo: companyId)
//         .get();
//
//     return snap.docs;
//   }
//
//   // =====================================================
//   // TOTAL CALCULATION
//   // =====================================================
//
//   void calculateGrandTotal() {
//
//     double total = 0;
//
//     for (var item in invoiceItems) {
//       total += item.totalAmount;
//     }
//
//     setState(() => grandTotal = total);
//   }
//
//   // =====================================================
//   // SAVE INVOICE
//   // =====================================================
//
//   Future<void> saveInvoice() async {
//
//     if (selectedClientId == null) {
//       showMsg("Select customer");
//       return;
//     }
//
//     if (invoiceItems.isEmpty) {
//       showMsg("Add at least one product");
//       return;
//     }
//
//     try {
//
//       setState(() => saving = true);
//
//       final invoiceNumber =
//           "INV-${DateTime.now().millisecondsSinceEpoch}";
//
//       await _firestore.collection('invoices').add({
//
//         "companyId": companyId,
//         "clientId": selectedClientId,
//
//         "invoiceNumber": invoiceNumber,
//         "description": descriptionCtrl.text.trim(),
//
//         "date": Timestamp.fromDate(selectedDate),
//         "notes": notesCtrl.text.trim(),
//
//         "totalAmount": grandTotal,
//
//         "items": invoiceItems.map((e) => e.toMap()).toList(),
//
//         "paymentStatus": "unpaid",
//
//         "pdfUrl": "",
//
//         "createdAt": Timestamp.now(),
//       });
//
//       showMsg("Invoice Created Successfully");
//       Navigator.pop(context);
//
//     } catch (e) {
//
//       debugPrint("Invoice Save Error => $e");
//       showMsg("Error Saving Invoice");
//
//     } finally {
//
//       if (mounted) {
//         setState(() => saving = false);
//       }
//     }
//   }
//
//   void showMsg(String msg) {
//     ScaffoldMessenger.of(context)
//         .showSnackBar(SnackBar(content: Text(msg)));
//   }
//
//   // =====================================================
//   // UI
//   // =====================================================
//
//   @override
//   Widget build(BuildContext context) {
//
//     return Scaffold(
//
//       appBar: AppBar(
//         title: const Text(
//           "Create Invoice",
//           style: TextStyle(
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//           ),
//         ),
//         backgroundColor: AppColors.darkBlue,
//         foregroundColor: Colors.white,
//       ),
//
//
//       body: companyId == null
//
//           ? const Center(child: CircularProgressIndicator())
//
//           : SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//
//             buildClientDropdown(),
//
//             const SizedBox(height: 10),
//
//             Text("Address: $clientAddress"),
//
//             const SizedBox(height: 15),
//
//             buildDatePicker(),
//
//             const SizedBox(height: 15),
//
//             TextField(
//               controller: descriptionCtrl,
//               decoration: const InputDecoration(
//                 labelText: "Invoice Description",
//                 border: OutlineInputBorder(),
//               ),
//             ),
//
//             const SizedBox(height: 20),
//
//             buildItemSection(),
//
//             const SizedBox(height: 20),
//
//             TextField(
//               controller: notesCtrl,
//               decoration: const InputDecoration(
//                 labelText: "Notes",
//                 border: OutlineInputBorder(),
//               ),
//             ),
//
//             const SizedBox(height: 20),
//
//             Card(
//               child: Padding(
//                 padding: const EdgeInsets.all(12),
//                 child: Text(
//                   "Grand Total : ₹ ${grandTotal.toStringAsFixed(2)}",
//                   style: const TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 18),
//                 ),
//               ),
//             ),
//
//             const SizedBox(height: 20),
//
//             SizedBox(
//               width: double.infinity,
//
//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppColors.darkBlue,
//                   padding: const EdgeInsets.all(14),
//                 ),
//
//                 onPressed: saving ? null : saveInvoice,
//
//                 child: saving
//                     ? const CircularProgressIndicator(
//                   color: Colors.white,
//                 )
//                     : const Text(
//                   "SAVE INVOICE",
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // =====================================================
//   // CLIENT DROPDOWN
//   // =====================================================
//
//   Widget buildClientDropdown() {
//
//     return FutureBuilder(
//       future: fetchClients(),
//
//       builder: (context, snapshot) {
//
//         if (!snapshot.hasData) {
//           return const LinearProgressIndicator();
//         }
//
//         final clients = snapshot.data!;
//
//         if (clients.isEmpty) {
//           return const Text("No clients available");
//         }
//
//         return DropdownButtonFormField(
//
//           hint: const Text("Select Customer"),
//
//           decoration: const InputDecoration(
//             border: OutlineInputBorder(),
//           ),
//
//           items: clients.map((c) {
//
//             return DropdownMenuItem(
//               value: c.id,
//               child: Text(c['companyName']),
//             );
//
//           }).toList(),
//
//           onChanged: (value) {
//
//             final client =
//             clients.firstWhere((e) => e.id == value);
//
//             setState(() {
//
//               selectedClientId = value.toString();
//
//               clientAddress =
//               "${client['street']} ${client['city']} ${client['state']}";
//
//             });
//           },
//         );
//       },
//     );
//   }
//
//   // =====================================================
//   // DATE PICKER
//   // =====================================================
//
//   Widget buildDatePicker() {
//
//     return Row(
//       children: [
//
//         Text("Date: ${DateFormat.yMMMd().format(selectedDate)}"),
//
//         IconButton(
//           icon: const Icon(Icons.calendar_month),
//
//           onPressed: () async {
//
//             final picked = await showDatePicker(
//               context: context,
//               initialDate: selectedDate,
//               firstDate: DateTime(2020),
//               lastDate: DateTime(2030),
//             );
//
//             if (picked != null) {
//               setState(() => selectedDate = picked);
//             }
//           },
//         )
//       ],
//     );
//   }
//
//   // =====================================================
//   // ITEM LIST
//   // =====================================================
//
//   Widget buildItemSection() {
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//
//         const Text(
//           "Invoice Items",
//           style: TextStyle(fontWeight: FontWeight.bold),
//         ),
//
//         const SizedBox(height: 10),
//
//         ...invoiceItems.map((e) {
//
//           return Card(
//             child: ListTile(
//               title: Text(e.productId),
//               subtitle: Text("Qty: ${e.quantity}"),
//               trailing:
//               Text("₹ ${e.totalAmount.toStringAsFixed(2)}"),
//             ),
//           );
//
//         }),
//
//         const SizedBox(height: 10),
//
//         ElevatedButton.icon(
//           icon: const Icon(Icons.add),
//           label: const Text("Add Product"),
//           onPressed: addItemDialog,
//         )
//       ],
//     );
//   }
//
//   // =====================================================
//   // ADD PRODUCT DIALOG
//   // =====================================================
//
//   void addItemDialog() {
//
//     final qtyCtrl = TextEditingController();
//     final unitCtrl = TextEditingController();
//     final federalCtrl = TextEditingController();
//     final provinceCtrl = TextEditingController();
//     final descCtrl = TextEditingController();
//
//     String? productId;
//     String? productName;
//
//     showDialog(
//       context: context,
//
//       builder: (_) => AlertDialog(
//
//         title: const Text("Add Product"),
//
//         content: SingleChildScrollView(
//           child: Column(
//             children: [
//
//               FutureBuilder(
//                 future: fetchProducts(),
//
//                 builder: (context, snapshot) {
//
//                   if (!snapshot.hasData) {
//                     return const LinearProgressIndicator();
//                   }
//
//                   final products = snapshot.data!;
//
//                   return DropdownButtonFormField(
//                     hint: const Text("Select Product"),
//
//                     items: products.map((p) {
//
//                       return DropdownMenuItem(
//                         value: p.id,
//                         child: Text(p['title']),
//                       );
//
//                     }).toList(),
//
//                     onChanged: (val) {
//
//                       final prod =
//                       products.firstWhere((e) => e.id == val);
//
//                       productId = val.toString();
//                       productName = prod['title'];
//                     },
//                   );
//                 },
//               ),
//
//               TextField(controller: qtyCtrl, decoration: const InputDecoration(labelText: "Quantity")),
//               TextField(controller: unitCtrl, decoration: const InputDecoration(labelText: "Unit Cost")),
//               TextField(controller: federalCtrl, decoration: const InputDecoration(labelText: "Federal Tax %")),
//               TextField(controller: provinceCtrl, decoration: const InputDecoration(labelText: "Province Tax %")),
//               TextField(controller: descCtrl, decoration: const InputDecoration(labelText: "Description")),
//             ],
//           ),
//         ),
//
//         actions: [
//
//           TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text("Cancel")),
//
//           ElevatedButton(
//             child: const Text("ADD"),
//
//             onPressed: () {
//
//               if (productId == null) return;
//
//               final qty = int.tryParse(qtyCtrl.text) ?? 0;
//               final unit = double.tryParse(unitCtrl.text) ?? 0;
//
//               if (qty <= 0 || unit <= 0) return;
//
//               final federal = double.tryParse(federalCtrl.text) ?? 0;
//               final province = double.tryParse(provinceCtrl.text) ?? 0;
//
//               final base = qty * unit;
//               final tax = base * (federal + province) / 100;
//               final total = base + tax;
//
//               invoiceItems.add(
//
//                 InvoiceItem(
//                   productId: productId!,
//                   quantity: qty,
//                   unitCost: unit,
//                   description: descCtrl.text,
//                   federalTax: federal,
//                   provinceTax: province,
//                   totalAmount: total,
//                 ),
//               );
//
//               calculateGrandTotal();
//               Navigator.pop(context);
//             },
//           )
//         ],
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     descriptionCtrl.dispose();
//     notesCtrl.dispose();
//     super.dispose();
//   }
// }
