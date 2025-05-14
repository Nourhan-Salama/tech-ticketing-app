// import 'package:final_app/cubits/logot-state.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';



// class LogoutCubit extends Cubit<LogoutState> {
//   final FlutterSecureStorage secureStorage;

//   LogoutCubit({FlutterSecureStorage? storage})
//       : secureStorage = storage ?? const FlutterSecureStorage(),
//         super(LogoutInitial());

//   Future<void> logout() async {
//     emit(LogoutLoading());
//     try {
//       await secureStorage.deleteAll();
//       emit(LogoutSuccess('Logged out successfully'));
//     } catch (e) {
//       emit(LogoutFailure('Logout failed: ${e.toString()}'));
//     }
//   }
// }
