import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;

/// Client-side image → WebP conversion (keeps original resolution).
/// Server-side [Helpers::upload] also converts; this shrinks upload payloads.
class ImageConverter {
  static const int quality = 82;

  static const Set<String> _convertibleExt = {
    'jpg',
    'jpeg',
    'png',
    'gif',
    'bmp',
    'webp',
    'tif',
    'tiff',
  };

  static const Set<String> _skipExt = {
    'mp4',
    'mov',
    'avi',
    'mkv',
    'webm',
    'pdf',
    'doc',
    'docx',
    'p8',
    'zip',
  };

  static bool isConvertibleImage(String? path, {String? key}) {
    final keyLower = (key ?? '').toLowerCase();
    if (keyLower.contains('video') || keyLower.contains('document')) {
      return false;
    }

    final ext = p.extension(path ?? '').toLowerCase().replaceAll('.', '');
    if (_skipExt.contains(ext)) {
      return false;
    }
    if (ext.isEmpty) {
      return true;
    }
    return _convertibleExt.contains(ext);
  }

  static Future<ConvertedImage?> toWebp(XFile file, {String? key}) async {
    if (!isConvertibleImage(file.path, key: key) &&
        !isConvertibleImage(file.name, key: key)) {
      return null;
    }

    try {
      final original = await file.readAsBytes();
      if (original.isEmpty) {
        return null;
      }

      final decoded = img.decodeImage(original);
      final width = decoded?.width ?? 100000;
      final height = decoded?.height ?? 100000;

      Uint8List? best;
      for (final q in <int>[quality, 67, 52]) {
        final compressed = await FlutterImageCompress.compressWithList(
          original,
          minWidth: width,
          minHeight: height,
          quality: q,
          format: CompressFormat.webp,
          keepExif: false,
        );
        if (compressed.isEmpty) {
          continue;
        }
        if (best == null || compressed.length < best.length) {
          best = compressed;
        }
        if (compressed.length <= original.length) {
          break;
        }
      }

      if (best == null || best.isEmpty) {
        return null;
      }

      final base = p.basenameWithoutExtension(
        file.name.isNotEmpty ? file.name : file.path,
      );
      final filename = '${base.isEmpty ? 'image' : base}.webp';

      if (kDebugMode) {
        debugPrint(
          'ImageConverter: ${original.length} → ${best.length} bytes ($filename)',
        );
      }

      return ConvertedImage(bytes: best, filename: filename);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ImageConverter failed: $e');
      }
      return null;
    }
  }
}

class ConvertedImage {
  final Uint8List bytes;
  final String filename;

  const ConvertedImage({required this.bytes, required this.filename});
}
