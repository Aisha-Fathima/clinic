import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../providers/auth_provider.dart';
import '../../providers/queue_provider.dart';
import '../../routes.dart';
import '../../widgets/dashboard_card.dart';
import '../../widgets/app_drawer.dart';

class PatientDashboard extends StatelessWidget {
  const PatientDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final queueProvider = Provider.of<QueueProvider>(context);
    final user = authProvider.currentUser!;
    
    // Check if patient is already in queue
    final waitingAppointment = queueProvider.getPatientWaitingAppointment(user.id);
    final isInQueue = waitingAppointment != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Dashboard'),
        elevation: 0,
      ),
      drawer: const AppDrawer(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome section
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
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
                              'Welcome back,',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            Text(
                              user.name,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Queue status card (if in queue)
              if (isInQueue)
                Card(
                  elevation: 2,
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
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
                            Icon(
                              Icons.access_time,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'You are in queue',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Doctor: ${waitingAppointment.doctorName}',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Time: ${waitingAppointment.formattedTime}',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          waitingAppointment.isEmergency ? 'Priority: Emergency' : 'Priority: Regular',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: waitingAppointment.isEmergency ? Colors.red : null,
                            fontWeight: waitingAppointment.isEmergency ? FontWeight.bold : null,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pushNamed(AppRoutes.liveQueue);
                          },
                          icon: const Icon(Icons.visibility),
                          label: const Text('View Queue Status'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              
              const SizedBox(height: 24),
              
              Text(
                'Quick Actions',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Dashboard cards
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  DashboardCard(
                    title: 'Book a Slot',
                    icon: FontAwesomeIcons.calendarPlus,
                    color: const Color(0xFF4A90E2),
                    onTap: isInQueue
                        ? () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('You already have an active appointment'),
                                backgroundColor: Colors.orange,
                              ),
                            );
                          }
                        : () {
                            Navigator.of(context).pushNamed(AppRoutes.bookSlot);
                          },
                  ),
                  DashboardCard(
                    title: 'View Queue',
                    icon: FontAwesomeIcons.userClock,
                    color: const Color(0xFF50C878),
                    onTap: () {
                      Navigator.of(context).pushNamed(AppRoutes.liveQueue);
                    },
                  ),
                  DashboardCard(
                    title: 'Prescriptions',
                    icon: FontAwesomeIcons.filePrescription,
                    color: const Color(0xFFFFA500),
                    onTap: () {
                      Navigator.of(context).pushNamed(AppRoutes.pastPrescriptions);
                    },
                  ),
                  DashboardCard(
                    title: 'Logout',
                    icon: FontAwesomeIcons.rightFromBracket,
                    color: Colors.grey,
                    onTap: () {
                      authProvider.logout();
                      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
