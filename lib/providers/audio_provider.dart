import 'package:flutter/material.dart';
import '../services/audio_service.dart';
import '../services/api_service.dart';

class AudioProvider with ChangeNotifier {
  final AudioService _audioService = AudioService();

  bool _isPlaying = false;
  bool _isLoading = false;
  String? _currentAudioUrl;
  String? _currentAudioTitle;
  double _volume = 1.0;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  String? _error;

  // Getters
  bool get isPlaying => _isPlaying;
  bool get isLoading => _isLoading;
  String? get currentAudioUrl => _currentAudioUrl;
  String? get currentAudioTitle => _currentAudioTitle;
  double get volume => _volume;
  Duration get currentPosition => _currentPosition;
  Duration get totalDuration => _totalDuration;
  String? get error => _error;
  bool get hasAudio => _currentAudioUrl != null;

  // Progress
  double get progress => _totalDuration.inMilliseconds > 0
      ? _currentPosition.inMilliseconds / _totalDuration.inMilliseconds
      : 0.0;

  // Initialize audio provider
  Future<void> initialize() async {
    await _audioService.initialize();
    _volume = _audioService.audioVolume;

  }

  // Play audio from URL
  Future<void> playFromUrl(String audioUrl, {String? title}) async {
    _setLoading(true);
    _clearError();

    try {
      // Stop current playback if different audio
      if (_currentAudioUrl != audioUrl) {
        await stop();
      }

      final response = await _audioService.playFromUrl(audioUrl);
      if (response.isSuccess) {
        _currentAudioUrl = audioUrl;
        _currentAudioTitle = title;
        _isPlaying = true;

        // Start position tracking
        _startPositionTracking();
      } else {
        _setError(response.error!);
      }
    } catch (e) {
      _setError('Failed to play audio: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Play from asset
  Future<void> playFromAsset(String assetPath, {String? title}) async {
    _setLoading(true);
    _clearError();

    try {
      await stop();

      final response = await _audioService.playFromAsset(assetPath);
      if (response.isSuccess) {
        _currentAudioUrl = assetPath;
        _currentAudioTitle = title;
        _isPlaying = true;
        _startPositionTracking();
      } else {
        _setError(response.error!);
      }
    } catch (e) {
      _setError('Failed to play asset: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Pause playback
  Future<void> pause() async {
    await _audioService.pause();
    _isPlaying = false;
    notifyListeners();
  }

  // Resume playback
  Future<void> resume() async {
    await _audioService.resume();
    _isPlaying = true;
    notifyListeners();
  }

  // Stop playback
  Future<void> stop() async {
    await _audioService.stop();
    _isPlaying = false;
    _currentAudioUrl = null;
    _currentAudioTitle = null;
    _currentPosition = Duration.zero;
    _totalDuration = Duration.zero;
    notifyListeners();
  }

  // Toggle play/pause
  Future<void> togglePlayPause() async {
    if (_isPlaying) {
      await pause();
    } else if (_currentAudioUrl != null) {
      await resume();
    }
  }

  // Set volume
  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
    await _audioService.setVolume(_volume);
    notifyListeners();
  }

  // Seek to position
  Future<void> seekTo(Duration position) async {
    await _audioService.seek(position);
    _currentPosition = position;
    notifyListeners();
  }

  // Seek to percentage
  Future<void> seekToPercentage(double percentage) async {
    final position = Duration(
      milliseconds: (_totalDuration.inMilliseconds * percentage).round(),
    );
    await seekTo(position);
  }

  // Start position tracking
  void _startPositionTracking() async {
    // Update duration
    _totalDuration = await _audioService.getDuration() ?? Duration.zero;

    // Track position every second
    while (_isPlaying && _currentAudioUrl != null) {
      await Future.delayed(const Duration(seconds: 1));

      if (_isPlaying && _currentAudioUrl != null) {
        _currentPosition = await _audioService.getCurrentPosition() ?? Duration.zero;
        notifyListeners();

        // Check if audio finished
        if (_currentPosition >= _totalDuration && _totalDuration.inMilliseconds > 0) {
          _isPlaying = false;
          _currentPosition = _totalDuration;
          notifyListeners();
          break;
        }
      }
    }
  }

  // Check if specific audio is playing
  bool isAudioPlaying(String audioUrl) {
    return _isPlaying && _currentAudioUrl == audioUrl;
  }

  // Format duration for display
  String formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // Get formatted current time
  String get formattedCurrentPosition => formatDuration(_currentPosition);

  // Get formatted total time
  String get formattedTotalDuration => formatDuration(_totalDuration);

  // Get formatted time remaining
  String get formattedTimeRemaining {
    final remaining = _totalDuration - _currentPosition;
    return formatDuration(remaining);
  }

  // Clear audio cache
  Future<void> clearCache() async {
    await _audioService.clearCache();
  }

  // Get cache size
  Future<String> getCacheSize() async {
    final sizeBytes = await _audioService.getCacheSize();
    if (sizeBytes < 1024) {
      return '$sizeBytes B';
    } else if (sizeBytes < 1024 * 1024) {
      return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    stop();
    _audioService.dispose();
    super.dispose();
  }
}