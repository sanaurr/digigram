import 'package:digigram/utils/extentions.dart';
import 'package:flutter/material.dart';

class Aboutus extends StatefulWidget {
  const Aboutus({super.key});

  @override
  State<Aboutus> createState() => _AboutusState();
}

class _AboutusState extends State<Aboutus> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("About Digigram"),
        centerTitle: true,
        backgroundColor: context.colorScheme.secondary,
        foregroundColor: context.colorScheme.onSecondary,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: Image.asset("assets/us.jpeg").image,
            fit: BoxFit.contain,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                color: context.colorScheme.surface,
                child: const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 50,
                      ),
                      Text(
                        "DIGIGRAM is a social media platform for sharing images and videos. Users can upload images and videos of their moments.It's a beta version of DIGIGRAM.It's now available only for beta testing.Send your feedback to improve the platform.",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(
                        height: 50,
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                height: 300,
                color: context.colorScheme.secondary,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundImage: Image.asset("assets/b.jpg").image,
                          ),
                          const Column(
                            children: [
                              Text(
                                "SANAUR RAHAMAN",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                "Developer of DIGIGRAM",
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                //
              ),
              Container(
                height: 200,
              ),
              Container(
                height: 200,
                color: context.colorScheme.tertiary,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundImage:
                                Image.asset("assets/amit.jpeg").image,
                          ),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "AMIT HASAN",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                "Instructor of DIGIGRAM,\nprogramming teacher of \nSANAUR RAHAMAN",
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                //
              ),
              Container(
                height: 100,
                color: Colors.transparent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
