// import 'package:flutter/material.dart';
//
// import '../../core/theme/app_colors.dart';
// import '../shared/widgets/admin_drawer.dart';
//
// import 'sections/enquiry_analytics_section.dart';
// import 'sections/quotation_analytics_section.dart';
// import 'sections/loi_analytics_section.dart';
// import 'sections/client_movement_section.dart';
//
// class AdminDashboardScreen extends StatefulWidget {
//   const AdminDashboardScreen({super.key});
//
//   @override
//   State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
// }
//
// class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
//   final PageController _pageController = PageController();
//   int _currentIndex = 0;
//
//   final List<String> _titles = ['Enquiry', 'Quotation', 'LOI'];
//
//   void _onTabTap(int index) {
//     setState(() => _currentIndex = index);
//     _pageController.animateToPage(
//       index,
//       duration: const Duration(milliseconds: 300),
//       curve: Curves.easeInOut,
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final screenHeight = MediaQuery.of(context).size.height;
//
//     return Scaffold(
//       drawer: const AdminDrawer(currentRoute: '/adminDashboard'),
//       backgroundColor: AppColors.lightGrey,
//
//       appBar: AppBar(
//         backgroundColor: AppColors.navy,
//         elevation: 0,
//         iconTheme: const IconThemeData(color: Colors.white),
//         title: const Text(
//           'Admin Dashboard',
//           style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//         ),
//       ),
//
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.only(bottom: 20),
//         child: Column(
//           children: [
//             _SwapHeader(
//               titles: _titles,
//               currentIndex: _currentIndex,
//               onTap: _onTabTap,
//             ),
//
//             const SizedBox(height: 16),
//
//             SizedBox(
//               height: MediaQuery.of(context).size.height*0.80,
//               child: PageView(
//                 controller: _pageController,
//                 onPageChanged: (index) {
//                   setState(() => _currentIndex = index);
//                 },
//                 children: const [
//                   Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 20),
//                     child: EnquiryAnalyticsSection(),
//                   ),
//                   Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 20),
//                     child: QuotationAnalyticsSection(),
//                   ),
//                   Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 20),
//                     child: LoiAnalyticsSection(),
//                   ),
//                 ],
//               ),
//             ),
//
//             const SizedBox(height: 16),
//
//             const Padding(
//               padding: EdgeInsets.symmetric(horizontal: 20),
//               child: ClientMovementSection(),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class _SwapHeader extends StatelessWidget {
//   final List<String> titles;
//   final int currentIndex;
//   final Function(int) onTap;
//
//   const _SwapHeader({
//     required this.titles,
//     required this.currentIndex,
//     required this.onTap,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 20),
//       padding: const EdgeInsets.all(6),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Row(
//         children: List.generate(titles.length, (index) {
//           final isActive = index == currentIndex;
//
//           return Expanded(
//             child: GestureDetector(
//               onTap: () => onTap(index),
//               child: AnimatedContainer(
//                 duration: const Duration(milliseconds: 250),
//                 padding: const EdgeInsets.symmetric(vertical: 12),
//                 decoration: BoxDecoration(
//                   color: isActive
//                       ? AppColors.primaryBlue
//                       : Colors.transparent,
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: Text(
//                   titles[index],
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     color: isActive ? Colors.white : Colors.black87,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ),
//           );
//         }),
//       ),
//     );
//   }
// }
