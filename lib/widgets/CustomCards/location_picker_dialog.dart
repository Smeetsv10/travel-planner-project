import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';

class LocationPickerDialog extends StatefulWidget {
  final LatLng? initialLocation;
  const LocationPickerDialog({super.key, this.initialLocation});

  @override
  State<LocationPickerDialog> createState() => _LocationPickerDialogState();
}

class _LocationPickerDialogState extends State<LocationPickerDialog> {
  LatLng? _pickedLocation;
  late GoogleMapController _controller;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _pickedLocation =
        widget.initialLocation ?? const LatLng(52.3676, 4.9041); // Amsterdam
  }

  Future<void> _searchLocation() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;
    try {
      final locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        final loc = locations.first;
        final latLng = LatLng(loc.latitude, loc.longitude);
        setState(() {
          _pickedLocation = latLng;
        });
        _controller.animateCamera(CameraUpdate.newLatLng(latLng));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Location not found')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Pick a location'),
      content: SizedBox(
        width: 350,
        height: 380,
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search location',
                      isDense: true,
                    ),
                    onSubmitted: (_) => _searchLocation(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _searchLocation,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _pickedLocation!,
                  zoom: 12,
                ),
                onMapCreated: (controller) => _controller = controller,
                onTap: (latLng) {
                  setState(() {
                    _pickedLocation = latLng;
                  });
                },
                markers: _pickedLocation != null
                    ? {
                        Marker(
                          markerId: const MarkerId('picked'),
                          position: _pickedLocation!,
                        ),
                      }
                    : {},
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(_pickedLocation),
          child: const Text('Select'),
        ),
      ],
    );
  }
}
