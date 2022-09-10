import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:thentic_app/resources/feed_repository.dart';
import 'package:thentic_app/resources/user_repository.dart';

class AppRepositoryProviders {
  AppRepositoryProviders._();
  static final List<RepositoryProvider<dynamic>> repositoryProviders = [
     RepositoryProvider<FeedRepository>(
       create: (context) => GetIt.I<FeedRepository>(),
     ),
     RepositoryProvider<UserRepository>(
       create: (context) => GetIt.I<UserRepository>(),
     ),
  ];


}