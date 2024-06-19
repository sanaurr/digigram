import 'package:digigram/models/theme_provider.dart';
// import 'package:digigram/models/user_model.dart';
import 'package:digigram/widgets/change_password.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../widgets/update_profile.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  bool editProfile = false;
  bool changePassword = false;

  @override
  Widget build(BuildContext context) {
    // var usermodel = context.watch<UserModel>();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (editProfile)
                UpdateProfile(
                  onDone: () {
                    setState(() {
                      editProfile = false;
                      changePassword = false;
                    });
                  },
                )
              else if (changePassword)
                const ChangePassword()
              else ...[
                ListTile(
                  title: const Text("Edit Profile"),
                  onTap: () {
                    setState(() {
                      editProfile = true;
                    });
                  },
                ),
                ListTile(
                  title: const Text("Change password"),
                  onTap: () {
                    setState(() {
                      changePassword = true;
                    });
                  },
                ),
                const SizedBox(
                  height: 30,
                ),
                ListTile(
                  title: const Text('Dark Mode'),
                  trailing: Switch(
                    value: Theme.of(context).brightness == Brightness.dark,
                    onChanged: (value) {
                      if (value) {
                        context.read<ThemeProvider>().mode = Brightness.dark;
                      } else {
                        context.read<ThemeProvider>().mode = Brightness.light;
                      }
                    },
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                ElevatedButton(
                  onPressed: () async {
                    var router = GoRouter.of(context);
                    await FirebaseAuth.instance.signOut();
                    router.go('/');
                  },
                  child: const Text("Logout"),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
