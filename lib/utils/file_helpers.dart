import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

Future<List<Map<String, dynamic>>> getFileBytesAndMimeTypes(List<File> files) async {
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

Widget buildFileBox(File file, VoidCallback onRemove) {
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
            const Icon(Icons.broken_image, color: Colors.white54, size: 32),
      ),
    );
  } else if (isVideo) {
    content = const Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          child: Icon(Icons.videocam, color: Colors.white54, size: 40),
        ),
        Icon(Icons.play_circle_fill, color: Colors.white, size: 48),
      ],
    );
  } else if (isPdf) {
    content = const Column(
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
      child: Text(
        ext.toUpperCase(),
        style: const TextStyle(color: Colors.white70),
      ),
    );
  }

  return Stack(
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
          icon: const Icon(Icons.close, color: Colors.white, size: 18),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          splashRadius: 16,
          onPressed: onRemove,
          tooltip: 'Remove',
        ),
      ),
    ],
  );
}
