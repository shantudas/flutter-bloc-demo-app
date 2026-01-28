import 'package:flutter/material.dart';
import '../../core/services/firebase_service.dart';
import '../../core/utils/app_logger.dart';
import '../../core/utils/crashlytics_helper.dart';

/// Debug screen for testing Crashlytics integration
/// Only use in development!
class CrashlyticsTestScreen extends StatelessWidget {
  const CrashlyticsTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crashlytics Test'),
        backgroundColor: Colors.orange,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Test Crashlytics Integration',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Use these buttons to test different Crashlytics features. Check Firebase Console → Crashlytics to see the results.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),

          // Test non-fatal exception
          _buildTestCard(
            title: 'Test Non-Fatal Exception',
            description: 'Sends a test exception without crashing the app',
            icon: Icons.warning,
            color: Colors.orange,
            onPressed: () async {
              AppLogger.info('Sending test non-fatal exception');
              await FirebaseService.instance.sendTestException();
              _showSnackbar(context, 'Test exception sent!');
            },
          ),

          // Test fatal crash (force crash)
          _buildTestCard(
            title: 'Force Crash (Dev Only)',
            description: 'Forces the app to crash (only works in debug mode)',
            icon: Icons.error,
            color: Colors.red,
            onPressed: () {
              AppLogger.warning('Attempting to force crash');
              FirebaseService.instance.forceCrash();
            },
          ),

          // Test custom keys
          _buildTestCard(
            title: 'Set Custom Keys',
            description: 'Sets custom key-value pairs for context',
            icon: Icons.key,
            color: Colors.blue,
            onPressed: () async {
              await FirebaseService.instance.setCustomKey('test_key', 'test_value');
              await FirebaseService.instance.setCustomKey('test_number', 42);
              await FirebaseService.instance.setCustomKey('test_bool', true);
              AppLogger.info('Custom keys set');
              _showSnackbar(context, 'Custom keys set!');
            },
          ),

          // Test user identifier
          _buildTestCard(
            title: 'Set User Identifier',
            description: 'Sets a test user ID',
            icon: Icons.person,
            color: Colors.green,
            onPressed: () async {
              await CrashlyticsHelper.setUser(
                'test_user_123',
                email: 'test@example.com',
                username: 'testuser',
              );
              _showSnackbar(context, 'User identifier set!');
            },
          ),

          // Test breadcrumbs
          _buildTestCard(
            title: 'Log Breadcrumbs',
            description: 'Logs several breadcrumb messages',
            icon: Icons.list,
            color: Colors.purple,
            onPressed: () async {
              AppLogger.info('User navigated to test screen');
              await Future.delayed(const Duration(milliseconds: 100));

              AppLogger.info('User clicked test button');
              await Future.delayed(const Duration(milliseconds: 100));

              AppLogger.warning('Test warning message');
              await Future.delayed(const Duration(milliseconds: 100));

              AppLogger.info('Breadcrumb trail created');
              _showSnackbar(context, 'Breadcrumbs logged!');
            },
          ),

          // Test handled exception
          _buildTestCard(
            title: 'Record Handled Exception',
            description: 'Records an exception that was caught and handled',
            icon: Icons.catching_pokemon,
            color: Colors.teal,
            onPressed: () async {
              try {
                throw Exception('This is a test handled exception');
              } catch (e, stackTrace) {
                await CrashlyticsHelper.recordHandledException(
                  e,
                  stackTrace,
                  context: 'Testing handled exception recording',
                );
                _showSnackbar(context, 'Handled exception recorded!');
              }
            },
          ),

          // Test network error
          _buildTestCard(
            title: 'Simulate Network Error',
            description: 'Records a simulated network error',
            icon: Icons.cloud_off,
            color: Colors.deepOrange,
            onPressed: () async {
              await CrashlyticsHelper.recordNetworkError(
                'https://api.example.com/test',
                500,
                'Internal Server Error',
                method: 'GET',
              );
              _showSnackbar(context, 'Network error recorded!');
            },
          ),

          // Test milestone logging
          _buildTestCard(
            title: 'Log Milestone',
            description: 'Logs a user journey milestone',
            icon: Icons.flag,
            color: Colors.indigo,
            onPressed: () async {
              await CrashlyticsHelper.logMilestone(
                'completed_test_flow',
                data: {
                  'test_count': 5,
                  'success': true,
                },
              );
              _showSnackbar(context, 'Milestone logged!');
            },
          ),

          const SizedBox(height: 24),
          const Card(
            color: Colors.yellow,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info, color: Colors.black),
                      SizedBox(width: 8),
                      Text(
                        'Important Notes',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text('• Check Firebase Console → Crashlytics to see reports'),
                  Text('• It may take a few minutes for reports to appear'),
                  Text('• Force crash only works in debug mode'),
                  Text('• Remove this screen before production release'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );
  }
}

