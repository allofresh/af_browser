import 'package:allofresh_browser/src/entity/af_browser_url_pattern_matcher.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AF Browser URL Pattern Matcher - Matched', () {
    test('Match root domain with trailing /', () {
      const url = 'https://allofresh.id/';
      final pattern = _createPattern('/');
      final match = pattern.match(url);

      expect(match?.url, Uri.parse(url));
      expect(match?.queryParameters, {});
      expect(match?.pathVariableParameters, {});
    });
    test('Match root domain without trailing /', () {
      const url = 'https://allofresh.id';
      final pattern = _createPattern('');
      final match = pattern.match(url);

      expect(match?.url, Uri.parse(url));
      expect(match?.queryParameters, {});
      expect(match?.pathVariableParameters, {});
    });
    test('Match URL with trailing /', () {
      const url = 'https://www.google.com/users/';
      final pattern = _createPattern('/users/');
      final match = pattern.match(url);

      expect(match?.url, Uri.parse(url));
      expect(match?.queryParameters, {});
      expect(match?.pathVariableParameters, {});
    });
    test('Match simple pattern', () {
      const url = 'https://allofresh.id/checkout/success?order_id=1';
      final pattern = _createPattern('/checkout/success');
      final match = pattern.match(url);

      expect(match?.url, Uri.parse(url));
      expect(match?.queryParameters, {'order_id': '1'});
      expect(match?.pathVariableParameters, {});
    });
    test('Wildcard pattern match with 0 url component', () {
      const url = 'https://allofresh.id/checkout/success';
      final pattern = _createPattern('*/checkout/success/*');
      final match = pattern.match(url);

      expect(match?.url, Uri.parse(url));
      expect(match?.queryParameters, {});
      expect(match?.pathVariableParameters, {});
    });
    test('Wildcard pattern match with 1 url component', () {
      const url = 'https://allofresh.id/checkout/success?order_id=1';
      final pattern = _createPattern('*/success');
      final match = pattern.match(url);

      expect(match?.url, Uri.parse(url));
      expect(match?.queryParameters, {'order_id': '1'});
      expect(match?.pathVariableParameters, {});
    });
    test('Wildcard pattern match with > 1 url components', () {
      const url = 'https://allofresh.id/callback/xendit/checkout/fail';
      final pattern = _createPattern('*/checkout/fail');
      final match = pattern.match(url);

      expect(match?.url, Uri.parse(url));
      expect(match?.queryParameters, {});
      expect(match?.pathVariableParameters, {});
    });
    test('Match variable pattern and captured it', () {
      const url = 'https://allofresh.id/checkout/success?order_id=App-12345';
      final pattern = _createPattern('/checkout/:status');
      final match = pattern.match(url);

      expect(match?.url, Uri.parse(url));
      expect(match?.queryParameters, {'order_id': 'App-12345'});
      expect(match?.pathVariableParameters, {'status': 'success'});
    });
    test('Match combination of wildcard and variable pattern', () {
      const url =
          'https://allofresh.id/categories/12345/detail/view?from_home=true';
      final pattern = _createPattern('*/categories/:id/*');
      final match = pattern.match(url);

      expect(match?.url, Uri.parse(url));
      expect(match?.queryParameters, {'from_home': 'true'});
      expect(match?.pathVariableParameters, {'id': '12345'});
    });
    test('Match with custom uri scheme', () {
      const url =
          'shopeeid://reactPath?navigate_url=https%3A%2F%2Fshopee.co.id%2Fxxxx&path=shopee%2F';
      final pattern = _createPattern(
        '',
        schemeRegex: RegExp(r'shopeeid'),
        domainRegex: RegExp(r'reactPath'),
      );
      final match = pattern.match(url);

      expect(match?.url, Uri.parse(url));
      expect(match?.queryParameters, {
        'navigate_url': 'https://shopee.co.id/xxxx',
        'path': 'shopee/',
      });
      expect(match?.pathVariableParameters, {});
    });
    test('The pattern must be case insensitive', () {
      const url = 'https://ALLOFRESH.id/view/category/12345/detail/view';
      final pattern = _createPattern(
        '/view/CATEGORY/:id/detail/view',
        domainRegex: RegExp(r'allofresh'),
        schemeRegex: RegExp(r'HTTPS'),
      );
      final match = pattern.match(url);

      expect(match?.url, Uri.parse(url));
      expect(match?.queryParameters, {});
      expect(match?.pathVariableParameters, {'id': '12345'});
    });
  });

  group('AF Browser URL Pattern Matcher - Not Matched', () {
    test('Does not match root domain with trailing slash', () {
      const url = 'https://allofresh.id/';
      final pattern = _createPattern('');
      final match = pattern.match(url);

      expect(match, null);
    });
    test('Does not match root domain without trailing slash', () {
      const url = 'https://allofresh.id';
      final pattern = _createPattern('/');
      final match = pattern.match(url);

      expect(match, null);
    });
    test('Does not match if pattern matched but the domain not matched', () {
      const url = 'https://allofresh.id/users/';
      final pattern = _createPattern(
        '/users/',
        domainRegex: RegExp(r'staging\.allofresh\.id'),
      );
      final match = pattern.match(url);

      expect(match, null);
    });
    test('Does not match simple url pattern', () {
      const url = 'https://allofresh.id/checkout/success?order_id=1';
      final pattern = _createPattern('/checkout/fail');
      final match = pattern.match(url);

      expect(match, null);
    });
    test('Does not match wildcard pattern', () {
      const url = 'https://allofresh.id/checkout/xendit/success?order_id=1';
      final pattern = _createPattern('/checkout/success');
      final match = pattern.match(url);

      expect(match, null);
    });
    test('Does not match variable pattern', () {
      const url = 'https://allofresh.id/order/1235123/detail';
      final pattern = _createPattern('/order/:id/view');
      final match = pattern.match(url);

      expect(match, null);
    });
    test('Does not match combination of wildcard and variable pattern', () {
      const url =
          'https://allofresh.id/categories/12345/detail/view?from_home=true';
      final pattern = _createPattern('*/categories/:id/view');
      final match = pattern.match(url);

      expect(match, null);
    });
    test('Does not match if pattern matched but the scheme not matched', () {
      const url =
          'shopeeid://reactPath?navigate_url=https%3A%2F%2Fshopee.co.id%2Fxxxx&path=shopee%2F';
      final pattern = _createPattern(
        '',
        schemeRegex: RegExp(r'allofresh'),
        domainRegex: RegExp(r'notReactPath'),
      );
      final match = pattern.match(url);

      expect(match, null);
    });
  });
}

AFBrowserUrlPatternMatcher _createPattern(
    String urlPattern, {
      RegExp? domainRegex,
      RegExp? schemeRegex,
    }) {
  return AFBrowserUrlPatternMatcher(
    urlPathPattern: urlPattern,
    domainRegex: domainRegex,
    schemeRegex: schemeRegex,
    onMatched: (_) {},
  );
}
