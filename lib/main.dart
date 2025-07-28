import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'splash_screen.dart';
import 'video_call_screen.dart';
import 'chat_screen.dart'; // Optional: if you're using named navigation for chat

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Doctor Appointment App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: SplashScreen(),

      // Named routes
      onGenerateRoute: (settings) {
        if (settings.name == '/videoCall') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (_) => VideoCallScreen(
              roomName: args['roomName'],
              userName: args['userName'],
            ),
          );
        }

        // Optional: add chat route
        // if (settings.name == '/chat') {
        //   final args = settings.arguments as Map<String, dynamic>;
        //   return MaterialPageRoute(
        //     builder: (_) => ChatScreen(doctorName: args['doctorName']),
        //   );
        // }

        return null;
      },
    );
  }
}
