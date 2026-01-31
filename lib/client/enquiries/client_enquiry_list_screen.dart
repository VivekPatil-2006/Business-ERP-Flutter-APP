import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
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

  final auth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;

  String filterStatus = "all";

  // ================= STATUS COLOR =================

  Color getStatusColor(String status) {
    switch (status) {
      case "raised":
        return Colors.orange;
      case "quoted":
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  // ================= APP BAR TITLE =================

  String getAppBarTitle() {
    switch (filterStatus) {
      case "raised":
        return "Raised Enquiries";
      case "quoted":
        return "Quoted Enquiries";
      default:
        return "My Enquiries";
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

    final uid = auth.currentUser!.uid;

    return Scaffold(

      // ================= APP BAR =================

      appBar: AppBar(
        backgroundColor: AppColors.darkBlue,
        elevation: 0,

        // 👈 Back arrow
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        // 👈 Title in white
        title: Text(
          getAppBarTitle(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),

        // 👈 Ensures icons are white
        iconTheme: const IconThemeData(color: Colors.white),
      ),


      // ================= CREATE BUTTON =================

      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.darkBlue,

        child: const Icon(Icons.add, color: Colors.white),

        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CreateClientEnquiryScreen(),
            ),
          );
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
                        value: "all",
                        child: Text("All Enquiries"),
                      ),

                      DropdownMenuItem(
                        value: "raised",
                        child: Text("Raised"),
                      ),

                      DropdownMenuItem(
                        value: "quoted",
                        child: Text("Quoted"),
                      ),
                    ],

                    onChanged: (val) {
                      setState(() => filterStatus = val!);
                    },
                  ),
                ),
              ],
            ),
          ),

          // ================= REALTIME LIST =================

          Expanded(
            child: StreamBuilder<QuerySnapshot>(

              stream: firestore
                  .collection("enquiries")
                  .where("clientId", isEqualTo: uid)
                  .orderBy("createdAt", descending: true)
                  .snapshots(),

              builder: (context, snapshot) {

                // ---------- LOADING ----------

                if (snapshot.connectionState ==
                    ConnectionState.waiting) {

                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                // ---------- EMPTY ----------

                if (!snapshot.hasData ||
                    snapshot.data!.docs.isEmpty) {

                  return const Center(
                    child: Text("No Enquiries Found"),
                  );
                }

                final docs = snapshot.data!.docs;

                // ---------- FILTER ----------

                final filtered = filterStatus == "all"
                    ? docs
                    : docs.where(
                      (e) => e['status'] == filterStatus,
                ).toList();

                if (filtered.isEmpty) {
                  return const Center(
                    child: Text("No Matching Enquiries"),
                  );
                }

                // ---------- LIST ----------

                return ListView.builder(

                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 90),

                  itemCount: filtered.length,

                  itemBuilder: (context, index) {

                    final e = filtered[index];
                    final data =
                    e.data() as Map<String, dynamic>;

                    final status =
                        data['status'] ?? "raised";

                    final Timestamp ts =
                        data['createdAt'] ?? Timestamp.now();

                    final createdAt = ts.toDate();

                    return InkWell(

                      borderRadius: BorderRadius.circular(14),

                      onTap: () {

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ClientEnquiryDetailsScreen(
                                  enquiryId: e.id,
                                ),
                          ),
                        );
                      },

                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),

                        padding: const EdgeInsets.all(14),

                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 6,
                              color: Colors.black.withOpacity(0.05),
                            ),
                          ],
                        ),

                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [

                            // -------- ICON --------

                            CircleAvatar(
                              radius: 22,

                              backgroundColor:
                              getStatusColor(status)
                                  .withOpacity(0.15),

                              child: Icon(
                                Icons.assignment,
                                color: getStatusColor(status),
                              ),
                            ),

                            const SizedBox(width: 12),

                            // -------- CONTENT --------

                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,

                                children: [

                                  Text(
                                    data['title'] ?? "Enquiry",

                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,

                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
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

                            // -------- STATUS --------

                            statusChip(status),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
