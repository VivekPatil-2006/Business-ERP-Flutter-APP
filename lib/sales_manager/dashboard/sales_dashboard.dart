import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';

class SalesDashboard extends StatefulWidget {
  const SalesDashboard({super.key});

  @override
  State<SalesDashboard> createState() => _SalesDashboardState();
}

class _SalesDashboardState extends State<SalesDashboard> {

  bool loading = true;

  String managerId = "";

  int totalInvoices = 0;
  int paidInvoices = 0;
  int unpaidInvoices = 0;

  double invoiceTotal = 0;
  double paymentReceived = 0;
  double paymentPending = 0;

  double targetSales = 0;
  double achievedSales = 0;

  List<Map<String, dynamic>> recentInvoices = [];
  Map<String, double> monthlyTotals = {};

  @override
  void initState() {
    super.initState();
    loadDashboardData();
  }

  // =====================================================
  // LOAD DASHBOARD DATA
  // =====================================================

  Future<void> loadDashboardData() async {

    try {

      resetValues();

      final authUser = FirebaseAuth.instance.currentUser!;
      final email = authUser.email;

      // ================= GET SALES MANAGER DOC =================

      final managerQuery = await FirebaseFirestore.instance
          .collection("sales_managers")
          .where("email", isEqualTo: email)
          .limit(1)
          .get();

      if (managerQuery.docs.isEmpty) {
        debugPrint("Sales Manager record not found");
        return;
      }

      managerId = managerQuery.docs.first.id;
      final managerData = managerQuery.docs.first.data();

      // ================= TARGET SALES =================

      final rawTarget = managerData['targetSales'];

      if (rawTarget is int) {
        targetSales = rawTarget.toDouble();
      } else if (rawTarget is double) {
        targetSales = rawTarget;
      }

      // ================= ACHIEVED SALES (LOI SENT) =================

      final quotationSnap = await FirebaseFirestore.instance
          .collection("quotations")
          .where("salesManagerId", isEqualTo: managerId)
          .where("status", isEqualTo: "loi_sent")
          .get();

      for (var q in quotationSnap.docs) {
        achievedSales += (q['quotationAmount'] ?? 0).toDouble();
      }

      // ================= INVOICES =================

      final invoiceSnap =
      await FirebaseFirestore.instance.collection("invoices").get();

      final paymentSnap =
      await FirebaseFirestore.instance.collection("payments").get();

      totalInvoices = invoiceSnap.docs.length;

      for (var doc in invoiceSnap.docs) {

        final data = doc.data();

        final amount = (data['totalAmount'] ?? 0).toDouble();
        final status = data['paymentStatus'] ?? "unpaid";
        final Timestamp? ts = data['date'];

        invoiceTotal += amount;

        status == "paid" ? paidInvoices++ : unpaidInvoices++;

        if (ts != null) {

          final monthKey =
          DateFormat("yyyy-MM").format(ts.toDate());

          monthlyTotals[monthKey] =
              (monthlyTotals[monthKey] ?? 0) + amount;
        }
      }

      // ================= PAYMENTS =================

      for (var doc in paymentSnap.docs) {

        final data = doc.data();

        final amount = (data['amount'] ?? 0).toDouble();
        final status = data['status'] ?? "pending";

        if (status == "completed") {
          paymentReceived += amount;
        } else {
          paymentPending += amount;
        }
      }

      // ================= RECENT =================

      if (invoiceSnap.docs.isNotEmpty) {

        final sorted = invoiceSnap.docs.toList()
          ..sort((a, b) {

            final aTime = a['createdAt'] ?? Timestamp.now();
            final bTime = b['createdAt'] ?? Timestamp.now();

            return bTime.compareTo(aTime);
          });

        recentInvoices = sorted.take(5).map((e) => {
          "invoiceNumber": e['invoiceNumber'] ?? "-",
          "amount": e['totalAmount'] ?? 0,
          "date": e['date'] ?? Timestamp.now(),
        }).toList();
      }

      if (monthlyTotals.isEmpty || recentInvoices.isEmpty) {
        loadSampleChartAndRecent();
      }

    } catch (e) {

      debugPrint("Sales Dashboard Error => $e");
      loadSampleChartAndRecent();

    } finally {

      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  // =====================================================
  // RESET
  // =====================================================

  void resetValues() {

    totalInvoices = 0;
    paidInvoices = 0;
    unpaidInvoices = 0;

    invoiceTotal = 0;
    paymentReceived = 0;
    paymentPending = 0;

    targetSales = 0;
    achievedSales = 0;

    recentInvoices.clear();
    monthlyTotals.clear();
  }

  // =====================================================
  // SAMPLE PREVIEW
  // =====================================================

  void loadSampleChartAndRecent() {

    monthlyTotals = {
      "2025-09": 35000,
      "2025-10": 42000,
      "2025-11": 38000,
      "2025-12": 55000,
      "2026-01": 70000,
    };

    recentInvoices = [
      {
        "invoiceNumber": "INV-1001",
        "amount": 15000,
        "date": Timestamp.now(),
      },
      {
        "invoiceNumber": "INV-1002",
        "amount": 22500,
        "date": Timestamp.now(),
      },
      {
        "invoiceNumber": "INV-1003",
        "amount": 18000,
        "date": Timestamp.now(),
      },
    ];
  }

  // =====================================================
  // UI (UNCHANGED)
  // =====================================================

  @override
  Widget build(BuildContext context) {

    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      child: Column(
        children: [

          headerUI(),

          const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [

                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.3,

                  children: [

                    kpiCard("Target Sales",
                        "₹ ${targetSales.toStringAsFixed(0)}",
                        Icons.flag),

                    kpiCard("Achieved Sales",
                        "₹ ${achievedSales.toStringAsFixed(0)}",
                        Icons.trending_up),

                    kpiCard("Total Invoices",
                        totalInvoices.toString(),
                        Icons.receipt_long),

                    kpiCard("Paid Invoices",
                        paidInvoices.toString(),
                        Icons.check_circle),

                    kpiCard("Unpaid Invoices",
                        unpaidInvoices.toString(),
                        Icons.pending_actions),

                    kpiCard("Invoice Total",
                        "₹ ${invoiceTotal.toStringAsFixed(0)}",
                        Icons.account_balance),
                  ],
                ),

                const SizedBox(height: 25),

                dashboardCard(
                  title: "Monthly Revenue Trend",
                  child: SizedBox(height: 220, child: buildLineChart()),
                ),

                const SizedBox(height: 25),

                dashboardCard(
                  title: "Recent Invoices",
                  child: Column(
                    children: recentInvoices.map((inv) {

                      final date =
                      (inv['date'] as Timestamp).toDate();

                      return ListTile(
                        dense: true,
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primaryBlue,
                          child: const Icon(Icons.receipt,
                              size: 18, color: Colors.white),
                        ),
                        title: Text(inv['invoiceNumber']),
                        subtitle: Text(DateFormat.yMMMd().format(date)),
                        trailing: Text("₹ ${inv['amount']}",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold)),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= UI HELPERS =================

  Widget headerUI() {

    return Container(
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.darkBlue, AppColors.primaryBlue],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(22),
          bottomRight: Radius.circular(22),
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Sales Dashboard",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold)),
          SizedBox(height: 6),
          Text("Revenue and invoice performance",
              style: TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  // =====================================================
  // KPI CARD (UNCHANGED UI)
  // =====================================================

  Widget kpiCard(String title, String value, IconData icon) {

    final parts = title.split(" ");

    return Container(
      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Text(parts.first,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        )),

                    if (parts.length > 1)
                      Text(parts.sublist(1).join(" "),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          )),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon,
                    size: 30,
                    color: AppColors.primaryBlue),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // CARD
  // =====================================================

  Widget dashboardCard({
    required String title,
    required Widget child,
  }) {

    return Container(
      padding: const EdgeInsets.all(14),
      width: double.infinity,

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Text(title,
              style: const TextStyle(fontWeight: FontWeight.bold)),

          const SizedBox(height: 12),

          child,
        ],
      ),
    );
  }

  // =====================================================
  // LINE CHART
  // =====================================================

  Widget buildLineChart() {

    final keys = monthlyTotals.keys.toList()..sort();

    final spots = <FlSpot>[];

    for (int i = 0; i < keys.length; i++) {
      spots.add(
        FlSpot(i.toDouble(), monthlyTotals[keys[i]]!),
      );
    }

    final maxY =
    monthlyTotals.values.reduce((a, b) => a > b ? a : b);

    return LineChart(
      LineChartData(

        minY: 0,
        maxY: maxY + (maxY * 0.2),

        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(show: false),
        borderData: FlBorderData(show: false),

        lineBarsData: [

          LineChartBarData(
            spots: spots,
            isCurved: true,
            barWidth: 3,
            color: AppColors.primaryBlue,

            dotData: FlDotData(show: true),

            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryBlue.withOpacity(0.35),
                  AppColors.primaryBlue.withOpacity(0.05),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
