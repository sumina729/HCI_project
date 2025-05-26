import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home.dart';

class OnboardingPage3 extends StatefulWidget {
  final List<String> symptoms;
  const OnboardingPage3({super.key, required this.symptoms});

  @override
  State<OnboardingPage3> createState() => _OnboardingPage3State();
}

class _OnboardingPage3State extends State<OnboardingPage3> {
  final TextEditingController _controller = TextEditingController();
  String nickname = '';

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        nickname = _controller.text;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget buildButton({
    required String label,
    required Color backgroundColor,
    required Color textColor,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 57,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(40),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: 20,
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF6F5),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const SizedBox(height: 80),
              const Text(
                '어떻게 불러드릴까요?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF16314E),
                  fontSize: 28,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 100),
              TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  hintText: '닉네임을 입력해주세요',
                  hintStyle: TextStyle(
                    fontSize: 28,
                    color: Color(0xFF9E9E9E),
                    fontFamily: 'Pretendard',
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF299BFF)),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF299BFF), width: 2),
                  ),
                ),
                style: const TextStyle(fontSize: 28, fontFamily: 'Pretendard',),
              ),
              const Spacer(flex: 3),
              Opacity(
                opacity: nickname.isNotEmpty ? 1.0 : 0.3,
                child: buildButton(
                  label: '완료', // 20
                  backgroundColor: const Color(0xFF299BFF),
                  textColor: Colors.white,
                  onTap: nickname.isNotEmpty
                      ? () async {
                          final firestore = FirebaseFirestore.instance;
                          final docRef = firestore.collection('users').doc();

                          await docRef.set({
                            'nickname': nickname,
                            'symptoms': widget.symptoms,
                            'alarmSetting': {
                              'enabled': false,
                              'untilDate': Timestamp.fromDate(DateTime.now()),
                              'times': {
                                'morning': {'enabled': false, 'time': '09:00 AM'},
                                'noon': {'enabled': false, 'time': '12:00 PM'},
                                'evening': {'enabled': false, 'time': '06:00 PM'},
                              },
                            },
                          });
  

                          // await docRef.collection('myMedicines').doc('1a0UIfV5RzTnZuasunN0').set({
                          //   'medicineId': '1a0UIfV5RzTnZuasunN0',
                          //   'name': '슈다페드정',
                          // });

                          // await docRef.collection('myMedicines').doc('JEcQpCvfpK6v4qsnDHt8').set({
                          //   'medicineId': 'JEcQpCvfpK6v4qsnDHt8',
                          //   'name': '로이솔정',
                          // });

                          // 생성한 유저 ID를 HomePage에 전달
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              // builder: (context) => HomePage(),
                              builder: (context) => HomePage(userId: docRef.id),
                            ),
                          );
                        }
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
