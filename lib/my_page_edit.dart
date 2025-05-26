import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hci_project/my_page.dart';

class EditPage extends StatefulWidget {
  final String userId;

  const EditPage({super.key, required this.userId});

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  late TextEditingController _nameController;
  String originalName = '';
  String editedName = '';
  List<String> selectedSymptoms = [];
  final List<String> allSymptoms = [
    '당뇨', '천식', '비만', '고혈압', '저혈압', '고지혈증',
    '비염', '수면장애', '골다공증', '두통', '피부질환',
    '폐렴', '심장질환', '간 질환'
  ];

  bool isChanged = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    loadUserInfo();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> loadUserInfo() async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(widget.userId).get();
    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        originalName = data['nickname'] ?? '김땡땡';
        editedName = originalName;
        _nameController.text = originalName;
        selectedSymptoms = List<String>.from(data['symptoms'] ?? []);
      });
    }
  }

  void toggleSymptom(String symptom) {
    setState(() {
      if (selectedSymptoms.contains(symptom)) {
        selectedSymptoms.remove(symptom);
      } else {
        selectedSymptoms.add(symptom);
      }
      isChanged = true;
    });
  }

  void updateName(String name) {
    setState(() {
      editedName = name;
      isChanged = name != originalName;
    });
  }

  Future<void> saveSymptoms() async {
    await FirebaseFirestore.instance.collection('users').doc(widget.userId).update({
      'symptoms': selectedSymptoms,
      'nickname': editedName,
    });
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MyPage(userId: widget.userId)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: true, // ✅ 키보드 올라와도 오버플로우 X
      backgroundColor: const Color(0xFFFBF6F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFBF6F5),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => MyPage(userId: widget.userId)),
          ),
        ),
        title: const Text(
          '마이페이지 수정',
          style: TextStyle(
            color: Color(0xFF0A1D32),
            fontSize: 20,
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 100,
          ), // ✅ 키보드 올라도 충분한 여유 공간
          child: Column(
            
            children: [
              const SizedBox(height: 60),
              Center(
                child: Column(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.9, // 💡 밑줄 포함 TextField 전체 너비
                      child: TextField(
                        controller: _nameController,
                        onChanged: updateName,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
                        cursorColor: Color(0xFF299BFF),
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 8),
                          border: UnderlineInputBorder(),
                          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    const Text(
                      '현재 나의 건강상태',
                      style: TextStyle(fontSize: 16, color: Color(0xFF787878), fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: allSymptoms.map((condition) {
                  final isSelected = selectedSymptoms.contains(condition);
                  return GestureDetector(
                    onTap: () => toggleSymptom(condition),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF299BFF) : const Color(0xFFFBF6F5),
                        border: Border.all(color: const Color(0xFF299BFF)),
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: Text(
                        condition,
                        style: TextStyle(
                          color: isSelected ? Colors.white : const Color(0xFF299BFF),
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 100), // 하단 버튼 공간 확보
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 0), // bottom 0으로 변경
      child: Column(
        mainAxisSize: MainAxisSize.min, // bottomNavigationBar가 필요한 만큼만 높이 사용
        children: [
          GestureDetector(
            onTap: isChanged ? saveSymptoms : null,
            child: Container(
              width: 311,
              height: 57,
              decoration: BoxDecoration(
                color: isChanged ? const Color(0xFF299BFF) : Colors.grey[400],
                borderRadius: BorderRadius.circular(40),
                boxShadow: const [
                  BoxShadow(color: Color(0x14453D3D), blurRadius: 6, offset: Offset(3, 3)),
                  BoxShadow(color: Color(0x0F453C3C), blurRadius: 2, offset: Offset(1, 1)),
                ],
              ),
              alignment: Alignment.center,
              child: const Text(
                '확인',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    ),
      
      
    );
  }
}
