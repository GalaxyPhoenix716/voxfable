import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:voxfable/core/audio/audio_cache_service.dart';

class ElevenLabsService {
  final Dio _dio;
  final AudioCacheService _cacheService;

  static final String _apiKey = dotenv.env['ELEVENLABS_API_KEY']!;
  static const String _voiceId = 'rv30Fd6w5bnbL0kHzWlr'; //alice
  static const String _modelId = 'eleven_multilingual_v2';
  static const String _apiUrl =
      'https://api.elevenlabs.io/v1/text-to-speech/$_voiceId';

  ElevenLabsService({Dio? dio, AudioCacheService? cacheService})
    : _dio = dio ?? Dio(),
      _cacheService = cacheService ?? AudioCacheService();

  Future<File> fetchTTS(String text) async {
    //check if audio exists in cache
    final cachedFile = await _cacheService.getCachedAudio(text);
    if (cachedFile != null) {
      return cachedFile;
    }

    //if not then call api
    final response = await _dio.post<List<int>>(
      _apiUrl,
      options: Options(
        headers: {'xi_api_key': _apiKey, 'Content-Type': 'application/json'},
        responseType: ResponseType.bytes,
      ),
      data: {
        'text': text,
        'model_id': _modelId,
        'voice_settings': {'stability': 0.75, 'similarity_boost': 0.85},
      },
    );

    //cache the audio or throw error :)
    if (response.statusCode == 200 && response.data != null) {
      return await _cacheService.saveAudioToCache(text, response.data!);
    } else {
      throw Exception('ElevenLabs TTS Failed: ${response.statusCode}');
    }
  }
}
