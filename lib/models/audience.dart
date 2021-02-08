
import 'microsfot_account.dart';

class Audience {
  final MicrosoftAccount type;
  final String tenantID;

  Audience(this.type, {this.tenantID});

  Map<String, dynamic> toJson() =>
      {"type": "${type.toString().split('.').last}", "tenant_id": tenantID};
}
