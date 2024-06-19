import 'package:digigram/models/story_model.dart';
import 'package:digigram/models/user_model.dart';
import 'package:digigram/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StoryPage extends StatefulWidget {
  const StoryPage({super.key, required this.story});

  final Story story;

  @override
  State<StoryPage> createState() => _StoryPageState();
}

class _StoryPageState extends State<StoryPage> {
  @override
  Widget build(BuildContext context) {
    var usermodel = context.watch<UserModel>();
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            itemCount: 5,
            itemBuilder: (context, index) {
              if (widget.story.mediaType == MediaType.image) {
                return Image.network(
                  widget.story.url,
                  fit: BoxFit.cover,
                );
              } else {}
            },
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
                      backgroundImage: NetworkImage(widget.story.user.photoURL),
                    ),
                  ),
                ),
                // ignore: prefer_const_constructors
                Text(
                  widget.story.user.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Text(widget.story.added.formattedTime),
                const Spacer(),
                IconButton(
                    onPressed: () {}, icon: const Icon(Icons.more_vert_sharp))
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
      ),
    );
  }
}

extension StoryViewer on BuildContext {
  void viewStory(Story story) {
    var user = read<UserModel>();
    Navigator.of(this).push(MaterialPageRoute(builder: (context) {
      return ChangeNotifierProvider.value(
        value: user,
        builder: (context, _) {
          return StoryPage(story: story);
        }
      );
    }));
  }
}
