import 'package:flutter/material.dart';

import '../shared/widgets/admin_drawer.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/loading_indicator.dart';
import 'services/sales_manager_service.dart';
import 'sales_manager_detail_screen.dart';

class SalesManagerListScreen extends StatefulWidget {
  const SalesManagerListScreen({super.key});

  @override
  State<SalesManagerListScreen> createState() =>
      _SalesManagerListScreenState();
}

class _SalesManagerListScreenState extends State<SalesManagerListScreen> {
  String query = '';
  late Future<List<Map<String, dynamic>>> _managersFuture;

  @override
  void initState() {
    super.initState();
    _loadManagers();
  }

  void _loadManagers() {
    _managersFuture = SalesManagerService().getSalesManagers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AdminDrawer(currentRoute: '/salesManagers'),
      backgroundColor: AppColors.lightGrey,

      appBar: AppBar(
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        title: const Text(
          'Sales Managers',
          style: TextStyle(color: Colors.white),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.pushNamed(context, '/createSalesManager');
          _loadManagers();
          setState(() {});
        },
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),

      body: Column(
        children: [
          // 🔍 SEARCH BAR
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search sales manager',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (v) => setState(() => query = v.toLowerCase()),
            ),
          ),

          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _managersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingIndicator(
                    message: 'Loading sales managers...',
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(snapshot.error.toString()),
                  );
                }

                final managers = (snapshot.data ?? [])
                    .where((m) =>
                (m['name'] ?? '')
                    .toLowerCase()
                    .contains(query) ||
                    (m['email'] ?? '')
                        .toLowerCase()
                        .contains(query))
                    .toList();

                if (managers.isEmpty) {
                  return const EmptyState(
                    title: 'No Sales Managers',
                    message: 'Tap + to create one',
                    icon: Icons.groups_outlined,
                  );
                }

                return RefreshIndicator(
                  color: AppColors.primaryBlue,
                  onRefresh: () async {
                    _loadManagers();
                    setState(() {});
                    await _managersFuture;
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: managers.length,
                    itemBuilder: (context, index) {
                      final m = managers[index];
                      final isActive = m['status'] == 'active';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.neonBlue.withOpacity(0.08),
                              blurRadius: 16,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // 👤 AVATAR
                            CircleAvatar(
                              radius: 26,
                              backgroundColor:
                              AppColors.primaryBlue.withOpacity(0.15),
                              child: const Icon(
                                Icons.person,
                                color: AppColors.primaryBlue,
                              ),
                            ),

                            const SizedBox(width: 14),

                            // 📄 INFO
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    m['name'] ?? '',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.navy,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    m['email'] ?? '',
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // 🔁 STATUS
                            Column(
                              children: [
                                Switch(
                                  value: isActive,
                                  activeColor:
                                  AppColors.primaryBlue,
                                  onChanged: (v) async {
                                    await SalesManagerService()
                                        .toggleStatus(
                                      managerId: m['managerId'],
                                      activate: v,
                                    );
                                    _loadManagers();
                                    setState(() {});
                                  },
                                ),
                                Text(
                                  isActive ? 'ACTIVE' : 'INACTIVE',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: isActive
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ).inkWell(
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  SalesManagerDetailScreen(
                                    managerId: m['managerId'],
                                  ),
                            ),
                          );
                          _loadManagers();
                          setState(() {});
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// 🪄 Clean InkWell on Container
extension _InkWellExt on Widget {
  Widget inkWell({required VoidCallback onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: this,
      ),
    );
  }
}
