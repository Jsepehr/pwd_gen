part of 'pwd_list_cubit.dart';

sealed class PwdListState extends Equatable {
  const PwdListState();

  @override
  List<Object> get props => [];
}

final class PwdListInitial extends PwdListState {}

class PwdListLoading extends PwdListState {}

class PwdListLoaded extends PwdListState {
  final List<PwdEntity> pwdListShow;

  final bool isSearching;
  final bool isLoading;

  const PwdListLoaded({
    required this.pwdListShow,
    required this.isSearching,
    required this.isLoading,

  });

  @override
  List<Object> get props => [pwdListShow, isSearching, isLoading,];
}

class PwdListError extends PwdListState {
  final String message;

  const PwdListError(this.message);
}
