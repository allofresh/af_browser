class AFBrowserUrlPatternMatch {
  final Uri url;

  final Map<String, String> queryParameters;

  final Map<String, String> pathVariableParameters;

  AFBrowserUrlPatternMatch({
    required this.url,
    this.queryParameters = const {},
    this.pathVariableParameters = const {},
  });

  AFBrowserUrlPatternMatch copyWith({
    Map<String, String>? queryParameters,
    Map<String, String>? pathVariableParameters,
    Uri? url,
  }) {
    return AFBrowserUrlPatternMatch(
      queryParameters: queryParameters ?? this.queryParameters,
      pathVariableParameters:
          pathVariableParameters ?? this.pathVariableParameters,
      url: url ?? this.url,
    );
  }
}
