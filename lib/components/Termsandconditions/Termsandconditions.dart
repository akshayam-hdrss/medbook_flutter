import 'package:flutter/material.dart';

class TermsAndConditions extends StatelessWidget {
  const TermsAndConditions({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar: AppBar(
  automaticallyImplyLeading: true, // shows the back arrow
  title: const Text(
    'Terms & Conditions',
    style: TextStyle(color: Colors.white),
  ),
  centerTitle: true,
  elevation: 0,
  backgroundColor: Colors.transparent,
  iconTheme: const IconThemeData(color: Colors.white), // makes arrow white
  flexibleSpace: Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Color.fromARGB(255, 225, 119, 20), // orange
          Color.fromARGB(255, 239, 48, 34),  // red
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
  ),
),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
       child: const Text(
  '''
Welcome to Medbook!

By using Medbook, you agree to the following Terms and Conditions. These terms ensure that all users, including patients and healthcare professionals, enjoy a safe and efficient platform experience.

1. Acceptance of Terms  
By accessing or using Medbook, you confirm that you have read, understood, and agreed to these Terms of Service. If you do not agree, you must discontinue use immediately. These terms may be updated occasionally, and continued use constitutes acceptance of those updates. It is your responsibility to review terms periodically. These terms form a binding agreement between you and Medbook.

2. User Eligibility  
To use Medbook, you must be at least 18 years old or have legal parental or guardian consent. By creating an account, you affirm that all information provided is accurate and complete. Fake or misleading profiles are strictly prohibited. Medbook reserves the right to terminate access to users who violate this eligibility requirement.

3. Account Registration and Security  
To access certain features, you must create an account. You are responsible for maintaining the confidentiality of your login credentials. Sharing your account is prohibited. Notify us immediately if you suspect unauthorized activity on your account. Medbook is not liable for losses arising from compromised credentials.

4. Doctor Listings and Information  
Doctors listed on Medbook provide their credentials, services, and availability. Medbook does not guarantee the accuracy of this information. Users are encouraged to verify the qualifications and licenses of healthcare professionals before engaging their services. The platform only facilitates connections, and all medical decisions are the user's responsibility.

5. Booking Appointments  
Users can book appointments with doctors through the platform. You are responsible for ensuring accuracy during the booking process. Appointments may be subject to availability, and rescheduling or cancellations should be made in a timely manner. Missed or canceled appointments may impact your ability to use future services.

6. Communication with Doctors  
Medbook may enable communication between users and doctors via chat or video consultation. These communications should remain professional and respectful. All health-related advice shared on the platform is between the user and the healthcare provider. Medbook does not monitor consultations for medical content.

7. Payments and Refund Policy  
Some services on Medbook may require payment. All payments must be made securely through our authorized gateways. Refunds are subject to the cancellation policy of the respective doctor or service provider. Medbook does not handle direct refunds but can assist in resolving payment-related queries.

8. Privacy and Confidentiality  
We value your privacy and handle your data according to our Privacy Policy. Personal and health data collected is stored securely and shared only with your consent. Medbook complies with data protection regulations. We advise users not to share sensitive medical data in public sections of the app.

9. Prohibited Activities  
Users may not use the app for unlawful, harmful, or abusive purposes. This includes harassment, impersonation, spreading false information, or trying to interfere with system security. Violations can result in suspension or permanent termination of access to Medbook.

10. Termination and Governing Law  
Medbook reserves the right to terminate or suspend your access without notice for violations of these Terms. These Terms are governed by the laws of India. Any disputes shall be resolved through arbitration or the appropriate legal channels.

Thank you for using Medbook. For further questions, contact us at support@medbook.com.
''',
  style: TextStyle(fontSize: 14),
)
  ),
);
}
}