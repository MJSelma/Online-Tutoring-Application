// ignore_for_file: unused_local_variable

import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'package:universal_html/html.dart' as html;
import 'package:wokr4ututor/data_class/subject_teach_pricing.dart';
import 'package:wokr4ututor/ui/web/admin/executive_dashboard.dart';
import '../data_class/studentsEnrolledclass.dart';
import '../data_class/tutor_info_class.dart';

Future<String?> uploadData(String uid) async {
  FilePickerResult? result = await FilePicker.platform.pickFiles();

  if (result != null) {
    Uint8List? file = result.files.first.bytes;
    String filename = result.files.first.name;

    UploadTask task = FirebaseStorage.instance
        .ref()
        .child("students/$filename")
        .putData(file!);

    // Wait for the upload task to complete
    await task;

    // Generate and return the download URL
    String downloadURL = await task.snapshot.ref.getDownloadURL();
    return downloadURL;
  } else {
    return null; // Return null in case of an error
  }
}

addUser(String tEmail, tPassword, uType) {
  FirebaseFirestore.instance
      .collection('user')
      .add({'email': tEmail, 'password': tPassword, 'role': uType});
  FirebaseFirestore.instance
      .collection('tutor')
      .add({'firstName': tEmail, 'lastName': tPassword, 'userID': 'Tutor'});
}

addTutorInfo(String tEmail, tPassword, uType) {
  FirebaseFirestore.instance
      .collection('user')
      .add({'email': tEmail, 'password': tPassword, 'role': uType});
  FirebaseFirestore.instance
      .collection('tutor')
      .add({'firstName': tEmail, 'lastName': tPassword, 'userID': 'Tutor'});
}

addStudentInfo(String tEmail, tPassword, uType) {
  FirebaseFirestore.instance
      .collection('user')
      .add({'email': tEmail, 'password': tPassword, 'role': uType});
  FirebaseFirestore.instance
      .collection('students')
      .add({'firstName': tEmail, 'lastName': tPassword, 'userID': 'Student'});
}

class DatabaseService {
  final String uid;
  DatabaseService({required this.uid});
  //collection reference
  final CollectionReference dataCollection =
      FirebaseFirestore.instance.collection('user');
  final CollectionReference tutorCollection =
      FirebaseFirestore.instance.collection('tutor');
  final CollectionReference studentCollection =
      FirebaseFirestore.instance.collection('students');
  final CollectionReference enrolleeCollection =
      FirebaseFirestore.instance.collection('studentsEnrolled');

  List<TutorInformation> _getTutorInformation(QuerySnapshot snapshot) {
    return snapshot.docs.map((tutordata) {
      return TutorInformation(
        birthPlace: tutordata['birthPlace'] ?? '',
        country: tutordata['country'] ?? '',
        certificates:
            (tutordata['certificates'] as List<dynamic>).cast<String>(),
        resume: tutordata['resume'] ?? '',
        promotionalMessage: tutordata['promotionalMessage'] ?? '',
        withdrawal: tutordata['withdrawal'] ?? '',
        status: tutordata['status'] ?? '',
        extensionName: tutordata['extensionName'] ?? '',
        dateSign: tutordata['dateSign']?.toDate() ?? '',
        firstName: tutordata['firstName'] ?? '',
        imageID: tutordata['imageID'] ?? '',
        language: (tutordata['language'] as List<dynamic>).cast<String>(),
        lastname: tutordata['lastName'] ?? '',
        middleName: tutordata['middleName'] ?? '',
        presentation: tutordata['presentation'] ?? '',
        tutorID: tutordata['tutorID'] ?? '',
        userId: tutordata['userID'] ?? '',
      );
    }).toList();
  }

  Stream<List<TutorInformation>> get tutorlist {
    return tutorCollection.snapshots().map(_getTutorInformation);
  }

  List<StudentsList> _getStudentsEnrolled(QuerySnapshot snapshot) {
    return snapshot.docs.map((enrolleedata) {
      return StudentsList(
        address: enrolleedata['address'] ?? '',
        dateEnrolled: enrolleedata['dateEnrolled'] ?? '',
        numberofClasses: enrolleedata['numberofClasses'] ?? '',
        price: enrolleedata['price'] ?? '',
        status: enrolleedata['status'] ?? '',
        studentID: enrolleedata['studentID'] ?? '',
        studentName: enrolleedata['studentName'] ?? '',
        subjectName: enrolleedata['subjectName'] ?? '',
      );
    }).toList();
  }

  Stream<List<StudentsList>> get enrolleelist {
    return enrolleeCollection
        .doc('YnLdZm2n7bPZSTbXS0VvHgG0Jor2')
        .collection('students')
        .snapshots()
        .map(_getStudentsEnrolled);
  }

  Future updateUserData(String email, String role) async {
    return await dataCollection
        .doc(uid)
        .set({'email': email, 'role': role, 'status': 'unfinished'});
  }

  Future<void> updateUserStatus(
    String uid,
    String status,
  ) async {
    try {
      await FirebaseFirestore.instance.collection('user').doc(uid).set({
        "status": status,
      }, SetOptions(merge: true));
      html.window.alert('Upload Successful');
    } catch (error) {
      html.window.alert('Upload Failed: $error');
    }
  }

  Future updateTutorData(
    String email,
  ) async {
    final tutorDocumentRef = tutorCollection.doc(uid);
    await tutorDocumentRef.set({
      "language": [],
      "birthPlace": "",
      "certificates": "",
      "country": "",
      "dateSign": "",
      "emailadd": email,
      "extensionName": "",
      "firstName": '',
      "imageID": "",
      "lastName": "",
      "middleName": "",
      "presentation": "",
      "promotionalMessage": "",
      "resume": "",
      "status": "unsubscribe",
      "tutorID": "",
      "userID": uid,
      "withdrawal": "",
    });
  }

  Future updateStudentData(String email) async {
    // Reference to the student document
    final studentDocumentRef = studentCollection.doc(uid);

    // Set the initial data for the document
    await studentDocumentRef.set({
      "userID": uid,
      "studentMiddleName": '',
      "studentLastName": "",
      "studentID": "",
      "studentFirstName": "",
      "profileurl": "",
      "language": [],
      "emailadd": email,
      "dateregistered": DateTime.now(),
      "dateofbirth": '',
      "country": "",
      "contact": "",
      "age": "",
      "address": "",
      "timezone": "",
    });

    // Create the "enrolledclasses" collection
    await studentDocumentRef.collection("enrolledclasses").add({
      // Add data specific to the "enrolledclasses" collection
      // Example: {"className": "Math 101", "instructor": "John Doe"}
    });

    // Create the "guardianname" collection
    await studentDocumentRef.collection("guardianname").add({
      // Add data specific to the "guardianname" collection
      // Example: {"guardianName": "Alice Smith", "relationship": "Parent"}
    });

    // Create the "myconversation" collection
    await studentDocumentRef.collection("myconversation").add({
      // Add data specific to the "myconversation" collection
      // Example: {"message": "Hello, world!", "timestamp": Timestamp.now()}
    });
  }

  // Future updateStudentData(String email) async {
  //   return await studentCollection.doc(uid).set({
  //     "userID": uid,
  //     "studentMiddleName": '',
  //     "studentLastName": "",
  //     "studentID": "",
  //     "studentFirstName": "",
  //     "profileurl": "",
  //     "language": [],
  //     "emailadd": email,
  //     "dateregistered": DateTime.now(),
  //     "dateofbirth": '',
  //     "country": "",
  //     "contact": "",
  //     "age": "",
  //     "address": "",
  //   });
  // }

  getTutorInfo() async {
    try {
      await FirebaseFirestore.instance
          .collection('tutor')
          .where(uid, isEqualTo: uid)
          .get()
          .then((QuerySnapshot querySnapshot) {
        return querySnapshot.docs.map((tutordata) {
          return tutordata['status'].toString();
        });
      });
    } catch (e) {
      return null;
    }
  }
  //Adding Schedule to database

  addTutoravailbaleDays() async {
    return await FirebaseFirestore.instance
        .collection('tutorSchedule')
        .doc(uid)
        .update({
      'availableDays': [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday'
      ],
    });
  }

  addDayoffs() async {
    return await FirebaseFirestore.instance
        .collection('tutorSchedule')
        .doc(uid)
        .update({
      'availableDays': [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday'
      ],
    });
  }

  addBlockDates() async {
    return await FirebaseFirestore.instance
        .collection('tutorSchedule')
        .doc(uid)
        .collection('blockDates')
        .doc()
        .set({
      'description': 'Vaction Holiday',
      'from': DateTime.now(),
      'to': DateTime.now()
    });
  }

  addTimea() async {
    return await FirebaseFirestore.instance
        .collection('tutorSchedule')
        .doc(uid)
        .collection('blockDates')
        .doc()
        .set({
      'description': 'Vaction Holiday',
      'from': DateTime.now(),
      'to': DateTime.now()
    });
  }

  addTimeavailable() async {
    return await FirebaseFirestore.instance
        .collection('tutorSchedule')
        .doc(uid)
        .collection('timeAvailable')
        .doc()
        .set({
      'description': 'Available Days',
      'from': DateFormat('HH:MM').format(DateTime.now()),
      'to': DateFormat('HH:MM').format(DateTime.now())
    });
  }
}

class TutorInfoData {
  final String uid;
  TutorInfoData({required this.uid});

  List<TutorInformation> _getTutorInfo(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    return [
      TutorInformation(
        birthPlace: snapshot.get('birthPlace') ?? '',
        country: snapshot.get('country') ?? '',
        certificates:
            (snapshot.get('certificates') as List<dynamic>).cast<String>(),
        resume: snapshot.get('resume') ?? '',
        promotionalMessage: snapshot.get('promotionalMessage') ?? '',
        withdrawal: snapshot.get('withdrawal') ?? '',
        status: snapshot.get('status') ?? '',
        extensionName: snapshot.get('extensionName') ?? '',
        dateSign: snapshot.get('dateSign')?.toDate() ?? '',
        firstName: snapshot.get('firstName') ?? '',
        imageID: snapshot.get('imageID') ?? '',
        language: (snapshot.get('language') as List<dynamic>).cast<String>(),
        lastname: snapshot.get('lastName') ?? '',
        middleName: snapshot.get('middleName') ?? '',
        presentation: snapshot.get('presentation') ?? '',
        tutorID: snapshot.get('tutorID') ?? '',
        userId: snapshot.get('userID') ?? '',
      )
    ];
  }

  Stream<List<TutorInformation>> get gettutorinfo {
    return FirebaseFirestore.instance
        .collection('tutor')
        .doc(uid)
        .snapshots()
        .map(_getTutorInfo);
  }
}
