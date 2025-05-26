import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home.dart';

class ScanConfirmPage extends StatefulWidget {
  final String userId;
  final List<String> matchedName;

  const ScanConfirmPage({super.key, required this.userId, required this.matchedName});

  @override
  State<ScanConfirmPage> createState() => _ScanConfirmPageState();
}

List<String> allMedicines = [
  '경동아스피린장용정',
  '다이크로짇정',
  '듀비메트서방정',
  '로이솔정',
  '리피토정',
  '베리온정',
  '소론도정',
  '슈가메트서방정',
  '슈다페드정',
  '알마겔정',
  '애니코프캡슐',
  '크라목신정',
  '트라몰서방정',
];

String? selectedMedicine;


class _ScanConfirmPageState extends State<ScanConfirmPage> {
  int medicationDays = 3;

  String getFormattedToday() {
    final now = DateTime.now();
    return '${now.year}년 ${now.month}월 ${now.day}일';
  }

  // final List<String> medicines = [
  //   '슈다페드정',
  //   '로이솔정',
  //   '트라몰서방정',
  //   '크라목신정',
  //   '베리온정'
  // ];
  // final List<String> medicines = matchedName;
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF6F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFBF6F5),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          '스캔하기',
          style: TextStyle(color: Color(0xFF0A1D32), fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF0A1D32)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              '복용 예정인 약의 정보를 스캔했어요.\n잘못 스캔된 정보가 없는지 확인해 주세요!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, height: 1.4),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Text('스캔한 날짜 ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                Text(getFormattedToday(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Text('복용기간 ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(width: 22,),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(color: const Color(0x14453D3D), blurRadius: 3, offset: const Offset(-2, -1)),
                      BoxShadow(color: const Color(0x0F453C3C), blurRadius: 2, offset: const Offset(1, 1)),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: () => setState(() {
                          if (medicationDays > 1) medicationDays--;
                        }),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), bottomLeft: Radius.circular(4)),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(color: const Color(0x14453D3D), blurRadius: 3, offset: const Offset(-2, -1)),
                              BoxShadow(color: const Color(0x0F453C3C), blurRadius: 2, offset: const Offset(1, 1)),
                            ],
                          ),
                          child: const Center(child: Icon(Icons.remove, color: Color(0xFF007AFF), size: 18)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text('$medicationDays', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
                      ),
                      InkWell(
                        onTap: () => setState(() => medicationDays++),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(topRight: Radius.circular(4), bottomRight: Radius.circular(4)),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(color: const Color(0x14453D3D), blurRadius: 3, offset: const Offset(-2, -1)),
                              BoxShadow(color: const Color(0x0F453C3C), blurRadius: 2, offset: const Offset(1, 1)),
                            ],
                          ),
                          child: const Center(child: Icon(Icons.add, color: Color(0xFF007AFF), size: 18)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                const Text('일', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
  child: Column(
    children: [
      // 🔹 드롭다운 + 추가 버튼 (리스트 위로 이동)
      Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              value: selectedMedicine,
              hint: const Text('추가할 약을 선택하세요'),
              items: allMedicines
                  .where((med) => !widget.matchedName.contains(med))
                  .map((med) => DropdownMenuItem(
                        value: med,
                        child: Text(med),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedMedicine = value;
                });
              },
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Color(0xFF299BFF), width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: selectedMedicine != null &&
                    !widget.matchedName.contains(selectedMedicine!)
                ? () {
                    setState(() {
                      widget.matchedName.add(selectedMedicine!);
                      selectedMedicine = null;
                    });
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF299BFF),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ],
      ),
      const SizedBox(height: 16),
      // 🔹 리스트 영역
      Expanded(
        child: ListView(
          children: widget.matchedName.map((medicine) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                // 휴지통 아이콘
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Color(0xFF299BFF)),
                  onPressed: () {
                    setState(() {
                      widget.matchedName.remove(medicine);
                    });
                  },
                ),
                const SizedBox(width: 8),

                // 약 이름 + 파란 줄
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        medicine,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF0A1D32),
                        ),
                      ),
                      const Divider(color: Color(0xFF299BFF), thickness: 2, height: 8),
                    ],
                  ),
                ),
              ],
            ),
          )).toList(),
        ),
      ),
    ],
  ),
),


          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1️⃣ 다시 스캔하기 버튼 (위)
            SizedBox(
              width: 311,
              height: 57,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFCBE6FF),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                  elevation: 2,
                ),
                child: const Text('다시 스캔하기', style: TextStyle(fontSize: 20, color: Color(0xFF299BFF), fontWeight: FontWeight.w500)),
              ),
            ),
            const SizedBox(height: 12),

            // 2️⃣ 확인 버튼 (아래)
            SizedBox(
              width: 311,
              height: 57,
              child: ElevatedButton(
                onPressed: () async {
                  final docRef = FirebaseFirestore.instance.collection('users').doc(widget.userId);
                  final updatedUntilDate = DateTime.now().add(Duration(days: medicationDays));

                  final medData = {
                    'S1hXkMoSxiaeKuR0Kvs1': '경동아스피린장용정',
                    'KNgV3feBmjcdik2cdBHR': '다이크로짇정',
                    'ZLKdbE1rjIkzpnISvP30': '듀비메트서방정',
                    'JEcQpCvfpK6v4qsnDHt8': '로이솔정',
                    '1wATVAUOZzHvYqRyfAgz': '리피토정',
                    'tPwj50K6MBcAwyTXfzYd': '베리온정',
                    'SlbBCg47Okel1gmjLXSG': '소론도정',
                    'CGKJeLNBVxpguUTR3tyt': '슈가메트서방정',
                    '1a0UIfV5RzTnZuasunN0': '슈다페드정',
                    'KIqOGcLG46dafV4Y5Quz': '알마겔정',
                    'J6U9qghfuVih4xUcCvSF': '애니코프캡슐',
                    'LkiOMRQ2mJh46r9b4OXw': '크라목신정',
                    'squWATUFZza9SLnHavtv': '트라몰서방정',
                  };

                  // ✅ matchedName에 있는 약만 필터링해서 등록
                  for (final entry in medData.entries) {
                    if (widget.matchedName.contains(entry.value)) {
                      await docRef.collection('myMedicines').doc(entry.key).set({
                        'medicineId': entry.key,
                        'name': entry.value,
                      });
                    }
                  }

                  await docRef.update({
                    'alarmSetting.enabled': true,
                    'alarmSetting.untilDate': Timestamp.fromDate(updatedUntilDate),
                    'alarmSetting.times.morning.enabled': true,
                    'alarmSetting.times.noon.enabled': true,
                    'alarmSetting.times.evening.enabled': true,
                  });

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => HomePage(userId: widget.userId)),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF299BFF),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                  elevation: 4,
                ),
                child: const Text('확인', style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.w500)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
