import 'dart:developer';

import 'package:digigram/models/story_model.dart';
import 'package:digigram/models/user_model.dart';
import 'package:digigram/screens/profile.dart';
import 'package:digigram/utils/extentions.dart';
import 'package:digigram/widgets/story_progressbar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class ViewStory extends StatefulWidget {
  const ViewStory({
    super.key,
    required this.stories,
    this.onnext,
    this.onprevious,
  });
  final List<Story> stories;
  final VoidCallback? onnext;
  final VoidCallback? onprevious;
  @override
  State<ViewStory> createState() => _ViewStoryState();
}

class _ViewStoryState extends State<ViewStory> {
  var currentindex = 0;

  Offset tapdown = Offset.zero;
  @override
  Widget build(BuildContext context) {
    var currentuser = context.watch<UserModel>();
    var image = Image.network(
      widget.stories[currentindex].url,
      fit: BoxFit.contain,
    );
    var colorscheme = ColorScheme.fromImageProvider(
      provider: image.image,
    );
    return FutureBuilder(
        future: colorscheme,
        builder: (context, snapshot) {
          return Container(
            color: snapshot.data?.secondaryContainer,
            child: Stack(
              children: [
                Positioned.fill(
                  child: GestureDetector(
                    onTapDown: (details) {
                      setState(() {
                        tapdown = details.globalPosition;
                      });
                    },
                    onTapUp: (details) {
                      setState(() {
                        if ((tapdown - details.globalPosition).distance < 10) {
                          var halfWidth = MediaQuery.sizeOf(context).width / 2;
                          if (details.globalPosition.dx < halfWidth) {
                            // widget.onprevious?.call();
                            // currentindex++;
                            if (currentindex == 0) {
                              widget.onprevious?.call();
                            } else {
                              currentindex--;
                            }
                          } else {
                            // widget.onnext?.call();
                            // currentindex--;
                            if (currentindex == widget.stories.length - 1) {
                              // currentindex = widget.stories.length - 1;
                              widget.onnext?.call();
                            } else {
                              currentindex++;
                            }
                          }
                        }
                      });
                    },
                    child: image,
                  ),
                ),
                Positioned(
                  top: 30,
                  left: 0,
                  right: 0,
                  child: StoryProgress(
                    totalStoryCount: widget.stories.length,
                    duration: const Duration(seconds: 5),
                    // currentStoryIndex: currentindex,
                    onIndexChanged: (index) {
                      setState(() {
                        currentindex = index;
                      });
                    },
                  ),
                ),
                Positioned(
                  top: 30,
                  left: 0,
                  right: 0,
                  child: ListTile(
                    leading: IconButton(
                      onPressed: () {
                        var user = context.read<UserModel>();
                      if (user.uid == widget.stories[currentindex].uid) {
                        context.go('/profile');
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChangeNotifierProvider.value(
                              value: user,
                              child: Profile(user: widget.stories[currentindex].user),
                            ),
                          ),
                        );
                      }
                      },
                      icon: SizedBox.square(
                        dimension: 50,
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(
                              widget.stories[currentindex].user.photoURL),
                        ),
                      ),
                    ),
                    title: Text(
                      widget.stories[currentindex].user.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      widget.stories[currentindex].added.formattedTime,
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: PopupMenuButton(
                      itemBuilder: (context) {
                        return [
                          if (widget.stories[currentindex].uid ==
                              currentuser.uid)
                          const PopupMenuItem(
                            value: 1,
                            child: Text("Delete"),
                          ),
                          const PopupMenuItem(
                            value: 2,
                            child: Text("Hide"),
                          ),
                        ];
                      },
                      onSelected: (value) async {
                        try {
                          if (value == 1) {
                            var navigator = Navigator.of(context);
                            log("inside try");
                            await widget.stories[currentindex].deleteStory();
                            navigator.pop();
                            // log(story.uid);
                            // log(currentuser.uid);
                          }
                        } catch (e) {
                          log(e.toString());
                        }
                      },
                      icon: const Icon(Icons.more_vert_sharp),
                    ),
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
        });
  }
}
