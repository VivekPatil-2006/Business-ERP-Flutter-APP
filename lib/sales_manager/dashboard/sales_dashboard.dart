import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  int totalInvoices = 0;
  int paidInvoices = 0;
  int unpaidInvoices = 0;

  double invoiceTotal = 0;
  double paymentReceived = 0;
  double paymentPending = 0;

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

      final invoiceSnap =
      await FirebaseFirestore.instance.collection("invoices").get();

      final paymentSnap =
      await FirebaseFirestore.instance.collection("payments").get();

      // ================= EMPTY STATE → LOAD SAMPLE DATA =================

      if (invoiceSnap.docs.isEmpty && paymentSnap.docs.isEmpty) {
        loadSampleData();
        return;
      }

      // ================= INVOICES =================

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

      final sorted = invoiceSnap.docs.toList()
        ..sort((a, b) {

          final aTime = a['createdAt'] ?? Timestamp.now();
          final bTime = b['createdAt'] ?? Timestamp.now();

          return bTime.compareTo(aTime);
        });

      recentInvoices = sorted.take(5).map((e) => {
        "invoiceNumber": e['invoiceNumber'],
        "amount": e['totalAmount'],
        "date": e['date'],
      }).toList();

    } catch (e) {
      debugPrint("Sales Dashboard Error => $e");
      loadSampleData();
    }

    if (mounted) {
      setState(() => loading = false);
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

    recentInvoices.clear();
    monthlyTotals.clear();
  }

  // =====================================================
  // SAMPLE DATA (FALLBACK)
  // =====================================================

  void loadSampleData() {

    totalInvoices = 12;
    paidInvoices = 8;
    unpaidInvoices = 4;

    invoiceTotal = 240000;
    paymentReceived = 180000;
    paymentPending = 60000;

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

    setState(() => loading = false);
  }

  // =====================================================
  // UI
  // =====================================================

  @override
  Widget build(BuildContext context) {

    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      child: Column(
        children: [

          // ================= HEADER =================

          Container(
            padding: const EdgeInsets.all(20),
            width: double.infinity,

            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.darkBlue,
                  AppColors.primaryBlue,
                ],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(22),
                bottomRight: Radius.circular(22),
              ),
            ),

            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  "Sales Dashboard",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 6),

                Text(
                  "Revenue and invoice performance",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),

            child: Column(
              children: [

                // ================= KPI GRID =================

                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.4,

                  children: [

                    kpiCard("Total Invoices", totalInvoices.toString(),
                        Icons.receipt_long),

                    kpiCard("Paid Invoices", paidInvoices.toString(),
                        Icons.check_circle),

                    kpiCard("Unpaid Invoices", unpaidInvoices.toString(),
                        Icons.pending_actions),

                    kpiCard("Invoice Total",
                        "₹ ${invoiceTotal.toStringAsFixed(0)}",
                        Icons.account_balance),

                    kpiCard("Payment Received",
                        "₹ ${paymentReceived.toStringAsFixed(0)}",
                        Icons.payments),

                    kpiCard("Payment Pending",
                        "₹ ${paymentPending.toStringAsFixed(0)}",
                        Icons.hourglass_bottom),
                  ],
                ),

                const SizedBox(height: 25),

                // ================= CHART =================

                dashboardCard(
                  title: "Monthly Revenue Trend",
                  child: SizedBox(
                    height: 220,
                    child: buildLineChart(),
                  ),
                ),

                const SizedBox(height: 25),

                // ================= RECENT =================

                dashboardCard(
                  title: "Recent Invoices",

                  child: Column(
                    children: recentInvoices.map((inv) {

                      final date =
                      (inv['date'] as Timestamp).toDate();

                      return ListTile(
                        dense: true,

                        leading: const CircleAvatar(
                          backgroundColor: Colors.green,
                          child: Icon(
                            Icons.receipt,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),

                        title: Text(inv['invoiceNumber']),

                        subtitle: Text(
                          DateFormat.yMMMd().format(date),
                        ),

                        trailing: Text(
                          "₹ ${inv['amount']}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // KPI CARD
  // =====================================================

  Widget kpiCard(String title, String value, IconData icon) {

    return Container(
      padding: const EdgeInsets.all(14),

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

          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
            child: Icon(icon,
                size: 18,
                color: AppColors.primaryBlue),
          ),

          const Spacer(),

          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
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

          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),

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

    if (monthlyTotals.isEmpty) {
      return const Center(child: Text("No Revenue Data"));
    }

    final keys = monthlyTotals.keys.toList()..sort();

    final spots = <FlSpot>[];

    for (int i = 0; i < keys.length; i++) {
      spots.add(
        FlSpot(i.toDouble(), monthlyTotals[keys[i]]!),
      );
    }

    if (spots.length == 1) {
      spots.add(FlSpot(spots.first.x + 1, spots.first.y));
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
