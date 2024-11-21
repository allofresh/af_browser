import 'dart:async';
import 'dart:io';

import 'package:allofresh_browser/src/helper/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart' as webview;

import '../../allofresh_browser.dart';

class AFBrowser extends StatefulWidget {
  final AFBrowserParam param;

  const AFBrowser({
    super.key,
    required this.param,
  });

  @override
  State<AFBrowser> createState() => _AFBrowserState();
}

class _AFBrowserState extends State<AFBrowser> {
  late final requestUri = Uri.tryParse(widget.param.url);
  late final _webviewController = webview.WebViewController();

  /// This set contains a list of URL which the HTTP codes have
  /// been validated (for sending non fatal exception to Crashlytics
  /// if the https status code is between 400 - 500)
  bool isForceClose = false;

  @override
  void initState() {
    super.initState();
    _loadUrl();
  }

  void _loadUrl() async {
    await Future.wait([
      _webviewController.setJavaScriptMode(webview.JavaScriptMode.unrestricted),
      _webviewController.setBackgroundColor(Colors.white),
      _webviewController.enableZoom(widget.param.enableZoom),
      _webviewController._enableAndroidXenditCopyToClipboard(),
      _webviewController._registerJavascriptChannel(
        channels: widget.param.javascriptChannels,
      ),
      _webviewController.setNavigationDelegate(
        webview.NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            return _validatePatternMatchers(request);
          },
          onWebResourceError: (error) {},
          onPageFinished: (url) {
            if (!mounted) return;
            setState(() {});
          },
          onPageStarted: (url) {},
          onUrlChange: (change) {},
        ),
      ),
    ]);

    final url = requestUri;
    if (url == null) return;
    _webviewController.loadRequest(url);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPopped) async {
        if (didPopped) return;

        final canGoBack = await _webviewController.canGoBack();
        final shouldPop = widget.param.activateGoBack ? !canGoBack : true;
        if (shouldPop && context.mounted) {
          widget.param.onBrowserClosedByUser?.call();
          context.pop();
        } else if (canGoBack) {
          _webviewController.goBack();
        }
      },
      child: Scaffold(
        appBar: _buildNavBar(),
        body: _buildWebView(),
      ),
    );
  }

  PreferredSizeWidget? _buildNavBar() {
    if (widget.param.hideNavBar) return null;
    return AppBar(
      title: FutureBuilder(
        future: _webviewController.getTitle(),
        builder: (context, snapshot) => Text(
          widget.param.browserTitle ?? snapshot.data ?? '',
          style: const TextStyle(color: Colors.black),
        ),
      ),
      leading: _buildCloseButton(),
    );
  }

  Widget? _buildCloseButton() {
    if (widget.param.closeButtonType == AFBrowserCloseButtonType.back) {
      return IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.of(context).maybePop();
        },
      );
    }

    return InkWell(
      onTap: () {
        isForceClose = true;
        Navigator.of(context).maybePop();
      },
      child: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Icon(Icons.close),
      ),
    );
  }

  Widget _buildWebView() {
    return SafeArea(
      left: false,
      bottom: false,
      right: false,
      child: webview.WebViewWidget(controller: _webviewController),
    );
  }

  /// Validates the navigation [request] against the url pattern matchers.
  /// Returns [NavigationDecision.navigate] if all matchers allow navigation, otherwise [NavigationDecision.prevent].
  /// [NavigationDecision.navigate] means that the browser will load the requested url.
  /// [NavigationDecision.prevent] means that the browser will not load the requested url.
  NavigationDecision _validatePatternMatchers(NavigationRequest request) {
    var allowNavigation = true;
    for (final patternMatcher in widget.param.urlPatternMatchers) {
      final match = patternMatcher.match(request.url);
      if (match == null) continue;
      patternMatcher.onMatched.call(match);
      allowNavigation = allowNavigation && patternMatcher.allowNavigation;
    }
    return allowNavigation
        ? NavigationDecision.navigate
        : NavigationDecision.prevent;
  }
}

extension JSBridges on webview.WebViewController {
  /// Adds a JavaScript channel called WebviewFlutterClipboard to the Xendit webview
  /// to allow copying messages from the webview to the clipboard.
  /// This method is only for Android because iOS has a different issue with the
  /// same JS bridge for copying to clipboard. When iOS uses the JS bridge, the
  /// invoice amount sent by Xendit is in decimal format (13700.0 instead of 13700).
  /// Since iOS can copy to clipboard without JS, this method is not needed for iOS.
  Future<void> _enableAndroidXenditCopyToClipboard() async {
    if (!Platform.isAndroid) return;
    return addJavaScriptChannel(
      'WebviewFlutterClipboard',
      onMessageReceived: (message) {
        Clipboard.setData(ClipboardData(text: message.message));
      },
    );
  }

  Future<void> _registerJavascriptChannel({
    required Map<String, ValueSetter<JavaScriptMessage>> channels,
  }) async {
    for (final channel in channels.entries) {
      await addJavaScriptChannel(
        channel.key,
        onMessageReceived: channel.value,
      );
    }
  }
}
