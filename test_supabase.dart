import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'lib/core/config/supabase_config.dart';

/// Quick Supabase Diagnostic Test
///
/// Run this to test your Supabase connection step by step:
/// flutter run -d chrome test_supabase.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('═══════════════════════════════════════════════════');
  print('🔍 SUPABASE DIAGNOSTIC TEST');
  print('═══════════════════════════════════════════════════\n');

  // Step 1: Test Initialization
  print('📋 STEP 1: Testing Supabase Initialization...');
  try {
    await SupabaseConfig.initialize();
    print('   ✅ PASSED: Supabase initialized successfully');
    print('   📍 URL: ${SupabaseConfig.supabaseUrl}\n');
  } catch (e) {
    print('   ❌ FAILED: $e');
    print('   💡 Check: Internet connection, URL, API key\n');
    return;
  }

  // Step 2: Test Client Access
  print('📋 STEP 2: Testing Client Access...');
  try {
    final client = SupabaseConfig.client;
    print('   ✅ PASSED: Client accessible\n');
  } catch (e) {
    print('   ❌ FAILED: $e\n');
    return;
  }

  // Step 3: Test Database Connection
  print('📋 STEP 3: Testing Database Connection...');
  try {
    final client = SupabaseConfig.client;

    // Test users table
    try {
      final usersResponse = await client.from('users').select('count').limit(1);
      print('   ✅ PASSED: users table accessible');
    } catch (e) {
      print('   ⚠️  WARNING: users table - $e');
    }

    // Test foods table
    try {
      final foodsResponse = await client.from('foods').select('count').limit(1);
      print('   ✅ PASSED: foods table accessible');
    } catch (e) {
      print('   ⚠️  WARNING: foods table - $e');
    }

    // Test stores table
    try {
      final storesResponse =
          await client.from('stores').select('count').limit(1);
      print('   ✅ PASSED: stores table accessible');
    } catch (e) {
      print('   ⚠️  WARNING: stores table - $e');
    }

    print('');
  } catch (e) {
    print('   ❌ FAILED: $e');
    print('   💡 Check: Table names, RLS policies\n');
  }

  // Step 4: Test Authentication Status
  print('📋 STEP 4: Testing Authentication Status...');
  try {
    final user = SupabaseConfig.currentUser;
    if (user != null) {
      print('   ✅ PASSED: User is authenticated');
      print('   👤 User ID: ${user.id}');
      print('   📧 Email: ${user.email}\n');
    } else {
      print('   ℹ️  INFO: No user currently authenticated');
      print('   💡 This is normal if you haven\'t logged in yet\n');
    }
  } catch (e) {
    print('   ❌ FAILED: $e\n');
  }

  // Step 5: Test Session
  print('📋 STEP 5: Testing Session...');
  try {
    final client = SupabaseConfig.client;
    final session = client.auth.currentSession;

    if (session != null) {
      print('   ✅ PASSED: Active session found');
      print('   🔑 Token expires: ${session.expiresAt}');
      if (session.expiresAt != null) {
        final expiresIn =
            DateTime.fromMillisecondsSinceEpoch(session.expiresAt! * 1000)
                .difference(DateTime.now());
        print('   ⏰ Expires in: $expiresIn\n');
      } else {
        print('   ⏰ Expires in: Unknown\n');
      }
    } else {
      print('   ℹ️  INFO: No active session');
      print('   💡 Login to create a session\n');
    }
  } catch (e) {
    print('   ❌ FAILED: $e\n');
  }

  // Summary
  print('═══════════════════════════════════════════════════');
  print('📊 DIAGNOSTIC SUMMARY');
  print('═══════════════════════════════════════════════════');
  print('✅ If all steps passed, your Supabase connection is working!');
  print('⚠️  If any step failed, check the error messages above.');
  print('💡 See SUPABASE_TROUBLESHOOTING.md for detailed solutions.\n');

  // Keep app running to see results
  runApp(const MaterialApp(
    home: Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 64),
            SizedBox(height: 16),
            Text(
              'Supabase Diagnostic Complete!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Check the terminal for detailed results'),
          ],
        ),
      ),
    ),
  ));
}
