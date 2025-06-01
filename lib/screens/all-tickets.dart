import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
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
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('🏁 Initializing tickets fetch...');
      context.read<TicketsCubit>().fetchTickets(refresh: true);
    });
    
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_searchDebounce?.isActive ?? false) _searchDebounce?.cancel();
    
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      final query = _searchController.text.trim();
      context.read<TicketsCubit>().searchTickets(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);

    return Scaffold(
      backgroundColor: Colors.white,
      drawer: MyDrawer(),
      appBar: CustomAppBar(title: 'allTickets'.tr()),
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
            return Center(child: Text('no_tickets_found'.tr()));
          } else if (state is TicketsLoaded) {
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
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'search_hint'.tr(),
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
                    if (state.tickets.isEmpty)
                      Center(child: Text('no_tickets_to_show').tr())
                    else
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


