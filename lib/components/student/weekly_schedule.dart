import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:learn_play_level_up_flutter/theme/app_theme.dart';
import 'package:intl/intl.dart';

class WeeklySchedule extends StatelessWidget {
  final List<Map<String, dynamic>> scheduleItems;
  final bool isLoading;

  const WeeklySchedule({
    super.key,
    required this.scheduleItems,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (isLoading) {
      return _buildLoadingState(context);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Weekly Schedule',
              style: TextStyle(
                fontFamily: 'PressStart2P',
                fontSize: 16,
                color: colorScheme.onSurface,
              ),
            ),
            TextButton.icon(
              onPressed: () {},
              icon: Icon(
                Icons.calendar_today_outlined,
                size: 16,
                color: colorScheme.primary,
              ),
              label: Text(
                'View Calendar',
                style: TextStyle(
                  fontFamily: 'PixelifySans',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.outline.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              // Week navigation
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.chevron_left,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    'October 16-22',
                    style: TextStyle(
                      fontFamily: 'PixelifySans',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.chevron_right,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Week day header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: _buildWeekdayHeaders(context),
              ),
              const SizedBox(height: 16),
              // Schedule content
              scheduleItems.isEmpty
                  ? _buildEmptySchedule(context)
                  : _buildScheduleItems(context),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildWeekdayHeaders(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final today = DateTime.now().weekday - 1; // 0 = Monday, 6 = Sunday

    return List.generate(7, (index) {
      final weekday = DateFormat('E').format(
        DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1 - index)),
      );
      final date = DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1 - index)).day;
      final isToday = index == today;

      return Container(
        width: 40,
        decoration: BoxDecoration(
          color: isToday ? colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            Text(
              weekday.substring(0, 1),
              style: TextStyle(
                fontFamily: 'PixelifySans',
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isToday ? Colors.white : colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              date.toString(),
              style: TextStyle(
                fontFamily: 'PixelifySans',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isToday ? Colors.white : colorScheme.onSurface,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildScheduleItems(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Group items by day
    final Map<int, List<Map<String, dynamic>>> groupedByDay = {};
    
    for (final item in scheduleItems) {
      final day = item['day'] as int;
      if (!groupedByDay.containsKey(day)) {
        groupedByDay[day] = [];
      }
      groupedByDay[day]!.add(item);
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (dayIndex) {
        final items = groupedByDay[dayIndex] ?? [];
        
        return Column(
          children: [
            // Items for this day
            ...items.map((item) {
              final Color itemColor = item['color'] as Color? ?? colorScheme.primary;
              return Container(
                width: 40,
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: itemColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: itemColor.withOpacity(0.4),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      item['icon'] as IconData,
                      color: itemColor,
                      size: 16,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item['time'] as String,
                      style: TextStyle(
                        fontFamily: 'PixelifySans',
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: itemColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ).animate()
                .fadeIn(duration: 300.ms, delay: Duration(milliseconds: 100 * dayIndex));
            }),
            
            // Add placeholder if no items
            if (items.isEmpty)
              const SizedBox(height: 40),
          ],
        );
      }),
    );
  }

  Widget _buildEmptySchedule(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 48,
            color: colorScheme.onSurfaceVariant.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No scheduled activities',
            style: TextStyle(
              fontFamily: 'PixelifySans',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Your teacher will assign games and activities',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Weekly Schedule',
              style: TextStyle(
                fontFamily: 'PressStart2P',
                fontSize: 16,
                color: colorScheme.onSurface,
              ),
            ),
            TextButton.icon(
              onPressed: null,
              icon: Icon(
                Icons.calendar_today_outlined,
                size: 16,
                color: colorScheme.primary.withOpacity(0.5),
              ),
              label: Text(
                'View Calendar',
                style: TextStyle(
                  fontFamily: 'PixelifySans',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary.withOpacity(0.5),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          height: 200,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.outline.withOpacity(0.2),
              width: 1,
            ),
          ),
        ).animate()
          .shimmer(duration: 1200.ms, color: colorScheme.primary.withOpacity(0.1)),
      ],
    );
  }
} 