import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:firebase_database/firebase_database.dart';

class GeminiService {
  // API key injected via --dart-define at build time
  static const _apiKey = String.fromEnvironment('GEMINI_KEY');

  final GenerativeModel _model;

  GeminiService()
      : _model = GenerativeModel(
          model: 'gemini-1.5-flash',
          apiKey: _apiKey,
        );

  Future<void> generateAndSaveBrief({
    required String crisisId,
    required String type,
    required int floor,
    required String room,
  }) async {
    try {
      final prompt = '''A $type emergency has been reported at a hotel.
Location: Floor $floor, Room $room.

Write a 3-sentence emergency response brief for hotel staff.
Sentence 1: Clearly state what happened and exactly where.
Sentence 2: The single most important immediate action staff must take right now.
Sentence 3: The nearest exit route from Floor $floor and who to contact for backup.

Rules: Be calm, authoritative, and specific.
No bullet points. No markdown. No headers. Plain text only.
Maximum 60 words total.''';

      final response = await _model.generateContent(
        [Content.text(prompt)],
      );

      final brief = response.text?.trim() ??
          'Emergency confirmed. Follow standard protocol for '
              '$type on Floor $floor. Contact duty manager immediately.';

      await FirebaseDatabase.instance.ref('crises/$crisisId').update({
        'aiBrief': brief,
        'briefAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      // Fallback brief if Gemini fails — never leave staff without guidance
      final fallbacks = {
        'fire': 'Fire reported on Floor $floor, Room $room. '
            'Activate fire alarm and begin immediate floor evacuation. '
            'Direct all guests to nearest stairwell — do not use lifts.',
        'medical': 'Medical emergency on Floor $floor, Room $room. '
            'Call 112 immediately and dispatch first-aid trained staff. '
            'Keep guest calm, do not move them, meet ambulance at main entrance.',
        'security': 'Security threat on Floor $floor, Room $room. '
            'Alert security team immediately and lock down floor access. '
            'Call police at 100 and guide guests to safe assembly area.',
        'other': 'Emergency reported on Floor $floor, Room $room. '
            'Alert duty manager and send nearest available staff member. '
            'Follow standard emergency protocol and keep guests informed.',
      };

      final fallbackBrief = fallbacks[type] ?? fallbacks['other']!;

      await FirebaseDatabase.instance.ref('crises/$crisisId').update({
        'aiBrief': fallbackBrief,
        'briefAt': DateTime.now().millisecondsSinceEpoch,
      });
    }
  }
}
