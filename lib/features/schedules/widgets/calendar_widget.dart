import 'package:flutter/material.dart';
import '../../../data/models/session.dart';

class CalendarWidget extends StatefulWidget {
  final DateTime initialDate;
  final Function(DateTime) onDateSelected;
  final Map<String, List<Session>> sessionsByDate;

  const CalendarWidget({
    super.key,
    required this.initialDate,
    required this.onDateSelected,
    required this.sessionsByDate,
  });

  @override
  State<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  late DateTime _currentDate;
  bool _showingMonthPicker = false;
  bool _showingYearPicker = false;

  final List<String> _monthNamesShort = [
    'Jan.','Fev.','Mar.','Abr.','Mai.','Jun.',
    'Jul.','Ago.','Set.','Out.','Nov.','Dez.',
  ];
  final List<String> _monthNamesUpper = [
    'JANEIRO','FEVEVEIRO','MARÇO','ABRIL','MAIO','JUNHO',
    'JULHO','AGOSTO','SETEMBRO','OUTUBRO','NOVEMBRO','DEZEMBRO',
  ];

  @override
  void initState() {
    super.initState();
    _currentDate = widget.initialDate;
  }

  Widget _buildYearPickerGrid() {
    final currentYear = DateTime.now().year;
    final years = List.generate(12, (i) => currentYear - 5 + i);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 4,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1.4,
        children: years.map((year) {
          final isSelected = _currentDate.year == year;
          return Material(
            color: isSelected
                ? const Color(0xFF6A1B9A)
                : const Color(0xFFF3E5F5),
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              splashColor: Colors.white.withValues(alpha: 0.4),
              highlightColor: Colors.white.withValues(alpha: 0.2),
              onTap: () => setState(() {
                _currentDate = DateTime(year, _currentDate.month, 1);
                _showingYearPicker = false;
                _showingMonthPicker = true;
              }),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: const Color(0xFF6A1B9A)
                          .withValues(alpha: 0.3)),
                ),
                child: Center(
                  child: Text(
                    '$year',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMonthPickerGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 4,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1.4,
        children: List.generate(12, (index) {
          final isSelected = _currentDate.month == index + 1;
          return Material(
            color: isSelected
                ? const Color(0xFF6A1B9A)
                : const Color(0xFFF3E5F5),
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              splashColor: Colors.white.withValues(alpha: 0.4),
              highlightColor: Colors.white.withValues(alpha: 0.2),
              onTap: () => setState(() {
                _currentDate =
                    DateTime(_currentDate.year, index + 1, 1);
                _showingMonthPicker = false;
              }),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: const Color(0xFF6A1B9A)
                          .withValues(alpha: 0.3)),
                ),
                child: Center(
                  child: Text(
                    _monthNamesShort[index],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildDaysGrid() {
    final firstDay =
        DateTime(_currentDate.year, _currentDate.month, 1);
    final lastDay =
        DateTime(_currentDate.year, _currentDate.month + 1, 0);
    final daysInMonth = lastDay.day;
    final firstWeekday = firstDay.weekday % 7;
    final totalCells =  42;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
          childAspectRatio: 0.72,
        ),
        itemCount: totalCells,
        itemBuilder: (context, index) {
          final weekdayIndex = index % 7;
          int dayOfMonth = index - firstWeekday + 1;
          bool isOtherMonth =
              dayOfMonth < 1 || dayOfMonth > daysInMonth;

          DateTime dateForDay;
          int displayDay;

          if (dayOfMonth < 1) {
            final prevMonthLastDay = DateTime(
                    _currentDate.year, _currentDate.month, 0)
                .day;
            displayDay = prevMonthLastDay + dayOfMonth;
            dateForDay = DateTime(_currentDate.year,
                _currentDate.month - 1, displayDay);
          } else if (dayOfMonth > daysInMonth) {
            displayDay = dayOfMonth - daysInMonth;
            dateForDay = DateTime(_currentDate.year,
                _currentDate.month + 1, displayDay);
          } else {
            displayDay = dayOfMonth;
            dateForDay = DateTime(
                _currentDate.year, _currentDate.month, displayDay);
          }

          final dateString =
              '${dateForDay.year}-${dateForDay.month.toString().padLeft(2, '0')}-${dateForDay.day.toString().padLeft(2, '0')}';
          final sessions =
              widget.sessionsByDate[dateString] ?? [];
          final isSunday = weekdayIndex == 0;

          return Material(
            color: isOtherMonth
                ? Colors.transparent
                : isSunday
                    ? const Color(0xFFFCE4EC)
                    : Colors.white,
            borderRadius: BorderRadius.circular(4),
            child: InkWell(
              onTap: isOtherMonth
                  ? null
                  : () => widget.onDateSelected(dateForDay),
              borderRadius: BorderRadius.circular(4),
              splashColor:
                  const Color(0xFF6A1B9A).withValues(alpha: 0.2),
              highlightColor:
                  const Color(0xFF6A1B9A).withValues(alpha: 0.1),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isOtherMonth
                        ? Colors.grey.shade200
                        : Colors.grey.shade300,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Opacity(
                  opacity: isOtherMonth ? 0.3 : 1.0,
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$displayDay',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color:
                                isSunday ? Colors.red : Colors.black,
                          ),
                        ),
                        if (sessions.isNotEmpty && !isOtherMonth)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              sessions.length == 1
                                  ? sessions[0]
                                      .procedure
                                      .split(' ')
                                      .first
                                  : '+${sessions.length}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 8,
                                color: Color(0xFF6A1B9A),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left,
                    color: Color(0xFF6A1B9A)),
                onPressed: () => setState(() {
                  if (_showingYearPicker) {
                    _currentDate = DateTime(
                        _currentDate.year - 12, _currentDate.month);
                  } else if (_showingMonthPicker) {
                    _currentDate = DateTime(
                        _currentDate.year - 1, _currentDate.month);
                  } else {
                    _currentDate = DateTime(
                        _currentDate.year, _currentDate.month - 1);
                  }
                }),
              ),
              Material(
                color: const Color(0xFFF3E5F5),
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  onTap: () => setState(() {
                    if (_showingYearPicker) {
                      _showingYearPicker = false;
                    } else if (_showingMonthPicker) {
                      _showingMonthPicker = false;
                      _showingYearPicker = true;
                    } else {
                      _showingMonthPicker = true;
                    }
                  }),
                  borderRadius: BorderRadius.circular(8),
                  splashColor: const Color(0xFF6A1B9A).withValues(alpha: 0.2),
                  highlightColor: const Color(0xFF6A1B9A).withValues(alpha: 0.15),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFF6A1B9A), width: 1.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _showingYearPicker
                          ? 'Selecionar ano'
                          : _showingMonthPicker
                              ? '${_currentDate.year}'
                              : '${_monthNamesUpper[_currentDate.month - 1]} ${_currentDate.year}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6A1B9A),
                      ),
                    ),
                  ),
                ),
              ),  
              IconButton(
                icon: const Icon(Icons.chevron_right,
                    color: Color(0xFF6A1B9A)),
                onPressed: () => setState(() {
                  if (_showingYearPicker) {
                    _currentDate = DateTime(
                        _currentDate.year + 12, _currentDate.month);
                  } else if (_showingMonthPicker) {
                    _currentDate = DateTime(
                        _currentDate.year + 1, _currentDate.month);
                  } else {
                    _currentDate = DateTime(
                        _currentDate.year, _currentDate.month + 1);
                  }
                }),
              ),
            ],
          ),
        ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.05),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                    parent: animation, curve: Curves.easeOut)),
                child: child,
              ),
            ),
            child: _showingYearPicker
                ? KeyedSubtree(
                    key: const ValueKey('years'),
                    child: _buildYearPickerGrid())
                : _showingMonthPicker
                    ? KeyedSubtree(
                        key: const ValueKey('months'),
                        child: _buildMonthPickerGrid())
                    : KeyedSubtree(
                        key: const ValueKey('days'),
                        child: _buildDaysGrid()),
          ),
      ],
    );
  }
}