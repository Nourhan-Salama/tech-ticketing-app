import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tech_app/Helper/app-bar.dart';
import 'package:tech_app/Widgets/drawer.dart';
import 'package:tech_app/Widgets/tickets-view.dart';
import 'package:tech_app/cubits/tickets/get-ticket-cubits.dart';
import 'package:tech_app/cubits/tickets/ticket-state.dart';
import 'package:tech_app/util/responsive-helper.dart';

class AllTickets extends StatefulWidget {
  static const routeName = '/all-tickets';

  @override
  State<AllTickets> createState() => _AllTicketsState();
}

class _AllTicketsState extends State<AllTickets> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('🏁 Initializing tickets fetch...');
      context.read<TicketsCubit>().fetchTickets(refresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);

    return Scaffold(
      backgroundColor: Colors.white,
      drawer: MyDrawer(),
      appBar: CustomAppBar(title: 'All Tickets'),
      body: BlocConsumer<TicketsCubit, TicketsState>(
        listener: (context, state) {
          if (state is TicketsError) {
            print('🚨 Error state: ${state.message}');
          }
        },
        builder: (context, state) {
          if (state is TicketsLoading && state is! TicketsLoaded) {
            return Center(child: CircularProgressIndicator());
          } else if (state is TicketsError) {
            return Center(child: Text(state.message));
          } else if (state is TicketsEmpty) {
            return Center(child: Text('No tickets found'));
          } else if (state is TicketsLoaded) {
            if (state.tickets.isEmpty) {
              return Center(child: Text('No tickets to show'));
            }
            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveHelper.responsiveValue(
                    context: context,
                    mobile: 16,
                    tablet: 24,
                    desktop: 32,
                  ),
                  vertical: 5,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: ResponsiveHelper.responsiveValue(
                      context: context,
                      mobile: 16,
                      tablet: 24,
                      desktop: 32,
                    )),
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Search',
                        hintStyle: TextStyle(
                          fontSize: ResponsiveHelper.responsiveTextSize(context, 16),
                        ),
                        prefixIcon: Icon(Icons.search, size: isMobile ? 20 : 24),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            ResponsiveHelper.responsiveValue(
                              context: context,
                              mobile: 12,
                              tablet: 16,
                              desktop: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: ResponsiveHelper.responsiveValue(
                      context: context,
                      mobile: 16,
                      tablet: 24,
                      desktop: 32,
                    )),
                    TicketsList(
                      tickets: state.tickets,
                      hasMore: state.hasMore,
                      currentPage: state.currentPage,
                      lastPage: state.lastPage,
                      isFiltered: state.isFiltered,
                    ),
                  
                    SizedBox(height: 32),
                  ],
                ),
              ),
            );
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}


