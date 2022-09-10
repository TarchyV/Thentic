import 'package:flutter_bloc/flutter_bloc.dart';

class GlobalCubitObserver extends BlocObserver {
  @override
  void onChange(BlocBase cubit, Change change) {
    print('${cubit.runtimeType}, $change');
    super.onChange(cubit, change);
  }

  @override
  void onError(BlocBase cubit, Object error, StackTrace stackTrace) {
    print('${cubit.runtimeType}, $error, $stackTrace');
    super.onError(cubit, error, stackTrace);
  }
}