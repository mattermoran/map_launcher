/// Builds a URL by combining [url] with [queryParams].
///
/// - If [url] already contains query parameters or a fragment (`#`),
///   they are stripped before adding [queryParams].
/// - Entries with empty-string values are ignored.
/// - Parameters are URL-encoded.
String buildUrl({
  required String url,
  required Map<String, String> queryParams,
}) {
  // Strip off any existing query or fragment
  final baseUrl = url.split('?')[0].split('#')[0];

  // Filter out empty values
  final params = <String, String>{
    for (final entry in queryParams.entries)
      if (entry.value.trim().isNotEmpty) entry.key: entry.value,
  };

  if (params.isEmpty) return baseUrl;

  final query = Uri(queryParameters: params).query;
  return '$baseUrl?$query';
}
