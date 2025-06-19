import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '/core/app_pallet.dart';
import '/view/widgets/pwd_keyword_input/cubit_pwd_keword/pwd_keyword_cubit.dart';
import '/view/widgets/shared/edit_pwd_textfield.dart';



class PwdKeyWordBottomSheet extends StatefulWidget {
  final int index;
  const PwdKeyWordBottomSheet({
    super.key,
    required this.index,
  });
  @override
  State<PwdKeyWordBottomSheet> createState() => _PwdKeyWordBottomSheetState();
}

class _PwdKeyWordBottomSheetState extends State<PwdKeyWordBottomSheet> {
  late PwdKeyWordCubit cubit;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      cubit = context.read<PwdKeyWordCubit>();
      cubit.focusNode.requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      // 👇 Pushes content above the keyboard
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          color: AppPallet.bottomSheetBG,
          height: 250,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 0),
            child: BlocBuilder<PwdKeyWordCubit, PwdKeyWordState>(
              builder: (context, state) {
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Icon(
                          Icons.edit,
                          color: AppPallet.bottomSheetTitleIcon,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 50,
                      child: state is PwdKeyWordLoaded
                          ? EditPwdTextField(
                              focusNode: state.focusNode,
                              controller: state.hintController,
                              onChange: (p0) {
                                cubit.keyWordStr = p0;
                              },
                            )
                          : CircularProgressIndicator(),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        state is PwdKeyWordLoaded
                            ? ElevatedButton(
                                onPressed: () async {
                                  // TODO
                                  // confront with the keyword saved on file in binary
                                  Navigator.pop(context);
                                },
                                child: Text('Apply'))
                            : CircularProgressIndicator(),
                        ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('Dismiss')),
                      ],
                    )
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
