part of 'pwd_editor_cubit.dart';

sealed class PwdEditorState extends Equatable {
  const PwdEditorState();

  @override
  List<Object> get props => [];
}

final class PwdEditorInitial extends PwdEditorState {}

class PwdEditorLoading extends PwdEditorState {}

class PwdEditorLoaded extends PwdEditorState {
  final String pwd;
  final String hint;
  final TextEditingController hintController;
  final TextEditingController pwdController;

  const PwdEditorLoaded({
    required this.pwd,
    required this.hint,
    required this.hintController,
    required this.pwdController,
  });

  @override
  List<Object> get props => [pwd, hint];
}

class PwdEditorError extends PwdEditorState {
  final String message;

  const PwdEditorError(this.message);
}
