import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/healthcare_models.dart';
import '../../services/user_service.dart';
import '../../widgets/app_widgets.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final _userService = UserService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users and roles'),
        foregroundColor: deepBlue,
      ),
      body: AppGradientBackground(
        child: SafeArea(
          child: _userService.isConfigured
              ? StreamBuilder<List<AppUser>>(
                  stream: _userService.watchUsers(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return const _UsersMessage(
                        icon: Icons.cloud_off_rounded,
                        message:
                            'Could not load users. Check your connection and try again.',
                      );
                    }

                    final users = snapshot.data ?? const <AppUser>[];
                    if (users.isEmpty) {
                      return const _UsersMessage(
                        icon: Icons.group_rounded,
                        message:
                            'No users yet. Register accounts from login or staff upload.',
                      );
                    }

                    return ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        SectionHeader(
                          title: 'All users (${users.length})',
                          subtitle:
                              'Edit role or delete. Doctors and pharmacists are removed from Staff too.',
                        ),
                        const SizedBox(height: 14),
                        for (final user in users)
                          _UserCard(
                            user: user,
                            onEditRole: () => _editRole(user),
                            onDelete: () => _deleteUser(user),
                          ),
                      ],
                    );
                  },
                )
              : const _UsersMessage(
                  icon: Icons.info_rounded,
                  message: 'User management is unavailable offline.',
                ),
        ),
      ),
    );
  }

  Future<void> _editRole(AppUser user) async {
    var selectedRole = user.role;
    final saved = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(20, 8, 20, bottomInset + 24),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: const TextStyle(
                        color: deepBlue,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      style: const TextStyle(color: Color(0xFF5B7280)),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Select role',
                      style: TextStyle(
                        color: deepBlue,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    for (final role in UserRole.values)
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        value: selectedRole == role,
                        onChanged: (_) {
                          setModalState(() => selectedRole = role);
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                        activeColor: primaryTeal,
                        secondary: Icon(role.icon, color: primaryTeal),
                        title: Text(
                          role.label,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Save role'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (saved != true || !mounted) return;

    try {
      await _userService.updateUserRole(uid: user.uid, role: selectedRole);
      if (!mounted) return;
      showSimulationSnack(
        context,
        '${user.name} is now ${selectedRole.label}.',
      );
    } catch (_) {
      if (!mounted) return;
      showSimulationSnack(
        context,
        'Could not update user role. Try again later.',
      );
    }
  }

  Future<void> _deleteUser(AppUser user) async {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    if (currentUid != null && user.uid == currentUid) {
      showSimulationSnack(context, 'You cannot delete your own account.');
      return;
    }

    final staffNote = user.role == UserRole.doctor ||
            user.role == UserRole.pharmacist
        ? ' Their staff profile will also be removed.'
        : '';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete user?'),
        content: Text(
          'Remove ${user.name} (${user.role.label}) from MediQuick?$staffNote',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: accentRed),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      await _userService.deleteUser(user);
      if (!mounted) return;
      showSimulationSnack(context, '${user.name} deleted.');
    } catch (_) {
      if (!mounted) return;
      showSimulationSnack(
        context,
        'Could not delete user. Try again later.',
      );
    }
  }
}

class _UserCard extends StatelessWidget {
  const _UserCard({
    required this.user,
    required this.onEditRole,
    required this.onDelete,
  });

  final AppUser user;
  final VoidCallback onEditRole;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: primaryTeal.withValues(alpha: 0.12),
            child: Icon(user.role.icon, color: primaryTeal),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: const TextStyle(
                    color: deepBlue,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: const TextStyle(color: Color(0xFF5B7280)),
                ),
                if (user.workerType != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    user.workerType!,
                    style: const TextStyle(
                      color: primaryTeal,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8FFF9),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  user.role.label,
                  style: const TextStyle(
                    color: primaryTeal,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton.filledTonal(
                    onPressed: onDelete,
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      color: accentRed,
                    ),
                    tooltip: 'Delete user',
                  ),
                  IconButton.filledTonal(
                    onPressed: onEditRole,
                    icon: const Icon(Icons.edit_rounded),
                    tooltip: 'Edit role',
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _UsersMessage extends StatelessWidget {
  const _UsersMessage({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: primaryTeal, size: 42),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: deepBlue,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
