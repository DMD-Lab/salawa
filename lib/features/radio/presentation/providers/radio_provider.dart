import 'package:audio_service/audio_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

const _radioUrl = 'http://n04a-eu.rcs.revma.com/7hnrkawf4p8uv.mp3';

enum RadioStatus { idle, loading, playing, paused, error }

class RadioState {
  const RadioState({
    this.status = RadioStatus.idle,
  });
  final RadioStatus status;

  bool get isPlaying => status == RadioStatus.playing;
  bool get isLoading => status == RadioStatus.loading;
  bool get hasError => status == RadioStatus.error;

  RadioState copyWith({RadioStatus? status}) =>
      RadioState(status: status ?? this.status);
}

class RadioNotifier extends Notifier<RadioState> {
  late final AudioPlayer _player;

  @override
  RadioState build() {
    _player = AudioPlayer();
    _player.playerStateStream.listen(_onStateChanged);
    _setup();
    ref.onDispose(() => _player.dispose());
    return const RadioState();
  }

  Future<void> _setup() async {
    try {
      await _player.setAudioSource(
        AudioSource.uri(
          Uri.parse(_radioUrl),
          tag: const MediaItem(
            id: 'radio-orient',
            title: 'Radio Orient',
            artist: 'En direct',
          ),
        ),
      );
    } catch (_) {
      state = state.copyWith(status: RadioStatus.error);
    }
  }

  void _onStateChanged(PlayerState playerState) {
    if (playerState.processingState == ProcessingState.loading ||
        playerState.processingState == ProcessingState.buffering) {
      state = state.copyWith(status: RadioStatus.loading);
    } else if (playerState.playing) {
      state = state.copyWith(status: RadioStatus.playing);
    } else if (playerState.processingState == ProcessingState.ready) {
      state = state.copyWith(status: RadioStatus.paused);
    } else if (playerState.processingState == ProcessingState.idle) {
      state = state.copyWith(status: RadioStatus.idle);
    }
  }

  Future<void> toggle() async {
    if (state.hasError) {
      state = state.copyWith(status: RadioStatus.idle);
      await _setup();
    }
    if (_player.playing) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  Future<void> retry() async {
    state = state.copyWith(status: RadioStatus.idle);
    await _setup();
    await _player.play();
  }
}

final radioProvider = NotifierProvider<RadioNotifier, RadioState>(
  RadioNotifier.new,
);
