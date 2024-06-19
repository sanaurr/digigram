import 'dart:async';
import 'dart:developer';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:digigram/models/post_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:mime/mime.dart';

class UserModel with ChangeNotifier {
  String name;
  String photoURL;
  String uid;
  String bio = "";
  List<String> following = [];

  UserModel(this.name, this.photoURL)
      : uid = FirebaseAuth.instance.currentUser!.uid;

  UserModel.fromMap(Map<String, dynamic> map)
      : name = map['name'],
        photoURL = map['photoURL'],
        uid = map['uid'],
        bio = map['bio'],
        following = (map['following'] as List).map((e) => e as String).toList();
  Map<String, dynamic> toMap() => {
        'name': name,
        'photoURL': photoURL,
        'uid': uid,
        'bio': bio,
        'following': following,
      };

  factory UserModel.empty() => UserModel('', '');
  bool get isEmptyuser => name.isEmpty;

  factory UserModel.deleted() => UserModel('', 'Deleted');
  bool get isDeleteduser => photoURL == "Deleted";
}

extension UserModelServicve on UserModel {
  Future<void> save() async {
    return UserModelStaticService.currentUserRef.set(this);
  }

  Future<void> follow(String uid) {
    following.add(uid);
    return save();
  }

  Future<void> unfollow(String uid) {
    following.remove(uid);
    return save();
  }

  Future<List<UserModel>> getFollowing() async {
    var snapshot = await UserModelStaticService.collectionModelRef
        .where("uid", whereIn: following)
        .limit(10)
        .get();
    return snapshot.docs.map((e) => e.data()).toList();
  }

  Future<List<UserModel>> getFollowers() async {
    var snapshot = await UserModelStaticService.collectionModelRef
        .where("following", arrayContains: uid)
        .limit(10)
        .get();
    return snapshot.docs.map((e) => e.data()).toList();
  }

  Future<List<PostModel>> getFeedPosts() async {
    try {
      var snapshot = await PostModelStaticService.collectionRef
          .orderBy("created", descending: true)
          .where("uid", whereIn: [...following, uid])
          .limit(30)
          .get();
      var list = snapshot.docs.map((e) async {
        var postModel = PostModel.fromMap(e.data(), e.reference);

        await postModel.loadUser();

        return postModel;
      }).toList();
      var returnlist = await Future.wait(list);
      return returnlist;
    } catch (e) {
      log("", error: e, name: 'posts');
      print(e);
      return [];
    }
  }

  Future<List<PostModel>> getOwnFeedPosts() async {
    var snapshot = await PostModelStaticService.collectionRef
        .where("uid", isEqualTo: uid)
        .limit(10)
        .get();
    return snapshot.docs
        .map((e) => PostModel.fromMap(e.data(), e.reference)..user = this)
        .toList();
  }

  Future<void> post(PostModel postModel) async {
    return await PostModelStaticService.collectionRef
        .doc()
        .set(postModel.toMap());
  }

  Future<List<UserModel>> searchUsers(String name) async {
    var query = UserModelStaticService.collectionModelRef
        .where("name", isGreaterThanOrEqualTo: name)
        .where("name", isLessThan: '${name}z')
        .limit(10);
    var snapshot = await query.get();

    var usermodel =
        snapshot.docs.map((e) => e.data()).toList();
    usermodel.removeWhere((element) => element.uid == uid);
    return usermodel;
  }
}

extension UserModelStaticService on UserModel {
  static CollectionReference<UserModel> get collectionModelRef =>
      FirebaseFirestore.instance.collection('users').withConverter<UserModel>(
        fromFirestore: (map, _) => UserModel.fromMap(map.data()!),
        toFirestore: (user, _) => user.toMap(),
      );

  static DocumentReference<UserModel> get currentUserRef =>
      collectionModelRef.doc(FirebaseAuth.instance.currentUser!.uid);

     static Future<UserModel> getUser(String uid) async {
      var user = await collectionModelRef.doc(uid).get();
      return user.data()!;
     } 

     static Stream<UserModel> userChanges() =>
      currentUserRef.snapshots().asyncMap((event) {
        try {
          if (event.exists) {
            return event.data()!;
          }
        } catch (e) {
          log(e.toString(), name: 'UserModel.fromMap');
        }
        return UserModel.empty();
      });
}

extension ProfileUpdate on UserModel {
  Future<void> uploadProfileImage(Uint8List image) async {
    var completer = Completer<void>();
    var mimeType = lookupMimeType('', headerBytes: image.toList())!;
    var profilePicRef = FirebaseStorage.instance
        .ref('profilePictures/$uid.${mimeType.split('/').last}');
    var task = profilePicRef.putData(
      image,
      SettableMetadata(contentType: mimeType),
    );
    task.snapshotEvents.listen((event) async {
      log("${event.bytesTransferred}/${event.totalBytes}", name: 'upload');
      if (event.state == TaskState.success) {
        photoURL = await profilePicRef.getDownloadURL();
        completer.complete();
      }
    });
    return completer.future;
  }
}
