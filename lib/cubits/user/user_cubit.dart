import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
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
Future<List<String>> getFollowers(String userId ) async{
  return _userRepository.getFollowers(userId);
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
  //  await _userRepository.addFollowing(getUserId(), getUserId());
   await _userRepository.addFollower(getUserId(), getUserId());
  }

  void followUser(String userId) async {
    await _userRepository.addFollowing(getUserId(), userId);
    await _userRepository.addFollower(userId, getUserId());
    getUser();
  }

  void unfollowUser(String userId) async {
    await _userRepository.removeFollowing(getUserId(), userId);
    await _userRepository.removeFollower(userId, getUserId());
    getUser();
  }


  Future<void> createPost(File file, String caption, PostType type) async {
     await _userRepository.createPost(
      userId: getUserId(),
      file: file,
      caption: caption,
      type: type,
      );
  }

  Future<void> setProfilePicture(String userId, File file) async {
    return _userRepository.setProfilePicture(
      userId: userId,
      file: file,
    );
  }
  Future<String> getProfilePictureUrl(String userId) async {
    return await _userRepository.getProfilePictureUrl(userId: userId);
  }

  Future<void> setProfileGradientColor1(String userId, Color color) async {
    return _userRepository.setProfileGradientColor1(
      userId,
      color,
    );
  }
  Future<void> setProfileGradientColor2(String userId, Color color) async {
    return _userRepository.setProfileGradientColor2(
      userId,
      color,
    );
  }
  Future<List<Color>> getProfileGradientColors(String userId) async {
    return await _userRepository.getGradientColors(userId);
  }

  Future<int> getFollowingCount(String userId) async {
    int followingCount = 0;
    await getFollowing(userId).then((value) => followingCount = value.length);
    return followingCount;
  }
  Future<int> getFollowerCount(String userId) async {
    int followerCount = 0;
    await getFollowers(userId).then((value) => followerCount = value.length);
    return followerCount;
  }

  Future<List<String>> searchUsers(String query) async {
    return await _userRepository.searchUsers(query);
  }




}
