/// Builds a URL by combining [url] with [queryParams].
///
/// - Entries with empty-string values are ignored.
/// - Parameters are URL-encoded.
/// - Existing query parameters in [url] are preserved, but keys in
///   [queryParams] will override them.
String buildUrl({
  required String url,
  required Map<String, String> queryParams,
}) {
  final base = Uri.parse(url);

  final cleaned = <String, String>{
    for (final e in queryParams.entries)
      if (e.value.trim().isNotEmpty) e.key: e.value,
  };

  final merged = {...base.queryParameters, ...cleaned};
  return base.replace(queryParameters: merged).toString();
}
