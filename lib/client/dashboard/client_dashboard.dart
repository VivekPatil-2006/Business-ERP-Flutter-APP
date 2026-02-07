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

  final String uid = FirebaseAuth.instance.currentUser!.uid;

  // ================= SAMPLE PAYMENT TREND =================

  final Map<String, double> monthlyPayments = {
    "2025-09": 12000,
    "2025-10": 18000,
    "2025-11": 15000,
    "2025-12": 23000,
    "2026-01": 28000,
  };

  // =====================================================
  // UI
  // =====================================================

  @override
  Widget build(BuildContext context) {

    return StreamBuilder<QuerySnapshot>(

      stream: FirebaseFirestore.instance
          .collection("quotations")
          .where("clientId", isEqualTo: uid)
          .snapshots(),

      builder: (context, quotationSnapshot) {

        if (quotationSnapshot.connectionState ==
            ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final quotationDocs =
            quotationSnapshot.data?.docs ?? [];

        return StreamBuilder<QuerySnapshot>(

          stream: FirebaseFirestore.instance
              .collection("payments")
              .where("clientId", isEqualTo: uid)
              .snapshots(),

          builder: (context, paymentSnapshot) {

            if (paymentSnapshot.connectionState ==
                ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final paymentDocs =
                paymentSnapshot.data?.docs ?? [];

            // ================= PROCESS REALTIME DATA =================

            int totalQuotations = quotationDocs.length;
            int approvedQuotations = 0;
            int pendingPayments = 0;

            double totalInvoiceAmount = 0;
            double totalPaidAmount = 0;

            List<Map<String, dynamic>> recentActivity = [];

            // ---------- QUOTATIONS ----------

            for (var q in quotationDocs) {

              final status = q['status'] ?? "";

              if (status == "payment_done") {
                approvedQuotations++;
              }

              if (status == "loi_sent") {
                pendingPayments++;
              }
            }

            // ---------- PAYMENTS ----------

            for (var p in paymentDocs) {

              final data = p.data() as Map<String, dynamic>;

              final amount =
              (data['amount'] ?? 0).toDouble();

              final status =
                  data['status'] ?? "pending";

              totalInvoiceAmount += amount;

              if (status == "completed") {
                totalPaidAmount += amount;
              }
            }

            // ---------- RECENT ACTIVITY ----------

            final sortedQuotes = quotationDocs.toList()
              ..sort((a, b) {

                final aTime =
                    a['createdAt'] ?? Timestamp.now();

                final bTime =
                    b['createdAt'] ?? Timestamp.now();

                return bTime.compareTo(aTime);
              });

            recentActivity = sortedQuotes
                .take(5)
                .map((e) => {

              "title": "Quotation",
              "value": (e['quotationAmount'] ?? 0).toDouble(),
              "date": e['createdAt'] ?? Timestamp.now(),

            }).toList();

            // ================= UI =================

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
                          childAspectRatio: 1.2,

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

                        // ================= PAYMENT TREND (SAMPLE) =================

                        dashboardCard(
                          title: "Payment Trend",
                          child: SizedBox(
                            height: 220,
                            child: buildLineChart(),
                          ),
                        ),

                        const SizedBox(height: 25),

                        // ================= RECENT ACTIVITY =================

                        dashboardCard(
                          title: "Recent Activity",

                          child: recentActivity.isEmpty
                              ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: Center(
                                child: Text("No recent activity")),
                          )
                              : Column(
                            children: recentActivity.map((item) {

                              final date =
                              (item['date'] as Timestamp).toDate();

                              return ListTile(
                                dense: true,

                                leading: CircleAvatar(
                                  backgroundColor:
                                  AppColors.primaryBlue,

                                  child: const Icon(
                                    Icons.receipt_long,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                ),

                                title: const Text("Quotation"),

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
          },
        );
      },
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
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,

        children: [

          Row(
            children: [

              Expanded(
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(width: 6),

              Icon(
                icon,
                size: 22,
                color: AppColors.primaryBlue,
              ),
            ],
          ),

          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
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
  // PAYMENT TREND CHART (SAMPLE)
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
