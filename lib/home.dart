import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'my_page.dart';
import 'detail_page.dart';
import 'ocr_screen.dart';
import 'alarm.dart';
// import 'dart:math';


class HomePage extends StatefulWidget {
  final String userId;
  const HomePage({super.key, required this.userId});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isAlarmOn = false;
  List<Map<String, dynamic>> medicineInfos = [];
  String nickname = '';
  String untilDateText = '';
  List<String> userConditions = [];

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final firestore = FirebaseFirestore.instance;
    final userDoc = await firestore.collection('users').doc(widget.userId).get();

    if (userDoc.exists) {
      final data = userDoc.data()!;
      setState(() {
        nickname = data['nickname'] ?? '김땡땡';
        isAlarmOn = data['alarmSetting']?['enabled'] ?? true;
        userConditions = List<String>.from(data['symptoms'] ?? []);

        final timestamp = data['alarmSetting']?['untilDate'];
        if (timestamp is Timestamp) {
          final date = timestamp.toDate();
          untilDateText = '${date.month}월 ${date.day}일';
        }
      });

      final myMedsSnapshot = await firestore
          .collection('users')
          .doc(widget.userId)
          .collection('myMedicines')
          .get();

      final medicineIds = myMedsSnapshot.docs.map((doc) => doc['medicineId']).toList();

      List<Map<String, dynamic>> meds = [];
      for (final id in medicineIds) {
        final doc = await firestore.collection('medicines').doc(id).get();
        if (doc.exists) {
          meds.add(doc.data()!);
        }
      }

      setState(() {
        medicineInfos = meds;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF6F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFBF6F5),
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          '스마트 처방전 도우미',
          style: TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Pretendard', fontSize: 20),
        ),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => OCRCameraScreen(userId: widget.userId),
                ),
              );
            },
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0x0C0C0C0D),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                  BoxShadow(
                    color: const Color(0x190C0C0D),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Center(
                child: Icon(Icons.qr_code_scanner, color: Color(0xFF299BFF), size: 20),
              ),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              icon: const Icon(Icons.person, size: 30),
              
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => MyPage(userId: widget.userId)),
                );
              },
            ),
          ),
        ],
      ),
      body: 
        SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        // padding:const EdgeInsets.only( top: 16, right: 16, bottom: 16,),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // medicineInfos.isEmpty ? const SizedBox(height: 0) :  const SizedBox(height: 10),
            medicineInfos.isEmpty ? Transform.translate(
              offset: const Offset(-10, -20),
              child: buildGoToScanButton(),
            ) :  const SizedBox(height: 10),
            Text(
              medicineInfos.isEmpty
                  ? '$nickname님, 어떤 약을 처방받으셨나요?\n약 봉투를 스캔해주시면, 복용 시간과 방법을 안내해드릴게요!'
                  : '$nickname님, 코감기로 힘드시죠🥺\n코막힘과 목 통증을 가라앉히고, 염증이 심해지지 않도록 도와주는 약이에요.\n위 보호 약도 함께 들어있으니 안심하세요!',
              style: const TextStyle(fontSize: 24, height: 1.4, fontWeight: FontWeight.w600, fontFamily: 'Pretendard',),
            ),
            const SizedBox(height: 20),
            AlarmCard(
              isAlarmOn: isAlarmOn,
              untilDateText: untilDateText,
              onToggle: (val) {
                setState(() => isAlarmOn = val);
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(widget.userId)
                    .update({'alarmSetting.enabled': val});
              },
              userId: widget.userId, // ✅ 여기에 추가!

            ),
            medicineInfos.isEmpty ? const SizedBox(height: 200) : const SizedBox(height: 24),
            if (medicineInfos.isEmpty)
              const Center(
                child: Text(
                  '아직 보여줄 약 정보가 없어요.',
                  style: TextStyle(fontSize: 16, color: Colors.grey, fontFamily: 'Pretendard',),
                ),
              )
            else
              ...medicineInfos.map((med) => MedicineCard(
                    medicine: med,
                    nickname: nickname,
                    conditions: userConditions,
                  )),
          ],
        ),
      ),
    );
  }
}

class MedicineCard extends StatelessWidget {
  final Map<String, dynamic> medicine;
  final String nickname;
  final List<String> conditions;

  const MedicineCard({super.key, required this.medicine, required this.nickname, required this.conditions});

  @override
  Widget build(BuildContext context) {
    final imageSize = MediaQuery.of(context).size.width * 0.2;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailPage(
              medicineName: medicine['name'] ?? '',
              category: medicine['category'] ?? '',
              description: medicine['description'] ?? '',
              imageUrl: medicine['imageUrl'] ?? '',
              userName: nickname,
              conditions: conditions,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14453D3D),
              blurRadius: 6,
              offset: Offset(3, 3),
            )
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 91,
                height: 80,
                color: const Color.fromARGB(255, 40, 40, 40), // ✅ 배경색을 검정색으로 지정
                child: Image.asset(
                  medicine["imageUrl"] ?? '',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    medicine["name"] ?? "",
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, fontFamily: 'Pretendard',),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    medicine["category"] ?? "",
                    style: const TextStyle(fontSize: 16, color: Color(0xFF299BFF), fontWeight: FontWeight.w600, fontFamily: 'Pretendard',),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    medicine["time"] ?? "",
                    style: const TextStyle(fontSize: 14, color: Color(0xFF696969), fontWeight: FontWeight.w500, fontFamily: 'Pretendard',),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 30),
          ],
        ),
      ),
    );
  }
}


class AlarmCard extends StatelessWidget {
  final bool isAlarmOn;
  final String untilDateText;
  final ValueChanged<bool> onToggle;
  final String userId; // ✅ 추가: userId 받아오기

  const AlarmCard({
    super.key,
    required this.isAlarmOn,
    required this.untilDateText,
    required this.onToggle,
    required this.userId, // ✅ 추가
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isAlarmOn ? const Color(0xFFCBE6FF) : Colors.grey[300],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 1),
            decoration: BoxDecoration(
              color: isAlarmOn ? const Color(0xFF70AFF4) : Colors.grey[600],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.alarm, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    '약 챙김 시간 설정',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                      fontFamily: 'Pretendard',
                    ),
                  ),
                ),
                Switch(
                  value: isAlarmOn,
                  onChanged: onToggle,
                  activeColor: const Color(0xFF007AFF),
                  thumbColor: MaterialStateProperty.all<Color>(Colors.white),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () {
              // ✅ userId를 전달하여 AlarmPage로 이동
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AlarmPage(userId: userId),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Text(
                    isAlarmOn ? '아침, 점심, 저녁' : '아직 설정한 알림이 없어요',
                    style: TextStyle(
                      fontSize: isAlarmOn ? 20 : 16,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Pretendard',
                      color: isAlarmOn ? const Color(0xFF0A1D32) : Colors.grey[600],
                    ),
                  ),
                  const Spacer(),
                  isAlarmOn
                      ? Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: '$untilDateText 저녁까지',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  fontFamily: 'Pretendard',
                                  color: const Color(0xFF0A1D32),
                                ),
                              ),
                              const TextSpan(
                                text: ' 울림',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Pretendard',
                                  color: Color(0xFF0A1D32),
                                ),
                              ),
                            ],
                          ),
                        )
                      : const Text('',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Pretendard',
                            color: Colors.grey,
                          ),
                        ),
                  const SizedBox(width: 6),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 30,
                    color: isAlarmOn ? const Color(0xFF085EBC) : const Color(0xFF767676),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


Widget buildGoToScanButton() {
  return Stack(
    children: [
      Container(
        width: 211,
        height: 51,
        // decoration: BoxDecoration(
        //   boxShadow: [
        //     BoxShadow(
        //       color: Color(0x190C0C0D),
        //       blurRadius: 4,
        //       offset: Offset(0, 1),
        //       spreadRadius: 10,
        //     )
        //   ],
        // ),
        child: Positioned.fill(
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              margin: const EdgeInsets.only(left: 0, top: 13),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              child: const Text(
                '처방받은 약봉투 스캔하러 가기',
                style: TextStyle(
                  color: Color(0xFF299BFF),
                  fontSize: 18,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w800,
                  height: 1.40,
                ),
              ),
            ),
          ),
        ),
      ),
      // 삼각형 추가
      Positioned(
        left: 10,
        top: 3,
        child: CustomPaint(
          size: const Size(20, 17.32), // 높이 = 한 변의 길이 * sqrt(3) / 2
          painter: EquilateralTrianglePainter(color: Colors.white),
        ),
      ),
    ],
  );
}

class EquilateralTrianglePainter extends CustomPainter {
  final Color color;

  EquilateralTrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;

    final double side = size.width;
    final double height = size.height;

    final path = Path()
      ..moveTo(0, height)
      ..lineTo(side / 2, 0)
      ..lineTo(side, height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}