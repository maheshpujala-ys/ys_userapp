enum NoticePriority {
  emergency,
  urgent,
  maintenance,
  general,
  event,
}

class CommunityNotice {
  final String id;
  final String title;
  final String description;
  final String timestamp;
  final NoticePriority priority;
  final String author;
  final bool isRead;

  const CommunityNotice({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.priority,
    required this.author,
    this.isRead = false,
  });
}
