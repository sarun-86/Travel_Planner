import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/event.dart';
import '../utils/formatters.dart';

class EventDetailScreen extends StatelessWidget {
  const EventDetailScreen({super.key, required this.event});

  final Event event;

  Future<void> _launchUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open link')),
        );
      }
    }
  }

  void _openSource(BuildContext context) {
    if (event.sourceUrl.isNotEmpty) {
      _launchUrl(context, event.sourceUrl);
    }
  }

  void _openMaps(BuildContext context) {
    final query = Uri.encodeComponent(event.name);
    _launchUrl(context, 'https://www.google.com/maps/search/?api=1&query=$query');
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colors.primaryContainer,
        title: const Text('Event Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event name
            Text(
              event.name,
              style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 20),

            // Date + recurrence
            _DetailRow(
              icon: Icons.calendar_today_outlined,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    formatDateRange(event.startDate, event.endDate),
                    style: textTheme.bodyLarge,
                  ),
                  if (event.isRecurring && event.recurrenceNote.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        event.recurrenceNote,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Region
            _DetailRow(
              icon: Icons.location_on_outlined,
              child: Text(regionLabel(event.region), style: textTheme.bodyLarge),
            ),
            const SizedBox(height: 14),

            // Cost
            _DetailRow(
              icon: Icons.attach_money,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(costLabel(event.costTier), style: textTheme.bodyLarge),
                  if (event.costNote.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        event.costNote,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Audience tags
            _DetailRow(
              icon: Icons.people_outline,
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: event.audience
                    .map((tag) => _AudienceChip(label: audienceLabel(tag)))
                    .toList(),
              ),
            ),
            const SizedBox(height: 24),

            // Description
            Text(event.description, style: textTheme.bodyLarge?.copyWith(height: 1.5)),
            const SizedBox(height: 32),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: event.sourceUrl.isNotEmpty
                        ? () => _openSource(context)
                        : null,
                    icon: const Icon(Icons.open_in_new, size: 18),
                    label: const Text('View Source'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _openMaps(context),
                    icon: const Icon(Icons.map_outlined, size: 18),
                    label: const Text('Open in Maps'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.icon, required this.child});
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.onSurfaceVariant),
        const SizedBox(width: 12),
        Expanded(child: child),
      ],
    );
  }
}

class _AudienceChip extends StatelessWidget {
  const _AudienceChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: colors.tertiaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: colors.onTertiaryContainer,
        ),
      ),
    );
  }
}
