
import 'package:digigram/models/user_model.dart';
import 'package:digigram/utils/extentions.dart';
import 'package:digigram/widgets/connections.dart';
import 'package:digigram/widgets/feedpostsview.dart';
import 'package:digigram/widgets/new_post.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_provider/loading_provider.dart';
import 'package:provider/provider.dart';


class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int selectedNav = 0;
  void onposted() {
    setState(() {
      selectedNav = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    var usermodel = context.watch<UserModel>();
    var isDeskTop = MediaQuery.of(context).size.width > 600;
    return Scaffold(
      appBar: selectedNav != 1
          ? AppBar(
              title: const Text("DIGIGRAM"),
              backgroundColor: context.colorScheme.secondary,
              foregroundColor: context.colorScheme.onSecondary,
              actions: [
                IconButton(
                  onPressed: () async {
                    context.loadingController.on();
                    await Future.delayed(
                      const Duration(seconds: 3),
                    );
                    context.loadingController.off();
                  },
                  icon: const Icon(Icons.notifications),
                ),
                IconButton(
                  onPressed: () {
                    context.go('/profile');
                  },
                  icon: SizedBox.square(
                    dimension: 30,
                    child: CircleAvatar(
                      backgroundImage:
                          NetworkImage(usermodel.photoURL),
                    ),
                  ),
                ),
              ],
            )
          : null,
      body: Row(
        children: [
          if (isDeskTop)
            NavigationRail(
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.home),
                  label: Text('Home'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.add),
                  label: Text('New Post'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.person_add),
                  label: Text('Connections'),
                ),
              ],
              selectedIndex: selectedNav,
              onDestinationSelected: (index) {
                setState(() {
                  selectedNav = index;
                });
              },
            ),
          Expanded(
            child: selectedNav == 2
                ? const Connections()
                : selectedNav == 1
                    ? NewPost(onposted: onposted)
                    : const FeedPosts(),
          ),
        ],
      ),
      bottomNavigationBar: isDeskTop
          ? null
          : CurvedNavigationBar(
              height: 50,
              items: [
                Icon(Icons.home,
                    size: 30, color: context.colorScheme.onSecondary),
                Icon(Icons.add,
                    size: 30, color: context.colorScheme.onSecondary),
                Icon(Icons.person_add,
                    size: 30, color: context.colorScheme.onSecondary),
              ],
              color: context.colorScheme.secondary,
              buttonBackgroundColor: context.colorScheme.secondary,
              backgroundColor: Colors.transparent,
              animationCurve: Curves.easeInOut,
              animationDuration: const Duration(milliseconds: 400),
              index: selectedNav,
              onTap: (index) {
                setState(() {
                  selectedNav = index;
                });
              },
              letIndexChange: (index) => true,
            ),
    );
  }
}
