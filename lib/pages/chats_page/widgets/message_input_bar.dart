import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class MessageInputBar extends StatefulWidget {
  final bool isSending;
  final Function(String, List<File>) onSend;

  const MessageInputBar({
    super.key,
    required this.isSending,
    required this.onSend,
  });

  @override
  State<MessageInputBar> createState() => _MessageInputBarState();
}

class _MessageInputBarState extends State<MessageInputBar> {
  final _controller = TextEditingController();
  final _files = <File>[];

  Future<void> _addFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.media,
    );
    if (result != null) {
      setState(() {
        _files.addAll(result.paths.whereType<String>().map((path) => File(path)));
      });
    }
  }

  void _removeFile(File file) {
    setState(() {
      _files.remove(file);
    });
  }

  void _onSend() {
    if (_controller.text.isEmpty && _files.isEmpty) return;
    widget.onSend(_controller.text, _files);
    _controller.clear();
    setState(() {
      _files.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_files.isNotEmpty)
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _files.length,
                itemBuilder: (context, index) {
                  final file = _files[index];
                  return Stack(
                    alignment: Alignment.topRight,
                    children: [
                      Container(
                        margin: const EdgeInsets.all(4),
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: FileImage(file),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => _removeFile(file),
                      ),
                    ],
                  );
                },
              ),
            ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: widget.isSending ? null : _addFiles,
                tooltip: 'Add media',
              ),
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: 'Type a message...',
                    border: InputBorder.none,
                  ),
                  onSubmitted: (_) => _onSend(),
                  enabled: !widget.isSending,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: widget.isSending ? null : _onSend,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
