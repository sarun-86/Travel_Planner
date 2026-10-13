import 'package:flutter/material.dart';

import '../models/event.dart';
import '../screens/event_detail_screen.dart';
import '../utils/formatters.dart';

class EventCard extends StatelessWidget {
  const EventCard({super.key, required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EventDetailScreen(event: event),
          ),
        ),
        child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Emoji + event name
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(eventEmoji(event.name), style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    event.name,
                    style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Date range
            Row(
              children: [
                Icon(Icons.calendar_today_outlined, size: 14, color: colors.onSurfaceVariant),
                const SizedBox(width: 4),
                Text(
                  formatDateRange(event.startDate, event.endDate),
                  style: textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
                ),
                if (event.isRecurring) ...[
                  const SizedBox(width: 6),
                  Icon(Icons.repeat, size: 14, color: colors.onSurfaceVariant),
                ],
              ],
            ),
            const SizedBox(height: 12),

            // Pills row: region + cost + audience tags
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _RegionPill(label: regionLabel(event.region), colors: colors),
                _CostPill(label: costLabel(event.costTier), colors: colors),
                for (final tag in event.audience)
                  _AudiencePill(label: audienceLabel(tag), colors: colors),
              ],
            ),
          ],
        ),
      ),
      ),
    );
  }
}

class _RegionPill extends StatelessWidget {
  const _RegionPill({required this.label, required this.colors});
  final String label;
  final ColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return _Pill(
      label: label,
      background: colors.primaryContainer,
      foreground: colors.onPrimaryContainer,
    );
  }
}

class _CostPill extends StatelessWidget {
  const _CostPill({required this.label, required this.colors});
  final String label;
  final ColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return _Pill(
      label: label,
      background: colors.secondaryContainer,
      foreground: colors.onSecondaryContainer,
    );
  }
}

class _AudiencePill extends StatelessWidget {
  const _AudiencePill({required this.label, required this.colors});
  final String label;
  final ColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return _Pill(
      label: label,
      background: colors.tertiaryContainer,
      foreground: colors.onTertiaryContainer,
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.background,
    required this.foreground,
  });
  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: foreground),
      ),
    );
  }
}
