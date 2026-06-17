import 'package:flutter/material.dart';
import 'package:frontend/widgets/app_theme.dart';

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
      decoration: BoxDecoration(
        color: AppTheme.dialogBg(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.all(24),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _currentStep == 0 ? _buildPlansStep() : _buildPaymentStep(),
      ),
    );
  }


  Widget _buildPlansStep() {
    return Column(
      key: const ValueKey(0),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(child: _buildHandle(context)),
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


  Widget _buildPaymentStep() {
    return Column(
      key: const ValueKey(1),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(child: _buildHandle(context)),
        const SizedBox(height: 24),
        _buildHeader('💳 Payment', 'Premium Package - Rs699'),
        const SizedBox(height: 20),


        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(color: AppTheme.inputFill(context), borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: [
              _buildTab('Debit/Credit', Icons.credit_card, !_isDigitalWallet, () => setState(() => _isDigitalWallet = false)),
              _buildTab('Digital Wallet', Icons.account_balance_wallet, _isDigitalWallet, () => setState(() => _isDigitalWallet = true)),
            ],
          ),
        ),
        const SizedBox(height: 24),


        _isDigitalWallet ? _buildDigitalWalletView() : _buildCardView(),

        const Spacer(),
        _buildButton(_isDigitalWallet ? 'Select Provider' : 'Pay Now Rs699', () {}),
        Center(
          child: TextButton(
            onPressed: () => setState(() => _currentStep = 0),
            child: Text('← Back to plans', style: TextStyle(color: AppTheme.secondaryText(context))),
          ),
        ),
      ],
    );
  }


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


  Widget _buildHandle(BuildContext context) => Container(
    width: 40,
    height: 4,
    decoration: BoxDecoration(
      color: AppTheme.borderColor(context),
      borderRadius: BorderRadius.circular(2),
    ),
  );

  Widget _buildHeader(String title, String sub) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryText(context),
          ),
        ),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.close, color: AppTheme.iconColor(context)),
        ),
      ]),
      Text(sub, style: TextStyle(color: AppTheme.secondaryText(context))),
    ],
  );

  Widget _buildTab(String label, IconData icon, bool active, VoidCallback onTap) {
    final isDark = AppTheme.isDark(context);
    final activeBg = isDark ? const Color(0xFF333333) : Colors.white;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: active ? activeBg : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: active ? [BoxShadow(color: isDark ? Colors.black26 : Colors.black12, blurRadius: 4)] : [],
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(
              icon,
              size: 18,
              color: active ? (isDark ? Colors.blueAccent : const Color(0xFF007BFF)) : AppTheme.secondaryText(context),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: active ? AppTheme.primaryText(context) : AppTheme.secondaryText(context),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String hint, IconData? icon) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: AppTheme.primaryText(context),
        ),
      ),
      const SizedBox(height: 8),
      TextField(
        style: TextStyle(color: AppTheme.primaryText(context)),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: AppTheme.secondaryText(context)),
          prefixIcon: icon != null ? Icon(icon, size: 20, color: AppTheme.secondaryText(context)) : null,
          filled: true,
          fillColor: AppTheme.inputFill(context),
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

  Widget _buildButton(String text, VoidCallback onPressed) {
    final isDark = AppTheme.isDark(context);
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isDark ? Colors.blueAccent : const Color(0xFF007BFF),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }

  Widget _packageCard({required String title, required String price, required List<String> features, bool isSelected = false}) {
    final isDark = AppTheme.isDark(context);
    final accentColor = isDark ? Colors.blueAccent : const Color(0xFF007BFF);
    final selectedBorder = isDark ? Colors.blueAccent : const Color(0xFF8B5CF6);
    final defaultBorder = AppTheme.borderColor(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.cardBg(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isSelected ? selectedBorder : defaultBorder, width: 2),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryText(context),
            ),
          ),
          Text(
            price,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: accentColor,
            ),
          ),
        ]),
        const SizedBox(height: 12),
        ...features.map((f) => Padding(
          padding: const EdgeInsets.only(bottom: 6.0),
          child: Row(children: [
            Icon(Icons.check_circle, size: 16, color: accentColor),
            const SizedBox(width: 8),
            Text(
              f,
              style: TextStyle(fontSize: 13, color: AppTheme.secondaryText(context)),
            ),
          ]),
        )),
      ]),
    );
  }
}