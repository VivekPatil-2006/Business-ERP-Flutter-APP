// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:intl/intl.dart';
//
// import '../../core/theme/app_colors.dart';
//
// class SalesDashboard extends StatefulWidget {
//   const SalesDashboard({super.key});
//
//   @override
//   State<SalesDashboard> createState() => _SalesDashboardState();
// }
//
// class _SalesDashboardState extends State<SalesDashboard> {
//
//   bool loading = true;
//
//   final firestore = FirebaseFirestore.instance;
//   final auth = FirebaseAuth.instance;
//
//   late String managerId;
//
//   int totalInvoices = 0;
//   int paidInvoices = 0;
//   int unpaidInvoices = 0;
//
//   double invoiceTotal = 0;
//   double paymentReceived = 0;
//   double paymentPending = 0;
//
//   double targetSales = 0;
//   double achievedSales = 0;
//
//   double targetReceipt = 0;
//   double achievedReceipt = 0;
//   double pendingReceipt = 0;
//
//
//   List<Map<String, dynamic>> recentInvoices = [];
//   Map<String, double> monthlyTotals = {};
//
//   Map<String, int> enquirySourceCount = {
//     "by phone": 0,
//     "by reference": 0,
//     "by email": 0,
//     "by walkin": 0,
//     "other": 0,
//   };
//
//   String? companyId;
//
//   @override
//   void initState() {
//     super.initState();
//     loadDashboardData();
//   }
//
//   // =====================================================
//   // LOAD DASHBOARD DATA
//   // =====================================================
//
//   Future<void> loadDashboardData() async {
//
//     try {
//
//       resetValues();
//
//
//       managerId = auth.currentUser!.uid;
//
//       // ================= SALES MANAGER PROFILE =================
//
//       final managerDoc = await firestore
//           .collection("sales_managers")
//           .doc(managerId)
//           .get();
//
//       final managerData =
//       managerDoc.data() as Map<String, dynamic>?;
//
//       if (managerData != null) {
//
//         final rawTarget = managerData['targetSales'];
//
//         if (rawTarget is int) {
//           targetSales = rawTarget.toDouble();
//         }
//         else if (rawTarget is double) {
//           targetSales = rawTarget;
//         }
//       }
//
//       if (managerData != null) {
//         companyId = managerData['companyId'];
//
//         final rawTarget = managerData['targetSales'];
//         if (rawTarget is int) {
//           targetSales = rawTarget.toDouble();
//         } else if (rawTarget is double) {
//           targetSales = rawTarget;
//         }
//       }
//
//
//
//       // ================= ACHIEVED SALES (loi_sent) =================
//       final quotationSnapSales = await firestore
//           .collection("quotations")
//           .where("salesManagerId", isEqualTo: managerId)
//           .get();
//
//       for (var doc in quotationSnapSales.docs) {
//         final data = doc.data();
//         final status = data['status'];
//
//         double amount = 0;
//         if (data['pricing'] != null &&
//             data['pricing']['totalAmount'] != null) {
//           amount = (data['pricing']['totalAmount'] as num).toDouble();
//         }
//
//         // 🎯 ACHIEVED SALES = LOI SENT ONLY
//         if (status == "loi_sent") {
//           achievedSales += amount;
//         }
//       }
//
//
//       // ================= QUOTATION RECEIPT ANALYSIS =================
//
//       final quotationSnap = await firestore
//           .collection("quotations")
//           .where("salesManagerId", isEqualTo: managerId)
//           .get();
//
//       for (var doc in quotationSnap.docs) {
//         final data = doc.data();
//
//         final status = data['status'];
//
//         // SAFELY READ AMOUNT
//         double amount = 0;
//
//         if (data['quotationAmount'] != null) {
//           amount = (data['quotationAmount'] as num).toDouble();
//         } else if (data['pricing'] != null &&
//             data['pricing']['totalAmount'] != null) {
//           amount = (data['pricing']['totalAmount'] as num).toDouble();
//         }
//
//         // TARGET RECEIPT = ALL QUOTATIONS
//         targetReceipt += amount;
//
//         // ACHIEVED RECEIPT = PAYMENT DONE
//         if (status == "payment_done") {
//           achievedReceipt += amount;
//         } else {
//           pendingReceipt += amount;
//         }
//       }
//
//       // ================= ENQUIRY SOURCE ANALYSIS =================
//
//       // ================= ENQUIRY SOURCE ANALYSIS =================
//
//       if (companyId != null) {
//         final enquirySnap = await firestore
//             .collection("enquiries")
//             .where("companyId", isEqualTo: companyId)
//             .get();
//
//         for (var doc in enquirySnap.docs) {
//           final data = doc.data();
//
//           final normalizedSource = normalizeSource(data['source']);
//
//           enquirySourceCount[normalizedSource] =
//               enquirySourceCount[normalizedSource]! + 1;
//         }
//       }
//
//
//
//
//       // ================= INVOICES =================
//
//       final invoiceSnap = await firestore
//           .collection("invoices")
//           .where("salesManagerId", isEqualTo: managerId)
//           .get();
//
//       totalInvoices = invoiceSnap.docs.length;
//
//       for (var doc in invoiceSnap.docs) {
//
//         final data = doc.data();
//
//         final amount =
//         (data['totalAmount'] ?? 0).toDouble();
//
//         final status =
//             data['paymentStatus'] ?? "unpaid";
//
//         final Timestamp? ts =
//         data['createdAt'];
//
//         invoiceTotal += amount;
//
//         status == "paid"
//             ? paidInvoices++
//             : unpaidInvoices++;
//
//         if (ts != null) {
//
//           final monthKey =
//           DateFormat("yyyy-MM").format(ts.toDate());
//
//           monthlyTotals[monthKey] =
//               (monthlyTotals[monthKey] ?? 0) + amount;
//         }
//       }
//
//       // ================= PAYMENTS =================
//
//       final paymentSnap = await firestore
//           .collection("payments")
//           .where("salesManagerId", isEqualTo: managerId)
//           .get();
//
//       for (var doc in paymentSnap.docs) {
//
//         final data = doc.data();
//
//         final amount =
//         (data['amount'] ?? 0).toDouble();
//
//         final status =
//             data['status'] ?? "pending";
//
//         if (status == "completed") {
//           paymentReceived += amount;
//         }
//         else {
//           paymentPending += amount;
//         }
//       }
//
//       // ================= RECENT INVOICES =================
//
//       if (invoiceSnap.docs.isNotEmpty) {
//
//         final sorted = invoiceSnap.docs.toList()
//           ..sort((a, b) {
//
//             final aTime =
//                 a['createdAt'] ?? Timestamp.now();
//
//             final bTime =
//                 b['createdAt'] ?? Timestamp.now();
//
//             return bTime.compareTo(aTime);
//           });
//
//         recentInvoices = sorted.take(5).map((e) => {
//
//           "invoiceNumber": e['invoiceNumber'] ?? "-",
//           "amount": e['totalAmount'] ?? 0,
//           "date": e['createdAt'] ?? Timestamp.now(),
//
//         }).toList();
//       }
//
//     } catch (e) {
//
//       debugPrint("Sales Dashboard Error => $e");
//
//     } finally {
//
//       if (mounted) {
//         setState(() => loading = false);
//       }
//     }
//   }
//
//   // =====================================================
//   // RESET
//   // =====================================================
//
//   void resetValues() {
//
//     totalInvoices = 0;
//     paidInvoices = 0;
//     unpaidInvoices = 0;
//
//     invoiceTotal = 0;
//     paymentReceived = 0;
//     paymentPending = 0;
//
//     targetSales = 0;
//     achievedSales = 0;
//
//     enquirySourceCount.updateAll((key, value) => 0);
//
//     recentInvoices.clear();
//     monthlyTotals.clear();
//   }
//
//   // =====================================================
//   // UI
//   // =====================================================
//
//   @override
//   Widget build(BuildContext context) {
//
//     if (loading) {
//       return const Center(child: CircularProgressIndicator());
//     }
//
//     return SingleChildScrollView(
//       child: Column(
//         children: [
//
//           headerUI(),
//
//           const SizedBox(height: 20),
//
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             child: Column(
//               children: [
//
//                 GridView.count(
//                   crossAxisCount: 2,
//                   shrinkWrap: true,
//                   physics: const NeverScrollableScrollPhysics(),
//                   mainAxisSpacing: 12,
//                   crossAxisSpacing: 12,
//                   childAspectRatio: 1.3,
//
//                   children: [
//
//                     kpiCard("Target Sales",
//                         "₹ ${targetSales.toStringAsFixed(0)}",
//                         Icons.flag),
//
//                     kpiCard("Achieved Sales",
//                         "₹ ${achievedSales.toStringAsFixed(0)}",
//                         Icons.trending_up),
//
//                     kpiCard("Total Invoices",
//                         totalInvoices.toString(),
//                         Icons.receipt_long),
//
//                     kpiCard("Paid Invoices",
//                         paidInvoices.toString(),
//                         Icons.check_circle),
//
//                     kpiCard("Unpaid Invoices",
//                         unpaidInvoices.toString(),
//                         Icons.pending_actions),
//
//                     kpiCard("Invoice Total",
//                         "₹ ${invoiceTotal.toStringAsFixed(0)}",
//                         Icons.account_balance),
//
//                     // kpiCard(
//                     //   "Target Receipt",
//                     //   "₹ ${targetReceipt.toStringAsFixed(0)}",
//                     //   Icons.account_balance_wallet,
//                     // ),
//                     //
//                     // kpiCard(
//                     //   "Achieved Receipt",
//                     //   "₹ ${achievedReceipt.toStringAsFixed(0)}",
//                     //   Icons.payments,
//                     // ),
//
//                   ],
//                 ),
//                 const SizedBox(height: 25),
//
//                 dashboardCard(
//                   title: "Receipt Overview",
//                   child: Column(
//                     children: [
//
//                       // 🔢 RECEIPT KPIs (ROW)
//                       Row(
//                         children: [
//                           Expanded(
//                             child: _receiptMiniCard(
//                               title: "Target Receipt",
//                               value: targetReceipt,
//                               color: Colors.blue,
//                               icon: Icons.account_balance_wallet,
//                             ),
//                           ),
//                           const SizedBox(width: 12),
//                           Expanded(
//                             child: _receiptMiniCard(
//                               title: "Achieved Receipt",
//                               value: achievedReceipt,
//                               color: Colors.green,
//                               icon: Icons.payments,
//                             ),
//                           ),
//                         ],
//                       ),
//
//                       const SizedBox(height: 16),
//
//                       // 📊 RECEIPT ANALYSIS GRAPH
//                       SizedBox(
//                         height: 200,
//                         child: buildReceiptChart(),
//                       ),
//                     ],
//                   ),
//                 ),
//
//                 const SizedBox(height: 25),
//
//                 dashboardCard(
//                   title: "Monthly Revenue Trend",
//                   child: SizedBox(
//                       height: 220,
//                       child: buildLineChart()),
//                 ),
//
//
//                 const SizedBox(height: 25),
//
//                 dashboardCard(
//                   title: "Source of Enquiry Analysis",
//                   child: buildEnquirySourceChart(),
//                 ),
//
//
//                 const SizedBox(height: 25),
//
//                 dashboardCard(
//                   title: "Recent Invoices",
//                   child: recentInvoices.isEmpty
//                       ? const Text("No invoices yet")
//                       : Column(
//                     children: recentInvoices.map((inv) {
//
//                       final date =
//                       (inv['date'] as Timestamp).toDate();
//
//                       return ListTile(
//                         dense: true,
//                         leading: CircleAvatar(
//                           backgroundColor:
//                           AppColors.primaryBlue,
//                           child: const Icon(Icons.receipt,
//                               size: 18,
//                               color: Colors.white),
//                         ),
//                         title: Text(inv['invoiceNumber']),
//                         subtitle:
//                         Text(DateFormat.yMMMd().format(date)),
//                         trailing: Text("₹ ${inv['amount']}",
//                             style: const TextStyle(
//                                 fontWeight: FontWeight.bold)),
//                       );
//                     }).toList(),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget buildReceiptChart() {
//     if (targetReceipt == 0) {
//       return const Center(child: Text("No receipt data"));
//     }
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//
//         // 🔤 Chart Title
//         const Padding(
//           padding: EdgeInsets.only(bottom: 8),
//           // child: Text(
//           //   "Target vs Achieved Receipt",
//           //   style: TextStyle(
//           //     fontWeight: FontWeight.bold,
//           //     fontSize: 14,
//           //   ),
//           // ),
//         ),
//
//         Expanded(
//           child: BarChart(
//             BarChartData(
//               maxY: targetReceipt * 1.2,
//
//               gridData: FlGridData(
//                 show: true,
//                 drawVerticalLine: false,
//                 horizontalInterval: targetReceipt / 4,
//               ),
//
//               borderData: FlBorderData(
//                 show: true,
//                 border: const Border(
//                   left: BorderSide(),
//                   bottom: BorderSide(),
//                 ),
//               ),
//
//               titlesData: FlTitlesData(
//                 topTitles: AxisTitles(
//                   sideTitles: SideTitles(showTitles: false),
//                 ),
//                 rightTitles: AxisTitles(
//                   sideTitles: SideTitles(showTitles: false),
//                 ),
//
//                 // 🧮 Y-AXIS (AMOUNT)
//                 leftTitles: AxisTitles(
//                   sideTitles: SideTitles(
//                     showTitles: false,
//                     reservedSize: 42,
//                     interval: targetReceipt / 4,
//                     getTitlesWidget: (value, meta) {
//                       return Text(
//                         "₹${value.toInt()}",
//                         style: const TextStyle(fontSize: 10),
//                       );
//                     },
//                   ),
//                 ),
//
//                 // 🏷️ X-AXIS (LABELS)
//                 bottomTitles: AxisTitles(
//                   sideTitles: SideTitles(
//                     showTitles: true,
//                     getTitlesWidget: (value, meta) {
//                       switch (value.toInt()) {
//                         case 0:
//                           return const Text(
//                             "Total",
//                             style: TextStyle(fontSize: 11),
//                           );
//                         case 1:
//                           return const Text(
//                             "Pending",
//                             style: TextStyle(fontSize: 11),
//                           );
//                         case 2:
//                           return const Text(
//                             "Achieved",
//                             style: TextStyle(fontSize: 11),
//                           );
//                         default:
//                           return const SizedBox.shrink();
//                       }
//                     },
//                   ),
//                 ),
//               ),
//
//               barGroups: [
//                 BarChartGroupData(
//                   x: 0,
//                   barRods: [
//                     BarChartRodData(
//                       toY: (achievedReceipt+pendingReceipt),
//                       width: 28,
//                       color: Colors.blue,
//                       borderRadius: BorderRadius.circular(6),
//                     ),
//                   ],
//                 ),
//                 BarChartGroupData(
//                   x: 2,
//                   barRods: [
//                     BarChartRodData(
//                       toY: pendingReceipt,
//                       width: 28,
//                       color: Colors.green,
//                       borderRadius: BorderRadius.circular(6),
//                     ),
//                   ],
//                 ),
//                 BarChartGroupData(
//                   x: 1,
//                   barRods: [
//                     BarChartRodData(
//                       toY: achievedReceipt,
//                       width: 28,
//                       color: Colors.orange,
//                       borderRadius: BorderRadius.circular(6),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget buildLineChart() {
//     if (monthlyTotals.isEmpty) {
//       return const Center(child: Text("No data"));
//     }
//
//     final keys = monthlyTotals.keys.toList()..sort();
//     final spots = <FlSpot>[];
//
//     for (int i = 0; i < keys.length; i++) {
//       spots.add(
//         FlSpot(i.toDouble(), monthlyTotals[keys[i]]!),
//       );
//     }
//
//     final maxY =
//     monthlyTotals.values.reduce((a, b) => a > b ? a : b);
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//
//         // 🔤 Chart Title
//         const Padding(
//           padding: EdgeInsets.only(bottom: 8),
//           // child: Text(
//           //   "Monthly Revenue Trend",
//           //   style: TextStyle(
//           //     fontWeight: FontWeight.bold,
//           //     fontSize: 14,
//           //   ),
//           // ),
//         ),
//
//         Expanded(
//           child: LineChart(
//             LineChartData(
//               minY: 0,
//               maxY: maxY + (maxY * 0.2),
//
//               gridData: FlGridData(show: true),
//               borderData: FlBorderData(
//                 show: true,
//                 border: const Border(
//                   left: BorderSide(),
//                   bottom: BorderSide(),
//                 ),
//               ),
//
//               titlesData: FlTitlesData(
//                 topTitles: AxisTitles(
//                   sideTitles: SideTitles(showTitles: false),
//                 ),
//                 rightTitles: AxisTitles(
//                   sideTitles: SideTitles(showTitles: false),
//                 ),
//
//                 // 🧮 Y AXIS
//                 leftTitles: AxisTitles(
//                   sideTitles: SideTitles(
//                     showTitles: false, // 👈 hides Y-axis labels completely
//                   ),
//                 ),
//
//
//
//                 // 🏷️ X AXIS (MONTHS)
//                 bottomTitles: AxisTitles(
//                   sideTitles: SideTitles(
//                     showTitles: true,
//                     getTitlesWidget: (value, meta) {
//                       final index = value.toInt();
//                       if (index < 0 || index >= keys.length) {
//                         return const SizedBox.shrink();
//                       }
//                       final date =
//                       DateFormat("yyyy-MM").parse(keys[index]);
//                       return Text(
//                         DateFormat.MMM().format(date),
//                         style: const TextStyle(fontSize: 10),
//                       );
//                     },
//                   ),
//                 ),
//               ),
//
//               lineBarsData: [
//                 LineChartBarData(
//                   spots: spots,
//                   isCurved: true,
//                   barWidth: 3,
//                   color: AppColors.primaryBlue,
//                   dotData: FlDotData(show: true),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//
//   Widget buildEnquirySourceChart() {
//     final total = enquirySourceCount.values.fold(0, (a, b) => a + b);
//
//     if (total == 0) {
//       return const Center(child: Text("No enquiry data"));
//     }
//
//     final colors = {
//       "by phone": Colors.blue,
//       "by reference": Colors.green,
//       "by email": Colors.orange,
//       "by walkin": Colors.purple,
//       "other": Colors.grey,
//     };
//
//     return Column(
//       children: [
//         SizedBox(
//           height: 220,
//           child: PieChart(
//             PieChartData(
//               sectionsSpace: 2,
//               centerSpaceRadius: 40,
//               sections: enquirySourceCount.entries.map((entry) {
//                 final value = entry.value;
//                 if (value == 0) return PieChartSectionData(value: 0);
//
//                 return PieChartSectionData(
//                   value: value.toDouble(),
//                   color: colors[entry.key],
//                   radius: 55,
//                   title:
//                   "${((value / total) * 100).toStringAsFixed(0)}%",
//                   titleStyle: const TextStyle(
//                     fontSize: 12,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 );
//               }).toList(),
//             ),
//           ),
//         ),
//
//         const SizedBox(height: 12),
//
//         Wrap(
//           spacing: 12,
//           runSpacing: 6,
//           children: enquirySourceCount.keys.map((key) {
//             return Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Container(
//                   width: 10,
//                   height: 10,
//                   color: colors[key],
//                 ),
//                 const SizedBox(width: 6),
//                 Text(
//                   key,
//                   style: const TextStyle(fontSize: 12),
//                 ),
//               ],
//             );
//           }).toList(),
//         ),
//       ],
//     );
//   }
//
//   // ================= UI HELPERS =================
//
//   Widget headerUI() {
//
//     return Container(
//       padding: const EdgeInsets.all(20),
//       width: double.infinity,
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [
//             AppColors.darkBlue,
//             AppColors.primaryBlue
//           ],
//         ),
//         borderRadius: const BorderRadius.only(
//           bottomLeft: Radius.circular(22),
//           bottomRight: Radius.circular(22),
//         ),
//       ),
//       child: const Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text("Sales Dashboard",
//               style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 22,
//                   fontWeight: FontWeight.bold)),
//           SizedBox(height: 6),
//           Text("Revenue and invoice performance",
//               style: TextStyle(color: Colors.white70)),
//         ],
//       ),
//     );
//   }
//
//   Widget _receiptMiniCard({
//     required String title,
//     required double value,
//     required Color color,
//     required IconData icon,
//   }) {
//     return Container(
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.08),
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(color: color.withOpacity(0.3)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 title,
//                 style: const TextStyle(
//                   fontSize: 10,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//               Icon(icon, size: 18, color: color),
//             ],
//           ),
//           const SizedBox(height: 8),
//           Text(
//             "₹ ${value.toStringAsFixed(0)}",
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: color,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget kpiCard(String title, String value, IconData icon) {
//
//     return Container(
//       padding: const EdgeInsets.all(14),
//
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.06),
//             blurRadius: 10,
//           ),
//         ],
//       ),
//
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//
//               Text(title,
//                   style: const TextStyle(
//                     fontSize: 12,
//                     fontWeight: FontWeight.w600,
//                   )),
//
//               Icon(icon,
//                   color: AppColors.primaryBlue),
//             ],
//           ),
//
//           const Spacer(),
//
//           Text(value,
//               style: const TextStyle(
//                 fontSize: 22,
//                 fontWeight: FontWeight.bold,
//               )),
//         ],
//       ),
//     );
//   }
//
//   Widget dashboardCard({
//     required String title,
//     required Widget child,
//   }) {
//
//     return Container(
//       padding: const EdgeInsets.all(14),
//       width: double.infinity,
//
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(14),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 8,
//           ),
//         ],
//       ),
//
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//
//           Text(title,
//               style: const TextStyle(fontWeight: FontWeight.bold)),
//
//           const SizedBox(height: 12),
//
//           child,
//         ],
//       ),
//     );
//   }
//
//   String normalizeSource(dynamic rawSource) {
//     if (rawSource == null) return "other";
//
//     final s = rawSource.toString().toLowerCase().trim();
//
//     if (s.contains("walk")) return "by walkin";
//     if (s.contains("phone")) return "by phone";
//     if (s.contains("refer")) return "by reference";
//     if (s.contains("email") || s.contains("mail")) return "by email";
//
//     return "other";
//   }
//
//
// // =====================================================
//   // LINE CHART
//   // =====================================================
//
//
// }
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class SalesDashboard extends StatelessWidget {
  const SalesDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.darkBlue,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          '',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: const Center(
        child: Text(
          "Sales DashBoard",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
