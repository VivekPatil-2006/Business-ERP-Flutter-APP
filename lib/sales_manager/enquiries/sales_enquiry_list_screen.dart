import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../shared/widgets/loading_indicator.dart';
import 'services/services.dart';
import 'enquiry_details_screen.dart';
import 'create_enquiry_screen.dart';

class SalesEnquiryListScreen extends StatefulWidget {
  const SalesEnquiryListScreen({super.key});

  @override
  State<SalesEnquiryListScreen> createState() =>
      _SalesEnquiryListScreenState();
}

class _SalesEnquiryListScreenState extends State<SalesEnquiryListScreen> {
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = EnquiryService().getEnquiries();
  }

  Future<void> _refresh() async {
    _load();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrey,

      /* ================= APP BAR ================= */
      appBar: AppBar(
        title: const Text(
          'Enquiries',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
      ),

      /* ================= FAB (ADD ENQUIRY) ================= */
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CreateEnquiryScreen(),
            ),
          ).then((_) => _refresh());
        },
      ),

      /* ================= BODY ================= */
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LoadingIndicator(
                message: 'Loading enquiries...',
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(snapshot.error.toString()),
              );
            }

            final enquiries = snapshot.data ?? [];

            if (enquiries.isEmpty) {
              return const Center(
                child: Text('No enquiries found'),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: enquiries.length,
              itemBuilder: (context, index) {
                final e = enquiries[index];

                final createdAt = e['createdAt'] != null
                    ? DateTime.tryParse(e['createdAt'])
                    : null;

                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.neonBlue.withOpacity(0.08),
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                      AppColors.primaryBlue.withOpacity(0.15),
                      child: const Icon(
                        Icons.assignment,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    title: Text(
                      e['title'] ?? 'Untitled Enquiry',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.navy,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text('Source: ${e['source'] ?? '-'}'),
                        if (createdAt != null)
                          Text(
                            DateFormat.yMMMd().format(createdAt),
                            style: const TextStyle(fontSize: 12),
                          ),
                      ],
                    ),
                    trailing: Chip(
                      label: Text(
                        (e['status'] ?? 'raised').toUpperCase(),
                        style:
                        const TextStyle(color: Colors.white),
                      ),
                      backgroundColor:
                      e['status'] == 'quoted'
                          ? Colors.green
                          : Colors.orange,
                    ),

                    /* ================= TAP → DETAILS ================= */
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EnquiryDetailsScreen(
                            enquiryId: e['enquiryId'],
                          ),
                        ),
                      ).then((_) => _refresh());
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
