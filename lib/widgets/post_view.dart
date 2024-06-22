import 'dart:developer';

import 'package:digigram/models/post_model.dart';
import 'package:digigram/models/user_model.dart';
import 'package:digigram/screens/profile.dart';
import 'package:digigram/screens/view_image.dart';
import 'package:digigram/utils/extentions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class PostView extends StatefulWidget {
  const PostView(
    this.post, {
    super.key,
  });

  final PostModel post;

  @override
  State<PostView> createState() => _PostViewState();
}

class _PostViewState extends State<PostView> {
  bool showReactbar = false;
  @override
  Widget build(BuildContext context) {
    var usermodel = context.watch<UserModel>();
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: context.colorScheme.primaryContainer.withOpacity(0.2),
            child: Row(
              children: [
                SizedBox.square(
                  dimension: 30,
                  child: InkWell(
                    onTap: () {
                      var user = context.read<UserModel>();
                      if (user.uid == widget.post.uid) {
                        context.go('/profile');
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChangeNotifierProvider.value(
                              value: user,
                              child: Profile(user: widget.post.user),
                            ),
                          ),
                        );
                      }
                    },
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(widget.post.user.photoURL),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 40,
                ),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.post.user.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        widget.post.created.formattedTime,
                        style: const TextStyle(
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton(
                  itemBuilder: (context) {
                    return [
                      if (widget.post.uid == context.read<UserModel>().uid)
                        const PopupMenuItem(
                          value: 1,
                          child: Text("Delete"),
                        ),
                      const PopupMenuItem(
                        value: 2,
                        child: Text("Hide"),
                      ),
                      const PopupMenuItem(
                        value: 3,
                        child: Text("Report"),
                      ),
                    ];
                  },
                  onSelected: (value) async {
                    if (value == 1) {
                      try {
                        await widget.post.deletePost();
                      } catch (e) {
                        log(e.toString());
                      }
                    }
                  },
                  icon: const Icon(Icons.more_vert),
                ),
              ],
            ),
          ),
          Stack(
            alignment: Alignment.bottomLeft,
            children: [
              Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.post.postData != null)
                      Text(widget.post.postData!),
                    if (widget.post.photoURL != null) ...[
                      const SizedBox(
                        height: 10,
                      ),
                      InkWell(
                        onTap: () {
                          context.viewImage(widget.post.photoURL!);
                        },
                        child: Image.network(widget.post.photoURL!),
                      ),
                    ],
                  ],
                ),
              ),
              if (showReactbar)
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.grey,
                        offset: Offset(5, 5),
                        blurRadius: 15,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var react in PostReaction.values)
                        IconButton(
                          onPressed: () {
                            widget.post.react(react);
                            setState(() {
                              showReactbar = false;
                            });
                          },
                          icon: Text(
                            react.emoji,
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
          Divider(
            thickness: 0.5,
            height: 0.5,
            // color: context.colorScheme.primary.withOpacity(0.3),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: MaterialButton(
                  onPressed: () {
                    setState(() {
                      showReactbar = !showReactbar;
                    });
                  },
                  child: StreamBuilder(
                      stream: widget.post.likeChanges,
                      builder: (context, snapshot) {
                        var myReaction = "";
                        for (PostLikeModel reaction in snapshot.data ?? []) {
                          if (reaction.uid ==
                              FirebaseAuth.instance.currentUser!.uid) {
                            myReaction = reaction.reaction.emoji;
                            break;
                          }
                        }

                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('${snapshot.data?.length ?? ''}',
                                style: const TextStyle(fontSize: 14)),
                            // Icon(Icons.favorite, size: 15),
                            Text(
                              myReaction,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        );
                      }),
                ),
              ),
              Expanded(
                child: MaterialButton(
                  onPressed: () => showComments(context, usermodel),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      StreamBuilder(
                          stream: widget.post.commentCountChanges,
                          builder: (context, snapshot) {
                            return Text('${snapshot.data ?? ""} ',
                                style: const TextStyle(fontSize: 12));
                          }),
                      const Text('Comments', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: MaterialButton(
                  onPressed: () {},
                  child: const Icon(Icons.share, size: 15),
                ),
              ),
            ],
          ),
          Divider(
            thickness: 0.5,
            height: 0.5,
            // color: context.colorScheme.primary.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  void showComments(BuildContext context, usermodel) {
    var commentController = TextEditingController();
    showModalBottomSheet(
      context: context,
      builder: (context) => BottomSheet(
        onClosing: () {},
        builder: (context) => SingleChildScrollView(
          child: StreamBuilder(
              stream: widget.post.commentChanges,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  return Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        TextField(
                          controller: commentController,
                          decoration: InputDecoration(
                              labelText: "Write your comment",
                              suffix: IconButton(
                                  onPressed: () {
                                    widget.post.comment(commentController.text);
                                    commentController.text = "";
                                  },
                                  icon: const Icon(Icons.send))),
                        ),
                        StreamBuilder(
                          stream: widget.post.likeChanges,
                          builder: (context, snap) {
                            var map =
                                PostReaction.values.asMap().map((key, value) {
                              return MapEntry(value.emoji, <PostLikeModel>[]);
                            });
                            for (PostLikeModel like in snap.data ?? []) {
                              map[like.reaction.emoji]!.add(like);
                            }
                            map.removeWhere((key, value) {
                              return value.isEmpty;
                            });
                            var list = map.entries.toList()
                              ..sort((a, b) {
                                return a.value.length - b.value.length;
                              });
                            String? selectedEmoji;
                            return StatefulBuilder(
                                builder: (context, setState) {
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    children: [
                                      for (var react in list)
                                        InkWell(
                                          onTap: () {
                                            setState(
                                              () {
                                                selectedEmoji = react.key;
                                              },
                                            );
                                          },
                                          child: Text(
                                            "${react.key}${react.value.length}  ",
                                            style: const TextStyle(fontSize: 18),
                                          ),
                                        ),
                                    ],
                                  ),
                                  if (selectedEmoji != null)
                                    SizedBox(
                                      height: 70,
                                      child: SingleChildScrollView(
                                        child: Column(
                                          children: [
                                            for (var react
                                                in map[selectedEmoji]!)
                                              ListTile(
                                                leading: CircleAvatar(
                                                  backgroundImage: NetworkImage(
                                                      react.user.photoURL),
                                                ),
                                                title: Text(react.user.name),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  const Divider(
                                    thickness: 1,
                                  ),
                                ],
                              );
                            });
                          },
                        ),
                        for (var comment in snapshot.requireData)
                          ListTile(
                            title: RichText(
                              text: TextSpan(
                                text: comment.user.name,
                                style: Theme.of(context).textTheme.titleMedium,
                                children: [
                                  TextSpan(
                                    text: " ${comment.dateTime.formattedTime}",
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium!
                                        .copyWith(
                                          fontSize: 9.5,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            subtitle: Text(comment.data),
                            leading: InkWell(
                              onTap: () {
                                if (comment.user.uid == usermodel.uid) {
                                  context.go('/profile');
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ChangeNotifierProvider.value(
                                        value: comment.user,
                                        child: Profile(user: comment.user),
                                      ),
                                    ),
                                  );
                                }
                              },
                              child: CircleAvatar(
                                backgroundImage:
                                    NetworkImage(comment.user.photoURL),
                              ),
                            ),
                            trailing: PopupMenuButton(
                              itemBuilder: (context) {
                                return [
                                  if (comment.uid == usermodel.uid ||
                                      widget.post.uid == usermodel.uid)
                                    const PopupMenuItem(
                                      value: 1,
                                      child: Text("Delete"),
                                    ),
                                  if (comment.uid == usermodel.uid)
                                    const PopupMenuItem(
                                      value: 2,
                                      child: Text("Edit"),
                                    ),
                                  // const PopupMenuItem(
                                  //   value: 3,
                                  //   child: Text("Report"),
                                  // ),
                                ];
                              },
                              onSelected: (value) async {
                                if (value == 1) {
                                  try {
                                    await comment.delete();
                                  } catch (e) {
                                    log("cant delete");
                                    log(e.toString());
                                  }
                                } else if (value == 2) {
                                  try {
                                    // await comment.editComment()
                                  } catch (e) {}
                                }
                              },
                              icon: const Icon(Icons.more_vert),
                            ),
                          ),
                      ],
                    ),
                  );
                }
              },),
        ),
      ),
    );
  }
}
