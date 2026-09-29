import 'notification_json.dart';
import 'vault_notification.dart';

class NotificationPage {
  NotificationPage({
    required List<VaultNotification> content,
    required this.number,
    required this.size,
    required this.totalPages,
    required this.totalElements,
  }) : content = List.unmodifiable(content);

  final List<VaultNotification> content;
  final int number;
  final int size;
  final int totalPages;
  final int totalElements;

  bool get hasNext => number + 1 < totalPages;

  factory NotificationPage.fromJson(Map<String, dynamic> json) {
    final rawContent = json['content'];
    if (rawContent is! List) {
      throw const FormatException('Notification page content is missing.');
    }

    // Support the two layouts:
    //content, number, size, totalPages, totalElements
    //content, page: { number, size, totalPages, totalElements }
    final metadata =
        json.containsKey('page') ? NotificationJson.object(json['page']) : json;

    final number = NotificationJson.integer(metadata['number'], 'number');
    final size = NotificationJson.integer(
      metadata['size'],
      'size',
      minimum: 1,
    );
    final totalPages = NotificationJson.integer(
      metadata['totalPages'],
      'totalPages',
    );
    final totalElements = NotificationJson.integer(
      metadata['totalElements'],
      'totalElements',
    );

    final content = rawContent
        .map(
          (item) => VaultNotification.fromJson(
            NotificationJson.object(item),
          ),
        )
        .toList();

    if (content.length > size ||
        content.length > totalElements ||
        (totalPages == 0 && content.isNotEmpty)) {
      throw const FormatException('Inconsistent notification page.');
    }

    //out of range requested page can be empty
    return NotificationPage(
      content: content,
      number: number,
      size: size,
      totalPages: totalPages,
      totalElements: totalElements,
    );
  }
}
