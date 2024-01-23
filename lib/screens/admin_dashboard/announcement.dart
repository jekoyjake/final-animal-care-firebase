import 'package:flutter/material.dart';
import 'package:animalcare/models/announcement.dart';
import 'package:animalcare/services/announcement_service.dart';
import 'package:animalcare/services/auth_service.dart';

class AnnouncementAdmin extends StatefulWidget {
  @override
  _AnnouncementAdminState createState() => _AnnouncementAdminState();
}

class _AnnouncementAdminState extends State<AnnouncementAdmin> {
  final AnnouncementService _announcementService = AnnouncementService();
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Announcements"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _authService.signOut();
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Announcement>>(
        future: _announcementService.getAllAnnouncements(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No announcements found.'));
          } else {
            List<Announcement> announcements = snapshot.data!;

            return ListView.builder(
              itemCount: announcements.length,
              itemBuilder: (context, index) {
                Announcement announcement = announcements[index];
                return Card(
                  elevation: 3,
                  margin: EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(
                      announcement.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      announcement.content,
                      style: TextStyle(fontSize: 16),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            // Navigate to the edit screen
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditAnnouncementWidget(
                                  announcement: announcement,
                                  onUpdate: () {
                                    // Refresh the list after updating
                                    setState(() {});
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () async {
                            // Delete the announcement and refresh the list
                            await _announcementService
                                .deleteAnnouncement(announcement.uid);
                            setState(() {});
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to the add screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddAnnouncementWidget(
                onAdd: () {
                  // Refresh the list after adding
                  setState(() {});
                },
              ),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class AddAnnouncementWidget extends StatefulWidget {
  final Function onAdd;

  AddAnnouncementWidget({required this.onAdd});

  @override
  State<AddAnnouncementWidget> createState() => _AddAnnouncementWidgetState();
}

class _AddAnnouncementWidgetState extends State<AddAnnouncementWidget> {
  final AnnouncementService _announcementService = AnnouncementService();

  @override
  Widget build(BuildContext context) {
    final AuthService _authService = AuthService();
    final _formKey = GlobalKey<FormState>();
    final TextEditingController _titleController = TextEditingController();
    final TextEditingController _contentController = TextEditingController();
    bool isLoading = false;
    void _submit() async {
      setState(() {
        isLoading = true;
      });
      if (_formKey.currentState!.validate()) {
        try {
          await _announcementService.addAnnouncement(
            ownerUid: _authService.uid!,
            title: _titleController.text,
            content: _contentController.text,
          );
          widget.onAdd();
          setState(() {
            isLoading = false;
            _titleController.clear();
            _contentController.clear();
          });
          Navigator.pop(context);
        } catch (e) {
          // Handle errors
          print('Error adding doctor: $e');
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Add Announcement'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please add title';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _contentController,
                decoration: InputDecoration(labelText: 'Content'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please add content';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () async {
                  // Add the announcement and invoke the callback
                  _submit();
                },
                child: isLoading
                    ? CircularProgressIndicator()
                    : const Text('Add Announcement'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EditAnnouncementWidget extends StatefulWidget {
  final Announcement announcement;
  final Function onUpdate;

  EditAnnouncementWidget({required this.announcement, required this.onUpdate});

  @override
  _EditAnnouncementWidgetState createState() => _EditAnnouncementWidgetState();
}

class _EditAnnouncementWidgetState extends State<EditAnnouncementWidget> {
  final AnnouncementService _announcementService = AnnouncementService();
  late TextEditingController _titleController;
  late TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.announcement.title);
    _contentController =
        TextEditingController(text: widget.announcement.content);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Announcement'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
              onChanged: (value) {
                // Handle title change
              },
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _contentController,
              decoration: InputDecoration(labelText: 'Content'),
              onChanged: (value) {
                // Handle content change
              },
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                // Update the announcement and invoke the callback
                await _announcementService.updateAnnouncement(
                  announcementId: widget.announcement.uid,
                  ownerUid: widget.announcement.ownerUid,
                  title: _titleController.text,
                  content: _contentController.text,
                );
                widget.onUpdate();
                Navigator.pop(context);
              },
              child: Text('Update Announcement'),
            ),
          ],
        ),
      ),
    );
  }
}
