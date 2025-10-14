import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/audio_provider.dart';
import '../../utils/constants.dart';

class AudioPlayerWidget extends StatefulWidget {
  final String audioUrl;
  final String title;

  const AudioPlayerWidget({
    super.key,
    required this.audioUrl,
    required this.title,
  });

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget>
    with TickerProviderStateMixin {
  late AnimationController _playPauseController;
  late AnimationController _loadingController;

  @override
  void initState() {
    super.initState();
    _playPauseController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _loadingController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _playPauseController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioProvider>(
      builder: (context, audioProvider, child) {
        final isPlayingThisAudio = audioProvider.isAudioPlaying(widget.audioUrl);
        final isLoading = audioProvider.isLoading;

        if (isLoading && isPlayingThisAudio) {
          _loadingController.repeat();
        } else {
          _loadingController.stop();
          _loadingController.reset();
        }

        return GestureDetector(
          onTap: () => _togglePlayPause(audioProvider),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isPlayingThisAudio
                  ? const Color(AppConstants.primaryGreen).withOpacity(0.1)
                  : Colors.white,
              border: Border.all(
                color: isPlayingThisAudio
                    ? const Color(AppConstants.primaryGreen)
                    : Colors.grey[300]!,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: isPlayingThisAudio
                  ? [
                      BoxShadow(
                        color: const Color(AppConstants.primaryGreen).withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Play/Pause Icon with Animation
                SizedBox(
                  width: 20,
                  height: 20,
                  child: isLoading && isPlayingThisAudio
                      ? AnimatedBuilder(
                          animation: _loadingController,
                          builder: (context, child) {
                            return Transform.rotate(
                              angle: _loadingController.value * 2 * 3.14159,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(AppConstants.primaryGreen),
                                ),
                              ),
                            );
                          },
                        )
                      : AnimatedIcon(
                          icon: AnimatedIcons.play_pause,
                          progress: _playPauseController,
                          color: isPlayingThisAudio
                              ? const Color(AppConstants.primaryGreen)
                              : Colors.grey[600],
                          size: 20,
                        ),
                ),

                const SizedBox(width: 8),

                // Audio Text
                Text(
                  'Audio',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isPlayingThisAudio
                        ? const Color(AppConstants.primaryGreen)
                        : Colors.grey[600],
                    fontFamily: 'Poppins',
                  ),
                ),

                const SizedBox(width: 8),

                // Duration Indicator (if available)
                if (isPlayingThisAudio && audioProvider.totalDuration != Duration.zero)
                  Text(
                    audioProvider.formattedCurrentPosition,
                    style: TextStyle(
                      fontSize: 10,
                      color: isPlayingThisAudio
                          ? const Color(AppConstants.primaryGreen)
                          : Colors.grey[500],
                      fontFamily: 'Poppins',
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _togglePlayPause(AudioProvider audioProvider) async {
    final isPlayingThisAudio = audioProvider.isAudioPlaying(widget.audioUrl);

    if (isPlayingThisAudio) {
      // Pause current audio
      await audioProvider.pause();
      await _playPauseController.reverse();
    } else {
      // Play this audio
      await audioProvider.playFromUrl(widget.audioUrl, title: widget.title);
      await _playPauseController.forward();
    }
  }
}