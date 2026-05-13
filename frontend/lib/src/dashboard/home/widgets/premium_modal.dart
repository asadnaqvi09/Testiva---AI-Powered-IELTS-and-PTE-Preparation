import 'package:flutter/material.dart';

class PremiumModal extends StatefulWidget {
  const PremiumModal({super.key});

  @override
  State<PremiumModal> createState() => _PremiumModalState();
}

class _PremiumModalState extends State<PremiumModal> {
  // 0: Plans, 1: Payment Method Selection
  int _currentStep = 0;
  bool _isDigitalWallet = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.all(24),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _currentStep == 0 ? _buildPlansStep() : _buildPaymentStep(),
      ),
    );
  }

  // --- STEP 1: PLANS SCREEN ---
  Widget _buildPlansStep() {
    return Column(
      key: const ValueKey(0),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(child: _buildHandle()),
        const SizedBox(height: 24),
        _buildHeader('🚀 Unlock Premium', 'Choose a plan that fits your prep journey'),
        const SizedBox(height: 24),
        _packageCard(title: 'Basic Package', price: 'Rs399', features: ['IELTS Reading', 'IELTS Writing', 'IELTS Listening', 'IELTS Speaking']),
        const SizedBox(height: 16),
        _packageCard(title: 'Premium Package', price: 'Rs699', isSelected: true, features: ['Everything in Basic', 'PTE Full Preparation', 'AI Analysis & Reports']),
        const Spacer(),
        _buildButton('Continue to Payment', () => setState(() => _currentStep = 1)),
      ],
    );
  }

  // --- STEP 2: PAYMENT SCREEN ---
  Widget _buildPaymentStep() {
    return Column(
      key: const ValueKey(1),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(child: _buildHandle()),
        const SizedBox(height: 24),
        _buildHeader('💳 Payment', 'Premium Package - Rs699'),
        const SizedBox(height: 20),

        // Tab Switcher (Debit vs Digital Wallet)
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: [
              _buildTab('Debit/Credit', Icons.credit_card, !_isDigitalWallet, () => setState(() => _isDigitalWallet = false)),
              _buildTab('Digital Wallet', Icons.account_balance_wallet, _isDigitalWallet, () => setState(() => _isDigitalWallet = true)),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Dynamic Form based on selection
        _isDigitalWallet ? _buildDigitalWalletView() : _buildCardView(),

        const Spacer(),
        _buildButton(_isDigitalWallet ? 'Select Provider' : 'Pay Now Rs699', () {}),
        Center(
          child: TextButton(
            onPressed: () => setState(() => _currentStep = 0),
            child: const Text('← Back to plans', style: TextStyle(color: Colors.grey)),
          ),
        ),
      ],
    );
  }

  // Card Input View
  Widget _buildCardView() {
    return Column(
      children: [
        _buildTextField('Card Number', '4242 4242 4242 4242', Icons.credit_card),
        const SizedBox(height: 16),
        _buildTextField('Name on Card', 'Ahmed Khan', Icons.person_outline),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildTextField('Expiry Date', '12/28', null)),
            const SizedBox(width: 16),
            Expanded(child: _buildTextField('CVV', '123', null)),
          ],
        ),
      ],
    );
  }

  // Digital Wallet View
  Widget _buildDigitalWalletView() {
    return Column(
      children: [
        _walletButton('Pay with Easypaisa', Colors.green, 'assets/easypaisa.png'),
        const SizedBox(height: 12),
        _walletButton('Pay with JazzCash', Colors.red, 'assets/jazzcash.png'),
        const SizedBox(height: 12),
        _walletButton('Pay with SadaPay', Colors.deepPurple, 'assets/sadapay.png'),
      ],
    );
  }

  // --- HELPER WIDGETS ---
  Widget _buildHandle() => Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)));

  Widget _buildHeader(String title, String sub) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
      ]),
      Text(sub, style: const TextStyle(color: Colors.grey)),
    ],
  );

  Widget _buildTab(String label, IconData icon, bool active, VoidCallback onTap) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(color: active ? Colors.white : Colors.transparent, borderRadius: BorderRadius.circular(10), boxShadow: active ? [const BoxShadow(color: Colors.black12, blurRadius: 4)] : []),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 18, color: active ? const Color(0xFF007BFF) : Colors.grey),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: active ? Colors.black : Colors.grey)),
        ]),
      ),
    ),
  );

  Widget _buildTextField(String label, String hint, IconData? icon) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      const SizedBox(height: 8),
      TextField(
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: icon != null ? Icon(icon, size: 20) : null,
          filled: true,
          fillColor: Colors.grey[50],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
      ),
    ],
  );

  Widget _walletButton(String label, Color color, String iconPath) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 16),
    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(16)),
    child: Center(child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
  );

  Widget _buildButton(String text, VoidCallback onPressed) => SizedBox(
    width: double.infinity,
    height: 55,
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF007BFF), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
      child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
    ),
  );

  Widget _packageCard({required String title, required String price, required List<String> features, bool isSelected = false}) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), border: Border.all(color: isSelected ? const Color(0xFF8B5CF6) : Colors.grey[200]!, width: 2)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(price, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF007BFF))),
      ]),
      const SizedBox(height: 12),
      ...features.map((f) => Row(children: [const Icon(Icons.check_circle, size: 16, color: Color(0xFF007BFF)), const SizedBox(width: 8), Text(f, style: const TextStyle(fontSize: 13))])),
    ]),
  );
}