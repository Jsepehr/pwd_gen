part of 'pwd_list_cubit.dart';

sealed class PwdListState extends Equatable {
  const PwdListState();

  @override
  List<Object> get props => [];
}

final class PwdListInitial extends PwdListState {}

class PwdListLoading extends PwdListState {}

class PwdListLoaded extends PwdListState {
  final List<PwdEntity> pwdList;
  final List<PwdEntity> pwdListSaved;
  final List<PwdEntity> pwdFilteredList;
  final List<PwdEntity> pwdListShow;
  final List<bool> opacityFlags;
  final bool isSearching;
  final int addingIndex;
  final TextEditingController secretString;

  const PwdListLoaded(
      {
   required this.secretString, 
        required this.pwdListShow,
      required this.opacityFlags,
      required this.isSearching,
      required this.pwdList,
      required this.pwdListSaved,
      required this.pwdFilteredList,
      required this.addingIndex,
      });

  @override
  List<Object> get props => [pwdListShow];
}

class PwdListError extends PwdListState {
  final String message;

  const PwdListError(this.message);
}
