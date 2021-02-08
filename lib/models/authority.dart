import 'package:flutter/cupertino.dart';

import 'audience.dart';
import 'authority_type.dart';

class Authority {
  final AuthorityType type;
  final Audience audience;
  final bool mDefault;
  final String authorityUrl;

  Authority(
      {@required this.type,  this.audience, this.mDefault = false, this.authorityUrl});


  Map<String, dynamic> toJson() {
    Map<String, dynamic> audienceJson =this.audience != null ? this.audience.toJson() : null;

    return {
      "type": "${type.toString().split('.').last}",
      if (type == AuthorityType.AAD && audience != null) "audience": audienceJson,
      "default": mDefault,
      if (type == AuthorityType.B2C && authorityUrl.isNotEmpty) "authority_url": authorityUrl,
    };
  }
}

