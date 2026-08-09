class PaymentType {
  String id;
  String name;
  String merchantId;
  String? callbackUrl;
  String? callbackDomain;
  String? resolvedCallbackUrl;
  String? defaultCallbackUrl;
  bool isActive;
  bool isSandbox;
  String type;
  PaymentType({
    required this.id,
    required this.name,
    required this.merchantId,
    required this.isActive,
    required this.type,
    this.callbackUrl,
    this.callbackDomain,
    this.resolvedCallbackUrl,
    this.defaultCallbackUrl,
    this.isSandbox = false,
  });

  factory PaymentType.fromJson(Map<String, dynamic> json) {
    final isSandboxRaw = json['is_sandbox'];
    final isSandbox = isSandboxRaw == true ||
        isSandboxRaw?.toString() == '1' ||
        isSandboxRaw?.toString().toLowerCase() == 'true';

    return PaymentType(
      id: json['id'].toString(),
      name: json['name'].toString(),
      merchantId: json['merchant_id'].toString(),
      callbackUrl: json['callback_url']?.toString(),
      callbackDomain: json['callback_domain']?.toString() ??
          json['callback_url']?.toString(),
      resolvedCallbackUrl: json['resolved_callback_url']?.toString(),
      defaultCallbackUrl: json['default_callback_url']?.toString(),
      isActive: json['is_active'].toString() == "0" ? false : true,
      isSandbox: isSandbox,
      type: json['type'].toString(),
    );
  }
}
