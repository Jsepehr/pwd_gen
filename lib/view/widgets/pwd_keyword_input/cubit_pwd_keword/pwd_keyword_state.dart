part of 'pwd_keyword_cubit.dart';

sealed class PwdKeyWordState extends Equatable {
  const PwdKeyWordState();

  @override
  List<Object> get props => [];
}

final class PwdKeyWordInitial extends PwdKeyWordState {}

class PwdKeyWordLoading extends PwdKeyWordState {}

class PwdKeyWordLoaded extends PwdKeyWordState {

  final String keyWord;
  final TextEditingController hintController;

  final FocusNode focusNode;

  const PwdKeyWordLoaded({
    required this.focusNode,
    required this.keyWord,
    required this.hintController,

  });

  @override
  List<Object> get props => [keyWord, focusNode];
}

class PwdKeyWordError extends PwdKeyWordState {
  final String message;

  const PwdKeyWordError(this.message);
}
