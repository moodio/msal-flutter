

import 'package:flutter/cupertino.dart';

class HttpConfiguration {
  final int readTimeout;
  final int connectTimeout;


  HttpConfiguration({@required this.connectTimeout,@required  this.readTimeout});

  Map<String, dynamic> toJson() => {
        "connect_timeout": connectTimeout,
        "read_timeout": readTimeout,
      };
}
