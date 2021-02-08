import 'package:flutter/cupertino.dart';

import 'log_level.dart';

class LoggerConfiguration {
  final bool piiEnabled;
  final LogLevel logLevel;
  final bool logcatEnabled;

  LoggerConfiguration({@required this.logLevel,@required this.logcatEnabled,@required this.piiEnabled});

  Map<String, dynamic> toJson() => {
        "pii_enabled": piiEnabled,
        "log_level": "${logLevel.toString().split('.').last}",
        "logcat_enabled": logcatEnabled,
      };
}
