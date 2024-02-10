import 'package:animalcare/screens/wrapper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:animalcare/models/announcement.dart';
import 'package:animalcare/services/announcement_service.dart';
import 'package:animalcare/services/auth_service.dart';

class AnnouncementAdmin extends StatefulWidget {
  const AnnouncementAdmin({super.key});

  @override
  // ignore: library_private_types_in_public_api
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
            icon: const Icon(Icons.logout),
            onPressed: () {
              _authService.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const Wrapper()),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Announcement>>(
        future: _announcementService.getAllAnnouncements(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No announcements found.'));
          } else {
            List<Announcement> announcements = snapshot.data!;

            return ListView.builder(
              itemCount: announcements.length,
              itemBuilder: (context, index) {
                Announcement announcement = announcements[index];
                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    leading: const Icon(Icons.newspaper),
                    title: Text(
                      announcement.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      announcement.content,
                      style: const TextStyle(fontSize: 16),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditAnnouncementWidget(
                                  announcement: announcement,
                                  onUpdate: () {
                                    setState(() {});
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () async {
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
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddAnnouncementWidget(
                onAdd: () {
                  setState(() {});
                },
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AddAnnouncementWidget extends StatefulWidget {
  final Function onAdd;

  const AddAnnouncementWidget({super.key, required this.onAdd});

  @override
  State<AddAnnouncementWidget> createState() => _AddAnnouncementWidgetState();
}

class _AddAnnouncementWidgetState extends State<AddAnnouncementWidget> {
  final AnnouncementService _announcementService = AnnouncementService();

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();
    final formKey = GlobalKey<FormState>();
    final TextEditingController titleController = TextEditingController();
    final TextEditingController contentController = TextEditingController();
    bool isLoading = false;
    void submit() async {
      setState(() {
        isLoading = true;
      });
      if (formKey.currentState!.validate()) {
        try {
          await _announcementService.addAnnouncement(
            ownerUid: authService.uid!,
            title: titleController.text,
            content: contentController.text,
          );
          widget.onAdd();
          setState(() {
            isLoading = false;
            titleController.clear();
            contentController.clear();
          });
          // ignore: use_build_context_synchronously
          Navigator.pop(context);
        } catch (e) {
          if (kDebugMode) {
            print('Error adding doctor: $e');
          }
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Announcement'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please add title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: contentController,
                decoration: const InputDecoration(labelText: 'Content'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please add content';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () async {
                  // Add the announcement and invoke the callback
                  submit();
                },
                child: isLoading
                    ? const CircularProgressIndicator()
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

  const EditAnnouncementWidget(
      {super.key, required this.announcement, required this.onUpdate});

  @override
  // ignore: library_private_types_in_public_api
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
        title: const Text('Edit Announcement'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
              onChanged: (value) {
                // Handle title change
              },
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(labelText: 'Content'),
              onChanged: (value) {},
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                await _announcementService.updateAnnouncement(
                  announcementId: widget.announcement.uid,
                  ownerUid: widget.announcement.ownerUid,
                  title: _titleController.text,
                  content: _contentController.text,
                );
                widget.onUpdate();
                // ignore: use_build_context_synchronously
                Navigator.pop(context);
              },
              child: const Text('Update Announcement'),
            ),
          ],
        ),
      ),
    );
  }
}
