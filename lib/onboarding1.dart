import 'package:flutter/material.dart';
import 'onboarding2.dart'; // 반드시 해당 파일이 있어야 함

class OnboardingPage1 extends StatelessWidget {
  const OnboardingPage1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF6F5),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque, // 빈 공간도 터치 감지
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const OnboardingPage2()),
          );
        },
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 100),
              const Text(
                '어서오세요!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF16314E),
                  fontSize: 28,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 80),
              Center(
                child: 
                  Image.asset(
                    'assets/medi.png', // ✅ 로컬 assets 이미지 사용
                    width: MediaQuery.of(context).size.width * 0.4,
                    fit: BoxFit.contain,
                  ),
              ),
              const SizedBox(height: 20),
              const Text(
                '스마트 처방전 도우미\nDr. 메디',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF299BFF),
                  fontSize: 16,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w600,
                  height: 1.5,
                ),
              ),
              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }
}
