import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app_providers.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_error_state.dart';
import '../../../../shared/widgets/app_loading_state.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../data/models/booking_models.dart';
import '../widgets/appointment_widgets.dart';
import '../widgets/slot_picker.dart';

class AppointmentNewScreen extends ConsumerStatefulWidget {
  const AppointmentNewScreen({this.rescheduleAppointmentId, super.key});

  final String? rescheduleAppointmentId;

  bool get isReschedule => rescheduleAppointmentId != null;

  @override
  ConsumerState<AppointmentNewScreen> createState() =>
      _AppointmentNewScreenState();
}

class _AppointmentNewScreenState extends ConsumerState<AppointmentNewScreen> {
  static const _slotPageSize = 8;

  final _reasonController = TextEditingController();
  bool _initialized = false;
  SlotPeriod _slotPeriod = SlotPeriod.all;
  int _visibleSlotCount = _slotPageSize;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final user = ref.read(authControllerProvider).user;
      if (user != null &&
          ref.read(profileControllerProvider).patientProfiles.isEmpty) {
        await ref
            .read(profileControllerProvider.notifier)
            .loadLinkedPatientProfiles(user.id);
      }
      if (widget.isReschedule) {
        final id = widget.rescheduleAppointmentId!;
        await ref
            .read(appointmentDetailControllerProvider.notifier)
            .loadAppointment(id);
        final appointment = ref
            .read(appointmentDetailControllerProvider)
            .appointment;
        if (appointment != null) {
          await ref
              .read(bookingControllerProvider.notifier)
              .prepareReschedule(appointment);
        }
      } else {
        await _loadFacilitiesForCurrentPatient();
      }
      _initialized = true;
    });
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileControllerProvider);
    final bookingState = ref.watch(bookingControllerProvider);
    final detailState = ref.watch(appointmentDetailControllerProvider);
    final patient = profileState.patientProfiles.isEmpty
        ? null
        : profileState.patientProfiles.first;
    final sourceAppointment = detailState.appointment;

    return AppScaffold(
      title: widget.isReschedule ? 'Reschedule' : 'Book Appointment',
      showBottomNavigation: true,
      body: profileState.isLoading
          ? const AppLoadingState(message: 'Loading patient profile...')
          : patient == null
          ? const AppErrorState(
              message:
                  'A linked patient profile is required to book appointments.',
            )
          : widget.isReschedule && sourceAppointment == null && !_initialized
          ? const AppLoadingState(message: 'Loading appointment...')
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (bookingState.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSizes.md),
                    child: Text(
                      bookingState.errorMessage!,
                      style: const TextStyle(color: AppColors.danger),
                    ),
                  ),
                if (!widget.isReschedule) ...[
                  const BookingSectionTitle('1. Select facility'),
                  _FacilitySelector(
                    facilities: bookingState.facilities,
                    onChanged: _resetSlotPicker,
                  ),
                ] else if (sourceAppointment != null) ...[
                  AppCard(
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        sourceAppointment.facilityName ?? 'Current facility',
                      ),
                      subtitle: Text(
                        sourceAppointment.specialtyName ?? 'Current service',
                      ),
                    ),
                  ),
                ],
                const BookingSectionTitle('2. Select service'),
                widget.isReschedule
                    ? _LockedValue(
                        value:
                            sourceAppointment?.specialtyName ??
                            'Current service',
                      )
                    : _SpecialtySelector(
                        specialties: bookingState.specialties,
                        onChanged: _resetSlotPicker,
                      ),
                const BookingSectionTitle('3. Select date'),
                OutlinedButton.icon(
                  icon: const Icon(Icons.calendar_month_outlined),
                  label: Text(
                    bookingState.selectedDate == null
                        ? 'Choose appointment date'
                        : DateFormatter.readableDate(
                            bookingState.selectedDate!,
                          ),
                  ),
                  onPressed: () async {
                    final now = DateTime.now();
                    final picked = await showDatePicker(
                      context: context,
                      firstDate: now,
                      lastDate: now.add(const Duration(days: 180)),
                      initialDate: bookingState.selectedDate ?? now,
                    );
                    if (picked != null) {
                      _resetSlotPicker();
                      await ref
                          .read(bookingControllerProvider.notifier)
                          .selectDate(picked);
                    }
                  },
                ),
                const BookingSectionTitle('4. Select available slot'),
                if (bookingState.isLoading)
                  const AppLoadingState(message: 'Loading slots...')
                else if (bookingState.slots.isEmpty)
                  const AppCard(
                    child: Text('No available slots for the selected date.'),
                  )
                else
                  SlotPicker(
                    slots: bookingState.slots,
                    selectedSlot: bookingState.selectedSlot,
                    selectedPeriod: _slotPeriod,
                    visibleSlotCount: _visibleSlotCount,
                    onPeriodChanged: (period) {
                      setState(() {
                        _slotPeriod = period;
                        _visibleSlotCount = _slotPageSize;
                      });
                    },
                    onShowMore: () {
                      setState(() {
                        _visibleSlotCount += _slotPageSize;
                      });
                    },
                    onSlotSelected: (slot) => ref
                        .read(bookingControllerProvider.notifier)
                        .selectSlot(slot),
                  ),
                const BookingSectionTitle('5. Confirm'),
                AppTextField(
                  label: 'Reason for visit (optional)',
                  controller: _reasonController,
                ),
                const SizedBox(height: AppSizes.lg),
                AppButton(
                  label: widget.isReschedule
                      ? 'Confirm Reschedule'
                      : 'Confirm Appointment',
                  isLoading: bookingState.isSubmitting,
                  onPressed: () => _submit(patient.id),
                ),
              ],
            ),
    );
  }

  Future<void> _loadFacilitiesForCurrentPatient() async {
    final profileState = ref.read(profileControllerProvider);
    final patient = profileState.patientProfiles.isEmpty
        ? null
        : profileState.patientProfiles.first;
    await ref
        .read(bookingControllerProvider.notifier)
        .loadFacilities(organizationId: patient?.organizationId);
  }

  void _resetSlotPicker() {
    setState(() {
      _slotPeriod = SlotPeriod.all;
      _visibleSlotCount = _slotPageSize;
    });
  }

  Future<void> _submit(String patientId) async {
    final controller = ref.read(bookingControllerProvider.notifier);
    final appointment = widget.isReschedule
        ? await controller.submitReschedule(
            appointmentId: widget.rescheduleAppointmentId!,
            reasonForVisit: _reasonController.text,
          )
        : await controller.submitBooking(
            patientId: patientId,
            reasonForVisit: _reasonController.text,
          );
    if (appointment == null || !mounted) return;
    await ref
        .read(appointmentsControllerProvider.notifier)
        .loadAppointments(patientId);
    if (!mounted) return;
    context.go('/appointments/${appointment.id}');
  }
}

class _FacilitySelector extends ConsumerWidget {
  const _FacilitySelector({required this.facilities, required this.onChanged});

  final List<FacilityOption> facilities;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(bookingControllerProvider).selectedFacility;
    if (facilities.isEmpty) {
      return const AppCard(child: Text('No active facilities are available.'));
    }
    return DropdownButtonFormField<String>(
      initialValue: selected?.id,
      decoration: const InputDecoration(labelText: 'Facility'),
      items: facilities
          .map(
            (facility) => DropdownMenuItem(
              value: facility.id,
              child: Text(facility.name),
            ),
          )
          .toList(),
      onChanged: (id) {
        final facility = facilities.firstWhere((item) => item.id == id);
        onChanged();
        ref.read(bookingControllerProvider.notifier).selectFacility(facility);
      },
    );
  }
}

class _SpecialtySelector extends ConsumerWidget {
  const _SpecialtySelector({
    required this.specialties,
    required this.onChanged,
  });

  final List<FacilitySpecialtyOption> specialties;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(bookingControllerProvider).selectedSpecialty;
    if (specialties.isEmpty) {
      return const AppCard(
        child: Text('Select a facility to load appointment services.'),
      );
    }
    return DropdownButtonFormField<String>(
      initialValue: selected?.id,
      decoration: const InputDecoration(labelText: 'Service'),
      items: specialties
          .map(
            (specialty) => DropdownMenuItem(
              value: specialty.id,
              child: Text(specialty.specialtyName),
            ),
          )
          .toList(),
      onChanged: (id) {
        final specialty = specialties.firstWhere((item) => item.id == id);
        onChanged();
        ref.read(bookingControllerProvider.notifier).selectSpecialty(specialty);
      },
    );
  }
}

class _LockedValue extends StatelessWidget {
  const _LockedValue({required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          const Icon(Icons.lock_outline, color: AppColors.textSecondary),
          const SizedBox(width: AppSizes.sm),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
