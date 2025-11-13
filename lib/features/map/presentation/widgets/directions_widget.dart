import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../services/navigation_service.dart';
import '../../domain/entities/campsite_location.dart';

/// Widget pour afficher les directions vers un emplacement
class DirectionsWidget extends StatefulWidget {
  final double startLat;
  final double startLon;
  final CampsiteLocation destination;
  final NavigationService navigationService;

  const DirectionsWidget({
    super.key,
    required this.startLat,
    required this.startLon,
    required this.destination,
    required this.navigationService,
  });

  @override
  State<DirectionsWidget> createState() => _DirectionsWidgetState();
}

class _DirectionsWidgetState extends State<DirectionsWidget> {
  NavigationRoute? _route;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDirections();
  }

  Future<void> _loadDirections() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final route = await widget.navigationService.getDirectionsToCampsite(
        startLat: widget.startLat,
        startLon: widget.startLon,
        destination: widget.destination,
      );

      setState(() {
        _route = route;
        _isLoading = false;
        if (route == null) {
          _error = 'Aucun itinéraire trouvé';
        }
      });
    } catch (e) {
      setState(() {
        _error = 'Erreur lors du chargement des directions';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadDirections,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (_route == null) {
      return const Center(child: Text('Aucun itinéraire disponible'));
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête avec distance et durée
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Distance',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  Text(
                    _route!.formattedDistance,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Durée',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  Text(
                    _route!.formattedDuration,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Étapes de la route
          if (_route!.steps.isNotEmpty) ...[
            const Divider(),
            const Text(
              'Itinéraire',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            ..._route!.steps.take(5).map((step) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(
                      _getManeuverIcon(step.maneuver),
                      size: 20,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        step.instruction,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              );
            }),
            if (_route!.steps.length > 5)
              TextButton(
                onPressed: () {
                  // TODO: Afficher toutes les étapes
                },
                child: const Text('Voir toutes les étapes'),
              ),
          ],

          // Bouton d'action
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // TODO: Ouvrir l'application de navigation
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Ouvrir dans la navigation'),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getManeuverIcon(String? maneuver) {
    switch (maneuver) {
      case 'turn':
        return Icons.turn_right;
      case 'straight':
        return Icons.straight;
      case 'arrive':
        return Icons.flag;
      default:
        return Icons.navigation;
    }
  }
}
