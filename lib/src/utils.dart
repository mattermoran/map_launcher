String enumToString(o) => o.toString().split('.').last;

T enumFromString<T>(Iterable<T> values, String value) {
  return values.firstWhere((type) => type.toString().split('.').last == value,
      orElse: () => null);
}

String buildQueryParams(Map<String, String> queryParams) {
  final queryParamString =
      queryParams.entries.fold('', (previousValue, element) {
    if (element.value == null || element.value == '') {
      return previousValue;
    }
    return '$previousValue&${element.key}=${element.value}';
  });

  return queryParamString;
}
