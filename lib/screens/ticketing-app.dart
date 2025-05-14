import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:tech_app/Helper/enum-helper.dart';
import 'package:tech_app/cubits/Conversations/conversation-cubit.dart';
import 'package:tech_app/cubits/changePassword/change-pass-cubit.dart';

import 'package:tech_app/cubits/get-chat-cubit.dart';
import 'package:tech_app/cubits/tickets/get-ticket-cubits.dart';
import 'package:tech_app/cubits/login/login-cubit.dart';
import 'package:tech_app/cubits/notifications/notifications-cubit.dart';
import 'package:tech_app/cubits/otp/otp-verification-cubit.dart';
import 'package:tech_app/cubits/profile/profile-cubit.dart';
import 'package:tech_app/cubits/resetPassword/rest-password-cubit.dart';
import 'package:tech_app/cubits/rich-text-cubit.dart';


import 'package:tech_app/screens/all-tickets.dart';
import 'package:tech_app/screens/chande-password.dart';
import 'package:tech_app/screens/conversatins.dart';
import 'package:tech_app/screens/create-new.dart';
import 'package:tech_app/screens/edit-profile.dart';
import 'package:tech_app/screens/login.dart';
import 'package:tech_app/screens/otp-screen.dart';
import 'package:tech_app/screens/profile.dart';
import 'package:tech_app/screens/rest-screen.dart';
import 'package:tech_app/screens/splash-screen.dart';
import 'package:tech_app/screens/user-dashboard.dart';
import 'package:tech_app/services/conversations-service.dart';
import 'package:tech_app/services/login-service.dart';
import 'package:tech_app/services/notifications-services.dart';
import 'package:tech_app/services/resend-otp-api.dart';
import 'package:tech_app/services/send-forget-pass-api.dart';
import 'package:tech_app/services/service-profile.dart';
import 'package:tech_app/services/ticket-service.dart';
import 'package:tech_app/services/verify_user_auth.dart';
class TicketingApp extends StatelessWidget {
  final SharedPreferences sharedPreferences;

  const TicketingApp({super.key, required this.sharedPreferences});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => const FlutterSecureStorage()),
        RepositoryProvider(create: (_) => http.Client()),
        RepositoryProvider(
          create: (context) =>
              AuthService(storage: context.read<FlutterSecureStorage>()),
        ),
        RepositoryProvider(create: (_) => VerifyUserApi()),
        RepositoryProvider(create: (_) => ResendOtpApi()),
        RepositoryProvider(
          create: (context) => ProfileService(
            client: context.read<http.Client>(),
            secureStorage: context.read<FlutterSecureStorage>(),
          ),
        ),
        RepositoryProvider(create: (_) => SendForgetPassApi()),
        RepositoryProvider(create: (_) => TicketService()),
        RepositoryProvider(create: (_) => NotificationService()),
        RepositoryProvider(
          create: (context) => ConversationsService(
            // storage: context.read<FlutterSecureStorage>(),
            // client: context.read<http.Client>(),
          ),
        ),
      ],
      child: Builder(
        builder: (context) {
          return MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (context) =>
                    LoginCubit(authApi: context.read<AuthService>()),
              ),
              BlocProvider(create: (_) => RichTextCubit()),
              BlocProvider(create: (_) => TicketsCubit(context.read<TicketService>())),
              BlocProvider(
                create: (context) =>
                    ProfileCubit(context.read<ProfileService>()),
              ),
              BlocProvider(create: (_) => ChangePasswordCubit()),
              BlocProvider(create: (context) => NotificationsCubit(context.read<NotificationService>())),
              BlocProvider(
                create: (context) => ChatCubit(
                  chatService: context.read<ConversationsService>(),
                ),
              ),
              // Adding the ConversationsCubit here
              BlocProvider(
                create: (context) => ConversationsCubit(
                  conversationsService: context.read<ConversationsService>(),
                ),
              ),
            ],
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              initialRoute: SplashScreen.routeName,
              routes: {
                SplashScreen.routeName: (_) => SplashScreen(),
                LoginScreen.routeName: (_) => LoginScreen(),
                UserDashboard.routeName: (_) => UserDashboard(),
                AllTickets.routeName: (_) => AllTickets(),
                ConversationsScreen.routeName: (context) {
                  // Get arguments passed to the route
                  final args = ModalRoute.of(context)!.settings.arguments 
                      as Map<String, dynamic>? ?? {};
                  
                  return ConversationsScreen(
                    // ticketId: args['ticketId'] as int,
                    // userName: args['userName'] as String,
                  );
                },
                EditProfileScreen.routeName: (_) => EditProfileScreen(),
                Profile.routName: (_) => Profile(),
                ResetPasswordScreen.routeName: (context) {
                  final sendForgetPassApi =
                      RepositoryProvider.of<SendForgetPassApi>(context);
                  return BlocProvider(
                    create: (_) => ResetPasswordCubit(sendForgetPassApi),
                    child: ResetPasswordScreen(),
                  );
                },
                ChangePasswordScreen.routeName: (_) => ChangePasswordScreen(
                      handle: '',
                      verificationCode: '',
                    ),
                OtpVerificationPage.routeName: (context) {
                  final args = ModalRoute.of(context)!.settings.arguments
                      as Map<String, dynamic>;
                  final email = args['email'] as String;
                  final otpType = args['otpType'] as OtpType;
                  return BlocProvider(
                    create: (_) => OtpCubit(
                      context.read<VerifyUserApi>(),
                      context.read<ResendOtpApi>(),
                      email,
                      otpType,
                    ),
                    child: OtpVerificationPage(
                      email: email,
                      otpType: otpType,
                    ),
                  );
                },
              },
              theme: ThemeData(
                primarySwatch: Colors.blue,
                scaffoldBackgroundColor: Colors.white,
              ),
            ),
          );
        },
      ),
    );
  }
}
