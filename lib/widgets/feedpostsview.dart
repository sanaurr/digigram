import 'package:digigram/models/post_model.dart';
import 'package:digigram/models/user_model.dart';
import 'package:digigram/widgets/post_view.dart';
import 'package:digigram/widgets/storybar.dart';
import 'package:flutter/material.dart';
import 'package:loading_provider/loading_provider.dart';
import 'package:provider/provider.dart';

class FeedPosts extends StatefulWidget {
  const FeedPosts({super.key});

  @override
  State<FeedPosts> createState() => _FeedPostsState();
}

class _FeedPostsState extends State<FeedPosts> {
  List<PostModel> posts = [];
  bool isloading = false;

  @override
  void initState() {
    super.initState();
    loadPosts();
  }

  Future<void> loadPosts() async {
    // setState(() {
    //   isloading = true;
    // });
    var usermodel = context.read<UserModel>();
    posts = await usermodel.getFeedPosts();
    if (mounted) {
      setState(() {
        isloading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => await loadPosts(),
      child: LoadingWidget(
        isLoading: isloading,
        child: ListView(
          children: [
            const Padding(
              padding: EdgeInsets.all(15.0),
              child: Storybar(),
            ),
            for (var post in posts) PostView(post),
          ],
        ),
      ),
    );
  }
}
