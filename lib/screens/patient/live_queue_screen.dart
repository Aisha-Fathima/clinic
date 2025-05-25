import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import '../../providers/auth_provider.dart';
import '../../providers/queue_provider.dart';
import '../../widgets/queue_position_indicator.dart';

class LiveQueueScreen extends StatefulWidget {
  const LiveQueueScreen({super.key});

  @override
  State<LiveQueueScreen> createState() => _LiveQueueScreenState();
}

class _LiveQueueScreenState extends State<LiveQueueScreen> with SingleTickerProviderStateMixin {
  late Timer _timer;
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _showAlert = false;

  @override
  void initState() {
    super.initState();
    
    // Set up animation for alert
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    // Set up timer to refresh queue position
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        setState(() {});
        
        // Check if position is <= 2 to show alert
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final queueProvider = Provider.of<QueueProvider>(context, listen: false);
        final position = queueProvider.getPatientPosition(authProvider.currentUser!.id);
        
        if (position <= 2 && position > 0) {
          setState(() {
            _showAlert = true;
          });
          _animationController.reset();
          _animationController.forward();
        } else {
          setState(() {
            _showAlert = false;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final queueProvider = Provider.of<QueueProvider>(context);
    final user = authProvider.currentUser!;
    
    // Get patient's position in queue
    final position = queueProvider.getPatientPosition(user.id);
    final waitingAppointment = queueProvider.getPatientWaitingAppointment(user.id);
    final averageWaitTime = queueProvider.getAverageWaitTime();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Queue Status'),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Alert banner
              if (_showAlert)
                FadeTransition(
                  opacity: _animation,
                  child: Card(
                    color: Colors.amber.shade100,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.amber.shade700),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.amber.shade800,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Your turn is coming up soon! Please be ready.',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.amber.shade900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              
              const SizedBox(height: 24),
              
              if (position > 0)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Queue Status',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Queue position indicator
                    Center(
                      child: QueuePositionIndicator(position: position),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Queue details
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Appointment Details',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            
                            const SizedBox(height: 16),
                            
                            if (waitingAppointment != null) ...[
                              _buildDetailRow(
                                context,
                                'Doctor',
                                waitingAppointment.doctorName,
                                Icons.person,
                              ),
                              const SizedBox(height: 8),
                              _buildDetailRow(
                                context,
                                'Date',
                                waitingAppointment.formattedDate,
                                Icons.calendar_today,
                              ),
                              const SizedBox(height: 8),
                              _buildDetailRow(
                                context,
                                'Time',
                                waitingAppointment.formattedTime,
                                Icons.access_time,
                              ),
                              const SizedBox(height: 8),
                              _buildDetailRow(
                                context,
                                'Priority',
                                waitingAppointment.isEmergency ? 'Emergency' : 'Regular',
                                Icons.priority_high,
                                valueColor: waitingAppointment.isEmergency ? Colors.red : null,
                              ),
                              const SizedBox(height: 8),
                              _buildDetailRow(
                                context,
                                'Estimated Wait',
                                '$averageWaitTime minutes',
                                Icons.hourglass_bottom,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              else
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.info_outline,
                        size: 80,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'You are not in the queue',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Book an appointment to join the queue',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Go Back'),
                      ),
                    ],
                  ),
                ),
              
              const SizedBox(height: 24),
              
              // Current queue
              if (position > 0)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Queue',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: queueProvider.waitingAppointments.length,
                        separatorBuilder: (context, index) => const Divider(),
                        itemBuilder: (context, index) {
                          final appointment = queueProvider.waitingAppointments[index];
                          final isCurrentUser = appointment.patientId == user.id;
                          
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isCurrentUser
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.grey.shade200,
                              child: Text(
                                '${index + 1}',
                                style: TextStyle(
                                  color: isCurrentUser ? Colors.white : Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              appointment.patientName,
                              style: TextStyle(
                                fontWeight: isCurrentUser ? FontWeight.bold : null,
                              ),
                            ),
                            subtitle: Text(appointment.formattedTime),
                            trailing: appointment.isEmergency
                                ? Chip(
                                    label: const Text(
                                      'Emergency',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                    backgroundColor: Colors.red,
                                  )
                                : null,
                          );
                        },
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Colors.grey,
        ),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
