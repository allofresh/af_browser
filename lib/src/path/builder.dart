import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../allofresh_browser.dart';
import '../helper/object_extension.dart';

List<GoRoute> afBrowserBuilder() {
  return [
    GoRoute(
      path: AFBrowserPath.afBrowser,
      name: AFBrowserPath.afBrowser,
      builder: (context, state) {
        final extra = state.extra;
        final AFBrowserParam? args = extra?.castOrNull();
        if (args == null) return const SizedBox.shrink();
        return AFBrowser(param: args);
      },
    ),
  ];
}
