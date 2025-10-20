import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'auth_service.dart';
import 'services/location_service.dart';
import 'theme/app_theme.dart';
import 'utils/dimensions.dart';

class MechanicLocationSharingPage extends StatefulWidget {
  const MechanicLocationSharingPage({super.key});

  @override
  State<MechanicLocationSharingPage> createState() => _MechanicLocationSharingPageState();
}

class _MechanicLocationSharingPageState extends State<MechanicLocationSharingPage> {
  final LocationService _locationService = LocationService();
  bool _isSharingLocation = false;
  bool _isLoading = false;
  String? _currentAddress;
  Position? _currentPosition;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _errorMessage = 'Location services are disabled. Please enable them in settings.';
          _isLoading = false;
        });
        return;
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _errorMessage = 'Location permissions are denied. Please enable them in settings.';
            _isLoading = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _errorMessage = 'Location permissions are permanently denied. Please enable them in settings.';
          _isLoading = false;
        });
        return;
      }

      // Get current location
      await _getCurrentLocation();

      setState(() {
        _isLoading = false;
      });

    } catch (e) {
      setState(() {
        _errorMessage = 'Error checking location: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
      });

      // Get address from coordinates
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];
          String address = '${place.street}, ${place.locality}, ${place.administrativeArea}';
          setState(() {
            _currentAddress = address;
          });
        }
      } catch (e) {
        print('Could not get address: $e');
        setState(() {
          _currentAddress = 'Lat: ${position.latitude.toStringAsFixed(4)}, Lng: ${position.longitude.toStringAsFixed(4)}';
        });
      }

    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to get current location: $e';
      });
    }
  }

  Future<void> _startLocationSharing() async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final mechanicId = authService.currentUser!.id;
      
      // Get mechanic name from profile
      String mechanicName = 'Mechanic';
      try {
        final profile = await _locationService.supabase
            .from('mechanic_profiles')
            .select('name')
            .eq('user_id', mechanicId)
            .single();
        mechanicName = profile['name'] ?? 'Mechanic';
      } catch (e) {
        print('Could not get mechanic name: $e');
      }

      await _locationService.startLocationTracking(mechanicId, mechanicName);
      
      setState(() {
        _isSharingLocation = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location sharing started! Users can now see your location.'),
          backgroundColor: Colors.green,
        ),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to start location sharing: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _stopLocationSharing() async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final mechanicId = authService.currentUser!.id;

      _locationService.stopLocationTracking();
      await _locationService.setMechanicOffline(mechanicId);
      
      setState(() {
        _isSharingLocation = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location sharing stopped.'),
          backgroundColor: Colors.orange,
        ),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to stop location sharing: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _testLocationService() async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final mechanicId = authService.currentUser!.id;
      final mechanicName = 'Test Mechanic';

      await _locationService.testLocationService(mechanicId, mechanicName);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location service test completed. Check console logs.'),
          backgroundColor: Colors.blue,
        ),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Location service test failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dim = Dimensions(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Share Location'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: _testLocationService,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorWidget(dim)
              : _buildMainWidget(dim),
    );
  }

  Widget _buildErrorWidget(Dimensions dim) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(dim.width24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_off,
              size: dim.height80,
              color: Colors.red,
            ),
            SizedBox(height: dim.height16),
            Text(
              'Location Error',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            SizedBox(height: dim.height8),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            SizedBox(height: dim.height24),
            ElevatedButton.icon(
              onPressed: _checkLocationPermission,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainWidget(Dimensions dim) {
    return Padding(
      padding: EdgeInsets.all(dim.width24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Status Card
          Container(
            padding: EdgeInsets.all(dim.width20),
            decoration: BoxDecoration(
              color: _isSharingLocation ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(dim.radius16),
              border: Border.all(
                color: _isSharingLocation ? Colors.green : Colors.grey,
                width: 2,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  _isSharingLocation ? Icons.location_on : Icons.location_off,
                  size: dim.height60,
                  color: _isSharingLocation ? Colors.green : Colors.grey,
                ),
                SizedBox(height: dim.height12),
                Text(
                  _isSharingLocation ? 'Location Sharing Active' : 'Location Sharing Inactive',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _isSharingLocation ? Colors.green : Colors.grey,
                  ),
                ),
                SizedBox(height: dim.height8),
                Text(
                  _isSharingLocation 
                      ? 'Users can see your live location on the map'
                      : 'Your location is not being shared',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: dim.height24),

          // Current Location Info
          if (_currentPosition != null) ...[
            Container(
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
                        Icons.my_location,
                        color: AppTheme.primaryColor,
                        size: dim.iconSize24,
                      ),
                      SizedBox(width: dim.width8),
                      Text(
                        'Current Location',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: dim.height8),
                  Text(
                    _currentAddress ?? 'Address not available',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  SizedBox(height: dim.height40),
                  Text(
                    'Lat: ${_currentPosition!.latitude.toStringAsFixed(6)}, Lng: ${_currentPosition!.longitude.toStringAsFixed(6)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: dim.height24),
          ],

          // Action Buttons
          if (_isSharingLocation) ...[
            ElevatedButton.icon(
              onPressed: _stopLocationSharing,
              icon: const Icon(Icons.stop),
              label: const Text('Stop Sharing Location'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: dim.height16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(dim.radius12),
                ),
              ),
            ),
          ] else ...[
            ElevatedButton.icon(
              onPressed: _startLocationSharing,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start Sharing Location'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: dim.height16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(dim.radius12),
                ),
              ),
            ),
          ],

          SizedBox(height: dim.height16),

          OutlinedButton.icon(
            onPressed: _getCurrentLocation,
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh Location'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.primaryColor,
              padding: EdgeInsets.symmetric(vertical: dim.height16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(dim.radius12),
              ),
            ),
          ),

          SizedBox(height: dim.height24),

          // Info Card
          Container(
            padding: EdgeInsets.all(dim.width16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(dim.radius12),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue,
                      size: dim.iconSize24,
                    ),
                    SizedBox(width: dim.width8),
                    Text(
                      'How it works',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: dim.height8),
                Text(
                  '• Your location is updated every 30 seconds\n'
                  '• Users can see your live location on the map\n'
                  '• Location sharing stops when you go offline\n'
                  '• Your privacy is protected - only online status is shared',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.blue[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Don't stop location sharing on dispose - let it continue in background
    super.dispose();
  }
}
