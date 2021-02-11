import 'package:flutter/services.dart';

import 'method_channel_abstract.dart';

class MethodChannelImpl extends MethodChannelAbstract {
  static const MethodChannel _channel = const MethodChannel('msal_flutter');

  @override
  Future<T> invokeMethod<T>(String method, [arguments]) {
    return _channel.invokeMethod(method, arguments);
  }
}
