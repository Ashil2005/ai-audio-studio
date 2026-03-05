import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/library_provider.dart';
import '../../../models/library_item.dart';
import '../../../core/router/app_router.dart';
import '../../../services/local_storage_service.dart';

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final libraryItems = ref.watch(libraryProvider);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          title: const Text('Library'),
          bottom: const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelColor: AppTheme.primary,
            unselectedLabelColor: AppTheme.textSecondary,
            indicatorColor: AppTheme.primary,
            indicatorSize: TabBarIndicatorSize.label,
            dividerColor: AppTheme.glassBorder,
            tabs: [
              Tab(text: 'Audiobooks'),
              Tab(text: 'Debates'),
              Tab(text: 'Summaries'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _LibraryListView(
              items: libraryItems.where((i) => i.type == LibraryItemType.audiobook).toList(),
              emptyIcon: Icons.headphones_rounded,
              emptyTitle: 'No audiobooks yet',
              emptySubtitle: 'Convert a PDF to get started',
            ),
            _LibraryListView(
              items: libraryItems.where((i) => i.type == LibraryItemType.debate).toList(),
              emptyIcon: Icons.record_voice_over_rounded,
              emptyTitle: 'No debates yet',
              emptySubtitle: 'Start a debate from the Studio',
            ),
            _LibraryListView(
              items: libraryItems.where((i) => i.type == LibraryItemType.summary).toList(),
              emptyIcon: Icons.summarize_rounded,
              emptyTitle: 'No summaries yet',
              emptySubtitle: 'AI summaries will appear here',
            ),
          ],
        ),
      ),
    );
  }
}

class _LibraryListView extends ConsumerWidget {
  final List<LibraryItem> items;
  final IconData emptyIcon;
  final String emptyTitle;
  final String emptySubtitle;
  final bool isLoading;

  const _LibraryListView({
    required this.items,
    required this.emptyIcon,
    required this.emptyTitle,
    required this.emptySubtitle,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isLoading) {
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        itemBuilder: (context, index) => _buildShimmerCard(),
      );
    }

    if (items.isEmpty) {
      return _EmptyTabView(
        icon: emptyIcon,
        title: emptyTitle,
        subtitle: emptySubtitle,
        comingSoon: false,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _LibraryCard(item: item);
      },
    );
  }

  Widget _buildShimmerCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
    ).animate(onPlay: (controller) => controller.repeat())
     .shimmer(duration: 1200.ms, color: Colors.white.withOpacity(0.1));
  }
}

class _LibraryCard extends ConsumerWidget {
  final LibraryItem item;

  const _LibraryCard({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateStr = DateFormat('MMM d, yyyy').format(item.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: AppTheme.glassMorphism(),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          item.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              item.preview,
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              dateStr,
              style: TextStyle(color: AppTheme.primary.withOpacity(0.7), fontSize: 11),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: AppTheme.error, size: 20),
          onPressed: () => _confirmDelete(context, ref),
        ),
        onTap: () => _onTap(context, ref),
      ),
    ).animate().fadeIn(delay: 50.ms).slideY(begin: 0.1, end: 0);
  }

  void _onTap(BuildContext context, WidgetRef ref) async {
    switch (item.type) {
      case LibraryItemType.audiobook:
        context.push(AppRoutes.pdfUpload);
        break;
      case LibraryItemType.debate:
        await _showContentDialog(context, ref, 'Debate Result');
        break;
      case LibraryItemType.summary:
        await _showContentDialog(context, ref, 'AI Summary');
        break;
      case LibraryItemType.voiceChat:
        await _showContentDialog(context, ref, 'Voice Chat Session');
        break;
    }
  }

  Future<void> _showContentDialog(BuildContext context, WidgetRef ref, String title) async {
    // Show loading while reading file if needed
    final storage = ref.read(localStorageServiceProvider);
    final fullContent = await storage.readFullContent(item);

    if (context.mounted) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppTheme.cardColor,
          title: Text(title),
          content: SingleChildScrollView(
            child: Text(fullContent, style: const TextStyle(color: Colors.white, height: 1.5)),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
          ],
        ),
      );
    }
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        title: const Text('Delete Item?'),
        content: const Text('Are you sure you want to remove this from your library?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              ref.read(libraryProvider.notifier).deleteItem(item.id);
              Navigator.pop(ctx);
            },
            child: const Text('Delete', style: TextStyle(color: AppTheme.error)),
          ),
        ],
      ),
    );
  }
}

class _EmptyTabView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool comingSoon;

  const _EmptyTabView({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.comingSoon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primary.withOpacity(0.1),
            ),
            child: Icon(icon, color: AppTheme.primary, size: 36),
          ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
          const SizedBox(height: 20),
          Text(title,
              style: Theme.of(context).textTheme.titleMedium)
              .animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 8),
          Text(subtitle,
              style: Theme.of(context).textTheme.bodyMedium)
              .animate().fadeIn(delay: 300.ms),
          if (comingSoon) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: AppTheme.primary.withOpacity(0.15),
                border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
              ),
              child: const Text(
                'Coming Soon',
                style: TextStyle(
                  color: AppTheme.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ).animate().fadeIn(delay: 400.ms),
          ],
        ],
      ),
    );
  }
}
