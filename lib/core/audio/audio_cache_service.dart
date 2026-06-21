import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:path_provider/path_provider.dart';

class AudioCacheService {
  Future<String> _getCacheKey(String text) async {
    final bytes = utf8.encode(text);
    final digest = sha256.convert(bytes);
    final tempDir = await getTemporaryDirectory();

    return '${tempDir.path}/tts_${digest.toString()}.mp3';
  }

  Future<File?> getCachedAudio(String text) async {
    final path = await _getCacheKey(text);
    final file = File(path);
    if (await file.exists()) {
      return file;
    }

    return null;
  }

  Future<File> saveAudioToCache(String text, List<int> audioBytes) async {
    final path = await _getCacheKey(text);
    final file = File(path);
    return await file.writeAsBytes(audioBytes);
  }
}
