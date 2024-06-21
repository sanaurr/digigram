import 'package:digigram/firebase_options.dart';
import 'package:digigram/models/story_model.dart';
import 'package:digigram/models/theme_provider.dart';
import 'package:digigram/models/user_model.dart';
import 'package:digigram/screens/dashboard.dart';
import 'package:digigram/screens/login.dart';
import 'package:digigram/screens/profile.dart';
import 'package:digigram/screens/settings.dart';
import 'package:digigram/screens/update_profile.dart';
import 'package:digigram/utils/loading.dart';
import 'package:digigram/widgets/add_story.dart';
import 'package:digigram/widgets/story.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_provider/loading_provider.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => ThemeProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => Loading(),
        ),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return LoadingProvider(
      appBuilder: (context, builder) => MaterialApp.router(
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: const Color.fromARGB(255, 43, 76, 128),
          brightness: context.watch<ThemeProvider>().mode,
        ),
        debugShowCheckedModeBanner: false,
        routerConfig: GoRouter(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) {
                return StreamBuilder(
                    stream: FirebaseAuth.instance.userChanges(),
                    builder: (context, snapshot) {
                      return snapshot.hasData
                          ? StreamBuilder(
                              stream: UserModelStaticService.userChanges(),
                              builder: (context, modelSnapshot) {
                                if (!modelSnapshot.hasData) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                } else {
                                  return ChangeNotifierProvider.value(
                                    value: modelSnapshot.requireData,
                                    child: modelSnapshot.requireData.isEmptyuser
                                        ? const UpdateProfileScreen()
                                        : const Dashboard(),
                                  );
                                }
                              })
                          : const Login();
                    });
              },
              routes: [
                GoRoute(
                  path: 'profile',
                  redirect: (context, state) async {
                    if (FirebaseAuth.instance.currentUser == null) {
                      return "/";
                    } else {
                      return null;
                    }
                  },
                  builder: (context, state) {
                    return StreamBuilder(
                      stream: UserModelStaticService.userChanges(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return ChangeNotifierProvider.value(
                            value: snapshot.requireData,
                            child: const Profile(),
                          );
                        } else {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                      },
                    );
                  },
                  routes: [
                    GoRoute(
                      path: 'settings',
                      redirect: (context, state) async {
                        if (FirebaseAuth.instance.currentUser == null) {
                          return "/";
                        } else {
                          return null;
                        }
                      },
                      builder: (context, state) {
                        return StreamBuilder(
                          stream: UserModelStaticService.userChanges(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return ChangeNotifierProvider.value(
                                value: snapshot.requireData,
                                child: const Settings(),
                              );
                            } else {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                          },
                        );
                      },
                    ),
                  ],
                ),
                GoRoute(
                  path: 'addstory',
                  redirect: (context, state) async {
                    if (FirebaseAuth.instance.currentUser == null) {
                      return "/";
                    } else {
                      return null;
                    }
                  },
                  builder: (context, state) => const AddStory(),
                ),
                GoRoute(
                  path: 'viewstory',
                  redirect: (context, state) async {
                    if (FirebaseAuth.instance.currentUser == null || state.extra == null || state.extra is! List<List<Story>>) {
                      return "/";
                    } else {
                      return null;
                    }
                  },
                  builder: (context, state) => StoryPage(stories: state.extra as List<List<Story>>),
                ),
              ],
            ),
          ],
        ),
        builder: builder,
      ),
      loadings: {
        'circular': LoadingConfig(
          backgroundColor: Colors.blue.withOpacity(0.4),
          widget: const CircularProgressIndicator(),
        ),
        'text': LoadingConfig(
          backgroundColor: Colors.green.withOpacity(0.5),
          widget: const Text("Loading"),
        ),
        'onpoastloading': LoadingConfig(
          backgroundColor: Colors.blue.withOpacity(0.4),
          widget: Lottie.asset('assets/lotties/onpost.json'),
        ),
      },
    );
  }
}
