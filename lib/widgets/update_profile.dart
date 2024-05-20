import 'dart:developer';
import 'package:digigram/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:provider/provider.dart';

class UpdateProfile extends StatefulWidget {
  const UpdateProfile({
    super.key,
    required this.onDone,
  });

  final VoidCallback onDone;

  @override
  State<UpdateProfile> createState() => _UpdateProfileState();
}

class _UpdateProfileState extends State<UpdateProfile> {
  var nameController = TextEditingController();
  var bioController = TextEditingController();
  Uint8List? image;
  Future<void> saveChanges() async {
    var usermodel = context.read<UserModel>();
    if (nameController.text != usermodel.name &&
        nameController.text.trim().isNotEmpty) {
      usermodel.name = nameController.text.trim();
    }
    if (bioController.text != usermodel.bio &&
        bioController.text.trim().isNotEmpty) {
      usermodel.bio = bioController.text.trim();
    }
    if (usermodel.name.isEmpty) {
      // show error
      return;
    }
    if (image != null) {
      await usermodel.uploadProfileImage(image!);
    }
    await usermodel.save();
    if (mounted) {
      widget.onDone();
    }
  }

  @override
  void initState() {
    super.initState();
    var userModel = context.read<UserModel>();
    nameController.text = userModel.name;
    bioController.text = userModel.bio;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Center(
          child: SizedBox.square(
            dimension: 150,
            child: Stack(
              children: [
                Positioned.fill(
                  child: CircleAvatar(
                    backgroundImage: image == null ? null : MemoryImage(image!),
                    child: image == null ? const FlutterLogo() : null,
                  ),
                ),
                Positioned(
                  bottom: 5,
                  right: 5,
                  child: IconButton(
                    onPressed: () async {
                      var file = await ImagePicker()
                          .pickImage(source: ImageSource.gallery);

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
                    style: IconButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).colorScheme.tertiaryContainer,
                      foregroundColor:
                          Theme.of(context).colorScheme.onTertiaryContainer,
                    ),
                    icon: const Icon(
                      Icons.add_a_photo,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: TextFormField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: "Enter your full name",
            ),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]')),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: TextField(
            controller: bioController,
            decoration: const InputDecoration(
              labelText: "Describe yourself",
            ),
          ),
        ),
        ElevatedButton(
          onPressed: saveChanges,
          child: const Text("Save changes"),
        ),
      ],
    );
  }
}
