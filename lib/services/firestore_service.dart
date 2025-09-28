import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Generate a unique chat ID for two users
  String getChatId(String uid1, String uid2) {
    return uid1.compareTo(uid2) < 0 ? '${uid1}_$uid2' : '${uid2}_$uid1';
  }

  // Stream of all users
  Stream<QuerySnapshot> getUsersStream() {
    return _firestore.collection('users').snapshots();
  }

  // Get the last message in a chat
  Future<QuerySnapshot> getLastMessageInChat(String chatId) async {
    return await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();
  }

  // Get chat info including last message
  Future<DocumentSnapshot> getChatInfo(String chatId) async {
    return await _firestore.collection('chats').doc(chatId).get();
  }

  // Add a message to a specific chat
  Future<void> addMessageToChat(String text, String chatId, String userId, String userName, List<String> participants) async {
    if (_auth.currentUser == null) {
      throw Exception('User must be authenticated to send messages');
    }
    await _firestore.collection('chats').doc(chatId).collection('messages').add({
      'userId': userId,
      'userName': userName,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
    });
    // Update the chat document with last message info
    await _firestore.collection('chats').doc(chatId).set({
      'participants': participants,
      'lastMessage': text,
      'lastMessageTime': FieldValue.serverTimestamp(),
      'lastMessageSender': userName,
    }, SetOptions(merge: true));
  }

  // Stream of messages in a specific chat
  Stream<QuerySnapshot> getMessagesInChat(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Update a message in a chat if owned by current user
  Future<void> updateMessageInChat(String chatId, String messageId, String newText) async {
    if (_auth.currentUser == null) {
      throw Exception('User must be authenticated to update messages');
    }
    String currentUserId = _auth.currentUser!.uid;
    DocumentSnapshot doc = await _firestore.collection('chats').doc(chatId).collection('messages').doc(messageId).get();
    if (doc.exists && doc['userId'] == currentUserId) {
      await _firestore.collection('chats').doc(chatId).collection('messages').doc(messageId).update({
        'text': newText,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } else {
      throw Exception('Unauthorized to update this message');
    }
  }

  // Delete a message in a chat if owned by current user
  Future<void> deleteMessageInChat(String chatId, String messageId) async {
    if (_auth.currentUser == null) {
      throw Exception('User must be authenticated to delete messages');
    }
    String currentUserId = _auth.currentUser!.uid;
    DocumentSnapshot doc = await _firestore.collection('chats').doc(chatId).collection('messages').doc(messageId).get();
    if (doc.exists && doc['userId'] == currentUserId) {
      await _firestore.collection('chats').doc(chatId).collection('messages').doc(messageId).delete();
    } else {
      throw Exception('Unauthorized to delete this message');
    }
  }

  // Add a new message
  Future<void> addMessage(String text, String userId, String userName) async {
    if (_auth.currentUser == null) {
      throw Exception('User must be authenticated to send messages');
    }
    await _firestore.collection('messages').add({
      'userId': userId,
      'userName': userName,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // Stream of all messages, ordered by timestamp descending
  Stream<QuerySnapshot> getMessagesStream() {
    return _firestore
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Update a message if owned by current user
  Future<void> updateMessage(String messageId, String newText) async {
    if (_auth.currentUser == null) {
      throw Exception('User must be authenticated to update messages');
    }
    String currentUserId = _auth.currentUser!.uid;
    DocumentSnapshot doc = await _firestore.collection('messages').doc(messageId).get();
    if (doc.exists && doc['userId'] == currentUserId) {
      await _firestore.collection('messages').doc(messageId).update({
        'text': newText,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } else {
      throw Exception('Unauthorized to update this message');
    }
  }

  // Delete a message if owned by current user
  Future<void> deleteMessage(String messageId) async {
    if (_auth.currentUser == null) {
      throw Exception('User must be authenticated to delete messages');
    }
    String currentUserId = _auth.currentUser!.uid;
    DocumentSnapshot doc = await _firestore.collection('messages').doc(messageId).get();
    if (doc.exists && doc['userId'] == currentUserId) {
      await _firestore.collection('messages').doc(messageId).delete();
    } else {
      throw Exception('Unauthorized to delete this message');
    }
  }
}
