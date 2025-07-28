import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'my_appointments_screen.dart';
import 'utils.dart';

class BookAppointmentScreen extends StatefulWidget {
  final String doctorName;
  final String doctorEmail;
  final String? appointmentId;
  final Map<String, dynamic>? existingData;

  const BookAppointmentScreen({
    Key? key,
    required this.doctorName,
    required this.doctorEmail,
    this.appointmentId,
    this.existingData,
  }) : super(key: key);

  @override
  _BookAppointmentScreenState createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.existingData != null) {
      _nameController.text = widget.existingData!['patientName'] ?? '';
      final dateString = widget.existingData!['date'] ?? '';
      final timeString = widget.existingData!['time'] ?? '';
      if (dateString.isNotEmpty) {
        final parts = dateString.split('-');
        if (parts.length == 3) {
          selectedDate = DateTime.tryParse(dateString);
        }
      }
      if (timeString.isNotEmpty) {
        final timeParts = timeString.split(':');
        if (timeParts.length == 2) {
          selectedTime = TimeOfDay(
            hour: int.tryParse(timeParts[0]) ?? 10,
            minute: int.tryParse(timeParts[1]) ?? 0,
          );
        }
      }
    }
  }

  void _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now().add(Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  void _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay(hour: 10, minute: 0),
    );
    if (picked != null) setState(() => selectedTime = picked);
  }

  Future<void> _bookAppointment() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('User not logged in.')));
      return;
    }

    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please enter patient name')));
      return;
    }

    if (selectedDate != null && selectedTime != null) {
      final patientEmail = user.email ?? '';
      final patientName = _nameController.text.trim();
      final patientId = getPatientIdFromEmail(patientEmail); // ✅ FIXED

      final data = {
        'doctorName': widget.doctorName,
        'doctorEmail': widget.doctorEmail,
        'date': "${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}",
        'time': selectedTime!.format(context),
        'patientName': patientName,
        'patientId': patientId,
        'patientEmail': patientEmail,
        'status': 'Pending',
      };

      if (widget.appointmentId != null) {
        await FirebaseFirestore.instance
            .collection('appointments')
            .doc(widget.appointmentId)
            .update(data);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Appointment updated!')));
      } else {
        await FirebaseFirestore.instance.collection('appointments').add(data);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Appointment booked successfully!')));
      }

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MyAppointmentsScreen()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please select date and time')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Book Appointment'), backgroundColor: Colors.blue),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text('Booking with ${widget.doctorName}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Enter Your Name', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.calendar_today),
              title: Text(selectedDate == null
                  ? 'Select Date'
                  : '${selectedDate!.day}-${selectedDate!.month}-${selectedDate!.year}'),
              onTap: _selectDate,
            ),
            ListTile(
              leading: Icon(Icons.access_time),
              title: Text(selectedTime == null ? 'Select Time' : selectedTime!.format(context)),
              onTap: _selectTime,
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _bookAppointment,
              child: Text(widget.appointmentId != null ? 'Update Appointment' : 'Book Now'),
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
            ),
          ],
        ),
      ),
    );
  }
}
