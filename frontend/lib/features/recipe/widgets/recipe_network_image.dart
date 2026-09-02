import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_provider.dart';
import '../providers/recipe_image_cache_provider.dart';

class RecipeNetworkImage extends StatelessWidget {
  const RecipeNetworkImage({
    super.key,
    required this.photoUrl,
    required this.placeholder,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
  });

  final String? photoUrl;
  final Widget placeholder;
  final BoxFit fit;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final url = photoUrl?.trim();
    if (url == null || url.isEmpty) return placeholder;
    final cacheManager = _viewerCacheManager(context);

    return CachedNetworkImage(
      imageUrl: url,
      cacheManager: cacheManager,
      fit: fit,
      alignment: alignment,
      placeholder: (_, __) => placeholder,
      errorWidget: (_, __, ___) => placeholder,
    );
  }

  CacheManager? _viewerCacheManager(BuildContext context) {
    try {
      final container = ProviderScope.containerOf(context, listen: false);
      final viewerUserId = container.read(activeIdentityProvider);
      if (viewerUserId == null) return null;
      return container.read(recipeImageCacheManagerProvider(viewerUserId));
    } on StateError {
      // Small isolated widget tests do not need to construct a ProviderScope.
      return null;
    }
  }
}
