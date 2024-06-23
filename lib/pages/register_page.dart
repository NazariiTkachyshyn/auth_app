import 'package:auth_app/components/my_button.dart';
import 'package:auth_app/components/my_textfield.dart';
import 'package:auth_app/helper/helper_functions.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? onTap;

  RegisterPage({super.key, this.onTap});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Text controllers
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPwController = TextEditingController();
  TextEditingController businessNameController = TextEditingController();
  TextEditingController licenseNumberController = TextEditingController();
  TextEditingController companyNameController = TextEditingController();
  TextEditingController companyIdController = TextEditingController();

  String userType = 'Individual';

  void registerUser() async {
    // loading circle
    showDialog(
      context: context,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
    // make sure passwords matches
    if (passwordController.text != confirmPwController.text) {
      Navigator.pop(context);
      displayMessageToUser("Passwords dont't match!", context);
    } else {
      try {
        // creating User
        UserCredential? userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );

        // create a user doc and add to db
        createUserDocument(userCredential);

        //pop loading cirсle
        if (mounted) Navigator.pop(context);
      } on FirebaseAuthException catch (e) {
        Navigator.pop(context);

        displayMessageToUser(e.code, context);
      }
    }
    // try creating user
  }

  Future<void> createUserDocument(UserCredential? userCredential) async {
    if (userCredential != null && userCredential.user != null) {
      Map<String, dynamic> userData = {
        'email': userCredential.user!.email,
        'name': nameController.text,
        'userType': userType,
      };

      if (userType == 'FOP') {
        userData.addAll({
          'businessName': businessNameController.text,
          'licenseNumber': licenseNumberController.text,
        });
      } else if (userType == 'Legal Entity') {
        userData.addAll({
          'companyName': companyNameController.text,
          'companyId': companyIdController.text,
        });
      }

      await FirebaseFirestore.instance
          .collection("Users")
          .doc(userCredential.user!.email)
          .set(userData);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App name
                const Text(
                  'My App',
                  style: TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 55),

                // Name textfield
                MyTextfield(
                  hintText: 'Name',
                  obscureText: false,
                  controller: nameController,
                ),
                const SizedBox(height: 10),

                // Email textfield
                MyTextfield(
                  hintText: 'Email',
                  obscureText: false,
                  controller: emailController,
                ),
                const SizedBox(height: 10),

                // Password textfield
                MyTextfield(
                  hintText: 'Password',
                  obscureText: true,
                  controller: passwordController,
                ),
                const SizedBox(height: 10),

                // Confirm password textfield
                MyTextfield(
                  hintText: 'Confirm Password',
                  obscureText: true,
                  controller: confirmPwController,
                ),
                const SizedBox(height: 15),

                // User type selection carousel
                CarouselSlider(
                  options: CarouselOptions(
                    height: 60.0,
                    enlargeCenterPage: true,
                    onPageChanged: (index, reason) {
                      setState(() {
                        switch (index) {
                          case 0:
                            userType = 'Individual';
                            break;
                          case 1:
                            userType = 'FOP';
                            break;
                          case 2:
                            userType = 'Legal Entity';
                            break;
                        }
                      });
                    },
                  ),
                  items: ['Individual', 'FOP', 'Legal Entity'].map((i) {
                    return Builder(
                      builder: (BuildContext context) {
                        return Container(
                          width: MediaQuery.of(context).size.width,
                          margin: const EdgeInsets.symmetric(horizontal: 5.0),
                          decoration: BoxDecoration(
                            color: Colors.black26,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              i,
                              style: const TextStyle(fontSize: 16.0),
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 10),

                // Additional fields based on user type with animation
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: AnimatedOpacity(
                    opacity: (userType == 'Individual') ? 0 : 1,
                    duration: const Duration(milliseconds: 300),
                    child: Column(
                      key: ValueKey<String>(userType),
                      children: [
                        if (userType == 'FOP') ...[
                          MyTextfield(
                            hintText: 'Business Name',
                            obscureText: false,
                            controller: businessNameController,
                          ),
                          const SizedBox(height: 10),
                          MyTextfield(
                            hintText: 'License Number',
                            obscureText: false,
                            controller: licenseNumberController,
                          ),
                        ] else if (userType == 'Legal Entity') ...[
                          MyTextfield(
                            hintText: 'Company Name',
                            obscureText: false,
                            controller: companyNameController,
                          ),
                          const SizedBox(height: 10),
                          MyTextfield(
                            hintText: 'Company ID',
                            obscureText: false,
                            controller: companyIdController,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 5),

                // Forgot password
                const Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text("Forgot password?"),
                  ],
                ),
                const SizedBox(height: 5),

                // Register button
                MyButton(
                  text: "Register",
                  onTap: registerUser,
                ),
                const SizedBox(height: 25),

                // Login prompt
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have account?"),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: const Text(
                        'Login here',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
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
    );
  }
}
