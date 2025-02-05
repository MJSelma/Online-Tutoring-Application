// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../../services/services.dart';
import '../../services/timefromtimestamp.dart';
import '../../services/timestampconverter.dart';
import '../web/tutor/calendar/setup_calendar.dart';

class UserDataService {
  final String userUID;
  UserDataService({required this.userUID});

  final CollectionReference dataCollection =
      FirebaseFirestore.instance.collection('tutor');

  Future addScheduleTimeavailable() async {
    try {
      //create a new document for the user with the uid
      await DatabaseService(uid: userUID).addTutoravailbaleDays();
      return userUID;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future addDayoffs(List<String> dayoffs) async {
    try {
      //create a new document for the user with the uid
      await DatabaseService(uid: userUID).addDayoffs(
        dayoffs,
        userUID,
      );
      return userUID;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future addTimeavailable() async {
    try {
      //create a new document for the user with the uid
      await DatabaseService(uid: userUID).addTimeavailable();
      return userUID;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}

Future<String?> addDayOffDates(
    String uid, List<String> dayoffs, List<DateTime> dateoffselected) async {
  try {
    final DocumentReference docRef =
        FirebaseFirestore.instance.collection('tutorSchedule').doc(uid);
    final DocumentSnapshot doc = await docRef.get();

    if (doc.exists) {
      final dynamic data = doc.data();
      if (data != null &&
          data['dayoffs'] is List<dynamic> &&
          data['dateoffselected'] is List<dynamic>) {
        final List<dynamic> currentDayoffs = data['dayoffs'];
        final List<dynamic> currentDateOffSelected = data['dateoffselected'];

        if (!listsAreEqual(dayoffs, currentDayoffs) ||
            !datesAreEqual(dateoffselected, currentDateOffSelected)) {
          await docRef.update({
            'uid': uid,
            'dayoffs': dayoffs,
            'dateoffselected': dateoffselected
                .map((date) => <String, dynamic>{
                      'selectedDate': formatTimewDate(
                              DateFormat('MMMM d, yyyy').format(date),
                              "12:00 AM")
                          .toString(),
                      'timeAvailableFrom': formatTimewDate(
                              DateFormat('MMMM d, yyyy').format(date),
                              "12:00 AM")
                          .toString(),
                      'timeAvailableTo': formatTimewDate(
                              DateFormat('MMMM d, yyyy').format(date),
                              "11:59 PM")
                          .toString(),
                    })
                .toList(),
          });

          return 'success';
        } else {
          return 'Dayoffs and DateOffSelected are already up to date';
        }
      }
    }

    // Create a new document if it doesn't exist or if 'dayoffs' or 'dateoffselected' is not a list
    await docRef.set({
      'uid': uid,
      'dayoffs': dayoffs,
      'dateoffselected':
          dateoffselected.map((date) => date.toIso8601String()).toList(),
    });

    return 'success';
  } catch (e) {
    print(e.toString());
    return null;
  }
}

bool listsAreEqual(List<String> list1, List<dynamic> list2) {
  if (list1.length != list2.length) {
    return false;
  }

  for (int i = 0; i < list1.length; i++) {
    if (list1[i] != list2[i]) {
      return false;
    }
  }

  return true;
}

bool datesAreEqual(List<DateTime> list1, List<dynamic> list2) {
  if (list1.length != list2.length) {
    return false;
  }

  for (int i = 0; i < list1.length; i++) {
    final dateAsString = list2[i] as String;
    final dateFromDatabase = DateTime.tryParse(dateAsString);

    if (dateFromDatabase == null || list1[i] != dateFromDatabase) {
      return false;
    }
  }

  return true;
}

Future<String?> addBlockDates(String uid, List<String> dayoffs) async {
  try {
    //create a new document for the user with the uid
    await FirebaseFirestore.instance.collection('tutorSchedule').doc(uid).set({
      'dayoffs': dayoffs,
    });
    return 'success';
  } catch (e) {
    print(e.toString());
    return null;
  }
}

Future<String?> deleteDayOffDates(String uid) async {
  try {
    final DocumentReference docRef =
        FirebaseFirestore.instance.collection('tutorSchedule').doc(uid);
    final DocumentSnapshot doc = await docRef.get();

    if (doc.exists) {
      await docRef.update({
        'dayoffs': FieldValue.delete(),
        'dateoffselected': FieldValue.delete(),
      });

      return 'success';
    } else {
      // The document with the provided UID doesn't exist
      return 'Document does not exist';
    }
  } catch (e) {
    return e.toString();
  }
}

Future<String?> deleteDayOff(String uid, String dayOffDate) async {
  try {
    final DocumentReference docRef =
        FirebaseFirestore.instance.collection('tutorSchedule').doc(uid);
    final DocumentSnapshot doc = await docRef.get();

    if (doc.exists) {
      List<String>? dayOffs = List<String>.from(doc['dayoffs']);

      // Check if the dayOffDate exists in the list
      if (dayOffs != null && dayOffs.contains(dayOffDate)) {
        dayOffs.remove(dayOffDate);

        await docRef.update({
          'dayoffs': dayOffs,
        });

        return 'success';
      } else {
        return 'Day off date not found in the list';
      }
    } else {
      return 'Document does not exist';
    }
  } catch (e) {
    return e.toString();
  }
}

Future<String?> deleteDateOff(String uid, DateTime dayOffDate) async {
  try {
    final DocumentReference docRef =
        FirebaseFirestore.instance.collection('tutorSchedule').doc(uid);
    final DocumentSnapshot doc = await docRef.get();
    Map<String, dynamic> datatoupload = {
      'selectedDate': formatTimewDate(
              DateFormat('MMMM d, yyyy').format(dayOffDate), '12:00 AM')
          .toString(),
      'timeAvailableFrom': formatTimewDate(
              DateFormat('MMMM d, yyyy').format(dayOffDate), '12:00 AM')
          .toString(),
      'timeAvailableTo': formatTimewDate(
              DateFormat('MMMM d, yyyy').format(dayOffDate), '11:59 PM')
          .toString(),
    };
    print(datatoupload);
    if (doc.exists) {
      List<dynamic> datesoff = doc['dateoffselected'] ?? [];

      // Find the block date to remove
      datesoff.removeWhere((date) {
        return date['timeAvailableTo'] == datatoupload['timeAvailableTo'] &&
            date['selectedDate'] == datatoupload['selectedDate'] &&
            date['timeAvailableFrom'] == datatoupload['timeAvailableFrom'];
      });

      // Update the document with the modified blockdatetime field
      await docRef.update({'dateoffselected': datesoff});

      return 'success';
    } else {
      return 'Document not found';
    }
  } catch (e) {
    return e.toString();
  }
}

// Future<String?> addOrUpdateTimeAvailability(
//     String uid, TimeAvailability timeAvailability) async {
//   try {
//     final DocumentReference docRef =
//         FirebaseFirestore.instance.collection('tutorSchedule').doc(uid);

//     // Create a reference to the "timeavailable" subcollection
//     final CollectionReference timeAvailableCollectionRef =
//         docRef.collection('timeavailable');

//     // Delete all existing documents within the "timeavailable" subcollection
//     QuerySnapshot existingDocs = await timeAvailableCollectionRef.get();
//     for (QueryDocumentSnapshot doc in existingDocs.docs) {
//       await doc.reference.delete();
//     }
//     Map<String, dynamic> data = {
//       'timeAvailableFrom': formatTime(timeAvailability.timeAvailableFrom).toString(),
//       'timeAvailableTo': formatTime(timeAvailability.timeAvailableTo).toString(),
//     };
//     // Add a new document to the "timeavailable" subcollection
//     await timeAvailableCollectionRef.add(data);

//     return 'success';
//   } catch (e) {
//     print('Error adding/updating subcollection: $e');
//     return e.toString();
//   }
// }

Future<String?> addOrUpdateTimeAvailability(
    String uid, TimeAvailability timeAvailability) async {
  try {
    final DocumentReference docRef =
        FirebaseFirestore.instance.collection('tutorSchedule').doc(uid);

    Map<String, dynamic> data = {
      'timeAvailableFrom':
          formatTime(timeAvailability.timeAvailableFrom).toString(),
      'timeAvailableTo':
          formatTime(timeAvailability.timeAvailableTo).toString(),
    };

    // Update the "timeavailable" field in the main document
    await docRef.set({'timeavailable': data}, SetOptions(merge: true));

    return 'success';
  } catch (e) {
    print('Error adding/updating timeavailable field: $e');
    return e.toString();
  }
}

Future<String?> deleteTimeAvailability(
    String uid, TimeAvailability timeAvailability) async {
  try {
    final DocumentReference docRef =
        FirebaseFirestore.instance.collection('tutorSchedule').doc(uid);

    DocumentSnapshot docSnapshot = await docRef.get();

    if (!docSnapshot.exists) {
      return 'document not found';
    }

    // Format the values for comparison
    Map<String, dynamic> targetData = {
      'timeAvailableFrom': formatTimewDate('August 6, 2024',
              updateTime('Asia/Manila', timeAvailability.timeAvailableFrom))
          .toString(),
      'timeAvailableTo': formatTimewDate('August 6, 2024',
              updateTime('Asia/Manila', timeAvailability.timeAvailableTo))
          .toString(),
    };

    // Retrieve the `timeavailable` map from the document
    Map<String, dynamic> timedateavailable =
        (docSnapshot.data() as Map<String, dynamic>?)?['timeavailable']
                as Map<String, dynamic>? ??
            {};

    if (timedateavailable.isNotEmpty) {
      if (timedateavailable['timeAvailableFrom'] ==
              targetData['timeAvailableFrom'] &&
          timedateavailable['timeAvailableTo'] ==
              targetData['timeAvailableTo']) {
        // Remove the item from the map

        // Update the document with the new `timeavailable` map
        await docRef.update({'timeavailable': FieldValue.delete()});

        return 'success';
      } else {
        return 'timeavailable field is empty';
      }
    } else {
      return 'empty';
    }
  } catch (e) {
    return e.toString();
  }
}

// Future<String?> addOrUpdateTimeAvailabilityWithDate(
//     String uid, List<DateTimeAvailability> timeAvailability) async {
//   try {
//     final DocumentReference docRef =
//         FirebaseFirestore.instance.collection('tutorSchedule').doc(uid);

//     final CollectionReference timeAvailableCollectionRef =
//         docRef.collection('timedateavailable');

//     QuerySnapshot existingDocs = await timeAvailableCollectionRef.get();

//     if (existingDocs.docs.isEmpty) {
//       for (DateTimeAvailability availability in timeAvailability) {
//         await timeAvailableCollectionRef.add(availability.toMap());
//       }
//     } else {
//       for (DateTimeAvailability availability in timeAvailability) {
//         DateTime formattedSelectedDate = availability.selectedDate;

//         bool selectedDateExists = existingDocs.docs.any(
//             (doc) => doc['selectedDate'].toDate() == formattedSelectedDate);

//         // If selectedDate doesn't exist, add it to the subcollection
//         if (!selectedDateExists) {
//           await timeAvailableCollectionRef.add(availability.toMap());
//         }
//       }
//     }

//     return 'success';
//   } catch (e) {
//     print('Error adding/updating subcollection: $e');
//     return e.toString();
//   }
// }
Future<String?> addOrUpdateTimeAvailabilityWithDate(
    String uid, DateTimeAvailability timeAvailability) async {
  try {
    final DocumentReference docRef =
        FirebaseFirestore.instance.collection('tutorSchedule').doc(uid);

    DocumentSnapshot docSnapshot = await docRef.get();

    List<dynamic> timedateavailable = (docSnapshot.data()
            as Map<String, dynamic>?)?['timedateavailable'] as List<dynamic>? ??
        [];

    // Convert each item in the list to a Map<String, dynamic>
    List<Map<String, dynamic>> timeList =
        timedateavailable.cast<Map<String, dynamic>>();

    Map<String, dynamic> datatoupload = {
      'selectedDate': formatTimewDate(
              DateFormat('MMMM d, yyyy').format(timeAvailability.selectedDate),
              timeAvailability.timeAvailableFrom)
          .toString(),
      'timeAvailableFrom': formatTimewDate(
              DateFormat('MMMM d, yyyy').format(timeAvailability.selectedDate),
              timeAvailability.timeAvailableFrom)
          .toString(),
      'timeAvailableTo': formatTimewDate(
              DateFormat('MMMM d, yyyy').format(timeAvailability.selectedDate),
              timeAvailability.timeAvailableTo)
          .toString(),
    };
    // Find the index of the existing availability with the same selectedDate

    timeList.add(datatoupload);

    await docRef.set({'timedateavailable': timeList}, SetOptions(merge: true));

    return 'success';
  } catch (e) {
    print('Error adding/updating timedateavailable field: $e');
    return e.toString();
  }
}

Future<String?> deleteDateAvailability(
    String uid, DateTimeAvailability timeAvailability) async {
  try {
    final DocumentReference docRef =
        FirebaseFirestore.instance.collection('tutorSchedule').doc(uid);

    DocumentSnapshot docSnapshot = await docRef.get();

    if (!docSnapshot.exists) {
      return 'Document not found';
    }

    // Format the values for comparison
    Map<String, dynamic> dateoff = {
      'timeAvailableTo': formatTimewDate(
              DateFormat('MMMM d, yyyy').format(timeAvailability.selectedDate),
              timeAvailability.timeAvailableTo)
          .toString(),
      'selectedDate': formatTimewDate(
              DateFormat('MMMM d, yyyy').format(timeAvailability.selectedDate),
              timeAvailability.timeAvailableFrom)
          .toString(),
      'timeAvailableFrom': formatTimewDate(
              DateFormat('MMMM d, yyyy').format(timeAvailability.selectedDate),
              timeAvailability.timeAvailableFrom)
          .toString(),
    };

    // Retrieve the existing list from Firestore
    List<dynamic> dateoffs =
        List<dynamic>.from(docSnapshot['timedateavailable'] ?? []);

    // Remove the matching entry
    dateoffs.removeWhere((item) {
      Map<String, dynamic> itemMap = item as Map<String, dynamic>;
      return itemMap['timeAvailableTo'] == dateoff['timeAvailableTo'] &&
          itemMap['selectedDate'] == dateoff['selectedDate'] &&
          itemMap['timeAvailableFrom'] == dateoff['timeAvailableFrom'];
    });

    // Update the document with the modified list
    await docRef.update({'timedateavailable': dateoffs});

    return 'success';
  } catch (e) {
    return e.toString();
  }
}

Future<String?> deleteAllTimeData(String uid) async {
  try {
    final DocumentReference docRef =
        FirebaseFirestore.instance.collection('tutorSchedule').doc(uid);

    // Delete 'blockdatetime' subcollection
    await deleteSubcollection(docRef, 'timeavailable');

    // Delete another subcollection (replace 'otherSubcollection' with the actual subcollection name)
    await deleteSubcollection(docRef, 'timedateavailable');

    return 'success';
  } catch (e) {
    print('Error deleting data: $e');
    return e.toString();
  }
}

Future<void> deleteSubcollection(
    DocumentReference docRef, String subcollectionPath) async {
  final CollectionReference subcollectionRef =
      docRef.collection(subcollectionPath);

  // Delete all documents inside the subcollection
  QuerySnapshot querySnapshot = await subcollectionRef.get();
  querySnapshot.docs.forEach((doc) async {
    await doc.reference.delete();
  });
}

// Future<String?> blockTimeWithDate(String uid, BlockDate blockDate) async {
//   try {
//     final DocumentReference docRef =
//         FirebaseFirestore.instance.collection('tutorSchedule').doc(uid);

//     final CollectionReference blockCollectionRef =
//         docRef.collection('blockdatetime');

//     QuerySnapshot existingDocs = await blockCollectionRef.get();

//     if (existingDocs.docs.isEmpty) {
//       await blockCollectionRef.add(blockDate.toMap());
//     } else {
//       bool dataNotFound = true;

//       if (dataNotFound) {
//         await blockCollectionRef.add(blockDate.toMap());
//       }
//     }

//     return 'success';
//   } catch (e) {
//     print('Error adding/updating subcollection: $e');
//     return e.toString();
//   }
// }

Future<String?> blockTimeWithDate(String uid, BlockDate blockDate) async {
  try {
    final DocumentReference docRef =
        FirebaseFirestore.instance.collection('tutorSchedule').doc(uid);

    DocumentSnapshot docSnapshot = await docRef.get();

    List<dynamic> timedateavailable = (docSnapshot.data()
            as Map<String, dynamic>?)?['blockdatetime'] as List<dynamic>? ??
        [];

    // Convert each item in the list to a Map<String, dynamic>
    List<Map<String, dynamic>> timeList =
        timedateavailable.cast<Map<String, dynamic>>();

    Map<String, dynamic> datatoupload = {
      'selectedDate': formatTimewDate(
              DateFormat('MMMM d, yyyy').format(blockDate.blockDate),
              blockDate.timeFrom)
          .toString(),
      'timeAvailableFrom': formatTimewDate(
              DateFormat('MMMM d, yyyy').format(blockDate.blockDate),
              blockDate.timeFrom)
          .toString(),
      'timeAvailableTo': formatTimewDate(
              DateFormat('MMMM d, yyyy').format(blockDate.blockDate),
              blockDate.timeTo)
          .toString(),
    };
    // Find the index of the existing availability with the same selectedDate

    timeList.add(datatoupload);

    await docRef.set({'blockdatetime': timeList}, SetOptions(merge: true));

    return 'success';
  } catch (e) {
    print('Error adding/updating blockdatetime field: $e');
    return e.toString();
  }
}

Future<String?> deleteBlockDate(String uid, BlockDate blockDate) async {
  try {
    final DocumentReference docRef =
        FirebaseFirestore.instance.collection('tutorSchedule').doc(uid);

    // Retrieve the document containing the blockdatetime field
    DocumentSnapshot docSnapshot = await docRef.get();

    dynamic tempBlockDate = {
      'timeAvailableTo': formatTimewDate(
              DateFormat('MMMM d, yyyy').format(blockDate.blockDate),
              blockDate.timeTo)
          .toString(),
      'selectedDate': formatTimewDate(
              DateFormat('MMMM d, yyyy').format(blockDate.blockDate),
              blockDate.timeFrom)
          .toString(),
      'timeAvailableFrom': formatTimewDate(
              DateFormat('MMMM d, yyyy').format(blockDate.blockDate),
              blockDate.timeFrom)
          .toString(),
    };

    if (docSnapshot.exists) {
      List<dynamic> blockDates = docSnapshot['blockdatetime'] ?? [];

      // Find the block date to remove
      blockDates.removeWhere((date) {
        return date['timeAvailableTo'] == tempBlockDate['timeAvailableTo'] &&
            date['selectedDate'] == tempBlockDate['selectedDate'] &&
            date['timeAvailableFrom'] == tempBlockDate['timeAvailableFrom'];
      });

      // Update the document with the modified blockdatetime field
      await docRef.update({'blockdatetime': blockDates});

      return 'success';
    } else {
      return 'Document not found';
    }
  } catch (e) {
    print('Error deleting block date: $e');
    return e.toString();
  }
}

Future<String?> deleteAllBlockDates(String uid) async {
  try {
    final DocumentReference docRef =
        FirebaseFirestore.instance.collection('tutorSchedule').doc(uid);

    // Update the blockdatetime field to an empty array to clear all dates
    await docRef.update({
      'blockdatetime': [],
    });

    return 'success';
  } catch (e) {
    print('Error deleting block dates: $e');
    return e.toString();
  }
}


// Future<String?> blockTimeWithDate(
//     String uid, List<BlockDate> blockdates) async {
//   try {
//     final DocumentReference docRef =
//         FirebaseFirestore.instance.collection('tutorSchedule').doc(uid);

//     final CollectionReference blockCollectionRef =
//         docRef.collection('blockdatetime');

//     QuerySnapshot existingDocs = await blockCollectionRef.get();

//     if (existingDocs.docs.isEmpty) {
//       for (BlockDate blocks in blockdates) {
//         await blockCollectionRef.add(blocks.toMap());
//       }
//     } else {
//       bool dataNotFound = true;

//       if (dataNotFound) {
//         for (BlockDate blocks in blockdates) {
//           await blockCollectionRef.add(blocks.toMap());
//         }
//       }
//     }

//     return 'success';
//   } catch (e) {
//     print('Error adding/updating subcollection: $e');
//     return e.toString();
//   }
// }
