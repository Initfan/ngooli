import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:midtrans_sdk/midtrans_sdk.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<MidtransSDK> initializeMidtrans(BuildContext context) async {
  final midtrans = await MidtransSDK.init(
    config: MidtransConfig(
      clientKey: dotenv.env['MIDTRANS_CLIENT_KEY'] ?? "",
      merchantBaseUrl: dotenv.env['MIDTRANS_MERCHANT_BASE_URL'] ?? "",
    ),
  );

  midtrans.setUIKitCustomSetting(
    showPaymentStatus: true,
    skipCustomerDetailsPages: true,
  );

  return midtrans;
}

Future<String> createTransaction(
  String orderId,
  double price,
  Map<String, dynamic> customer,
) async {
  final key = dotenv.env['MIDTRANS_SERVER_KEY']!;
  final res = await http.post(
    Uri.parse("https://app.sandbox.midtrans.com/snap/v1/transactions"),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Basic ${base64Encode(utf8.encode(key))}:',
    },
    body: jsonEncode(
      {
        "transaction_details": {
          "order_id": orderId,
          "gross_amount": price,
        },
        "credit_card": {"secure": true},
        "customer_details": customer,
      },
    ),
  );
  return jsonDecode(res.body)['token'];
}
