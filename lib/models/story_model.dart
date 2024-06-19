import 'dart:async';
import 'dart:developer';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:digigram/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:mime/mime.dart';

enum MediaType {
  image,
  video,
}

class Story {
  String uid;
  MediaType mediaType;
  late String url;
  DateTime added;
  late UserModel user;
  Story(
    this.mediaType,
  )   : added = DateTime.now().toUtc(),
        uid = FirebaseAuth.instance.currentUser!.uid;

  Story.fromMap(Map<String, dynamic> map)
      : uid = map['uid'],
        mediaType = MediaType.values[map['mediaType']],
        url = map['url'],
        added = DateTime.fromMillisecondsSinceEpoch(map['added']);

  Map<String, dynamic> toMap() => {
        "uid": uid,
        "mediaType": mediaType.index,
        "url": url,
        "added": added.millisecondsSinceEpoch,
      };

  Future<void> uploadStoryImage(Uint8List image) async {
    var now = DateTime.now().millisecondsSinceEpoch.toString();
    var completer = Completer<void>();
    var mimeType = lookupMimeType('', headerBytes: image.toList())!;
    var storyRef = FirebaseStorage.instance.ref('story/$now.${mimeType.split('/').last}');
    var task = storyRef.putData(
      image,
      SettableMetadata(contentType: mimeType),
    );
    task.snapshotEvents.listen((event) async {
      // log("${event.bytesTransferred}/${event.totalBytes}", name: 'upload');
      if (event.state == TaskState.success) {
        url = await storyRef.getDownloadURL();
        completer.complete();
      }
    });
    return completer.future;
  }

  Future<void> fetchUser() async {
    user = await UserModelStaticService.getUser(uid);
  }
}

extension StoryModelService on Story {
  static CollectionReference<Map<String, dynamic>> get collectionRef => FirebaseFirestore.instance.collection('story');
  static Stream<List<Story>> getStory(UserModel user) {
    var snapshot = collectionRef.where("uid", whereIn: user.following..add(user.uid)).snapshots();
    return snapshot.asyncMap((querySnap) async {
      var users = querySnap.docs.map((e) async {
        var story = Story.fromMap(e.data());
        await story.fetchUser();
        return story;
      }).toList();
      return await Future.wait(users);
    });
  }

  Future<void> saveStory() async {
    try {
      await collectionRef.doc().set(toMap());
    } catch (e) {
      log(e.toString());
    }
  }
}
