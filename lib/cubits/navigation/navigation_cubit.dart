import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'navigation_state.dart';

enum TabItem { home, explore, create, profile, messages }

class NavigationCubit extends Cubit<NavigationState> {
  NavigationCubit() : super(NavigationInitial());


  void selectTab(TabItem tabItem, {TabItem? previousTab}) {
    emit(NavigationSelected(tabItem , previousTab: previousTab));
  }
}
