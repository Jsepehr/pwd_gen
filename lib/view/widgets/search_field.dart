import 'package:flutter/material.dart';

class SearchField extends StatefulWidget {
  final Function(String) onChange;
  const SearchField({
    super.key,
    required this.onChange,
  });
  @override
  SearchFieldState createState() => SearchFieldState();
}

class SearchFieldState extends State<SearchField> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 15),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search...',
          hintStyle: const TextStyle(),
        ),
        onChanged: widget.onChange,
        cursorHeight: 20,
        autofocus: false,
      ),
    );
  }
}
