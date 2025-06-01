import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tech_app/cubits/localization/localization-state.dart';
import 'package:tech_app/services/localization-service.dart';


class LocalizationCubit extends Cubit<LocalizationState> {
  final LocalizationService _service;

  LocalizationCubit(this._service) : super(LocalizationInitial());

  Future<void> updateLocale(String locale) async {
    emit(LocalizationLoading());
    try {
      await _service.updateLocale(locale);
      emit(LocalizationSuccess());
    } catch (e) {
      emit(LocalizationError(e.toString()));
    }
  }
}
