import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reading_book_app/core/stores/StoryStore.dart';

class StorySearchBar extends StatefulWidget {
  const StorySearchBar({super.key});

  @override
  State<StorySearchBar> createState() => _StorySearchBarState();
}

class _StorySearchBarState extends State<StorySearchBar> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 400), () {
      final store = context.read<StoryStore>();

      if (value.trim().isEmpty) {
        store.resetAndFetch();
      } else {
        store.searchStories(value.trim());
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: _onSearchChanged,

      /// Màu chữ
      style: const TextStyle(
        color: Colors.white,
        fontSize: 14, // giảm size chữ → field thấp hơn
      ),

      decoration: InputDecoration(
        hintText: 'Tìm kiếm truyện...',
        hintStyle: TextStyle(
          color: Colors.white.withOpacity(0.6),
          fontSize: 14,
        ),

        /// Icon
        prefixIcon: const Icon(Icons.search, color: Colors.white, size: 20),

        suffixIcon: _controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, color: Colors.white, size: 18),
                onPressed: () {
                  _controller.clear();
                  context.read<StoryStore>().searchStories('');
                  setState(() {});
                },
              )
            : null,

        /// Giảm chiều cao
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 10, // 👈 giảm / tăng để chỉnh height
          horizontal: 16,
        ),

        /// Border trắng
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: Colors.white, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: Colors.white, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: Colors.white, width: 1.2),
        ),
      ),
    );
  }
}
