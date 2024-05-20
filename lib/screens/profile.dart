import 'package:digigram/models/post_model.dart';
import 'package:digigram/models/user_model.dart';
import 'package:digigram/screens/view_image.dart';
import 'package:digigram/utils/extentions.dart';
import 'package:digigram/widgets/post_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class Profile extends StatefulWidget {
  const Profile({super.key, this.user});
  final UserModel? user;
  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  int selectedTab = 0;
  int followercount = 0;
  int followingcount = 0;
  @override
  Widget build(BuildContext context) {
    var currentUsermodel = widget.user ?? context.watch<UserModel>();
    var ismyProfile = widget.user == null;
    return Scaffold(
      appBar: AppBar(
        title: Text("${currentUsermodel.name}'s Profile"),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              context.go('/profile/settings');
            },
            icon: Icon(ismyProfile ? Icons.settings : null),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox.square(
                    dimension: 100,
                    child: InkWell(
                      onTap: () {
                        context.viewImage(currentUsermodel.photoURL);
                      },
                      child: CircleAvatar(
                        backgroundImage:
                            NetworkImage(currentUsermodel.photoURL),
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        currentUsermodel.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 25,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Text(currentUsermodel.bio),
              const SizedBox(
                height: 40,
              ),
              DefaultTabController(
                length: 3,
                child: TabBar(
                  onTap: (value) {
                    setState(() {
                      selectedTab = value;
                    });
                  },
                  tabs: [
                    const Text("Posts"),
                    FittedBox(child: Text("Followers($followercount)")),
                    FittedBox(child: Text("Following($followingcount)")),
                  ],
                ),
              ),
              if (selectedTab == 0)
                FutureBuilder(
                    future: currentUsermodel.getOwnFeedPosts(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      } else {
                        return Column(
                          children: [
                            for (var post in snapshot.requireData)
                              PostView(post),
                          ],
                        );
                      }
                    })
              else if (selectedTab == 1)
                FutureBuilder(
                    key: const ValueKey(1),
                    future: currentUsermodel.getFollowers(),
                    builder: (context, snap) {
                      if (!snap.hasData) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      } else {
                        WidgetsBinding.instance.addPostFrameCallback(
                          (timeStamp) {
                            setState(() {
                              followercount = snap.requireData.length;
                            });
                          },
                        );
                        return Column(
                          children: [
                            const SizedBox(height: 10),
                            for (var user in snap.requireData) ...[
                              ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: NetworkImage(user.photoURL),
                                ),
                                title: Text(user.name),
                                trailing:
                                    user.uid == context.watch<UserModel>().uid
                                        ? null
                                        : IconButton(
                                            onPressed: () {
                                              if (context
                                                  .read<UserModel>()
                                                  .following
                                                  .contains(user.uid)) {
                                                context
                                                    .read<UserModel>()
                                                    .unfollow(user.uid);
                                              } else {
                                                context
                                                    .read<UserModel>()
                                                    .follow(user.uid);
                                              }
                                            },
                                            icon: Icon(
                                              context
                                                      .read<UserModel>()
                                                      .following
                                                      .contains(user.uid)
                                                  ? Icons.remove_circle_outline
                                                  : Icons.person_add_alt_1,
                                            ),
                                          ),
                              ),
                              const Divider(thickness: 0.5),
                            ],
                          ],
                        );
                      }
                    })
              else
                FutureBuilder(
                    key: const ValueKey(2),
                    future: currentUsermodel.getFollowing(),
                    builder: (context, snap) {
                      if (!snap.hasData) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      } else {
                        WidgetsBinding.instance.addPostFrameCallback(
                          (timeStamp) {
                            setState(() {
                              followingcount = snap.requireData.length;
                            });
                          },
                        );
                        return Column(
                          children: [
                            const SizedBox(height: 10),
                            for (var user in snap.requireData) ...[
                              ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: NetworkImage(user.photoURL),
                                ),
                                title: Text(user.name),
                                trailing: IconButton(
                                  onPressed: () {
                                    if (context
                                        .read<UserModel>()
                                        .following
                                        .contains(user.uid)) {
                                      context
                                          .read<UserModel>()
                                          .unfollow(user.uid);
                                    } else {
                                      context
                                          .read<UserModel>()
                                          .follow(user.uid);
                                    }
                                  },
                                  icon: Icon(
                                    context
                                            .read<UserModel>()
                                            .following
                                            .contains(user.uid)
                                        ? Icons.remove_circle_outline
                                        : Icons.person_add_alt_1,
                                    color: context
                                            .read<UserModel>()
                                            .following
                                            .contains(user.uid)
                                        ? context.colorScheme.primary
                                        : null,
                                  ),
                                ),
                              ),
                              const Divider(thickness: 0.5),
                            ],
                          ],
                        );
                      }
                    }),
            ],
          ),
        ),
      ),
    );
  }
}
