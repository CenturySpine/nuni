import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
// Hides gotrue's own `Session` type, which otherwise clashes with the
// sessions feature's `Session`.
import 'package:supabase_flutter/supabase_flutter.dart' hide Session;

import '../../../core/supabase/supabase_providers.dart';
import '../../profile/data/profile_repository.dart';
import '../../sessions/domain/session.dart';
import '../domain/event.dart';
import '../domain/ics/ics_parser.dart';
import '../domain/planning.dart';

part 'events_repository.g.dart';

/// An event row with what the condensed views show: every answer (count of
/// present players, my own answer) and the number of comments (plan 23).
const _eventColumns =
    '*, event_responses(player_id, response), '
    'event_comments(count)';

/// What a new import would erase (Q155, Q163).
class ImportPreview {
  const ImportPreview({
    required this.events,
    required this.responses,
    required this.comments,
  });

  final int events;
  final int responses;
  final int comments;
}

class EventsRepository {
  EventsRepository(this._client);

  final SupabaseClient _client;

  /// Every event of [associationId], past and coming, in date order (Q159).
  Future<List<Event>> fetchPlanning(String associationId) async {
    final rows = await _client
        .from('events')
        .select(_eventColumns)
        .eq('association_id', associationId)
        .order('starts_at', ascending: true);
    return rows.map(Event.fromJson).toList();
  }

  /// Null when the event doesn't exist or belongs to another association
  /// (RLS shows nothing of it, plan 23 decision 18).
  Future<Event?> fetchEvent(String id) async {
    final row = await _client
        .from('events')
        .select(_eventColumns)
        .eq('id', id)
        .maybeSingle();
    return row == null ? null : Event.fromJson(row);
  }

  /// Adds an event to my association (the base sets it, with its creator
  /// and origin); returns its id.
  Future<String> create(EventDraft draft) async {
    final row = await _client
        .from('events')
        .insert(draft.toRow())
        .select('id')
        .single();
    return row['id'] as String;
  }

  Future<void> update(String id, EventDraft draft) =>
      _client.from('events').update(draft.toRow()).eq('id', id);

  Future<void> delete(String id) =>
      _client.from('events').delete().eq('id', id);

  /// Sets my answer, or withdraws it when [response] is null.
  Future<void> answer({
    required String eventId,
    required String playerId,
    required EventResponse? response,
  }) {
    if (response == null) {
      return _client
          .from('event_responses')
          .delete()
          .eq('event_id', eventId)
          .eq('player_id', playerId);
    }
    return _client.from('event_responses').upsert({
      'event_id': eventId,
      'player_id': playerId,
      'response': response.toPostgresValue(),
    });
  }

  Future<List<EventComment>> fetchComments(String eventId) async {
    final rows = await _client
        .from('event_comments')
        .select()
        .eq('event_id', eventId)
        .order('created_at', ascending: true);
    return rows.map(EventComment.fromJson).toList();
  }

  Future<void> addComment({
    required String eventId,
    required String authorPlayerId,
    required String body,
  }) => _client.from('event_comments').insert({
    'event_id': eventId,
    'author_player_id': authorPlayerId,
    'body': body.trim(),
  });

  Future<void> editComment(String id, String body) =>
      _client.from('event_comments').update({'body': body.trim()}).eq('id', id);

  Future<void> deleteComment(String id) =>
      _client.from('event_comments').delete().eq('id', id);

  /// The comment thread of [eventId], live (Q166): reloaded whenever a
  /// comment of this event is added, edited or deleted -- a Realtime
  /// subscription filtered by event, never on the whole table.
  Stream<List<EventComment>> watchComments(String eventId) {
    late final StreamController<List<EventComment>> controller;
    StreamSubscription<List<Map<String, dynamic>>>? subscription;

    Future<void> refresh() async {
      try {
        final comments = await fetchComments(eventId);
        if (!controller.isClosed) controller.add(comments);
      } catch (error, stack) {
        if (!controller.isClosed) controller.addError(error, stack);
      }
    }

    controller = StreamController<List<EventComment>>(
      onListen: () {
        unawaited(refresh());
        subscription = _client
            .from('event_comments')
            .stream(primaryKey: ['id'])
            .eq('event_id', eventId)
            .listen((_) => unawaited(refresh()), onError: controller.addError);
      },
      onCancel: () => unawaited(subscription?.cancel()),
    );
    return controller.stream;
  }

  /// Labels used in [associationId]'s events, most recent first (Q148).
  Future<List<String>> fetchLabels(String associationId) async {
    final rows = await _client
        .from('events')
        .select('label, created_at')
        .eq('association_id', associationId)
        .order('created_at', ascending: false)
        .limit(300);
    return labelSuggestions([for (final row in rows) row['label'] as String]);
  }

  /// The sessions started from [eventId] (Q164), most recent first.
  Future<List<Session>> fetchSessions(String eventId) async {
    final rows = await _client
        .from('sessions')
        .select()
        .eq('event_id', eventId)
        .order('created_at', ascending: false);
    return rows.map(Session.fromJson).toList();
  }

  /// What importing into my association would erase. An import always
  /// targets the importer's own association (PO, 2026-09-25): the base
  /// finds it, the app never sends one.
  Future<ImportPreview> importPreview() async {
    final result = await _client.rpc<Map<String, dynamic>>(
      'import_events_preview',
    );
    return ImportPreview(
      events: (result['events'] as num).toInt(),
      responses: (result['responses'] as num).toInt(),
      comments: (result['comments'] as num).toInt(),
    );
  }

  /// Replaces my association's coming imported events with [events] (Q155,
  /// Q163); returns how many were created.
  Future<int> importEvents(
    List<IcsEvent> events, {
    required String untitledLabel,
  }) async {
    final result = await _client.rpc<Map<String, dynamic>>(
      'import_events',
      params: {
        'p_events': [
          for (final event in events)
            {
              'label': event.label ?? untitledLabel,
              'starts_at': event.startsAt.toUtc().toIso8601String(),
              'spot': event.spot,
              'description': event.description,
              if (event.lat != null && event.lng != null)
                'location': {'lat': event.lat, 'lng': event.lng},
            },
        ],
      },
    );
    return (result['created'] as num).toInt();
  }
}

final eventsRepositoryProvider = Provider<EventsRepository>(
  (ref) => EventsRepository(ref.watch(supabaseClientProvider)),
);

/// My association's planning, or an empty list without an association.
@riverpod
Future<List<Event>> myPlanning(Ref ref) async {
  final associationId = (await ref.watch(myPlayerProvider.future))
      .associationId;
  if (associationId == null) return const [];
  return ref.watch(eventsRepositoryProvider).fetchPlanning(associationId);
}

@riverpod
Future<Event?> eventById(Ref ref, String id) =>
    ref.watch(eventsRepositoryProvider).fetchEvent(id);

@riverpod
Stream<List<EventComment>> eventComments(Ref ref, String eventId) =>
    ref.watch(eventsRepositoryProvider).watchComments(eventId);

@riverpod
Future<List<Session>> eventSessions(Ref ref, String eventId) =>
    ref.watch(eventsRepositoryProvider).fetchSessions(eventId);

@riverpod
Future<List<String>> eventLabelSuggestions(Ref ref, String associationId) =>
    ref.watch(eventsRepositoryProvider).fetchLabels(associationId);
