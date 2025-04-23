import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tech_app/Helper/app-bar.dart';
import 'package:tech_app/Helper/card-ticket.dart';
import 'package:tech_app/Widgets/drawer.dart';
import 'package:tech_app/cubits/get-ticket-cubits.dart';
import 'package:tech_app/cubits/ticket-state.dart';
import 'package:tech_app/util/colors.dart';
import 'package:tech_app/util/responsive-helper.dart';

class UserDashboard extends StatefulWidget {
  static const String routeName = "/user-dashboard";
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMoreTickets();
    }
  }

  void _loadMoreTickets() {
    if (!_isLoadingMore) {
      setState(() => _isLoadingMore = true);
      context.read<TicketsCubit>().fetchTickets().then((_) {
        setState(() => _isLoadingMore = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MyDrawer(),
      appBar: const CustomAppBar(title: 'Dashboard'),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dashboard Cards
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 0.85,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: const [
                StatusCard(
                  icon: Icons.airplane_ticket,
                  title: 'All Tickets',
                  value: '7',
                  percentage: 100,
                ),
                StatusCard(
                  icon: Icons.airplane_ticket,
                  title: 'Open Tickets',
                  value: '3',
                  percentage: 30,
                ),
                StatusCard(
                  icon: Icons.airplane_ticket,
                  title: 'Closed Tickets',
                  value: '4',
                  percentage: 70,
                ),
                StatusCard(
                  icon: Icons.group,
                  title: 'Users',
                  value: '5',
                  percentage: 100,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Bar Chart
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Daily Respond',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 200,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        gridData: const FlGridData(show: false),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 1,
                              getTitlesWidget: (value, meta) {
                                const days = ['Sat', 'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
                                return Text(
                                  days[value.toInt()],
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                );
                              },
                            ),
                          ),
                          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(show: false),
                        barGroups: List.generate(7, (i) {
                          final heights = [5, 7, 10, 8, 6, 4, 3];
                          return BarChartGroupData(x: i, barRods: [
                            BarChartRodData(
                              toY: heights[i].toDouble(),
                              color: Colors.deepPurple,
                              borderRadius: BorderRadius.circular(4),
                              width: 14,
                            ),
                          ]);
                        }),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Curved Line Chart
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Annual tickets average',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 200,
                    child: LineChart(
                      LineChartData(
                        minX: 0,
                        maxX: 4,
                        minY: 0,
                        maxY: 5,
                        gridData: const FlGridData(show: false),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 1,
                              getTitlesWidget: (value, meta) {
                                const years = ['2021', '2022', '2023', '2024', '2025'];
                                if (value.toInt() < years.length) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      years[value.toInt()],
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  );
                                }
                                return const Text('');
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 1,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  value.toInt().toString(),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                );
                              },
                            ),
                          ),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(
                          show: true,
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            spots: const [
                              FlSpot(0, 1),
                              FlSpot(1, 2.5),
                              FlSpot(2, 1.5),
                              FlSpot(3, 3),
                              FlSpot(4, 4),
                            ],
                            isCurved: true,
                            curveSmoothness: 0.3,
                            color: ColorsHelper.darkBlue,
                            barWidth: 4,
                            isStrokeCapRound: true,
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, barData, index) {
                                return FlDotCirclePainter(
                                  radius: 4,
                                  color: ColorsHelper.darkBlue,
                                  strokeWidth: 2,
                                  strokeColor: Colors.white,
                                );
                              },
                            ),
                            belowBarData: BarAreaData(
                              show: true,
                              gradient: LinearGradient(
                                colors: [
                                  Colors.blue.withOpacity(0.3),
                                  Colors.blue.withOpacity(0.1),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                            shadow: const Shadow(
                              color: Colors.blue,
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}



// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:tech_app/Helper/app-bar.dart';
// import 'package:tech_app/Helper/card-ticket.dart';
// import 'package:tech_app/Widgets/drawer.dart';
// import 'package:tech_app/cubits/get-ticket-cubits.dart';
// import 'package:tech_app/cubits/ticket-state.dart';
// import 'package:tech_app/util/colors.dart';
// import 'package:tech_app/Widgets/data-tabel.dart';
// import 'package:tech_app/util/responsive-helper.dart';

// class UserDashboard extends StatefulWidget {
//   static const String routeName = "/user-dashboard";
//   const UserDashboard({super.key});

//   @override
//   State<UserDashboard> createState() => _UserDashboardState();
// }

// class _UserDashboardState extends State<UserDashboard> {
//   final ScrollController _scrollController = ScrollController();
//   bool _isLoadingMore = false;

//   @override
//   void initState() {
//     super.initState();
//     //context.read<TicketsCubit>().fetchTickets(isInitial: true);
//     _scrollController.addListener(_onScroll);
//   }

//   @override
//   void dispose() {
//     _scrollController.dispose();
//     super.dispose();
//   }

//   void _onScroll() {
//     if (_scrollController.position.pixels ==
//         _scrollController.position.maxScrollExtent) {
//       _loadMoreTickets();
//     }
//   }

//   void _loadMoreTickets() {
//     if (!_isLoadingMore) {
//       setState(() => _isLoadingMore = true);
//       context.read<TicketsCubit>().fetchTickets().then((_) {
//         setState(() => _isLoadingMore = false);
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       drawer: const MyDrawer(),
//       appBar: const CustomAppBar(title: 'Dashboard'),
//       body: SingleChildScrollView(
//         controller: _scrollController,
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Dashboard Cards 
//             GridView.count(
//               crossAxisCount: 2,
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               childAspectRatio: 0.85,
//               mainAxisSpacing: 12,
//               crossAxisSpacing: 12,
//               children: const [
//                 StatusCard(
//                   icon: Icons.airplane_ticket,
//                   title: 'All Tickets',
//                   value: '7',
//                   percentage: 100,
//                 ),
//                 StatusCard(
//                   icon: Icons.airplane_ticket,
//                   title: 'Open Tickets',
//                   value: '3',
//                   percentage: 30,
//                 ),
//                 StatusCard(
//                   icon: Icons.airplane_ticket,
//                   title: 'Closed Tickets',
//                   value: '4',
//                   percentage: 70,
//                 ),
//                 StatusCard(
//                   icon: Icons.group,
//                   title: 'Users',
//                   value: '5',
//                   percentage: 100,
//                 ),
//               ],
//             ),

//             const SizedBox(height: 24),

//             // Bar Chart 
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(16),
//                 border: Border.all(color: Colors.grey),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.05),
//                     blurRadius: 10,
//                     offset: const Offset(0, 4),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     'Daily Respond',
//                     style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
//                   ),
//                   const SizedBox(height: 12),
//                   SizedBox(
//                     height: 200,
//                     child: BarChart(
//                       BarChartData(
//                         alignment: BarChartAlignment.spaceAround,
//                         gridData: const FlGridData(show: false),
//                         titlesData: FlTitlesData(
//                           bottomTitles: AxisTitles(
//                             sideTitles: SideTitles(
//                               showTitles: true,
//                               interval: 1,
//                               getTitlesWidget: (value, meta) {
//                                 const days = ['Sat', 'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
//                                 return Text(
//                                   days[value.toInt()],
//                                   style: const TextStyle(fontSize: 12, color: Colors.grey),
//                                 );
//                               },
//                             ),
//                           ),
//                           leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//                           rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//                           topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//                         ),
//                         borderData: FlBorderData(show: false),
//                         barGroups: List.generate(7, (i) {
//                           final heights = [5, 7, 10, 8, 6, 4, 3];
//                           return BarChartGroupData(x: i, barRods: [
//                             BarChartRodData(
//                               toY: heights[i].toDouble(),
//                               color: Colors.deepPurple,
//                               borderRadius: BorderRadius.circular(4),
//                               width: 14,
//                             ),
//                           ]);
//                         }),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 24),

//             // Curved Line Chart
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(16),
//                 border: Border.all(color: Colors.grey),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.05),
//                     blurRadius: 10,
//                     offset: const Offset(0, 4),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     'Annual tickets average',
//                     style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
//                   ),
//                   const SizedBox(height: 12),
//                   SizedBox(
//                     height: 200,
//                     child: LineChart(
//                       LineChartData(
//                         minX: 0,
//                         maxX: 4,
//                         minY: 0,
//                         maxY: 5,
//                         gridData: const FlGridData(show: false),
//                         titlesData: FlTitlesData(
//                           bottomTitles: AxisTitles(
//                             sideTitles: SideTitles(
//                               showTitles: true,
//                               interval: 1,
//                               getTitlesWidget: (value, meta) {
//                                 const years = ['2021', '2022', '2023', '2024', '2025'];
//                                 if (value.toInt() < years.length) {
//                                   return Padding(
//                                     padding: const EdgeInsets.only(top: 8.0),
//                                     child: Text(
//                                       years[value.toInt()],
//                                       style: const TextStyle(
//                                         fontSize: 12,
//                                         color: Colors.grey,
//                                       ),
//                                     ),
//                                   );
//                                 }
//                                 return const Text('');
//                               },
//                             ),
//                           ),
//                           leftTitles: AxisTitles(
//                             sideTitles: SideTitles(
//                               showTitles: true,
//                               interval: 1,
//                               getTitlesWidget: (value, meta) {
//                                 return Text(
//                                   value.toInt().toString(),
//                                   style: const TextStyle(
//                                     fontSize: 12,
//                                     color: Colors.grey,
//                                   ),
//                                 );
//                               },
//                             ),
//                           ),
//                           rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//                           topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//                         ),
//                         borderData: FlBorderData(
//                           show: true,
//                           border: Border.all(
//                             color: Colors.grey.withOpacity(0.2),
//                             width: 1,
//                           ),
//                         ),
//                         lineBarsData: [
//                           LineChartBarData(
//                             spots: const [
//                               FlSpot(0, 1),
//                               FlSpot(1, 2.5),
//                               FlSpot(2, 1.5),
//                               FlSpot(3, 3),
//                               FlSpot(4, 4),
//                             ],
//                             isCurved: true,
//                             curveSmoothness: 0.3,
//                             color: ColorsHelper.darkBlue,
//                             barWidth: 4,
//                             isStrokeCapRound: true,
//                             dotData: FlDotData(
//                               show: true,
//                               getDotPainter: (spot, percent, barData, index) {
//                                 return FlDotCirclePainter(
//                                   radius: 4,
//                                   color: ColorsHelper.darkBlue,
//                                   strokeWidth: 2,
//                                   strokeColor: Colors.white,
//                                 );
//                               },
//                             ),
//                             belowBarData: BarAreaData(
//                               show: true,
//                               gradient: LinearGradient(
//                                 colors: [
//                                   Colors.blue.withOpacity(0.3),
//                                   Colors.blue.withOpacity(0.1),
//                                 ],
//                                 begin: Alignment.topCenter,
//                                 end: Alignment.bottomCenter,
//                               ),
//                             ),
//                             shadow: const Shadow(
//                               color: Colors.blue,
//                               blurRadius: 8,
//                               offset: Offset(0, 2),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 24),

//             // Recent Tickets Section
//             const Text(
//               'Recent Tickets',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 12),
            
//             // Tickets List
//             BlocBuilder<TicketsCubit, TicketsState>(
//               builder: (context, state) {
//                 if (state is TicketsLoading && state is! TicketsLoaded) {
//                   return const Center(child: CircularProgressIndicator());
//                 }
//                 else if (state is TicketsError) {
//                   return Center(
//                     child: Text(
//                       state.message, 
//                       style: TextStyle(color: ColorsHelper.LightGrey),
//                     ),
//                   );
//                 }
//                 else if (state is TicketsEmpty) {
//                   return Center(
//                     child: Text(
//                       'No tickets available',
//                       style: TextStyle(color: Colors.grey),
//                     ),
//                   );
//                 }
//                 else if (state is TicketsLoaded) {
//                   return Column(
//                     children: [
//                       Container(
//                         decoration: BoxDecoration(
//                           border: Border.all(color: ColorsHelper.LightGrey),
//                           borderRadius: BorderRadius.circular(
//                             ResponsiveHelper.responsiveValue(
//                               context: context,
//                               mobile: 8,
//                               tablet: 12,
//                               desktop: 16,
//                             ),
//                           ),
//                         ),
//                         child: ListView.separated(
//                           separatorBuilder: (context, index) => Divider(
//                             color: ColorsHelper.LightGrey,
//                             thickness: 0.5,
//                             indent: 20,
//                             endIndent: 20,
//                           ),
//                           shrinkWrap: true,
//                           physics: const NeverScrollableScrollPhysics(),
//                           itemCount: state.tickets.length,
//                           itemBuilder: (context, index) {
//                             final ticket = state.tickets[index];
//                             return Padding(
//                               padding: EdgeInsets.symmetric(
//                                 horizontal: ResponsiveHelper.responsiveValue(
//                                   context: context,
//                                   mobile: 12,
//                                   tablet: 16,
//                                   desktop: 20,
//                                 ),
//                                 vertical: ResponsiveHelper.responsiveValue(
//                                   context: context,
//                                   mobile: 8,
//                                   tablet: 12,
//                                   desktop: 16,
//                                 ),
//                               ),
//                               // child: DataTableWidget(
//                               //   description: ticket.description,
//                               //   userName: ticket.userName,
//                               //   status: ticket.statusText,
//                               //   statusColor: ticket.statusColor,
//                               // ),
//                             );
//                           },
//                         ),
//                       ),
//                       // if (_isLoadingMore)
//                       //   const Padding(
//                       //     padding: EdgeInsets.all(16.0),
//                       //     child: Center(child: CircularProgressIndicator()),
//                       //   ),
//                       // if (state.hasMore && !_isLoadingMore)
//                       //   Padding(
//                       //     padding: const EdgeInsets.all(16.0),
//                       //     child: Center(
//                       //       child: ElevatedButton(
//                       //         onPressed: _loadMoreTickets,
//                       //         child: const Text('Load More'),
//                       //       ),
//                       //     ),
//                       //   ),
//                     ],
//                   );
//                 }
//                 return const Center(child: Text("Unknown state")); 
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


