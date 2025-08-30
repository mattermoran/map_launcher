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
  return queryParams.entries
      .fold('$url?', (dynamic previousValue, element) {
    if (element.value == null || element.value == '') {
      return previousValue;
    }
    return '$previousValue&${Uri.encodeQueryComponent(element.key)}=${Uri.encodeQueryComponent(element.value)}';
  }).replaceFirst('&', '');
}
