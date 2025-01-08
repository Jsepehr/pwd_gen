import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pwd_gen/view/widgets/pwd_configure_bottom_sheet.dart';

class DialogGenerateOrImport extends StatelessWidget {
  const DialogGenerateOrImport({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 100,
          width: 150,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15), // Adjust the radius as needed
                  bottomLeft:
                      Radius.circular(15), // Adjust the radius as needed
                ),
              ),
            ),
            onPressed: () async {
              Get.back();
              await Get.bottomSheet(
                PwdConfigureBottomSheet(),
              );
            },
            child: const Text('Generate'),
          ),
        ),
        SizedBox(
          width: 1,
        ),
        SizedBox(
          height: 100,
          width: 150,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(15), // Adjust the radius as needed
                  bottomRight:
                      Radius.circular(15), // Adjust the radius as needed
                ),
              ),
            ),
            onPressed: () {
              Navigator.pop(context); // Handle Import action
              print('Import button pressed');
            },
            child: const Text('Import'),
          ),
        ),
      ],
    );
  }
}
