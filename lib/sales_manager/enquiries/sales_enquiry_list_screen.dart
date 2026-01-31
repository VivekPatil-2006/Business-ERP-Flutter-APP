import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import 'enquiry_details_screen.dart';
import 'create_enquiry_screen.dart';


class SalesEnquiryListScreen extends StatefulWidget {
  const SalesEnquiryListScreen({super.key});

  @override
  State<SalesEnquiryListScreen> createState() => _EnquiryListScreenState();
}

class _EnquiryListScreenState extends State<SalesEnquiryListScreen> {
  final firestore = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;

  String? companyId;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadCompanyId();
  }

  // ============================
  // LOAD COMPANY ID
  // ============================

  Future<void> loadCompanyId() async {
    final uid = auth.currentUser!.uid;

    final snap = await firestore
        .collection("sales_managers")
        .doc(uid)
        .get();

    companyId = snap.data()?['companyId'];

    setState(() => loading = false);
  }

  // ============================
  // FETCH ENQUIRIES
  // ============================

  Stream<QuerySnapshot> enquiryStream() {
    return firestore
        .collection("enquiries")
        .where("companyId", isEqualTo: companyId)
        .orderBy("createdAt", descending: true)
        .snapshots();
  }

  // ============================
  // UI
  // ============================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Enquiries",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.darkBlue,
        foregroundColor: Colors.white,
      ),


      // ✅ FLOATING ACTION BUTTON
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.darkBlue,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CreateEnquiryScreen(),
            ),
          );
        },
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<QuerySnapshot>(
        stream: enquiryStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No enquiries found"));
          }

          final enquiries = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: enquiries.length,
            itemBuilder: (context, index) {
              final doc = enquiries[index];
              final data = doc.data() as Map<String, dynamic>;

              final createdAt =
              (data['createdAt'] as Timestamp?)?.toDate();

              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primaryBlue,
                    child: const Icon(
                      Icons.assignment,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    data['title'] ?? "Untitled Enquiry",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text("Source: ${data['source'] ?? '-'}"),
                      if (createdAt != null)
                        Text(
                          DateFormat.yMMMd().format(createdAt),
                          style: const TextStyle(fontSize: 12),
                        ),
                    ],
                  ),
                  trailing: Chip(
                    label: Text(
                      data['status'] ?? "raised",
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: data['status'] == "quoted"
                        ? Colors.green
                        : Colors.orange,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EnquiryDetailsScreen(
                          enquiryId: doc.id,
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
    );
  }
}
