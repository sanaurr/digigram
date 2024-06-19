import 'package:digigram/models/story_model.dart';
import 'package:digigram/models/user_model.dart';
import 'package:digigram/widgets/add_story.dart';
import 'package:digigram/widgets/story.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Storybar extends StatefulWidget {
  const Storybar({super.key});

  @override
  State<Storybar> createState() => _StorybarState();
}

class _StorybarState extends State<Storybar> {
  @override
  Widget build(BuildContext context) {
    var user = context.read<UserModel>();

    return StreamBuilder(
        stream: StoryModelService.getStory(user),
        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return const SizedBox.shrink();
          }
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {
                    context.addStory();
                  },
                  child: Column(
                    children: [
                      SizedBox.square(
                        dimension: 80,
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(user.photoURL),
                        ),
                      ),
                      const Text(
                        "Your Story",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                ...snapshot.requireData
                    .map((s) => Column(
                          children: [
                            IconButton(
                              onPressed: () {
                                context.viewStory(s);
                              },
                              icon: SizedBox.square(
                                dimension: 80,
                                child: CircleAvatar(
                                  backgroundImage: NetworkImage(s.url),
                                ),
                              ),
                            ),
                            Text(
                              s.user.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ))
                    .toList(),
              ],
            ),
          );
        });
  }
}
