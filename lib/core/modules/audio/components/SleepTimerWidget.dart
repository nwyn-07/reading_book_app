import 'package:flutter/material.dart';
import 'package:reading_book_app/core/theme/AppColors.dart';
import 'package:reading_book_app/core/models/SleepOptions.dart';

class SleepTimerWidget extends StatefulWidget {
  final void Function(Duration? duration) onSelected;
  final VoidCallback? onCancel;
  final SleepOption? initialOption;

  const SleepTimerWidget({
    super.key,
    required this.onSelected,
    this.onCancel,
    this.initialOption,
  });

  @override
  State<SleepTimerWidget> createState() => _SleepTimerWidgetState();
}

class _SleepTimerWidgetState extends State<SleepTimerWidget> {
  SleepOption? _selectedOptions;

  final List<SleepOption> _options = sleepOptions;

  @override
  void initState() {
    super.initState();
    _selectedOptions = widget.initialOption;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),

            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
              title: const Text(
                'Hẹn Giờ',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),

            ..._options.map((option) {
              final selected = _selectedOptions == option;
              return ListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,

                  children: [
                    Text(
                      option.label,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                    if (selected) const SizedBox(width: 8),
                    if (selected)
                      const Icon(Icons.check, color: Colors.orangeAccent),
                  ],
                ),

                onTap: () {
                  setState(() => _selectedOptions = option);

                  widget.onSelected(option.duration);

                  Navigator.pop(context);
                },
              );
            }),

            Padding(
              padding: EdgeInsets.zero,
              child: InkWell(
                onTap: () {
                  widget.onCancel?.call();
                  Navigator.pop(context);
                },
                child: Container(
                  width: double.infinity,
                  height: 50,
                  color: AppColors.surface,
                  child: const Center(
                    child: Icon(Icons.close, color: Colors.white, size: 30),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
