import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/request_model.dart';

class RequestService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<ServiceRequest>> getMechanicRequests(String mechanicId) async {
    try {
      final requestsData = await _supabase
          .from('service_requests')
          .select('*')
          .contains('mechanic_ids', [mechanicId])
          .order('created_at', ascending: false);

      return requestsData.map((map) => ServiceRequest.fromMap(map)).toList();
    } catch (e) {
      print('Error getting mechanic requests: $e');
      return [];
    }
  }

  // Update request status
  Future<void> updateRequestStatus(String requestId, String status, {String? acceptedMechanicId}) async {
    try {
      final updates = {
        'status': status, // Values: pending, in_progress, completed, rejected
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (acceptedMechanicId != null) {
        updates['accepted_mechanic_id'] = acceptedMechanicId;
      }

      print('🔄 Updating request $requestId with: $updates');

      // Try direct SQL update to bypass RLS issues
      try {
        // First try the normal update
        final result = await _supabase
            .from('service_requests')
            .update(updates)
            .eq('id', requestId);

        print('✅ Request $requestId updated successfully. Result: $result');
        
        // Verify the update worked
        final verification = await _supabase
            .from('service_requests')
            .select('status, accepted_mechanic_id')
            .eq('id', requestId)
            .single();
            
        print('🔍 Verification - Status: ${verification['status']}, Accepted: ${verification['accepted_mechanic_id']}');
        
        if (verification['status'] != status) {
          throw Exception('Update verification failed - status not changed');
        }
        
      } catch (updateError) {
        print('❌ Normal update failed: $updateError');
        print('🔄 Trying alternative update method...');
        
        // Alternative method: Use direct SQL
        final sqlResult = await _supabase
            .from('service_requests')
            .update(updates)
            .eq('id', requestId)
            .select();
        
        print('✅ Direct SQL update result: $sqlResult');
        
        if (sqlResult.isEmpty) {
          throw Exception('No rows were updated - check RLS policies');
        }
      }

      // Create notification for user when mechanic accepts request or starts work
      if ((status == 'accepted' || status == 'in_progress') && acceptedMechanicId != null) {
        try {
          print('🔔 Creating notification for user...');
          
          // Get the request details to create notification
          final requestData = await _supabase
              .from('service_requests')
              .select('user_id, user_name, vehicle_type, vehicle_model')
              .eq('id', requestId)
              .single();

          print('📋 Request data: $requestData');

          // Get mechanic details
          final mechanicData = await _supabase
              .from('mechanic_profiles')
              .select('name')
              .eq('user_id', acceptedMechanicId)
              .single();

          print('👨‍🔧 Mechanic data: $mechanicData');

          final mechanicName = mechanicData['name'] as String? ?? 'A mechanic';
          final vehicleInfo = '${requestData['vehicle_type']} ${requestData['vehicle_model']}';

          // Create notification for the user
          await createNotification(
            userId: requestData['user_id'] as String,
            title: status == 'in_progress' ? 'Work in Progress!' : 'Request Accepted!',
            message: '$mechanicName has ${status == 'in_progress' ? 'started working on' : 'accepted'} your service request for $vehicleInfo. They will contact you soon!',
            type: 'request_accepted',
            relatedRequestId: requestId,
          );
          
          print('✅ Notification created successfully');
        } catch (notificationError) {
          print('❌ Error creating acceptance notification: $notificationError');
          // Don't rethrow here to avoid breaking the main flow
        }
      }
    } catch (e) {
      print('❌ Error updating request status: $e');
      rethrow;
    }
  }

  // Create notification
  Future<void> createNotification({
    required String userId,
    required String title,
    required String message,
    required String type,
    String? relatedRequestId,
  }) async {
    try {
      await _supabase
          .from('notifications')
          .insert({
            'user_id': userId,
            'title': title,
            'message': message,
            'type': type,
            'related_request_id': relatedRequestId,
            'created_at': DateTime.now().toIso8601String(),
          });
    } catch (e) {
      print('Error creating notification: $e');
      rethrow;
    }
  }

  // Create a new service request
  Future<String> createServiceRequest({
    required String userId,
    required String userName,
    required String userPhone,
    required String userLocation,
    required String userAddress,
    required String issueDescription,
    required String vehicleType,
    required String vehicleModel,
    required List<String> mechanicIds,
  }) async {
    try {
      final response = await _supabase
          .from('service_requests')
          .insert({
            'user_id': userId,
            'user_name': userName,
            'user_phone': userPhone,
            'user_location': userLocation,
            'user_address': userAddress,
            'issue_description': issueDescription,
            'vehicle_type': vehicleType,
            'vehicle_model': vehicleModel,
            'mechanic_ids': mechanicIds,
          })
          .select('id')
          .single();

      return response['id'] as String;
    } catch (e) {
      print('Error creating service request: $e');
      rethrow;
    }
  }

  // Get requests for a user
  Future<List<ServiceRequest>> getUserRequests(String userId) async {
    try {
      final requestsData = await _supabase
          .from('service_requests')
          .select('*')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return requestsData.map((map) => ServiceRequest.fromMap(map)).toList();
    } catch (e) {
      print('Error getting user requests: $e');
      return [];
    }
  }

  // // Get requests for a mechanic
  // Future<List<ServiceRequest>> getMechanicRequests(String mechanicId) async {
  //   try {
  //     final requestsData = await _supabase
  //         .from('service_requests')
  //         .select('*')
  //         .contains('mechanic_ids', [mechanicId])
  //         .order('created_at', ascending: false);

  //     return requestsData.map((map) => ServiceRequest.fromMap(map)).toList();
  //   } catch (e) {
  //     print('Error getting mechanic requests: $e');
  //     return [];
  //   }
  // }

  // // Update request status
  // Future<void> updateRequestStatus(String requestId, String status, {String? acceptedMechanicId}) async {
  //   try {
  //     final updates = {
  //       'status': status,
  //       'updated_at': DateTime.now().toIso8601String(),
  //     };

  //     if (acceptedMechanicId != null) {
  //       updates['accepted_mechanic_id'] = acceptedMechanicId;
  //     }

  //     await _supabase
  //         .from('service_requests')
  //         .update(updates)
  //         .eq('id', requestId);
  //   } catch (e) {
  //     print('Error updating request status: $e');
  //     rethrow;
  //   }
  // }

  // // Create notification
  // Future<void> createNotification({
  //   required String userId,
  //   required String title,
  //   required String message,
  //   required String type,
  //   String? relatedRequestId,
  // }) async {
  //   try {
  //     await _supabase
  //         .from('notifications')
  //         .insert({
  //           'user_id': userId,
  //           'title': title,
  //           'message': message,
  //           'type': type,
  //           'related_request_id': relatedRequestId,
  //         });
  //   } catch (e) {
  //     print('Error creating notification: $e');
  //     rethrow;
  //   }
  // }

  // Get user notifications
  Future<List<Map<String, dynamic>>> getUserNotifications(String userId) async {
    try {
      return await _supabase
          .from('notifications')
          .select('*')
          .eq('user_id', userId)
          .order('created_at', ascending: false);
    } catch (e) {
      print('Error getting notifications: $e');
      return [];
    }
  }

  // Mark notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('id', notificationId);
    } catch (e) {
      print('Error marking notification as read: $e');
      rethrow;
    }
  }

  // Debug method to test database connection and update
  Future<void> testUpdateRequestStatus(String requestId) async {
    try {
      print('🧪 Testing database update for request: $requestId');
      
      // First, let's check if the request exists
      final existingRequest = await _supabase
          .from('service_requests')
          .select('*')
          .eq('id', requestId)
          .single();
      
      print('📋 Existing request: $existingRequest');
      
      // Test 1: Try a simple update with select to see if it works
      print('🔄 Test 1: Simple update with select...');
      final testResult = await _supabase
          .from('service_requests')
          .update({
            'status': 'in_progress',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', requestId)
          .select();
      
      print('✅ Test 1 result: $testResult');
      
      if (testResult.isEmpty) {
        print('❌ UPDATE FAILED - No rows updated. This indicates RLS policy issue.');
        print('🔧 SOLUTION: Run the SQL commands in supabase_rls_fix.sql');
        return;
      }
      
      // Test 2: Verify the update
      print('🔄 Test 2: Verifying update...');
      final updatedRequest = await _supabase
          .from('service_requests')
          .select('*')
          .eq('id', requestId)
          .single();
      
      print('✅ Test 2 - Updated request: $updatedRequest');
      
      // Test 3: Try updating accepted_mechanic_id
      print('🔄 Test 3: Updating accepted_mechanic_id...');
      final testResult2 = await _supabase
          .from('service_requests')
          .update({
            'accepted_mechanic_id': 'test-mechanic-id',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', requestId)
          .select();
      
      print('✅ Test 3 result: $testResult2');
      
    } catch (e) {
      print('❌ Test update failed: $e');
      print('🔧 This confirms RLS policy issue. Run supabase_rls_fix.sql');
    }
  }
}