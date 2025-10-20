import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:async';

class LocationService {
  final SupabaseClient _supabase = Supabase.instance.client;
  Timer? _locationTimer;
  bool _isTracking = false;

  // Expose supabase client for external access
  SupabaseClient get supabase => _supabase;

  // Start location tracking for mechanic
  Future<void> startLocationTracking(String mechanicId, String mechanicName) async {
    try {
      print('🗺️ Starting location tracking for mechanic: $mechanicName');
      
      _isTracking = true;
      
      // Get initial location
      await _updateLocation(mechanicId, mechanicName);
      
      // Set up periodic location updates (every 30 seconds)
      _locationTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
        if (_isTracking) {
          _updateLocation(mechanicId, mechanicName);
        }
      });
      
      print('✅ Location tracking started successfully');
    } catch (e) {
      print('❌ Error starting location tracking: $e');
      rethrow;
    }
  }

  // Stop location tracking
  void stopLocationTracking() {
    print('🛑 Stopping location tracking');
    _isTracking = false;
    _locationTimer?.cancel();
    _locationTimer = null;
  }

  // Update mechanic location in database
  Future<void> _updateLocation(String mechanicId, String mechanicName) async {
    try {
      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        print('❌ Location permission denied');
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Get address from coordinates
      String address = 'Location not available';
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        
        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];
          address = '${place.street}, ${place.locality}, ${place.administrativeArea}';
        }
      } catch (e) {
        print('⚠️ Could not get address: $e');
      }

      // Update or insert location in database
      await _supabase
          .from('mechanic_locations')
          .upsert({
            'mechanic_id': mechanicId,
            'mechanic_name': mechanicName,
            'latitude': position.latitude,
            'longitude': position.longitude,
            'address': address,
            'is_online': true,
            'last_updated': DateTime.now().toIso8601String(),
          });

      print('📍 Location updated: ${position.latitude}, ${position.longitude} - $address');
      
    } catch (e) {
      print('❌ Error updating location: $e');
    }
  }

  // Get all online mechanics locations
  Future<List<Map<String, dynamic>>> getOnlineMechanicsLocations() async {
    try {
      print('🔍 Fetching online mechanics locations...');
      
      final response = await _supabase
          .from('mechanic_locations')
          .select('*')
          .eq('is_online', true)
          .order('last_updated', ascending: false);

      print('✅ Found ${response.length} online mechanics');
      return List<Map<String, dynamic>>.from(response);
      
    } catch (e) {
      print('❌ Error fetching mechanics locations: $e');
      return [];
    }
  }

  // Get specific mechanic location
  Future<Map<String, dynamic>?> getMechanicLocation(String mechanicId) async {
    try {
      final response = await _supabase
          .from('mechanic_locations')
          .select('*')
          .eq('mechanic_id', mechanicId)
          .eq('is_online', true)
          .single();

      return response;
    } catch (e) {
      print('❌ Error fetching mechanic location: $e');
      return null;
    }
  }

  // Set mechanic offline
  Future<void> setMechanicOffline(String mechanicId) async {
    try {
      await _supabase
          .from('mechanic_locations')
          .update({'is_online': false})
          .eq('mechanic_id', mechanicId);
      
      print('👋 Mechanic $mechanicId set offline');
    } catch (e) {
      print('❌ Error setting mechanic offline: $e');
    }
  }

  // Debug method to test location service
  Future<void> testLocationService(String mechanicId, String mechanicName) async {
    try {
      print('🧪 Testing location service...');
      
      // Test 1: Check permissions
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      print('📍 Location service enabled: $serviceEnabled');
      
      LocationPermission permission = await Geolocator.checkPermission();
      print('🔐 Location permission: $permission');
      
      // Test 2: Get current location
      Position position = await Geolocator.getCurrentPosition();
      print('📍 Current position: ${position.latitude}, ${position.longitude}');
      
      // Test 3: Test database insert
      await _updateLocation(mechanicId, mechanicName);
      
      // Test 4: Verify database
      final locations = await getOnlineMechanicsLocations();
      print('📊 Online mechanics count: ${locations.length}');
      
      print('✅ Location service test completed successfully');
      
    } catch (e) {
      print('❌ Location service test failed: $e');
    }
  }
}
