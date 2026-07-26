class ExploreItem {
  const ExploreItem({
    required this.id,
    required this.title,
    required this.imageUrl,
    this.matchPercent,
    this.isMissingItems = false,
    this.isVideo = false,
  });

  final int id;
  final String title;
  final String imageUrl;
  final int? matchPercent;
  final bool isMissingItems;
  final bool isVideo;
}