import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'models/event.dart';
import 'services/event_service.dart';
import 'widgets/event_card.dart';
import 'widgets/filter_bar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const GTAActivityApp());
}

class GTAActivityApp extends StatelessWidget {
  const GTAActivityApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GTA Activities',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFE07B39)),
        useMaterial3: true,
      ),
      home: const EventListScreen(),
    );
  }
}

class EventListScreen extends StatefulWidget {
  const EventListScreen({super.key});

  @override
  State<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  bool _thisWeekendActive = false;
  final Set<String> _selectedAudience = {};
  String? _selectedRegion;

  /// Returns a human-readable label for today, e.g. "Tuesday, Oct 14"
  String _todayLabel() {
    final now = DateTime.now();
    const weekdays = ['', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    const months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${weekdays[now.weekday]}, ${months[now.month]} ${now.day}';
  }

  /// Returns the [start, end] date range for "this weekend" based on today.
  ///
  /// Mon–Fri → coming Saturday + Sunday
  /// Saturday → today + tomorrow (Sun)
  /// Sunday  → today only
  (DateTime, DateTime) _getWeekendRange() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekday = today.weekday; // 1=Mon … 6=Sat, 7=Sun

    if (weekday == DateTime.saturday) {
      // Sat: show Sat + Sun
      return (today, today.add(const Duration(days: 1)));
    } else if (weekday == DateTime.sunday) {
      // Sun: show today only
      return (today, today);
    } else {
      // Mon–Fri: find coming Saturday
      final daysUntilSat = DateTime.saturday - weekday;
      final sat = today.add(Duration(days: daysUntilSat));
      return (sat, sat.add(const Duration(days: 1))); // Sat + Sun
    }
  }

  List<Event> _applyFilters(List<Event> events) {
    return events.where((e) {
      // This Weekend: event window must overlap the weekend date range
      if (_thisWeekendActive) {
        final (weekendStart, weekendEnd) = _getWeekendRange();
        // Normalize event dates to midnight for day-level comparison
        final eventEndDay = DateTime(e.endDate.year, e.endDate.month, e.endDate.day);
        final eventStartDay = DateTime(e.startDate.year, e.startDate.month, e.startDate.day);
        // Exclude if event ends before weekend starts OR starts after weekend ends
        if (eventEndDay.isBefore(weekendStart) || eventStartDay.isAfter(weekendEnd)) {
          return false;
        }
      }

      // Audience: event must share at least one tag with selection
      if (_selectedAudience.isNotEmpty &&
          !e.audience.any(_selectedAudience.contains)) {
        return false;
      }

      // Region: exact match
      if (_selectedRegion != null && e.region != _selectedRegion) {
        return false;
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 72,
        backgroundColor: colors.primaryContainer,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'GTA Activities',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
            ),
            Text(
              _todayLabel(),
              style: TextStyle(
                fontSize: 13,
                color: colors.onPrimaryContainer.withAlpha(180),
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          FilterBar(
            thisWeekendActive: _thisWeekendActive,
            selectedAudience: _selectedAudience,
            selectedRegion: _selectedRegion,
            onThisWeekendToggled: () =>
                setState(() => _thisWeekendActive = !_thisWeekendActive),
            onAudienceToggled: (tag) => setState(() {
              if (_selectedAudience.contains(tag)) {
                _selectedAudience.remove(tag);
              } else {
                _selectedAudience.add(tag);
              }
            }),
            onRegionChanged: (region) =>
                setState(() => _selectedRegion = region),
          ),
          Expanded(
            child: StreamBuilder<List<Event>>(
              stream: EventService().watchActiveEvents(),
              builder: (context, snapshot) {
                // Loading state
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: colors.primary),
                        const SizedBox(height: 16),
                        Text(
                          'Loading events…',
                          style: textTheme.bodyMedium?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Error state
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.wifi_off_rounded, size: 48,
                              color: colors.onSurfaceVariant),
                          const SizedBox(height: 16),
                          Text("Couldn't load events",
                              style: textTheme.titleMedium),
                          const SizedBox(height: 8),
                          Text(
                            'Check your connection and try again.',
                            textAlign: TextAlign.center,
                            style: textTheme.bodyMedium?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final filtered = _applyFilters(snapshot.data ?? []);

                // Empty state
                if (filtered.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.event_busy_rounded, size: 48,
                              color: colors.onSurfaceVariant),
                          const SizedBox(height: 16),
                          Text('Nothing here yet',
                              style: textTheme.titleMedium),
                          const SizedBox(height: 8),
                          Text(
                            'Try a different date range or widen your filters.',
                            textAlign: TextAlign.center,
                            style: textTheme.bodyMedium?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) =>
                      EventCard(event: filtered[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
