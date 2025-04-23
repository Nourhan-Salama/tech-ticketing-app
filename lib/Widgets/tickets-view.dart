import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tech_app/Widgets/data-tabel.dart';
import 'package:tech_app/cubits/get-ticket-cubits.dart';
import 'package:tech_app/models/ticket-model.dart';
import 'package:tech_app/util/colors.dart';
import 'package:tech_app/util/responsive-helper.dart';

class TicketsList extends StatefulWidget {
  final List<TicketModel> tickets;
  final bool hasMore;
  final int currentPage;
  final int lastPage;
  final bool isFiltered;

  const TicketsList({
    super.key,
    required this.tickets,
    required this.hasMore,
    required this.currentPage,
    required this.lastPage,
    required this.isFiltered,
  });

  @override
  State<TicketsList> createState() => _TicketsListState();
}

class _TicketsListState extends State<TicketsList> {
  Color _getStatusColor(int status) {
    switch (status) {
      case 0: return Colors.grey;
      case 1: return Colors.blue;
      case 2: return Colors.green;
      case 3: return Colors.red;
      default: return Colors.grey;
    }
  }

  String _getStatusText(int status) {
    switch (status) {
      case 0: return 'Pending';
      case 1: return 'In Progress';
      case 2: return 'Resolved';
      case 3: return 'Closed';
      default: return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.tickets.isEmpty) {
      return Container(height: 0);
    }

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: ColorsHelper.LightGrey),
            borderRadius: BorderRadius.circular(
              ResponsiveHelper.responsiveValue(
                context: context,
                mobile: 8,
                tablet: 12,
                desktop: 16,
              ),
            ),
          ),
          child: ListView.separated(
            separatorBuilder: (context, index) => Divider(
              color: ColorsHelper.LightGrey,
              thickness: 0.5,
              indent: 20,
              endIndent: 20,
            ),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.tickets.length,
            itemBuilder: (context, index) {
              final ticket = widget.tickets[index];
              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveHelper.responsiveValue(
                    context: context,
                    mobile: 12,
                    tablet: 16,
                    desktop: 20,
                  ),
                  vertical: ResponsiveHelper.responsiveValue(
                    context: context,
                    mobile: 8,
                    tablet: 12,
                    desktop: 16,
                  ),
                ),
                child: GestureDetector(
                  onTap: () {},
                  child: DataTableWidget(
                    title: ticket.title,
                    userName: ticket.user.name,
                    status: _getStatusText(ticket.status),
                    statusColor: _getStatusColor(ticket.status),
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 16),
        if (!widget.isFiltered) // Only show pagination when not filtered
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Only show Previous button if not on first page
              if (widget.currentPage > 1) ...[
                ElevatedButton(
                  onPressed: () => context.read<TicketsCubit>().goToPage(widget.currentPage - 1),
                  child: Text('Previous', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorsHelper.darkBlue,
                  ),
                ),
                SizedBox(width: 16),
              ],
              
              Text(
                'Page ${widget.currentPage} of ${widget.lastPage}',
                style: TextStyle(fontSize: 16, color: ColorsHelper.darkGrey),
              ),
              
              SizedBox(width: 16),
              
              // Always show Next button (disabled when on last page)
              ElevatedButton(
                onPressed: widget.currentPage < widget.lastPage
                    ? () => context.read<TicketsCubit>().goToPage(widget.currentPage + 1)
                    : null,
                child: Text('Next', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.currentPage < widget.lastPage
                      ? ColorsHelper.darkBlue
                      : Colors.grey,
                ),
              ),
            ],
          ),
        SizedBox(height: 16),
      ],
    );
  }
}