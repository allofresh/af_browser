import 'package:allofresh_browser/allofresh_browser.dart';
import 'package:flutter/material.dart';

import 'payment_success_screen.dart';

class DemoScreen extends StatefulWidget {
  const DemoScreen({super.key});

  @override
  State<DemoScreen> createState() => _DemoScreenState();
}

class _DemoScreenState extends State<DemoScreen> {
  late final TextEditingController _browserUrlController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        title: const Text('Browser Demo Screen'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                const Text(
                  "Browser URL:",
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _browserUrlController,
                  onFieldSubmitted: (value) {
                    _openBrowser();
                  },
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please input the URL';
                    }
                    if (!_isValidURL(value)) {
                      return 'Invalid URL! Please input a valid URL';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    labelText: 'Input the Browser URL:',
                    hintText: 'https://allofresh.id',
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _openBrowser,
                  child: const Text('Open Browser'),
                ),
                const SizedBox(height: 16),
                _createAutoFillButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _createAutoFillButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          "Click the button below to automatically fill the text field with a specific domain (for testing purposes)",
          style: TextStyle(fontSize: 16),
          textAlign: TextAlign.start,
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            _browserUrlController.text = 'https://demo.midtrans.com/';
          },
          child: const Text('Use Midtrans Demo URL'),
        ),
        ElevatedButton(
          onPressed: () {
            _browserUrlController.text = 'https://demo.xendit.co/';
          },
          child: const Text('Use Xendit Demo URL'),
        ),
        ElevatedButton(
          onPressed: () {
            _browserUrlController.text = 'https://allofresh.id/blog/';
          },
          child: const Text('Use AlloFresh Blog URL'),
        ),
      ],
    );
  }

  bool _isValidURL(String url) {
    final uri = Uri.tryParse(url);
    return uri != null && uri.hasScheme && uri.hasAuthority;
  }

  void _openBrowser() {
    final urlString = _browserUrlController.text;

    if (!_isValidURL(urlString)) {
      const snackbar = SnackBar(
        content: Text('Invalid URL! Please input a valid URL.'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
      return;
    }

    final browserScreen = AFBrowser(
      param: AFBrowserParam(
        url: urlString,
        activateGoBack: true,
        closeButtonType: AFBrowserCloseButtonType.back,
        // Define your URL pattern matchers for the callback here.
        // The patterns will be executed in the order they are listed (first come, first served).
        // If multiple pattern matchers match the URL, all corresponding callbacks will be executed.
        urlPatternMatchers: [
          _paymentSuccessfulPattern(),
          _categoryDetailPattern(),
        ],
      ),
    );
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => browserScreen,
      ),
    );
  }

  AFBrowserUrlPatternMatcher _paymentSuccessfulPattern() {
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
        const snackbar = SnackBar(
          content: Text(
            'URL pattern /try-checkout matched! Redirecting now...',
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackbar);

        await Future.delayed(const Duration(milliseconds: 2000));

        if (!mounted) return;

        final navigator = Navigator.of(context);
        if (navigator.canPop()) {
          navigator.pop();
        }

        const paymentSuccessScreen = PaymentSuccessScreen();
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => paymentSuccessScreen,
          ),
        );
      },
    );
  }

  AFBrowserUrlPatternMatcher _categoryDetailPattern() {
    return AFBrowserUrlPatternMatcher(
      urlPathPattern: '/category/:category_id',
      onMatched: (match) async {
        final categoryId = match.pathVariableParameters['category_id'] ?? '';
        final snackbar = SnackBar(
          content: Text(
            'User tap link for category detali with id: $categoryId',
          ),
          backgroundColor: Colors.deepOrangeAccent,
          behavior: SnackBarBehavior.floating,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackbar);
      },
    );
  }
}
