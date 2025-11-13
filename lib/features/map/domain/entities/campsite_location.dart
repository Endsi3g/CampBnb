import 'package:equatable/equatable.dart';

/// Type d'emplacement de camping
enum CampsiteType {
  tent, // Tente
  rv, // VR (Véhicule récréatif)
  cabin, // Chalet/Prêt-à-camper
  wild, // Camping sauvage
  lake, // Emplacement au bord d'un lac
  forest, // Emplacement en forêt
  beach, // Emplacement sur la plage
  mountain, // Emplacement en montagne
}

/// Entité représentant un emplacement de camping sur la carte
class CampsiteLocation extends Equatable {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final CampsiteType type;
  final String? description;
  final double? pricePerNight;
  final String? hostId;
  final String? imageUrl;
  final double? rating;
  final int? reviewCount;
  final bool isAvailable;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const CampsiteLocation({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.type,
    this.description,
    this.pricePerNight,
    this.hostId,
    this.imageUrl,
    this.rating,
    this.reviewCount,
    this.isAvailable = true,
    this.createdAt,
    this.updatedAt,
  });

  /// Crée une copie avec des champs modifiés
  CampsiteLocation copyWith({
    String? id,
    String? name,
    double? latitude,
    double? longitude,
    CampsiteType? type,
    String? description,
    double? pricePerNight,
    String? hostId,
    String? imageUrl,
    double? rating,
    int? reviewCount,
    bool? isAvailable,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CampsiteLocation(
      id: id ?? this.id,
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      type: type ?? this.type,
      description: description ?? this.description,
      pricePerNight: pricePerNight ?? this.pricePerNight,
      hostId: hostId ?? this.hostId,
      imageUrl: imageUrl ?? this.imageUrl,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      isAvailable: isAvailable ?? this.isAvailable,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    latitude,
    longitude,
    type,
    description,
    pricePerNight,
    hostId,
    imageUrl,
    rating,
    reviewCount,
    isAvailable,
    createdAt,
    updatedAt,
  ];
}

/// Cluster de plusieurs emplacements proches
class CampsiteCluster extends Equatable {
  final String id;
  final double latitude;
  final double longitude;
  final int pointCount;
  final List<String> campsiteIds;

  const CampsiteCluster({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.pointCount,
    required this.campsiteIds,
  });

  @override
  List<Object?> get props => [id, latitude, longitude, pointCount, campsiteIds];
}
