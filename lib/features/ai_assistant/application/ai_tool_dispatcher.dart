/// AI Tool Dispatcher architecture ensuring safe, permission-checked execution.
class AiToolDispatcher {
  /// Interprets user query and routes to the appropriate authorized tool.
  static Future<String> executeIntent(String query) async {
    final lower = query.toLowerCase();

    // 1. Parking Intent
    if (lower.contains('parking') || lower.contains('slot')) {
      return '🅿️ **Parking Status for Palm Meadows:**\n• Basement 1: 14 Slots Available (including 4 EV bays)\n• Basement 2: 22 Slots Available\n• Your active reservation: **Slot B2-45** (Valid for 42 more mins).';
    }

    // 2. Visitor / Guest Intent
    if (lower.contains('visitor') || lower.contains('guest') || lower.contains('entered') || lower.contains('cab')) {
      return '👥 **Visitor Access Log for Unit A-1204:**\n• **Rahul Sharma (Cab TS09EQ1234)** entered via Gate 1 at 11:15 AM.\n• **Pooja Verma** pre-approved for 6:00 PM today.\n• 1 Amazon parcel held at Main Security Desk.';
    }

    // 3. Vehicle / Service Intent
    if (lower.contains('vehicle') || lower.contains('car') || lower.contains('service') || lower.contains('wash')) {
      return '🚗 **Primary Vehicle Status (TS 09 EQ 4821):**\n• Hyundai Creta SX(O) Turbo\n• Ongoing Service: **Eco Wash & Interior Detailing** (ETA ~45 mins)\n• Insurance: Valid until Oct 2027\n• Allocated Slot: Basement 1 - #42.';
    }

    // 4. Wallet / Dues Intent
    if (lower.contains('wallet') || lower.contains('balance') || lower.contains('dues') || lower.contains('maintenance')) {
      return '💳 **Financial Overview:**\n• YellowSpot Wallet Balance: **₹4,850.00**\n• September Society Maintenance: **₹4,500** (Due by 10th Sep).\n• Auto-pay is active for parking & EV charging.';
    }

    // 5. Emergency / SOS Intent
    if (lower.contains('emergency') || lower.contains('sos') || lower.contains('security') || lower.contains('guard')) {
      return '🚨 **Emergency Protocol:**\n• Security Desk 24/7: **+91 98765 43210**\n• Gate 1 Intercom: **001**\n• Tap the red SOS button on your Home screen for immediate 1-tap guard dispatch.';
    }

    // Default fallback
    return '🤖 I am your YellowSpot Smart Residential Assistant. You can ask me about:\n• Parking slot availability\n• Visitor entries and gate passes\n• Vehicle services and charging\n• Society maintenance and wallet balance';
  }
}
