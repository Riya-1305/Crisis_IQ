import 'package:flutter/material.dart';
import '../services/crisis_service.dart';
import '../services/gemini_service.dart';
import 'staff_login_screen.dart';

class GuestSOSScreen extends StatefulWidget {
  const GuestSOSScreen({super.key});

  @override
  State<GuestSOSScreen> createState() => _GuestSOSScreenState();
}

class _GuestSOSScreenState extends State<GuestSOSScreen> {
  final _crisisService = CrisisService();
  final _geminiService = GeminiService();
  final _roomController = TextEditingController();
  String _selectedType = 'fire';
  bool _isSending = false;
  bool _sent = false;
  String _sentRoom = '';

  final _types = [
    {'value': 'fire', 'label': '🔥  Fire'},
    {'value': 'medical', 'label': '🚑  Medical Emergency'},
    {'value': 'security', 'label': '🚨  Security Threat'},
    {'value': 'other', 'label': '⚠️  Other Emergency'},
  ];

  Future<void> _triggerSOS() async {
    final room = _roomController.text.trim();
    if (room.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your room number'),
          backgroundColor: Color(0xFFE53935),
        ),
      );
      return;
    }

    setState(() => _isSending = true);

    try {
      // 1. Write SOS to Firebase
      final crisisId = await _crisisService.triggerSOS(
        type: _selectedType,
        room: room,
      );

      // 2. Call Gemini directly from Flutter — no Cloud Functions needed
      final floor = room.isNotEmpty ? int.tryParse(room[0]) ?? 0 : 0;
      _geminiService.generateAndSaveBrief(
        crisisId: crisisId,
        type: _selectedType,
        floor: floor,
        room: room,
      );
      // Note: fire-and-forget — don't await so SOS confirmation
      // shows instantly. Brief writes back to Firebase in background.

      setState(() {
        _isSending = false;
        _sent = true;
        _sentRoom = room;
      });
    } catch (e) {
      setState(() => _isSending = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sending SOS: $e'),
            backgroundColor: const Color(0xFFE53935),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _roomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_sent) return _buildConfirmation();
    return _buildSOSForm();
  }

  Widget _buildSOSForm() {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFFE53935),
        title: const Row(
          children: [
            Icon(Icons.emergency_share_rounded,
                color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text('CrisisIQ',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const StaffLoginScreen()),
            ),
            child: const Text('Staff Login',
                style: TextStyle(color: Colors.white70, fontSize: 12)),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // Hotel card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color:
                            const Color(0xFFE53935).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.hotel,
                          color: Color(0xFFE53935), size: 26),
                    ),
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Grand Hospitality Hotel',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15)),
                        Text('Emergency Response System',
                            style:
                                TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Crisis type label
              const Text('What is happening?',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87)),
              const SizedBox(height: 8),

              // Dropdown
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedType,
                    isExpanded: true,
                    items: _types
                        .map((t) => DropdownMenuItem(
                              value: t['value'],
                              child: Text(t['label']!,
                                  style: const TextStyle(fontSize: 15)),
                            ))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _selectedType = v ?? 'fire'),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Room number label
              const Text('Your room number',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87)),
              const SizedBox(height: 8),

              // Room input
              TextField(
                controller: _roomController,
                keyboardType: TextInputType.number,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  hintText: 'e.g. 305',
                  prefixIcon:
                      const Icon(Icons.room, color: Color(0xFFE53935)),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[200]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[200]!),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    borderSide:
                        BorderSide(color: Color(0xFFE53935), width: 2),
                  ),
                ),
              ),

              const Spacer(),

              // SOS Button
              GestureDetector(
                onTap: _isSending ? null : _triggerSOS,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: double.infinity,
                  height: 72,
                  decoration: BoxDecoration(
                    color: _isSending
                        ? Colors.grey[400]
                        : const Color(0xFFE53935),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: _isSending
                        ? []
                        : [
                            BoxShadow(
                              color: const Color(0xFFE53935)
                                  .withValues(alpha: 0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                  ),
                  child: Center(
                    child: _isSending
                        ? const CircularProgressIndicator(
                            color: Colors.white)
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.emergency_share_rounded,
                                  color: Colors.white, size: 28),
                              SizedBox(width: 12),
                              Text('SEND SOS',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2,
                                  )),
                            ],
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 14),
              Center(
                child: Text(
                  'Pressing SOS immediately alerts all hotel staff.',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConfirmation() {
    return Scaffold(
      backgroundColor: const Color(0xFF1B5E20),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle_outline,
                    color: Colors.white, size: 100),
                const SizedBox(height: 24),
                const Text('Help is on the way',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Text(
                  'Staff have been alerted to Room $_sentRoom',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 15),
                ),
                const SizedBox(height: 8),
                Text(
                  'Type: ${_selectedType.toUpperCase()}',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.65),
                      fontSize: 13),
                ),
                const SizedBox(height: 56),
                const Text(
                  'Stay calm.\nDo not leave your room unless\ninstructed by hotel staff.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white70, fontSize: 14, height: 1.6),
                ),
                const SizedBox(height: 48),
                TextButton(
                  onPressed: () => setState(() {
                    _sent = false;
                    _roomController.clear();
                  }),
                  child: const Text('Send another alert',
                      style: TextStyle(color: Colors.white54)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
