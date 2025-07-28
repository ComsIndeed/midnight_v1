import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:midnight_v1/classes/app_data.dart';
import 'package:path/path.dart' as p;
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';

class QuizGenerationContainer extends StatefulWidget {
  const QuizGenerationContainer({super.key});

  @override
  State<QuizGenerationContainer> createState() =>
      _QuizGenerationContainerState();
}

class _QuizGenerationContainerState extends State<QuizGenerationContainer>
    with SingleTickerProviderStateMixin {
  final controller = TextEditingController();
  final progressStreamController = StreamController<String>.broadcast();
  List<File> files = [];
  String controllerTextSnapshot = "";
  bool isGenerating = false;

  late AnimationController _shadowController;
  late Animation<Color?> _colorAnimation;
  late Animation<double> _blurAnimation;

  final List<Color> _shadowColors = [
    Colors.pinkAccent,
    Colors.purpleAccent,
    Colors.blueAccent,
  ];

  @override
  void initState() {
    super.initState();
    _shadowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _colorAnimation = TweenSequence<Color?>([
      TweenSequenceItem(
        tween: ColorTween(begin: _shadowColors[0], end: _shadowColors[1]),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: ColorTween(begin: _shadowColors[1], end: _shadowColors[2]),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: ColorTween(begin: _shadowColors[2], end: _shadowColors[0]),
        weight: 1,
      ),
    ]).animate(_shadowController);
    _blurAnimation = Tween<double>(begin: 16, end: 48).animate(
      CurvedAnimation(parent: _shadowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _shadowController.dispose();
    controller.dispose();
    super.dispose();
  }

  /// Returns a list of maps: { 'mimetype': String, 'bytes': Uint8List }
  Future<List<Map<String, dynamic>>> getFileBytesAndMimeTypes() async {
    List<Map<String, dynamic>> result = [];
    for (final file in files) {
      final ext = p.extension(file.path).toLowerCase();
      String? mimetype;
      if (['.jpg', '.jpeg', '.jpe', '.jfif', '.pjpeg', '.pjp'].contains(ext)) {
        mimetype = 'image/jpeg';
      } else if (ext == '.png') {
        mimetype = 'image/png';
      } else if (ext == '.gif') {
        mimetype = 'image/gif';
      } else if (ext == '.bmp') {
        mimetype = 'image/bmp';
      } else if (ext == '.webp') {
        mimetype = 'image/webp';
      } else if (ext == '.pdf') {
        mimetype = 'application/pdf';
      } else if (ext == '.mp3') {
        mimetype = 'audio/mpeg';
      } else if (ext == '.wav') {
        mimetype = 'audio/wav';
      } else if (ext == '.ogg') {
        mimetype = 'audio/ogg';
      } else if (ext == '.aac') {
        mimetype = 'audio/aac';
      } else if (ext == '.m4a') {
        mimetype = 'audio/mp4';
      } else if (ext == '.mp4') {
        mimetype = 'video/mp4';
      } else if (ext == '.mov') {
        mimetype = 'video/quicktime';
      } else if (ext == '.avi') {
        mimetype = 'video/x-msvideo';
      } else if (ext == '.wmv') {
        mimetype = 'video/x-ms-wmv';
      } else if (ext == '.flv') {
        mimetype = 'video/x-flv';
      } else if (ext == '.mkv') {
        mimetype = 'video/x-matroska';
      } else if (ext == '.webm') {
        mimetype = 'video/webm';
      } else {
        mimetype = 'application/octet-stream';
      }
      final bytes = await file.readAsBytes();
      result.add({'mimetype': mimetype, 'bytes': bytes});
    }
    return result;
  }

  Future<void> addFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: [
        'pdf',
        'jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp', // images
        'mp3', 'wav', 'ogg', 'aac', 'm4a', // audio
        'mp4', 'mov', 'avi', 'wmv', 'flv', 'mkv', 'webm', // video
      ],
    );
    if (result != null) {
      setState(() {
        files.addAll(
          result.paths
              .whereType<String>()
              .map((path) => File(path))
              .where((file) => !files.any((f) => f.path == file.path)),
        );
      });
    }
  }

  void removeFile(File file) {
    setState(() {
      files.remove(file);
    });
  }

  Widget buildFileBox(File file) {
    final ext = p.extension(file.path).toLowerCase();
    final isImage = [
      '.jpg',
      '.jpeg',
      '.png',
      '.gif',
      '.bmp',
      '.webp',
    ].contains(ext);
    final isVideo = [
      '.mp4',
      '.mov',
      '.avi',
      '.wmv',
      '.flv',
      '.mkv',
      '.webm',
    ].contains(ext);
    final isAudio = ['.mp3', '.wav', '.ogg', '.aac', '.m4a'].contains(ext);
    final isPdf = ext == '.pdf';

    Widget content;
    if (isImage) {
      content = ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          file,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (c, e, s) =>
              Icon(Icons.broken_image, color: Colors.white54, size: 32),
        ),
      );
    } else if (isVideo) {
      content = Stack(
        alignment: Alignment.center,
        children: [
          Container(
            color: Colors.black26,
            child: Icon(Icons.videocam, color: Colors.white54, size: 40),
          ),
          Icon(Icons.play_circle_fill, color: Colors.white, size: 48),
        ],
      );
    } else if (isPdf) {
      content = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.picture_as_pdf, color: Colors.red, size: 32),
          Text(
            'PDF',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
        ],
      );
    } else if (isAudio) {
      content = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.audiotrack, color: Colors.blue.shade900, size: 32),
          Text(
            ext.replaceFirst('.', '').toUpperCase(),
            style: TextStyle(
              color: Colors.blue.shade900,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
    } else {
      content = Center(
        child: Text(ext.toUpperCase(), style: TextStyle(color: Colors.white70)),
      );
    }

    return Stack(
      // TODO: Fix the dimensions
      children: [
        Container(
          width: 120,
          height: 72,
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.grey.shade800,
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: content,
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: IconButton(
            icon: Icon(Icons.close, color: Colors.white, size: 18),
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(),
            splashRadius: 16,
            onPressed: () => removeFile(file),
            tooltip: 'Remove',
          ),
        ),
      ],
    );
  }

  Future<void> generateQuiz(AppData appData) async {
    if (isGenerating) return;
    setState(() => isGenerating = true);
    try {
      final fileData = await getFileBytesAndMimeTypes();
      final generateQuizResponse = appData.generateQuiz(
        Content("user", [
          if (controller.text.isNotEmpty) TextPart(controller.text),
          ...fileData.map(
            (data) => InlineDataPart(
              data['mimetype'] as String,
              data['bytes'] as Uint8List,
            ),
          ),
        ]),
      );
      controllerTextSnapshot = controller.text;
      controller.clear();
      generateQuizResponse.progressText.listen(
        (text) => progressStreamController.add(text),
      );
      final quiz = await generateQuizResponse.quiz;
      print(quiz);
      setState(() => isGenerating = false);
      files.clear();
    } catch (e, st) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      print("$e\n$st");
    } finally {
      setState(() => isGenerating = false);
      controller.clear();
      files.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final sizes = MediaQuery.sizeOf(context);
    final appData = Provider.of<AppData>(context);
    final isMobile = sizes.width < 600;
    return AnimatedBuilder(
      animation: _shadowController,
      builder: (context, child) {
        return AnimatedContainer(
          duration: Durations.medium1,
          width: isMobile ? sizes.width * 0.9 : sizes.width * 0.6,
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            borderRadius: BorderRadius.circular(64),
            boxShadow: [
              if (isGenerating)
                BoxShadow(
                  color: _colorAnimation.value ?? Colors.pinkAccent,
                  blurRadius: _blurAnimation.value,
                ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(isMobile ? 2.0 : 8.0),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: isGenerating ? null : addFiles,
                      icon: Icon(Icons.add),
                      tooltip: 'Add files (PDF, images, audio, video)',
                    ),
                    Expanded(
                      child: StreamBuilder<String>(
                        stream: progressStreamController.stream,
                        builder: (context, snapshot) => TextField(
                          enabled: !isGenerating,
                          onSubmitted: (_) => generateQuiz(appData),
                          controller: controller,
                          decoration: InputDecoration(
                            hintText: isGenerating
                                ? "$controllerTextSnapshot ${snapshot.data ?? ""}"
                                : "Generate me a quiz about...",
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    IconButton.filled(
                      onPressed: isGenerating
                          ? null
                          : () => generateQuiz(appData),
                      icon: Icon(Icons.send),
                    ),
                  ],
                ),
                if (files.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    child: SizedBox(
                      height: 80,
                      child: GridView.builder(
                        scrollDirection: Axis.horizontal,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 1,
                          childAspectRatio: 4 / 3,
                          mainAxisSpacing: 4,
                        ),
                        itemCount: files.length,
                        itemBuilder: (context, idx) => buildFileBox(files[idx]),
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
}
