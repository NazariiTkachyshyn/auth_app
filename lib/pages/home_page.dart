import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  User? currentUser = FirebaseAuth.instance.currentUser;

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserDetails() async {
    return await FirebaseFirestore.instance
        .collection('Users')
        .doc(currentUser!.email)
        .get();
  }

  void logout(BuildContext context) {
    FirebaseAuth.instance.signOut();
    Navigator.popUntil(context,
        ModalRoute.withName('/')); // повернення на екран входу після виходу
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("HomePage"),
        backgroundColor: Colors.cyan,
        elevation: 0,
        actions: [
          // logout button
          IconButton(
            onPressed: () => logout(context),
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: getUserDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (snapshot.hasData) {
            Map<String, dynamic>? user = snapshot.data!.data();
            if (user == null) {
              return const Center(child: Text('No data'));
            }
            String userType = user['userType'];

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Email: ${user['email']}',
                      style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  Text('Name: ${user['name']}',
                      style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  Text('User Type: $userType',
                      style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  if (userType == 'FOP') ...[
                    Text('Business Name: ${user['businessName']}',
                        style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    Text('License Number: ${user['licenseNumber']}',
                        style: const TextStyle(fontSize: 16)),
                  ] else if (userType == 'Legal Entity') ...[
                    Text('Company Name: ${user['companyName']}',
                        style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    Text('Company ID: ${user['companyId']}',
                        style: const TextStyle(fontSize: 16)),
                  ],
                ],
              ),
            );
          } else {
            return const Center(child: Text('No data'));
          }
        },
      ),
    );
  }
}
