import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thentic_app/resources/post.dart';

class UserRepository {


  

Future<UserCredential> authenticate_email(String email, String password) async {
   FirebaseAuth _auth = FirebaseAuth.instance;

  UserCredential _user = await _auth.signInWithEmailAndPassword(email: email, password: password);
  return _user;
}

Future<UserCredential?> register_email(String email, String password) async {
   FirebaseAuth _auth = FirebaseAuth.instance;
   UserCredential? _user;
    try {
      _user = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
    } catch (e) {
      print(e);
    }
      return _user;
}

Future<void> signOut() async {
   FirebaseAuth _auth = FirebaseAuth.instance;

  await _auth.signOut();
}

Future<User?> getCurrentUser() async {
   FirebaseAuth _auth = FirebaseAuth.instance;

  User? _user = await _auth.currentUser;
  return _user ?? null;
}

Future<void> storeUserId(String userId) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString("userId", userId);
}

Future<String?> getUserId() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString("userId");
}

Future<UserCredential> signInWithGoogle() async {
  // Trigger the authentication flow
  final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

  // Obtain the auth details from the request
  final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

  // Create a new credential
  final credential = GoogleAuthProvider.credential(
    accessToken: googleAuth?.accessToken,
    idToken: googleAuth?.idToken,
  );

  // Once signed in, return the UserCredential
  return await FirebaseAuth.instance.signInWithCredential(credential);
}


Future<void> saveUserToDatabase(User user, String name) async {
  // Call the user's CollectionReference to add a new user
  await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .set({'name': name, 'email': user.email});
}



Future<List<String>> getPostIds() async {
  List<String> _postIds = [];
  await FirebaseFirestore.instance
      .collection('posts')
      .get()
      .then((QuerySnapshot querySnapshot) {
    querySnapshot.docs.forEach((doc) {
      _postIds.add(doc.id);
    });
  });
  return _postIds;
}


Future<String> getNameFromUserId(String userId) async {
  String _name = "";
  await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .get()
      .then((DocumentSnapshot documentSnapshot) {
    if (documentSnapshot.exists) {
      _name = documentSnapshot.get('name');
    }
  });
  return _name;
}


Future<void> createPost({required String userId,required File file, String caption = " ",required PostType type}) async {
//generate a unique id for the post
var r = Random();
var postId = r.nextInt(1000000000);
//check if the id is already in use
List<String> postIds = await getPostIds();
while (postIds.contains(postId.toString())) {
  postId = r.nextInt(1000000000);
}
  FirebaseStorage storage = FirebaseStorage.instance;
  Reference ref = storage.ref().child("$userId/images/$postId");
  UploadTask uploadTask = ref.putFile(file);
  TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
  String url = await taskSnapshot.ref.getDownloadURL();
  await FirebaseFirestore.instance
      .collection('posts')
      .doc(postId.toString())
      .set({
        'userId': userId, 
        'contentUrl': url, 
        'type': type == PostType.IMAGE ? 'image' : 'video', 
        'caption': caption, 
        'views': 0,
        'comments': 0, 
        'timestamp': DateTime.now().millisecondsSinceEpoch
        });
 //add post id to the user ref array "posts"
  await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .update({'posts': FieldValue.arrayUnion([postId.toString()])});
}


Future<void> setProfilePicture({required String userId, required File file}) async {
    FirebaseStorage storage = FirebaseStorage.instance;
  Reference ref = storage.ref().child("$userId/profilePicture");
  UploadTask uploadTask = ref.putFile(file);
  TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
  String url = await taskSnapshot.ref.getDownloadURL();
  await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .update({'profilePicture': url});
}

Future<String> getProfilePictureUrl({required String userId}) async {
  String _url = "";
  try {
    await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .get()
      .then((DocumentSnapshot documentSnapshot) {
    if (documentSnapshot.exists) {
     _url = documentSnapshot.get('profilePicture');
    }
  });
  } catch (e) {
    print(e);
  }
   
  return _url;
}


Future<void> addFollowing(String userId, String followingId) async {
  await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .update({'following': FieldValue.arrayUnion([followingId])});
}

Future<void> removeFollowing(String userId, String followingId) async {
  await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .update({'following': FieldValue.arrayRemove([followingId])});
}

//get following list of a user
Future<List<String>> getFollowing(String userId) async {
  List<String> _following = [];
  await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .get()
      .then((DocumentSnapshot documentSnapshot) {
    if (documentSnapshot.exists) {
      _following = List.from(documentSnapshot.get('following'));
    }
  });
  return _following;
}

Future<void> addFollower(String userId, String followerId) async {
  await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .update({'followers': FieldValue.arrayUnion([followerId])});
}

Future<void> removeFollower(String userId, String followerId) async {
  await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .update({'followers': FieldValue.arrayRemove([followerId])});
}

Future<List<String>> getFollowers(String userId) async {
  List<String> _followers = [];
  await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .get()
      .then((DocumentSnapshot documentSnapshot) {
    if (documentSnapshot.exists) {
      _followers = List.from(documentSnapshot.get('followers'));
    }
  });
  return _followers;
}



Future<void> setProfileGradientColor1(String userId, Color color) async {
  await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .update({'profileGradientColor1': color.value});
}
Future<void> setProfileGradientColor2(String userId, Color color) async {
  await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .update({'profileGradientColor2': color.value});
}

Future<List<Color>> getGradientColors(String userId) async {
  List<Color> _colors = [];
  try {
      await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .get()
      .then((DocumentSnapshot documentSnapshot) {
    if (documentSnapshot.exists) {
      _colors.add(Color(documentSnapshot.get('profileGradientColor1')));
      _colors.add(Color(documentSnapshot.get('profileGradientColor2')));
    }
  });
  } catch (e) {
      _colors.add(Colors.blue);
      _colors.add(Colors.white);
  }
  return _colors;
}


Future<List<String>> searchUsers(String query) async {
  List<String> _users = [];
  await FirebaseFirestore.instance
      .collection('users')
      .where('name', isGreaterThanOrEqualTo: query)
      .get()
      .then((QuerySnapshot querySnapshot) {
    querySnapshot.docs.forEach((doc) {
      _users.add(doc.id);
    });
  });
  return _users;
}





}