import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

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

    return CachedNetworkImage(
      imageUrl: url,
      fit: fit,
      alignment: alignment,
      placeholder: (_, __) => placeholder,
      errorWidget: (_, __, ___) => placeholder,
    );
  }
}
