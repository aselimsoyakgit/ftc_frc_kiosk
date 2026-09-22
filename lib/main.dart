import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:ui_web' as ui;
import 'dart:html' as html;

void main() {
  runApp(const KioskApp());
}

class KioskApp extends StatelessWidget {
  const KioskApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FTC & FRC Kiosk',
      theme: ThemeData.dark(),
      home: const KioskHomeScreen(),
    );
  }
}

enum ContentType { webUrl, image }

class KioskItem {
  final ContentType type;
  final String value;

  KioskItem({required this.type, required this.value});
}

class KioskHomeScreen extends StatefulWidget {
  const KioskHomeScreen({super.key});

  @override
  State<KioskHomeScreen> createState() => _KioskHomeScreenState();
}

class _KioskHomeScreenState extends State<KioskHomeScreen> {
  // BİLİM ŞENLİĞİNDE GÖSTERİLECEK LİSTE
  // Buraya kendi web sitelerinizi ve eklediğiniz resimlerin yollarını yazın:
  final List<KioskItem> _items = [
    KioskItem(type: ContentType.webUrl, value: 'https://asteria32334.github.io/asteria.web.general/'),
    KioskItem(type: ContentType.image, value: 'assets/slides/slide1.png'),
    KioskItem(type: ContentType.webUrl, value: 'https://asteria32334.github.io/yangin.ihbar/'),
    KioskItem(type: ContentType.image, value: 'assets/slides/slide2.png'),
    KioskItem(type: ContentType.webUrl, value: 'https://firstinspires.org'),
    KioskItem(type: ContentType.image, value: 'assets/slides/slide3.png'),
    KioskItem(type: ContentType.webUrl, value: 'https://asteria32334.github.io/quick-manual/'),
    KioskItem(type: ContentType.image, value: 'assets/slides/slide4.png'),
    KioskItem(type: ContentType.webUrl, value: 'https://github.com/asteria32334/scouting.app.public.git'),
    KioskItem(type: ContentType.image, value: 'assets/slides/slide5.png'),
    KioskItem(type: ContentType.webUrl, value: 'https://asteria32334.github.io/asteria.web.general/files/FTC%20101%20EN.pdf'),
    KioskItem(type: ContentType.image, value: 'assets/slides/slide6.png'),
    KioskItem(type: ContentType.webUrl, value: 'https://asteria32334.github.io/ftc-turkiye-alliance/'),
    KioskItem(type: ContentType.image, value: 'assets/slides/slide7.png'),
    KioskItem(type: ContentType.webUrl, value: 'https://asteria32334.github.io/asteria.web.general/'),
    KioskItem(type: ContentType.image, value: 'assets/slides/slide8.png'),
    KioskItem(type: ContentType.webUrl, value: 'https://asteria32334.github.io/yangin.ihbar/'),
    KioskItem(type: ContentType.image, value: 'assets/slides/slide9.png'),
    KioskItem(type: ContentType.webUrl, value: 'https://asteria32334.github.io/quick-manual/'),
    KioskItem(type: ContentType.image, value: 'assets/slides/slide10.png'),
    KioskItem(type: ContentType.webUrl, value: 'https://firstinspires.org'),
    KioskItem(type: ContentType.image, value: 'assets/slides/slide11.png'),
    KioskItem(type: ContentType.webUrl, value: 'https://github.com/asteria32334/scouting.app.public.git'),
    KioskItem(type: ContentType.image, value: 'assets/slides/slide12.png'),
  ];

  late final PageController _pageController;
  int _currentIndex = 0;
  Timer? _timer;
  bool _isAutoPlay = true;
  final Duration _autoSwitchInterval = const Duration(seconds: 10);

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _registerWebViews();
    _startAutoPlay();
  }

  void _registerWebViews() {
    for (int i = 0; i < _items.length; i++) {
      if (_items[i].type == ContentType.webUrl) {
        // ignore: undefined_prefixed_name
        ui.platformViewRegistry.registerViewFactory(
          'iframe-element-$i',
          (int viewId) {
            final iframe = html.IFrameElement()
              ..src = _items[i].value
              ..style.border = 'none'
              ..style.width = '100%'
              ..style.height = '100%';
            return iframe;
          },
        );
      }
    }
  }

  void _startAutoPlay() {
    _timer?.cancel();
    _timer = Timer.periodic(_autoSwitchInterval, (timer) {
      if (_isAutoPlay && _pageController.hasClients) {
        _nextPage();
      }
    });
  }

  void _pauseAutoPlay() {
    if (_isAutoPlay) {
      setState(() {
        _isAutoPlay = false;
      });
    }
  }

  void _toggleAutoPlay() {
    setState(() {
      _isAutoPlay = !_isAutoPlay;
      if (_isAutoPlay) {
        _startAutoPlay();
      }
    });
  }

  void _nextPage() {
    int nextIndex = (_currentIndex + 1) % _items.length;
    _pageController.animateToPage(
      nextIndex,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
    );
  }

  void _previousPage() {
    int prevIndex = (_currentIndex - 1 + _items.length) % _items.length;
    _pageController.animateToPage(
      prevIndex,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Listener(
        onPointerDown: (_) => _pauseAutoPlay(),
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];
                if (item.type == ContentType.webUrl) {
                  return HtmlElementView(
                    viewType: 'iframe-element-$index',
                  );
                } else {
                  return Container(
                    color: Colors.black,
                    child: Image.asset(
                      item.value,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Text(
                            'Resim bulunamadı:\n${item.value}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.redAccent),
                          ),
                        );
                      },
                    ),
                  );
                }
              },
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black45,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        _pauseAutoPlay();
                        _previousPage();
                      },
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Önceki'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    IconButton(
                      onPressed: _toggleAutoPlay,
                      icon: Icon(
                        _isAutoPlay ? Icons.pause_circle_filled : Icons.play_circle_fill,
                        size: 36,
                        color: _isAutoPlay ? Colors.greenAccent : Colors.orangeAccent,
                      ),
                      tooltip: _isAutoPlay ? 'Otomatik Geçişi Durdur' : 'Otomatik Geçişi Başlat',
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '${_currentIndex + 1} / ${_items.length}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(width: 15),
                    ElevatedButton.icon(
                      onPressed: () {
                        _pauseAutoPlay();
                        _nextPage();
                      },
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Sonraki'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}