import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_status_badge.dart';
import '../../data/models/appointment_models.dart';
import '../../data/models/booking_models.dart';

class AppointmentCard extends StatelessWidget {
  const AppointmentCard({required this.appointment, super.key});

  final Appointment appointment;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(appointment.specialtyName ?? 'Appointment'),
        subtitle: Text(
          '${appointment.facilityName ?? 'Facility'}\n'
          '${DateFormatter.readableDateTime(appointment.scheduledStart)}',
        ),
        isThreeLine: true,
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.go('/appointments/${appointment.id}'),
      ),
    );
  }
}

class AppointmentStatusBadge extends StatelessWidget {
  const AppointmentStatusBadge({required this.status, super.key});

  final String status;

  @override
  Widget build(BuildContext context) {
    return AppStatusBadge(label: _label(status), color: _color(status));
  }

  String _label(String value) {
    return value
        .split('_')
        .map(
          (part) => part.isEmpty
              ? part
              : '${part[0].toUpperCase()}${part.substring(1)}',
        )
        .join(' ');
  }

  Color _color(String value) {
    return switch (value) {
      AppointmentStatus.confirmed ||
      AppointmentStatus.checkedIn ||
      AppointmentStatus.queued ||
      AppointmentStatus.inService => AppColors.primaryTeal,
      AppointmentStatus.completed => AppColors.success,
      AppointmentStatus.cancelled ||
      AppointmentStatus.noShow => AppColors.danger,
      AppointmentStatus.rescheduled => AppColors.warning,
      _ => AppColors.info,
    };
  }
}

class SlotCard extends StatelessWidget {
  const SlotCard({
    required this.slot,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  final AppointmentSlotOption slot;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isSelected ? AppColors.softCyan : AppColors.card,
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          Icons.schedule,
          color: isSelected ? AppColors.primaryTeal : AppColors.textSecondary,
        ),
        title: Text(
          '${_time(slot.startsAt)} - ${_time(slot.endsAt)}',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          slot.practitionerNumber == null
              ? 'Doctor assigned by schedule'
              : 'Doctor ${slot.practitionerNumber}',
        ),
        trailing: Text('${slot.capacity - slot.bookedCount} left'),
      ),
    );
  }

  String _time(DateTime value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class BookingSectionTitle extends StatelessWidget {
  const BookingSectionTitle(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.lg, bottom: AppSizes.sm),
      child: Text(title, style: Theme.of(context).textTheme.titleLarge),
    );
  }
}
