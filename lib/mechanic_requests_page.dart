import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_service.dart';
import 'models/request_model.dart';
import 'services/request_service.dart';

class MechanicRequestsPage extends StatefulWidget {
  const MechanicRequestsPage({super.key});

  @override
  _MechanicRequestsPageState createState() => _MechanicRequestsPageState();
}

class _MechanicRequestsPageState extends State<MechanicRequestsPage> {
  List<ServiceRequest> _requests = []; // Fixed: Properly declared
  bool _isLoading = true;
  final RequestService _requestService = RequestService();

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    
    try {
      final requests = await _requestService.getMechanicRequests(authService.currentUser!.id);
      setState(() {
        // Only show pending requests in the requests panel
        // Accepted/In-progress requests should be in "My Requests" page
        _requests = requests.where((r) => r.status == 'pending').toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading requests: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _acceptRequest(ServiceRequest request) async {
    try {
      print('🚀 Starting to accept request: ${request.id}');
      
      final authService = Provider.of<AuthService>(context, listen: false);
      final mechanicId = authService.currentUser!.id;
      
      print('👨‍🔧 Mechanic ID: $mechanicId');
      print('📋 Current request status: ${request.status}');
      print('📋 Current accepted_mechanic_id: ${request.acceptedMechanicId}');
      
      // When mechanic accepts, set to 'in_progress' and assign the mechanic
      await _requestService.updateRequestStatus(
        request.id, 
        'in_progress',
        acceptedMechanicId: mechanicId,
      );

      print('✅ Request status updated successfully');

      // Notify user
      await _requestService.createNotification(
        userId: request.userId,
        title: 'Request Accepted - Work in Progress',
        message: 'Your service request has been accepted and the mechanic is on their way!',
        type: 'acceptance',
        relatedRequestId: request.id,
      );

      print('✅ Notification sent to user');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Request accepted! Work started. User has been notified.'),
            backgroundColor: Colors.green,
          ),
        );
      }

      // Refresh list to remove the accepted request
      await _loadRequests();
      
      print('✅ Request list refreshed');
    } catch (e) {
      print('❌ Error accepting request: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error accepting request: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _rejectRequest(ServiceRequest request) async {
    try {
      await _requestService.updateRequestStatus(request.id, 'rejected');
      _loadRequests(); // Refresh list
    } catch (e) {
      print('Error rejecting request: $e');
    }
  }

  Widget _buildRequestCard(ServiceRequest request) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Request from ${request.userName}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Phone: ${request.userPhone}'),
            Text('Location: ${request.userLocation}'),
            Text('Vehicle: ${request.vehicleType} ${request.vehicleModel}'),
            const SizedBox(height: 8),
            Text(
              'Issue: ${request.issueDescription}',
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 16),
            if (request.status == 'pending')
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _acceptRequest(request),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      child: const Text('Accept'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _rejectRequest(request),
                      child: const Text('Reject'),
                    ),
                  ),
                ],
              )
            else if (request.status != 'pending')
              Text(
                'Status: ${request.status.toUpperCase().replaceAll('_', ' ')}',
                style: TextStyle(
                  color: request.status == 'in_progress' ? Colors.orange : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Service Requests'),
        actions: [
          // Debug button to test database update
          if (_requests.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.bug_report),
              onPressed: () async {
                try {
                  await _requestService.testUpdateRequestStatus(_requests.first.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Test completed - check console logs')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Test failed: $e')),
                  );
                }
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _requests.isEmpty
              ? const Center(child: Text('No service requests yet'))
              : RefreshIndicator(
                  onRefresh: _loadRequests,
                  child: ListView.builder(
                    itemCount: _requests.length,
                    itemBuilder: (context, index) => _buildRequestCard(_requests[index]),
                  ),
                ),
    );
  }
}