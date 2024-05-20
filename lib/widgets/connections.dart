import 'package:digigram/models/user_model.dart';
import 'package:digigram/screens/profile.dart';
import 'package:digigram/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Connections extends StatefulWidget {
  const Connections({super.key});

  @override
  State<Connections> createState() => _ConnectionsState();
}

class _ConnectionsState extends State<Connections> {
  Future<List<UserModel>>? searchUsers;
  var searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'Search',
              suffix: IconButton(
                onPressed: () async {
                  setState(() {
                    searchUsers = context.read<UserModel>().searchUsers(
                          searchController.text.trim(),
                        );
                  });
                },
                icon: const Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder(
                future: searchUsers,
                builder: (context, snap) {
                  if (!snap.hasData) {
                    return const SizedBox.shrink();
                  } else {
                    return ListView(
                      children: [
                        const SizedBox(height: 10),
                        for (var user in snap.requireData) ...[
                          ListTile(
                            leading: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ChangeNotifierProvider.value(
                                      value: user,
                                      child: Profile(user: user),
                                    ),
                                  ),
                                );
                              },
                              child: CircleAvatar(
                                backgroundImage: NetworkImage(user.photoURL),
                              ),
                            ),
                            title: Text(user.name),
                            trailing: context.read<UserModel>().uid == user.uid
                                ? null
                                : IconButton(
                                    onPressed: () async {
                                      var currentuser =
                                          context.read<UserModel>();
                                      if (currentuser.following
                                          .contains(user.uid)) {
                                        currentuser.unfollow(user.uid);
                                      } else {
                                        currentuser.follow(user.uid);
                                      }
                                    },
                                    icon: Icon(
                                      context
                                              .watch<UserModel>()
                                              .following
                                              .contains(user.uid)
                                          ? Icons.remove_circle_outline
                                          : Icons.person_add_alt_1,
                                      color: context
                                              .watch<UserModel>()
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
          ),
        ],
      ),
    );
  }
}
