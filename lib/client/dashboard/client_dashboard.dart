import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';

class ClientDashboard extends StatefulWidget {
  const ClientDashboard({super.key});

  @override
  State<ClientDashboard> createState() => _ClientDashboardState();
}

class _ClientDashboardState extends State<ClientDashboard> {

  final uid = FirebaseAuth.instance.currentUser!.uid;

  bool loading = true;

  int totalQuotations = 0;
  int approvedQuotations = 0;
  int pendingPayments = 0;

  double totalInvoiceAmount = 0;
  double totalPaidAmount = 0;

  List<Map<String, dynamic>> recentActivity = [];
  Map<String, double> monthlyPayments = {};

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

      final quotationSnap = await FirebaseFirestore.instance
          .collection("quotations")
          .where("clientId", isEqualTo: uid)
          .get();

      final paymentSnap = await FirebaseFirestore.instance
          .collection("payments")
          .where("clientId", isEqualTo: uid)
          .get();

      // ================= QUOTATIONS =================

      totalQuotations = quotationSnap.docs.length;

      for (var q in quotationSnap.docs) {

        final status = q['status'] ?? "";

        if (status == "ack_sent" || status == "payment_done") {
          approvedQuotations++;
        }

        if (status == "ack_sent") {
          pendingPayments++;
        }
      }

      // ================= PAYMENTS =================

      for (var p in paymentSnap.docs) {

        final data = p.data();

        final amount = (data['amount'] ?? 0).toDouble();
        final status = data['status'] ?? "pending";

        totalInvoiceAmount += amount;

        if (status == "completed") {
          totalPaidAmount += amount;
        }
      }

      // ================= RECENT ACTIVITY =================

      recentActivity = quotationSnap.docs
          .take(5)
          .map((e) => {
        "title": "Quotation",
        "value": e['quotationAmount'] ?? 0,
        "date": e['createdAt'] ?? Timestamp.now(),
      })
          .toList();

      // ================= PAYMENT TREND (SAMPLE ONLY) =================

      if (monthlyPayments.isEmpty) {
        loadSamplePaymentTrend();
      }

    } catch (e) {

      debugPrint("Client Dashboard Error => $e");

      loadSamplePaymentTrend();
    }

    if (mounted) {
      setState(() => loading = false);
    }
  }

  // =====================================================
  // RESET
  // =====================================================

  void resetValues() {

    totalQuotations = 0;
    approvedQuotations = 0;
    pendingPayments = 0;

    totalInvoiceAmount = 0;
    totalPaidAmount = 0;

    recentActivity.clear();
    monthlyPayments.clear();
  }

  // =====================================================
  // SAMPLE PAYMENT TREND (GRAPH PREVIEW)
  // =====================================================

  void loadSamplePaymentTrend() {

    monthlyPayments = {
      "2025-09": 12000,
      "2025-10": 18000,
      "2025-11": 15000,
      "2025-12": 23000,
      "2026-01": 28000,
    };
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
                  "Client Dashboard",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 6),

                Text(
                  "Overview of your business activity",
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
                  childAspectRatio: 1.3,

                  children: [

                    kpiCard("Total Quotation",
                        totalQuotations.toString(),
                        Icons.assignment),

                    kpiCard("Approved",
                        approvedQuotations.toString(),
                        Icons.verified),

                    kpiCard("Pending Payment",
                        pendingPayments.toString(),
                        Icons.pending_actions),

                    kpiCard("Invoice Amount",
                        "₹ ${totalInvoiceAmount.toStringAsFixed(0)}",
                        Icons.receipt),

                    kpiCard("Paid Amount",
                        "₹ ${totalPaidAmount.toStringAsFixed(0)}",
                        Icons.payments),
                  ],
                ),

                const SizedBox(height: 25),

                // ================= PAYMENT TREND =================

                dashboardCard(
                  title: "Payment Trend",
                  child: SizedBox(
                    height: 220,
                    child: buildLineChart(),
                  ),
                ),

                const SizedBox(height: 25),

                // ================= RECENT =================

                dashboardCard(
                  title: "Recent Activity",

                  child: recentActivity.isEmpty
                      ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: Center(child: Text("No recent activity")),
                  )
                      : Column(
                    children: recentActivity.map((item) {

                      final date =
                      (item['date'] as Timestamp).toDate();

                      return ListTile(
                        dense: true,

                        leading: CircleAvatar(
                          backgroundColor: AppColors.primaryBlue,
                          child: const Icon(
                            Icons.receipt_long,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),

                        title: Text(item['title']),

                        subtitle: Text(
                          DateFormat.yMMMd().format(date),
                        ),

                        trailing: Text(
                          "₹ ${item['value']}",
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
  // KPI CARD (MATCH SALES DASHBOARD STYLE)
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

                    Text(
                      parts.first,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    if (parts.length > 1)
                      Text(
                        parts.sublist(1).join(" "),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  size: 30,
                  color: AppColors.primaryBlue,
                ),
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
  // CARD WRAPPER
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
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 12),

          child,
        ],
      ),
    );
  }

  // =====================================================
  // PAYMENT TREND LINE CHART
  // =====================================================

  Widget buildLineChart() {

    final keys = monthlyPayments.keys.toList()..sort();

    final spots = <FlSpot>[];

    for (int i = 0; i < keys.length; i++) {
      spots.add(
        FlSpot(i.toDouble(), monthlyPayments[keys[i]]!),
      );
    }

    final maxY =
    monthlyPayments.values.reduce((a, b) => a > b ? a : b);

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
