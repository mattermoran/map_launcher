/// Extension methods for working with nullable [String] values.
extension StringX on String? {
  /// Returns `true` if this string is neither `null` nor empty (`''`).
  bool get isNotNullOrEmpty => this?.isNotEmpty ?? false;
}
