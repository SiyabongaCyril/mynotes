import 'package:flutter/material.dart';

void navigateToViewAndRemoveOtherViews(BuildContext context, String route) {
  Navigator.of(context).pushNamedAndRemoveUntil(
    route,
    (route) => false,
  );
}

void navigateToView(BuildContext context, String route) {
  Navigator.of(context).pushNamed(route);
}
