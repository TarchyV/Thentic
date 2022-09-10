part of 'utility_cubit.dart';

@immutable
abstract class UtilityState {}

class UtilityInitial extends UtilityState {}

class SetUtilites extends UtilityState {
  final List<CameraDescription> cameras;
  SetUtilites(this.cameras);
}