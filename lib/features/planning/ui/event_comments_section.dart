import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/errors/app_error_message.dart';
import '../../../core/theme/phosphor_icons.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/nuni_avatar.dart';
import '../../../shared/nuni_card.dart';
import '../../../shared/nuni_confirm_dialog.dart';
import '../../../shared/nuni_error_banner.dart';
import '../../../shared/nuni_linked_text.dart';
import '../../../shared/nuni_loading.dart';
import '../../../shared/nuni_section_header.dart';
import '../../profile/data/profile_repository.dart';
import '../../profile/domain/player.dart';
import '../data/events_repository.dart';
import '../domain/event.dart';
import 'event_widgets.dart';

/// Longest comment the base accepts (Q166).
const _maxLength = 2000;

/// An event's comment thread (plan 23, Q166): linear, oldest first, live
/// while the page is open; links clickable; no reply, no mention, no emoji
/// picker (the phone keyboard's emoji go through). The author edits or
/// deletes their comment; the local manager and super_admins delete any.
class EventCommentsSection extends ConsumerStatefulWidget {
  const EventCommentsSection({
    super.key,
    required this.event,
    required this.members,
    required this.canModerate,
  });

  final Event event;
  final List<Player> members;
  final bool canModerate;

  @override
  ConsumerState<EventCommentsSection> createState() =>
      _EventCommentsSectionState();
}

class _EventCommentsSectionState extends ConsumerState<EventCommentsSection> {
  final _controller = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _afterChange() {
    // The live thread shows the change; the comment count of the planning
    // and home cards is read apart.
    ref
      ..invalidate(myPlanningProvider)
      ..invalidate(eventByIdProvider(widget.event.id));
  }

  void _snack(String message) =>
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));

  Future<void> _send(String playerId) async {
    final l10n = AppLocalizations.of(context)!;
    final body = _controller.text.trim();
    if (body.isEmpty) return;
    setState(() => _sending = true);
    try {
      await ref
          .read(eventsRepositoryProvider)
          .addComment(
            eventId: widget.event.id,
            authorPlayerId: playerId,
            body: body,
          );
      _controller.clear();
      // Reloads right away, whether or not the live update arrives first.
      ref.invalidate(eventCommentsProvider(widget.event.id));
      _afterChange();
    } catch (error) {
      if (mounted) _snack(describeError(error, l10n));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _edit(EventComment comment) async {
    final l10n = AppLocalizations.of(context)!;
    final body = await showDialog<String>(
      context: context,
      builder: (context) => _EditCommentDialog(initial: comment.body),
    );
    if (body == null || body.trim().isEmpty || body.trim() == comment.body) {
      return;
    }
    try {
      await ref.read(eventsRepositoryProvider).editComment(comment.id, body);
      ref.invalidate(eventCommentsProvider(widget.event.id));
    } catch (error) {
      if (mounted) _snack(describeError(error, l10n));
    }
  }

  Future<void> _delete(EventComment comment) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await NuniConfirmDialog.show(
      context,
      title: l10n.planningCommentDeleteTitle,
      message: l10n.planningCommentDeleteMessage,
      confirmLabel: l10n.commonDelete,
      danger: true,
    );
    if (!confirmed) return;
    try {
      await ref.read(eventsRepositoryProvider).deleteComment(comment.id);
      ref.invalidate(eventCommentsProvider(widget.event.id));
      _afterChange();
    } catch (error) {
      if (mounted) _snack(describeError(error, l10n));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final me = ref.watch(myPlayerProvider).value;
    final comments = ref.watch(eventCommentsProvider(widget.event.id));
    final byId = {for (final member in widget.members) member.id: member};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        NuniSectionHeader(
          title: l10n.planningComments,
          trailing: EventCommentCount(count: comments.value?.length ?? 0),
        ),
        comments.when(
          data: (list) => list.isEmpty
              ? Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    l10n.planningCommentsEmpty,
                    style: textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                )
              : Column(
                  children: [
                    for (final comment in list)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _CommentTile(
                          comment: comment,
                          author: byId[comment.authorPlayerId],
                          mine: comment.authorPlayerId == me?.id,
                          canDelete:
                              comment.authorPlayerId == me?.id ||
                              widget.canModerate,
                          onEdit: () => _edit(comment),
                          onDelete: () => _delete(comment),
                        ),
                      ),
                  ],
                ),
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: NuniLoading(),
          ),
          error: (error, _) =>
              NuniErrorBanner(message: describeError(error, l10n)),
        ),
        if (me != null)
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  minLines: 1,
                  maxLines: 5,
                  maxLength: _maxLength,
                  maxLengthEnforcement: MaxLengthEnforcement.enforced,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: l10n.planningCommentHint,
                    counterText: '',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                tooltip: l10n.planningCommentSend,
                onPressed: _sending ? null : () => _send(me.id),
                icon: const Icon(PhosphorIcons.paperPlaneRight),
              ),
            ],
          ),
      ],
    );
  }
}

class _CommentTile extends StatelessWidget {
  const _CommentTile({
    required this.comment,
    required this.author,
    required this.mine,
    required this.canDelete,
    required this.onEdit,
    required this.onDelete,
  });

  final EventComment comment;
  final Player? author;
  final bool mine;
  final bool canDelete;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context).toString();
    final at = comment.createdAt.toLocal();
    final when = [
      '${DateFormat.MMMd(locale).format(at)} ${DateFormat.Hm(locale).format(at)}',
      if (comment.editedAt != null) l10n.planningCommentEdited,
    ].join(' · ');

    return NuniCard(
      padding: const EdgeInsets.fromLTRB(12, 10, 4, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NuniAvatar(name: author?.name, imageUrl: author?.avatarUrl, size: 32),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  author?.name ?? '…',
                  style: textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  when,
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 6),
                NuniLinkedText(comment.body, style: textTheme.bodyMedium),
              ],
            ),
          ),
          if (mine || canDelete)
            PopupMenuButton<String>(
              icon: const Icon(PhosphorIcons.dotsThreeVertical, size: 18),
              onSelected: (action) => action == 'edit' ? onEdit() : onDelete(),
              itemBuilder: (context) => [
                if (mine)
                  PopupMenuItem(value: 'edit', child: Text(l10n.planningEdit)),
                if (canDelete)
                  PopupMenuItem(
                    value: 'delete',
                    child: Text(
                      l10n.planningDelete,
                      style: TextStyle(color: scheme.error),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _EditCommentDialog extends StatefulWidget {
  const _EditCommentDialog({required this.initial});

  final String initial;

  @override
  State<_EditCommentDialog> createState() => _EditCommentDialogState();
}

class _EditCommentDialogState extends State<_EditCommentDialog> {
  late final _controller = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.planningCommentEditTitle),
      content: TextField(
        controller: _controller,
        autofocus: true,
        minLines: 2,
        maxLines: 8,
        maxLength: _maxLength,
        maxLengthEnforcement: MaxLengthEnforcement.enforced,
        textCapitalization: TextCapitalization.sentences,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: Text(l10n.commonSave),
        ),
      ],
    );
  }
}
