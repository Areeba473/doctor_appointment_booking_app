import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Add this import for logout
import 'doctor_chat_screen.dart';
import 'login_screen.dart'; // Add this import to navigate after logout

class DoctorDashboardScreen extends StatelessWidget {
  final String doctorEmail;
  final String doctorName;

  const DoctorDashboardScreen({
    Key? key,
    required this.doctorEmail,
    required this.doctorName,
  }) : super(key: key);

  void updateAppointmentStatus(String appointmentId, String newStatus) {
    FirebaseFirestore.instance
        .collection('appointments')
        .doc(appointmentId)
        .update({'status': newStatus});
  }

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Logged out successfully.')),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Doctor Dashboard'),
        backgroundColor: Colors.blue,
        actions: [
          TextButton.icon(
            onPressed: () => _logout(context),
            icon: Icon(Icons.logout, color: Colors.white),
            label: Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('appointments')
            .where('doctorEmail', isEqualTo: doctorEmail)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No appointments found."));
          }

          final appointments = snapshot.data!.docs;

          return ListView.builder(
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              final data = appointments[index].data() as Map<String, dynamic>;
              final docId = appointments[index].id;
              final patientName = data['patientName'] ?? 'Unknown';
              final patientEmail = data['patientId'] ?? '';
              final date = data['date'] ?? '';
              final time = data['time'] ?? '';
              final status = (data['status'] ?? 'Pending').toString();

              return Card(
                margin: const EdgeInsets.all(10),
                color: Colors.purple[50],
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.person),
                      title: Text('Patient: $patientName'),
                      subtitle: Text('$date at $time\n📌 Status: $status'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DoctorChatScreen(
                              patientEmail: patientEmail,
                              doctorEmail: doctorEmail,
                              doctorName: doctorName,
                            ),
                          ),
                        );
                      },
                    ),
                    if (status == 'Pending')
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                updateAppointmentStatus(docId, 'Approved');
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                              child: const Text('Approve'),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: () {
                                updateAppointmentStatus(docId, 'Rejected');
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                              child: const Text('Reject'),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
