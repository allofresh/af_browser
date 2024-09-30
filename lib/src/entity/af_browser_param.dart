import 'package:flutter/foundation.dart';
import 'package:webview_flutter/webview_flutter.dart' as webview_flutter;

import 'af_browser_url_pattern_matcher.dart';

typedef NavigationRequest = webview_flutter.NavigationRequest;
typedef NavigationDecision = webview_flutter.NavigationDecision;

enum AFBrowserCloseButtonType { close, back }

class AFBrowserParam {
  final List<AFBrowserUrlPatternMatcher> urlPatternMatchers;

  final Map<String, ValueSetter<webview_flutter.JavaScriptMessage>> javascriptChannels;

  final AFBrowserCloseButtonType closeButtonType;

  final void Function()? onBrowserClosedByUser;

  final bool hideNavBar;

  final String url;

  final String? browserTitle;

  final bool enableZoom;

  /// to activate user can go back to previous page on webview
  /// when user click back button from device or back button from navbar
  final bool activateGoBack;

  const AFBrowserParam({
    this.hideNavBar = false,
    required this.url,
    this.browserTitle,
    this.onBrowserClosedByUser,
    this.closeButtonType = AFBrowserCloseButtonType.close,
    this.urlPatternMatchers = const [],
    this.javascriptChannels = const {},
    this.activateGoBack = false,
    this.enableZoom = true,
  });
}
