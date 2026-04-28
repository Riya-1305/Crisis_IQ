import 'package:flutter/material.dart';
import '../models/crisis.dart';
import '../services/crisis_service.dart';
import 'ai_brief_box.dart';
import 'floor_map_painter.dart';

class CrisisCard extends StatefulWidget {
  final Crisis crisis;

  const CrisisCard({super.key, required this.crisis});

  @override
  State<CrisisCard> createState() => _CrisisCardState();
}

class _CrisisCardState extends State<CrisisCard> {
  final _crisisService = CrisisService();
  bool _showMap = false;
  bool _resolving = false;

  String get _icon {
    switch (widget.crisis.type) {
      case 'fire':
        return '🔥';
      case 'medical':
        return '🚑';
      case 'security':
        return '🚨';
      default:
        return '⚠️';
    }
  }

  Color get _color {
    switch (widget.crisis.type) {
      case 'fire':
        return const Color(0xFFE53935);
      case 'medical':
        return const Color(0xFF1565C0);
      case 'security':
        return const Color(0xFF6A1B9A);
      default:
        return const Color(0xFFE65100);
    }
  }

  String _elapsed(int ts) {
    final d =
        DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(ts));
    if (d.inSeconds < 60) return '${d.inSeconds}s ago';
    if (d.inMinutes < 60) return '${d.inMinutes}m ago';
    return '${d.inHours}h ago';
  }

  Future<void> _resolve() async {
    setState(() => _resolving = true);
    await _crisisService.resolveCrisis(widget.crisis.id);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _color.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
            color: _color.withValues(alpha: 0.07),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            decoration: BoxDecoration(
              color: _color.withValues(alpha: 0.07),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: Row(
              children: [
                Text(_icon, style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.crisis.type.toUpperCase(),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: _color,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        'Floor ${widget.crisis.floor}  ·  Room ${widget.crisis.room}',
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _color,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _elapsed(widget.crisis.timestamp),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),

          // Body
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Gemini brief or loading state
                widget.crisis.aiBrief != null &&
                        widget.crisis.aiBrief!.isNotEmpty
                    ? AIBriefBox(
                        brief: widget.crisis.aiBrief!,
                        generatedAt: widget.crisis.briefAt,
                      )
                    : Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Row(children: [
                          const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                                strokeWidth: 2),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Gemini AI generating response brief...',
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[600]),
                          ),
                        ]),
                      ),

                const SizedBox(height: 14),

                // Map toggle
                GestureDetector(
                  onTap: () => setState(() => _showMap = !_showMap),
                  child: Row(children: [
                    Icon(
                      _showMap ? Icons.expand_less : Icons.map_outlined,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _showMap ? 'Hide floor map' : 'Show floor map',
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ]),
                ),

                if (_showMap) ...[
                  const SizedBox(height: 10),
                  FloorMapWidget(
                    crisisRoom: widget.crisis.room,
                    crisisFloor: widget.crisis.floor,
                  ),
                ],

                const SizedBox(height: 16),

                // Resolve button
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton.icon(
                    onPressed: _resolving ? null : _resolve,
                    icon: _resolving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.check_circle_outline,
                            size: 18),
                    label: Text(
                        _resolving ? 'Resolving...' : 'Mark as Resolved'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
