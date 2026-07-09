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

  List<Event> _applyFilters(List<Event> events) {
    return events.where((e) {
      // This Weekend: event window overlaps [today, today+2 days]
      if (_thisWeekendActive) {
        final today = DateTime.now();
        final weekend = today.add(const Duration(days: 2));
        if (e.endDate.isBefore(today) || e.startDate.isAfter(weekend)) {
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('GTA Activities'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
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
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final filtered = _applyFilters(snapshot.data ?? []);
                if (filtered.isEmpty) {
                  return const Center(
                    child: Text(
                      'No events match your filters.\nTry widening your selection.',
                      textAlign: TextAlign.center,
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
