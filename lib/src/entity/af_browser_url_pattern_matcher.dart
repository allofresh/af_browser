import 'af_browser_url_pattern_match.dart';

class AFBrowserUrlPatternMatcher {
  /// This regular expression is used to validate the domain name of the URL.
  final RegExp _domainRegex;

  /// This regular expression is used to validate the scheme of the URL.
  final RegExp _schemeRegex;

  /// The pattern to be matched with the URL path.
  final String urlPathPattern;

  /// The clo034731sure that will be triggered when the pattern matched.
  final void Function(AFBrowserUrlPatternMatch match) onMatched;

  /// Use this character for matching with zero or more url components
  final String _wildcardCharacter = '*';

  /// Use this character for indicating a variable in the url path
  final String _variableIdentifier = ':';

  /// This flag controls whether the browser can load the URL or not
  /// when the URL pattern matches the actual URL.
  /// - If the flag is true, the browser will load the URL.
  /// - If the flag is false, the browser will not load the URL.
  final bool allowNavigation;

  /// Creates a new [AFBrowserUrlPatternMatcher] instance with the given parameters.
  ///
  /// - The [urlPathPattern] and [onMatched] parameters are required and must not be null.
  /// - The [allowNavigation] parameter is optional and defaults to false. This parameter
  /// controls whether the browser can load the URL or not when the URL pattern matches
  /// - The [domainRegex] and [schemeRegex] parameters are optional and default to matching anything.
  AFBrowserUrlPatternMatcher({
    required this.urlPathPattern,
    required this.onMatched,
    this.allowNavigation = false,
    RegExp? domainRegex,
    RegExp? schemeRegex,
  })  : _domainRegex = domainRegex ?? RegExp(r'.*'),
        _schemeRegex = schemeRegex ?? RegExp(r'.*');

  /// This method attempts to match the given url with the pattern
  /// It returns null if the pattern does not match the url
  /// It returns [AFBrowserUrlPatternMatch] if the pattern matches the url
  /// The pattern can use the following special characters:
  /// - * (wildcard character): to match zero or more url components
  /// - : (variable identifier): to indicate a variable in the url path
  ///
  /// For example:
  /// - Pattern: */category/:category_id/detail/*
  /// - URL: https://allofresh.id/view/category/12345/detail/view?from_home=true
  /// - Result:
  ///   - matched url: https://allofresh.id/view/category/12345/detail/view?from_home=true
  ///   - query parameters: {'from_home': 'true'}
  ///   - path variable parameters: {'category_id': '12345'}
  AFBrowserUrlPatternMatch? match(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return null;

    // Check if the URL has a valid domain name using the domain regular expression
    final domain = uri.host;
    if (!_domainRegex._ignoredCase.hasMatch(domain)) {
      return null;
    }

    // Check if the URL has a valid scheme using the scheme regular expression
    final scheme = uri.scheme;
    if (!_schemeRegex._ignoredCase.hasMatch(scheme)) {
      return null;
    }

    final urlComponents = uri.path._pathComponents();
    final patternComponents = urlPathPattern._pathComponents();

    final currentMatch = AFBrowserUrlPatternMatch(
      queryParameters: uri.queryParameters,
      url: uri,
    );
    return _matchRecursive(
      urlComponents: urlComponents,
      urlComponentIndex: 0,
      patternComponents: patternComponents,
      patternComponentIndex: 0,
      currentMatch: currentMatch,
    );
  }

  /// This method uses backtracking to find out if the url pattern matches the given url
  /// It returns null if the pattern does not match the url
  /// It returns [AFBrowserUrlPatternMatch] if the pattern matches the url
  AFBrowserUrlPatternMatch? _matchRecursive({
    required List<String> urlComponents,
    required int urlComponentIndex,
    required List<String> patternComponents,
    required int patternComponentIndex,
    required AFBrowserUrlPatternMatch currentMatch,
  }) {
    // If both the pattern and the actual URL have reached the end,
    // it means the pattern matches the actual URL, and we can
    // return the current match to the caller.
    if (urlComponentIndex >= urlComponents.length &&
        patternComponentIndex >= patternComponents.length) {
      return currentMatch;
    }

    // If the pattern has reached the end, but the url has not
    // it means the pattern does not match the url.
    // We return null instead.
    if (patternComponentIndex >= patternComponents.length) {
      return null;
    }

    // If the url has reached the end, but the pattern has not, we check
    // if the remaining of the pattern is a wildcard character or not.
    // (since wildcard character can match with 0 or more url components)
    if (urlComponentIndex >= urlComponents.length) {
      if (patternComponents[patternComponentIndex] == _wildcardCharacter) {
        return _matchRecursive(
          urlComponents: urlComponents,
          urlComponentIndex: urlComponentIndex,
          patternComponents: patternComponents,
          patternComponentIndex: patternComponentIndex + 1,
          currentMatch: currentMatch,
        );
      } else {
        return null;
      }
    }

    final currentUrlComponent = urlComponents[urlComponentIndex];
    final currentPatternComponent = patternComponents[patternComponentIndex];

    // Handle wild card pattern
    if (currentPatternComponent == _wildcardCharacter) {
      // possible 1st scenario: match the wild cart with 0 component
      final matchWithZeroComponent = _matchRecursive(
        urlComponents: urlComponents,
        urlComponentIndex: urlComponentIndex,
        patternComponents: patternComponents,
        patternComponentIndex: patternComponentIndex + 1,
        currentMatch: currentMatch,
      );
      if (matchWithZeroComponent != null) {
        return matchWithZeroComponent;
      }

      // possible 2nd scenario: match the wild card with 1 component
      final matchWithOneComponent = _matchRecursive(
        urlComponents: urlComponents,
        urlComponentIndex: urlComponentIndex + 1,
        patternComponents: patternComponents,
        patternComponentIndex: patternComponentIndex + 1,
        currentMatch: currentMatch,
      );
      if (matchWithOneComponent != null) {
        return matchWithOneComponent;
      }

      // possible 3rd scenario: match the wild card with > 1 components
      final matchWithMoreThanOneComponent = _matchRecursive(
        urlComponents: urlComponents,
        urlComponentIndex: urlComponentIndex + 1,
        patternComponents: patternComponents,
        patternComponentIndex: patternComponentIndex,
        currentMatch: currentMatch,
      );
      if (matchWithMoreThanOneComponent != null) {
        return matchWithMoreThanOneComponent;
      }

      // if none of the scenarios above works, it means the wild card
      // does not match with the url components. We return null instead.
      return null;
    }

    // Handle variable pattern
    if (currentPatternComponent.startsWith(_variableIdentifier)) {
      var currentVariables = currentMatch.pathVariableParameters;
      final variableName = currentPatternComponent.substring(1);
      final newVariables = {
        ...currentVariables,
        variableName: currentUrlComponent,
      };
      final newCurrentMatch = currentMatch.copyWith(
        pathVariableParameters: newVariables,
      );
      return _matchRecursive(
        urlComponents: urlComponents,
        urlComponentIndex: urlComponentIndex + 1,
        patternComponents: patternComponents,
        patternComponentIndex: patternComponentIndex + 1,
        currentMatch: newCurrentMatch,
      );
    }

    // Handle normal pattern
    if (currentUrlComponent == currentPatternComponent) {
      return _matchRecursive(
        urlComponents: urlComponents,
        urlComponentIndex: urlComponentIndex + 1,
        patternComponents: patternComponents,
        patternComponentIndex: patternComponentIndex + 1,
        currentMatch: currentMatch,
      );
    }

    // If none of the cases above applies, it means the pattern does not match
    // the url. We return null instead.
    return null;
  }
}

extension _StringHelper on String {
  /// Returns a list of path components in this string, after converting them to lower case.
  ///
  /// For example, '/checkout/Xendit' becomes ['', 'checkout', 'xendit'].
  /// If this string is empty, returns an empty list.
  List<String> _pathComponents() {
    if (isEmpty) {
      return [];
    }
    return split('/').map((component) {
      return component.toLowerCase();
    }).toList();
  }
}

extension _RegexHelper on RegExp {
  /// Returns a case insensitive version of this regular expression.
  RegExp get _ignoredCase {
    return RegExp(
      pattern,
      caseSensitive: false,
    );
  }
}
