import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../data/models/booking_models.dart';
import 'appointment_widgets.dart';

enum SlotPeriod { all, morning, afternoon, evening }

class SlotPicker extends StatelessWidget {
  const SlotPicker({
    required this.slots,
    required this.selectedSlot,
    required this.selectedPeriod,
    required this.visibleSlotCount,
    required this.onPeriodChanged,
    required this.onShowMore,
    required this.onSlotSelected,
    super.key,
  });

  final List<AppointmentSlotOption> slots;
  final AppointmentSlotOption? selectedSlot;
  final SlotPeriod selectedPeriod;
  final int visibleSlotCount;
  final ValueChanged<SlotPeriod> onPeriodChanged;
  final VoidCallback onShowMore;
  final ValueChanged<AppointmentSlotOption> onSlotSelected;

  @override
  Widget build(BuildContext context) {
    final filteredSlots =
        slots.where((slot) => _matchesPeriod(slot, selectedPeriod)).toList()
          ..sort((a, b) {
            final timeCompare = a.startsAt.compareTo(b.startsAt);
            if (timeCompare != 0) return timeCompare;
            return (a.practitionerNumber ?? '').compareTo(
              b.practitionerNumber ?? '',
            );
          });
    final visibleSlots = filteredSlots.take(visibleSlotCount).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (selectedSlot != null) ...[
          _SelectedSlotSummary(slot: selectedSlot!),
          const SizedBox(height: AppSizes.md),
        ],
        Wrap(
          spacing: AppSizes.sm,
          runSpacing: AppSizes.sm,
          children: SlotPeriod.values
              .map(
                (period) => ChoiceChip(
                  label: Text(_periodLabel(period)),
                  selected: selectedPeriod == period,
                  onSelected: (_) => onPeriodChanged(period),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: AppSizes.md),
        Text(
          'Showing ${visibleSlots.length} of ${filteredSlots.length} available slots',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSizes.sm),
        if (visibleSlots.isEmpty)
          const AppCard(child: Text('No slots in this time range.'))
        else
          ...visibleSlots.map(
            (slot) => Padding(
              padding: const EdgeInsets.only(bottom: AppSizes.sm),
              child: SlotCard(
                slot: slot,
                isSelected: selectedSlot?.id == slot.id,
                onTap: () => onSlotSelected(slot),
              ),
            ),
          ),
        if (filteredSlots.length > visibleSlots.length)
          OutlinedButton.icon(
            onPressed: onShowMore,
            icon: const Icon(Icons.expand_more),
            label: const Text('Show more slots'),
          ),
      ],
    );
  }

  bool _matchesPeriod(AppointmentSlotOption slot, SlotPeriod period) {
    final hour = slot.startsAt.hour;
    return switch (period) {
      SlotPeriod.all => true,
      SlotPeriod.morning => hour < 12,
      SlotPeriod.afternoon => hour >= 12 && hour < 17,
      SlotPeriod.evening => hour >= 17,
    };
  }

  String _periodLabel(SlotPeriod period) {
    return switch (period) {
      SlotPeriod.all => 'All',
      SlotPeriod.morning => 'Morning',
      SlotPeriod.afternoon => 'Afternoon',
      SlotPeriod.evening => 'Evening',
    };
  }
}

class _SelectedSlotSummary extends StatelessWidget {
  const _SelectedSlotSummary({required this.slot});

  final AppointmentSlotOption slot;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: AppSizes.md,
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.softCyan,
              borderRadius: BorderRadius.circular(AppSizes.radius),
            ),
            child: const Icon(
              Icons.event_available,
              color: AppColors.primaryTeal,
            ),
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Selected slot',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSizes.xs),
                Text(
                  '${DateFormatter.readableDate(slot.startsAt)} • '
                  '${_time(slot.startsAt)} - ${_time(slot.endsAt)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.darkNavy,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _time(DateTime value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
