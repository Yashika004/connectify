import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import '../screens/chat_screen.dart';
import 'settingsScreen.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();
  String? _userName;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  Future<void> _loadUserName() async {
    if (FirebaseAuth.instance.currentUser != null) {
      Map<String, dynamic>? profile = await _authService.getUserProfile(
        FirebaseAuth.instance.currentUser!.uid,
      );
      if (mounted) {
        setState(() {
          _userName = profile?['name'] ?? 'Anonymous';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Connectify"),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsScreen()),
                );
              },
              child: CircleAvatar(
                radius: 20,
                child: Text(_userName?.substring(0, 1).toUpperCase() ?? '?'),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search users...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: const Color.fromARGB(255, 255, 245, 248),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestoreService.getUsersStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No users found.'));
                }

                final currentUserId = FirebaseAuth.instance.currentUser?.uid;
                final allUsers =
                    snapshot.data!.docs.where((doc) => doc.id != currentUserId).toList();
                final filteredUsers =
                    _searchQuery.isEmpty
                        ? allUsers
                        : allUsers.where((doc) {
                          final userData = doc.data() as Map<String, dynamic>;
                          final name = userData['name'] as String;
                          return name.toLowerCase().contains(_searchQuery);
                        }).toList();

                return ListView.builder(
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    final userDoc = filteredUsers[index];
                    final userData = userDoc.data() as Map<String, dynamic>;
                    final otherUserId = userDoc.id;
                    final otherUserName = userData['name'] as String;
                    final chatId = _firestoreService.getChatId(currentUserId!, otherUserId);

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                      child: FutureBuilder<DocumentSnapshot>(
                        future: _firestoreService.getChatInfo(chatId),
                        builder: (context, chatSnapshot) {
                          String subtitleText = 'No messages yet';
                          String timeStr = '';

                          if (chatSnapshot.hasData && chatSnapshot.data!.exists) {
                            final chatData = chatSnapshot.data!.data() as Map<String, dynamic>;
                            subtitleText = chatData['lastMessage'] ?? 'No messages yet';
                            final timestamp = chatData['lastMessageTime'] as Timestamp?;
                            timeStr =
                                timestamp != null
                                    ? '${timestamp.toDate().hour}:${timestamp.toDate().minute}'
                                    : '';
                          }

                          return ListTile(
                            leading: CircleAvatar(
                              radius: 24,
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              child: Text(
                                otherUserName.substring(0, 1).toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              otherUserName,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(subtitleText, maxLines: 1, overflow: TextOverflow.ellipsis),
                                if (timeStr.isNotEmpty)
                                  Text(
                                    timeStr,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                              ],
                            ),
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => ChatScreen(
                                        otherUserId: otherUserId,
                                        otherUserName: otherUserName,
                                      ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
