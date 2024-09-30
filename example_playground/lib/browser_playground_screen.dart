import 'package:allofresh_browser/allofresh_browser.dart';
import 'package:flutter/material.dart';

class BrowserPlaygroundScreen extends StatefulWidget {
  const BrowserPlaygroundScreen({super.key});

  @override
  State<BrowserPlaygroundScreen> createState() =>
      _BrowserPlaygroundScreenState();
}

class _BrowserPlaygroundScreenState extends State<BrowserPlaygroundScreen> {
  final _browserTitleController = TextEditingController();

  final _browserUrlController =
      TextEditingController(text: 'https://www.google.com');

  final _patternPathController = TextEditingController();

  final _patternUrlController = TextEditingController();

  final _schemeRegexController = TextEditingController();

  final _domainRegexController = TextEditingController();

  var _browserCloseButtonType = AFBrowserCloseButtonType.back;

  bool _hideBrowserNavbar = false;

  bool _enableGoToPreviousURL = true;

  AFBrowserUrlPatternMatch? _urlPatternMatch;

  @override
  void dispose() {
    _browserTitleController.dispose();
    _browserUrlController.dispose();
    _patternPathController.dispose();
    _patternUrlController.dispose();
    _schemeRegexController.dispose();
    _domainRegexController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Browser Playground')),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ListView(
                  children: [
                    ..._buildBrowserConfigsSection(),
                    const SizedBox(height: 16),
                    const Divider(height: 1, color: Colors.grey),
                    const SizedBox(height: 16),
                    ..._buildUrlPatternMatcherSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildBrowserConfigsSection() {
    return [
      const SizedBox(height: 16),
      _buildSectionTitle('Browser Configs'),
      _buildTextField(
        textFieldTitle: 'Title',
        textFieldPlaceholder: 'AF Browser',
        textController: _browserTitleController,
        onSubmit: (_) => _openAFBrowser(context),
      ),
      const SizedBox(height: 8),
      _buildTextField(
        textFieldTitle: 'URL',
        textFieldPlaceholder: 'https://www.google.com',
        textController: _browserUrlController,
        onSubmit: (_) => _openAFBrowser(context),
      ),
      const SizedBox(height: 8),
      Row(
        children: [
          const Text(
            'Hide Browser Navbar?',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox.square(
            dimension: 32,
            child: Checkbox(
              value: _hideBrowserNavbar,
              onChanged: (hidden) {
                if (hidden == null) return;
                setState(() {
                  _hideBrowserNavbar = hidden;
                });
              },
            ),
          ),
        ],
      ),
      const SizedBox(height: 8),
      Row(
        children: [
          const Text(
            'Enable Go To Previous URL?',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox.square(
            dimension: 32,
            child: Checkbox(
              value: _enableGoToPreviousURL,
              onChanged: (enabled) {
                if (enabled == null) return;
                setState(() {
                  _enableGoToPreviousURL = enabled;
                });
              },
            ),
          ),
        ],
      ),
      const SizedBox(height: 8),
      Row(
        children: [
          const Text(
            'Close Button Type: ',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: DropdownButtonFormField<AFBrowserCloseButtonType>(
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.all(8),
                border: OutlineInputBorder(),
              ),
              hint: null,
              iconSize: 16.0,
              value: _browserCloseButtonType,
              isDense: true,
              onChanged: (type) {
                if (type == null) return;
                setState(() {
                  _browserCloseButtonType = type;
                });
              },
              items: AFBrowserCloseButtonType.values.map((type) {
                return DropdownMenuItem<AFBrowserCloseButtonType>(
                  value: type,
                  child: Text(
                    type == AFBrowserCloseButtonType.close ? 'Close' : 'Back',
                    style: const TextStyle(fontSize: 16),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
      const SizedBox(height: 8),
      ElevatedButton(
        style: ElevatedButton.styleFrom(
          textStyle: const TextStyle(fontSize: 16),
        ),
        onPressed: () => _openAFBrowser(context),
        child: const Text('Open Browser'),
      ),
    ];
  }

  List<Widget> _buildUrlPatternMatcherSection() {
    return [
      _buildSectionTitle('URL Pattern Matcher'),
      _buildTextField(
        textFieldTitle: 'URL',
        textFieldPlaceholder: 'https://allofresh.id',
        textController: _patternUrlController,
        onSubmit: (_) => _matchUrlPattern(),
      ),
      const SizedBox(height: 8),
      _buildTextField(
        textFieldTitle: 'URL Path Pattern',
        textFieldPlaceholder: '*/transcheckout/*/success',
        textController: _patternPathController,
        onSubmit: (_) => _matchUrlPattern(),
      ),
      const SizedBox(height: 8),
      _buildTextField(
        textFieldTitle: 'Scheme Regex',
        textFieldPlaceholder: '.*',
        textController: _schemeRegexController,
        onSubmit: (_) => _matchUrlPattern(),
      ),
      const SizedBox(height: 8),
      _buildTextField(
        textFieldTitle: 'Domain Regex',
        textFieldPlaceholder: '.*',
        textController: _domainRegexController,
        onSubmit: (_) => _matchUrlPattern(),
      ),
      const SizedBox(height: 8),
      ElevatedButton(
        style: ElevatedButton.styleFrom(
          textStyle: const TextStyle(fontSize: 16),
        ),
        onPressed: _matchUrlPattern,
        child: const Text('Validate Pattern'),
      ),
      ..._buildPatternMatcherResult(),
    ];
  }

  List<Widget> _buildPatternMatcherResult() {
    List<Widget> widgets = [];
    widgets.add(const SizedBox(height: 12));
    widgets.add(_buildSectionTitle('Url Pattern Matcher Result'));

    if (_patternPathController.text.isEmpty) {
      widgets.add(
        const Text(
          'URL Path Pattern is empty',
          style: TextStyle(fontSize: 16),
        ),
      );
    } else if (_urlPatternMatch == null) {
      widgets.add(
        const Text(
          'Not matched',
          style: TextStyle(fontSize: 16, color: Colors.red),
        ),
      );
    } else {
      widgets.addAll(
        [
          const Text(
            'Matched with the following result:',
            style: TextStyle(fontSize: 16, color: Colors.green),
          ),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              children: [
                const TextSpan(
                  text: 'Url: ',
                  style: TextStyle(fontSize: 16, color: Colors.green),
                ),
                TextSpan(
                  text: _urlPatternMatch!.url.toString(),
                  style: const TextStyle(fontSize: 16, color: Colors.green),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              children: [
                const TextSpan(
                  text: 'Query Parameters: ',
                  style: TextStyle(color: Colors.green, fontSize: 16),
                ),
                TextSpan(
                  text: _urlPatternMatch!.queryParameters.toString(),
                  style: const TextStyle(fontSize: 16, color: Colors.green),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              children: [
                const TextSpan(
                  text: 'Path Variable Parameters: ',
                  style: TextStyle(color: Colors.green, fontSize: 16),
                ),
                TextSpan(
                  text: _urlPatternMatch!.pathVariableParameters.toString(),
                  style: const TextStyle(fontSize: 16, color: Colors.green),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return widgets;
  }

  Widget _buildSectionTitle(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildTextField({
    required String textFieldTitle,
    required String? textFieldPlaceholder,
    required TextEditingController textController,
    required void Function(String) onSubmit,
  }) {
    return Row(
      children: [
        Text(
          '$textFieldTitle: ',
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(
          width: 4,
        ),
        Expanded(
          child: TextFormField(
            controller: textController,
            onFieldSubmitted: onSubmit,
            decoration: InputDecoration(
              hintText: textFieldPlaceholder,
              contentPadding: const EdgeInsets.all(8),
              border: const OutlineInputBorder(),
              hintStyle: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ),
        ),
      ],
    );
  }

  void _matchUrlPattern() {
    RegExp? domainRegex;
    try {
      domainRegex = RegExp(_domainRegexController.text);
    } catch (_) {
      domainRegex = null;
    }

    RegExp? schemeRegex;
    try {
      schemeRegex = RegExp(_schemeRegexController.text);
    } catch (_) {
      schemeRegex = null;
    }

    final urlPatternMatcher = AFBrowserUrlPatternMatcher(
      urlPathPattern: _patternPathController.text,
      domainRegex: domainRegex,
      schemeRegex: schemeRegex,
      onMatched: (_) {},
    );
    setState(() {
      _urlPatternMatch = urlPatternMatcher.match(_patternUrlController.text);
    });
  }

  void _openAFBrowser(BuildContext context) {
    final validatedUrl = _validateBrowserUrl();
    if (validatedUrl == null) return;

    final browserTitle = _browserTitleController.text;

    final browser = AFBrowser(
      param: AFBrowserParam(
        url: validatedUrl.toString(),
        browserTitle: browserTitle.isEmpty ? null : browserTitle,
        hideNavBar: _hideBrowserNavbar,
        closeButtonType: _browserCloseButtonType,
        onBrowserClosedByUser: () {
          const snackBar = SnackBar(
            content: Text('Browser closed by user'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        },
        activateGoBack: _enableGoToPreviousURL,
      ),
    );
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => browser));
  }

  Uri? _validateBrowserUrl() {
    void onBrowserInvalid() {
      final snackBar = SnackBar(
        content: Text('Browser url: ${_browserUrlController.text} is invalid'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }

    final url = Uri.tryParse(_browserUrlController.text);
    if (url == null) {
      onBrowserInvalid();
      return null;
    }

    if (url.scheme.isEmpty) {
      onBrowserInvalid();
      return null;
    }

    return url;
  }
}
