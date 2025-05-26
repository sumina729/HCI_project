import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'dart:ui';
import 'scan_confirm.dart';
class OCRCameraScreen extends StatefulWidget {
  final String userId;
  OCRCameraScreen({required this.userId});

  @override
  State<OCRCameraScreen> createState() => _OCRCameraScreenState();
}

class _OCRCameraScreenState extends State<OCRCameraScreen> {
  CameraController? _cameraController;
  bool _isProcessing = false;
  bool _isCameraInitialized = false;
  // List<String> localMedicineList = ["슈다페드정", "로이솔정", "트라몰서방정","크라목신정","베리온정"];
  List<String> localMedicineList = [
    '알마겔정', 
    '슈가메트서방정', 
    '듀비메트서방정', 
    '경동아스피린장용정', 
    '리피토정', 
    '애니코프캡슐',  
    '다이크로짇정',
    '소론도정', 
    '슈다페드정', 
    '로이솔정', 
    '트라몰서방정', 
    '크라목신정', 
    '베리온정'
  ];
  late List<CameraDescription> _cameras;
  String? _capturedImagePath;

  @override
  void initState() {
    super.initState();
    initializeCamera();
  }

  Future<void> initializeCamera() async {
    await Permission.camera.request();
    _cameras = await availableCameras();
    _cameraController = CameraController(_cameras[0], ResolutionPreset.high);
    await _cameraController!.initialize();
    setState(() {
      _isCameraInitialized = true;
    });
  }
  List<String> extractMatchedKeywords(String recognizedText, List<String> keywords) {
      return keywords.where((keyword) => recognizedText.contains(keyword)).toList();
    }
  Future<void> captureAndAnalyze(BuildContext context) async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;

    await _cameraController!.takePicture().then((file) async {
      setState(() {
        _capturedImagePath = file.path;
        _isProcessing = true;
      });
    // showRecognitionErrorDialog(context);
     final inputImage = InputImage.fromFilePath(file.path);
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.korean);

      final recognizedText = await textRecognizer.processImage(inputImage);

      final text = recognizedText.text;
      print(text);
      textRecognizer.close();


      final List<String> matchedName = extractMatchedKeywords(text, localMedicineList);
      await Future.delayed(Duration(seconds: 1));

      if (matchedName.isNotEmpty) {
        print(matchedName);
      } else {
        showRecognitionErrorDialog(context);
      }
      // showRecognitionErrorDialog(context);
      setState(() {
        _isProcessing = false;
        _capturedImagePath = null;
      });
      if(matchedName.isNotEmpty){
        Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScanConfirmPage(
          userId: widget.userId,
          matchedName: matchedName,
        ),
      ),
    );
      }
    });
  }
void showRecognitionErrorDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: Colors.white,
        child: SizedBox(
          width: 280,  // 원하는 가로 크기
          height: 175, // 원하는 세로 크기
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 내용 영역
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Column(
                  children: [
                    Text(
                      '인식이 제대로 되지 않았어요!',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '글자가 잘 보이도록\n흔들리지 않게 찍어주세요.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF299BFF),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),

              // Divider: 좌우 padding 없이 전체 너비
              Divider(
                color: Colors.grey.shade400,
                thickness: 1,
                height: 1,
              ),
              // 버튼
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                      '확인',
                      style: TextStyle(
                        color: Color(0xFF299BFF),
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}


  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _isCameraInitialized
          ? Stack(
              children: [
                Positioned.fill(
                  child: AspectRatio(
                    aspectRatio: _cameraController!.value.aspectRatio,
                    child: _capturedImagePath != null && _isProcessing
                        ? Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.file(
                            File(_capturedImagePath!),
                            fit: BoxFit.cover,
                          ),
                          BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                            child: Container(
                              color: Colors.black.withOpacity(0), // 흐림 효과를 위한 투명 레이어
                            ),
                          ),
                        ],
                      )
                        : CameraPreview(_cameraController!),
                  ),
                ),
                Positioned(
                left: 0,
                top: 0,
                child: Container(
                  width: 393,
                  height: 233,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment(0.50, 0.42),
                      end: Alignment(0.50, 1.00),
                      colors: [Color(0x66222222), // 밝은 검정, 불투명도 80%
      Color(0x00222222), // 같은 색상 but 완전 투명
      ] // 투명],
                    ),
                  ),
                ),
              ),
                Positioned(
                  top: MediaQuery.of(context).padding.top + 10,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 48),
                      const Text(
                        '스캔하기',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          fontFamily:'Pretendard'
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        iconSize: 32,
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                if (!_isProcessing)
                  Positioned(
                left: 76,
                top: 154,
                child: Text(
                  '글자가 잘 보이도록\n흔들리지 않게 찍어주세요',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w600,
                    height: 1.33,
                  ),
                ),
              ),
              if (_isProcessing)
                Positioned(
                  top: 164,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      Text(
                        '약 정보 분석 중…',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w600,
                          height: 1.33,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!_isProcessing)
                  Positioned(
                    bottom: 40,
                    left: MediaQuery.of(context).size.width / 2 - 40,
                    child: GestureDetector(
                      onTap: () => captureAndAnalyze(context),
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF299BFF),
                        ),
                        child: Center(
                          child: Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFFBF6F5),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
