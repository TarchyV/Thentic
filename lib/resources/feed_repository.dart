import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thentic_app/resources/post.dart';

class FeedRepository {


  Future<List<Post>> getFeed(List<String> followingIds) async {
    List<Post> _posts = [];
    FirebaseFirestore.instance.collection("posts").get().then((value) {
      for (var element in value.docs) {
        if (followingIds.contains(element.data()["userId"])) {
          Post post = Post(
            id: element.id,
            userId: element.data()["userId"],
            caption: element.data()["caption"],
            createdAt: element.data()["timestamp"].toString(),
            type: element.data()["type"] == "image" ? PostType.IMAGE : PostType.VIDEO,
            imageUrl: element.data()["type"] == "image" ? element.data()["contentUrl"] : null,
            videoUrl: element.data()["type"] == "video" ? element.data()["contentUrl"] : null,
          );
          _posts.add(post);
        }
      }
    });
    return _posts;
  }
  
}