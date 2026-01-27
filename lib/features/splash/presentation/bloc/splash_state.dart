import 'package:equatable/equatable.dart';

abstract class SplashState extends Equatable {
  const SplashState();

  @override
  List<Object?> get props => [];
}

class SplashInitial extends SplashState {
  const SplashInitial();
}

class SplashLoading extends SplashState {
  const SplashLoading();
}

class SplashAuthenticated extends SplashState {
  const SplashAuthenticated();
}

class SplashUnauthenticated extends SplashState {
  final bool needsOnboarding;

  const SplashUnauthenticated({this.needsOnboarding = false});

  @override
  List<Object?> get props => [needsOnboarding];
}

