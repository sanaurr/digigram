import 'dart:developer';
import 'dart:typed_data';

import 'package:digigram/models/post_model.dart';
import 'package:digigram/models/user_model.dart';
import 'package:digigram/utils/loading.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_provider/loading_provider.dart';
import 'package:lottie/lottie.dart';
import 'package:mime/mime.dart';
import 'package:provider/provider.dart';

class NewPost extends StatefulWidget {
  const NewPost({super.key, required this.onposted});
  final VoidCallback onposted;

  @override
  State<NewPost> createState() => _NewPostState();
}

class _NewPostState extends State<NewPost> {
  var postController = TextEditingController();
  Uint8List? image;
  @override
  Widget build(BuildContext context) {
    var usermodel = context.watch<UserModel>();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create post"),
        centerTitle: true,
        actions: [
          ElevatedButton(
            onPressed: () async {
              var loadcontroller = context.loadingController;
              loadcontroller.on("onpoastloading");
              var messanger = ScaffoldMessenger.of(context);
              if (postController.text.isEmpty && image == null) {
                messanger.showSnackBar(
                    const SnackBar(content: Text("Add some content or photo")));
              } else {
                var newpost = PostModel(
                  postData: postController.text,
                );
                if (image != null) {
                  await newpost.uploadPostImage(image!);
                }
                try {
                  await usermodel.post(newpost);
                  loadcontroller.off();
                  messanger.showSnackBar(
                    const SnackBar(
                      content: Text("Posted"),
                    ),
                  );
                  widget.onposted();
                } catch (e) {
                  loadcontroller.off();
                  log(e.toString());
                }
              }
              loadcontroller.off();
            },
            child: const Text("Post"),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: TextField(
                controller: postController,
                minLines: 20,
                maxLines: 20,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Write your post here...',
                ),
              ),
            ),
            const SizedBox(height: 5),
            Expanded(
              child: Container(
                height: double.infinity,
                width: double.infinity,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    border: Border.all(width: 1),
                    image: image == null
                        ? null
                        : DecorationImage(image: MemoryImage(image!))),
                child: IconButton(
                  onPressed: () async {
                    var popvalue = await showDialog(
                        context: context,
                        builder: (BuildContext) {
                          return AlertDialog(
                            title: const Text("Select image from"),
                            content: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    Navigator.of(context)
                                        .pop(ImageSource.camera);
                                  },
                                  icon: const Icon(
                                    Icons.camera_alt,
                                    size: 100,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    Navigator.of(context)
                                        .pop(ImageSource.gallery);
                                  },
                                  icon: const Icon(
                                    Icons.photo,
                                    size: 100,
                                  ),
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text("Cancel"),
                              ),
                            ],
                          );
                        });
                    if (popvalue == null) {
                      return;
                    }
                    var file = await ImagePicker().pickImage(source: popvalue);
                    if (file != null) {
                      var newimage = await file.readAsBytes();
                      var mimeType =
                          lookupMimeType('', headerBytes: newimage.toList());
                      log(mimeType.toString());
                      if (mimeType?.startsWith("image") ?? false) {
                        setState(() {
                          image = newimage;
                        });
                      }
                    }
                  },
                  icon: const Icon(Icons.add_a_photo, size: 50),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
