// ignore_for_file: must_be_immutable

part of 'config_pwds_cubit.dart';

sealed class ConfigPwdsState extends Equatable {
  const ConfigPwdsState();

  @override
  List<Object> get props => [];
}

final class ConfigPwdsInitial extends ConfigPwdsState {}

class ConfigPwdsLoading extends ConfigPwdsState {}

class ConfigPwdsLoaded extends ConfigPwdsState {
  final String secretPhrase;
  bool isGenerateBtnEnabled;
  bool isImageBtnEnabled;
  File? image;

  ConfigPwdsLoaded({
    required this.secretPhrase,
    required this.isGenerateBtnEnabled,
    required this.isImageBtnEnabled,
    this.image,
  });
  @override
  List<Object> get props => [isImageBtnEnabled, isGenerateBtnEnabled];
}

class ConfigPwdsError extends ConfigPwdsState {
  final String message;

  const ConfigPwdsError(this.message);
}
