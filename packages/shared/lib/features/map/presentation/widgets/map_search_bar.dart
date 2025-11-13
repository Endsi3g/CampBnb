import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/config/mapbox_config.dart';

/// Barre de recherche pour la carte
class MapSearchBar extends StatefulWidget {
  final Function(String)? onSearch;
  final Function(String)? onRegionSelected;

  const MapSearchBar({
    super.key,
    this.onSearch,
    this.onRegionSelected,
  });

  @override
  State<MapSearchBar> createState() => _MapSearchBarState();
}

class _MapSearchBarState extends State<MapSearchBar> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<String> _suggestions = [];
  bool _showSuggestions = false;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    if (value.isEmpty) {
      setState(() {
        _suggestions = [];
        _showSuggestions = false;
      });
      return;
    }

    // Recherche dans les régions du Québec
    final matchingRegions = MapboxConfig.quebecRegions
        .where((region) =>
            region.toLowerCase().contains(value.toLowerCase()))
        .take(5)
        .toList();

    setState(() {
      _suggestions = matchingRegions;
      _showSuggestions = matchingRegions.isNotEmpty;
    });

    widget.onSearch?.call(value);
  }

  void _onSuggestionTap(String suggestion) {
    _controller.text = suggestion;
    setState(() {
      _showSuggestions = false;
    });
    _focusNode.unfocus();
    widget.onRegionSelected?.call(suggestion);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Bouton liste
              IconButton(
                icon: const Icon(Icons.list),
                onPressed: () {
                  // TODO: Afficher la liste des campings
                },
                color: AppColors.primary,
              ),

              // Champ de recherche
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  onChanged: _onSearchChanged,
                  decoration: const InputDecoration(
 hintText: 'Rechercher par région, parc ou ville...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
              ),

              // Icône de recherche
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  widget.onSearch?.call(_controller.text);
                },
                color: AppColors.primary,
              ),
            ],
          ),
        ),

        // Suggestions
        if (_showSuggestions && _suggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 8),
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
              children: _suggestions.map((suggestion) {
                return ListTile(
                  title: Text(suggestion),
                  leading: const Icon(Icons.location_on, color: AppColors.primary),
                  onTap: () => _onSuggestionTap(suggestion),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}


