import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'اصوات بلذكاء العربي',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0D1117),
      ),
      home: const HelloPage(),
    );
  }
}

class HelloPage extends StatefulWidget {
  const HelloPage({super.key});

  @override
  State<HelloPage> createState() => _HelloPageState();
}

class _HelloPageState extends State<HelloPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Opacity(
              opacity: 0.6 + (_animation.value * 0.4),
              child: Text(
                'Hello World from Codweva',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Color.lerp(
                    const Color(0xFF58A6FF),
                    const Color(0xFF1F6FEB),
                    _animation.value,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const ArabicAIVoiceApp());
}

class ArabicAIVoiceApp extends StatelessWidget {
  const ArabicAIVoiceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'صوت ذكي عربي',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00C9A7),
          brightness: Brightness.dark,
        ),
        textTheme: GoogleFonts.cairoTextTheme(ThemeData.dark().textTheme),
      ),
      home: const VoiceHomePage(),
    );
  }
}

class VoiceHomePage extends StatefulWidget {
  const VoiceHomePage({super.key});

  @override
  State<VoiceHomePage> createState() => _VoiceHomePageState();
}

class _VoiceHomePageState extends State<VoiceHomePage> {
  final FlutterTts flutterTts = FlutterTts();
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  // القائمة المختصرة الجميلة
  final List<Map<String, dynamic>> dialects = [
    {
      'id': 'fusha',
      'name': 'فصحى',
      'emoji': '📜',
      'locale': 'ar',
      'color': const Color(0xFF6366F1),
    },
    {
      'id': 'egyptian',
      'name': 'مصري',
      'emoji': '🇪🇬',
      'locale': 'ar-EG',
      'color': const Color(0xFF10B981),
    },
    {
      'id': 'iraqi',
      'name': 'عراقي',
      'emoji': '🇮🇶',
      'locale': 'ar-IQ',
      'color': const Color(0xFFF59E0B),
    },
    {
      'id': 'gulf',
      'name': 'خليجي',
      'emoji': '🌴',
      'locale': 'ar-SA',
      'color': const Color(0xFFEC4899),
    },
  ];

  String selectedDialect = 'fusha';
  bool isSpeaking = false;
  bool isReady = false;
  double speechRate = 0.5;
  double pitch = 1.0;

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  Future<void> _initTts() async {
    await flutterTts.setSharedInstance(true);
    await flutterTts.awaitSpeakCompletion(true);

    // إعدادات أساسية للعربية
    await flutterTts.setLanguage('ar');
    await flutterTts.setSpeechRate(speechRate);
    await flutterTts.setPitch(pitch);
    await flutterTts.setVolume(1.0);

    // الاستماع لحالة الكلام
    flutterTts.setStartHandler(() {
      setState(() => isSpeaking = true);
    });

    flutterTts.setCompletionHandler(() {
      setState(() => isSpeaking = false);
    });

    flutterTts.setErrorHandler((msg) {
      setState(() => isSpeaking = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ: $msg'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    });

    setState(() => isReady = true);
  }

  Future<void> _speak() async {
    if (_textController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('اكتب نصاً أولاً'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final dialect = dialects.firstWhere((d) => d['id'] == selectedDialect);
    final locale = dialect['locale'] as String;

    // محاولة ضبط اللهجة
    bool available = await flutterTts.isLanguageAvailable(locale);
    if (available) {
      await flutterTts.setLanguage(locale);
    } else {
      // fallback للفصحى
      await flutterTts.setLanguage('ar');
    }

    await flutterTts.setSpeechRate(speechRate);
    await flutterTts.setPitch(pitch);

    await flutterTts.speak(_textController.text.trim());
  }

  Future<void> _stop() async {
    await flutterTts.stop();
    setState(() => isSpeaking = false);
  }

  @override
  void dispose() {
    flutterTts.stop();
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Column(
          children: [
            // الهيدر
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00C9A7), Color(0xFF00A8E8)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.record_voice_over_rounded,
                        color: Colors.white, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'صوت ذكي عربي',
                        style: GoogleFonts.cairo(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'نص → صوت باللهجات العربية',
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          color: Colors.white60,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2),

            const SizedBox(height: 20),

            // قائمة اللهجات المختصرة والجميلة
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                height: 52,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: dialects.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final d = dialects[index];
                    final isSelected = selectedDialect == d['id'];
                    return GestureDetector(
                      onTap: () {
                        setState(() => selectedDialect = d['id']);
                        HapticFeedback.selectionClick();
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? d['color'] as Color
                              : Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: isSelected
                                ? Colors.transparent
                                : Colors.white12,
                            width: 1.5,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: (d['color'] as Color)
                                        .withOpacity(0.4),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  )
                                ]
                              : null,
                        ),
                        child: Row(
                          children: [
                            Text(d['emoji'], style: const TextStyle(fontSize: 18)),
                            const SizedBox(width: 8),
                            Text(
                              d['name'],
                              style: GoogleFonts.cairo(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? Colors.white
                                    : Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ).animate().fadeIn(delay: 150.ms).slideX(begin: 0.1),

            const SizedBox(height: 24),

            // حقل النص
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: TextField(
                    controller: _textController,
                    focusNode: _focusNode,
                    maxLines: null,
                    expands: true,
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      height: 1.6,
                      color: Colors.white,
                    ),
                    decoration: InputDecoration(
                      hintText: 'اكتب النص هنا...\nمثال: مرحبا كيف حالك اليوم؟',
                      hintStyle: GoogleFonts.cairo(
                        color: Colors.white38,
                        fontSize: 16,
                      ),
                      contentPadding: const EdgeInsets.all(20),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
            ).animate().fadeIn(delay: 250.ms),

            const SizedBox(height: 16),

            // التحكم في السرعة والنبرة (مختصر)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('السرعة',
                            style: GoogleFonts.cairo(
                                fontSize: 12, color: Colors.white54)),
                        Slider(
                          value: speechRate,
                          min: 0.3,
                          max: 0.8,
                          activeColor: const Color(0xFF00C9A7),
                          onChanged: (v) => setState(() => speechRate = v),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('النبرة',
                            style: GoogleFonts.cairo(
                                fontSize: 12, color: Colors.white54)),
                        Slider(
                          value: pitch,
                          min: 0.7,
                          max: 1.3,
                          activeColor: const Color(0xFF00A8E8),
                          onChanged: (v) => setState(() => pitch = v),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // زر التوليد / الإيقاف
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: isReady
                      ? (isSpeaking ? _stop : _speak)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSpeaking
                        ? Colors.red.shade600
                        : const Color(0xFF00C9A7),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 8,
                    shadowColor: isSpeaking
                        ? Colors.red.withOpacity(0.4)
                        : const Color(0xFF00C9A7).withOpacity(0.4),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isSpeaking
                            ? Icons.stop_rounded
                            : Icons.play_arrow_rounded,
                        size: 28,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        isSpeaking ? 'إيقاف' : 'إنشاء الصوت',
                        style: GoogleFonts.cairo(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ).animate().fadeIn(delay: 350.ms).slideY(begin: 0.3),
          ],
        ),
      ),
    );
  }
}
}