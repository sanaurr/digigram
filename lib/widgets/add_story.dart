import 'dart:typed_data';

import 'package:digigram/models/story_model.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_provider/loading_provider.dart';
import 'package:mime/mime.dart';

class AddStory extends StatefulWidget {
  const AddStory({super.key});

  @override
  State<AddStory> createState() => _AddStoryState();
}

class _AddStoryState extends State<AddStory> {
  Uint8List? image;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add your story"),
        centerTitle: true,
        actions: [
          ElevatedButton(
            onPressed: () async {
              var loadcontroller = context.loadingController;
              loadcontroller.on("onpoastloading");
              var messanger = ScaffoldMessenger.of(context);
              if (image == null) {
                messanger.showSnackBar(
                    const SnackBar(content: Text("Add a video or photo")));
              } else {
                var newStory = Story(
                  MediaType.image,

                );
                
                  await newStory.uploadStoryImage(image!);
                
                try {
                  await newStory.saveStory();
                  loadcontroller.off();
                  messanger.showSnackBar(
                    const SnackBar(
                      content: Text("Story Added"),
                    ),
                  );
                  // widget.onposted();
                } catch (e) {
                  loadcontroller.off();
                  // log(e.toString());
                }
              }
              loadcontroller.off();
            },
            child: const Text("Add"),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                InkWell(
                  child: Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.camera_alt),
                        Text("Camera"),
                      ],
                    ),
                  ),
                  onTap: () async{
                   var file = await ImagePicker().pickImage(source: ImageSource.camera);
                    if (file != null) {
                      var newimage = await file.readAsBytes();
                      var mimeType =
                          lookupMimeType('', headerBytes: newimage.toList());
                      if (mimeType?.startsWith("image") ?? false) {
                        setState(() {
                          image = newimage;
                        });
                      }
                    }
                  },
                ),
                InkWell(
                  child: Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.photo),
                        Text("Photos"),
                      ],
                    ),
                  ),
                  onTap: () async{
                   var file = await ImagePicker().pickImage(source: ImageSource.gallery);
                    if (file != null) {
                      var newimage = await file.readAsBytes();
                      var mimeType =
                          lookupMimeType('', headerBytes: newimage.toList());
                      if (mimeType?.startsWith("image") ?? false) {
                        setState(() {
                          image = newimage;
                        });
                      }
                    }
                  },
                ),
                Container(
                  height: 80,
                  width: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.video_camera_back_sharp),
                      Text("Videos"),
                    ],
                  ),
                ),
                Container(
                  height: 80,
                  width: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.text_fields_sharp),
                      Text("Text"),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.5),
                  // border: Border.,
                  image: image == null
                      ? null
                      : DecorationImage(
                          image: MemoryImage(image!),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

extension StoryAdd on BuildContext {
  void addStory() {
    Navigator.of(this).push(MaterialPageRoute(builder: (context) {
          return const AddStory();
    }));
  }
}