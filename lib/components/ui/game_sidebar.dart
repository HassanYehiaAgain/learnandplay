import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:learn_play_level_up_flutter/theme/app_theme.dart';

class SidebarItem {
  final String title;
  final IconData icon;
  final String path;
  final int? badgeCount;
  final bool isLocked;

  SidebarItem({
    required this.title,
    required this.icon,
    required this.path,
    this.badgeCount,
    this.isLocked = false,
  });
}

class GameSidebar extends StatefulWidget {
  final List<SidebarItem> items;
  final bool expanded;
  final ValueChanged<bool>? onExpandToggle;
  final Color? backgroundColor;
  final String? username;
  final String? userLevel;
  final double? userProgress;

  const GameSidebar({
    Key? key,
    required this.items,
    this.expanded = true,
    this.onExpandToggle,
    this.backgroundColor,
    this.username,
    this.userLevel,
    this.userProgress,
  }) : super(key: key);

  @override
  State<GameSidebar> createState() => _GameSidebarState();
}

class _GameSidebarState extends State<GameSidebar> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isHoveringExpand = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    
    if (widget.expanded) {
      _animationController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(GameSidebar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.expanded != oldWidget.expanded) {
      if (widget.expanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    widget.onExpandToggle?.call(!widget.expanded);
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final router = GoRouter.of(context);
    final currentRoute = router.routerDelegate.currentConfiguration.uri.path;
    final sidebarWidth = widget.expanded ? 240.0 : 80.0;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: sidebarWidth,
      height: double.infinity,
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? colorScheme.surfaceContainerHighest,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(1, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Logo area
          _buildLogoArea(colorScheme),
          
          // User info if available
          if (widget.username != null) ...[
            const SizedBox(height: 16),
            _buildUserInfo(colorScheme),
          ],
          
          // Divider
          const SizedBox(height: 24),
          Container(
            height: 2,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              gradient: AppGradients.purpleToPink,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          const SizedBox(height: 16),
          
          // Navigation items
          Expanded(
            child: ListView.builder(
              itemCount: widget.items.length,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemBuilder: (context, index) {
                final item = widget.items[index];
                final isActive = currentRoute == item.path;
                
                return _SidebarNavItem(
                  title: item.title,
                  icon: item.icon,
                  path: item.path,
                  badgeCount: item.badgeCount,
                  isLocked: item.isLocked,
                  isActive: isActive,
                  expanded: widget.expanded,
                  animation: _animation,
                );
              },
            ),
          ),
          
          // Expand/collapse toggle
          _buildToggleButton(colorScheme),
        ],
      ),
    );
  }

  Widget _buildLogoArea(ColorScheme colorScheme) {
    return Container(
      height: 80,
      padding: EdgeInsets.symmetric(
        horizontal: widget.expanded ? 16 : 12,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: AppGradients.purpleToPink,
            ),
            child: Icon(
              Icons.gamepad,
              color: Colors.white,
              size: 24,
            ),
          ),
          
          SizeTransition(
            sizeFactor: _animation,
            axis: Axis.horizontal,
            axisAlignment: -1,
            child: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Text(
                'Learn & Play',
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'PixelifySans',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfo(ColorScheme colorScheme) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: widget.expanded ? 16 : 12,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppGradients.orangeToYellow,
            ),
            child: Center(
              child: Text(
                widget.username?.isNotEmpty == true
                    ? widget.username![0].toUpperCase()
                    : 'U',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          
          // User details with animation
          SizeTransition(
            sizeFactor: _animation,
            axis: Axis.horizontal,
            axisAlignment: -1,
            child: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.username ?? 'User',
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Lvl ${widget.userLevel ?? '1'}',
                          style: TextStyle(
                            color: colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                            fontFamily: 'PixelifySans',
                          ),
                        ),
                      ),
                      if (widget.userProgress != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          width: 80,
                          height: 6,
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: widget.userProgress,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: AppGradients.purpleToPink,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHoveringExpand = true),
        onExit: (_) => setState(() => _isHoveringExpand = false),
        child: GestureDetector(
          onTap: _toggleExpanded,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: _isHoveringExpand
                  ? colorScheme.surfaceContainerHighest.withOpacity(0.8)
                  : colorScheme.surfaceContainerLowest,
              border: Border.all(
                color: colorScheme.outline.withOpacity(0.5),
              ),
            ),
            child: Row(
              mainAxisAlignment: widget.expanded
                  ? MainAxisAlignment.spaceBetween
                  : MainAxisAlignment.center,
              children: [
                if (widget.expanded)
                  Text(
                    'Collapse',
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurface,
                    ),
                  ),
                Icon(
                  widget.expanded ? Icons.chevron_left : Icons.chevron_right,
                  color: colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Individual sidebar navigation item
class _SidebarNavItem extends StatefulWidget {
  final String title;
  final IconData icon;
  final String path;
  final int? badgeCount;
  final bool isLocked;
  final bool isActive;
  final bool expanded;
  final Animation<double> animation;

  const _SidebarNavItem({
    Key? key,
    required this.title,
    required this.icon,
    required this.path,
    this.badgeCount,
    this.isLocked = false,
    this.isActive = false,
    required this.expanded,
    required this.animation,
  }) : super(key: key);

  @override
  State<_SidebarNavItem> createState() => _SidebarNavItemState();
}

class _SidebarNavItemState extends State<_SidebarNavItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.isLocked ? null : () {
          GoRouter.of(context).go(widget.path);
          HapticFeedback.lightImpact();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 4,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: widget.isActive
                ? colorScheme.primaryContainer
                : (_isHovered && !widget.isLocked
                    ? colorScheme.surfaceContainerLowest
                    : Colors.transparent),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              // Icon with or without locks
              Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    widget.icon,
                    color: widget.isLocked
                        ? colorScheme.onSurface.withOpacity(0.3)
                        : (widget.isActive
                            ? colorScheme.primary
                            : colorScheme.onSurfaceVariant),
                    size: 24,
                  ),
                  if (widget.isLocked)
                    Icon(
                      Icons.lock,
                      color: colorScheme.onSurface.withOpacity(0.5),
                      size: 10,
                    ),
                ],
              ),
              
              // Title with animation
              SizeTransition(
                sizeFactor: widget.animation,
                axis: Axis.horizontal,
                axisAlignment: -1,
                child: Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Row(
                    children: [
                      Text(
                        widget.title,
                        style: TextStyle(
                          color: widget.isLocked
                              ? colorScheme.onSurface.withOpacity(0.3)
                              : (widget.isActive
                                  ? colorScheme.primary
                                  : colorScheme.onSurface),
                          fontWeight: widget.isActive ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      const SizedBox(width: 4),
                      
                      // Badge counter if needed
                      if (widget.badgeCount != null && widget.badgeCount! > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.error,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            widget.badgeCount.toString(),
                            style: TextStyle(
                              color: colorScheme.onError,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              
              // Lock icon for collapsed state
              if (!widget.expanded && widget.isLocked)
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Icon(
                      Icons.lock,
                      color: colorScheme.onSurface.withOpacity(0.3),
                      size: 14,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
} 