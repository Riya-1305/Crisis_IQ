# CrisisIQ — AI Hospitality Emergency Response
> Google Solution Challenge 2026 | Rapid Crisis Response

## The problem
Hotel emergencies lose lives to delayed, fragmented communication.
Staff find out via WhatsApp. First responders arrive without context.

## Our solution
Guest presses SOS → Firebase alerts all staff in under 2 seconds
→ Gemini AI generates a 3-sentence response brief automatically
→ Staff see what happened, what to do, and which exit to use.

**Response time: 8 minutes → under 90 seconds.**

## Tech stack
| Layer | Technology |
|---|---|
| Mobile + Web | Flutter |
| Real-time alerts | Firebase Realtime Database |
| AI brief | Gemini 1.5 Flash |
| Auth | Firebase Auth |
| Deployment | Firebase Hosting |

## SDG alignment
- SDG 3: Good Health & Well-Being
- SDG 11: Safe, Resilient Cities

## Run locally
flutter pub get
flutter run --dart-define=GEMINI_KEY=your_key

## Live demo
https://crisisiq-7b8aa.web.app/

