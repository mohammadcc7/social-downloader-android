import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Social Downloader',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const DownloadScreen(),
    );
  }
}

class DownloadScreen extends StatefulWidget {
  const DownloadScreen({super.key});

  @override
  State<DownloadScreen> createState() => _DownloadScreenState();
}

class _DownloadScreenState extends State<DownloadScreen> {
  final TextEditingController _urlController = TextEditingController();
  String _downloadType = 'video';
  bool _isDownloading = false;
  double _progress = 0.0;
  String _statusText = 'جاهز للتحميل...';

  void _startDownload() {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال رابط صحيح!')),
      );
      return;
    }

    setState(() {
      _isDownloading = true;
      _progress = 0.3;
      _statusText = 'جاري الاتصال بالرابط...';
    });

    // محاكاة مرحلة التحميل مؤقتاً
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _progress = 1.0;
        _statusText = 'اكتمل التحميل بنجاح!';
        _isDownloading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم التحميل بنجاح!')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('برنامج تحميل وسائل التواصل'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'أدخل الرابط (يوتيوب، فيسبوك، انستغرام...):',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'ألصق الرابط هنا...',
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'اختر صيغة التحميل:',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('فيديو (MP4)'),
                    value: 'video',
                    groupValue: _downloadType,
                    onChanged: (value) {
                      setState(() {
                        _downloadType = value!;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('صوت (MP3)'),
                    value: 'audio',
                    groupValue: _downloadType,
                    onChanged: (value) {
                      setState(() {
                        _downloadType = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              onPressed: _isDownloading ? null : _startDownload,
              child: const Text(
                'بدء التحميل',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 30),
            if (_isDownloading || _progress > 0) ...[
              LinearProgressIndicator(value: _progress),
              const SizedBox(height: 10),
              Text(
                _statusText,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
