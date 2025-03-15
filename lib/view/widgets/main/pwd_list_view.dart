import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:pwd_gen/core/injector.dart';
import 'package:pwd_gen/view/widgets/main/cubit_pwds_list/pwd_list_cubit.dart';
import 'package:pwd_gen/domain/pwd_entity.dart';
import 'package:pwd_gen/view/widgets/shared/dialog_generate_or_import.dart';
import 'package:pwd_gen/view/widgets/pwd_edit/pwd_editor_bottom_sheet.dart';
import 'package:pwd_gen/view/widgets/shared/pwd_widget.dart';
import 'package:pwd_gen/view/widgets/shared/search_field.dart';

class PwdListView extends StatelessWidget {
  const PwdListView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.save_outlined),
          onPressed: ()  {
             context.read<PwdListCubit>().wrightContentToFile();
          },
        ),
        title: Text('Passwords List'),
        actions: [
          IconButton(
            onPressed: () {
              context.read<PwdListCubit>().toggleSearch();
            },
            icon: Icon(Icons.search),
          ),
        ],
      ),
      body: BlocBuilder<PwdListCubit, PwdListState>(
        builder: (context, state) {
          if (state is PwdListLoaded) {
            return Stack(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedSwitcher(
                      duration: Duration(milliseconds: 500),
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SizeTransition(
                            sizeFactor: animation,
                            axisAlignment: -1.0,
                            child: child,
                          ),
                        );
                      },
                      child: state.isSearching
                          ? SearchField(
                              key:
                                  ValueKey(1), // Important for AnimatedSwitcher
                              onChange: (value) {
                                context.read<PwdListCubit>().searchThis(value);
                              },
                            )
                          : SizedBox.shrink(
                              key: ValueKey(2)), // Ensures transition happens
                    ),
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
                            duration: Duration(milliseconds: 300),
                            curve: Curves.bounceInOut,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 5.0, horizontal: 10),
                              child: SizedBox(
                                height: 50,
                                child: PwdWidget(
                                  pwd: state.pwdListShow[index],
                                  onEdit: () async {
                                    getIt<PwdEntityEdit>().update(
                                        hint: state.pwdListShow[index].hint,
                                        password:
                                            state.pwdListShow[index].password,
                                        index: index);

                                    await showModalBottomSheet(
                                      enableDrag: false,
                                      isDismissible: state.isLoading,
                                      context: context,
                                      builder: (context) {
                                        return PwdEditorBottomSheet(
                                          index: index,
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  ],
                ),
                state.isLoading
                    ? Container(
                        color: const Color.fromARGB(200, 0, 0, 0),
                        child: Center(
                          child: LoadingAnimationWidget.threeArchedCircle(
                              color: const Color.fromARGB(255, 0, 102, 192),
                              size: 50),
                        ),
                      )
                    : SizedBox.shrink()
              ],
            );
          } else {
            return Center(child: Text('error'));
          }
        },
      ),
    );
  }
}
