part of 'navigation_cubit.dart';

@immutable
abstract class NavigationState {}

class NavigationInitial extends NavigationState {}

class NavigationSelected extends NavigationState {
  TabItem? previousTab;
  final TabItem page;
  NavigationSelected(this.page , {this.previousTab});
}
