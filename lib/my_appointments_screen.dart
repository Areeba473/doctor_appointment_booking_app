import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'utils.dart';
import 'book_appointment_screen.dart';

class MyAppointmentsScreen extends StatelessWidget {
  const MyAppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("My Appointments")),
        body: const Center(child: Text("User not logged in.")),
      );
    }

    final patientEmail = user.email!;
    final patientId = getPatientIdFromEmail(patientEmail); // ✅ FIXED

    return Scaffold(
      appBar: AppBar(title: const Text('My Appointments'), backgroundColor: Colors.blue),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('appointments')
            .where('patientId', isEqualTo: patientId) // ✅ FIXED QUERY
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No Appointments Found!'));
          }

          final appointments = snapshot.data!.docs;

          return ListView.builder(
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              final data = appointments[index].data() as Map<String, dynamic>;
              final doctorName = data['doctorName'] ?? 'Doctor';
              final date = data['date'] ?? '';
              final time = data['time'] ?? '';
              final status = data['status'] ?? 'Pending';
              final docId = appointments[index].id;

              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                color: Colors.purple[50],
                child: ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: Text('Dr. $doctorName'),
                  subtitle: Text('📅 $date   ⏰ $time\n📌 Status: $status'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BookAppointmentScreen(
                                doctorName: doctorName,
                                doctorEmail: data['doctorEmail'] ?? '',
                                appointmentId: docId,
                                existingData: data,
                              ),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text("Delete Appointment"),
                              content: const Text("Are you sure you want to delete this appointment?"),
                              actions: [
                                TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: const Text("Cancel")),
                                TextButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    child: const Text("Delete")),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            await FirebaseFirestore.instance
                                .collection('appointments')
                                .doc(docId)
                                .delete();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
