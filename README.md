# AFBrowser
AFBrowser is an enhanced in-app browser package built upon the foundation of the webview_flutter package (https://pub.dev/packages/webview_flutter). It extends the basic functionality with additional features such as URL pattern matching system that enables customized browser callback behaviors.

## URL Path Pattern Matching
One of AFBrowser's standout features is its URL pattern matching capability. This feature allows developers to tailor the browser's callback behavior based on specific URL patterns. The system supports two key pattern matching techniques: wildcard matching using asterisks (*) and path variable capturing using colons (:variable_name).

### Wildcard Matching
The wildcard character (*) can be used to match zero or more URL components. For example:
- Pattern: `*/category/*/detail/*`
- URL: `https://example.com/view/category/12345/detail/view?from_home=true`
- Result: The pattern matches the URL, and the browser callback behavior can be customized accordingly.

### Capturing Path Variables
The variable identifier (:) can be used to capture specific parts of the URL path as variables. For example:
- Pattern: `*/category/:category_id/detail/*`
- URL: `https://example.com/view/category/12345/detail/view?from_home=true`
- Result:
  - Matched URL: `https://example.com/view/category/12345/detail/view?from_home=true`
  - Query parameters: `{'from_home': 'true'}`
  - Path variable parameters: `{'category_id': '12345'}`

## Example Usage
To use AFBrowser in your Flutter project, you can follow this example:

```dart
import 'package:allofresh_browser/allofresh_browser.dart';
import 'package:flutter/material.dart';

class DemoScreen extends StatelessWidget {
  const DemoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AFBrowser Demo')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _openBrowser(context),
          child: const Text('Open Browser'),
        ),
      ),
    );
  }

  void _openBrowser(BuildContext context) {
    final browserScreen = AFBrowser(
      param: AFBrowserParam(
        url: 'https://example.com',
        activateGoBack: true,
        closeButtonType: AFBrowserCloseButtonType.back,
        // Define your URL pattern matchers for the callback here.
        // The patterns will be executed in the order they are listed (first come, first served).
        // If multiple pattern matchers match the URL, all corresponding callbacks will be executed.
        urlPatternMatchers: [
          _paymentSuccessfulPattern(context),
          _categoryDetailPattern(context),
        ],
      ),
    );
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => browserScreen),
    );
  }

  AFBrowserUrlPatternMatcher _paymentSuccessfulPattern(BuildContext context) {
    return AFBrowserUrlPatternMatcher(
      // This pattern matches any URL with the path /try-checkout.
      urlPathPattern: '/try-checkout',
      // The domainRegex matches any URL with the domain xendit.co.
      // For instance, it will match the following URLs:
      // - https://demo.xendit.co/try-checkout
      // - https://checkout-staging.xendit.co/try-checkout
      // - https://checkout.xendit.co/try-checkout
      domainRegex: RegExp(r'.*\.xendit\.co'),
      // This callback is executed when the URL pattern is matched.
      // In this case, it will display a snackbar and redirect the user to the payment success screen.
      onMatched: (match) async {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment successful! Redirecting...'),
            backgroundColor: Colors.green,
          ),
        );
        // Handle successful payment, e.g., navigate to a success screen
      },
    );
  }

  AFBrowserUrlPatternMatcher _categoryDetailPattern(BuildContext context) {
    return AFBrowserUrlPatternMatcher(
      urlPathPattern: '/category/:category_id',
      onMatched: (match) {
        final categoryId = match.pathVariableParameters['category_id'] ?? '';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Category detail tapped: $categoryId'),
            backgroundColor: Colors.blue,
          ),
        );
        // Handle category detail tap
      },
    );
  }
}
```

This example demonstrates how to create a simple screen with a button that opens the `AFBrowser`. It includes two URL pattern matchers:

1. A payment successful pattern that matches URLs ending with `/try-checkout` on the Xendit domain.
2. A category detail pattern that captures the category ID from URLs like `/category/:category_id`.

You can customize these patterns and add more based on your specific requirements.