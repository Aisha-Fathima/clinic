import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../providers/auth_provider.dart';
import '../../providers/queue_provider.dart';
import '../../routes.dart';
import '../../models/appointment.dart';
import '../../widgets/custom_button.dart';

class DoctorQueueScreen extends StatefulWidget {
  final String doctorId;
  final String doctorName;

  const DoctorQueueScreen({
    super.key,
    required this.doctorId,
    required this.doctorName,
  });

  @override
  State<DoctorQueueScreen> createState() => _DoctorQueueScreenState();
}

class _DoctorQueueScreenState extends State<DoctorQueueScreen> {
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _isEmergency = false;
  bool _isLoading = false;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _bookSlot() async {
    setState(() => _isLoading = true);
    
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final queueProvider = Provider.of<QueueProvider>(context, listen: false);
      final user = authProvider.currentUser!;
      
      // Combine date and time
      final dateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );
      
      // Add to queue
      queueProvider.addAppointment(
        patientId: user.id,
        patientName: user.name,
        doctorId: widget.doctorId,
        doctorName: widget.doctorName,
        dateTime: dateTime,
        isEmergency: _isEmergency,
      );
      
      if (!mounted) return;
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Appointment booked successfully'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Navigate to queue screen
      Navigator.of(context).pushReplacementNamed(AppRoutes.liveQueue);
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error booking appointment: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final queueProvider = Provider.of<QueueProvider>(context);
    final doctorQueue = queueProvider.getDoctorWaitingAppointments(widget.doctorId);
    final averageWaitTime = queueProvider.getAverageWaitTimeForDoctor(widget.doctorId);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Dr. ${widget.doctorName.split(' ').last}\'s Queue'),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Doctor info card
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
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                            child: Icon(
                              Icons.person,
                              size: 30,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.doctorName,
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Current Queue: ${doctorQueue.length} patients',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                                Text(
                                  'Estimated Wait: ~$averageWaitTime minutes',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Current queue
              Text(
                'Current Queue',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 16),
              
              if (doctorQueue.isEmpty)
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Column(
                        children: [
                          const Icon(
                            Icons.check_circle_outline,
                            size: 48,
                            color: Colors.green,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No patients in queue',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'This is a great time to book!',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: doctorQueue.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final appointment = doctorQueue[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: appointment.isEmergency
                              ? Colors.red
                              : Colors.grey.shade200,
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: appointment.isEmergency ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          appointment.patientName,
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
              
              const SizedBox(height: 24),
              
              // Book appointment section
              Text(
                'Book an Appointment',
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
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Date selection
                      InkWell(
                        onTap: () => _selectDate(context),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Date',
                            prefixIcon: Icon(Icons.calendar_today),
                          ),
                          child: Text(
                            DateFormat('EEEE, MMM dd, yyyy').format(_selectedDate),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Time selection
                      InkWell(
                        onTap: () => _selectTime(context),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Time',
                            prefixIcon: Icon(Icons.access_time),
                          ),
                          child: Text(
                            _selectedTime.format(context),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Emergency checkbox
                      CheckboxListTile(
                        title: const Text('Emergency'),
                        subtitle: const Text('Check this if you need urgent care'),
                        value: _isEmergency,
                        onChanged: (value) {
                          setState(() {
                            _isEmergency = value!;
                          });
                        },
                        activeColor: Theme.of(context).colorScheme.primary,
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                      
                      const SizedBox(height: 24),
                      
                      CustomButton(
                        onPressed: _isLoading ? null : _bookSlot,
                        isLoading: _isLoading,
                        text: 'Book Appointment',
                        icon: Icons.check_circle,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
