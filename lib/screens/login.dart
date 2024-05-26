import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool isloginpage = true;
  var mailController = TextEditingController();
  var passwordController = TextEditingController();
  bool showPassword = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/download.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(
                  sigmaX: 10,
                  sigmaY: 10), // Adjust the sigma values for the blur intensity
              child: Container(
                color: Colors.black.withOpacity(
                    0.05), // Adjust the opacity and color as needed
              ),
            ),
          ),
          Container(
            color: Colors.black.withOpacity(0.1),
          ),
          Container(
            padding: const EdgeInsets.all(30),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'DIGIGRAM',
                      style: GoogleFonts.pacifico(
                          textStyle: Theme.of(context).textTheme.headlineMedium,
                          color: Colors.purple.shade700,
                          shadows: [
                            Shadow(
                              offset: const Offset(
                                  -20, 20), // Set the offset of the shadow
                              blurRadius: 15, // Set the blur radius of the shadow
                              color: Colors.black.withOpacity(
                                  0.9), // Set the color and opacity of the shadow
                            ),
                          ]),
                    ),
                    const SizedBox(
                      height: 100,
                    ),
                    Container(
                      // height: 40,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.onPrimary,
                          boxShadow: const [
                            BoxShadow(
                              offset: Offset(-10, 10),
                              color: Colors.black,
                              blurRadius: 10,
                              spreadRadius: 0.2,
                            )
                          ],
                          borderRadius: BorderRadius.circular(15)),
                      child: TextField(
                        controller: mailController,
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            prefixIcon: Icon(
                                isloginpage == true ? Icons.person : Icons.mail),
                            hintText: isloginpage == true
                                ? 'Username'
                                : 'Enter E-mail'),
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Container(
                      // height: 40,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.onPrimary,
                          boxShadow: const [
                            BoxShadow(
                              offset: Offset(-10, 10),
                              color: Colors.black,
                              blurRadius: 10,
                              spreadRadius: 0.2,
                            )
                          ],
                          borderRadius: BorderRadius.circular(15)),
                      child: TextField(
                        obscureText: showPassword,
                        controller: passwordController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          prefixIcon: const Icon(Icons.lock),
                          hintText: 'Password',
                          suffix: InkWell(
                            onTap: () {
                              showPassword = !showPassword;
                              setState(() {});
                            },
                            child: Icon(showPassword
                                ? Icons.visibility_off_sharp
                                : Icons.visibility_sharp),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    isloginpage == true
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () {},
                                child: Text(
                                  "forget password",
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primaryContainer,
                                    shadows: [
                                      Shadow(
                                        offset: const Offset(-5,
                                            5), // Set the offset of the shadow
                                        blurRadius:
                                            5, // Set the blur radius of the shadow
                                        color: Colors.black.withOpacity(
                                            0.5), // Set the color and opacity of the shadow
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )
                        : const SizedBox(
                            height: 30,
                          ),
                    ElevatedButton(
                      onPressed: () async {
                        var messanger = ScaffoldMessenger.of(context);
                        if (isloginpage == true) {
                          try {
                            await FirebaseAuth.instance
                                .signInWithEmailAndPassword(
                              email: mailController.text,
                              password: passwordController.text,
                            );
                          } catch (e) {
                            messanger.showSnackBar(
                              const SnackBar(
                                  content:
                                      Text("Wrong Password or Mail Address!")),
                            );
                          }
                        } else {
                          try {
                            await FirebaseAuth.instance
                                .createUserWithEmailAndPassword(
                                    email: mailController.text,
                                    password: passwordController.text);
                          } on FirebaseAuthException catch (e) {
                            messanger.showSnackBar(
                                SnackBar(content: Text(e.message.toString())));
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 30,
                        backgroundColor: Theme.of(context).colorScheme.onPrimary,
                        foregroundColor: Theme.of(context).colorScheme.primary,
                        shadowColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              10), // Adjust the border radius as needed
                        ),
                      ),
                      child: Text(
                        isloginpage == true ? 'Login' : 'Signup',
                        style: const TextStyle(),
                      ),
                    ),
                    const SizedBox(
                      height: 50,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isloginpage == true
                              ? "Don't have account?"
                              : "Already have account?",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primaryContainer,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              isloginpage = !isloginpage;
                            });
                          },
                          child: Text(
                            isloginpage == true ? "Signup" : "Login",
                            style: TextStyle(
                              color:
                                  Theme.of(context).colorScheme.primaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
