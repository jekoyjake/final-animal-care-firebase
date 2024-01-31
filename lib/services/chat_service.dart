import 'package:animalcare/models/message.dart';
import 'package:animalcare/services/auth_service.dart';
import 'package:animalcare/services/user_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//send message

  Future<void> sendMessageToDoctor(String message) async {
    final String currentUserId = _auth.currentUser!.uid;
    final Timestamp timestamp = Timestamp.now();

    Message newMessage = Message(
      senderId: currentUserId,
      recieverId: "DOCTOR",
      messageContent: message,
      timestamp: timestamp,
    );

    //Generate Chatroom ID
    List<String> ids = [currentUserId, "DOCTOR"];
    ids.sort();
    String chatRoomId = ids.join("_");

    await _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .add(newMessage.toMap());
  }

  Future<void> sendMessageToClient(String recieverId, String message) async {
    final Timestamp timestamp = Timestamp.now();

    Message messageToClient = Message(
        senderId: "DOCTOR",
        recieverId: recieverId,
        messageContent: message,
        timestamp: timestamp);

    List<String> ids = ["DOCTOR", recieverId];
    ids.sort();
    String chatId = ids.join("_");

    await _firestore
        .collection('chat_rooms')
        .doc(chatId)
        .collection('messages')
        .add(messageToClient.toMap());
  }

  Stream<QuerySnapshot> getMessagesForDoctor(String clientUserId) {
    List<String> ids = ["DOCTOR", clientUserId];
    ids.sort();
    String chatRooomId = ids.join("_");
    markMessagesAsSeenBySenderId(chatRooomId, clientUserId);

    return _firestore
        .collection('chat_rooms')
        .doc(chatRooomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  Stream<int> streamUnseenMessagesCount(String clientId) {
    List<String> ids = ["DOCTOR", clientId];
    ids.sort();
    String chatRoomId = ids.join("_");
    // Get the reference to the messages collection
    CollectionReference messagesCollection = _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages');

    // Return a stream that listens for changes in the collection
    return messagesCollection.snapshots().map((querySnapshot) {
      int unseenMessageCount = 0;

      // Iterate through the documents and count messages with seen = false for a specific senderId
      for (QueryDocumentSnapshot messageSnapshot in querySnapshot.docs) {
        // Check if the senderId of the current message matches the given senderId and if seen is false
        if (messageSnapshot['senderId'] == clientId &&
            messageSnapshot['seen'] == false) {
          unseenMessageCount++;
        }
      }

      return unseenMessageCount;
    });
  }

  Future<void> markMessagesAsSeenBySenderId(
      String chatId, String senderId) async {
    try {
      // Get the reference to the messages collection
      CollectionReference messagesCollection = _firestore
          .collection('chat_rooms')
          .doc(chatId)
          .collection('messages');

      // Fetch all messages in the collection
      QuerySnapshot querySnapshot = await messagesCollection.get();

      // Iterate through the documents and update the seen field for messages with a specific senderId
      for (QueryDocumentSnapshot messageSnapshot in querySnapshot.docs) {
        // Check if the senderId of the current message matches the given senderId
        if (messageSnapshot['senderId'] == senderId) {
          await messagesCollection
              .doc(messageSnapshot.id)
              .update({'seen': true});
        }
      }
    } catch (error) {
      return;
    }
  }

  Stream<QuerySnapshot> getMessagesForClient(String userId) {
    List<String> ids = [userId, "DOCTOR"];
    ids.sort();
    String chatRooomId = ids.join("_");
    markMessagesAsSeenBySenderId(chatRooomId, "DOCTOR");

    return _firestore
        .collection('chat_rooms')
        .doc(chatRooomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  Future<bool> hasMessages(String userId) async {
    try {
      List<String> ids = ["DOCTOR", userId];
      ids.sort();
      String chatRoomId = ids.join("_");

      // Get the reference to the messages collection
      CollectionReference messagesCollection = _firestore
          .collection('chat_rooms')
          .doc(chatRoomId)
          .collection('messages');

      // Fetch all messages in the collection
      QuerySnapshot querySnapshot = await messagesCollection.get();

      // Check if there are any messages for the user
      return querySnapshot.docs.isNotEmpty;
    } catch (error) {
      // Handle errors, e.g., log or throw an exception
      print('Error checking messages: $error');
      return false;
    }
  }
}
