import 'dart:developer';

import 'package:digigram/models/story_model.dart';
import 'package:digigram/models/user_model.dart';
import 'package:digigram/utils/extentions.dart';
import 'package:digigram/widgets/story_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StoryPage extends StatefulWidget {
  const StoryPage({super.key, required this.stories});

  final List<List<Story>> stories;

  @override
  State<StoryPage> createState() => _StoryPageState();
}

class _StoryPageState extends State<StoryPage> {
  final controller = PageController();
  @override
  Widget build(BuildContext context) {
    var currentuser = context.watch<UserModel>();
    return Scaffold(
      // backgroundColor: Colors.black,
      body: PageView.builder(
          controller: controller,
          itemCount: widget.stories.length,
          itemBuilder: (context, i) {
            return ViewStory(
              stories: widget.stories[i],
              onnext: (){
                controller.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.linear);
              },
              onprevious: () {
                controller.previousPage(duration: const Duration(milliseconds: 500), curve: Curves.linear);
              },
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
