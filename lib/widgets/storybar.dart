// import 'dart:developer';

import 'package:digigram/models/story_model.dart';
import 'package:digigram/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class Storybar extends StatefulWidget {
  const Storybar({super.key});

  @override
  State<Storybar> createState() => _StorybarState();
}

class _StorybarState extends State<Storybar> {
  @override
  Widget build(BuildContext context) {
    var currentUser = context.read<UserModel>();

    return StreamBuilder(
        stream: StoryModelService.getStory(currentUser),
        builder: (context, snapshot) {
          // log(snapshot.requireData.length.toString());
          if (!snapshot.hasData) {
            return const SizedBox.shrink(
              // child: CircularProgressIndicator(),
            
            );
            // return Text("No story");
          }
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {
                    context.go('/addstory');
                  },
                  child: Column(
                    children: [
                      SizedBox.square(
                        dimension: 80,
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(currentUser.photoURL),
                        ),
                      ),
                      const Text(
                        "Add Story",
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
                                context.go(
                                  "/viewstory",
                                  extra: snapshot.requireData.sublist(snapshot.requireData.indexOf(s),),
                                );
                              },
                              icon: SizedBox.square(
                                dimension: 80,
                                child: CircleAvatar(
                                  backgroundImage: NetworkImage(s.first.url),
                                ),
                              ),
                            ),
                            Text(
                              currentUser.uid == s.first.uid ? "Your Story" : s.first.user.name,
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
