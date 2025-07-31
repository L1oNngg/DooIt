import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HeatmapChart extends StatefulWidget {
  final List<DateTime> completions;
  final void Function(DateTime day, bool newValue)? onToggle;
  final DateTime startMonth; // tháng đầu tiên có dữ liệu

  const HeatmapChart({
    super.key,
    required this.completions,
    required this.startMonth,
    this.onToggle,
  });

  @override
  State<HeatmapChart> createState() => _HeatmapChartState();
}

class _HeatmapChartState extends State<HeatmapChart> {
  late DateTime currentMonth;

  @override
  void initState() {
    super.initState();
    currentMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
  }

  bool _isCompletedOn(DateTime day) {
    return widget.completions.any((d) =>
    d.year == day.year && d.month == day.month && d.day == day.day);
  }

  @override
  Widget build(BuildContext context) {
    final daysInMonth =
    DateUtils.getDaysInMonth(currentMonth.year, currentMonth.month);

    final dates = List.generate(
      daysInMonth,
          (i) => DateTime(currentMonth.year, currentMonth.month, i + 1),
    );

    // Cố định số hàng, ví dụ 3
    const rowsCount = 3;
    final itemsPerRow = (dates.length / rowsCount).ceil();

    final canGoPrev = !(currentMonth.year == widget.startMonth.year &&
        currentMonth.month == widget.startMonth.month);
    final canGoNext = !(currentMonth.year == DateTime.now().year &&
        currentMonth.month == DateTime.now().month);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: canGoPrev
                  ? () {
                setState(() {
                  currentMonth = DateTime(
                      currentMonth.year, currentMonth.month - 1, 1);
                });
              }
                  : null,
            ),
            Text(
              DateFormat('MMMM yyyy').format(currentMonth),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: canGoNext
                  ? () {
                setState(() {
                  currentMonth = DateTime(
                      currentMonth.year, currentMonth.month + 1, 1);
                });
              }
                  : null,
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Lưới hiển thị ngang nhiều cột
        Column(
          children: List.generate(rowsCount, (row) {
            final start = row * itemsPerRow;
            final end = (start + itemsPerRow > dates.length)
                ? dates.length
                : start + itemsPerRow;
            final rowDates = dates.sublist(start, end);

            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: rowDates.map((day) {
                final done = _isCompletedOn(day);
                final color = done
                    ? Colors.green.withOpacity(0.8)
                    : Colors.grey.withOpacity(0.2);

                return GestureDetector(
                  onTap: widget.onToggle != null
                      ? () => widget.onToggle!(day, !done)
                      : null,
                  child: Container(
                    margin: const EdgeInsets.all(2),
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Tooltip(
                      message:
                      "${DateFormat('dd/MM').format(day)}: ${done ? 'Hoàn thành' : 'Chưa'}",
                    ),
                  ),
                );
              }).toList(),
            );
          }),
        ),
      ],
    );
  }
}
