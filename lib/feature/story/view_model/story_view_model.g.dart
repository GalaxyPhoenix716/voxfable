// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'story_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(elevenLabsService)
final elevenLabsServiceProvider = ElevenLabsServiceProvider._();

final class ElevenLabsServiceProvider
    extends
        $FunctionalProvider<
          ElevenLabsService,
          ElevenLabsService,
          ElevenLabsService
        >
    with $Provider<ElevenLabsService> {
  ElevenLabsServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'elevenLabsServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$elevenLabsServiceHash();

  @$internal
  @override
  $ProviderElement<ElevenLabsService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ElevenLabsService create(Ref ref) {
    return elevenLabsService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ElevenLabsService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ElevenLabsService>(value),
    );
  }
}

String _$elevenLabsServiceHash() => r'24e54c6d2441f7ea76b80b773ec0ec4a0801bb96';

@ProviderFor(audioPlayer)
final audioPlayerProvider = AudioPlayerProvider._();

final class AudioPlayerProvider
    extends $FunctionalProvider<AudioPlayer, AudioPlayer, AudioPlayer>
    with $Provider<AudioPlayer> {
  AudioPlayerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'audioPlayerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$audioPlayerHash();

  @$internal
  @override
  $ProviderElement<AudioPlayer> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AudioPlayer create(Ref ref) {
    return audioPlayer(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AudioPlayer value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AudioPlayer>(value),
    );
  }
}

String _$audioPlayerHash() => r'cc47a6893f6fe3d9b1f92a98bd3c083d03f17354';

@ProviderFor(StoryViewModel)
final storyViewModelProvider = StoryViewModelProvider._();

final class StoryViewModelProvider
    extends $NotifierProvider<StoryViewModel, StoryState> {
  StoryViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'storyViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$storyViewModelHash();

  @$internal
  @override
  StoryViewModel create() => StoryViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StoryState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StoryState>(value),
    );
  }
}

String _$storyViewModelHash() => r'b48b743887de3e943c729784c0b82d2151963c17';

abstract class _$StoryViewModel extends $Notifier<StoryState> {
  StoryState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<StoryState, StoryState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<StoryState, StoryState>,
              StoryState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
