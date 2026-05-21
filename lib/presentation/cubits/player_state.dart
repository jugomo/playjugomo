part of 'player_cubit.dart';

/// Immutable state for the radio player.
class RadioPlayerState extends Equatable {
  final RadioStation? currentStation;
  final bool isPlaying;
  final bool isLoading;
  final double volume;
  final String? errorMessage;

  const RadioPlayerState({
    this.currentStation,
    this.isPlaying = false,
    this.isLoading = false,
    this.volume = 1.0,
    this.errorMessage,
  });

  RadioPlayerState copyWith({
    RadioStation? currentStation,
    bool? isPlaying,
    bool? isLoading,
    double? volume,
    String? errorMessage,
    bool clearError = false,
  }) {
    return RadioPlayerState(
      currentStation: currentStation ?? this.currentStation,
      isPlaying: isPlaying ?? this.isPlaying,
      isLoading: isLoading ?? this.isLoading,
      volume: volume ?? this.volume,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [currentStation, isPlaying, isLoading, volume, errorMessage];
}
