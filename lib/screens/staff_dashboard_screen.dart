import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/crisis_service.dart';
import '../models/crisis.dart';
import '../widgets/crisis_card.dart';
import 'guest_sos_screen.dart';

class StaffDashboardScreen extends StatelessWidget {
  const StaffDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final crisisService = CrisisService();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(children: [
          const Icon(Icons.emergency_share_rounded,
              color: Color(0xFFE53935), size: 22),
          const SizedBox(width: 8),
          const Text('CrisisIQ',
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(width: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFE53935).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text('STAFF',
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE53935))),
          ),
        ]),
        actions: [
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const GuestSOSScreen()),
                );
              }
            },
            icon:
                const Icon(Icons.logout_rounded, color: Colors.grey),
          ),
        ],
      ),
      body: StreamBuilder<List<Crisis>>(
        stream: crisisService.getActiveCrises(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Connection error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red)),
            );
          }

          final crises = snapshot.data ?? [];

          if (crises.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline,
                      size: 72, color: Colors.green[300]),
                  const SizedBox(height: 16),
                  const Text('All Clear',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7D32))),
                  const SizedBox(height: 8),
                  Text('No active emergencies',
                      style: TextStyle(color: Colors.grey[500])),
                ],
              ),
            );
          }

          return Column(children: [
            // Active banner
            Container(
              width: double.infinity,
              color: const Color(0xFFE53935),
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 10),
              child: Row(children: [
                const Icon(Icons.warning_amber_rounded,
                    color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(
                  '${crises.length} ACTIVE EMERGENCY'
                  '${crises.length > 1 ? 'IES' : ''}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      letterSpacing: 0.5),
                ),
              ]),
            ),

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: crises.length,
                itemBuilder: (context, i) =>
                    CrisisCard(crisis: crises[i]),
              ),
            ),
          ]);
        },
      ),
    );
  }
}
