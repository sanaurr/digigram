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
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                const SizedBox(
                  height: 100,
                ),
                Text(
                  'DIGIGRAM',
                  style: GoogleFonts.pacifico(
                    textStyle: Theme.of(context).textTheme.headlineMedium,
                    // color: Colors.purple.shade700,
                  ),
                ),
                const SizedBox(
                  height: 50,
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,

                      borderRadius: BorderRadius.circular(15)),
                  child: TextField(
                    controller: mailController,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        prefixIcon: Icon(
                            isloginpage == true ? Icons.person : Icons.mail),
                        hintText:
                            isloginpage == true ? 'Username' : 'Enter E-mail'),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                Container(
                  // height: 40,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
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
                            child: const Text(
                              "forget password",
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
                        await FirebaseAuth.instance.signInWithEmailAndPassword(
                          email: mailController.text,
                          password: passwordController.text,
                        );
                      } catch (e) {
                        messanger.showSnackBar(
                          const SnackBar(
                              content: Text("Wrong Password or Mail Address!")),
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
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
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
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          isloginpage = !isloginpage;
                        });
                      },
                      child: Text(
                        isloginpage == true ? "Signup" : "Login",
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
