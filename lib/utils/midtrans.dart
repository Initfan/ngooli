import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:midtrans_sdk/midtrans_sdk.dart';

Future<MidtransSDK?> initializeMidtrans(BuildContext context) async {
  MidtransSDK? midtrans;
  midtrans = await MidtransSDK.init(
    config: MidtransConfig(
      clientKey: dotenv.env['MIDTRANS_CLIENT_KEY'] ?? "",
      merchantBaseUrl: dotenv.env['MIDTRANS_MERCHANT_BASE_URL'] ?? "",
      colorTheme: ColorTheme(
        colorPrimary: Theme.of(context).colorScheme.secondary,
        colorPrimaryDark: Theme.of(context).colorScheme.secondary,
        colorSecondary: Theme.of(context).colorScheme.secondary,
      ),
    ),
  );

  return midtrans;

  // _midtrans.setUIKitCustomSetting(
  //   skipCustomerDetailsPages: true,
  // );

  // _midtrans!.setTransactionFinishedCallback((result) async {
  //   await FirebaseFirestore.instance
  //       .collection('booking')
  //       .doc(widget.bookingId)
  //       .update({'payment_status': 'done'}).then(
  //     (_) => Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(builder: (_) => HomeUser(selected: 1)),
  //     ),
  //   );
  // });
}
