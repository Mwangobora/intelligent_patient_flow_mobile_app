import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/app_providers.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_error_state.dart';
import '../../../../shared/widgets/app_password_field.dart';
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
      ref.read(profileControllerProvider.notifier).loadCurrentPatientProfile();
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
        showBottomNavigation: true,
        body: AppErrorState(
          message: 'Please sign in again to view your profile.',
        ),
      );
    }

    return AppScaffold(
      title: 'Profile',
      showBottomNavigation: true,
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
          _PatientProfileCard(
            profile: profileState.patientProfile,
            isLoading: profileState.isLoading,
            errorMessage: profileState.errorMessage,
            onSave: (email, phoneNumber) async {
              final saved = await ref
                  .read(profileControllerProvider.notifier)
                  .updateCurrentPatientProfile(
                    email: email,
                    phoneNumber: phoneNumber,
                  );
              if (saved) {
                await ref
                    .read(authControllerProvider.notifier)
                    .checkSession(force: true);
              }
              return saved;
            },
          ),
          const SizedBox(height: AppSizes.lg),
          _PasswordCard(
            isSaving: authState.isLoading,
            errorMessage: authState.errorMessage,
            onSave: (oldPassword, newPassword) => ref
                .read(authControllerProvider.notifier)
                .changePassword(
                  oldPassword: oldPassword,
                  newPassword: newPassword,
                ),
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

class _PatientProfileCard extends StatefulWidget {
  const _PatientProfileCard({
    required this.profile,
    required this.isLoading,
    required this.onSave,
    this.errorMessage,
  });

  final PatientProfile? profile;
  final bool isLoading;
  final String? errorMessage;
  final Future<bool> Function(String? email, String? phoneNumber) onSave;

  @override
  State<_PatientProfileCard> createState() => _PatientProfileCardState();
}

class _PatientProfileCardState extends State<_PatientProfileCard> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _emailController.text = widget.profile?.email ?? '';
    _phoneController.text = widget.profile?.phoneNumber ?? '';
  }

  @override
  void didUpdateWidget(covariant _PatientProfileCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profile?.id != widget.profile?.id || !_isEditing) {
      _emailController.text = widget.profile?.email ?? '';
      _phoneController.text = widget.profile?.phoneNumber ?? '';
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

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
          if (widget.isLoading)
            const Center(child: CircularProgressIndicator())
          else if (widget.errorMessage != null)
            Text(
              widget.errorMessage!,
              style: const TextStyle(color: AppColors.warning),
            )
          else if (widget.profile == null)
            const Text('No patient profile is linked to this account yet.')
          else if (_isEditing)
            _buildContactForm()
          else
            _PatientProfileTile(
              widget.profile!,
              onEdit: () => setState(() => _isEditing = true),
            ),
        ],
      ),
    );
  }

  Widget _buildContactForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            label: 'Email',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            validator: Validators.email,
          ),
          const SizedBox(height: AppSizes.md),
          AppTextField(
            label: 'Phone',
            hintText: '075...',
            controller: _phoneController,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: AppSizes.lg),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.isLoading
                      ? null
                      : () => setState(() => _isEditing = false),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: AppButton(
                  label: 'Save',
                  isLoading: widget.isLoading,
                  onPressed: _save,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final saved = await widget.onSave(
      _emptyToNull(_emailController.text),
      _emptyToNull(_phoneController.text),
    );
    if (saved && mounted) setState(() => _isEditing = false);
  }

  String? _emptyToNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}

class _PatientProfileTile extends StatelessWidget {
  const _PatientProfileTile(this.profile, {required this.onEdit});

  final PatientProfile profile;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.badge_outlined),
      title: Text(profile.fullName),
      subtitle: Text(
        [
          profile.patientNumber.isEmpty
              ? 'Patient number unavailable'
              : profile.patientNumber,
          profile.registeredFacilityName,
          profile.phoneNumber,
        ].whereType<String>().where((value) => value.isNotEmpty).join(' • '),
      ),
      trailing: AppStatusBadge(
        label: profile.isActive ? 'Active' : 'Inactive',
        color: profile.isActive ? AppColors.success : AppColors.danger,
      ),
      onTap: onEdit,
    );
  }
}

class _PasswordCard extends StatefulWidget {
  const _PasswordCard({
    required this.isSaving,
    required this.onSave,
    this.errorMessage,
  });

  final bool isSaving;
  final String? errorMessage;
  final Future<bool> Function(String oldPassword, String newPassword) onSave;

  @override
  State<_PasswordCard> createState() => _PasswordCardState();
}

class _PasswordCardState extends State<_PasswordCard> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isEditing = false;
  bool _saved = false;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: _isEditing ? _buildForm(context) : _buildSummary(context),
    );
  }

  Widget _buildSummary(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.lock_outline, color: AppColors.primaryTeal),
            const SizedBox(width: AppSizes.sm),
            Expanded(
              child: Text(
                'Password',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            TextButton(
              onPressed: () => setState(() => _isEditing = true),
              child: const Text('Change'),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.sm),
        Text(
          _saved
              ? 'Your password was updated.'
              : 'Keep your patient account secure with a strong password.',
          style: TextStyle(color: _saved ? AppColors.success : null),
        ),
      ],
    );
  }

  Widget _buildForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Change password',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          if (widget.errorMessage != null) ...[
            const SizedBox(height: AppSizes.sm),
            Text(
              widget.errorMessage!,
              style: const TextStyle(color: AppColors.danger),
            ),
          ],
          const SizedBox(height: AppSizes.md),
          AppPasswordField(
            label: 'Current password',
            controller: _oldPasswordController,
            validator: (value) =>
                Validators.required(value, field: 'Current password'),
          ),
          const SizedBox(height: AppSizes.md),
          AppPasswordField(
            label: 'New password',
            controller: _newPasswordController,
            validator: (value) =>
                Validators.required(value, field: 'New password'),
          ),
          const SizedBox(height: AppSizes.md),
          AppPasswordField(
            label: 'Confirm new password',
            controller: _confirmPasswordController,
            validator: _validateConfirmPassword,
          ),
          const SizedBox(height: AppSizes.lg),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.isSaving ? null : _cancel,
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: AppButton(
                  label: 'Update',
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

  String? _validateConfirmPassword(String? value) {
    final required = Validators.required(value, field: 'Confirm password');
    if (required != null) return required;
    if (value != _newPasswordController.text) {
      return 'Passwords do not match.';
    }
    return null;
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final saved = await widget.onSave(
      _oldPasswordController.text,
      _newPasswordController.text,
    );
    if (!saved || !mounted) return;
    _oldPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();
    setState(() {
      _isEditing = false;
      _saved = true;
    });
  }

  void _cancel() {
    _oldPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();
    setState(() => _isEditing = false);
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
