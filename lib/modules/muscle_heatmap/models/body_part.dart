class BodyPart {
  final String slug;
  final String color;
  final List<String> left;
  final List<String> right;

  const BodyPart({
    required this.slug,
    required this.color,
    this.left = const [],
    this.right = const [],
  });
}