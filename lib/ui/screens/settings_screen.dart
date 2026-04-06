import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../main.dart';
import '../../services/save_service.dart';
import '../../services/audio_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _save = SaveService.instance;
  late double _sfxVol = _save.sfxVolume;
  late double _bgmVol = _save.bgmVolume;
  late int _shakeIntensity = _save.shakeIntensitySetting;
  late bool _colorBlindMode = _save.colorBlindMode;
  late int _langIndex = _save.language == 'en' ? 1 : 0;
  int _textSize = 1; // 0=소, 1=중, 2=대

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () { AudioService.uiBack(); Navigator.pop(context); },
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  const Text('설정', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  _sectionTitle('사운드'),
                  _sliderItem('효과음', _sfxVol, (v) {
                    setState(() => _sfxVol = v);
                    _save.sfxVolume = v;
                    AudioService.sfxVolume = v;
                  }),
                  _sliderItem('배경음', _bgmVol, (v) {
                    setState(() => _bgmVol = v);
                    _save.bgmVolume = v;
                    AudioService.bgmVolume = v;
                  }),
                  const SizedBox(height: 16),
                  _sectionTitle('접근성'),
                  _segmentItem('화면 진동', ['끔', '50%', '100%'], _shakeIntensity ~/ 50,
                      (i) { setState(() => _shakeIntensity = i * 50); _save.shakeIntensitySetting = i * 50; }),
                  _switchItem('색약 모드', _colorBlindMode,
                      (v) { setState(() => _colorBlindMode = v); _save.colorBlindMode = v; }),
                  _segmentItem('언어 Language', ['한국어', 'English'], _langIndex,
                      (i) {
                    setState(() => _langIndex = i);
                    final locale = i == 0 ? const Locale('ko') : const Locale('en');
                    ToemalokApp.setLocale(context, locale);
                  }),
                  _segmentItem('텍스트 크기', ['소', '중', '대'], _textSize,
                      (i) => setState(() => _textSize = i)),
                  const SizedBox(height: 16),
                  _sectionTitle('게임'),
                  _actionItem('튜토리얼 초기화', () {
                    _save.tutorialDone = false;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('튜토리얼이 초기화되었습니다')),
                    );
                  }),
                  _actionItem('데이터 초기화', () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: const Color(0xFF1D3557),
                        title: const Text('데이터 초기화', style: TextStyle(color: Colors.white)),
                        content: const Text('모든 진행 데이터가 삭제됩니다.\n정말 초기화하시겠습니까?',
                            style: TextStyle(color: Colors.white70)),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx),
                              child: const Text('취소', style: TextStyle(color: Colors.white54))),
                          TextButton(onPressed: () async {
                            await Hive.deleteBoxFromDisk('toemalok_save');
                            await _save.init();
                            if (!context.mounted) return;
                            Navigator.pop(ctx);
                            setState(() {
                              _sfxVol = 1.0; _bgmVol = 0.7;
                              _shakeIntensity = 100; _colorBlindMode = false;
                            });
                          }, child: const Text('초기화', style: TextStyle(color: Color(0xFFE63946)))),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Text(text, style: const TextStyle(color: Color(0xFFFFD166), fontSize: 14, fontWeight: FontWeight.bold)),
    );
  }

  Widget _sliderItem(String label, double value, ValueChanged<double> onChanged) {
    return Row(
      children: [
        SizedBox(width: 70, child: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13))),
        Expanded(
          child: SliderTheme(
            data: const SliderThemeData(
              activeTrackColor: Color(0xFF7EC850),
              thumbColor: Color(0xFF7EC850),
            ),
            child: Slider(
              value: value,
              onChanged: onChanged,
            ),
          ),
        ),
        SizedBox(width: 30, child: Text('${(value * 100).toInt()}%', style: const TextStyle(color: Colors.white54, fontSize: 11))),
      ],
    );
  }

  Widget _segmentItem(String label, List<String> options, int selected, ValueChanged<int> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 90, child: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13))),
          ...List.generate(options.length, (i) => GestureDetector(
            onTap: () => onChanged(i),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              margin: const EdgeInsets.only(right: 4),
              decoration: BoxDecoration(
                color: i == selected ? const Color(0xFF457B9D) : const Color(0xFF1D3557),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(options[i], style: const TextStyle(color: Colors.white, fontSize: 12)),
            ),
          )),
        ],
      ),
    );
  }

  Widget _switchItem(String label, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13))),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: const Color(0xFF7EC850),
          ),
        ],
      ),
    );
  }

  Widget _actionItem(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        margin: const EdgeInsets.symmetric(vertical: 2),
        child: Text(label, style: const TextStyle(color: Color(0xFFA8DADC), fontSize: 13)),
      ),
    );
  }
}
