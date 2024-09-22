import 'package:cloud_firestore/cloud_firestore.dart'; // Add Firestore import
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:video_conference/ui/Pages/dash_board.dart';

class ScheduleMeetingPage extends StatefulWidget {
  @override
  _ScheduleMeetingPageState createState() => _ScheduleMeetingPageState();
}

class _ScheduleMeetingPageState extends State<ScheduleMeetingPage> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _meetingTitle;
  String? _meetingDescription;
  final List<String> _participants = [];
  List<XFile>? _imageFiles; // For selected images

  final ImagePicker _picker = ImagePicker();

  Future<void> _selectImages() async {
    final List<XFile> selectedImages = await _picker.pickMultiImage();
    setState(() {
      _imageFiles = selectedImages;
    });
  }

  // For selecting the date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // For selecting the time
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _saveMeeting() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final formattedDate = _selectedDate != null
          ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
          : null;
      final formattedTime = _selectedTime != null
          ? '${_selectedTime!.hour}:${_selectedTime!.minute}'
          : null;

      // Prepare image URLs for Firestore (upload images as needed)
      List<String> imageUrls = [];
      if (_imageFiles != null) {
        for (var file in _imageFiles!) {
          // You might want to upload these images to a storage service
          // and get the URLs, here we just add the file paths as an example
          imageUrls.add(file.path);
        }
      }

      final meetingData = {
        'title': _meetingTitle,
        'description': _meetingDescription,
        'date': formattedDate,
        'time': formattedTime,
        'participants': _participants,
        'images': imageUrls,
        'created_at': FieldValue.serverTimestamp(),
      };

      try {
        await FirebaseFirestore.instance
            .collection('meetings')
            .add(meetingData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Meeting saved successfully!')),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const DashBoard(initialIndex: 0),
          ),
          (route) => false,
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save meeting: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 2,
        backgroundColor: const Color(0xff3a57e8),
        iconTheme: const IconThemeData(color: Colors.white),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
        ),
        title: const Text('Schedule Meeting',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Meeting Title
              Card(
                elevation: 1,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Meeting Details",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        style: const TextStyle(
                          color: Colors.black,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Meeting Title',
                          border: OutlineInputBorder(),
                          labelStyle: TextStyle(
                            color: Colors.black,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.blue, width: 2.0),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a title';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _meetingTitle = value;
                        },
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        style: const TextStyle(
                          color: Colors.black,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Meeting Description',
                          labelStyle: TextStyle(
                            color: Colors.black,
                          ),
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.blue, width: 2.0),
                          ),
                        ),
                        maxLines: 3,
                        onSaved: (value) {
                          _meetingDescription = value;
                        },
                      ),
                      const SizedBox(height: 16.0),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16.0),

              // Date Picker
              Card(
                elevation: 2,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0)),
                child: ListTile(
                  title: Text(
                    _selectedDate == null
                        ? 'Select Date'
                        : DateFormat.yMMMd().format(_selectedDate!),
                    style: const TextStyle(
                      color: Colors.black,
                    ),
                  ),
                  trailing:
                      const Icon(Icons.calendar_today, color: Colors.blue),
                  onTap: () => _selectDate(context),
                ),
              ),
              const SizedBox(height: 16.0),

              // Time Picker
              Card(
                elevation: 2,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0)),
                child: ListTile(
                  title: Text(
                    _selectedTime == null
                        ? 'Select Time'
                        : _selectedTime!.format(context),
                    style: const TextStyle(
                      color: Colors.black,
                    ),
                  ),
                  trailing: const Icon(Icons.access_time, color: Colors.blue),
                  onTap: () => _selectTime(context),
                ),
              ),
              const SizedBox(height: 16.0),

              // Image Picker
              Card(
                elevation: 2,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0)),
                child: ListTile(
                  title: const Text(
                    'Select Images',
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                  trailing: const Icon(Icons.image, color: Colors.blue),
                  onTap: _selectImages,
                ),
              ),
              const SizedBox(height: 16.0),

              // Save Button
              ElevatedButton(
                onPressed: _saveMeeting,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0)),
                  elevation: 4.0,
                ),
                child: const Text(
                  'Save Meeting',
                  style: TextStyle(fontSize: 16.0, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
