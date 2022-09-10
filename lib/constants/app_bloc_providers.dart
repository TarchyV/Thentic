import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:thentic_app/cubits/feed/feed_cubit.dart';
import 'package:thentic_app/cubits/user/user_cubit.dart';
import 'package:thentic_app/cubits/utility/utility_cubit.dart';


class AppBlocProviders {
  AppBlocProviders._();
    static final List<BlocProvider<dynamic>> blocProviders = [
      BlocProvider<UserCubit>(
        create: (context) => GetIt.I<UserCubit>(),
      ),
      BlocProvider<FeedCubit>(
        create: (context) => GetIt.I<FeedCubit>(),
      ),
      BlocProvider<UtilityCubit>(
        create: (context) => GetIt.I<UtilityCubit>(),
      ),
    ];
}