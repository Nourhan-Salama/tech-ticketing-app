import 'package:flutter/material.dart';
import 'package:tech_app/models/ticket-model.dart';

@immutable
abstract class TicketsState {
  const TicketsState();
}

class TicketsInitial extends TicketsState {
  const TicketsInitial();
}

class TicketsLoading extends TicketsState {
  const TicketsLoading();
}

class TicketsLoaded extends TicketsState {
  final List<TicketModel> tickets;
  final bool hasMore;
  final int currentPage;
  final int lastPage;
  final bool isFiltered;

  const TicketsLoaded({
    required this.tickets,
    required this.hasMore,
    required this.currentPage,
    required this.lastPage,
    required this.isFiltered,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TicketsLoaded &&
        other.tickets == tickets &&
        other.hasMore == hasMore &&
        other.currentPage == currentPage &&
        other.lastPage == lastPage &&
        other.isFiltered == isFiltered;
  }

  @override
  int get hashCode {
    return tickets.hashCode ^
        hasMore.hashCode ^
        currentPage.hashCode ^
        lastPage.hashCode ^
        isFiltered.hashCode;
  }
}

class TicketsError extends TicketsState {
  final String message;
  const TicketsError(this.message);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TicketsError && other.message == message;
  }

  @override
  int get hashCode => message.hashCode;
}

class TicketsEmpty extends TicketsState {
  const TicketsEmpty();
}


// import 'package:flutter/material.dart';
// import 'package:tech_app/models/ticket-model.dart';

// @immutable
// abstract class TicketsState {}

// class TicketsInitial extends TicketsState {}

// class TicketsLoading extends TicketsState {}

// class TicketsLoaded extends TicketsState {
//   final List<TicketModel> tickets;
//   final bool hasMore;
//   final int currentPage;
//   final int lastPage;
//   final bool isFiltered;

//   TicketsLoaded({
//     required this.tickets,
//     required this.hasMore,
//     required this.currentPage,
//     required this.lastPage,
//     required this.isFiltered,
//   });
// }

// class TicketsError extends TicketsState {
//   final String message;
//   TicketsError(this.message);
// }

// class TicketsEmpty extends TicketsState {}

