import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pwd_gen/core/ingector.dart';
import 'package:pwd_gen/cubit/pwd_list_cubit.dart';
import 'package:pwd_gen/data/local/password_repository.dart';
import 'package:pwd_gen/data/models/pwd_model.dart';
import 'package:pwd_gen/main.dart';
import 'package:pwd_gen/repository/pwd_repository.dart';
import 'package:pwd_gen/view/widgets/dialog_generate_or_import.dart';
import 'package:pwd_gen/view/widgets/pwd_widget.dart';
import 'package:pwd_gen/view/widgets/search_field.dart';
import 'package:uuid/uuid.dart';
import 'pwd_list_viewmodel.dart';

class PwdListView extends StatelessWidget {
  PwdListView({super.key});
  // Recupera un singleton o una factory
  final myService = getIt<PasswordRepository>();

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PwdListCubit>(
      create: (context) => PwdListCubit(myService)..loadPwdsFromDb(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Passwords List'),
          actions: [
            IconButton(
              onPressed: () {}, //_viewModel.toggleSearch,
              icon: Icon(Icons
                  .search), /* Obx(
                () => Icon(
                  _viewModel.isSearching.value ? Icons.close : Icons.search,
                  color:
                      _viewModel.isSearching.value ? Colors.amberAccent : null,
                ),
              ), */
            ),
          ],
        ),
        body: BlocBuilder<PwdListCubit, PwdListState>(
          builder: (context, state) {
            if (state is PwdListLoaded) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /*  Obx(
                  () => AnimatedOpacity(
                    opacity: _viewModel.isSearching.value ? 1 : 0,
                    duration: Duration(milliseconds: 50),
                    child: _viewModel.isSearching.value
                        ? SearchField(
                            onChange: (val) => _viewModel.filterPwds(val),
                          )
                        : SizedBox.shrink(),
                  ),
                ), */

                  Expanded(
                    child: ListView.builder(
                      itemCount: state.pwdListShow.length + 1,
                      itemBuilder: (context, index) {
                        if (index == state.pwdListShow.length) {
                          return Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: SizedBox(
                              height: 50,
                              child: ElevatedButton(
                                onPressed: () async {
                                  await showDialog(
                                    context: context,
                                    builder: (context) =>
                                        DialogGenerateOrImport(),
                                  );
                                },
                                child: Icon(Icons.add),
                              ),
                            ),
                          );
                        }
                        return AnimatedOpacity(
                          opacity: state.opacityFlags[index] ? 1.0 : 0.0,
                          duration: Duration(milliseconds: 100),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 5.0, horizontal: 10),
                            child: SizedBox(
                              height: 50,
                              child: PwdWidget(
                                pwd: state.pwdListShow[index],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  )
                ],
              );
            } else {
              return Center(child: Text('error'));
            }
          },
        ),
      ),
    );
  }
}
