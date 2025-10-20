import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_service.dart';
import 'services/request_service.dart';

class DebugTestPage extends StatefulWidget {
  const DebugTestPage({super.key});

  @override
  State<DebugTestPage> createState() => _DebugTestPageState();
}

class _DebugTestPageState extends State<DebugTestPage> {
  final RequestService _requestService = RequestService();
  String _testResults = '';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Database Debug Test'),
        backgroundColor: Colors.red,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _testDatabaseConnection,
              child: const Text('Test Database Connection'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _testCreateRequest,
              child: const Text('Test Create Request'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _testUpdateRequest,
              child: const Text('Test Update Request'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _testCompleteFlow,
              child: const Text('Test Complete Flow'),
            ),
            const SizedBox(height: 24),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      _testResults.isEmpty ? 'Click a test button above' : _testResults,
                      style: const TextStyle(fontFamily: 'monospace'),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _addResult(String result) {
    setState(() {
      _testResults += '$result\n';
    });
  }

  Future<void> _testDatabaseConnection() async {
    setState(() {
      _isLoading = true;
      _testResults = '';
    });

    try {
      _addResult('🧪 Testing Database Connection...');
      
      final supabase = Supabase.instance.client;
      final authService = Provider.of<AuthService>(context, listen: false);
      
      _addResult('✅ Supabase client initialized');
      _addResult('✅ Auth service available');
      _addResult('👤 Current user ID: ${authService.currentUser?.id}');
      
      // Test basic query
      final result = await supabase
          .from('service_requests')
          .select('count')
          .limit(1);
      
      _addResult('✅ Database query successful');
      _addResult('📊 Query result: $result');
      
    } catch (e) {
      _addResult('❌ Database connection failed: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _testCreateRequest() async {
    setState(() {
      _isLoading = true;
      _testResults = '';
    });

    try {
      _addResult('🧪 Testing Create Request...');
      
      final authService = Provider.of<AuthService>(context, listen: false);
      final userId = authService.currentUser!.id;
      
      _addResult('👤 User ID: $userId');
      
      // Create a test request
      final requestId = await _requestService.createServiceRequest(
        userId: userId,
        userName: 'Test User',
        userPhone: '1234567890',
        userLocation: 'Test Location',
        userAddress: 'Test Address',
        issueDescription: 'Test Issue',
        vehicleType: 'Test Vehicle',
        vehicleModel: 'Test Model',
        mechanicIds: [userId], // Assign to self for testing
      );
      
      _addResult('✅ Request created successfully');
      _addResult('🆔 Request ID: $requestId');
      
    } catch (e) {
      _addResult('❌ Create request failed: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _testUpdateRequest() async {
    setState(() {
      _isLoading = true;
      _testResults = '';
    });

    try {
      _addResult('🧪 Testing Update Request...');
      
      final supabase = Supabase.instance.client;
      
      // Get the first request
      final requests = await supabase
          .from('service_requests')
          .select('*')
          .limit(1);
      
      if (requests.isEmpty) {
        _addResult('❌ No requests found to update');
        return;
      }
      
      final request = requests.first;
      final requestId = request['id'] as String;
      
      _addResult('📋 Found request: $requestId');
      _addResult('📊 Current status: ${request['status']}');
      _addResult('📊 Current accepted_mechanic_id: ${request['accepted_mechanic_id']}');
      
      // Test update
      await _requestService.updateRequestStatus(
        requestId,
        'in_progress',
        acceptedMechanicId: 'test-mechanic-id',
      );
      
      _addResult('✅ Update request successful');
      
      // Verify update
      final updatedRequest = await supabase
          .from('service_requests')
          .select('*')
          .eq('id', requestId)
          .single();
      
      _addResult('✅ Verification successful');
      _addResult('📊 New status: ${updatedRequest['status']}');
      _addResult('📊 New accepted_mechanic_id: ${updatedRequest['accepted_mechanic_id']}');
      
    } catch (e) {
      _addResult('❌ Update request failed: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _testCompleteFlow() async {
    setState(() {
      _isLoading = true;
      _testResults = '';
    });

    try {
      _addResult('🧪 Testing Complete Flow...');
      
      final authService = Provider.of<AuthService>(context, listen: false);
      final supabase = Supabase.instance.client;
      
      // Step 1: Create a request
      _addResult('📝 Step 1: Creating request...');
      final requestId = await _requestService.createServiceRequest(
        userId: authService.currentUser!.id,
        userName: 'Flow Test User',
        userPhone: '9876543210',
        userLocation: 'Flow Test Location',
        userAddress: 'Flow Test Address',
        issueDescription: 'Flow Test Issue',
        vehicleType: 'Flow Test Vehicle',
        vehicleModel: 'Flow Test Model',
        mechanicIds: [authService.currentUser!.id],
      );
      _addResult('✅ Request created: $requestId');
      
      // Step 2: Update to in_progress
      _addResult('🔄 Step 2: Updating to in_progress...');
      await _requestService.updateRequestStatus(
        requestId,
        'in_progress',
        acceptedMechanicId: authService.currentUser!.id,
      );
      _addResult('✅ Updated to in_progress');
      
      // Step 3: Update to completed
      _addResult('✅ Step 3: Updating to completed...');
      await _requestService.updateRequestStatus(
        requestId,
        'completed',
        acceptedMechanicId: authService.currentUser!.id,
      );
      _addResult('✅ Updated to completed');
      
      // Step 4: Verify final state
      _addResult('🔍 Step 4: Verifying final state...');
      final finalRequest = await supabase
          .from('service_requests')
          .select('*')
          .eq('id', requestId)
          .single();
      
      _addResult('✅ Final verification complete');
      _addResult('📊 Final status: ${finalRequest['status']}');
      _addResult('📊 Final accepted_mechanic_id: ${finalRequest['accepted_mechanic_id']}');
      _addResult('📊 Final user_name: ${finalRequest['user_name']}');
      
      _addResult('🎉 Complete flow test successful!');
      
    } catch (e) {
      _addResult('❌ Complete flow test failed: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
