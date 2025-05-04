import 'package:flutter/material.dart';
import 'package:learn_play_level_up_flutter/models/gamification_models.dart' as gamification;

class LeaderboardDisplay extends StatelessWidget {
  final List<gamification.LeaderboardEntry> entries;
  final String title;
  final String? currentUserId;
  final int? currentUserRank;
  final int? totalParticipants;
  final VoidCallback? onRefresh;

  const LeaderboardDisplay({
    super.key,
    required this.entries,
    required this.title,
    this.currentUserId,
    this.currentUserRank,
    this.totalParticipants,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              if (onRefresh != null)
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: onRefresh,
                  tooltip: 'Refresh',
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        
        // Top 3 podium
        if (entries.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: _LeaderboardPodium(
              entries: entries.take(3).toList(),
              currentUserId: currentUserId,
            ),
          ),
        const SizedBox(height: 16),
        
        // Current user rank
        if (currentUserId != null && currentUserRank != null && totalParticipants != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colorScheme.primary.withOpacity(0.3)),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.shadow.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.assessment),
                  const SizedBox(width: 12),
                  Text(
                    'Your Rank: ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    '$currentUserRank of $totalParticipants',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 16),
        
        // Leaderboard list
        Expanded(
          child: entries.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.emoji_events_outlined,
                        size: 64,
                        color: colorScheme.onSurface.withOpacity(0.2),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No leaderboard data yet',
                        style: TextStyle(
                          fontSize: 16,
                          color: colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Complete games to see rankings',
                        style: TextStyle(
                          fontSize: 14,
                          color: colorScheme.onSurface.withOpacity(0.4),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: entries.length,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    final rank = index + 1;
                    final isCurrentUser = currentUserId != null && entry.userId == currentUserId;
                    
                    return _LeaderboardEntryTile(
                      entry: entry,
                      rank: rank,
                      isCurrentUser: isCurrentUser,
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _LeaderboardPodium extends StatelessWidget {
  final List<gamification.LeaderboardEntry> entries;
  final String? currentUserId;
  
  const _LeaderboardPodium({
    required this.entries,
    this.currentUserId,
  });
  
  @override
  Widget build(BuildContext context) {
    final List<gamification.LeaderboardEntry> podiumEntries = List.filled(3, _createEmptyEntry());
    
    // Fill available entries
    for (int i = 0; i < entries.length && i < 3; i++) {
      podiumEntries[i] = entries[i];
    }
    
    // Podium order: second place (left), first place (center), third place (right)
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Second place
        if (entries.length > 1)
          Expanded(
            child: _PodiumPosition(
              entry: podiumEntries[1],
              rank: 2,
              height: 90,
              isCurrentUser: currentUserId != null && podiumEntries[1].userId == currentUserId,
            ),
          )
        else
          const Spacer(),
          
        // First place
        if (entries.isNotEmpty)
          Expanded(
            flex: 2,
            child: _PodiumPosition(
              entry: podiumEntries[0],
              rank: 1,
              height: 120,
              isCurrentUser: currentUserId != null && podiumEntries[0].userId == currentUserId,
            ),
          )
        else
          const Spacer(flex: 2),
          
        // Third place
        if (entries.length > 2)
          Expanded(
            child: _PodiumPosition(
              entry: podiumEntries[2],
              rank: 3,
              height: 70,
              isCurrentUser: currentUserId != null && podiumEntries[2].userId == currentUserId,
            ),
          )
        else
          const Spacer(),
      ],
    );
  }
  
  // Create an empty leaderboard entry for placeholder positions
  gamification.LeaderboardEntry _createEmptyEntry() {
    return gamification.LeaderboardEntry(
      userId: '',
      userName: '',
      value: 0,
      updatedAt: DateTime.now(),
    );
  }
}

class _PodiumPosition extends StatelessWidget {
  final gamification.LeaderboardEntry entry;
  final int rank;
  final double height;
  final bool isCurrentUser;
  
  const _PodiumPosition({
    required this.entry,
    required this.rank,
    required this.height,
    this.isCurrentUser = false,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // If empty entry, show empty podium position
    if (entry.userId.isEmpty) {
      return Container(
        height: height,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: colorScheme.surfaceVariant.withOpacity(0.5),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(8),
            topRight: Radius.circular(8),
          ),
        ),
      );
    }
    
    // Determine medal color
    Color medalColor;
    switch (rank) {
      case 1:
        medalColor = Colors.amber.shade600; // Gold
        break;
      case 2:
        medalColor = Colors.grey.shade400; // Silver
        break;
      case 3:
        medalColor = Colors.brown.shade300; // Bronze
        break;
      default:
        medalColor = Colors.grey.shade300;
    }
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Avatar and name
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colorScheme.surface,
            border: Border.all(
              color: isCurrentUser ? colorScheme.primary : Colors.transparent,
              width: isCurrentUser ? 2 : 0,
            ),
            boxShadow: [
              BoxShadow(
                color: medalColor.withOpacity(0.5),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: entry.avatar != null
              ? ClipOval(
                  child: Image.network(
                    entry.avatar!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.person),
                  ),
                )
              : const Icon(Icons.person),
        ),
        const SizedBox(height: 4),
        
        // User name
        Text(
          entry.userName,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: isCurrentUser ? colorScheme.primary : null,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
        
        // Score
        Text(
          entry.value.toString(),
          style: TextStyle(
            fontSize: 10,
            color: colorScheme.onSurfaceVariant,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        
        // Medal
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: medalColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Center(
            child: Text(
              rank.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        
        // Podium
        Container(
          height: height,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: medalColor.withOpacity(0.3),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
            border: Border(
              top: BorderSide(color: medalColor, width: 2),
              left: BorderSide(color: medalColor, width: 1),
              right: BorderSide(color: medalColor, width: 1),
            ),
          ),
        ),
      ],
    );
  }
}

class _LeaderboardEntryTile extends StatelessWidget {
  final gamification.LeaderboardEntry entry;
  final int rank;
  final bool isCurrentUser;
  
  const _LeaderboardEntryTile({
    required this.entry,
    required this.rank,
    this.isCurrentUser = false,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    Color? rankColor;
    switch (rank) {
      case 1:
        rankColor = Colors.amber.shade600; // Gold
        break;
      case 2:
        rankColor = Colors.grey.shade400; // Silver
        break;
      case 3:
        rankColor = Colors.brown.shade300; // Bronze
        break;
      default:
        rankColor = null;
    }
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: isCurrentUser ? colorScheme.primary.withOpacity(0.05) : null,
        borderRadius: BorderRadius.circular(12),
        border: isCurrentUser
            ? Border.all(
                color: colorScheme.primary.withOpacity(0.3),
                width: 1,
              )
            : null,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: rankColor ?? colorScheme.surfaceVariant,
            boxShadow: rankColor != null
                ? [
                    BoxShadow(
                      color: rankColor.withOpacity(0.5),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              rank.toString(),
              style: TextStyle(
                color: rankColor != null ? Colors.white : colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        title: Text(
          entry.userName,
          style: TextStyle(
            fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
            color: isCurrentUser ? colorScheme.primary : null,
          ),
        ),
        subtitle: Text(
          'Last updated: ${_formatDate(entry.updatedAt)}',
          style: TextStyle(
            fontSize: 12,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: Text(
          entry.value.toString(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: rankColor ?? colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class LeaderboardTabSelector extends StatelessWidget {
  final List<String> categories;
  final int selectedIndex;
  final Function(int) onChanged;

  const LeaderboardTabSelector({
    super.key,
    required this.categories,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      height: 48,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          final isSelected = index == selectedIndex;
          
          return GestureDetector(
            onTap: () => onChanged(index),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: isSelected ? colorScheme.primary : colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(24),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: colorScheme.primary.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Text(
                  categories[index],
                  style: TextStyle(
                    color: isSelected ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
} 