import 'dart:typed_data';

class DownloadedFile {
  final Uint8List bytes;
  final String filename;
  final String contentType;

  DownloadedFile({
    required this.bytes,
    required this.filename,
    required this.contentType,
  });
}