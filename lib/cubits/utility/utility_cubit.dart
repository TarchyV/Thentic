import 'package:bloc/bloc.dart';
import 'package:camera/camera.dart';
import 'package:meta/meta.dart';

part 'utility_state.dart';

class UtilityCubit extends Cubit<UtilityState> {
  List<CameraDescription>? _cameras;

  UtilityCubit() : super(UtilityInitial());

  void setCameras(List<CameraDescription> cameras) {
    _cameras = cameras;
    emit(SetUtilites(_cameras!));
    print("Cameras set --> $_cameras");
  }

  List<CameraDescription>? get cameras => _cameras;

}
