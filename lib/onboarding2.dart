import 'package:flutter/material.dart';
import 'onboarding3.dart';

class OnboardingPage2 extends StatefulWidget {
  const OnboardingPage2({super.key});

  @override
  State<OnboardingPage2> createState() => _OnboardingPage2State();
}

class _OnboardingPage2State extends State<OnboardingPage2> {
  final List<String> symptoms = [
    '비만', '고혈압', '저혈압', '당뇨',
    '고지혈증', '천식', '비염', '수면장애',
    '골다공증', '두통', '피부질환', '폐렴',
    '심장질환', '간 질환',
  ];

  final Set<String> selectedSymptoms = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF6F5),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 100),
              const Text(
                '꼭 맞는 약 안내를 위해,\n앓고 계신 병력을 알려주세요!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF16314E),
                  fontSize: 28,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 50),

              Expanded(
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: symptoms.map((symptom) {
                      final selected = selectedSymptoms.contains(symptom);
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (selected) {
                              selectedSymptoms.remove(symptom);
                            } else {
                              selectedSymptoms.add(symptom);
                            }
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          decoration: ShapeDecoration(
                            color: selected ? const Color(0xFF299BFF) : Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(40),
                              side: const BorderSide(
                                width: 1.6,
                                color: Color(0xFF299BFF),
                              ),
                            ),
                          ),
                          child: Text(
                            symptom,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: selected ? Colors.white : const Color(0xFF299BFF),
                              fontFamily: 'Pretendard',
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Column(
                children: [
                  SizedBox(
                    width: 311,
                    height: 57,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFCBE6FF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                OnboardingPage3(symptoms: selectedSymptoms.toList()),
                          ),
                        );
                      },
                      child: const Text(
                        '건너뛰기',
                        style: TextStyle(
                          color: Color(0xFF299BFF),
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Pretendard',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: 311,
                    height: 57,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF299BFF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40),
                        ),
                      ),
                      onPressed: selectedSymptoms.isNotEmpty
                          ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      OnboardingPage3(symptoms: selectedSymptoms.toList()),
                                ),
                              );
                            }
                          : null,
                      child: const Text(
                        '다음',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Pretendard',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
