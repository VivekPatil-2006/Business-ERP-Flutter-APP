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

  // ======================
  // STATUS COLOR
  // ======================

  Color getStatusColor(String status) {
    switch (status) {
      case "raised":
        return Colors.orange;
      case "quoted":
        return Colors.blue;
      case "closed":
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  // ======================
  // DYNAMIC TITLE
  // ======================

  String getAppBarTitle() {
    switch (filterStatus) {
      case "raised":
        return "Raised Enquiries";
      case "quoted":
        return "Quoted Enquiries";
      case "closed":
        return "Closed Enquiries";
      default:
        return "My Enquiries";
    }
  }

  @override
  Widget build(BuildContext context) {

    final uid = auth.currentUser!.uid;

    return Scaffold(

      // ================= APP BAR =================

      appBar: AppBar(
        title: Text(getAppBarTitle()),
        backgroundColor: AppColors.darkBlue,
      ),

      // ================= FLOATING + BUTTON =================

      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.darkBlue,
        child: const Icon(Icons.add, color: Colors.white),

        onPressed: () async {

          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CreateClientEnquiryScreen(),
            ),
          );

          // Refresh list after returning
          setState(() {});
        },
      ),

      // ================= BODY =================

      body: Column(
        children: [

          // ================= FILTER BAR =================

          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 10),
            color: Colors.white,

            child: Row(
              children: [

                const Text(
                  "Filter:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),

                const SizedBox(width: 10),

                DropdownButton<String>(
                  value: filterStatus,
                  underline: const SizedBox(),

                  items: const [

                    DropdownMenuItem(
                        value: "all",
                        child: Text("All")),

                    DropdownMenuItem(
                        value: "raised",
                        child: Text("Raised")),

                    DropdownMenuItem(
                        value: "quoted",
                        child: Text("Quoted")),

                    DropdownMenuItem(
                        value: "closed",
                        child: Text("Closed")),
                  ],

                  onChanged: (val) {
                    setState(() => filterStatus = val!);
                  },
                ),
              ],
            ),
          ),

          // ================= LIST =================

          Expanded(
            child: StreamBuilder<QuerySnapshot>(

              stream: firestore
                  .collection("enquiries")
                  .where("clientId", isEqualTo: uid)
                  .orderBy("createdAt", descending: true)
                  .snapshots(),

              builder: (context, snapshot) {

                // -------- LOADING --------
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator());
                }

                // -------- EMPTY --------
                if (!snapshot.hasData ||
                    snapshot.data!.docs.isEmpty) {
                  return const Center(
                      child: Text("No Enquiries Found"));
                }

                final docs = snapshot.data!.docs;

                final filtered = filterStatus == "all"
                    ? docs
                    : docs.where(
                      (e) => e['status'] == filterStatus,
                ).toList();

                if (filtered.isEmpty) {
                  return const Center(
                      child: Text("No matching enquiries"));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: filtered.length,

                  itemBuilder: (context, index) {

                    final e = filtered[index];
                    final data =
                    e.data() as Map<String, dynamic>;

                    final status =
                        data['status'] ?? "raised";

                    final createdAt =
                    (data['createdAt'] as Timestamp)
                        .toDate();

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),

                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                        BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black
                                .withOpacity(0.05),
                            blurRadius: 6,
                          ),
                        ],
                      ),

                      child: ListTile(

                        contentPadding:
                        const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12),

                        // -------- ICON --------

                        leading: CircleAvatar(
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

                        // -------- TITLE --------

                        title: Text(
                          data['title'] ?? "",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),

                        // -------- SUBTITLE --------

                        subtitle: Padding(
                          padding:
                          const EdgeInsets.only(top: 6),

                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,

                            children: [

                              Text(
                                data['description'] ?? "",
                                maxLines: 1,
                                overflow:
                                TextOverflow.ellipsis,
                              ),

                              const SizedBox(height: 6),

                              Text(
                                "Created: ${DateFormat.yMMMd().format(createdAt)}",
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // -------- STATUS BADGE --------

                        trailing: Container(
                          padding:
                          const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4),

                          decoration: BoxDecoration(
                            color: getStatusColor(status)
                                .withOpacity(0.12),
                            borderRadius:
                            BorderRadius.circular(20),
                          ),

                          child: Text(
                            status.toUpperCase(),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color:
                              getStatusColor(status),
                            ),
                          ),
                        ),

                        // -------- OPEN DETAILS --------

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
