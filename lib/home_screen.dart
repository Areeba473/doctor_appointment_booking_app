import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'doctor_list_screen.dart';
import 'my_appointments_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  // Logout function
  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    // Show SnackBar after logout
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Logged out successfully.')),
    );

    // Navigate to LoginScreen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    // If not logged in, redirect to login screen
    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      });
      return Scaffold(); // Empty widget while redirecting
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Home'),
        backgroundColor: Colors.blue,
        actions: [
          TextButton.icon(
            onPressed: () => _logout(context),
            icon: Icon(Icons.logout, color: Colors.white),
            label: Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Logged in as: ${user.email}",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 4,
              child: ListTile(
                leading: const Icon(Icons.list, size: 40, color: Colors.blue),
                title: const Text('View Doctors'),
                subtitle: const Text('Browse and book appointments'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => DoctorListScreen()),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 4,
              child: ListTile(
                leading: const Icon(Icons.calendar_today, size: 40, color: Colors.green),
                title: const Text('My Appointments'),
                subtitle: const Text('View upcoming appointments'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => MyAppointmentsScreen()),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
