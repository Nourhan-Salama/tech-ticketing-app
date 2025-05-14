
import 'package:tech_app/models/statistics-model.dart';

abstract class StatisticsState {}

class StatisticsInitial extends StatisticsState {}

class StatisticsLoading extends StatisticsState {}

class StatisticsLoaded extends StatisticsState {
  final StatisticsModel statistics;

  StatisticsLoaded(this.statistics);
}

class StatisticsError extends StatisticsState {
  final String message;

  StatisticsError(this.message);
}