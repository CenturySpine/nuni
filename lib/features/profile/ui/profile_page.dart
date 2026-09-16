import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_error_message.dart';
import '../../../core/theme/phosphor_icons.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/nuni_button.dart';
import '../../../shared/nuni_error_banner.dart';
import '../../../shared/nuni_loading.dart';
import '../data/profile_repository.dart';

/// My player profile (plan 05): display name and avatar, which are mirrored
/// onto the linked player when saved.
class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final _displayNameController = TextEditingController();
  bool _saving = false;
  String? _loadedFor;

  @override
  void dispose() {
    _displayNameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _saving = true);
    try {
      await ref
          .read(profileRepositoryProvider)
          .updateMyProfile(displayName: _displayNameController.text.trim());
      ref.invalidate(myProfileProvider);
      ref.invalidate(myPlayerProvider);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.profileSaved)));
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(describeError(error, l10n))));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final profileAsync = ref.watch(myProfileProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profileTitle)),
      body: profileAsync.when(
        loading: () => const NuniLoading(),
        error: (error, _) => Padding(
          padding: const EdgeInsets.all(16),
          child: NuniErrorBanner(
            message: describeError(error, l10n),
            onRetry: () => ref.invalidate(myProfileProvider),
          ),
        ),
        data: (profile) {
          if (_loadedFor != profile.id) {
            _loadedFor = profile.id;
            _displayNameController.text = profile.displayName;
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Center(
                child: CircleAvatar(
                  radius: 40,
                  backgroundImage: profile.avatarUrl == null
                      ? null
                      : NetworkImage(profile.avatarUrl!),
                  child: profile.avatarUrl == null
                      ? const Icon(PhosphorIcons.userCircle, size: 40)
                      : null,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _displayNameController,
                decoration: InputDecoration(
                  labelText: l10n.profileDisplayNameLabel,
                ),
              ),
              const SizedBox(height: 24),
              NuniButton(
                label: l10n.commonSave,
                onPressed: _saving ? null : _save,
              ),
            ],
          );
        },
      ),
    );
  }
}
