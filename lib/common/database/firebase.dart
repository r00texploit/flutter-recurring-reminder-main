import 'package:flutter_reccuring_reminder/common/entities/task.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TasksDatabase {
  static final TasksDatabase instance = TasksDatabase._init();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? user;
  final String _collectionName = 'tasks';

  TasksDatabase._init();

  Future<void> create(Task task) async {
    await _firestore
        .collection(_collectionName)
        .doc(user!.uid)
        .set(task.toMap());
  }

  Future<List<Task>> readAllTasks() async {
    user = _auth.currentUser;
    QuerySnapshot querySnapshot = await _firestore
        .collection(_collectionName)
        .where(TaskFields.user, isEqualTo: user!.uid)
        .get();
    return querySnapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      return Task(
        id: doc.id,
        title: data[TaskFields.title],
        user: user!.uid,
        body: data[TaskFields.body],
        recurrence: data[TaskFields.recurrence],
        dateTime: data[TaskFields.dateTime],
      );
    }).toList();
  }

  Future<void> update(Task task) async {
    await _firestore
        .collection(_collectionName)
        .where(TaskFields.user, isEqualTo: user!.uid)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        if (doc.id == task.id) {
          doc.reference.update(task.toMap());
        }
      });
    });
  }

  Future<void> delete(String id) async {
    await _firestore
        .collection(_collectionName)
        .where(TaskFields.user, isEqualTo: user!.uid)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        if (doc.id == id) {
          doc.reference.delete();
        }
      });
    });
  }

  // No need for close() method in Firebase
}
