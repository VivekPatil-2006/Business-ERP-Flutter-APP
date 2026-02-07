import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../services/api_service.dart';
import '../../shared/widgets/loading_indicator.dart';
import 'client_enquiry_details_screen.dart';
import 'create_client_enquiry_screen.dart';

class ClientEnquiryListScreen extends StatefulWidget {
  const ClientEnquiryListScreen({super.key});

  @override
  State<ClientEnquiryListScreen> createState() =>
      _ClientEnquiryListScreenState();
}

class _ClientEnquiryListScreenState
    extends State<ClientEnquiryListScreen> {
  String filterStatus = 'all';
  bool loading = true;

  List<Map<String, dynamic>> enquiries = [];

  @override
  void initState() {
    super.initState();
    _loadEnquiries();
  }

  // ================= FETCH ENQUIRIES =================

  Future<void> _loadEnquiries() async {
    setState(() => loading = true);

    try {
      final res = await ApiService.get('/enquiries');
      final List list = res['enquiries'] ?? [];

      enquiries = list.map<Map<String, dynamic>>((e) {
        return {
          'id': e['id'],
          'title': e['title'],
          'status': e['status'] ?? 'raised',
          'createdAt': DateTime.parse(e['createdAt']),
        };
      }).toList();
    } catch (e) {
      enquiries = [];
    }

    setState(() => loading = false);
  }

  // ================= STATUS COLOR =================

  Color getStatusColor(String status) {
    switch (status) {
      case 'raised':
        return Colors.orange;
      case 'quoted':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  // ================= APP BAR TITLE =================

  String getAppBarTitle() {
    switch (filterStatus) {
      case 'raised':
        return 'Raised Enquiries';
      case 'quoted':
        return 'Quoted Enquiries';
      default:
        return 'My Enquiries';
    }
  }

  // ================= STATUS CHIP =================

  Widget statusChip(String status) {
    final color = getStatusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = filterStatus == 'all'
        ? enquiries
        : enquiries
        .where((e) => e['status'] == filterStatus)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.lightGrey,

      // ================= APP BAR =================

      appBar: AppBar(
        backgroundColor: AppColors.darkBlue,
        foregroundColor: Colors.white,
        title: Text(
          getAppBarTitle(),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),

      // ================= CREATE BUTTON =================

      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.darkBlue,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          // await Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     // builder: (_) => const CreateClientEnquiryScreen(),
          //   ),
          // );
          _loadEnquiries(); // refresh after create
        },
      ),

      body: Column(
        children: [
          // ================= FILTER BAR =================

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: Colors.white,
            child: Row(
              children: [
                const Icon(Icons.filter_alt, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: filterStatus,
                    decoration: const InputDecoration(
                      isDense: true,
                      border: OutlineInputBorder(),
                      contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'all',
                        child: Text('All Enquiries'),
                      ),
                      DropdownMenuItem(
                        value: 'raised',
                        child: Text('Raised'),
                      ),
                      DropdownMenuItem(
                        value: 'quoted',
                        child: Text('Quoted'),
                      ),
                    ],
                    onChanged: (v) =>
                        setState(() => filterStatus = v!),
                  ),
                ),
              ],
            ),
          ),

          // ================= LIST =================

          Expanded(
            child: loading
                ? const LoadingIndicator(message: 'Loading enquiries...')
                : filtered.isEmpty
                ? const Center(child: Text('No Enquiries Found'))
                : RefreshIndicator(
              onRefresh: _loadEnquiries,
              child: ListView.builder(
                padding:
                const EdgeInsets.fromLTRB(12, 12, 12, 90),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final e = filtered[index];
                  final status = e['status'];
                  final createdAt = e['createdAt'];

                  return InkWell(
                    borderRadius: BorderRadius.circular(14),
                    // onTap: () {
                    //   Navigator.push(
                    //     context,
                    //     // MaterialPageRoute(
                    //     //   builder: (_) =>
                    //     //       // ClientEnquiryDetailsScreen(
                    //     //       //   enquiryId: e['id'],
                    //     //       // ),
                    //     // ),
                    //   );
                    // },
                    child: Container(
                      margin:
                      const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                        BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 6,
                            color: Colors.black
                                .withOpacity(0.05),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor:
                            getStatusColor(status)
                                .withOpacity(0.15),
                            child: Icon(
                              Icons.assignment,
                              color:
                              getStatusColor(status),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  e['title'] ??
                                      'Enquiry',
                                  maxLines: 2,
                                  overflow:
                                  TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight:
                                    FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.calendar_today,
                                      size: 13,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      DateFormat.yMMMd()
                                          .format(createdAt),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          statusChip(status),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
