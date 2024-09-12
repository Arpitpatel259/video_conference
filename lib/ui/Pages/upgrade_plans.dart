import 'package:flutter/material.dart';

class UpgradePlans extends StatelessWidget {
  const UpgradePlans({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffffffff),
      appBar: AppBar(
        elevation: 4,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xff3a57e8),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        title: const Text(
          "Upgrade Plans",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontStyle: FontStyle.normal,
            fontSize: 20,
            color: Color(0xffffffff),
          ),
        ),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            Container(
              color: const Color(0xffffffff),
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: UpgradePlanCard(
                planName: 'Basic Plan',
                price: '\$9.99/month',
                features: const [
                  'Up to 50 participants per meeting',
                  '40 minutes per session',
                  'Screen sharing',
                  'Chat support',
                  'Virtual backgrounds',
                ],
                onTap: () {
                  showFeatureComingSoonDialog(context);
                },
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: UpgradePlanCard(
                planName: 'Pro Plan',
                price: '\$19.99/month',
                features: const [
                  'Up to 100 participants per meeting',
                  'Unlimited meeting duration',
                  'Cloud recording (10 GB storage)',
                  'Advanced screen sharing (multiple screens)',
                  'Priority customer support',
                ],
                onTap: () {
                  showFeatureComingSoonDialog(context);
                },
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: UpgradePlanCard(
                planName: 'Enterprise Plan',
                price: '\$49.99/month',
                features: const [
                  'Up to 500 participants per meeting',
                  'Unlimited meeting duration',
                  'Cloud recording (100 GB storage)',
                  'Custom branding and logos',
                  'Integration with CRM tools',
                  'Dedicated account manager',
                ],
                onTap: () {
                  showFeatureComingSoonDialog(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showFeatureComingSoonDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          title: const Text(
            'Coming Soon!',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
            textAlign: TextAlign.center,
          ),
          content: const Text(
            'This feature is coming in the future. Stay tuned!',
            textAlign: TextAlign.center,
          ),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'OK',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class UpgradePlanCard extends StatelessWidget {
  final String planName;
  final String price;
  final List<String> features;
  final VoidCallback onTap;

  const UpgradePlanCard({
    required this.planName,
    required this.price,
    required this.features,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              planName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              price,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: features.map((feature) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.check, color: Colors.green, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          feature,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                alignment: Alignment.center, // Ensures content is centered
                backgroundColor: Colors.deepPurple,
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      'Upgrade Now',
                      textAlign: TextAlign.center,
                      // Ensures the text is centered within its space
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
