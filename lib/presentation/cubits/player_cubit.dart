import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/radio_station.dart';

part 'player_state.dart';

/// Controls audio playback using [AudioPlayer] directly.
/// Listens to player state changes and reflects them in [RadioPlayerState].
class PlayerCubit extends Cubit<RadioPlayerState> {
  final AudioPlayer _player;
  StreamSubscription<PlayerState>? _stateSub;
  StreamSubscription<String>? _errorSub;

  PlayerCubit(this._player) : super(const RadioPlayerState()) {
    _stateSub = _player.onPlayerStateChanged.listen((ps) {
      switch (ps) {
        case PlayerState.playing:
          emit(state.copyWith(isPlaying: true, isLoading: false, clearError: true));
        case PlayerState.paused:
        case PlayerState.stopped:
          emit(state.copyWith(isPlaying: false, isLoading: false));
        case PlayerState.completed:
          emit(state.copyWith(isPlaying: false, isLoading: false));
        case PlayerState.disposed:
          break;
      }
    });
    _errorSub = _player.onLog.listen((msg) {
      if (state.isLoading) {
        emit(state.copyWith(
          isLoading: false,
          isPlaying: false,
          errorMessage: 'Failed to play station. Try another one.',
        ));
      }
    });
  }

  /// Stops current playback and starts streaming [station].
  Future<void> play(RadioStation station) async {
    emit(state.copyWith(currentStation: station, isLoading: true, isPlaying: false, clearError: true));
    try {
      await _player.stop();
      await _player.play(UrlSource(station.streamUrl)).timeout(const Duration(seconds: 20));
    } on TimeoutException {
      emit(state.copyWith(
        isLoading: false,
        isPlaying: false,
        errorMessage: 'Connection timed out. The station may be unavailable.',
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        isPlaying: false,
        errorMessage: 'Failed to play station. Try another one.',
      ));
    }
  }

  /// Pauses if playing, resumes if paused.
  Future<void> togglePlayPause() async {
    if (state.isPlaying) {
      await _player.pause();
    } else {
      await _player.resume();
    }
  }

  Future<void> setVolume(double volume) async {
    final clamped = volume.clamp(0.0, 1.0);
    await _player.setVolume(clamped);
    emit(state.copyWith(volume: clamped));
  }

  Future<void> volumeUp() => setVolume(state.volume + 0.1);
  Future<void> volumeDown() => setVolume(state.volume - 0.1);

  @override
  Future<void> close() async {
    await _stateSub?.cancel();
    await _errorSub?.cancel();
    await _player.dispose();
    return super.close();
  }
}
