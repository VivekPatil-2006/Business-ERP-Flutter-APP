import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/loading_indicator.dart';
import 'services/client_service.dart';

class ClientDetailScreen extends StatefulWidget {
  final String clientId;

  const ClientDetailScreen({
    super.key,
    required this.clientId,
  });

  @override
  State<ClientDetailScreen> createState() => _ClientDetailScreenState();
}

class _ClientDetailScreenState extends State<ClientDetailScreen> {
  Map<String, dynamic>? client;
  bool isLoading = true;
  bool isUpdatingStatus = false;

  @override
  void initState() {
    super.initState();
    _loadClient();
  }

  // ================= LOAD CLIENT =================
  Future<void> _loadClient() async {
    final data = await ClientService().getClientById(widget.clientId);
    setState(() {
      client = data;
      isLoading = false;
    });
  }

  // ================= TOGGLE STATUS =================
  Future<void> _toggleStatus(bool value) async {
    if (client == null) return;

    setState(() => isUpdatingStatus = true);

    await ClientService().toggleStatus(
      clientId: widget.clientId,
      activate: value,
    );

    // ✅ update local state (NO refetch needed)
    setState(() {
      client!['status'] = value ? 'active' : 'inactive';
      isUpdatingStatus = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: LoadingIndicator(message: 'Loading client...'),
      );
    }

    final c = client!;
    final bool isActive = c['status'] == 'active';

    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Client Details',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _profileCard(c),
            const SizedBox(height: 24),

            _section('Contact Information', [
              _row('Client Name', c['clientName']),
              _row('Company', c['companyName']),
              _row('Contact Person', c['contactPerson']),
              _row('Email', c['emailAddress']),
              _row('Phone 1', c['phoneNo1']),
              _row('Phone 2', c['phoneNo2']),
            ]),

            const SizedBox(height: 20),

            _section('Identity & Codes', [
              _row('Customer Code', c['customerCode']),
              _row('SSN', c['socialSecurityNumber']),
              _row('EIN / TIN', c['einTin']),
              _row('VAT', c['vatIdentifier']),
            ]),

            const SizedBox(height: 20),

            _section('Address', [
              _row('Street', c['street']),
              _row('City', c['city']),
              _row('State', c['state']),
              _row('Postcode', c['postcode']),
              _row('Country', c['country']),
            ]),

            const SizedBox(height: 24),

            _statusCard(isActive),
          ],
        ),
      ),
    );
  }

  // ================= UI =================

  Widget _profileCard(Map<String, dynamic> c) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.neonBlue.withOpacity(0.08),
            blurRadius: 20,
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 42,
            backgroundColor: AppColors.primaryBlue.withOpacity(0.15),
            child: const Icon(Icons.business,
                size: 42, color: AppColors.primaryBlue),
          ),
          const SizedBox(height: 14),
          Text(
            c['companyName'] ?? '',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.navy,
            ),
          ),
          const SizedBox(height: 6),
          Text(c['emailAddress'] ?? '',
              style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _section(String title, List<Widget> rows) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.navy)),
        const SizedBox(height: 14),
        ...rows,
      ]),
    );
  }

  Widget _row(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        SizedBox(width: 130, child: Text(label, style: const TextStyle(color: Colors.grey))),
        Expanded(
          child: Text(
            value?.isNotEmpty == true ? value! : '-',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: AppColors.navy,
            ),
          ),
        ),
      ]),
    );
  }

  Widget _statusCard(bool isActive) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Account Status',
                style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.navy)),
            const SizedBox(height: 6),
            Text(
              isActive ? 'Active' : 'Inactive',
              style: TextStyle(
                color: isActive ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ]),

          Switch(
            value: isActive,
            activeColor: AppColors.primaryBlue,
            onChanged: isUpdatingStatus ? null : _toggleStatus,
          ),
        ],
      ),
    );
  }
}
