import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:work4ututor/services/timefromtimestamp.dart';
import 'package:work4ututor/services/timestampconverter.dart';

import '../data_class/classesdataclass.dart';
import '../ui/web/tutor/calendar/setup_calendar.dart';

class TutorScheduleProvider with ChangeNotifier {
  TimeAvailability? _availableDateSelected;
  TimeAvailability? get availableDateSelected => _availableDateSelected;
  void getDataFromTutorScheduleCollectionAvailableTime(String uid) async {
    try {
      FirebaseFirestore.instance
          .collection('tutorSchedule')
          .doc(uid)
          .snapshots()
          .listen((DocumentSnapshot doc) {
        if (doc.exists) {
          Map<String, dynamic>? docData = doc.data() as Map<String, dynamic>?;
          Map<String, dynamic>? timeData =
              docData?['timeavailable'] as Map<String, dynamic>?;

          if (timeData != null && timeData.isNotEmpty) {
            TimeAvailability timeAvailability =
                TimeAvailability.fromMap(timeData);
            _availableDateSelected = timeAvailability;
          } else {
            _availableDateSelected = null; // Field is missing or empty
          }
        } else {
          _availableDateSelected = null; // Document doesn't exist
        }
        notifyListeners();
      });
    } catch (e) {
      print(e);
      _availableDateSelected = null; // Handle any exceptions by setting to null
      notifyListeners();
    }
  }

  List<DateTimeAvailability>? _dateavailabledateselected;
  List<DateTimeAvailability>? get dateavailabledateselected =>
      _dateavailabledateselected;

  void getDataFromTutorScheduleCollectionAvailableDateTime(
      String uid, targettimezone) async {
    try {
      FirebaseFirestore.instance
          .collection('tutorSchedule')
          .doc(uid)
          .snapshots()
          .listen((DocumentSnapshot doc) {
        if (doc.exists) {
          Map<String, dynamic>? docData = doc.data() as Map<String, dynamic>?;
          List<dynamic>? timeDataList =
              docData?['timedateavailable'] as List<dynamic>?;

          if (timeDataList != null && timeDataList.isNotEmpty) {
            // Find the most recent DateTimeAvailability based on selectedDate
            try {
              List<DateTimeAvailability> timeAvailabilities =
                  timeDataList.map((item) {
                return DateTimeAvailability(
                    selectedDate: formatTimewDatewZone(
                        DateFormat('MMMM d, yyyy h:mm a').format(
                            DateTime.parse(item['selectedDate']).toLocal()),
                        targettimezone),
                    timeAvailableFrom:
                        updateTime(targettimezone, item['timeAvailableFrom']),
                    timeAvailableTo:
                        updateTime(targettimezone, item['timeAvailableTo']));
              }).toList();

              timeAvailabilities
                  .sort((a, b) => b.selectedDate.compareTo(a.selectedDate));

              _dateavailabledateselected =
                  timeAvailabilities.isNotEmpty ? timeAvailabilities : null;
            } catch (e) {
              print(e);
            }
          } else {
            _dateavailabledateselected = null;
          }
        } else {
          _dateavailabledateselected = null;
        }
        notifyListeners();
      });
    } catch (e) {
      _dateavailabledateselected = null;
      notifyListeners();
    }
  }

  List<BlockDate>? _blockdateselected;
  List<BlockDate>? get blockdateselected => _blockdateselected;

  List<String>? dayOffs;
  List<DateTime>? dayOffsdate;

  void getDataFromTutorScheduleCollectionBlockDateTime(
      String uid, targettimezone) async {
    try {
      FirebaseFirestore.instance
          .collection('tutorSchedule')
          .doc(uid)
          .snapshots()
          .listen((DocumentSnapshot doc) {
        if (doc.exists) {
          Map<String, dynamic>? docData = doc.data() as Map<String, dynamic>?;
          List<dynamic>? timeDataList =
              docData?['blockdatetime'] as List<dynamic>?;

          if (timeDataList != null && timeDataList.isNotEmpty) {
            try {
              List<BlockDate> timeAvailabilities = timeDataList.expand((item) {
                String datefrom = DateFormat('MMMM d, yyyy').format(
                    formatTimewDatewZone(
                        DateFormat('MMMM d, yyyy h:mm a').format(
                            DateTime.parse(item['timeAvailableFrom'])
                                .toLocal()),
                        targettimezone));
                String dateto = DateFormat('MMMM d, yyyy').format(
                    formatTimewDatewZone(
                        DateFormat('MMMM d, yyyy h:mm a').format(
                            DateTime.parse(item['timeAvailableTo']).toLocal()),
                        targettimezone));

                List<BlockDate> blockDates = [];

                if (datefrom != dateto) {
                  BlockDate blockDate1 = BlockDate(
                    blockDate: formatTimewDatewZone(
                        DateFormat('MMMM d, yyyy h:mm a').format(
                            DateTime.parse(item['timeAvailableFrom'])
                                .toLocal()),
                        targettimezone),
                    timeFrom:
                        updateTime(targettimezone, item['timeAvailableFrom']),
                    timeTo: '11:59 PM',
                  );

                  BlockDate blockDate2 = BlockDate(
                    blockDate: formatTimewDatewZone(
                        DateFormat('MMMM d, yyyy h:mm a').format(
                            DateTime.parse(item['timeAvailableTo']).toLocal()),
                        targettimezone),
                    timeFrom: '12:00 AM',
                    timeTo: updateTime(targettimezone, item['timeAvailableTo']),
                  );

                  blockDates.add(blockDate1);
                  blockDates.add(blockDate2);
                } else {
                  BlockDate blockDate = BlockDate(
                    blockDate: formatTimewDatewZone(
                        DateFormat('MMMM d, yyyy h:mm a').format(
                            DateTime.parse(item['selectedDate']).toLocal()),
                        targettimezone),
                    timeFrom:
                        updateTime(targettimezone, item['timeAvailableFrom']),
                    timeTo: updateTime(targettimezone, item['timeAvailableTo']),
                  );

                  blockDates.add(blockDate);
                }

                return blockDates;
              }).toList();

              timeAvailabilities
                  .sort((a, b) => b.blockDate.compareTo(a.blockDate));

              _blockdateselected =
                  timeAvailabilities.isNotEmpty ? timeAvailabilities : null;
            } catch (e) {
              _blockdateselected = null;
            }
          } else {
            _blockdateselected = null;
          }
        } else {
          _blockdateselected = null;
        }
        notifyListeners(); // Move notifyListeners here to ensure it is called
      });
    } catch (e) {
      _blockdateselected = null;
      notifyListeners(); // Ensure notifyListeners is called in case of error
    }
  }

  void getDataFromTutorScheduleCollection(String uid, String targetTimezone) {
    FirebaseFirestore.instance
        .collection('tutorSchedule')
        .where('uid', isEqualTo: uid)
        .snapshots()
        .listen((querySnapshot) {
      dayOffs = [];
      dayOffsdate = [];

      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        List<dynamic> dateoffselected = data['dateoffselected'] != null
            ? List<dynamic>.from(data['dateoffselected'])
            : [];
        List<DateTime> tempdayOffsdate = [];

        try {
          List<BlockDate> timeAvailabilities = dateoffselected.expand((item) {
            String datefrom = DateFormat('MMMM d, yyyy').format(
                formatTimewDatewZone(
                    DateFormat('MMMM d, yyyy h:mm a').format(
                        DateTime.parse(item['timeAvailableFrom']).toLocal()),
                    targetTimezone));
            String dateto = DateFormat('MMMM d, yyyy').format(
                formatTimewDatewZone(
                    DateFormat('MMMM d, yyyy h:mm a').format(
                        DateTime.parse(item['timeAvailableTo']).toLocal()),
                    targetTimezone));

            List<BlockDate> blockDates = [];

            if (datefrom != dateto) {
              BlockDate blockDate1 = BlockDate(
                blockDate: formatTimewDatewZone(
                    DateFormat('MMMM d, yyyy h:mm a').format(
                        DateTime.parse(item['timeAvailableFrom']).toLocal()),
                    targetTimezone),
                timeFrom: updateTime(targetTimezone, item['timeAvailableFrom']),
                timeTo: '11:59 PM',
              );

              BlockDate blockDate2 = BlockDate(
                blockDate: formatTimewDatewZone(
                    DateFormat('MMMM d, yyyy h:mm a').format(
                        DateTime.parse(item['timeAvailableTo']).toLocal()),
                    targetTimezone),
                timeFrom: '12:00 AM',
                timeTo: updateTime(targetTimezone, item['timeAvailableTo']),
              );

              blockDates.add(blockDate1);
              blockDates.add(blockDate2);
            } else {
              tempdayOffsdate = dateoffselected
                  .map(
                    (dateString) => formatTimewDatewZone(
                        DateFormat('MMMM d, yyyy h:mm a').format(
                            DateTime.parse(dateString['selectedDate'])
                                .toLocal()),
                        targetTimezone),
                  )
                  .toList();
            }

            return blockDates;
          }).toList();

          timeAvailabilities.sort((a, b) => b.blockDate.compareTo(a.blockDate));
          print(timeAvailabilities.first.timeFrom);
          if (_blockdateselected == null) {
            _blockdateselected == timeAvailabilities;
            notifyListeners();
          } else {
            _blockdateselected!.addAll(timeAvailabilities);
            notifyListeners();
          }
        } catch (e) {
          dayOffsdate = [];
        }

        dayOffs = List<String>.from(data['dayoffs'] ?? []);
        dayOffsdate = tempdayOffsdate;
      }

      notifyListeners();
    });
  }

  List<Schedule> finalschedule = [];

  void fetchSchedule(String id, String type, String targetTimezone) async {
    try {
      List<Schedule> tempScheduleList = [];

      QuerySnapshot<Map<String, dynamic>> classSnapshot = type == 'tutor'
          ? await FirebaseFirestore.instance
              .collection('classes')
              .where('tutorID', isEqualTo: id)
              .get()
          : await FirebaseFirestore.instance
              .collection('classes')
              .where('studentID', isEqualTo: id)
              .get();

      for (var classDoc in classSnapshot.docs) {
        String snapshotId = classDoc.id;

        QuerySnapshot<Map<String, dynamic>> scheduleSnapshot =
            await FirebaseFirestore.instance
                .collection('schedule')
                .where('scheduleID', isEqualTo: snapshotId)
                .get();
        if (scheduleSnapshot.docs.isNotEmpty || scheduleSnapshot.docs != null) {
          for (var documentSnapshot in scheduleSnapshot.docs) {
            var data = documentSnapshot.data();

            String session = data['session'] ?? '';
            DateTime schedule = formatTimewDatewZone(
                DateFormat('MMMM d, yyyy h:mm a')
                    .format(DateTime.parse(data['schedule']).toLocal()),
                targetTimezone);
            String timefrom = updateTime(targetTimezone, data['timefrom']);
            String timeto = updateTime(targetTimezone, data['timeto']);

            Schedule tempschedinfo = Schedule(
              scheduleID: data['scheduleID'] ?? '',
              session: session,
              schedule: schedule,
              timefrom: timefrom,
              timeto: timeto,
              classstatus: data['classstatus'] ?? '',
              meetinglink: data['meetinglink'] ?? '',
              rating: data['rating'] ?? '',
              studentStatus: data['studentStatus'] ?? '',
              tutorStatus: data['tutorStatus'] ?? '',
            );
            tempScheduleList.add(tempschedinfo);
          }
          finalschedule = tempScheduleList;
          notifyListeners();
        } else {
          finalschedule = [];
          notifyListeners();
        }
      }

      // Update finalschedule with the accumulated list
    } catch (error) {
      finalschedule = [];
      notifyListeners();
    }
  }
}
