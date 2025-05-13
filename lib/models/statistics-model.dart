// lib/Models/statistics_model.dart
class StatisticsModel {
  final int allTickets;
  final int inProcessingTickets;
  final int closedTickets;
  final int users;
  final List<AnnualTicket> annualTicketsAverage;
  final List<RecentTicket> recentTickets;

  StatisticsModel({
    required this.users,
    required this.allTickets,
    required this.inProcessingTickets,
    required this.closedTickets,
    required this.annualTicketsAverage,
    required this.recentTickets,
  });

  factory StatisticsModel.fromJson(Map<String, dynamic> json) {
  return StatisticsModel(
     users: json['users'] ?? 0,
    allTickets: json['all_tickets'] ?? 0,
    inProcessingTickets: json['in_processing_tickets'] ?? 0,
    closedTickets: json['closed_tickets'] ?? 0,
    annualTicketsAverage: (json['annual_tickets_average'] as List?)
        ?.map((x) => AnnualTicket.fromJson(x))
        .toList() ?? [],
    recentTickets: (json['recent_tickets'] as List?)
        ?.map((x) => RecentTicket.fromJson(x))
        .toList() ?? [],
  );
}
}

class AnnualTicket {
  final int year;
  final int count;

  AnnualTicket({required this.year, required this.count});

  factory AnnualTicket.fromJson(Map<String, dynamic> json) {
    return AnnualTicket(
      year: json['year'] ?? 0,
      count: json['count'] ?? 0,
    );
  }
}

class RecentTicket {
  final int id;
  final int status;
  final String createdAt;

  RecentTicket({
    required this.id,
    required this.status,
    required this.createdAt,
  });

  factory RecentTicket.fromJson(Map<String, dynamic> json) {
    return RecentTicket(
      id: json['id'] ?? 0,
      status: json['status'] ?? 0,
      createdAt: json['created_at'] ?? '',
    );
  }
}

