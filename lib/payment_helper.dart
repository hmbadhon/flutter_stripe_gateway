import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

class PaymentHelper {
  String kPublishableKey =
      'pk_test_51KGVjiC6r0UrWGk6j0CIrKz5rI7byN9Mtmc3nbvOgbSzyzcC3HBiEHdc9gDGFD915uscU6zGAV2lgeGPmiSVjOvJ00n1eqWHh5';
  String kSecretKey =
      'sk_test_51KGVjiC6r0UrWGk6isiqs2va5HNiHDR8YpAzHP0oOEijwITnAsDsaOdv8qVg3WqVHVUwIQ36QybsrLGDM8oygndE00D1YmM9VN';

  late Map<String, dynamic> paymentIntentData;

  Future<void> makePayment({
    required BuildContext context,
    required String amount,
  }) async {
    try {
      paymentIntentData = await createPaymentIntent(
          amount, 'USD'); //json.decode(response.body);
      // log('Response body==>${response.body.toString()}');
      await Stripe.instance
          .initPaymentSheet(
            paymentSheetParameters: SetupPaymentSheetParameters(
              paymentIntentClientSecret: paymentIntentData['client_secret'],
              applePay: true,
              googlePay: true,
              testEnv: true,
              style: ThemeMode.light,
              merchantCountryCode: 'US',
              merchantDisplayName: 'HM Badhon',
            ),
          )
          .then((value) {});

      ///now finally display payment sheeet
      displayPaymentSheet(
        context: context,
      );
    } catch (e, s) {
      log('exception:$e$s');
    }
  }

  displayPaymentSheet({
    required BuildContext context,
  }) async {
    try {
      await Stripe.instance.presentPaymentSheet().then((newValue) async {
        log('payment intent' + paymentIntentData['id'].toString());
        log('payment intent' + paymentIntentData['client_secret'].toString());
        log('payment intent' + paymentIntentData['amount'].toString());
        log('payment intent' + paymentIntentData.toString());
        //orderPlaceApi(paymentIntentData!['id'].toString());
        // showCustomSnackBar('paid successfully');

        paymentIntentData = {};
      }).onError((error, stackTrace) {
        log('Exception/DISPLAYPAYMENTSHEET==> $error $stackTrace');
      });
    } on StripeException catch (e) {
      log('Exception/DISPLAYPAYMENTSHEET==> $e');
      showDialog(
          context: context,
          builder: (_) => const AlertDialog(
                content: Text("Cancelled "),
              ));
    } catch (e) {
      log('$e');
    }
  }

  //  Future<Map<String, dynamic>>
  createPaymentIntent(String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': calculateAmount(amount),
        'currency': currency,
        'payment_method_types[]': 'card'
      };
      log(body.toString());
      var response = await http.post(
          Uri.parse('https://api.stripe.com/v1/payment_intents'),
          body: body,
          headers: {
            'Authorization': 'Bearer $kSecretKey',
            'Content-Type': 'application/x-www-form-urlencoded'
          });
      log('Create Intent reponse ===> ${response.body.toString()}');
      return jsonDecode(response.body);
    } catch (err) {
      log('err charging user: ${err.toString()}');
    }
  }

  calculateAmount(String amount) {
    final a = (int.parse(amount)) * 100;
    return a.toString();
  }
}
