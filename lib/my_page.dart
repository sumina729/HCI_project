import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home.dart';
import 'my_page_edit.dart';
import 'onboarding1.dart';



class MyPage extends StatefulWidget {
  final String userId;

  const MyPage({super.key, required this.userId});

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  String userName = '';
  List<String> healthStatus = [];

  @override
  void initState() {
    super.initState();
    loadUserInfo();
  }

  Future<void> loadUserInfo() async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(widget.userId).get();
    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        userName = data['nickname'] ?? '김땡땡';
        healthStatus = List<String>.from(data['symptoms'] ?? []);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF6F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFBF6F5),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => HomePage(userId: widget.userId),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  const begin = Offset(-1.0, 0.0); // 왼쪽에서 들어오게
                  const end = Offset.zero;
                  const curve = Curves.ease;

                  final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                  return SlideTransition(position: animation.drive(tween), child: child);
                },
              ),
            );
          }
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: IconButton(
              icon: const Icon(Icons.edit, color: Colors.black),
              onPressed: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => EditPage(userId: widget.userId),
                    transitionsBuilder: (_, __, ___, child) => child, // 전환 애니메이션 없음
                  ),
                );
              }
            ),
          )
        ],
        title: const Text(
          '마이페이지',
          style: TextStyle(
            color: Color(0xFF0A1D32),
            fontSize: 20,
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Column(
        children: [
          // 이름과 건강상태 고정 영역
          Padding(
            padding: const EdgeInsets.only(top: 70.0),
            child: Column(
              children: [
                Text(
                  userName,
                  style: const TextStyle(
                    fontSize: 28,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 50),
                const Text(
                  '현재 나의 건강상태',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF787878),
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 증상 목록
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: healthStatus.map((condition) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF299BFF),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Text(
                  condition,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),

          const Spacer(),

          //여기에 로그아웃 버튼 추가
          Padding(
            padding: const EdgeInsets.only(right: 5),
            child: Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  // 온보딩 페이지로 이동 (예: OnboardingPage)
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const OnboardingPage1()),
                  );
                },
                child: const Text(
                  '로그아웃 | 문의하기',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),

          // Footer (왼쪽 정렬)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  '메디핏',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF8B8989),
                    fontFamily: 'Pretendard',
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '스마트 처방전 알리미 서비스',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF8B8989),
                    fontFamily: 'Pretendard',
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '대표    박원진\n'
                  '주소   경상북도 포항시 북구 흥해읍 한동로 558 에벤에셀 1층\n'
                  '문의전화    010-1234-1234\n'
                  '이메일    jinjin@handang.ac.kr\n'
                  '디자인    황유리 임예진\n'
                  '개발    류정현 오예은 이수민',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF8B8989),
                    fontFamily: 'Pretendard',
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '※  서비스 관련 문의는 전화 또는 이메일로 연락 바랍니다.',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF8B8989),
                    fontFamily: 'Pretendard',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
