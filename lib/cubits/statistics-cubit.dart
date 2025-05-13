import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tech_app/cubits/statistics-state.dart';
import 'package:tech_app/services/statistics.dart';

class StatisticsCubit extends Cubit<StatisticsState> {
  final StatisticsService statisticsService;

  StatisticsCubit(this.statisticsService) : super(StatisticsInitial());

  Future<void> getStatistics() async {
    try {
      emit(StatisticsLoading());
      final stats = await statisticsService.getTechnicianStatistics();
      emit(StatisticsLoaded(stats));
    } catch (e) {
      emit(StatisticsError(e.toString()));
    }
  }
}
