import 'dart:math';
import 'dart:typed_data';

import 'package:animalcare/models/appointment.dart';
import 'package:animalcare/screens/user_dashboard/pets.dart';
import 'package:animalcare/services/auth_service.dart';
import 'package:animalcare/services/pet_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppointmentService {
  final CollectionReference appointmentsCollection =
      FirebaseFirestore.instance.collection('appointments');
  final AuthService _authService = AuthService();

  // Create a new appointment
  Future<String> addAppointment(DateTime dateTime, String petId) async {
    try {
      DocumentReference appointmentRef = await appointmentsCollection.add({
        'userUid': _authService.uid,
        'appointmentDate': dateTime,
        'status': 'Pending',
        'seen': false,
        'petId': petId,
      });

      // Return the ID of the added appointment
      return "Appointment successfully added";
    } catch (e) {
      return "Error adding appointment: $e";
    }
  }

  Future<String> addManualAppointment(
      DateTime dateTime, String uuid, String petId) async {
    try {
      await appointmentsCollection.add({
        'userUid': uuid,
        'appointmentDate': dateTime,
        'status': 'Pending',
        'seen': false,
        'petId': petId,
      });

      // Return the ID of the added appointment
      return "Appointment successfully added";
    } catch (e) {
      return "Error adding appointment: $e";
    }
  }

  // Get all appointments for a specific user
  Stream<List<AppointmentModel>> getAppointmentsByUser(String userUid) {
    return appointmentsCollection
        .where('userUid', isEqualTo: userUid)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return AppointmentModel(
          uid: doc.id,
          userUid: data['userUid'],
          appointmentDate: (data['appointmentDate'] as Timestamp).toDate(),
          status: data['status'],
          seen: data['seen'],
          petId: data['petId'],
        );
      }).toList();
    });
  }

  // Update an existing appointment
  Future<void> updateAppointment(AppointmentModel appointment) async {
    try {
      await appointmentsCollection.doc(appointment.userUid).update({
        'appointmentDate': appointment.appointmentDate,
        'status': appointment.status,
        'seen': appointment.seen,
        'petId': appointment.petId,
      });
    } catch (e) {
      print('Error updating appointment: $e');
    }
  }

  // Delete an existing appointment
  Future<void> deleteAppointment(String appointmentId) async {
    try {
      await appointmentsCollection.doc(appointmentId).delete();
    } catch (e) {
      print('Error deleting appointment: $e');
    }
  }

  // Get all appointments for the currently logged-in user
  Stream<List<AppointmentModel>> getAllMyAppointments() {
    String currentUserUid = _authService.uid!;

    return appointmentsCollection
        .where('userUid', isEqualTo: currentUserUid)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return AppointmentModel(
          uid: doc.id,
          userUid: data['userUid'],
          appointmentDate: (data['appointmentDate'] as Timestamp).toDate(),
          status: data['status'],
          seen: data['seen'],
          petId: data['petId'],
        );
      }).toList();
    });
  }

  Stream<List<AppointmentModel>> getAppointmentsByStatus(String status) {
    print(status);
    return appointmentsCollection
        .where('status', isEqualTo: status)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return AppointmentModel(
          uid: doc.id,
          userUid: data['userUid'],
          appointmentDate: (data['appointmentDate'] as Timestamp).toDate(),
          status: data['status'],
          seen: data['seen'],
          petId: data['petId'],
        );
      }).toList();
    });
  }

  Future<void> changeStatusByAppointmentId(
      String appointmentId, String newStatus) async {
    try {
      await appointmentsCollection.doc(appointmentId).update({
        'status': newStatus,
      });
    } catch (e) {
      print('Error changing appointment status: $e');
    }
  }
}
