import 'package:flutter/material.dart';
import 'app.dart';
import 'core/services/firebase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 초기화
  try {
    await FirebaseService.initialize();
    print('✅ Firebase initialized successfully');
  } catch (e) {
    print('⚠️  Firebase initialization failed: $e');
    print('📱 Running in demo mode without Firebase');
  }

  runApp(const MannaBollaeApp());
}
