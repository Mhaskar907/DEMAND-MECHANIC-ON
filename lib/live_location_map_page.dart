import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'auth_service.dart';
import 'services/location_service.dart';
import 'theme/app_theme.dart';
import 'utils/dimensions.dart';

class LiveLocationMapPage extends StatefulWidget {
  const LiveLocationMapPage({super.key});

  @override
  State<LiveLocationMapPage> createState() => _LiveLocationMapPageState();
}

class _LiveLocationMapPageState extends State<LiveLocationMapPage> {
  final LocationService _locationService = LocationService();
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  LatLng? _userLocation;
  bool _isLoading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> _mechanicsLocations = [];

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Get user's current location
      await _getUserLocation();
      
      // Get mechanics locations
      await _loadMechanicsLocations();
      
      setState(() {
        _isLoading = false;
      });

    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load map: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _getUserLocation() async {
    try {
      print('📍 Getting user location...');
      
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions permanently denied');
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _userLocation = LatLng(position.latitude, position.longitude);
      });

      print('✅ User location: ${position.latitude}, ${position.longitude}');
      
    } catch (e) {
      print('❌ Error getting user location: $e');
      // Fallback to Mumbai coordinates
      setState(() {
        _userLocation = const LatLng(19.0760, 72.8777);
      });
    }
  }

  Future<void> _loadMechanicsLocations() async {
    try {
      print('🔍 Loading mechanics locations...');
      
      final locations = await _locationService.getOnlineMechanicsLocations();
      
      setState(() {
        _mechanicsLocations = locations;
        _markers = _createMarkers(locations);
      });

      print('✅ Loaded ${locations.length} mechanic locations');
      
    } catch (e) {
      print('❌ Error loading mechanics locations: $e');
      setState(() {
        _errorMessage = 'Failed to load mechanic locations: $e';
      });
    }
  }

  Set<Marker> _createMarkers(List<Map<String, dynamic>> locations) {
    Set<Marker> markers = {};
    
    // Add user location marker
    if (_userLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('user_location'),
          position: _userLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: const InfoWindow(
            title: 'Your Location',
            snippet: 'You are here',
          ),
        ),
      );
    }

    // Add mechanic markers
    for (int i = 0; i < locations.length; i++) {
      final location = locations[i];
      final lat = location['latitude'] as double;
      final lng = location['longitude'] as double;
      final mechanicName = location['mechanic_name'] as String;
      final address = location['address'] as String? ?? 'Location not available';
      final lastUpdated = DateTime.parse(location['last_updated'] as String);
      
      // Calculate time since last update
      final timeDiff = DateTime.now().difference(lastUpdated);
      final timeAgo = _formatTimeAgo(timeDiff);

      markers.add(
        Marker(
          markerId: MarkerId('mechanic_${location['mechanic_id']}'),
          position: LatLng(lat, lng),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(
            title: mechanicName,
            snippet: '$address\nLast seen: $timeAgo',
          ),
        ),
      );
    }

    return markers;
  }

  String _formatTimeAgo(Duration duration) {
    if (duration.inMinutes < 1) {
      return 'Just now';
    } else if (duration.inMinutes < 60) {
      return '${duration.inMinutes}m ago';
    } else if (duration.inHours < 24) {
      return '${duration.inHours}h ago';
    } else {
      return '${duration.inDays}d ago';
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    
    // Fit map to show all markers
    if (_markers.isNotEmpty && _mapController != null) {
      _fitMapToMarkers();
    }
  }

  Future<void> _fitMapToMarkers() async {
    if (_markers.isEmpty) return;

    double minLat = _markers.first.position.latitude;
    double maxLat = _markers.first.position.latitude;
    double minLng = _markers.first.position.longitude;
    double maxLng = _markers.first.position.longitude;

    for (Marker marker in _markers) {
      minLat = minLat < marker.position.latitude ? minLat : marker.position.latitude;
      maxLat = maxLat > marker.position.latitude ? maxLat : marker.position.latitude;
      minLng = minLng < marker.position.longitude ? minLng : marker.position.longitude;
      maxLng = maxLng > marker.position.longitude ? maxLng : marker.position.longitude;
    }

    await _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        100.0, // padding
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dim = Dimensions(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Mechanic Locations'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _initializeMap,
          ),
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: _showDebugInfo,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorWidget()
              : _buildMapWidget(dim),
      floatingActionButton: FloatingActionButton(
        onPressed: _fitMapToMarkers,
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.my_location, color: Colors.white),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Error Loading Map',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _initializeMap,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapWidget(Dimensions dim) {
    return Stack(
      children: [
        GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: _userLocation ?? const LatLng(19.0760, 72.8777),
            zoom: 12.0,
          ),
          markers: _markers,
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          mapType: MapType.normal,
          onTap: (LatLng position) {
            // Handle map tap if needed
          },
        ),
        
        // Info panel
        Positioned(
          top: 16,
          left: 16,
          right: 16,
          child: Container(
            padding: EdgeInsets.all(dim.width16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(dim.radius12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: AppTheme.primaryColor,
                      size: dim.iconSize24,
                    ),
                    SizedBox(width: dim.width8),
                    Text(
                      'Live Mechanic Locations',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: dim.height8),
                Text(
                  '${_mechanicsLocations.length} mechanics online',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                if (_userLocation != null) ...[
                  SizedBox(height: dim.height40),
                  Text(
                    'Your location: ${_userLocation!.latitude.toStringAsFixed(4)}, ${_userLocation!.longitude.toStringAsFixed(4)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showDebugInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Debug Information'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('User Location: ${_userLocation?.latitude}, ${_userLocation?.longitude}'),
              const SizedBox(height: 8),
              Text('Mechanics Online: ${_mechanicsLocations.length}'),
              const SizedBox(height: 8),
              Text('Markers Count: ${_markers.length}'),
              const SizedBox(height: 8),
              const Text('Mechanics Details:'),
              ..._mechanicsLocations.map((location) => Padding(
                padding: const EdgeInsets.only(left: 16, top: 4),
                child: Text(
                  '${location['mechanic_name']}: ${location['latitude']}, ${location['longitude']}',
                  style: const TextStyle(fontSize: 12),
                ),
              )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _initializeMap();
            },
            child: const Text('Refresh'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
