import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/app_providers.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_error_state.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/app_status_badge.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../auth/data/models/auth_user.dart';
import '../../data/models/patient_profile.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authControllerProvider).user;
      if (user != null) {
        ref
            .read(profileControllerProvider.notifier)
            .loadLinkedPatientProfiles(user.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final profileState = ref.watch(profileControllerProvider);
    final user = authState.user;

    if (user == null) {
      return const AppScaffold(
        title: 'Profile',
        body: AppErrorState(
          message: 'Please sign in again to view your profile.',
        ),
      );
    }

    return AppScaffold(
      title: 'Profile',
      actions: [
        IconButton(
          tooltip: 'Logout',
          onPressed: authState.isLoading
              ? null
              : () => ref.read(authControllerProvider.notifier).logout(),
          icon: const Icon(Icons.logout),
        ),
      ],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _UserProfileCard(
            user: user,
            isEditing: _isEditing,
            isSaving: authState.isLoading,
            errorMessage: authState.errorMessage,
            onEditChanged: (value) => setState(() => _isEditing = value),
            onSave: (firstName, middleName, lastName) async {
              final saved = await ref
                  .read(authControllerProvider.notifier)
                  .updateProfile(
                    firstName: firstName,
                    middleName: middleName,
                    lastName: lastName,
                  );
              if (saved && mounted) setState(() => _isEditing = false);
            },
          ),
          const SizedBox(height: AppSizes.lg),
          _MembershipsCard(memberships: user.memberships),
          const SizedBox(height: AppSizes.lg),
          _PatientProfilesCard(
            profiles: profileState.patientProfiles,
            isLoading: profileState.isLoading,
            errorMessage: profileState.errorMessage,
          ),
        ],
      ),
    );
  }
}

class _UserProfileCard extends StatefulWidget {
  const _UserProfileCard({
    required this.user,
    required this.isEditing,
    required this.isSaving,
    required this.onEditChanged,
    required this.onSave,
    this.errorMessage,
  });

  final AuthUser user;
  final bool isEditing;
  final bool isSaving;
  final String? errorMessage;
  final ValueChanged<bool> onEditChanged;
  final Future<void> Function(String, String?, String) onSave;

  @override
  State<_UserProfileCard> createState() => _UserProfileCardState();
}

class _UserProfileCardState extends State<_UserProfileCard> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstNameController;
  late final TextEditingController _middleNameController;
  late final TextEditingController _lastNameController;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.user.firstName);
    _middleNameController = TextEditingController(
      text: widget.user.middleName ?? '',
    );
    _lastNameController = TextEditingController(text: widget.user.lastName);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await widget.onSave(
      _firstNameController.text.trim(),
      _middleNameController.text.trim().isEmpty
          ? null
          : _middleNameController.text.trim(),
      _lastNameController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: widget.isEditing
          ? _buildEditForm()
          : _buildProfileSummary(context),
    );
  }

  Widget _buildProfileSummary(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(
              backgroundColor: AppColors.softCyan,
              child: Icon(Icons.person_outline, color: AppColors.primaryTeal),
            ),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.user.fullName,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: AppSizes.sm,
                    runSpacing: AppSizes.sm,
                    children: [
                      AppStatusBadge(
                        label: widget.user.isActive ? 'Active' : 'Inactive',
                        color: widget.user.isActive
                            ? AppColors.success
                            : AppColors.danger,
                      ),
                      if (widget.user.hasGlobalAccess)
                        const AppStatusBadge(label: 'Global access'),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Edit profile',
              onPressed: () => widget.onEditChanged(true),
              icon: const Icon(Icons.edit_outlined),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.lg),
        _InfoRow(label: 'Email', value: widget.user.email ?? 'Not provided'),
        _InfoRow(
          label: 'Phone',
          value: widget.user.phoneNumber ?? 'Not provided',
        ),
      ],
    );
  }

  Widget _buildEditForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Edit profile', style: Theme.of(context).textTheme.titleLarge),
          if (widget.errorMessage != null) ...[
            const SizedBox(height: AppSizes.sm),
            Text(
              widget.errorMessage!,
              style: const TextStyle(color: AppColors.danger),
            ),
          ],
          const SizedBox(height: AppSizes.md),
          AppTextField(
            label: 'First name',
            controller: _firstNameController,
            validator: (value) =>
                Validators.required(value, field: 'First name'),
          ),
          const SizedBox(height: AppSizes.md),
          AppTextField(label: 'Middle name', controller: _middleNameController),
          const SizedBox(height: AppSizes.md),
          AppTextField(
            label: 'Last name',
            controller: _lastNameController,
            validator: (value) =>
                Validators.required(value, field: 'Last name'),
          ),
          const SizedBox(height: AppSizes.lg),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.isSaving
                      ? null
                      : () => widget.onEditChanged(false),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: AppButton(
                  label: 'Save',
                  isLoading: widget.isSaving,
                  onPressed: _save,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MembershipsCard extends StatelessWidget {
  const _MembershipsCard({required this.memberships});

  final List<AuthMembership> memberships;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hospital access',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSizes.md),
          if (memberships.isEmpty)
            const Text('No organization or facility membership is linked yet.')
          else
            ...memberships.map(
              (membership) => Padding(
                padding: const EdgeInsets.only(bottom: AppSizes.sm),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.local_hospital_outlined),
                  title: Text(membership.organizationName),
                  subtitle: Text(membership.facilityName ?? 'All facilities'),
                  trailing: AppStatusBadge(
                    label: membership.isActive ? 'Active' : 'Inactive',
                    color: membership.isActive
                        ? AppColors.success
                        : AppColors.danger,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PatientProfilesCard extends StatelessWidget {
  const _PatientProfilesCard({
    required this.profiles,
    required this.isLoading,
    this.errorMessage,
  });

  final List<PatientProfile> profiles;
  final bool isLoading;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Patient profile',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSizes.md),
          if (isLoading)
            const Center(child: CircularProgressIndicator())
          else if (errorMessage != null)
            Text(
              errorMessage!,
              style: const TextStyle(color: AppColors.warning),
            )
          else if (profiles.isEmpty)
            const Text(
              'No patient profile is linked to this account yet. A patient-safe profile endpoint is still needed for mobile self-service.',
            )
          else
            ...profiles.map(_PatientProfileTile.new),
        ],
      ),
    );
  }
}

class _PatientProfileTile extends StatelessWidget {
  const _PatientProfileTile(this.profile);

  final PatientProfile profile;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.badge_outlined),
      title: Text(profile.fullName),
      subtitle: Text(
        profile.patientNumber.isEmpty
            ? 'Patient number unavailable'
            : profile.patientNumber,
      ),
      trailing: AppStatusBadge(
        label: profile.isActive ? 'Active' : 'Inactive',
        color: profile.isActive ? AppColors.success : AppColors.danger,
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.sm),
      child: Row(
        children: [
          SizedBox(
            width: 88,
            child: Text(
              label,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
