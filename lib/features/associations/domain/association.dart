import 'dart:math' as math;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'association.freezed.dart';
part 'association.g.dart';

/// Mirrors the `association_status` Postgres enum (plan 18).
enum AssociationStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('approved')
  approved,
  @JsonValue('rejected')
  rejected,
}

/// Mirrors the `associations` table (plan 18): the club a player belongs to,
/// a session is played for and a championship is run by (Q77).
@freezed
abstract class Association with _$Association {
  const Association._();

  const factory Association({
    required String id,
    required String name,
    @JsonKey(name: 'short_name') String? shortName,
    required String city,
    @JsonKey(name: 'location_lat') required double locationLat,
    @JsonKey(name: 'location_lng') required double locationLng,
    @JsonKey(name: 'website_url') String? websiteUrl,
    @JsonKey(name: 'logo_path') String? logoPath,
    required AssociationStatus status,
    @JsonKey(name: 'created_by') String? createdBy,
  }) = _Association;

  factory Association.fromJson(Map<String, Object?> json) =>
      _$AssociationFromJson(json);

  /// The short form for tight spots (championship card): the abbreviation
  /// when there is one ("LSG"), otherwise the full name.
  String get label {
    final short = shortName?.trim();
    return short == null || short.isEmpty ? name : short;
  }
}

/// Mirrors the `association_manager_status` Postgres enum (plan 18).
enum AssociationManagerStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('approved')
  approved,
  @JsonValue('rejected')
  rejected,
  @JsonValue('revoked')
  revoked,
}

/// Mirrors `association_managers`: one local-manager claim (plan 18, Q78).
/// The contact details live apart ([ManagerContact]), never public.
@freezed
abstract class AssociationManager with _$AssociationManager {
  const factory AssociationManager({
    required String id,
    @JsonKey(name: 'association_id') required String associationId,
    @JsonKey(name: 'user_id') required String userId,
    required AssociationManagerStatus status,
    @JsonKey(name: 'requested_at') required DateTime requestedAt,
  }) = _AssociationManager;

  factory AssociationManager.fromJson(Map<String, Object?> json) =>
      _$AssociationManagerFromJson(json);
}

/// Mirrors `association_manager_contacts`: readable only by the manager (or
/// claimant) themself and super_admins (plan 18).
@freezed
abstract class ManagerContact with _$ManagerContact {
  const factory ManagerContact({
    @JsonKey(name: 'manager_id') required String managerId,
    required String email,
    required String phone,
    @JsonKey(name: 'request_message') String? requestMessage,
  }) = _ManagerContact;

  factory ManagerContact.fromJson(Map<String, Object?> json) =>
      _$ManagerContactFromJson(json);
}

/// Great-circle distance in kilometres (haversine), precise enough to rank
/// associations by how close their city is.
double distanceKm(double lat1, double lng1, double lat2, double lng2) {
  const earthRadiusKm = 6371.0;
  double rad(double degrees) => degrees * math.pi / 180;
  final dLat = rad(lat2 - lat1);
  final dLng = rad(lng2 - lng1);
  final a =
      math.pow(math.sin(dLat / 2), 2) +
      math.cos(rad(lat1)) *
          math.cos(rad(lat2)) *
          math.pow(math.sin(dLng / 2), 2);
  return 2 * earthRadiusKm * math.asin(math.sqrt(a));
}

/// The first-sign-in list (plan 18, decision 1): nearest first when the
/// position is known, otherwise alphabetical.
List<Association> sortForChoice(
  List<Association> associations, {
  double? lat,
  double? lng,
}) {
  int byName(Association a, Association b) =>
      a.name.toLowerCase().compareTo(b.name.toLowerCase());
  final sorted = [...associations];
  if (lat == null || lng == null) return sorted..sort(byName);
  double distance(Association a) =>
      distanceKm(lat, lng, a.locationLat, a.locationLng);
  return sorted..sort((a, b) {
    final byDistance = distance(a).compareTo(distance(b));
    return byDistance != 0 ? byDistance : byName(a, b);
  });
}

/// The associations tab (plan 18): mine first, then the others
/// alphabetically.
List<Association> sortForDirectory(
  List<Association> associations,
  String? myAssociationId,
) {
  final sorted = sortForChoice(associations);
  final mine = [
    for (final a in sorted)
      if (a.id == myAssociationId) a,
  ];
  return [
    ...mine,
    for (final a in sorted)
      if (a.id != myAssociationId) a,
  ];
}
