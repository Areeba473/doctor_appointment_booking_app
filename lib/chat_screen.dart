import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'utils.dart';

class ChatScreen extends StatefulWidget {
  final String doctorEmail;
  final String doctorName;

  const ChatScreen({
    Key? key,
    required this.doctorEmail,
    required this.doctorName,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final patientEmail = user?.email ?? '';

    // 🔍 Debug logs
    print('LOGGED IN PATIENT EMAIL: $patientEmail');
    print('DOCTOR EMAIL: ${widget.doctorEmail}');
    final chatId = generateChatIdFromEmails(patientEmail, widget.doctorEmail);
    print('PATIENT CHAT ID: $chatId');

    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with ${widget.doctorName}'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(chatId)
                  .collection('messages')
                  .orderBy('timestamp')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final messages = snapshot.data!.docs;

                return ListView(
                  children: messages.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final isPatient = data['sender'] == 'patient';
                    final text = data['text'] ?? '';
                    final timestamp = data['timestamp'] as Timestamp?;
                    final time = timestamp != null
                        ? DateFormat('hh:mm a').format(timestamp.toDate())
                        : '';

                    return Align(
                      alignment: isPatient ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isPatient ? Colors.blue[100] : Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment:
                          isPatient ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            Text(text),
                            Text(time, style: const TextStyle(fontSize: 10)),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: 'Type your message...',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: () async {
                  final text = _controller.text.trim();
                  if (text.isEmpty) return;

                  await FirebaseFirestore.instance
                      .collection('chats')
                      .doc(chatId)
                      .collection('messages')
                      .add({
                    'text': text,
                    'sender': 'patient',
                    'timestamp': FieldValue.serverTimestamp(),
                  });

                  _controller.clear();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
