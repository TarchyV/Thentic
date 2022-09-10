part of 'user_cubit.dart';

@immutable
abstract class UserState {}

class UserInitial extends UserState {}

class UserLoggedIn extends UserState {
  final String userId;
  final List<String> following;
  UserLoggedIn(this.userId, this.following);
}

class UserLoggedOut extends UserState {}

class UserLoading extends UserState {}

