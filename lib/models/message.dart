import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String senderId;
  final String recieverId;
  final String messageContent;
  final Timestamp timestamp;
  bool seen;

  Message({
    required this.senderId,
    required this.recieverId,
    required this.messageContent,
    required this.timestamp,
    this.seen = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'recieverId': recieverId,
      'messageContent': messageContent,
      'timestamp': timestamp,
      'seen': seen,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      senderId: map['senderId'],
      recieverId: map['recieverId'],
      messageContent: map['messageContent'],
      timestamp: map['timestamp'],
      seen: map['seen'] ?? false,
    );
  }
}
