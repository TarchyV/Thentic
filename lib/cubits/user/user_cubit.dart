import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';
import 'package:thentic_app/resources/post.dart';
import 'package:thentic_app/resources/user_repository.dart';

part 'user_state.dart';

class UserCubit extends Cubit<UserState> {
  UserRepository _userRepository;
  UserCubit(this._userRepository) : super(UserInitial()) {
    getUser();
  }




Future<List<String>> getFollowing(String userId ) async{
  return _userRepository.getFollowing(userId);
}


void getUser() async {
  print("getUser called");
    String? userId;
    List<String> following = [];
    emit(UserLoading());
    try {
      userId = await _userRepository.getUserId();
      if (userId != null) {
        following = await _userRepository.getFollowing(userId);
        emit(UserLoggedIn(
          userId,
          following,
          ));
      } else {
        emit(UserLoggedOut());
      }
    } catch (e) {
      print(e);
      emit(UserLoggedOut());
    }
  }


  Future<String> getUserNameFromId(String userId) async {
      String userName = await _userRepository.getNameFromUserId(userId);
      return userName;
  }



  void email_login(String email, String password) async {
    print("email login, email: $email, password: $password");
    try {
      emit(UserLoading());
      UserCredential _user = await _userRepository.authenticate_email(email, password);
      List<String> following = await _userRepository.getFollowing(_user.user!.uid);
      emit(UserLoggedIn(_user.user!.uid, following));
      storeUserId(_user.user!.uid);
    } catch (e) {
      emit(UserInitial());
      print(e);
      
    }
  }

  void storeUserId(String userId) async {
    print("storeUserId, userId: $userId");
    await _userRepository.storeUserId(userId);
  }



  void email_register(String email, String password, String username) async {
    print("email register, email: $email, password: $password");
    try {
      emit(UserLoading());
      UserCredential? _user = await _userRepository.register_email(email, password);
      await _userRepository.saveUserToDatabase(_user!.user!, username);
      List<String> following = await _userRepository.getFollowing(_user.user!.uid);
      emit(UserLoggedIn(_user.user!.uid, following));
      storeUserId(_user.user!.uid);
    } catch (e) {
      emit(UserInitial());
      print(e);
    }
  }

  bool isLoggedIn() {
    return state is UserLoggedIn;
  }

  void signInWithGoogle() async {
    try {
      emit(UserLoading());
      UserCredential _user = await _userRepository.signInWithGoogle();
      List<String> following = await _userRepository.getFollowing(_user.user!.uid);
      emit(UserLoggedIn(_user.user!.uid, following));
      storeUserId(_user.user!.uid);
    } catch (e) {
      emit(UserInitial());
      print(e);
    }
  }

  String getUserId() {
    if (state is UserLoggedIn) {
      return (state as UserLoggedIn).userId;
    } else {
      return "";
    }
  }


  void followMyself() async {
   await _userRepository.addFollowing(getUserId(), getUserId());
  }


  Future<void> createPost(File file, String caption, PostType type) async {
     await _userRepository.createPost(
      userId: getUserId(),
      file: file,
      caption: caption,
      type: type,
      );
  }


}
