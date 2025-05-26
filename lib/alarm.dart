import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'alarm_service.dart'; // 알림 예약 함수 정의된 파일
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'home.dart';

class AlarmPage extends StatefulWidget {
  final String userId;
  const AlarmPage({super.key, required this.userId});

  @override
  State<AlarmPage> createState() => _AlarmPageState();
}

class _AlarmPageState extends State<AlarmPage> {
  // final Map<String, TimeOfDay> times = {
  //   '아침': const TimeOfDay(hour: 9, minute: 0),
  //   '점심': const TimeOfDay(hour: 12, minute: 0),
  //   '저녁': const TimeOfDay(hour: 18, minute: 15),
  // };

  // final Map<String, bool> toggles = {
  //   '아침': true,
  //   '점심': true,
  //   '저녁': true,
  // };

  final Map<String, TimeOfDay> times = {}; // <- 비워놓음
  final Map<String, bool> toggles = {};    // <- 비워놓음

  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    loadAlarmSettingFromFirestore();
  }

  Future<void> loadAlarmSettingFromFirestore() async {
  final doc = await FirebaseFirestore.instance
      .collection('users')
      .doc(widget.userId)
      .get();

  if (doc.exists) {
    final data = doc.data();
    final alarmSetting = data?['alarmSetting'];

    const keyToLabel = {
      'morning': '아침',
      'noon': '점심',
      'evening': '저녁',
    };

    setState(() {
      if (alarmSetting == null || alarmSetting['times'] == null) {
        // 🔹 초기 Firestore 값 세팅이 없을 경우, 기본값 적용
        times['아침'] = TimeOfDay(hour: 9, minute: 0);
        times['점심'] = TimeOfDay(hour: 12, minute: 0);
        times['저녁'] = TimeOfDay(hour: 18, minute: 0);

        toggles['아침'] = false;
        toggles['점심'] = false;
        toggles['저녁'] = false;
        selectedDate = DateTime.now();
      } else {
        final timesData = alarmSetting['times'];
        final untilDate = alarmSetting['untilDate'];

        if (untilDate != null) {
          selectedDate = (untilDate as Timestamp).toDate();
        }

        keyToLabel.forEach((key, label) {
          final timeInfo = timesData[key];
          if (timeInfo != null) {
            toggles[label] = timeInfo['enabled'] ?? false;
            final parsedTime = DateFormat('hh:mm a').parse(timeInfo['time']);
            times[label] = TimeOfDay(
              hour: parsedTime.hour,
              minute: parsedTime.minute,
            );
          }
        });
      }
    });
  }
}

  String get formattedDateText =>
      DateFormat("M월 d일").format(selectedDate) + " 저녁까지 알림 설정";

  void _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> saveAlarmSettingToFirestore() async {
    final formatted = (TimeOfDay t) {
      final dt = DateTime(0, 1, 1, t.hour, t.minute);
      return DateFormat('hh:mm a').format(dt);
    };

    const labelToKey = {
      '아침': 'morning',
      '점심': 'noon',
      '저녁': 'evening',
    };

    final Map<String, dynamic> timesData = {};
    labelToKey.forEach((label, key) {
      final toggle = toggles[label];
      final time = times[label];
      if (toggle != null && time != null) {
        timesData[key] = {
          'enabled': toggle,
          'time': formatted(time),
        };
      }
    });

    final data = {
      'enabled': true,
      'untilDate': Timestamp.fromDate(selectedDate),
      'times': timesData,
    };

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .set({'alarmSetting': data}, SetOptions(merge: true));
    } catch (e) {
      print('❌ 저장 실패: $e');
    }

    for (var label in labelToKey.keys) {
      if (toggles[label] == true) {
        int id = labelToKey.keys.toList().indexOf(label);
        await scheduleAlarm(
          id: id,
          time: times[label]!,
          message: '$label 약 복용 시간입니다!\n복용 방법과 함께 건강한 섭취를 해보세요',
        );
      }
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("저장 완료"),
        content: const Text("알림이 예약되었습니다."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomePage(userId: widget.userId),
              ),
            ),
            child: const Text("확인"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF6F5),
      body: SafeArea(
        child: Column(
          children: [
            const _Header(),
            GestureDetector(
              onTap: () => _pickDate(context),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Color(0xFF007AFF)),
                    const SizedBox(width: 8),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: formattedDateText.split(" 저녁까지")[0],
                            style: const TextStyle(
                              color: Color(0xFF007AFF),
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const TextSpan(
                            text: ' 저녁까지 알림 설정',
                            style: TextStyle(
                              color: Color(0xFF0A1D32),
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            ...times.entries.map((entry) => _TimePickerSection(
                  label: entry.key,
                  time: entry.value,
                  isEnabled: toggles[entry.key]!,
                  onTimeChanged: (newTime) {
                    setState(() {
                      times[entry.key] = newTime;
                    });
                  },
                  onToggleChanged: (value) {
                    setState(() {
                      toggles[entry.key] = value;
                    });
                  },
                )),
            const Spacer(),
            GestureDetector(
              onTap: saveAlarmSettingToFirestore,
              child: Opacity(
                opacity: 0.9,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  width: 311,
                  height: 57,
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40),
                      side: const BorderSide(color: Color(0xFF299BFF), width: 2),
                    ),
                    color: const Color(0xFF299BFF),
                  ),
                  child: const Center(
                    child: Text(
                      '저장',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pop(context); // 뒤로 가기
            },
            child: const Icon(Icons.arrow_back_ios, color: Colors.black),
          ),
          const Text(
            '약 챙김 시간 설정',
            style: TextStyle(
              color: Color(0xFF0A1D32),
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 24),
        ],
      ),
    );
  }
}

class _TimePickerSection extends StatelessWidget {
  final String label;
  final TimeOfDay time;
  final bool isEnabled;
  final ValueChanged<TimeOfDay> onTimeChanged;
  final ValueChanged<bool> onToggleChanged;

  const _TimePickerSection({
    required this.label,
    required this.time,
    required this.isEnabled,
    required this.onTimeChanged,
    required this.onToggleChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0A1D32),
                  ),
                ),
                SizedBox(
                  height: 100,
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.time,
                    initialDateTime: DateTime(2024, 1, 1, time.hour, time.minute),
                    use24hFormat: false,
                    onDateTimeChanged: (dateTime) => onTimeChanged(
                      TimeOfDay(hour: dateTime.hour, minute: dateTime.minute),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: isEnabled,
            onChanged: onToggleChanged,
            activeColor: const Color(0xFF299BFF),
            thumbColor: MaterialStateProperty.all<Color>(Colors.white),
          ),
        ],
      ),
    );
  }
}
