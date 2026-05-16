import 'package:flutter/material.dart';

class BookSpotScreen extends StatelessWidget {
  const BookSpotScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Your Spot'),
        actions: [
          IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('GVK One Mall', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const Text('Banjara Hills, Road No. 1, Hyderabad, Telangana 500034'),
            const SizedBox(height: 16),
            Row(
              children: const [
                Icon(Icons.access_time, size: 16, color: Colors.green),
                SizedBox(width: 4),
                Text('Open 24/7', style: TextStyle(color: Colors.green)),
                SizedBox(width: 16),
                Icon(Icons.local_parking, size: 16, color: Colors.green),
                SizedBox(width: 4),
                Text('45 Available spots', style: TextStyle(color: Colors.green)),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: _buildTextField(label: 'Vehicle Number', initialValue: 'TS09ER1234')),
                const SizedBox(width: 16),
                Expanded(child: _buildDropdownField(label: 'Duration', items: ['2 hours', '4 hours', '6 hours'])),
              ],
            ),
            const SizedBox(height: 24),
            _buildPriceBreakdown(),
            const SizedBox(height: 24),
            const Text('Other Services (Optional)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            _buildOptionalServices(),
            const SizedBox(height: 24),
            const Text('Choose Payment Option', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            _buildPaymentOptions(),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow[700], minimumSize: const Size.fromHeight(50)),
          child: const Text('Confirm Booking - ₹60', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
        ),
      ),
    );
  }

  Widget _buildTextField({required String label, required String initialValue}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: initialValue,
          decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
        ),
      ],
    );
  }

  Widget _buildDropdownField({required String label, required List<String> items}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        DropdownButtonFormField(
          value: items.first,
          items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
          onChanged: (value) {},
          decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
        ),
      ],
    );
  }

  Widget _buildPriceBreakdown() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Price Breakdown', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const Divider(height: 24),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: const [Text('Base parking fee'), Text('₹30')]),
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: const [Text('Hourly rate x 2 hours'), Text('₹30')]),
            const Divider(height: 24),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: const [Text('Total Amount', style: TextStyle(fontWeight: FontWeight.bold)), Text('₹60', style: TextStyle(fontWeight: FontWeight.bold))]),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionalServices() {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: [
        _buildServiceChip(Icons.ev_station, 'EV Charge', '+₹50'),
        _buildServiceChip(Icons.wash, 'Car Wash', '+₹150'),
        _buildServiceChip(Icons.local_parking_outlined, 'Valet', '+₹100'),
      ],
    );
  }

  Widget _buildServiceChip(IconData icon, String label, String price) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              Text(price, style: const TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOptions() {
    return Row(
      children: [
        Expanded(
          child: Card(
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: const BorderSide(color: Colors.green, width: 2)),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: const [
                  Text('Pay Now', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 14)),
                  SizedBox(height: 4),
                  Text('Instant confirmation', textAlign: TextAlign.center, style: TextStyle(fontSize: 10)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Card(
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: const [
                  Text('Pay Later', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  SizedBox(height: 4),
                  Text('Pay at exit', textAlign: TextAlign.center, style: TextStyle(fontSize: 10)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
