import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tech_app/cubits/tickets/ticket-state.dart';
import 'package:tech_app/models/ticket-details-model.dart';
import 'package:tech_app/models/ticket-model.dart';
import 'package:tech_app/services/ticket-service.dart';

class TicketsCubit extends Cubit<TicketsState> {
  final TicketService _ticketService;
  List<TicketModel> _allTickets = [];
  List<TicketModel> _filteredTickets = [];
  int _currentPage = 1;
  int _lastPage = 1;
  bool _isLoading = false;
  bool _isFiltered = false;
  String _currentSearchQuery = '';

  TicketsCubit(this._ticketService) : super(TicketsInitial());

  int get currentPage => _currentPage;
  int get lastPage => _lastPage;
  bool get isFiltered => _isFiltered;

  Future<void> fetchTickets({bool refresh = false, int? page}) async {
    if (_isLoading) return;
    _isLoading = true;

    try {
      if (refresh) {
        print('🔄 Refreshing tickets...');
        _currentPage = 1;
        _allTickets.clear();
        _isFiltered = false;
        _currentSearchQuery = '';
        emit(TicketsLoading());
      }

      final pageToFetch = page ?? _currentPage;
      print('📄 Fetching page $pageToFetch...');
      
      final result = await _ticketService.getPaginatedTickets(pageToFetch);
      final newTickets = result['tickets'] as List<TicketModel>;
      
      if (refresh) {
        _allTickets = newTickets;
      } else {
        _allTickets.addAll(newTickets);
      }
      
      _currentPage = result['current_page'] as int;
      _lastPage = result['last_page'] as int;
      
      // Apply current search if exists
      if (_currentSearchQuery.isNotEmpty) {
        _filteredTickets = _filterTickets(_allTickets, _currentSearchQuery);
      } else {
        _filteredTickets = List.from(_allTickets);
      }

      print('✅ Loaded ${newTickets.length} tickets (Total: ${_allTickets.length})');
      print('📊 Current page: $_currentPage, Last page: $_lastPage');

      emit(TicketsLoaded(
        tickets: _isFiltered ? _filteredTickets : _allTickets,
        hasMore: _currentPage < _lastPage && !_isFiltered,
        currentPage: _currentPage,
        lastPage: _lastPage,
        isFiltered: _isFiltered,
      ));
    } catch (e) {
      print('❌ Error fetching tickets: $e');
      emit(TicketsError("Failed to load tickets: ${e.toString()}"));
    } finally {
      _isLoading = false;
    }
  }
  

  void searchTickets(String query) {
    _currentSearchQuery = query;
    
    if (query.isEmpty) {
      _isFiltered = false;
      emit(TicketsLoaded(
        tickets: _allTickets,
        hasMore: _currentPage < _lastPage,
        currentPage: _currentPage,
        lastPage: _lastPage,
        isFiltered: false,
      ));
      return;
    }

    _isFiltered = true;
    _filteredTickets = _filterTickets(_allTickets, query);
    
    emit(TicketsLoaded(
      tickets: _filteredTickets,
      hasMore: false,
      currentPage: _currentPage,
      lastPage: _lastPage,
      isFiltered: true,
    ));
  }

  List<TicketModel> _filterTickets(List<TicketModel> tickets, String query) {
    final lowerCaseQuery = query.toLowerCase();
    return tickets.where((ticket) {
      return ticket.title.toLowerCase().contains(lowerCaseQuery) ||
          ticket.id.toString().contains(lowerCaseQuery);
    }).toList();
  }

  Future<TicketDetailsModel> getTicketDetails(int ticketId) async {
    try {
      print('🔍 Fetching details for ticket ID: $ticketId');
      return await _ticketService.getTicketDetails(ticketId);
    } catch (e) {
      print('❌ Error fetching ticket details: $e');
      rethrow;
    }
  }
  
 Future<TicketModel> getTicketById(int ticketId) async {
  try {
    final ticket = await _ticketService.getTicketById(ticketId);
    return ticket;
  } catch (e) {
    throw Exception('Failed to fetch ticket: $e');
  }
}

  Future<void> goToPage(int page) async {
    if (page < 1 || page > _lastPage) {
      print('⚠️ Invalid page number: $page');
      return;
    }
    print('⏩ Going to page $page');
    await fetchTickets(page: page);
  }

  Future<void> refreshTickets() async {
    await fetchTickets(refresh: true);
  }
}


