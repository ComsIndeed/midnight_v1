import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';

abstract class Source {
  Map<String, dynamic> toMap();
  String toJson();
  Uint8List toBytes();
}

class FileSource extends Source {
  final File file;
  FileSource(this.file);

  @override
  Map<String, dynamic> toMap() {
    return {'path': file.path.replaceAll('\\', '/')};
  }

  @override
  String toJson() {
    return jsonEncode(toMap());
  }

  factory FileSource.fromMap(Map<String, dynamic> map) {
    return FileSource(
      File(map['path'].replaceAll('/', Platform.pathSeparator)),
    );
  }

  factory FileSource.fromJson(String json) {
    return FileSource.fromMap(jsonDecode(json));
  }

  static FileSource fromBytesSync(Uint8List bytes, {String? filePath}) {
    final tempDir = Directory.systemTemp.createTempSync();
    final tempFile = File(
      '${tempDir.path}/temp_file_${DateTime.now().millisecondsSinceEpoch}.tmp',
    );
    tempFile.writeAsBytesSync(bytes);
    return FileSource(tempFile);
  }

  @override
  Uint8List toBytes() {
    return file.readAsBytesSync();
  }

  static Future<FileSource> fromBytes(
    Uint8List bytes, {
    String? filePath,
  }) async {
    final tempDir = await Directory.systemTemp.createTemp();
    final tempFile = File(
      '${tempDir.path}/temp_file_${DateTime.now().millisecondsSinceEpoch}.tmp',
    );
    await tempFile.writeAsBytes(bytes);
    return FileSource(tempFile);
  }

  Future<Uint8List> toBytesAsync() async {
    return await file.readAsBytes();
  }
}
