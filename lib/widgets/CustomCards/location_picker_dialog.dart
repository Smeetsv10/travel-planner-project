import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationPickerDialog extends StatefulWidget {
  final LatLng? initialLocation;
  const LocationPickerDialog({super.key, this.initialLocation});

  @override
  State<LocationPickerDialog> createState() => _LocationPickerDialogState();
}

class _LocationPickerDialogState extends State<LocationPickerDialog> {
  LatLng? _pickedLocation;
  late GoogleMapController _controller;

  @override
  void initState() {
    super.initState();
    _pickedLocation =
        widget.initialLocation ??
        const LatLng(52.3676, 4.9041); // Default: Amsterdam
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Pick a location'),
      content: SizedBox(
        width: 300,
        height: 300,
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
