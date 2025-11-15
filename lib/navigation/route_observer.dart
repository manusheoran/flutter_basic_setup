import 'package:flutter/material.dart';

/// Global route observer so we can listen for page visibility changes
/// across the application.
final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();
