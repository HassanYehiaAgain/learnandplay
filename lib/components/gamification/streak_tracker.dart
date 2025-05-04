import 'package:flutter/material.dart';

class StreakCalendar extends StatelessWidget {
  final List<DateTime> activeDates;
  final DateTime currentMonth;
  final int currentStreak;
  final VoidCallback? onMonthChanged;

  const StreakCalendar({
    super.key,
    required this.activeDates,
    required this.currentMonth,
    this.currentStreak = 0,
    this.onMonthChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Get the first day of the month
    final firstDay = DateTime(currentMonth.year, currentMonth.month, 1);
    
    // Get the number of days in the month
    final daysInMonth = DateTime(currentMonth.year, currentMonth.month + 1, 0).day;
    
    // Get the weekday of the first day (0 = Sunday, 1 = Monday, etc.)
    final firstWeekday = firstDay.weekday;
    
    // Calculate the number of rows needed in the calendar
    final numRows = ((firstWeekday + daysInMonth - 1) / 7).ceil();
    
    return Column(
      children: [
        // Month navigation
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: onMonthChanged,
            ),
            Text(
              '${_getMonthName(currentMonth.month)} ${currentMonth.year}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: onMonthChanged,
            ),
          ],
        ),
        const SizedBox(height: 8),
        
        // Weekday headers
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: const [
            _WeekdayLabel('Mon'),
            _WeekdayLabel('Tue'),
            _WeekdayLabel('Wed'),
            _WeekdayLabel('Thu'),
            _WeekdayLabel('Fri'),
            _WeekdayLabel('Sat'),
            _WeekdayLabel('Sun'),
          ],
        ),
        const SizedBox(height: 8),
        
        // Calendar grid
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
          ),
          child: Column(
            children: List.generate(numRows, (rowIndex) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(7, (colIndex) {
                  final dayIndex = rowIndex * 7 + colIndex - firstWeekday + 1;
                  
                  if (dayIndex < 1 || dayIndex > daysInMonth) {
                    return const SizedBox(
                      width: 40,
                      height: 40,
                    );
                  }
                  
                  final date = DateTime(currentMonth.year, currentMonth.month, dayIndex);
                  final isActive = activeDates.any((activeDate) =>
                    activeDate.year == date.year &&
                    activeDate.month == date.month &&
                    activeDate.day == date.day
                  );
                  
                  final isToday = DateTime.now().year == date.year &&
                      DateTime.now().month == date.month &&
                      DateTime.now().day == date.day;
                  
                  return _CalendarDay(
                    day: dayIndex,
                    isActive: isActive,
                    isToday: isToday,
                  );
                }),
              );
            }),
          ),
        ),
        
        // Current streak
        Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.local_fire_department,
                color: Colors.orange,
                size: 28,
              ),
              const SizedBox(width: 8),
              Text(
                'Current Streak: $currentStreak day${currentStreak != 1 ? 's' : ''}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }
}

class _WeekdayLabel extends StatelessWidget {
  final String label;
  
  const _WeekdayLabel(this.label);
  
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
          fontSize: 12,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _CalendarDay extends StatelessWidget {
  final int day;
  final bool isActive;
  final bool isToday;
  
  const _CalendarDay({
    required this.day,
    required this.isActive,
    required this.isToday,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      width: 40,
      height: 40,
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive
            ? Colors.orange
            : isToday
                ? colorScheme.primary.withOpacity(0.1)
                : Colors.transparent,
        border: isToday && !isActive
            ? Border.all(color: colorScheme.primary, width: 2)
            : null,
      ),
      child: Center(
        child: Text(
          day.toString(),
          style: TextStyle(
            fontWeight: isActive || isToday ? FontWeight.bold : FontWeight.normal,
            color: isActive
                ? Colors.white
                : isToday
                    ? colorScheme.primary
                    : colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}

class StreakMilestone extends StatelessWidget {
  final int requiredDays;
  final int currentStreak;
  final String reward;
  final double progress;

  const StreakMilestone({
    super.key,
    required this.requiredDays,
    required this.currentStreak,
    required this.reward,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isCompleted = currentStreak >= requiredDays;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCompleted
            ? Colors.orange.withOpacity(0.2)
            : colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCompleted ? Colors.orange : colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCompleted ? Icons.check_circle : Icons.timelapse,
                color: isCompleted ? Colors.orange : colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                '$requiredDays Day Streak',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: isCompleted ? Colors.orange : colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: colorScheme.surfaceVariant,
              color: Colors.orange,
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Progress: $currentStreak / $requiredDays days',
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          
          // Reward
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isCompleted ? Colors.orange.withOpacity(0.1) : colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isCompleted ? Colors.orange : colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.card_giftcard,
                  size: 18,
                ),
                const SizedBox(width: 4),
                Text(
                  reward,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isCompleted ? Colors.orange : colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SubjectStreakCard extends StatelessWidget {
  final String subjectName;
  final String subjectIcon;
  final int currentStreak;
  final int highestStreak;
  final int? lastCompletedDay;

  const SubjectStreakCard({
    super.key,
    required this.subjectName,
    required this.subjectIcon,
    required this.currentStreak,
    required this.highestStreak,
    this.lastCompletedDay,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final today = DateTime.now().weekday;
    
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Subject icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Image.asset(
                      subjectIcon,
                      width: 24,
                      height: 24,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                
                // Subject info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subjectName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      RichText(
                        text: TextSpan(
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontSize: 14,
                          ),
                          children: [
                            const TextSpan(text: 'Current Streak: '),
                            TextSpan(
                              text: '$currentStreak day${currentStreak != 1 ? 's' : ''}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: currentStreak > 0 ? Colors.orange : colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Highest: $highestStreak day${highestStreak != 1 ? 's' : ''}',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Week progress
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (index) {
                final weekday = index + 1; // 1 = Monday, 7 = Sunday
                final isToday = weekday == today;
                final isCompleted = lastCompletedDay == weekday;
                
                return _WeekdayCircle(
                  dayLabel: _getShortWeekdayName(weekday),
                  isToday: isToday,
                  isCompleted: isCompleted,
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
  
  String _getShortWeekdayName(int weekday) {
    const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return days[weekday - 1];
  }
}

class _WeekdayCircle extends StatelessWidget {
  final String dayLabel;
  final bool isToday;
  final bool isCompleted;
  
  const _WeekdayCircle({
    required this.dayLabel,
    required this.isToday,
    required this.isCompleted,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isCompleted
            ? Colors.orange
            : isToday
                ? colorScheme.primaryContainer
                : colorScheme.surfaceVariant,
        border: isToday && !isCompleted
            ? Border.all(color: colorScheme.primary, width: 2)
            : null,
      ),
      child: Center(
        child: Text(
          dayLabel,
          style: TextStyle(
            fontWeight: isToday || isCompleted ? FontWeight.bold : FontWeight.normal,
            color: isCompleted
                ? Colors.white
                : isToday
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
} 