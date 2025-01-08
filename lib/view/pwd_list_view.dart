import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pwd_gen/data/models/pwd_model.dart';
import 'package:pwd_gen/view/widgets/dialog_generate_or_import.dart';
import 'package:pwd_gen/view/widgets/pwd_widget.dart';
import 'package:pwd_gen/view/widgets/search_field.dart';
import 'package:uuid/uuid.dart';
import 'pwd_list_viewmodel.dart';

class PwdListView extends StatelessWidget {
  final PwdListViewModel _viewModel = Get.put(PwdListViewModel());
  PwdListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Passwords List'),
        actions: [
          IconButton(
            onPressed: _viewModel.toggleSearch,
            icon: Obx(() => Icon(
                  _viewModel.isSearching.value ? Icons.close : Icons.search,
                  color:
                      _viewModel.isSearching.value ? Colors.amberAccent : null,
                )),
          ),
        ],
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Obx(
            () => AnimatedOpacity(
              opacity: _viewModel.isSearching.value ? 1 : 0,
              duration: Duration(milliseconds: 50),
              child: _viewModel.isSearching.value
                  ? SearchField(
                      onChange: (val) => _viewModel.filterPwds(val),
                    )
                  : SizedBox.shrink(),
            ),
          ),
          Obx(() {
            return Expanded(
              child: ListView.builder(
                itemCount: _viewModel.pwdListShow.length + 1,
                itemBuilder: (context, index) {
                  if (index == _viewModel.pwdListShow.length) {
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () async {
                            await Get.dialog(
                              DialogGenerateOrImport(),
                            );
                            /* final List<PwdModel> pwds = [
                              PwdModel(
                                  hint: 'Hint ',
                                  password: 'asdfFASFDF ILil',
                                  usageCount: 0,
                                  id: Uuid().v4()),
                              PwdModel(
                                  hint: 'Hint ',
                                  password: 'Pwd',
                                  usageCount: 0,
                                  id: Uuid().v4()),
                              PwdModel(
                                  hint: 'Hint ',
                                  password: 'Pwd',
                                  usageCount: 0,
                                  id: Uuid().v4())
                            ];
                            //_viewModel.pwdList.addAll(pwds);
                            await _viewModel.showPwds(pwds);
                            _viewModel.saveOnLocalDb(); */
                          },
                          child: Icon(Icons.add),
                        ),
                      ),
                    );
                  }
                  return Obx(
                    () => AnimatedOpacity(
                      opacity: _viewModel.opacityFlags[index] ? 1.0 : 0.0,
                      duration: Duration(milliseconds: 100),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 5.0, horizontal: 10),
                        child: SizedBox(
                          height: 50,
                          child: PwdWidget(
                            pwd: _viewModel.pwdListShow[index],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}
