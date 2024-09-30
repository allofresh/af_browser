import 'package:flutter/material.dart';

class PaymentSuccessScreen extends StatefulWidget {
  const PaymentSuccessScreen({super.key});

  @override
  State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          title: const Text('Flutter Payment Success Screen'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              final navigator = Navigator.of(context);
              if (navigator.canPop()) {
                navigator.pop();
              }
            },
          )),
      body: _buildPaymentSuccess(),
    );
  }

  Widget _buildPaymentSuccess() {
    return const Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Spacer(),
          SizedBox(height: 16),
          Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 64,
          ),
          Text(
            'Payment Success!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.green,
              fontSize: 28,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 32),
          Padding(
            padding: EdgeInsetsDirectional.symmetric(horizontal: 16),
            child: Text(
              "This screen is a mock Flutter payment success screen. "
              "It appears because the browser loaded this URL: https://demo.xendit.co/try-checkout. "
              "Since the URL path pattern matches, the redirection logic implemented in the Demo Screen is triggered."
              "\n\nYou can close this screen to return back to the Demo Screen.",
              style: TextStyle(fontSize: 18),
            ),
          ),
          SizedBox(height: 16),
          Spacer(),
        ],
      ),
    );
  }
}
