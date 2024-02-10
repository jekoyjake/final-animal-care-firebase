import 'dart:collection';

import 'package:animalcare/models/appointment.dart';
import 'package:animalcare/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class AppointmentService {
  final CollectionReference appointmentsCollection =
      FirebaseFirestore.instance.collection('appointments');
  final AuthService _authService = AuthService();

  // Create a new appointment
  Future<String> addAppointment(DateTime dateTime, String petId) async {
    try {
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
      if (kDebugMode) {
        print('Error updating appointment: $e');
      }
    }
  }

  // Delete an existing appointment
  Future<void> deleteAppointment(String appointmentId) async {
    try {
      await appointmentsCollection.doc(appointmentId).delete();
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting appointment: $e');
      }
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

  Future<void> deleteAppointmentByPetId(String petId) async {
    try {
      // Query appointments by petId
      QuerySnapshot querySnapshot =
          await appointmentsCollection.where('petId', isEqualTo: petId).get();

      // Iterate through each appointment and delete it
      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting appointments by petId: $e');
      }
    }
  }

  Future<void> changeStatusByAppointmentId(
      String appointmentId, String newStatus) async {
    try {
      await appointmentsCollection.doc(appointmentId).update({
        'status': newStatus,
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error changing appointment status: $e');
      }
    }
  }

  Future<Map<DateTime, int>> getAppointmentDatesChartData(
      DateTime selectedMonth) async {
    try {
      DateTime startOfMonth = DateTime(selectedMonth.year, selectedMonth.month);
      DateTime endOfMonth =
          DateTime(selectedMonth.year, selectedMonth.month + 1, 0);

      QuerySnapshot querySnapshot = await appointmentsCollection
          .where('appointmentDate', isGreaterThanOrEqualTo: startOfMonth)
          .where('appointmentDate', isLessThanOrEqualTo: endOfMonth)
          .get();

      Map<DateTime, int> appointmentCounts = <DateTime, int>{};

      // Initialize appointmentCounts with all days in the selected month
      for (int i = 1; i <= endOfMonth.day; i++) {
        appointmentCounts[
            DateTime(selectedMonth.year, selectedMonth.month, i)] = 0;
      }

      for (var doc in querySnapshot.docs) {
        DateTime appointmentDate =
            (doc['appointmentDate'] as Timestamp).toDate();
        DateTime dateWithoutTime = DateTime(
            appointmentDate.year, appointmentDate.month, appointmentDate.day);

        // Increment the count for the respective date
        appointmentCounts.update(dateWithoutTime, (value) => value + 1,
            ifAbsent: () => 1);
      }
      return appointmentCounts;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching appointment dates chart data: $e');
      }
      rethrow;
    }
  }
}
