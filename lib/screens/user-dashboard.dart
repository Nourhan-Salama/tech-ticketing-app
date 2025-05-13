import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:tech_app/Helper/app-bar.dart';
import 'package:tech_app/Helper/card-ticket.dart';
import 'package:tech_app/Widgets/drawer.dart';
import 'package:tech_app/models/statistics-model.dart';
import 'package:tech_app/services/statistics.dart';
import 'package:tech_app/util/colors.dart';
import 'package:tech_app/util/responsive-helper.dart';

class UserDashboard extends StatefulWidget {
  static const String routeName = "/user-dashboard";
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  final StatisticsService _statisticsService = StatisticsService();
  late Future<StatisticsModel> _statisticsFuture;

  @override
  void initState() {
    super.initState();
    _statisticsFuture = _statisticsService.getTechnicianStatistics();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MyDrawer(),
      appBar: const CustomAppBar(title: 'Dashboard'),
      body: FutureBuilder<StatisticsModel>(
        future: _statisticsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('No data available'));
          }

          final stats = snapshot.data!;
          final annualData = stats.annualTicketsAverage;
          final recentData = stats.recentTickets;

          // Generating daily respond data for Bar Chart
          final List<BarChartGroupData> dailyRespondData = recentData.isNotEmpty
              ? List.generate(recentData.length, (i) {
                  return BarChartGroupData(x: i, barRods: [
                    BarChartRodData(
                      toY: recentData[i].status.toDouble(),
                      color: Colors.deepPurple,
                      borderRadius: BorderRadius.circular(4),
                      width: 14,
                    ),
                  ]);
                })
              : [];

          double maxY = annualData.isNotEmpty
              ? annualData.map((e) => e.count).reduce((a, b) => a > b ? a : b).toDouble() + 1
              : 10;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status Cards
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 0.85,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  children: [
                    StatusCard(
                      icon: Icons.airplane_ticket,
                      title: 'All Tickets',
                      value: stats.allTickets.toString(),
                      percentage: stats.allTickets.toDouble(),
                    ),
                    StatusCard(
                      icon: Icons.airplane_ticket,
                      title: 'In Progress',
                      value: stats.inProcessingTickets.toString(),
                      percentage: stats.allTickets > 0
                          ? (stats.inProcessingTickets / stats.allTickets) * 100
                          : 0,
                    ),
                    StatusCard(
                      icon: Icons.airplane_ticket,
                      title: 'Closed Tickets',
                      value: stats.closedTickets.toString(),
                      percentage: stats.allTickets > 0
                          ? (stats.closedTickets / stats.allTickets) * 100
                          : 0,
                    ),
                    StatusCard(
                      icon: Icons.group,
                      title: 'Users',
                      value: (stats.users ?? 0).toString(),
                      percentage: (stats.users ?? 0).toDouble(),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Daily Respond Bar Chart
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
                        child: dailyRespondData.isNotEmpty
                            ? BarChart(
                                BarChartData(
                                  alignment: BarChartAlignment.spaceAround,
                                  gridData: const FlGridData(show: false),
                                  titlesData: FlTitlesData(
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        interval: 1,
                                        getTitlesWidget: (value, meta) {
                                          if (value.toInt() < recentData.length) {
                                            final year = DateTime.parse(recentData[value.toInt()].createdAt).year.toString();
                                            return Text(
                                              year,
                                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                                            );
                                          }
                                          return const Text('');
                                        },
                                      ),
                                    ),
                                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  ),
                                  borderData: FlBorderData(show: false),
                                  barGroups: dailyRespondData,
                                ),
                              )
                            : const Center(child: Text('No recent tickets data')),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Annual Tickets Average Line Chart
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
                        child: annualData.isNotEmpty
                            ? LineChart(
                                LineChartData(
                                  minX: 0,
                                  maxX: (annualData.length - 1).toDouble(),
                                  minY: 0,
                                  maxY: maxY,
                                  gridData: const FlGridData(show: false),
                                  titlesData: FlTitlesData(
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        interval: 1,
                                        getTitlesWidget: (value, meta) {
                                          if (value.toInt() < annualData.length) {
                                            return Padding(
                                              padding: const EdgeInsets.only(top: 8.0),
                                              child: Text(
                                                annualData[value.toInt()].year.toString(),
                                                style: const TextStyle(fontSize: 12, color: Colors.grey),
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
                                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                                          );
                                        },
                                      ),
                                    ),
                                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  ),
                                  borderData: FlBorderData(
                                    show: true,
                                    border: Border.all(color: Colors.grey.withOpacity(0.2), width: 1),
                                  ),
                                  lineBarsData: [
                                    LineChartBarData(
                                      spots: annualData.asMap().entries.map((entry) {
                                        return FlSpot(entry.key.toDouble(), entry.value.count.toDouble());
                                      }).toList(),
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
                                    ),
                                  ],
                                ),
                              )
                            : const Center(child: Text('No annual tickets data')),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          );
        },
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
//           ],
//         ),
//       ),
//     );
//   }
// }


