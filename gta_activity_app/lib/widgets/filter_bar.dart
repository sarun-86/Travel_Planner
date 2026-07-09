import 'package:flutter/material.dart';

import '../utils/formatters.dart';

const _audienceTags = ['family', 'kids', 'couples', 'friends'];

const _regions = [
  'downtown_toronto',
  'west_gta',
  'east_gta',
  'north_gta',
  'niagara',
];

class FilterBar extends StatelessWidget {
  const FilterBar({
    super.key,
    required this.thisWeekendActive,
    required this.selectedAudience,
    required this.selectedRegion,
    required this.onThisWeekendToggled,
    required this.onAudienceToggled,
    required this.onRegionChanged,
  });

  final bool thisWeekendActive;
  final Set<String> selectedAudience;
  final String? selectedRegion;
  final VoidCallback onThisWeekendToggled;
  final void Function(String tag) onAudienceToggled;
  final void Function(String? region) onRegionChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      color: colors.surface,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: This Weekend button + Region dropdown
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
            child: Row(
              children: [
                _ThisWeekendButton(
                  active: thisWeekendActive,
                  onTap: onThisWeekendToggled,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _RegionDropdown(
                    selected: selectedRegion,
                    onChanged: onRegionChanged,
                  ),
                ),
              ],
            ),
          ),

          // Row 2: Audience chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
            child: Row(
              children: _audienceTags.map((tag) {
                final active = selectedAudience.contains(tag);
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(audienceLabel(tag)),
                    selected: active,
                    onSelected: (_) => onAudienceToggled(tag),
                    selectedColor: colors.primaryContainer,
                    checkmarkColor: colors.onPrimaryContainer,
                    labelStyle: TextStyle(
                      fontSize: 13,
                      color: active ? colors.onPrimaryContainer : colors.onSurface,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          Divider(height: 1, color: colors.outlineVariant),
        ],
      ),
    );
  }
}

class _ThisWeekendButton extends StatelessWidget {
  const _ThisWeekendButton({required this.active, required this.onTap});
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? colors.primary : colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          'This Weekend',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: active ? colors.onPrimary : colors.onSurface,
          ),
        ),
      ),
    );
  }
}

class _RegionDropdown extends StatelessWidget {
  const _RegionDropdown({required this.selected, required this.onChanged});
  final String? selected;
  final void Function(String?) onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: selected,
          hint: const Text('All regions', style: TextStyle(fontSize: 13)),
          isExpanded: true,
          style: TextStyle(fontSize: 13, color: colors.onSurface),
          icon: const Icon(Icons.expand_more, size: 18),
          borderRadius: BorderRadius.circular(12),
          items: [
            const DropdownMenuItem<String?>(
              value: null,
              child: Text('All regions'),
            ),
            ..._regions.map((r) => DropdownMenuItem<String?>(
                  value: r,
                  child: Text(regionLabel(r)),
                )),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}
