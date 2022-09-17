

import 'package:get_it/get_it.dart';
import 'package:thentic_app/cubits/feed/feed_cubit.dart';
import 'package:thentic_app/cubits/navigation/navigation_cubit.dart';
import 'package:thentic_app/cubits/user/user_cubit.dart';
import 'package:thentic_app/cubits/utility/utility_cubit.dart';
import 'package:thentic_app/resources/feed_repository.dart';
import 'package:thentic_app/resources/user_repository.dart';

class AppDIs {
    AppDIs._();
  static void dependencyInjection() {

    //Repositories
    GetIt.I.registerSingleton<UserRepository>(UserRepository());
    GetIt.I.registerSingleton<FeedRepository>(FeedRepository());


    //Cubits
    GetIt.I.registerSingleton<UserCubit>(UserCubit(GetIt.I<UserRepository>()));
    GetIt.I.registerSingleton<FeedCubit>(FeedCubit(GetIt.I<FeedRepository>()));
    GetIt.I.registerSingleton<UtilityCubit>(UtilityCubit());
    GetIt.I.registerSingleton<NavigationCubit>(NavigationCubit());




  }
}