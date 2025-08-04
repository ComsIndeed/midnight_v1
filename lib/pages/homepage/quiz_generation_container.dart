import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:midnight_v1/blocs/quizzes_bloc/quizzes_bloc.dart';
import 'package:midnight_v1/utils/file_helpers.dart';
import 'package:file_picker/file_picker.dart';

class QuizGenerationContainer extends StatefulWidget {
  const QuizGenerationContainer({super.key});

  @override
  State<QuizGenerationContainer> createState() =>
      _QuizGenerationContainerState();
}

class _QuizGenerationContainerState extends State<QuizGenerationContainer>
    with SingleTickerProviderStateMixin {
  final controller = TextEditingController();
  List<File> files = [];
  String controllerTextSnapshot = "";

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

  Future<void> generateQuiz(bool isGenerating) async {
    if (isGenerating) return;
    try {
      final fileData = await getFileBytesAndMimeTypes(files);
      final content = Content("user", [
        if (controller.text.isNotEmpty) TextPart(controller.text),
        ...fileData.map(
          (data) => InlineDataPart(
            data['mimetype'] as String,
            data['bytes'] as Uint8List,
          ),
        ),
      ]);
      context.read<QuizzesBloc>().add(GenerateQuiz(content));
      controllerTextSnapshot = controller.text;
      controller.clear();
      setState(() {
        files.clear();
      });
    } catch (e, st) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      print("$e\n$st");
    }
  }

  @override
  Widget build(BuildContext context) {
    final sizes = MediaQuery.sizeOf(context);
    final isMobile = sizes.width < 600;
    return BlocBuilder<QuizzesBloc, QuizzesState>(
      builder: (context, state) {
        final isGenerating = state is QuizGenerationInProgress;
        if (isGenerating) {
          _shadowController.repeat(reverse: true);
        } else {
          _shadowController.stop();
        }

        return AnimatedBuilder(
          animation: _shadowController,
          builder: (context, child) {
            return AnimatedContainer(
              duration: Durations.medium1,
              width: isMobile ? sizes.width * 0.9 : sizes.width * 0.6,
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: BorderRadius.circular(24),
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
                          icon: const Icon(Icons.add),
                          tooltip: 'Add files (PDF, images, audio, video)',
                        ),
                        Expanded(
                          child: TextField(
                            enabled: !isGenerating,
                            onSubmitted: (_) => generateQuiz(isGenerating),
                            controller: controller,
                            decoration: InputDecoration(
                              hintText: isGenerating
                                  ? "$controllerTextSnapshot..."
                                  : "Generate me a quiz about...",
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        IconButton.filled(
                          onPressed: isGenerating ? null : () => generateQuiz(isGenerating),
                          icon: const Icon(Icons.send),
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
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 1,
                                  childAspectRatio: 4 / 3,
                                  mainAxisSpacing: 4,
                                ),
                            itemCount: files.length,
                            itemBuilder: (context, idx) =>
                                buildFileBox(files[idx], () => removeFile(files[idx])),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
