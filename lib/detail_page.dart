// flutter:
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shimmer/shimmer.dart';
import 'dart:async';

class DetailPage extends StatefulWidget {
  final String medicineName;
  final String category;
  final String imageUrl;
  final String userName;
  final String description; 
  final List<String> conditions;

  const DetailPage({
    super.key,
    required this.medicineName,
    required this.category,
    required this.imageUrl,
    required this.userName,
    required this.description,
    required this.conditions,
  });

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  bool isLoading = true;
  // String summary = widget.description;
  String caution = '';
  String avoid = '';
  String exercise = '';
  String recommendedFoods = '';
  String cautionTitle = '';
  String avoidTitle = '';
  String exerciseTitle = '';
  String recommendedFoodsTitle = '';
  String loadingText = '';
  int _charIndex = 0;
  final String fullText = "AI가 맞춤형 가이드를 생성하고 있어요...";

  @override
  void initState() {
    super.initState();
    fetchDescription();
    Timer.periodic(const Duration(milliseconds: 70), (timer) {
      if (_charIndex < fullText.length) {
        setState(() {
          loadingText += fullText[_charIndex];
          _charIndex++;
        });
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> fetchDescription() async {
    try {
      final result = await getMedicineGuide(widget.medicineName, widget.description, widget.conditions);

      setState(() {
        cautionTitle = result['caution1_title'] ?? '';
        caution = result['caution1'] ?? '';
        avoidTitle = result['caution2_title'] ?? '';
        avoid = result['caution2'] ?? '';
        exerciseTitle = result['exercise_title'] ?? '';
        exercise = result['exercise'] ?? '';
        recommendedFoodsTitle = result['recommended_foods_title'] ?? '';
        recommendedFoods = result['recommended_foods'] ?? '';
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        // widget.description = '약 설명을 불러오는 데 실패했어요.';
        isLoading = false;
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
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '맞춤 복약 가이드', 
          style: TextStyle(
            color: Color(0xFF0A1D32),
            fontSize: 20,
            fontWeight: FontWeight.w600,
            fontFamily: 'Pretendard',
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.medicineName,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, fontFamily: 'Pretendard')),
              const SizedBox(height: 4),
              Text(widget.category,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF299BFF), fontFamily: 'Pretendard')),
              const SizedBox(height: 20),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  widget.imageUrl,
                  width: 361,
                  height: 194,
                  fit: BoxFit.fill,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: const Center(child: Icon(Icons.broken_image)),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(widget.description,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500, fontFamily: 'Pretendard')),
              const SizedBox(height: 20),
              _buildGuideCardWrapper(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGuideCardWrapper() {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF70AFF4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${widget.userName}님의 건강 상태를 반영하여\nAI가 주의사항과 맞춤 가이드를 안내해 드려요.',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.white,
              fontFamily: 'Pretendard',
            ),
          ),
          const SizedBox(height: 30),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.conditions.map((condition) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: ShapeDecoration(
                color: const Color(0xFFCBE6FF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40),
                ),
              ),
              child: Text(
                condition,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF299BFF),
                  fontSize: 20,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ),
            )).toList(),
          ),

          const SizedBox(height: 20),
          isLoading ? Column(
            children: [
              _buildSkeletonCard('🚨', '주의', Colors.white, Colors.black, const Color(0xFFE25254)),
              const SizedBox(height: 16),
              _buildSkeletonCard('💪', '운동', const Color(0xFF4F91DA), Colors.white, Colors.white),
              const SizedBox(height: 16),
              _buildSkeletonCard('🍽️', '식사', const Color(0xFF4F91D9), Colors.white, Colors.white),
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  '본 서비스는 GPT 기반 인공지능을 활용한 참고용 안내입니다.\n정확한 복약은 반드시 의사나 약사와 상담해 주세요.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: Colors.white,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ) : Column(
            children: [
              _buildGuideCard('🚨', '주의', [(cautionTitle, caution), (avoidTitle, avoid)], Colors.white, Colors.black, const Color(0xFFE25254)),
              const SizedBox(height: 16),
              _buildGuideCard('💪', '운동', [(exerciseTitle, exercise)], const Color(0xFF4F91DA), Colors.white, Colors.white),
              const SizedBox(height: 16),
              _buildGuideCard('🍽️', '식사', [(recommendedFoodsTitle, recommendedFoods)], const Color(0xFF4F91D9), Colors.white, Colors.white),
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  '본 서비스는 GPT 기반 인공지능을 활용한 참고용 안내입니다.\n정확한 복약은 반드시 의사나 약사와 상담해 주세요.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: Colors.white,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          )
          
        ],
      ),
    );
  }

  Widget _buildSkeletonCard(
    String icon,
    String title,
    Color cardColor,
    Color textColor,
    Color highlightColor,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: cardColor == Colors.white
            ? null
            : Border.all(color: Colors.white, width: 2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center, // ✅ 세로 중앙 정렬
        children: [
          /// 아이콘 + 타이틀 묶음 (중앙 정렬)
          Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(icon, style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  color: highlightColor,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Pretendard',
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),

          /// 스켈레톤 shimmer 박스
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: Container(
                    height: 16,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
              )),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildGuideCard(
    String icon,
    String title,
    List<(String, String)> content,
    Color cardColor,
    Color textColor,
    Color highlightColor,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: cardColor == Colors.white
            ? null
            : Border.all(color: Colors.white, width: 2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center, // ✅ 세로 가운데 정렬
        children: [
          /// 아이콘+타이틀 묶음을 가운데 정렬
          Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center, // ✅ 세로 중앙으로
            children: [
              Text(icon, style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  color: highlightColor,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Pretendard',
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),

          /// 우측 내용 영역
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: content.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      color: textColor,
                      fontSize: 20,
                      height: 1.4,
                      fontFamily: 'Pretendard',
                    ),
                    children: [
                      TextSpan(
                        text: '${item.$1}\n',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextSpan(
                        text: item.$2,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }

}
Future<Map<String, String>> getMedicineGuide(String name, String description, List<String> conditions) async {
  const apiKey = '';
  const endpoint = 'https://api.openai.com/v1/chat/completions';

  final prompt = '''
    약 이름: $name 
    약 설명: $description
    다음 약 이름을 가지고 갹관적인 정보를정보를 가지고 정확하고 구체적즈오 복용 가이드를 해줘
    다음 항목들을 포함해서 작성해줘:


    - 약 복용 시 주의사항1 제목(caution1_title) (20자 이내) (약 복용 시 주의사항1 에 대한 제목)
    - 약 복용 시 주의사항1(caution1) (약의 객곽적인 기본 주의사항1(포함피해야 할 음식·행동), 200자 이내)

    - 약 복용 시 주의사항2 제목(caution2_title) (20자 이내) (약 복용 시 주의사항2 에 대한 제목)
    - 약 복용 시 주의사항2(caution2) (약의 객곽적인 정보과, 유저의 건강상태 기반(포함피해야 할 음식·행동), 200자 이내)



    약 이름: $name 
    건강 상태: ${jsonEncode(conditions)}
    다음 약 정보와 겅강 상태를 반영해서 추천 운동, 함께 먹으면 좋은 음식을 알려줘, (우선순위1)약정보를 기반으로 적어주고, (우선순위2)건강상태도 반영해줘
    다음 항목들을 포함해서 작성해줘:


    - 추천 운동 제목(exercise_title) (20자 이내)  (추천 운동에 대한 제목)
    - 추천 운동(exercise) (200자 이내)
    - 함께 먹으면 좋은 음식 제목(recommended_foods_title) (20자 이내) (함께 먹으면 좋은 음식에 대한 제목)
    - 함께 먹으면 좋은 음식(recommended_foods) (200자 이내)

    출력은 아래 JSON 형식 예시를 그대로 따라줘.  
    JSON 포맷 구조, 필드명, 따옴표, 문체는 예시와 완전히 동일하게 작성할 것.  
    문장부호, 줄바꿈 없이, 값은 문자열로 반환할 것.}

    다음 항목을 포함한 JSON을 반환해줘:
    - description
    - caution1_title, caution1
    - caution2_title, caution2
    - exercise_title, exercise
    - recommended_foods_title, recommended_foods

    예시 형식:
    {
      "caution1_title": "혈당 자주 체크하기",
      "caution1": "이 약은 혈당 수치를 낮추거나 변동시킬 수 있어요. 식사 전후 혈당을 자주 측정하고, 저혈당 증상(어지러움, 식은땀, 손 떨림 등)이 느껴지면 빠르게 당을 섭취하고 의사와 상담하세요.",
      "caution2_title": "지방·당분 많은 음식 피하기",
      "caution2": "튀김류, 햄버거, 크림소스 파스타, 단 음료나 디저트는 혈당을 빠르게 높이므로 약 효과를 방해하거나 과도한 혈당 상승을 유발할 수 있어요. 가능하면 피해주세요.",
      "exercise_title": "식후 유산소 운동하기",
      "exercise": "식후 1시간 후에 20~30분간 가벼운 산책, 실내 자전거, 요가 등을 해주세요. 혈당 상승을 완만하게 만들고, 소화 촉진에도 도움이 됩니다. 무리한 고강도 운동은 피하세요.",
      "recommended_foods_title": "서서히 흡수되는 식단 유지",
      "recommended_foods": "현미밥, 귀리죽, 콩나물국, 삶은 두부, 브로콜리나 시금치 등 섬유질이 풍부하고 혈당을 천천히 올리는 식품을 중심으로 식사하세요. 식사 중 단백질을 함께 섭취하면 포만감도 오래 유지돼요."
    }

    ''';

  const int maxRetries = 3;
  int retryCount = 0;

  while (retryCount < maxRetries) {
    try {
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4-turbo',
          'messages': [
            {'role': 'system', 'content': 'You are a helpful assistant that explains medicine.'},
            {'role': 'user', 'content': prompt},
          ],
          'temperature': 0.7,
          'max_tokens': 800,
        }),
      );

      if (response.statusCode == 200) {
        final decoded = utf8.decode(response.bodyBytes);
        final data = jsonDecode(decoded);
        final content = data['choices'][0]['message']['content'];
        final parsed = jsonDecode(content);
        return Map<String, String>.from(parsed);
      } else {
        retryCount++;
        print('GPT 응답 오류 ${response.statusCode}: ${response.body}');
        await Future.delayed(const Duration(seconds: 2)); // 재시도 전 대기
      }
    } catch (e) {
      retryCount++;
      print('GPT 요청 예외 발생: $e');
      await Future.delayed(const Duration(seconds: 2)); // 재시도 전 대기
    }
  }

  // 모든 재시도 실패 시
  throw Exception('GPT 요청 재시도 실패');
}
