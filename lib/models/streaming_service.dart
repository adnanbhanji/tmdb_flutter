class StreamingService {
  final String id;
  final String name;
  final String logoPath;
  bool isSubscribed;

  StreamingService({
    required this.id,
    required this.name,
    required this.logoPath,
    this.isSubscribed = false,
  });
}
