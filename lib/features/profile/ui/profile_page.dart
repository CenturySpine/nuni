import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/errors/app_error_message.dart';
import '../../../core/theme/phosphor_icons.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/nuni_avatar.dart';
import '../../../shared/nuni_button.dart';
import '../../../shared/nuni_card.dart';
import '../../../shared/nuni_error_banner.dart';
import '../../../shared/nuni_list_card.dart';
import '../../../shared/nuni_loading.dart';
import '../../../shared/photo_field.dart';
import '../../associations/data/associations_repository.dart';
import '../../associations/ui/association_logo.dart';
import '../../championship/data/championship_repository.dart';
import '../../history/data/history_repository.dart';
import '../../live/data/live_repository.dart';
import '../../sessions/data/sessions_repository.dart';
import '../data/profile_repository.dart';
import '../domain/player.dart';
import 'avatar_crop_dialog.dart';

/// My player profile (plan 05): display name and avatar. There is no
/// separate "account" concept to edit -- the player row IS the account.
/// The avatar can be replaced by an uploaded, cropped photo, which then
/// takes precedence over the Google one (PO, 2026-09-23).
class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final _displayNameController = TextEditingController();
  bool _saving = false;
  bool _uploadingPhoto = false;
  String? _loadedFor;

  @override
  void dispose() {
    _displayNameController.dispose();
    super.dispose();
  }

  /// Names and avatars are never copied anywhere, always read from
  /// `players` -- but screens already loaded keep the old values until
  /// reloaded, so every cached read that shows them is refreshed (PO,
  /// 2026-09-23).
  void _refreshPlayerReads() {
    ref
      ..invalidate(myPlayerProvider)
      ..invalidate(historyEntriesProvider)
      ..invalidate(historyDetailProvider)
      ..invalidate(championshipStandingsProvider)
      ..invalidate(liveSessionProvider)
      ..invalidate(sessionRoomProvider)
      ..invalidate(playerSearchProvider);
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _saving = true);
    try {
      await ref
          .read(profileRepositoryProvider)
          .updateMyPlayer(displayName: _displayNameController.text.trim());
      _refreshPlayerReads();
      _showSnack(l10n.profileSaved);
    } catch (error) {
      _showSnack(describeError(error, l10n));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  /// Pick, crop, upload: saved right away, independently of the name field.
  Future<void> _changePhoto(Player player) async {
    final l10n = AppLocalizations.of(context)!;
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null || !mounted) return;
    final bytes = await picked.readAsBytes();
    if (!mounted) return;
    final cropped = await showAvatarCropDialog(context, bytes);
    if (cropped == null || !mounted) return;

    setState(() => _uploadingPhoto = true);
    try {
      await ref
          .read(profileRepositoryProvider)
          .uploadMyAvatar(
            resizeForUpload(cropped, maxWidth: 512, quality: 85),
            previousUrl: player.avatarUrl,
          );
      _refreshPlayerReads();
      _showSnack(l10n.profilePhotoUpdated);
    } catch (error) {
      _showSnack(describeError(error, l10n));
    } finally {
      if (mounted) setState(() => _uploadingPhoto = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final playerAsync = ref.watch(myPlayerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profileTitle)),
      body: playerAsync.when(
        loading: () => const NuniLoading(),
        error: (error, _) => Padding(
          padding: const EdgeInsets.all(16),
          child: NuniErrorBanner(
            message: describeError(error, l10n),
            onRetry: () => ref.invalidate(myPlayerProvider),
          ),
        ),
        data: (player) {
          if (_loadedFor != player.id) {
            _loadedFor = player.id;
            _displayNameController.text = player.name;
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const SizedBox(height: 8),
              Center(
                child: Stack(
                  children: [
                    InkWell(
                      customBorder: const CircleBorder(),
                      onTap: _uploadingPhoto
                          ? null
                          : () => _changePhoto(player),
                      child: NuniAvatar(
                        name: player.name,
                        imageUrl: player.avatarUrl,
                        size: 104,
                      ),
                    ),
                    if (_uploadingPhoto)
                      const Positioned.fill(
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: IconButton.filled(
                        tooltip: l10n.profilePhotoChange,
                        onPressed: _uploadingPhoto
                            ? null
                            : () => _changePhoto(player),
                        style: IconButton.styleFrom(
                          backgroundColor: scheme.primary,
                          foregroundColor: scheme.onPrimary,
                          side: BorderSide(color: scheme.surface, width: 3),
                        ),
                        icon: const Icon(PhosphorIcons.camera, size: 18),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  player.name,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              const SizedBox(height: 28),
              // How others see me (plan 26, volet C).
              NuniListCard(
                title: l10n.profileSeePublicPage,
                onTap: () => context.push('/players/${player.id}'),
              ),
              const SizedBox(height: 16),
              _MyAssociationCard(associationId: player.associationId),
              const SizedBox(height: 16),
              NuniCard(
                child: TextField(
                  controller: _displayNameController,
                  decoration: InputDecoration(
                    labelText: l10n.profileDisplayNameLabel,
                  ),
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

/// My association (plan 18), opening its page -- or the associations tab
/// while I have none.
class _MyAssociationCard extends ConsumerWidget {
  const _MyAssociationCard({required this.associationId});

  final String? associationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final association = associationId == null
        ? null
        : ref.watch(associationByIdProvider(associationId!)).value;
    return NuniListCard(
      leading: association == null
          ? null
          : AssociationLogo(association: association),
      title: association?.name ?? l10n.settingsNoAssociation,
      subtitle: l10n.settingsMyAssociation,
      onTap: () => context.push(
        association == null
            ? '/associations'
            : '/associations/${association.id}',
      ),
    );
  }
}
