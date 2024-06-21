import 'dart:developer';

import 'package:digigram/models/story_model.dart';
import 'package:digigram/models/user_model.dart';
import 'package:digigram/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StoryPage extends StatefulWidget {
  const StoryPage({super.key, required this.stories});

  final List<Story> stories;

  @override
  State<StoryPage> createState() => _StoryPageState();
}

class _StoryPageState extends State<StoryPage> {
  @override
  Widget build(BuildContext context) {
    // var currentuser = context.watch<UserModel>();
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
          itemCount: widget.stories.length,
          itemBuilder: (context, index) {
            var story = widget.stories[index];
            return Stack(
              children: [
                Image.network(
                  story.url,
                  fit: BoxFit.fill,
                ),
                Positioned(
                  top: 40,
                  left: 10,
                  right: 10,
                  child: Row(
                    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: SizedBox.square(
                          dimension: 50,
                          child: CircleAvatar(
                            backgroundImage: NetworkImage(story.user.photoURL),
                          ),
                        ),
                      ),
                      Text(
                        story.user.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(story.added.formattedTime),
                      const Spacer(),
                      IconButton(
                          onPressed: () async {
                            try {
                              log("inside try");

                              await StoryModelService.deleteStory(story.uid);
                              log(story.uid);
                              // log(currentuser.uid);
                            } catch (e) {
                              log(e.toString());
                            }
                          },
                          icon: const Icon(Icons.more_vert_sharp))
                    ],
                  ),
                ),
                Positioned(
                  bottom: 30,
                  left: 15,
                  right: 10,
                  child: Row(
                    children: [
                      const Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(20),
                              ),
                            ),
                            hintText: "Write a reply",
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.send),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),
    );
  }
}

// extension StoryViewer on BuildContext {
//   void viewStory(Story story) {
//     var user = read<UserModel>();
//     Navigator.of(this).push(MaterialPageRoute(builder: (context) {
//       return ChangeNotifierProvider.value(
//         value: user,
//         builder: (context, _) {
//           return StoryPage(story: story);
//         }
//       );
//     }));
//   }
// }
