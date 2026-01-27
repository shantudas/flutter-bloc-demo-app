import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../core/storage/settings_storage_service.dart';
import 'splash_event.dart';
import 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  final SecureStorageService secureStorage;
  final SettingsStorageService settingsStorage;

  SplashBloc({
    required this.secureStorage,
    required this.settingsStorage,
  }) : super(const SplashInitial()) {
    on<SplashInitialize>(_onInitialize);
  }

  Future<void> _onInitialize(
    SplashInitialize event,
    Emitter<SplashState> emit,
  ) async {
    emit(const SplashLoading());

    // Wait minimum splash duration
    await Future.delayed(AppConstants.minSplashDuration);

    // Check if onboarding is completed
    final onboardingCompleted = settingsStorage.isOnboardingCompleted;

    // Check if user has valid tokens
    final accessToken = await secureStorage.getAccessToken();

    if (accessToken != null) {
      // User is authenticated
      emit(const SplashAuthenticated());
    } else {
      // User is not authenticated
      emit(SplashUnauthenticated(needsOnboarding: !onboardingCompleted));
    }
  }
}

