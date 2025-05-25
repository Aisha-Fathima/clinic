import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/prescription_provider.dart';
import '../../routes.dart';
import '../../widgets/custom_button.dart';

class UploadPrescriptionScreen extends StatefulWidget {
  final String patientId;
  final String patientName;

  const UploadPrescriptionScreen({
    super.key,
    required this.patientId,
    required this.patientName,
  });

  @override
  State<UploadPrescriptionScreen> createState() => _UploadPrescriptionScreenState();
}

class _UploadPrescriptionScreenState extends State<UploadPrescriptionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  bool _isLoading = false;
  bool _hasAttachment = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _uploadPrescription() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final prescriptionProvider = Provider.of<PrescriptionProvider>(context, listen: false);
      final doctor = authProvider.currentUser!;
      
      // Add prescription
      prescriptionProvider.addPrescription(
        patientId: widget.patientId,
        doctorId: doctor.id,
        doctorName: doctor.name,
        notes: _notesController.text.trim(),
        fileUrl: _hasAttachment ? 'mock_file_url.pdf' : null,
      );
      
      if (!mounted) return;
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Prescription uploaded successfully'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Navigate back to dashboard
      Navigator.of(context).pushReplacementNamed(AppRoutes.doctorDashboard);
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error uploading prescription: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Prescription'),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                          'Patient: ${widget.patientName}',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Notes
                        TextFormField(
                          controller: _notesController,
                          decoration: const InputDecoration(
                            labelText: 'Prescription Notes',
                            alignLabelWithHint: true,
                            hintText: 'Enter prescription details, medications, dosage, etc.',
                          ),
                          maxLines: 5,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter prescription notes';
                            }
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // File upload
                        OutlinedButton.icon(
                          onPressed: () {
                            setState(() {
                              _hasAttachment = true;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('File attached successfully'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          },
                          icon: const Icon(Icons.attach_file),
                          label: Text(_hasAttachment ? 'File Attached' : 'Attach File'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _hasAttachment ? Colors.green : null,
                          ),
                        ),
                        
                        if (_hasAttachment) ...[
                          const SizedBox(height: 16),
                          ListTile(
                            leading: const Icon(Icons.file_present),
                            title: const Text('prescription.pdf'),
                            subtitle: const Text('PDF Document'),
                            trailing: IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                setState(() {
                                  _hasAttachment = false;
                                });
                              },
                            ),
                            tileColor: Colors.grey.shade100,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ],
                        
                        const SizedBox(height: 24),
                        
                        CustomButton(
                          onPressed: _isLoading ? null : _uploadPrescription,
                          isLoading: _isLoading,
                          text: 'Upload Prescription',
                          icon: Icons.upload_file,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
