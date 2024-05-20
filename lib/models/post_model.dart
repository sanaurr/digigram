import 'dart:async';
import 'dart:developer';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:digigram/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:mime/mime.dart';

enum PostReaction {
  like,
  love,
  haha,
  care,
  sad,
  shoe,
  fck;

  factory PostReaction.fromIndex(int index) {
    return PostReaction.values[index];
  }

  String get emoji => [
        "👍",
        "❤️",
        "😂",
        "🤗",
        "🥹",
        "🩴",
        "🖕",
      ][index];
}

class PostLikeModel {
  String uid;
  PostReaction reaction;
  PostLikeModel(this.reaction) : uid = FirebaseAuth.instance.currentUser!.uid;
  late UserModel user;
  PostLikeModel.fromMap(Map<String, dynamic> map)
      : uid = map['uid'],
        reaction = PostReaction.fromIndex(map['reaction']);
  Map<String, dynamic> toMap() => {
        "uid": uid,
        "reaction": reaction.index,
      };

  Future<void> loadUser() async {
    var snap = await UserModelStaticService.collectionRef.doc(uid).get();
    user = UserModel.fromMap(snap.data()!);
  }
}

class PostCommentModel {
  String uid;
  String data;
  DateTime dateTime = DateTime.now().toUtc();
  late DocumentReference<Map<String, dynamic>> commentref;
  late UserModel user;

  PostCommentModel(this.data) : uid = FirebaseAuth.instance.currentUser!.uid;
  PostCommentModel.fromMap(Map<String, dynamic> map, this.commentref)
      : uid = map['uid'],
        data = map['data'],
        dateTime = DateTime.fromMillisecondsSinceEpoch(map['dateTime']);
  Map<String, dynamic> toMap() => {
        'uid': uid,
        'data': data,
        'dateTime': dateTime.millisecondsSinceEpoch,
      };

  Future<UserModel> getUser() async {
    var snap = await UserModelStaticService.collectionRef.doc(uid).get();
    var user = UserModel.fromMap(snap.data()!);
    return user;
  }

  Future<void> delete() async {
    return await commentref.delete();
  }

  Future<void> editComment(String comment) async {
    data = comment;
    return await commentref.set(toMap());
  }

  Future<void> loadUser() async {
    var snap = await UserModelStaticService.collectionRef.doc(uid).get();
    user = UserModel.fromMap(snap.data()!);
  }
}

class PostModel {
  String uid;
  String? postData;
  String? photoURL;
  DateTime created;
  late UserModel user;
  late DocumentReference<Map<String, dynamic>> ref;
  PostModel({this.postData})
      : uid = FirebaseAuth.instance.currentUser!.uid,
        created = DateTime.now().toUtc();
  PostModel.fromMap(Map<String, dynamic> map, this.ref)
      : uid = map['uid'],
        postData = map['postData'],
        photoURL = map['photoURL'],
        created = DateTime.fromMillisecondsSinceEpoch(map['created']);
  Map<String, dynamic> toMap() => {
        'uid': uid,
        'postData': postData,
        'photoURL': photoURL,
        'created': created.millisecondsSinceEpoch
      };
  Future<void> loadUser() async {
    var snap = await UserModelStaticService.collectionRef.doc(uid).get();
    user = UserModel.fromMap(snap.data()!);
  }
}

extension PostModelService on PostModel {
  CollectionReference<Map<String, dynamic>> get likeCollectionRFef =>
      ref.collection('likes');

  CollectionReference<Map<String, dynamic>> get commentCollectionRFef =>
      ref.collection('comments');

  Stream<int> get likeCountChanges =>
      likeChanges.asyncMap((event) => event.length);

  Stream<int> get commentCountChanges =>
      commentChanges.asyncMap((event) => event.length);

  Stream<List<PostLikeModel>> get likeChanges {
    var snapshot =
        likeCollectionRFef.snapshots().asyncMap((event) => event.docs);
    var list = snapshot.asyncMap((ee) {
      var docs = ee.map((e) async {
        var postmodel = PostLikeModel.fromMap(e.data());
        await postmodel.loadUser();
        return postmodel;
      }).toList();
      var returnlist = Future.wait(docs);
      return returnlist;
    });
    return list;
  }

  Stream<List<PostCommentModel>> get commentChanges {
    var snapshot = commentCollectionRFef
        .orderBy("dateTime", descending: true)
        .snapshots()
        .asyncMap((event) => event.docs);
    var list = snapshot.asyncMap((ee) {
      var docs = ee.map((e) async {
        var postmodel = PostCommentModel.fromMap(e.data(), e.reference);
        await postmodel.loadUser();
        return postmodel;
      }).toList();
      var returnlist = Future.wait(docs);
      return returnlist;
    });
    return list;
  }

  Future<void> react(PostReaction reaction) async {
    var reactionSnap = await likeCollectionRFef
        .where("uid", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get();
    var add = true;
    for (var doc in reactionSnap.docs) {
      var likemodel = PostLikeModel.fromMap(doc.data());
      if (likemodel.reaction == reaction) {
        add = false;
      }
      await doc.reference.delete();
    }
    if (add) {
      return likeCollectionRFef.doc().set(PostLikeModel(reaction).toMap());
    }
  }

  Future<void> comment(String comment) async {
    return commentCollectionRFef.doc().set(PostCommentModel(comment).toMap());
  }

  Future<void> loadUser() async {
    var snap = await UserModelStaticService.collectionRef.doc(uid).get();
    user = UserModel.fromMap(snap.data()!);
  }

  Future<void> deletePost() async {
    var commentref = await commentCollectionRFef.get();
    for (var element in commentref.docs) {
      await element.reference.delete();
    }
    var reactref = await likeCollectionRFef.get();
    for (var element in reactref.docs) {
      await element.reference.delete();
    }
    await ref.delete();
  }

  Future<void> uploadPostImage(Uint8List image) async {
    var now = DateTime.now().millisecondsSinceEpoch.toString();
    var completer = Completer<void>();
    var mimeType = lookupMimeType('', headerBytes: image.toList())!;
    var postPicRef = FirebaseStorage.instance
        .ref('postimage/$now.${mimeType.split('/').last}');
    var task = postPicRef.putData(
      image,
      SettableMetadata(contentType: mimeType),
    );
    task.snapshotEvents.listen((event) async {
      log("${event.bytesTransferred}/${event.totalBytes}", name: 'upload');
      if (event.state == TaskState.success) {
        photoURL = await postPicRef.getDownloadURL();
        completer.complete();
      }
    });
    return completer.future;
  }
}

extension PostModelStaticService on PostModel {
  static CollectionReference<Map<String, dynamic>> get collectionRef =>
      FirebaseFirestore.instance.collection('posts');
}
