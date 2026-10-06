import 'package:flutter/material.dart';

class SearchBox extends StatefulWidget {
  final String initialValue;
  final ValueChanged<String> onSearch;

  const SearchBox({
    super.key,
    this.initialValue = '',
    required this.onSearch,
  });

  @override
  State<SearchBox> createState() => _SearchBoxState();
}

class _SearchBoxState extends State<SearchBox> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController(
      text: widget.initialValue,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    widget.onSearch(_controller.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      textInputAction: TextInputAction.search,
      onSubmitted: (_) => _submit(),
      decoration: InputDecoration(
        hintText: 'Search photos...',
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: _controller.text.isNotEmpty
            ? IconButton(
          onPressed: () {
            _controller.clear();
            widget.onSearch('');
            setState(() {});
          },
          icon: const Icon(
            Icons.close_rounded,
          ),
        )
            : null,
      ),
      onChanged: (_) {
        setState(() {});
      },
    );
  }
}