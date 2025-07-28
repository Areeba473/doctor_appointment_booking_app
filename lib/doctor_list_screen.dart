import 'package:flutter/material.dart';
import 'doctor_profile_screen.dart';

class DoctorListScreen extends StatelessWidget {
  final List<Map<String, String>> doctors = [
    {
      'name': 'Dr. Areeba Chaudhary',
      'specialty': 'Cardiologist',
      'email': 'doctor_areeba@gmail.com', // ✅ fixed
    },
    {
      'name': 'Dr. Ali Khan',
      'specialty': 'Dermatologist',
      'email': 'doctor_ali@gmail.com', // ✅ fixed
    },
    {
      'name': 'Dr. Sara Ahmed',
      'specialty': 'Pediatrician',
      'email': 'doctor_sara@gmail.com', // ✅ optional third
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Doctors List'),
        backgroundColor: Colors.blue,
      ),
      body: ListView.builder(
        itemCount: doctors.length,
        itemBuilder: (context, index) {
          final doctor = doctors[index];

          return Card(
            elevation: 4,
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: ListTile(
              leading: CircleAvatar(child: Icon(Icons.person)),
              title: Text(doctor['name'] ?? ''),
              subtitle: Text(doctor['specialty'] ?? ''),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DoctorProfileScreen(
                      name: doctor['name']!,
                      specialty: doctor['specialty']!,
                      email: doctor['email']!,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
