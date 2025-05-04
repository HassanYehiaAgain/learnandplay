import 'package:flutter/material.dart';
import 'package:learn_play_level_up_flutter/components/navbar.dart';
import 'package:learn_play_level_up_flutter/components/ui/card.dart';
import 'package:learn_play_level_up_flutter/models/game_template_models.dart';
import 'package:learn_play_level_up_flutter/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

class GameTemplatesSelectionPage extends StatefulWidget {
  const GameTemplatesSelectionPage({super.key});

  @override
  State<GameTemplatesSelectionPage> createState() => _GameTemplatesSelectionPageState();
}

class _GameTemplatesSelectionPageState extends State<GameTemplatesSelectionPage> {
  late List<UniversalGameTemplateInfo> _templates;
  String _searchQuery = '';
  
  @override
  void initState() {
    super.initState();
    _templates = UniversalGameTemplateInfo.getAllTemplates();
  }
  
  List<UniversalGameTemplateInfo> get filteredTemplates {
    if (_searchQuery.isEmpty) {
      return _templates;
    }
    
    return _templates.where((template) {
      return template.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             template.description.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.of(context).size;
    
    // Determine grid columns based on screen width
    int crossAxisCount = 4; // Default for wide screens
    
    if (size.width < 600) {
      crossAxisCount = 1; // Mobile
    } else if (size.width < 900) {
      crossAxisCount = 2; // Small tablet
    } else if (size.width < 1200) {
      crossAxisCount = 3; // Large tablet/small desktop
    }
    
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Column(
        children: [
          const Navbar(isAuthenticated: true),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Game Templates',
                    style: theme.textTheme.displayMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ).animate().fadeIn(duration: 300.ms).slideX(begin: -0.1, end: 0),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    'Select a template to create your educational game',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideX(begin: -0.1, end: 0),
                  
                  const SizedBox(height: 24),
                  
                  // Search bar
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Search templates...',
                      prefixIcon: Icon(Icons.search, color: colorScheme.primary),
                      filled: true,
                      fillColor: colorScheme.surfaceContainerHighest,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ).animate().fadeIn(duration: 500.ms, delay: 200.ms),
                  
                  const SizedBox(height: 24),
                  
                  // Grid of templates
                  Expanded(
                    child: filteredTemplates.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 64,
                                  color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No matching templates found',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : GridView.builder(
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              childAspectRatio: 1.4,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: filteredTemplates.length,
                            itemBuilder: (context, index) {
                              final template = filteredTemplates[index];
                              return _buildTemplateCard(context, template, index);
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTemplateCard(BuildContext context, UniversalGameTemplateInfo template, int index) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return AppCard(
      onTap: () {
        GoRouter.of(context).go(template.routePath);
      },
      isInteractive: true,
      borderRadius: 16,
      backgroundColor: colorScheme.surface,
      hasShadow: true,
      borderColor: template.color.withOpacity(0.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Template Icon in a circle
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: template.color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              template.icon,
              color: template.color,
              size: 30,
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Template title
          Text(
            template.title,
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          
          const SizedBox(height: 8),
          
          // Template description
          Expanded(
            child: Text(
              template.description,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms, delay: Duration(milliseconds: 100 * index)).moveY(begin: 20, end: 0);
  }
} 