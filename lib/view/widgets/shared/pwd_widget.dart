import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:pwd_gen/core/dictionary/app_strings.dart';
import 'package:pwd_gen/view/widgets/main/cubit_pwds_list/pwd_list_cubit.dart';
import 'package:share_plus/share_plus.dart';
import '/domain/pwd_entity.dart';

class PwdWidget extends StatefulWidget {
  final PwdEntity pwd;
  final VoidCallback onEdit;
  final VoidCallback onShareOrOnVisibilityChanged;
  const PwdWidget(
      {super.key,
      required this.pwd,
      required this.onEdit,
      required this.onShareOrOnVisibilityChanged});
  @override
  State<PwdWidget> createState() => PwdWidgetState();
}

class PwdWidgetState extends State<PwdWidget>
    with
        SingleTickerProviderStateMixin,
        AutomaticKeepAliveClientMixin<PwdWidget> {
  TextEditingController controller = TextEditingController();
  late AnimationController _controller;
  late Animation<Color?> _borderColorAnimation;
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 400),
      vsync: this,
    );
    _borderColorAnimation = ColorTween(
      begin: Colors.black,
      end: Color.fromARGB(255, 255, 106, 0),
    ).animate(_controller);
  }

  void changeBorderColor() async {
    _controller.forward(from: 0); // parte l'animazione verso arancione
    await Future.delayed(Duration(seconds: 2));
    _controller.reverse(); // torna a nero
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_isVisible) {
      controller.text = widget.pwd.password;
    } else {
      controller.text = widget.pwd.hint;
    }
    return Scaffold(
      body: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        child: Stack(
          children: [
            AnimatedBuilder(
              animation: _borderColorAnimation,
              builder: (context, _) => TextField(
                onTap: () {
                  widget.onEdit();
                },
                controller: controller,
                enabled: true,
                readOnly: true,
                textAlign: TextAlign.start,
                style: GoogleFonts.firaCode(
                    // Use Google Font for input text
                    textStyle: TextStyle(
                  fontSize: 18,
                )),
                decoration: InputDecoration(
                  hintStyle: TextStyle(color: Colors.grey),
                  hintText: '✍️ ' + AppStrings.hint,
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: _borderColorAnimation.value ?? Colors.black,
                      width: 1.5,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: _borderColorAnimation.value ?? Colors.black,
                      width: 1.5,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: _borderColorAnimation.value ?? Colors.black,
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: _borderColorAnimation.value ?? Colors.black,
                      width: 1.5,
                    ),
                  ),
                  suffixIcon: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      /*  IconButton(
                          onPressed: widget.onEdit, icon: Icon(Icons.edit)), */
                      IconButton(
                          onPressed: () async {
                            String result = widget.pwd.password;
                            if (!widget.pwd.hint.isEmpty) {
                              final userRes = await showDialog<bool>(
                                  barrierDismissible: false,
                                  context: context,
                                  builder: (context) => AlertDialog(
                                        content: Text(AppStrings
                                            .doYouWantToShareTheReminder),
                                        actions: [
                                          ElevatedButton(
                                              onPressed: () {
                                                Navigator.of(context).pop(true);
                                              },
                                              child: Text(AppStrings.yes)),
                                          ElevatedButton(
                                              onPressed: () {
                                                Navigator.of(context)
                                                    .pop(false);
                                              },
                                              child: Text(AppStrings.no))
                                        ],
                                      ));
                              if (userRes != null || userRes != false) {
                                result =
                                    '${widget.pwd.hint}\n${widget.pwd.password}';
                              }
                            }
                            await SharePlus.instance.share(
                              ShareParams(text: result),
                            );
                            widget.onShareOrOnVisibilityChanged();
                          },
                          icon: Icon(Icons.share)),
                      IconButton(
                          onPressed: () {
                            _isVisible = !_isVisible;
                            if (_isVisible) {
                              _controller.forward(from: 0);
                            } else {
                              _controller.reverse();
                            }
                            if (!_isVisible) {
                              widget.onShareOrOnVisibilityChanged();
                            }
                            setState(() {});
                          },
                          icon: _isVisible
                              ? Icon(Icons.visibility)
                              : Icon(Icons.visibility_off)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _controller.dispose();
    controller.dispose();
    super.dispose();
  }
}
