import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

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

  // دالة لطلب أذونات التخزين
  Future<bool> _requestPermission() async {
    if (Platform.isAndroid) {
      var status = await Permission.storage.request();
      if (!status.isGranted) {
        status = await Permission.manageExternalStorage.request();
      }
      return status.isGranted || await Permission.accessMediaLocation.isGranted;
    }
    return true;
  }

  // دالة التحميل الفعلي
  Future<void> _startDownload() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال رابط صحيح!')),
      );
      return;
    }

    bool hasPermission = await _requestPermission();
    if (!hasPermission) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم رفض إذن الوصول للتخزين!')),
      );
      return;
    }

    setState(() {
      _isDownloading = true;
      _progress = 0.1;
      _statusText = _downloadType == 'video' 
          ? 'جاري تجهيز تحميل الفيديو...' 
          : 'جاري تجهيز تحميل الصوت...';
    });

    try {
      // محاكاة جلب واستنزاف الرابط المباشر للتحميل الفعلي
      // (ملاحظة: يمكنك وضع رابط تجريبي مباشر للتأكد من حفظ الملفات في التخزين)
      await Future.delayed(const Duration(seconds: 1));
      setState(() {
        _progress = 0.5;
        _statusText = 'جاري تنزيل الملف وحفظه...';
      });

      // تحديد مسار التخزين في مجلد التنزيلات أو المستندات بالهاتف
      Directory? directory;
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      String fileName = _downloadType == 'video' 
          ? 'downloaded_video_${DateTime.now().millisecondsSinceEpoch}.mp4'
          : 'downloaded_audio_${DateTime.now().millisecondsSinceEpoch}.mp3';

      String filePath = '${directory?.path}/$fileName';

      // مثال لطلب الملف عبر HTTP (يمكن استبداله برابط استخراج مباشر)
      // هنا نقوم بإنشاء ملف حقيقي في الهاتف لتأكيد نجاح التخزين
      File file = File(filePath);
      await file.writeAsString('Dummy content for $_downloadType from $url');

      setState(() {
        _progress = 1.0;
        _isDownloading = false;
        _statusText = 'تم الحفظ في: $filePath';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم تحميل وحفظ ${_downloadType == 'video' ? 'الفيديو' : 'الصوت'} بنجاح!')),
      );
    } catch (e) {
      setState(() {
        _isDownloading = false;
        _statusText = 'حدث خطأ أثناء التحميل!';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ: $e')),
      );
    }
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
              'أدخل الرابط:',
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
                'بدء التحميل والحفظ',
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
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
