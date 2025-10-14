import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  final Map<String, String> _cachedFiles = {};

  String? _currentlyPlaying;
  bool _isPlaying = false;
  double _volume = 1.0; // Track current volume

  // Initialize audio service
  Future<void> initialize() async {
    _audioPlayer.onPlayerStateChanged.listen((state) {
      _isPlaying = state == PlayerState.playing;
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      _currentlyPlaying = null;
      _isPlaying = false;
    });
  }

  // Play audio from URL
  Future<ApiResponse<void>> playFromUrl(String audioUrl) async {
    try {
      // Stop current playback
      await stop();

      // Check if file is cached
      String? localPath = _cachedFiles[audioUrl];

      if (localPath == null || !File(localPath).existsSync()) {
        // Download and cache the file
        final cacheResponse = await _cacheAudioFile(audioUrl);
        if (!cacheResponse.isSuccess) {
          return ApiResponse.error(cacheResponse.error!);
        }
        localPath = cacheResponse.data!;
      }

      // Play from local file
      await _audioPlayer.play(DeviceFileSource(localPath));
      _currentlyPlaying = audioUrl;

      return ApiResponse.success(null);
    } catch (e) {
      return ApiResponse.error('Failed to play audio: ${e.toString()}');
    }
  }

  // Play from local asset
  Future<ApiResponse<void>> playFromAsset(String assetPath) async {
    try {
      await stop();
      await _audioPlayer.play(AssetSource(assetPath));
      _currentlyPlaying = assetPath;
      return ApiResponse.success(null);
    } catch (e) {
      return ApiResponse.error('Failed to play asset: ${e.toString()}');
    }
  }

  // Pause playback
  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  // Resume playback
  Future<void> resume() async {
    await _audioPlayer.resume();
  }

  // Stop playback
  Future<void> stop() async {
    await _audioPlayer.stop();
    _currentlyPlaying = null;
    _isPlaying = false;
  }

  // Set volume (0.0 to 1.0)
  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
    await _audioPlayer.setVolume(_volume);
  }

  // Seek to position
  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  // Get current position
  Future<Duration?> getCurrentPosition() async {
    return await _audioPlayer.getCurrentPosition();
  }

  // Get duration
  Future<Duration?> getDuration() async {
    return await _audioPlayer.getDuration();
  }

  // Cache audio file locally
  Future<ApiResponse<String>> _cacheAudioFile(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) {
        return ApiResponse.error('Failed to download audio file');
      }

      final directory = await getApplicationDocumentsDirectory();
      final cacheDir = Directory('${directory.path}/audio_cache');
      if (!cacheDir.existsSync()) {
        cacheDir.createSync(recursive: true);
      }

      final filename = url.split('/').last.split('?').first;
      final file = File('${cacheDir.path}/$filename');
      await file.writeAsBytes(response.bodyBytes);

      _cachedFiles[url] = file.path;
      return ApiResponse.success(file.path);
    } catch (e) {
      return ApiResponse.error('Failed to cache audio: ${e.toString()}');
    }
  }

  // Clear audio cache
  Future<void> clearCache() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final cacheDir = Directory('${directory.path}/audio_cache');
      if (cacheDir.existsSync()) {
        await cacheDir.delete(recursive: true);
      }
      _cachedFiles.clear();
    } catch (e) {
      print('Error clearing audio cache: $e');
    }
  }

  // Get cache size
  Future<int> getCacheSize() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final cacheDir = Directory('${directory.path}/audio_cache');
      if (!cacheDir.existsSync()) return 0;

      int totalSize = 0;
      await for (final file in cacheDir.list(recursive: true)) {
        if (file is File) {
          totalSize += await file.length();
        }
      }
      return totalSize;
    } catch (e) {
      return 0;
    }
  }

  // Getters
  bool get isPlaying => _isPlaying;
  String? get currentlyPlaying => _currentlyPlaying;
  double get audioVolume => _volume;

  // Dispose
  void dispose() {
    _audioPlayer.dispose();
  }
}