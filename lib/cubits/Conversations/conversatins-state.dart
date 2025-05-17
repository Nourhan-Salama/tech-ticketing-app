import 'package:equatable/equatable.dart';
import 'package:tech_app/models/conversation-model.dart';

abstract class ConversationsState extends Equatable {
  const ConversationsState();

  @override
  List<Object?> get props => [];
}

class ConversationsInitial extends ConversationsState {}

class ConversationsLoading extends ConversationsState {}

class ConversationsEmpty extends ConversationsState {}

class ConversationsLoaded extends ConversationsState {
  final List<Conversation> allConversations;
  final List<Conversation> filteredConversations;

  const ConversationsLoaded({
    required this.allConversations,
    required this.filteredConversations,
  });

  ConversationsLoaded copyWith({
    List<Conversation>? allConversations,
    List<Conversation>? filteredConversations,
  }) {
    return ConversationsLoaded(
      allConversations: allConversations ?? this.allConversations,
      filteredConversations: filteredConversations ?? this.filteredConversations,
    );
  }

  @override
  List<Object?> get props => [allConversations, filteredConversations];
}

class ConversationsError extends ConversationsState {
  final String message;

  const ConversationsError(this.message);

  @override
  List<Object?> get props => [message];
}

// // cubits/conversations/conversations_state.dart
// import 'package:equatable/equatable.dart';
// import 'package:tech_app/models/conversation-model.dart';

// abstract class ConversationsState extends Equatable {
//   const ConversationsState();

//   @override
//   List<Object?> get props => [];
// }

// class ConversationsInitial extends ConversationsState {}

// class ConversationsLoading extends ConversationsState {}

// class ConversationsLoaded extends ConversationsState {
//   final List<Conversation> allConversations;
//   final List<Conversation> filteredConversations;

//   const ConversationsLoaded({
//     required this.allConversations,
//     required this.filteredConversations,
//   });

//   ConversationsLoaded copyWith({
//     List<Conversation>? allConversations,
//     List<Conversation>? filteredConversations,
//   }) {
//     return ConversationsLoaded(
//       allConversations: allConversations ?? this.allConversations,
//       filteredConversations: filteredConversations ?? this.filteredConversations,
//     );
//   }

//   @override
//   List<Object?> get props => [allConversations, filteredConversations];
// }

// class ConversationsError extends ConversationsState {
//   final String message;

//   const ConversationsError(this.message);

//   @override
//   List<Object?> get props => [message];
// }