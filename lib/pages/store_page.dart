import 'package:flutter/material.dart';
import 'package:learn_play_level_up_flutter/models/gamification_models.dart' as gamification;
import 'package:learn_play_level_up_flutter/services/gamification_service.dart';
import 'package:learn_play_level_up_flutter/components/gamification/currency_display.dart';

class StorePage extends StatefulWidget {
  final String userId;

  const StorePage({
    super.key,
    required this.userId,
  });

  @override
  State<StorePage> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final GamificationService _gamificationService = GamificationService();
  
  List<gamification.StoreItem> _storeItems = [];
  List<String> _ownedItems = [];
  int _coins = 0;
  bool _isLoading = true;
  
  // Categories for the store
  final List<String> _categories = [
    'All',
    'Avatars',
    'Themes',
    'Power-ups',
    'Backgrounds',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
    _loadStoreData();
  }
  
  Future<void> _loadStoreData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Load store items
      final items = await _gamificationService.getStoreItems();
      
      // Load user inventory
      final inventory = await _gamificationService.getUserInventory(widget.userId);
      
      // Load user coins
      final progress = await _gamificationService.getUserProgress(widget.userId);
      
      setState(() {
        _storeItems = items;
        _ownedItems = inventory?.ownedItems ?? [];
        _coins = progress?.coins ?? 0;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load store data: $e')),
      );
    }
  }
  
  Future<void> _purchaseItem(gamification.StoreItem item) async {
    if (_coins < item.price) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not enough coins!')),
      );
      return;
    }
    
    // Show purchase confirmation
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Purchase'),
        content: Text('Do you want to purchase ${item.name} for ${item.price} coins?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Purchase'),
          ),
        ],
      ),
    );
    
    if (confirm != true) return;
    
    // Process purchase
    final success = await _gamificationService.purchaseItem(widget.userId, item.id);
    
    if (success) {
      // Show purchase animation and update state
      setState(() {
        _coins -= item.price;
        _ownedItems.add(item.id);
      });
      
      _showPurchaseAnimation(item);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Purchase failed. Please try again.')),
      );
    }
  }
  
  void _showPurchaseAnimation(gamification.StoreItem item) {
    // Show a congratulatory dialog with animation
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Item Purchased!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            Image.asset(
              item.imagePath,
              height: 100,
              width: 100,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 20),
            Text(
              item.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              item.description,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            const Text(
              'You can find this item in your inventory!',
              textAlign: TextAlign.center,
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Store'),
        actions: [
          CoinDisplay(
            coins: _coins,
            compact: true,
          ),
          const SizedBox(width: 16),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: _categories.map((category) => Tab(text: category)).toList(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: _categories.map((category) {
                // Filter items by category
                final items = category == 'All'
                    ? _storeItems
                    : _storeItems.where((item) => item.category == category.toLowerCase()).toList();
                
                return _buildStoreGrid(items);
              }).toList(),
            ),
    );
  }
  
  Widget _buildStoreGrid(List<gamification.StoreItem> items) {
    if (items.isEmpty) {
      return const Center(
        child: Text('No items available in this category'),
      );
    }
    
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isOwned = _ownedItems.contains(item.id);
        
        return StoreItemCard(
          item: item,
          isOwned: isOwned,
          onPurchase: () => _purchaseItem(item),
        );
      },
    );
  }
}

class StoreItemCard extends StatelessWidget {
  final gamification.StoreItem item;
  final bool isOwned;
  final VoidCallback onPurchase;

  const StoreItemCard({
    super.key,
    required this.item,
    required this.isOwned,
    required this.onPurchase,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Item image
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              padding: const EdgeInsets.all(12),
              child: Image.asset(
                item.imagePath,
                fit: BoxFit.contain,
              ),
            ),
          ),
          
          // Item details
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Item name
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  // Item description
                  Text(
                    item.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  // Price and purchase button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Price
                      Row(
                        children: [
                          const Icon(
                            Icons.monetization_on,
                            color: Colors.amber,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            item.price.toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      
                      // Purchase button
                      isOwned
                          ? ElevatedButton(
                              onPressed: null,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                backgroundColor: colorScheme.secondaryContainer,
                              ),
                              child: const Text('Owned'),
                            )
                          : ElevatedButton(
                              onPressed: onPurchase,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                              ),
                              child: const Text('Buy'),
                            ),
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
} 