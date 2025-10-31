import 'package:audioplayers/audioplayers.dart';

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  final AudioPlayer _bgPlayer = AudioPlayer();
  bool _isPlaying = false;

  //background musik
  Future<void> playBackgroundMusic() async {
    if (_isPlaying) return;

    await _bgPlayer.setPlayerMode(PlayerMode.mediaPlayer);
    await _bgPlayer.setReleaseMode(ReleaseMode.loop);
    await _bgPlayer.play(AssetSource("sounds/bg_music.mp3"));
    await _bgPlayer.setVolume(0.1);
    _isPlaying = true;
  }

  Future<void> stopBackgroundMusic() async {
    await _bgPlayer.stop();
    _isPlaying = false;
  }

  //putar suara
  Future<void> playVoice(String assetPath) async {
    final player = AudioPlayer();

    await player.setAudioContext(
      AudioContext(
        android: AudioContextAndroid(
          isSpeakerphoneOn: false,
          stayAwake: false,
          contentType: AndroidContentType.sonification,
          usageType: AndroidUsageType.game,
          audioFocus: AndroidAudioFocus.none,
        ),
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.playback,
          options: {AVAudioSessionOptions.mixWithOthers},
        ),
      ),
    );

    await player.setPlayerMode(PlayerMode.lowLatency);
    await player.play(AssetSource(assetPath));
  }
}
